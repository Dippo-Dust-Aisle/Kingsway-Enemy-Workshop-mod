# Authoring enemies

Use symbolic game names (`spr_Skeleton`, `obj_PotionAntidote`, a catalog path name) or mod-local asset/enemy IDs. Never copy numeric object IDs from decompiled code into your manifest. Mod IDs, enemy IDs and asset keys use lowercase letters, digits and underscores; begin with a letter.

## Stats and references

Health, damage, XP and gold are base values. Native Begin Step performs Kingsway's level scaling. Attack speed is in game units, not attacks per second. The reference selector shows an enemy's literal or dynamic expression, and the min/median/max of discoverable literal values. Dynamic assignments are not included in distributions. Shared resistance defaults are poison 90, cold 110 and burn 3.

PNG assets can be 1–2048 pixels per dimension. Enemy/Hazard portraits fit into 68×68; Cosmetics offer 68, 102, 136, 170, 204 or 272 logical pixels. Aspect ratio and transparency are preserved; portrait rotation is independent of window controls. A mod's `assets` maps symbolic keys to files inside its project. Each asset receives a namespaced sprite resource at compile time.

## Action graph

Use the eight grouped controls described in [actions and reactions](ACTION-REACTIONS.md). Attack Actions, When attacked and Periodic retain ordered nodes, independent cooldowns and copy/paste of nested branches. **Copy to…** can replace or append the complete section on another enemy.

## Status policy

Poison, cold, burn, stun and curse retain native storage, cure rules and timing. Poison variants all use poisonAmount; Antidote clears all of them. Applying another variant in the same family changes its presentation but does not create an independent status slot. Curse uses Kingsway's existing stat-curse objects and immunity, and is player-targeted. Nullify/Bolster are a separate exclusive next-attack group; either replaces the other, and the next attempted native attack consumes it even on a dodge.

## Loot and encounters

Each independent loot entry rolls once, then picks an inclusive integer quantity. A choose-one group uses one shared activation percentage and weights eligible members; members must have identical chance. Min/max level bounds filter entries before selection. Mandatory custom drops must have chance 100 and cannot be choose-one alternatives. Protected vanilla progression drops remain under their adapters regardless of optional loot.

Every loot row also has an enchantment choice. **Let Kingsway decide** preserves the original item behavior. **100% random enchantment** guarantees a positive native enchantment when that equipment drops, with native level-scaled bonuses. **100% selected enchantments** adds each chosen bonus and amount to the item's existing properties. Percent values are percentage points. Drop chance is separate: a 10% drop with a guaranteed enchantment still only drops 10% of the time. Consumables and quest items keep native behavior. Unique equipment can receive selected bonuses but cannot be rerolled. The combined item properties must fit nine native bonus slots; validation rejects duplicates, unknown bonuses, and invalid amounts.

**Cursed item** marks equipment as cursed (native `enchanted = 2`). With *Let Kingsway decide* or *100% random*, Kingsway rolls its own curse: one negative stat, one stronger bonus and a prefix such as “Fool's”. With *100% selected enchantments*, amounts may be negative (nonzero, down to the stat's negative maximum); the item drops identified and named “Cursed …”, and the native Remove Curse strips negative bonuses and the prefix. Unique equipment can only be cursed through selected enchantments.

Native status variants show extracted game icons alongside their names. Selecting a custom icon updates the variant preview; the family legend continues to show the native icons.

## Playable enemy fights

Choose a level from 1–25, then **Level Test** or **Random Fight**. These compile the selected draft and launch an interactive Kingsway instance. They do not install the draft. Close any ordinary Kingsway session first.

- Level Test creates a Mage at the selected level with Attack, Block, Fireball II (the native area fire spell), Chill II, and Escape. The normal three stat points per level are allocated evenly in a repeatable order.
- Random Fight rolls one of the nine native classes, allocates level-up stats randomly, fills all eight equipment slots with native equipment, and selects two distinct active skills from that class's full native progression. Skills can come from higher levels so low-level classes always have two choices. Gear favors items that meet current stats, with a level-appropriate fallback if a slot has no eligible item. Attack, Block, and Escape remain in their usual positions.
- Both modes supply six full healing potions, four full mana potions, and four poison scrolls in the backpack. Kingsway's native consumable for applying poison is a scroll. The test backpack has extra capacity for supplies and loot.
- There is no fight time limit or automatic attack. Use skills and items normally. Escape always ends a test fight. After victory, inspect the loot; collecting all items or closing the loot window ends the test once all hostile members and pending loot are resolved. Defeat also closes the test. Closing the game window is always available.

Characters and loot are disposable. Tests use `KingswayWorkshopV2Fight`, a separate save namespace. The workshop checks all normal Kingsway save hashes before and after. The short automated engine checks remain available in Build & verification. A normal installed game keeps its original escape rules and save namespace.

