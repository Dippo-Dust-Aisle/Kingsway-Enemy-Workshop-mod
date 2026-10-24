# Movement

Movement has Base Path and Action Moves tabs. Its canvas uses the same normalized positions, segment equations and timing conventions as the game. The start marker is separate from path points.

## Base Path

Spawn Position offers Center, Fixed, First point, Random X, Random Y and Random XY. First point begins at Point 1; the other modes travel from the selected/generated start to Point 1. Random X/Y preserves the marker's other coordinate. Changing Spawn Position never deletes a point or shifts the authored path.

Add and drag points on the canvas. A destination point supplies duration or positive speed (screen units per second), then its arrival wait. Its outgoing segment has Line/Arc shape and signed Bend. Linear, smoothstep, Catmull–Rom and Bézier interpolation remain available. None boundary allows offscreen movement; Clamp, Wrap, Reverse and Restart remain available. Coordinates range from -1 to 2. Loop start is a one-based point number.

Radius Random treats a point as a center. After its wait, the actor travels to a sampled circumference position, then to the next point. Radius, radial speed, left/right hemisphere spreads, circle rotation and opposite direction control that sample. The canvas shows the circle and allowed sectors.

Flip X and Flip Y transform every point about the screen center; repeating the same flip restores it. Random Mirror on Spawn chooses the original or both-axis reflection with equal probability. The canvas shows a translucent alternative. Show connected parts finds the head and connected limb/separate actors from either direction and previews all of them on a shared elapsed clock. Their speeds, waits and lengths remain independent.

Native profiles retain their extracted paths and speed baseline. Intensity scales movement; game-speed/quickness and chill apply when enabled. Pause settings govern attacks, stun, minimization and death. Minimization keeps the logical path state separate from the window's native slide animation.

## Action Moves

Create a named finite pattern, then select its ID in Movement Actions.

- Variation plays a center-relative offset while the Base Path advances. Entry and exit use Transition speed; completion returns the offset smoothly to zero.
- Detour saves the exact Base Path position, segment progress, direction and wait. It enters the pattern, plays it once, returns to the saved position, and resumes that state.

Entry chooses First point or the point closest to the current visible position. Points support speed/duration, waits, arcs and Radius Random. Patterns do not loop. One pattern can run per window; overlapping requests are ignored. Wait for completion holds the parent sequence until the movement completes. Return to Base Path cancels any remaining point wait and begins the return transition.

Converted old Window Move actions refer to named compatibility moves that preserve their original held offset, random-axis placement and retargeting. The canvas explains this and offers **Use finite pattern** to deliberately replace it. Newly authored actions use the visual patterns, without the former raw coordinate matrix.

## If dragged

When the player drags an actor's window by its title bar, all of its movement stops: Base Path, Action Moves, window moves and native profiles. On release the window travels from where it was dropped back to the Base Path at **Transition speed** (screen units per second) and continues from there. **Entry** chooses Point 1 or the point closest to the drop position; the arrival wait and Radius Random behavior of that point apply as if the path had arrived there. Native profiles return to the position where their path paused. A window may be dropped partly or fully offscreen; it never snaps back instantly. The return uses boundary None, so it glides back at Transition speed. An actor without movement moves the smallest distance needed to be fully back on screen, at Transition speed. Action Moves requested while the window is held or returning are ignored, like an overlap. The tab's preview lets you drag the window to try it.

## Canvas scale

The canvas shows the whole logical desktop (display width and height ÷ game scale) with each window at its true logical size: battle 254 × 264 (boss 324 wide), hazard 200 × 150 and cosmetic portrait square + 20 × + 32. A point is the window's centre; the dashed box is where the centre can travel when positions run 0–1, so a larger game scale or a larger window leaves less room to move.

## Test display

Test Settings controls resolution, scaling, fullscreen and game speed for disposable tests. Fullscreen applies to that test process. Normal installed Kingsway settings and saves remain separate.

Transition speeds (If dragged and Action Move entry/return) are measured in real screen distance, in screen widths per second, so vertical and horizontal travel take the same time for the same pixel distance. An Action Move Entry of None starts the move at Point 1 instantly, with no entry transition.
If dragged Entry "None - Do not move" leaves the window where it was dropped; a Base Path or native profile continues from there, shifted by the drag.
