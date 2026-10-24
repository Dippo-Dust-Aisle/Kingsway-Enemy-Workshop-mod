# Hazard, movement, sequencing and audio update

The current application uses schema 3. Existing projects convert automatically with recovery backups; see SCHEMA.md. Drafts can contain incomplete values; validation blocks exporting, staging or compiling an invalid project.

## Hazards and native projectiles

Choose **hazard** under Identity & stats. The dedicated trap window has a Close button and one activation bar. It shares portrait, movement, periodic actions and attack actions with enemies, but has no battle skills, corpse, experience or loot. Closing before activation cancels it. Normal activation removes the window while its own delayed actions finish; the remaining actor and path are then released. Window operations after expiration safely do nothing because that window is gone.

Native projectile actions offer Fireball, Arrow, Boulder, Black Fireball, Curse, Icicle, Poison Dart, Magic Arrow, Throwing Axe and the second Fireball variant. Their native effects and cleanup are retained; the authored Amount sets damage. Deliberate black-fireball duplicates are preserved. Random X/Y placement tries 48 nonoverlapping positions, then accepts a valid random position if crowded. Fixed axes stay fixed. Outside entry uses each moving trap's incoming edge; stationary curses have no incoming edge.

## Movement

See [Movement](MOVEMENT-ACTIONS.md) for the current visual Base Path and Action Moves editor, separate spawn marker, per-segment arcs, Radius Random, centered mirroring and all five boundaries.

Travel uses display width/height divided by game scale, less the actual window dimensions and the reserved 24-pixel bottom bar. Ordinary native battle paths are duplicated and scaled from the native 640×480 logical baseline. Configured speed is not rescaled with distance. Scripted boss choreography remains governed by the reviewed boss adapters; see LIMITATIONS.md.

**Use game speed for authored custom path** is an enemy setting. **Preview & playable test settings** are saved locally on this computer. Screen Movement is 0.30, 0.50, 0.75, 1.00, 1.15, 1.30 or 1.45. Native speed uses configured path speed × 0.8 × Screen Movement ÷ player quickness, with native per-point speeds, attack readiness pauses and chilling. The preview uses 2,001 samples per path exported by the actual runner, with interpolation between samples. It is not a pixel-identical recording of a future random fight.

Default preview quickness follows the Level Test Mage's base agility plus its allocated level stat points. Random Fight equipment/classes can change quickness; the optional override is applied in the game as well as the preview. Preview paused/chilled/stunned/minimized controls simulate those states; they do not permanently apply statuses to a playable character.

## Actions, damage and statuses

Every action has Wait before next action, with inclusive Min/Max seconds. Equal values give a fixed wait, 0/0 continues immediately, and a standalone Wait delays the following action. A child's final wait completes before its parent's continuation. Repeat runs the action and its subtree the requested number of times, with Interval between repetitions; Wait before next action applies after the completed repeat block. Limits prevent more than 4,096 expanded steps per activation.

Each attack activation owns its continuation and combat results, so volleys can overlap. Source death, escape or manual removal cancels unfinished work. Normally expired one-shot hazards retain their started sequence. Waits use elapsed seconds while the game is running and stop during pause; native frame stalls can delay a scheduled action until the next frame. No script blocks the game while waiting.

Weapon Attack honors Attacker/Victim and uses native attack calculations, including dodge/block. Direct physical damage uses defence/protection without a new strike roll. Status Apply, Reduce and Clear keep native amounts nonnegative. Poison reduction is not healing. For regeneration, add periodic Restore health targeting Attacker and choose its cooldown. Native family icons and authored variant names are retained; PNG imports are fully decoded, limited to 2,048 pixels per side, and included in project archives.

## Loot and audio

Each loot row can supply a custom item name. It is applied to that item after native enchantment/name updates, retaining identification state. Base stats are shown separately from selected bonuses and level-dependent behavior. Native, guaranteed random and guaranteed selected enchantments remain available.

Each independent row rolls its exact percentage. Entries with the same group name share one roll and choose one eligible item by weight. Quantity and level bounds are inclusive. Unless specified, Kingsway decides whether an item receives a random enchantment.

Choose native spawn sounds or import 16-bit PCM WAV sound effects (mono/stereo, 8–48 kHz, up to 32 MB). Sound actions use the same choices. Music accepts Ogg Vorbis, or WAV converted during import using an already installed ffmpeg. The original WAV is retained. This installation uses GameMaker's existing converter; none was installed. If another machine has no converter, import Ogg Vorbis instead.

The first requested encounter music owns one stream until all workshop encounter actors and pending hazard sequences finish. Other simultaneous music requests do not stack or replace it. Native sound/music and master volume apply. The previously paused native song resumes if it still exists. Custom WAV resources are embedded in builds; converted music is copied into the game directory's WorkshopAudio folder before play. Project ZIPs contain imported media and retained originals.

## Testing and removal

Playable tests default to fullscreen 1366×768 at ×2 scale. Unsupported dimensions fall back to the desktop; scale is reduced if necessary for essential native windows to fit. Launch attempts to bring the owned game window forward. Windows focus policy may still prevent it stealing focus from an active application.

Level Test gives Attack, Block, Fireball II, Chill II and Escape. Random Fight chooses a class, all eight equipment slots and two native class skills. Both supply health/mana potions and native poison consumables. Escape, death, completed loot or dismissal of remaining loot ends the isolated game. Ordinary playable sessions have no short lifetime timer. Test builds use separate save namespaces and disable Steam integration.

−Enemy identifies the selected enemy and affected references before confirmation. Cancel changes nothing. Confirmation removes its summons, component references and associated overrides, then selects a remaining enemy. Empty projects support +Enemy and export/reopen.

Numeric bounds come from shared backend metadata; related bounds and loop indices show errors beside controls. Native game diagnostics include available original output and the last traced enemy/action. An exit without a completion report is reported as unexplained when no native error details are available. This cannot rule out crashes in arbitrary advanced GML.
The native formatted-text renderer now falls back to its current color for unknown color names. This fixes the reproduced hazard physical-strike crash when battle text using medGrey is routed to the adventure log.