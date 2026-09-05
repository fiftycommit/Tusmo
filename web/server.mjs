import { createReadStream, existsSync, readFileSync } from 'node:fs';
import { mkdir } from 'node:fs/promises';
import { createServer } from 'node:http';
import { promisify } from 'node:util';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import crypto from 'node:crypto';
import { Pool } from 'pg';

const port = Number.parseInt(process.env.PORT ?? '3000', 10);
const databaseUrl = process.env.DATABASE_URL;
const cookieSecure = process.env.COOKIE_SECURE === 'true';
const publicDirectory = path.resolve(fileURLToPath(new URL('./public/', import.meta.url)));
const schema = readFileSync(new URL('./schema.sql', import.meta.url), 'utf8');
const sessionCookieName = 'tusmo_session';
const sessionDurationMs = 30 * 24 * 60 * 60 * 1000;
const maxBodyBytes = 1_000_000;
const scryptAsync = promisify(crypto.scrypt);
const loginAttempts = new Map();

if (!databaseUrl) {
  console.error('DATABASE_URL est obligatoire');
  process.exit(1);
}

const pool = new Pool({
  connectionString: databaseUrl,
  max: 10,
  connectionTimeoutMillis: 5_000,
  idleTimeoutMillis: 30_000,
  maxUses: 10_000,
});

function json(response, status, payload, headers = {}) {
  const body = JSON.stringify(payload);
  response.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Content-Length': Buffer.byteLength(body),
    'Cache-Control': 'no-store',
    ...headers,
  });
  response.end(body);
}

function empty(response, status, headers = {}) {
  response.writeHead(status, { 'Cache-Control': 'no-store', ...headers });
  response.end();
}

function publicUser(row) {
  return { id: row.id, email: row.email };
}

function normalizeEmail(value) {
  return typeof value === 'string' ? value.trim().toLowerCase() : '';
}

function validEmail(email) {
  return email.length >= 3 && email.length <= 254 && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function validPassword(password) {
  return typeof password === 'string' && password.length >= 12 && password.length <= 256;
}

function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

async function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString('hex');
  const key = await scryptAsync(password, salt, 64, {
    N: 16_384,
    r: 8,
    p: 1,
    maxmem: 64 * 1024 * 1024,
  });
  return `scrypt$16384$8$1$${salt}$${Buffer.from(key).toString('hex')}`;
}

async function verifyPassword(password, encoded) {
  const [algorithm, nValue, rValue, pValue, salt, expectedHex] = String(encoded).split('$');
  if (algorithm !== 'scrypt' || !salt || !expectedHex) return false;

  const expected = Buffer.from(expectedHex, 'hex');
  const actual = Buffer.from(await scryptAsync(password, salt, expected.length, {
    N: Number(nValue),
    r: Number(rValue),
    p: Number(pValue),
    maxmem: 64 * 1024 * 1024,
  }));

  return actual.length === expected.length && crypto.timingSafeEqual(actual, expected);
}

function parseCookies(request) {
  const cookies = {};
  for (const part of request.headers.cookie?.split(';') ?? []) {
    const separator = part.indexOf('=');
    if (separator === -1) continue;
    const key = part.slice(0, separator).trim();
    const value = part.slice(separator + 1).trim();
    cookies[key] = decodeURIComponent(value);
  }
  return cookies;
}

function sessionCookie(token, maxAge = sessionDurationMs / 1000) {
  const flags = [
    `${sessionCookieName}=${encodeURIComponent(token)}`,
    'Path=/',
    'HttpOnly',
    'SameSite=Lax',
    `Max-Age=${Math.max(0, Math.floor(maxAge))}`,
  ];
  if (cookieSecure) flags.push('Secure');
  return flags.join('; ');
}

async function createSession(userId) {
  const token = crypto.randomBytes(32).toString('base64url');
  const expiresAt = new Date(Date.now() + sessionDurationMs);
  await pool.query(
    'INSERT INTO sessions (token_hash, user_id, expires_at) VALUES ($1, $2, $3)',
    [hashToken(token), userId, expiresAt],
  );
  return { token, expiresAt };
}

async function currentUser(request) {
  const token = parseCookies(request)[sessionCookieName];
  if (!token) return null;

  const result = await pool.query(
    `SELECT u.id, u.email
       FROM sessions s
       JOIN users u ON u.id = s.user_id
      WHERE s.token_hash = $1 AND s.expires_at > now()`,
    [hashToken(token)],
  );
  return result.rows[0] ?? null;
}

function rateLimitKey(request, email) {
  return `${request.socket.remoteAddress ?? 'unknown'}:${email}`;
}

function canAttempt(key) {
  const now = Date.now();
  const existing = loginAttempts.get(key);
  if (!existing || existing.resetAt <= now) {
    loginAttempts.set(key, { count: 1, resetAt: now + 15 * 60 * 1000 });
    return true;
  }
  if (existing.count >= 10) return false;
  existing.count += 1;
  return true;
}

