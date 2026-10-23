# Current-client compatibility patches

`sevenday/SevendayManager.as` is the current client's decompiled class with a
single null check added to `isNotAllAchieved`. An older backend can have no
templates for quest IDs 3201–3214. Previously, accessing `.data` on a missing
template aborted `HallStateView.initHall` before its hit buttons became
transparent and before task tracking finished. Existing quests keep their
availability logic; no quest definitions or rewards are invented.

Run `node scripts/test-sevenday-contract.cjs` from the Flash repository.
The class exists in both `2.png` and `4.png`; `2.png` loads first. Rebuild both
using JPEXS FFDec 26.4.0 against unpatched copies:

```powershell
java -jar C:\tools\ffdec.jar -importScript C:\backup\2.png C:\output\2.png scripts/client-patches
java -jar C:\tools\ffdec.jar -importScript C:\backup\4.png C:\output\4.png scripts/client-patches
```

The `sevenday` source is imported into both modules. `gameCommon.view.control.LiveState` exists only in `4.png`; use a source directory containing only that class to rebuild its combat guide patch separately. This directory's README is ignored.
Increment the asset update version so existing Flash caches invalidate old code.

## Combat arrows shown once

`gameCommon/view/control/LiveState.as` preserves the decompiled current-client
class and changes its three combat hint callbacks. Previously, `loadWeakGuild`
marked steps 6, 23/25 and 26 complete while subscribing, but the callbacks still
showed arrows on every attacking/dander event for the lifetime of that view.
The callbacks now check the existing completion bit and record it only when
the hint actually displays. Rage waits until dander reaches 200. Turn-end cleanup
clears only that hint's arrows (18, 19/20, 21), leaving unrelated arrows intact.
Map 114 retains its scripted training progression and original completion path.
No rewards, equipment, currency or global guide-disable flag are changed.

Run `node scripts/test-combat-guide.cjs`; it executes the actual AS callback
bodies through the same Node VM approach as the seven-day contract test. It
covers repeated turns, repeated rage changes, persisted completion, a separate
character, unrelated-arrow cleanup and map 114. An optional source path can test
a class re-exported from the rebuilt SWF:

```powershell
node scripts/test-combat-guide.cjs C:\output\scripts\gameCommon\view\control\LiveState.as
```

The patch targets `4.png` only. Back up the served file, import the class using
FFDec with a 4096 MB Java heap, re-export it and rerun the test before serving.
The asset update version is 261 so existing clients reload the combat module.