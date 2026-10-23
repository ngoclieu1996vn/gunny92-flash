const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const source = fs.readFileSync(process.argv[2] || path.join(__dirname, 'client-patches/gameCommon/view/control/LiveState.as'), 'utf8');
function method(name) {
  const start = source.indexOf('function ' + name + '(');
  assert.ok(start >= 0, 'Missing production method ' + name);
  const open = source.indexOf('{', start);
  let depth = 1, end = open + 1;
  while (depth && end < source.length) { if(source[end] === '{') depth++; if(source[end] === '}') depth--; end++; }
  return source.slice(open + 1, end - 1);
}
function fixture(finished = new Set([2,5,10,11,12,19,51,55])) {
  const shown = [], cleared = [], saved = [], listeners = {};
  const player = {isAttacking:false, dander:0, addEventListener:(name, fn) => { (listeners[name] ||= []).push(fn); }};
  const noop = () => {};
  const scope = { _gameInfo:{selfGamePlayer:player},
    PlayerManager:{Instance:{Self:{IsWeakGuildFinish:id => finished.has(id), FightBag:{itemNumber:0}}}},
    SocketManager:{Instance:{out:{syncWeakStep:id => { saved.push(id); finished.add(id); }}}},
    GameControl:{Instance:{Current:{selfGamePlayer:player}}},
    NewHandGuideManager:{Instance:{mapID:0}},
    NewHandContainer:{Instance:{showArrow:(id,...rest) => shown.push(id), clearArrowByID:id => cleared.push(id)}},
    setWeaponPropVisible:noop, setRightPropVisible:noop, setArrowVisible:noop, setEnergyVisible:noop,
    setSelfPropBarVisible:noop, _tool:{setDanderEnable:noop}, setTimeout:noop, propOpenShow:noop
  };
  vm.createContext(scope);
  for(const name of ['__onDander','__showTenPersentArrow','__showThreeArrow']) vm.runInContext('function '+name+'(param1){'+method(name)+'}',scope);
  const invoke = name => vm.runInContext('(function(){'+method(name)+'})()',scope);
  return {finished, shown, cleared, saved, listeners, player, scope, invoke};
}
const f = fixture();
f.invoke('loadWeakGuild');
for(const step of [6,23,26]) assert.equal(f.finished.has(step),false,'Do not complete an unseen combat hint: '+step);
f.player.isAttacking = true;
f.scope.__showTenPersentArrow({}); f.scope.__showThreeArrow({}); f.scope.__onDander({});
assert.deepEqual(f.shown,[19,20,21]);
assert.equal(f.finished.has(26),false,'Rage hint must wait for usable rage');
f.player.dander = 200; f.scope.__onDander({}); f.scope.__onDander({});
f.player.isAttacking = false;
f.scope.__showTenPersentArrow({}); f.scope.__showThreeArrow({}); f.scope.__onDander({});
f.player.isAttacking = true;
f.scope.__showTenPersentArrow({}); f.scope.__showThreeArrow({}); f.scope.__onDander({});
assert.deepEqual(f.shown,[19,20,21,18],'Repeated shots/turns must not recreate completed hints');
assert.deepEqual(f.saved.filter(id => [6,23,25,26].includes(id)),[6,23,25,26]);
assert.deepEqual(f.cleared,[19,20,21,18],'Clear only this hint, preserving unrelated tutorial arrows');
const reloaded = fixture(f.finished); reloaded.invoke('loadWeakGuild');
assert.equal((reloaded.listeners.attackingChanged || []).length,0,'Persisted completion must survive a new view/login');
const nextPlayer = fixture(); nextPlayer.invoke('loadWeakGuild'); nextPlayer.player.isAttacking = true; nextPlayer.scope.__showThreeArrow({});
assert.deepEqual(nextPlayer.shown,[21],'One character must not suppress another character first hint');
const trainer = fixture(); trainer.scope.NewHandGuideManager.Instance.mapID = 114; trainer.invoke('loadWeakGuild');
for(const step of [23,25,26]) assert.equal(trainer.finished.has(step),true,'Preserve map114 scripted training progression');
console.log('PASS: combat arrows appear once, wait until displayed, persist existing progress and preserve unrelated hints.');