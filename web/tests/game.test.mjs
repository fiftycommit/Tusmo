import test from 'node:test';
import assert from 'node:assert/strict';

import { evaluate, finish, profile, select } from '../public/game.mjs';

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

test('une victoire rapide augmente le niveau du thème sans dépasser le maximum', () => {
  const player = profile('Test');
  player.niveauxParTheme.test = 1;
  player.seriesRapidesParTheme.test = 1;
  const result = finish(player, 'test', 'ALPHA', true, 1, 6, 1);
  assert.equal(result, 190);
  assert.equal(player.motsTrouvesParTheme.test[0], 'ALPHA');
  assert.equal(player.niveauxParTheme.test, 2);
});
