# Installation and recovery

The Workshop builds from an unmodded Kingsway 1.2.1 `data.win`, SHA-256:

`7BE7530EC424F9F5972E142E08E043B71A94D7E894D95D5A67AC26CB0B9184F9`

On first start it copies the game's `data.win` to `Recovery/original/data.win` and checks the copy. If the game file is already modified, the Workshop refuses to start; use Steam's **Verify integrity of game files** first. Older setups that already have `../KingswayModding/backup/data.win` keep using that backup.

Build writes `Builds/release.win.staging`, reloads it, decompiles every changed code entry and checks inheritance and release identity. Only a valid result replaces `Builds/release.win`. Compilation errors leave the previous successful release and installed game untouched. A build records source hashes and refuses sources that change during compilation.

Install/restore refuses a running Kingsway process. It checks the original checksum and current active hash, copies to a staging file on the same volume, checks again, stores previous bytes under `Recovery/<hash>.win`, and writes a prepared journal. It then atomically replaces data.win and records a committed journal and installed hash. Recovery recognizes either side of an interrupted transaction. A per-workspace file lock prevents simultaneous build/install mutations.

If data.win changed externally, the Workshop refuses to overwrite it. Preserve the changed file yourself before resolving that state. Do not edit installed.json to force an unknown binary through validation. If Steam restores the exact original, the Workshop recognizes it automatically. A different game version is unsupported.

To undo all mods, use the Mod manager's **Restore exact original**. Command equivalent (from the game directory):

```
dotnet KingswayModdingV2/KingswayWorkshop.dll restore
```

If the Workshop cannot start, close the game and use Steam's **Verify integrity of game files**. Save files are outside this process and are never modified.