Encounter placement uses the original named pools. A weight of 1 competes with each original list entry at weight 1; original duplicate entries retain their native contribution. A new candidate is registered once with a real-valued weight. Ordinary frequency and terrain/time/level selection remain native; only the final weighted choice is extended. Explicit object spawns stay explicit.

## Movement and ownership

See [Movement](MOVEMENT-ACTIONS.md) for Base Path, spawn markers, per-segment arcs, Radius Random, mirroring, linked-part preview and finite Variation/Detour Action Moves.

Static parts have one relationship: limb or separate. Limbs follow their head's lifetime; targetable combat limbs can apply configured structural death damage. Separate actors survive their head while another hostile group member remains and keep independent rewards. Dynamic summons have three combat slots and a minimum 0.25-second spawn cooldown. Cosmetics use a separate maximum of 32 per encounter, including recursive spawns, and never count as hostile members. A Cosmetic limb is healthless and cannot inflict structural death damage. Cosmetics run Periodic while a hostile remains and clean up with the group.

## Appearance and projects

Cosmetics have a native title bar with no combat controls, loot or activation bar. Their size settings affect only their portrait bounds. Draggable (the default for every actor) shows the drag icon at the right of the title bar and a black marching outline; any Enemy, Hazard or Cosmetic window can then be dragged by its title bar, even native battle windows. Always behind is click-through and undraggable, with stripes outside the portrait; it stays below every other window but above the desktop logo. Only Always on top windows show the pin icon (rightmost); while pinned the window has a red outline, and clicking the pin toggles it (a dimmed pin means unpinned). Pinned windows sit above every normal window but below menus, held items and the cursor; among pinned windows the last one clicked is highest. Always on top is locked in game: clicking its red pin shows a lock and a "PIN IS LOCKED!" message. Timer on Top has a blue outline and blue pin; clicking the pin plays a sound, unpins the window and counts 3, 2, 1 on the pin and in its title and taskbar button ("Battle (3)"), then re-pins it with a second sound. Cosmetic windows use the Canon (rounded) or Alt (square) frame, chosen per Cosmetic; the frame stretches for portrait sizes above 68. Frames and the drag, pin, lock and countdown icons follow the window theme (Light, Dark, Yellow, Pink) using variants generated from the game's own theme colours. Window stacking works like Windows "always on top": unpinned windows (including Status, Bag and Settings) keep the native click order; pinned windows stay above them, last clicked pinned on top. Start-menu windows and messages rise above pinned windows while they are the most recently clicked or opened unpinned windows. New enemy, hazard and Cosmetic windows open above every unpinned window except a Settings window opened most recently. "NEW MESSAGE" notifications sit below all windows (and fade out at once in tests). Variable Action (Attack Speed / Variable Activation) activates a Variable 1-99 for the whole project; every live enemy, limb, summon, hazard or Cosmetic from the project runs its Variable Branches with that number (Branches / Waits). Variable Branches are skipped in normal order. Non-draggable windows still come to the front when clicked. Window opacity and Window layering are in the Movement / Window action group; Text / Sound / Portrait holds messages, sounds and portrait changes. Play action move has Pause before move (seconds). Trails never change the window itself: ghosts are sampled every third frame while it moves and stay just behind it. Pin and drag icons sit on the window's native title-button box. Enemies and hazards can enable Sky Monster Portrait (97 x 99): the portrait fits 97 x 99 like the native Shadow and bleeds past the 68 x 68 frame. Cosmetic windows have no title-bar icon. Set/Add/Subtract opacity uses integer 0–10 and changes the entire window while behavior continues. Trails never make the window itself more transparent (use opacity for that). Trails are off by default, sample moving windows every third draw, fade quickly and share a strict 24-ghost limit. Project Settings can enable ordinary menu trails too.

Native Status Variants use searchable family and icon galleries with PNG import. Family Default needs no custom asset. Popup choices are Family default, None or Custom. Damage-producing status feedback displays its selected icon beside the hit.

+ Duplicate copies the selected enemy independently. Copy to… specifies replace/append and excludes the target's ID/name by default; Advanced copies only enemy settings and its own callback file. Boss / Quest stays project-level. Duplicate project creates a complete new source project without managed/enabled state. Remove project shows the exact warning and moves source and managed copies through Windows Recycle Bin; recoverable copies and rollback protect against partial removal. An installed build remains unchanged until rebuilt.

Audio imports retain recognizable filenames and original upload metadata, with numeric suffixes on collisions. Music deploys under WorkshopAudio/<project-id>. Test Settings includes Test death animation during an owned isolated test. It completes native death presentation, closes that test and verifies real saves. Testing a Cosmetic directly includes a passive encounter host.

For boss/quest overrides, consult BOSS-SUPPORT.md. Required component mappings are exact named slots, not a generic limb count.

Performance notes: wrapped Draw/Mouse events skip their opacity and click-through scripts while no window is dimmed or Always behind; pinned windows are ordered once per frame; Workshop hazard windows that finish normally are parked (up to 8) and reused for the next hazard; repeated identical Workshop battle messages in one window are limited to one per 0.5 s.
