import test from 'node:test';
import assert from 'node:assert/strict';

import {
  evaluate,
  finish,
  maxUnlockedLevel,
  profile,
  select,
} from '../public/game.mjs';

test('évalue correctement les lettres en double', () => {
  assert.deepEqual(evaluate('PAPAYE', 'PAPAYE'), ['correct', 'correct', 'correct', 'correct', 'correct', 'correct']);
  assert.deepEqual(evaluate('ABBA', 'BAAA'), ['present', 'present', 'absent', 'correct']);
});

test('la sélection respecte la progression et exclut les mots trouvés', () => {
  const bank = {
    id: 'test',
    groups: [
      ['ALPHA', 'BETA'],
      ['GAMMA'],
    ],
  };
  const player = profile('Test');
  player.motsTrouvesParTheme.test = ['ALPHA'];
  const picked = select(bank, player);
  assert.notEqual(picked.word, 'ALPHA');
  assert.ok(['BETA', 'GAMMA'].includes(picked.word));
});

test('la sélection applique le sous-thème avant la difficulté et garde le niveau du thème', () => {
  const bank = {
    id: 'pays',
    groups: [
      ['FRANCE'],
      ['BURUNDI'],
      ['JAPON'],
    ],
    tags: {
      FRANCE: ['europe'],
      BURUNDI: ['afrique'],
      JAPON: ['asie'],
    },
  };
  const player = profile('Test');
  player.niveauxParTheme.pays = 2;
  const picked = select(bank, player, 'afrique');
  assert.equal(picked.word, 'BURUNDI');
  assert.equal(picked.level, 2);
});

test('un sous-thème terminé ne déborde pas sur les autres catégories', () => {
  const bank = {
    id: 'pays',
    groups: [['FRANCE'], ['BURUNDI']],
    tags: { FRANCE: ['europe'], BURUNDI: ['afrique'] },
  };
  const player = profile('Test');
  player.motsTrouvesParTheme.pays = ['BURUNDI'];
  assert.equal(select(bank, player, 'afrique'), null);
  assert.equal(select(bank, player, 'europe').word, 'FRANCE');
});

test('une victoire rapide augmente le niveau du thème sans dépasser le maximum', () => {
  const player = profile('Test');
  player.niveauxParTheme.test = 1;
  player.seriesRapidesParTheme.test = 1;
  const result = finish(player, 'test', 'ALPHA', true, 1, 6, 1, 0.10);
  assert.equal(result, 190);
  assert.equal(player.motsTrouvesParTheme.test[0], 'ALPHA');
  assert.equal(player.niveauxParTheme.test, 2);
});

test('la performance ne débloque pas un niveau avant la découverte requise', () => {
  const player = profile('Test');
  player.seriesRapidesParTheme.test = 1;
  finish(player, 'test', 'ALPHA', true, 1, 6, 1, 0.01);
  assert.equal(player.niveauxParTheme.test, 1);
  assert.equal(player.experiencesParTheme.test, 2);
  assert.equal(maxUnlockedLevel(0.64), 4);
  assert.equal(maxUnlockedLevel(0.65), 5);
});
