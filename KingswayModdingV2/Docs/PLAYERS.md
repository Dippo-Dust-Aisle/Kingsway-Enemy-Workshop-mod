# Player instructions

The editor runs only on `127.0.0.1` with a random per-session access token. Its launcher opens the correct address automatically. Do not use an old saved browser address after restarting the backend. Project and manager data stay in the KingswayModdingV2 directory.

Import a `.kingswaymod.zip` in Mod manager. Archives contain a root `mod.json`, PNGs, optional GML and text documentation. Imports validate paths, sizes and symbolic references, and refuse to overwrite an existing mod ID. An imported mod also gets an editable project when no project with that ID already exists.

Projects are drafts; managed Mods are the versions selected for installation. **Add to manager** updates the managed copy. Save alone does not change gameplay. Every change to stats, attacks or assets requires a rebuild; there are no runtime configuration reads.

Enabled mods build in ascending loadOrder, then ordinal mod ID. A larger loadOrder does not win a conflicting override: conflicts are errors. All enabled projects build together from the exact original data.win. The manager compiles a staging file, reloads and decompiles the changed entries, checks its release identity, then records a SHA-256 report. Install checks the report and current installation again before atomic replacement.

Close Kingsway before install, restore or testing. The manager refuses unsupported originals and unexplained external changes. Steam Verify Files can restore the original game; a game update with different bytes requires a new reviewed version profile.

**Level Test** and **Random Fight** compile the selected draft and open a playable enemy encounter at the chosen level. Level Test provides Attack, Block, Fireball II, Chill II, and Escape. Random Fight provides a random class, eight equipment slots, and two distinct battle skills from that class's full skill pool between Attack/Block and Escape. Both include healing potions, mana potions, and poison scrolls in the backpack. Escape, defeat, or finishing the loot window closes the disposable game. There is no play time limit.

Playable fights use the separate `KingswayWorkshopV2Fight` save namespace. **Run isolated engine verification** runs the bundled automated conformance fixture in `KingswayWorkshopV2Test`. Both disable profile persistence and Steam integration and compare the complete real Kingsway save file set and hashes before/after. The automatic conformance harness may close only the disposable process it started once its report is complete. Test builds are never installable.

**Restore exact original** restores the pinned original byte-for-byte. It does not remove project files or edit saves.
