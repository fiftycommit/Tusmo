import {readFileSync, writeFileSync} from 'node:fs';

const motsSource = readFileSync(new URL('../Tusmo/Mots.swift', import.meta.url), 'utf8');
const taxonomySource = readFileSync(new URL('../Tusmo/SousThemes.swift', import.meta.url), 'utf8');

function matchingBracket(source, start) {
  const opening = source[start];
  const closing = opening === '[' ? ']' : opening === '(' ? ')' : '}';
  let depth = 0;
  let inString = false;
  let escaped = false;

  for (let index = start; index < source.length; index += 1) {
    const character = source[index];
    if (inString) {
      if (escaped) escaped = false;
      else if (character === '\\') escaped = true;
      else if (character === '"') inString = false;
      continue;
    }
    if (character === '"') {
      inString = true;
      continue;
    }
    if (character === opening) depth += 1;
    if (character === closing) {
      depth -= 1;
      if (depth === 0) return index;
    }
  }
  throw new Error(`Bloc Swift non terminé à ${start}`);
}

function extractArray(source, marker) {
  const markerIndex = source.indexOf(marker);
  if (markerIndex < 0) throw new Error(`Bloc introuvable : ${marker}`);
  const start = source.indexOf('[', source.indexOf('=', markerIndex));
  const end = matchingBracket(source, start);
  return source.slice(start, end + 1);
}

function parseSwiftGroups(source) {
  const section = source.split('static let groupesParTheme:')[1].split('static func poidsParTheme')[0];
  const banks = [];
  for (const match of section.matchAll(/"([^"\n]+)":\s*(\[[\s\S]*?\n        \])/g)) {
    const groups = JSON.parse(match[2].replace(/,\s*]/g, ']'));
    if (groups.length !== 5) throw new Error(`Niveaux manquants pour ${match[1]}`);
    banks.push({id: `theme.${match[1]}`, name: match[1], groups});
  }
  return banks;
}

function parsePokemonGroups(source) {
  const section = source.split('private var motsParNiveau:')[1].split('/// Liste aplatie')[0];
  const banks = [];
  for (const match of section.matchAll(/return (\[[\s\S]*?\n            \])/g)) {
    banks.push(JSON.parse(match[1].replace(/,\s*]/g, ']')));
  }
  return banks;
}

function parseTaxonomy(source) {
  const classificationsBlock = extractArray(
    source,
    'private static let classificationsParTheme:'
  );
  const tagsByTheme = {};
  const themePattern = /"([^"\n]+)":\s*classifications\(\[/g;

  for (const match of classificationsBlock.matchAll(themePattern)) {
    const opening = classificationsBlock.indexOf('[', match.index);
    const end = matchingBracket(classificationsBlock, opening);
    const body = classificationsBlock.slice(opening + 1, end);
    const tags = {};
    const categoryPattern = /"([^"\n]+)":\s*\[([\s\S]*?)\]/g;
    for (const category of body.matchAll(categoryPattern)) {
      tags[category[1]] = [...category[2].matchAll(/"([^"\n]+)"/g)].map((word) => word[1]);
    }
    tagsByTheme[match[1]] = tags;
  }

  const definitionsBlock = extractArray(source, 'static let definitionsParTheme:');
  const definitionsByTheme = {};
  const definitionPattern = /"([^"\n]+)":\s*\[([\s\S]*?)\n\s*\],/g;
  for (const match of definitionsBlock.matchAll(definitionPattern)) {
    definitionsByTheme[match[1]] = [...match[2].matchAll(
      /SousTheme\(id:\s*"([^"]+)",\s*nom:\s*"([^"]+)",\s*emoji:\s*"([^"]*)"\)/g
    )].map((entry) => ({id: entry[1], name: entry[2], emoji: entry[3] || null}));
  }

  const cityNamesBlock = extractArray(source, 'private static let nomsPaysVilles:');
  const cityNames = Object.fromEntries(
    [...cityNamesBlock.matchAll(/"([^"]+)":\s*"([^"]+)"/g)].map((entry) => [entry[1], entry[2]])
  );

  const taxonomy = {};
  for (const [theme, categories] of Object.entries(tagsByTheme)) {
    const tags = {};
    for (const [category, words] of Object.entries(categories)) {
      for (const word of words) {
        tags[word] ??= [];
        if (!tags[word].includes(category)) tags[word].push(category);
      }
    }

    const ids = new Set(Object.values(tags).flat());
    const subthemes = theme === 'Villes'
      ? [...ids]
        .sort((left, right) => (cityNames[left] || left).localeCompare(cityNames[right] || right, 'fr'))
        .map((id) => ({id, name: cityNames[id] || id, emoji: '🌍'}))
      : (definitionsByTheme[theme] || []).filter((subtheme) => ids.has(subtheme.id));

    taxonomy[theme] = {subthemes, tags};
  }
  return taxonomy;
}

const banks = parseSwiftGroups(motsSource);
const pokemonGroups = parsePokemonGroups(
  readFileSync(new URL('../Tusmo/Pokemon.swift', import.meta.url), 'utf8')
);
pokemonGroups.forEach((groups, index) => {
  banks.push({
    id: `pokemon.generation.${index + 1}`,
    name: `Pokémon · Génération ${index + 1}`,
    groups,
    subthemes: [],
    tags: {},
  });
});

if (banks.length !== 27 || pokemonGroups.length !== 9) throw new Error('Banques manquantes');

const emojis = ['🏀', '🎵', '🎤', '🍕', '🐾', '✈️', '🏙️', '🎬', '🎓', '💻', '📱', '🌳', '🏠', '🍩', '🏔️', '🍎', '🌍', '🛋️'];
const taxonomy = parseTaxonomy(taxonomySource);

banks.forEach((bank, index) => {
  bank.emoji = emojis[index] || '⚡';
  const words = new Set(bank.groups.flat());
  if (words.size !== bank.groups.flat().length) throw new Error(`Doublon ${bank.name}`);

  const metadata = taxonomy[bank.name] || {subthemes: [], tags: {}};
  for (const word of Object.keys(metadata.tags)) {
    if (!words.has(word)) throw new Error(`Mot classifié absent de ${bank.name}: ${word}`);
  }
  bank.subthemes = metadata.subthemes;
  bank.tags = metadata.tags;
});

const seen = new Set();
const mixed = [[], [], [], [], []];
for (const bank of banks.slice(0, 18)) {
  bank.groups.forEach((group, index) => group.forEach((word) => {
    if (!seen.has(word)) {
      mixed[index].push(word);
      seen.add(word);
    }
  }));
}
banks.push({id: 'theme.Mélange', name: 'Mélange', emoji: '🎲', groups: mixed, subthemes: [], tags: {}});

writeFileSync(new URL('./public/banks.json', import.meta.url), JSON.stringify(banks));
console.log(`${banks.length} banques exportées`);