function clearAttempts(key) {
  loginAttempts.delete(key);
}

function readJson(request) {
  return new Promise((resolve, reject) => {
    let total = 0;
    const chunks = [];

    request.on('data', (chunk) => {
      total += chunk.length;
      if (total > maxBodyBytes) {
        reject(Object.assign(new Error('Payload too large'), { statusCode: 413 }));
        request.destroy();
        return;
      }
      chunks.push(chunk);
    });

    request.on('end', () => {
      try {
        const raw = Buffer.concat(chunks).toString('utf8');
        resolve(raw ? JSON.parse(raw) : {});
      } catch {
        reject(Object.assign(new Error('Invalid JSON'), { statusCode: 400 }));
      }
    });

    request.on('error', reject);
  });
}

function validGameState(state) {
  if (!state || typeof state !== 'object' || Array.isArray(state)) return false;
  if (!Array.isArray(state.profils) || state.profils.length > 32) return false;

  return state.profils.every((profile) => {
    if (!profile || typeof profile !== 'object') return false;
    if (typeof profile.id !== 'string' || profile.id.length > 80) return false;
    if (typeof profile.nom !== 'string' || profile.nom.length > 80) return false;
    if (!profile.motsTrouvesParTheme || typeof profile.motsTrouvesParTheme !== 'object') return false;
    return Object.values(profile.motsTrouvesParTheme).every((words) => (
      Array.isArray(words) && words.length <= 2_000 && words.every((word) => (
        typeof word === 'string' && word.length <= 100
      ))
    ));
  });
}

function contentType(filePath) {
  const extension = path.extname(filePath).toLowerCase();
  return {
    '.html': 'text/html; charset=utf-8',
    '.css': 'text/css; charset=utf-8',
    '.js': 'text/javascript; charset=utf-8',
    '.mjs': 'text/javascript; charset=utf-8',
    '.json': 'application/json; charset=utf-8',
    '.svg': 'image/svg+xml',
    '.png': 'image/png',
    '.ico': 'image/x-icon',
  }[extension] ?? 'application/octet-stream';
}

async function serveStatic(request, response, pathname) {
  let decodedPath;
  try {
    decodedPath = decodeURIComponent(pathname);
  } catch {
    json(response, 400, { error: 'invalid_path' });
    return;
  }

  const relativePath = decodedPath === '/' ? '/index.html' : decodedPath;
  const filePath = path.resolve(publicDirectory, `.${relativePath}`);
  if (filePath !== publicDirectory && !filePath.startsWith(`${publicDirectory}${path.sep}`)) {
    json(response, 404, { error: 'not_found' });
    return;
  }
  if (!existsSync(filePath)) {
    json(response, 404, { error: 'not_found' });
    return;
  }

  response.writeHead(200, {
    'Content-Type': contentType(filePath),
    'Cache-Control': filePath.endsWith('banks.json') ? 'public, max-age=300' : 'no-cache',
  });
  createReadStream(filePath).on('error', () => response.destroy()).pipe(response);
}

async function stateGet(request, response) {
  const user = await currentUser(request);
  if (!user) return json(response, 401, { error: 'unauthorized' });

  const result = await pool.query(
    'SELECT revision, state FROM game_states WHERE user_id = $1',
    [user.id],
  );
  const row = result.rows[0];
  return json(response, 200, {
    revision: row?.revision ?? 0,
    state: row?.state ?? null,
  });
}

