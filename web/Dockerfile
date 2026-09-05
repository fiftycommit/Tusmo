FROM node:24-bookworm-slim

WORKDIR /app

COPY web/package.json web/package-lock.json /app/web/
WORKDIR /app/web
RUN npm ci --omit=dev

WORKDIR /app
COPY Tusmo/Mots.swift /app/Tusmo/Mots.swift
COPY Tusmo/Pokemon.swift /app/Tusmo/Pokemon.swift
COPY web /app/web
RUN node /app/web/export-banks.mjs
RUN chown -R node:node /app

USER node
WORKDIR /app/web
ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "server.mjs"]
