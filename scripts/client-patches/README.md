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

Only the `sevenday` class source is imported; this directory's README is ignored.
Increment the asset update version so existing Flash caches invalidate old code.