async function statePut(request, response) {
  const user = await currentUser(request);
  if (!user) return json(response, 401, { error: 'unauthorized' });

  const body = await readJson(request);
  const revision = Number(body.revision);
  if (!Number.isInteger(revision) || revision < 0 || !validGameState(body.state)) {
    return json(response, 400, { error: 'invalid_state' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await client.query(
      'SELECT revision, state FROM game_states WHERE user_id = $1 FOR UPDATE',
      [user.id],
    );
    const existing = result.rows[0];
    const currentRevision = existing?.revision ?? 0;

    if (revision !== currentRevision) {
      await client.query('ROLLBACK');
      return json(response, 409, {
        error: 'state_conflict',
        revision: currentRevision,
        state: existing?.state ?? null,
      });
    }

    const nextRevision = currentRevision + 1;
    if (existing) {
      await client.query(
        'UPDATE game_states SET revision = $1, state = $2, updated_at = now() WHERE user_id = $3',
        [nextRevision, body.state, user.id],
      );
    } else {
      await client.query(
        'INSERT INTO game_states (user_id, revision, state) VALUES ($1, $2, $3)',
        [user.id, nextRevision, body.state],
      );
    }
    await client.query('COMMIT');
    return json(response, 200, { revision: nextRevision });
  } catch (error) {
    await client.query('ROLLBACK').catch(() => {});
    throw error;
  } finally {
    client.release();
  }
}

async function register(request, response) {
  const body = await readJson(request);
  const email = normalizeEmail(body.email);
  const password = body.password;
  if (!validEmail(email) || !validPassword(password)) {
    return json(response, 400, { error: 'invalid_credentials' });
  }

  const passwordHash = await hashPassword(password);
  const userId = crypto.randomUUID();
  try {
    const result = await pool.query(
      'INSERT INTO users (id, email, password_hash) VALUES ($1, $2, $3) RETURNING id, email',
      [userId, email, passwordHash],
    );
    const session = await createSession(result.rows[0].id);
    return json(response, 201, { user: publicUser(result.rows[0]) }, {
      'Set-Cookie': sessionCookie(session.token),
    });
  } catch (error) {
    if (error?.code === '23505') return json(response, 409, { error: 'email_taken' });
    throw error;
  }
}

async function login(request, response) {
  const body = await readJson(request);
  const email = normalizeEmail(body.email);
  const password = body.password;
  const key = rateLimitKey(request, email);
  if (!canAttempt(key)) return json(response, 429, { error: 'too_many_attempts' });
  if (!validEmail(email) || !validPassword(password)) {
    return json(response, 401, { error: 'invalid_credentials' });
  }

  const result = await pool.query(
    'SELECT id, email, password_hash FROM users WHERE email = $1',
    [email],
  );
  const row = result.rows[0];
  if (!row || !(await verifyPassword(password, row.password_hash))) {
    return json(response, 401, { error: 'invalid_credentials' });
  }

  clearAttempts(key);
  await pool.query('UPDATE users SET last_login_at = now() WHERE id = $1', [row.id]);
  await pool.query('DELETE FROM sessions WHERE user_id = $1 OR expires_at <= now()', [row.id]);
  const session = await createSession(row.id);
  return json(response, 200, { user: publicUser(row) }, {
    'Set-Cookie': sessionCookie(session.token),
  });
}

async function logout(request, response) {
  const token = parseCookies(request)[sessionCookieName];
  if (token) await pool.query('DELETE FROM sessions WHERE token_hash = $1', [hashToken(token)]);
  return empty(response, 204, { 'Set-Cookie': sessionCookie('', 0) });
}

function applyCors(response) {
  const origin = process.env.CORS_ORIGIN;
  if (!origin) return;
  response.setHeader('Access-Control-Allow-Origin', origin);
  response.setHeader('Access-Control-Allow-Credentials', 'true');
  response.setHeader('Vary', 'Origin');
}

const server = createServer(async (request, response) => {
  applyCors(response);
  response.setHeader('X-Content-Type-Options', 'nosniff');
  response.setHeader('Referrer-Policy', 'same-origin');

  try {
    const url = new URL(request.url ?? '/', `http://${request.headers.host ?? 'localhost'}`);
    const { pathname } = url;

    if (request.method === 'OPTIONS' && pathname.startsWith('/api/')) {
      response.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,OPTIONS');
      response.setHeader('Access-Control-Allow-Headers', 'Content-Type');
      return empty(response, 204);
    }

    if (request.method === 'GET' && pathname === '/healthz') {
      await pool.query('SELECT 1');
      return json(response, 200, { ok: true, db: true });
    }

    if (pathname === '/api/register' && request.method === 'POST') return register(request, response);
    if (pathname === '/api/login' && request.method === 'POST') return login(request, response);
    if (pathname === '/api/logout' && request.method === 'POST') return logout(request, response);

    if (pathname === '/api/me' && request.method === 'GET') {
      const user = await currentUser(request);
      return user ? json(response, 200, { user: publicUser(user) }) : json(response, 401, { error: 'unauthorized' });
    }
    if (pathname === '/api/state' && request.method === 'GET') return stateGet(request, response);
    if (pathname === '/api/state' && request.method === 'PUT') return statePut(request, response);

    if (pathname.startsWith('/api/')) return json(response, 404, { error: 'not_found' });
    if (request.method !== 'GET' && request.method !== 'HEAD') return json(response, 405, { error: 'method_not_allowed' });
    return serveStatic(request, response, pathname);
  } catch (error) {
    if (response.headersSent) return response.destroy();
    const status = Number.isInteger(error?.statusCode) ? error.statusCode : 500;
    if (status >= 500) console.error(error);
    return json(response, status, { error: status === 500 ? 'server_error' : error.message });
  }
});

server.requestTimeout = 60_000;
server.headersTimeout = 65_000;
server.keepAliveTimeout = 5_000;

async function start() {
  await mkdir(publicDirectory, { recursive: true });
  await pool.query(schema);
  await pool.query('DELETE FROM sessions WHERE expires_at <= now()');
  server.listen(port, '0.0.0.0', () => console.log(`Tusmo web écoute sur le port ${port}`));
}

async function shutdown(signal) {
  console.log(`${signal}: arrêt de Tusmo web`);
  server.close(async () => {
    await pool.end();
    process.exit(0);
  });
  setTimeout(() => process.exit(1), 10_000).unref();
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));

start().catch(async (error) => {
  console.error('Impossible de démarrer Tusmo web', error);
  await pool.end().catch(() => {});
  process.exit(1);
});
