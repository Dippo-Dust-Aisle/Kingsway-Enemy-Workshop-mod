# Kingsway-Enemy-Workshop

# Kingsway Enemy Workshop

Make your own enemies for **Kingsway** and fight them in the real game. The editor runs in your browser, but only on your own PC. You an internet connection.

## Features

- **Enemies, hazards (traps) and cosmetics**, with custom portraits (PNG), sounds and music (WAV/OGG).
- **Stats, loot and encounters**: choose where and how often your enemy appears and what it drops.
- **Attack actions**: damage, magic and status effects, mana/health effects, messages, spawning, branches and attack speed. Actions can run in order, on a timer, or when the enemy is attacked.
- **Movement**: draw a window path on a canvas, preview it, and add one-off moves to attacks.
- **Multi-part enemies and summons** (limbs, walls, minions).
- **Level Test and Random Fight**: open a playable test fight against your draft. Your real save files are never used or changed.
- **Mod manager**: import and export mods as `.zip`, enable several at once, then **Rebuild & install**. **Restore exact original** puts the unmodded game back at any time.
- Optional **advanced GML** for scripted behavior (see [Docs/ADVANCED-GML.md](KingswayModdingV2/Docs/ADVANCED-GML.md)).

## Requirements

- Windows and the Steam version of **Kingsway 1.2.1**, unmodded.
- A web browser. The Workshop opens in it.
- The installer gets these for you if they're missing:
  - [.NET 10 Runtime](https://dotnet.microsoft.com/download/dotnet/10.0) (x64)
  - [UndertaleModTool 0.9.2.0](https://github.com/UnderminersTeam/UndertaleModTool/releases) (`UndertaleModTool_v0.9.2.0-Windows.zip`)

## Install

1. Download `Kingsway-Enemy-Workshop-V2.zip` and extract it anywhere, for example your Downloads folder.
2. Double-click **Install.cmd** and answer its questions. It will:
   - find your Kingsway folder through Steam, or ask you to pick it;
   - check that the game is unmodded (it opens Steam's file check if it isn't);
   - install .NET 10 if needed (Windows asks for permission);
   - download UndertaleModTool 0.9.2.0 from its official GitHub release and check the file;
   - copy the Workshop to `Kingsway\KingswayModdingV2`, back up the original `data.win`, and read the game's enemies, items and graphics;
   - optionally import the sample enemies, install them into the game, and add a desktop shortcut.
3. Afterwards, start the Workshop with **Start Workshop.cmd** in `Kingsway\KingswayModdingV2`, or with the desktop shortcut.

Running Install.cmd again updates the Workshop and keeps your projects and mods.

### Manual install

1. In Steam, right-click Kingsway > **Manage** > **Browse local files**.
2. Install the .NET 10 Runtime (x64).
3. Extract UndertaleModTool into a folder named `UndertaleModdingTool` there, so that `Kingsway\UndertaleModdingTool\UndertaleModLib.dll` exists.
4. Copy the `KingswayModdingV2` folder from the download into the Kingsway folder.
5. Double-click **Start Workshop.cmd**. The first start takes a little longer.

If the Workshop says `data.win` is modified, use Steam's **Properties > Installed Files > Verify integrity of game files**, then start it again. Startup errors are written to `startup-error.txt`.

## Sample enemies

The `Sample Enemies` folder has 7 example mods. The installer can import them. You can also add them yourself in **Mod manager** > **Import mod ZIP**. To put enabled mods into the game, close Kingsway and click **Rebuild & install**.

Each import also creates an editable project, so you can open it in Enemy studio to see how it was made. Enemies only appear in the game if their **encounter rate** is above 0. Walls, limbs and summons are usually left at 0.

## Making an enemy

1. Create a project, then pick or add an actor in **Enemy studio**.
2. Edit Identity & Stats, Attack Actions, Movement, Loot, Encounters and Parts & Summons. Changes save locally.
3. Use **Level Test** or **Random Fight** to try it.
4. **Add to manager**, enable it, and **Rebuild & install** (with Kingsway closed).
5. **Export** the project to share it.

More detail: [authoring](KingswayModdingV2/Docs/AUTHORS.md), [actions and reactions](KingswayModdingV2/Docs/ACTION-REACTIONS.md), [movement](KingswayModdingV2/Docs/MOVEMENT-ACTIONS.md), [hazards and audio](KingswayModdingV2/Docs/EXPANSION.md), [boss support](KingswayModdingV2/Docs/BOSS-SUPPORT.md), [using the manager](KingswayModdingV2/Docs/PLAYERS.md), [known limits](KingswayModdingV2/Docs/LIMITATIONS.md) and [recovery](KingswayModdingV2/Docs/RECOVERY.md).

------------------------------------
## Feature Headers 
Identity & stats, Attack actions, Loot, Encounters, Movement, Parts & summons, Boss / quest, Advanced

## Identity & stats
- **Toggles for new window controls**.
- Under **Layering**: 
- **Always on top** - Always layers a window ontop of another non-pinned window (which is useful for windows purposely made to block clicks or view; think an enemy holding a shield, or blocking item bags).
- **Timer on Top** - Window pinned by default; unpins for 3 seconds after pressing before pining again.
- **Always behind** - Window is always behind others and can't be clicked.

- **Draggable** - Makes any window that can't be dragged, draggable.
- **Window trails** - Makes window trails.

- Under **Actor Mode**: 
- **Cosmetic Windows** - Window with that doesn't attack, usable for decoration or obscuring/cluttering. Portrait sizes: 68, 102, 136, 170, 204, 272.
- **Portrait Rotation - Degrees: 0,90,180,270. 
- **Window Opacity** - Makes windows 0-10,

## Attack actions
Headers are if/else, but blocked as well.
"Branches" are essentially if/else statements, but designed to be simpler visual-based coding without the need to know a function list, mod-API, programming best practices/optimizations, dynamic typing (int, double, float, bool, char, String, etc.; don't know these - the app won't let you type the wrong one - you're good), external with lower debug failure rate.

## Loot
Only one item in a named group can drop. Group weight: see encounter weights below for example.

## Encounters - Example
Numbers are encounter weight. Example: If 3 enemies are in the forest pool by default (or after modding), each have 1/3 chance to spawn. If you set your enemy encounter rate to 1, it will have 1/4 change to spawn alongside the other 3.
Encounter weight number = 1 in forest pool(4) = 1/4 (25% to spawn).
Encounter weight number = 2 in forest pool(4) = 2/4 (50% to spawn).
Encounter weight number = 3 in forest pool(4) = 3/4 (75% to spawn).
Encounter weight number = 4 in forest pool(4) = 4/4 (100% to spawn).
Encounter weight number = +4 in forest pool(4) = 5/4 (100% to spawn).
I believe "shadowAnyLevel" is the Sky Eater Shadow - can replace Sky Eater Shadows.

## Movement
Scroll down to "Start marker & movement settings", native game speed is there - I usually keep it off because my examples do more complex things. It is up to you if you want it on, but it overall makes thing slower unless you play at a higher game/window speed.
Linear = No acceleration/deceleration 
Ease = Acceleration/deceleration 
Bezier = smooth/curve
Catmull-Rom = a kind of drifting and overshooting of points.
Under "Point behavior" > Radius Random: Randomly goes to a point in the circle based on the degrees in the hemispheres.
Under "Boundary" > 
Clamp: Stick to wall
Wrap - Screen wrap
Reverse - Bounce
Restart - returns to point 1.

## Parts & Summons
Add parts when you want them to die/spawn alongside the dead. Can do double spawns this way "separate".

## Boss / Quest
Can swap quest boss and drop their loot. Make your own "official" bosses this way and replace them. 

##  Advanced
Advanced GML: Basically for future modding - not really important. 
Complete project JSON: Copy and paste the text here into a word counter, it basically shows that your complex enemies would be 1000+ lines of code if you had to write them as .json. "Mother Mage Doctrinaire" is 2717 lines of code in a .json file, and that is just in its file, doesn't include other summons, hazards, or cosmetics. Maybe future versus cuts down on this - already mad converter in past that cut down on it. 
------------------------------------

## Uninstall

Click **Restore exact original** in the Mod manager, or use Steam's **Verify integrity of game files**. Then delete the `KingswayModdingV2` folder.

## Building from source

The source is in `Src` (C#), `Web` (editor) and `Runtime` (GameMaker scripts). `Build-App.ps1` rebuilds `KingswayWorkshop.dll` with PowerShell 7. It doesn't need the .NET SDK.

## Credits and license

Made by Dippo Dust Aisle. Uses [UndertaleModTool](https://github.com/UnderminersTeam/UndertaleModTool) (GPL-3.0), which isn't included. This is a fan project and is not affiliated with the developers of Kingsway. No game files are included.

Licensed under the [PolyForm Noncommercial License 1.0.0](KingswayModdingV2/LICENSE), with extra permissions:

- **Allowed:** using it, making videos and streams of it (monetized is fine), adding features and sharing your changed version for free.
- **Your enemies are yours:** you can share or sell the enemies and mods you make with it, including on Patreon or Ko-fi.
- **Not allowed:** selling, reselling or paywalling the Workshop itself, or a changed version of it.

See [LICENSE](KingswayModdingV2/LICENSE) for the exact terms.

