export const levels = ['Débutant', 'Apprenti', 'Confirmé', 'Expert', 'Maître'];
export const discoveryThresholds = [0, 0.10, 0.25, 0.45, 0.65];
export const experienceRequired = [3, 6, 10, 15];

export const normalize = (value) => value
  .normalize('NFD')
  .replace(/[\u0300-\u036f]/g, '')
  .toUpperCase()
  .replace(/[^A-Z]/g, '');

function newID() {
  return globalThis.crypto?.randomUUID?.()
    ?? `${Date.now().toString(36)}-${Math.random().toString(36).slice(2)}`;
}

export function profile(name = 'Joueur 1', id = newID()) {
  return {
    id,
    nom: name,
    niveauxParTheme: {},
    experiencesParTheme: {},
    seriesRapidesParTheme: {},
    motsTrouvesParTheme: {},
    partiesJouees: 0,
    victoires: 0,
    scoreTotal: 0,
    meilleurScore: 0,
    meilleurScoreSurvie: 0,
    tournoisJoues: 0,
    tournoisGagnes: 0,
  };
}

export function maxUnlockedLevel(discoveryFraction) {
  const fraction = Math.min(Math.max(Number(discoveryFraction) || 0, 0), 1);
  let highest = 1;
  discoveryThresholds.forEach((threshold, index) => {
    if (fraction + 0.000001 >= threshold) highest = index + 1;
  });
  return highest;
}

export function effectiveLevel(bank, player) {
  const allWords = bank.groups.flat();
  const found = new Set(player.motsTrouvesParTheme[bank.id] || []);
  const discovery = allWords.length ? found.size / allWords.length : 0;
  return Math.min(
    player.niveauxParTheme[bank.id] || 1,
    maxUnlockedLevel(discovery),
  );
}

export function evaluate(word, guess) {
  const result = Array(word.length).fill('absent');
  const left = [...word];
  [...guess].forEach((character, index) => {
    if (character === word[index]) {
      result[index] = 'correct';
      left[index] = null;
    }
  });
  [...guess].forEach((character, index) => {
    if (result[index] === 'correct') return;
    const position = left.indexOf(character);
    if (position >= 0) {
      result[index] = 'present';
      left[position] = null;
    }
  });
  return result;
}

export function select(bank, player, filterId = '__all__') {
  const found = new Set(player.motsTrouvesParTheme[bank.id] || []);
  const storedLevel = player.niveauxParTheme[bank.id] || 1;
  const level = effectiveLevel(bank, player);
  if (storedLevel > level) {
    player.niveauxParTheme[bank.id] = level;
    player.experiencesParTheme[bank.id] = 0;
    player.seriesRapidesParTheme[bank.id] = 0;
  }

  const filteredWords = filterId === '__all__'
    ? null
    : new Set(Object.entries(bank.tags || {})
      .filter(([, tags]) => tags.includes(filterId))
      .map(([word]) => word));
  const candidates = bank.groups.flatMap((group, index) => group
    .filter((word) => !found.has(word) && (!filteredWords || filteredWords.has(word)))
    .map((word) => ({ word, level: index + 1 })));
  if (!candidates.length) return null;

  const distance = Math.min(...candidates.map((candidate) => (
    Math.abs(candidate.level - level)
  )));
  const pool = candidates.filter((candidate) => (
    Math.abs(candidate.level - level) === distance
  ));
  return pool[Math.floor(Math.random() * pool.length)];
}

export function finish(
  player,
  key,
  word,
  won,
  attempts,
  maxAttempts,
  wordLevel,
  discoveryFraction = 0,
) {
  player.partiesJouees++;
  if (!won) {
    player.niveauxParTheme[key] = Math.max(
      1,
      (player.niveauxParTheme[key] || 1) - 1,
    );
    player.experiencesParTheme[key] = 0;
    player.seriesRapidesParTheme[key] = 0;
    return 0;
  }

  const points = Math.round(
    (50 + word.length * 10 + (maxAttempts - attempts + 1) * 15)
    * (1 + (wordLevel - 1) * 0.15),
  );
  player.victoires++;
  player.scoreTotal += points;
  player.meilleurScore = Math.max(player.meilleurScore, points);
  player.motsTrouvesParTheme[key] = [
    ...new Set([...(player.motsTrouvesParTheme[key] || []), word]),
  ];

  const maximum = maxUnlockedLevel(discoveryFraction);
  let level = Math.min(player.niveauxParTheme[key] || 1, maximum);
  let experience = player.experiencesParTheme[key] || 0;
  if ((player.niveauxParTheme[key] || 1) > level) {
    player.niveauxParTheme[key] = level;
    player.experiencesParTheme[key] = 0;
    player.seriesRapidesParTheme[key] = 0;
    experience = 0;
  }

  if (level === 5) {
    player.seriesRapidesParTheme[key] = 0;
    return points;
  }

  const quick = attempts <= Math.floor(maxAttempts / 2);
  const streak = player.seriesRapidesParTheme[key] || 0;
  let gain = quick ? Math.min(4, 2 + streak) : 1;
  player.seriesRapidesParTheme[key] = quick ? Math.min(3, streak + 1) : 0;

  while (gain > 0 && level < 5) {
    const required = experienceRequired[level - 1];
    const total = experience + gain;
    const nextLevel = level + 1;
    if (total < required) {
      experience = total;
      gain = 0;
      continue;
    }

    if (discoveryFraction + 0.000001 < discoveryThresholds[nextLevel - 1]) {
      experience = Math.max(required - 1, 0);
      gain = 0;
      continue;
    }

    level = nextLevel;
    experience = 0;
    gain = total - required;
  }

  player.niveauxParTheme[key] = level;
  player.experiencesParTheme[key] = experience;
  return points;
}
