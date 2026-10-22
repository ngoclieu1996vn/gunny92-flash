const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
// Execute the actual dependency-free AS3 decision body with backend quest fixtures.
const source = fs.readFileSync(path.join(__dirname, 'client-patches/sevenday/SevendayManager.as'), 'utf8');
const body = source.split('public function isNotAllAchieved')[1].split('private function updateTime')[0];
const js = body.slice(body.indexOf('{') + 1, body.lastIndexOf('}')).replace(/(var\s+\w+)\s*:\s*\w+/g, '$1');
function evaluate(quests, ignored = 0) {
  return vm.runInNewContext('(function(param1){' + js + '})(ignored)', {
    ignored,
    SevendayManager: { QUEST_LIST_1: [3201,3202,3203,3204,3205,3206,3207], QUEST_LIST_2: [3208,3209,3210,3211,3212,3213,3214] },
    TaskManager: { instance: { getQuestByID: id => quests[id] || null } }
  });
}
assert.equal(evaluate({}), false, 'An older backend without seven-day quests must not abort hall initialization');
assert.equal(evaluate({3208: {data: {}, isAchieved: false, isAvailable: true}}), true);
assert.equal(evaluate({3208: {data: {}, isAchieved: false, isAvailable: true}}, 3208), false);
assert.equal(evaluate({3201: {data: null, isAchieved: true, isAvailable: true}}), false);
assert.equal(evaluate({3201: {data: null, isAchieved: true, isAvailable: false}}), true);
console.log('PASS: absent optional quests do not interrupt hall startup; existing quest availability is preserved.');
