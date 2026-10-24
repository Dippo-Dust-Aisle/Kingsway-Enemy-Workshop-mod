# Manifest schema 3

Docs/manifest.schema.json is generated from the C# models and validation choices. Mod, enemy and asset IDs use lowercase letters, digits and underscores and begin with a letter. References are symbolic native names or project-local IDs; numeric native resource IDs are not portable.

Schema 3 uses grouped action kind/mode pairs: damage, magic, resource, text, movement, spawn, branch and attackSpeed. Ordered nodes retain children, else, chance, repeats, intervals, waits, cooldowns, target and result gates. Runtime lowering happens on a deep copy. Static component role is one of limb or separate; dynamic summon is independent. Actor mode is enemy, hazard or cosmetic.

Appearance contains cosmetic size (68/102/136/170/204/272), portrait rotation, draggable, normal/top/behind layer, integer opacity 0–10, trails and supported button text. Project menuTrails enables trails on ordinary menu windows. Movement separates spawn coordinates, base points, per-point/segment geometry, randomMirror, named actionMoves and dragReturn (entry first/closest, transitionSpeed 0.001–10; defaults closest and 0.5). Loot entries may set cursed; cursed selected enchantments allow nonzero negative amounts. Variants have family, name, icon and familyDefault/none/custom popup behavior. Audio metadata preserves originalFilename when known, readable file/original paths and legacy aliases for advanced callbacks.

The serializer and schema retain internal compatibility fields so converted held offsets and authored advanced callbacks can be reproduced. Ordinary authoring presents only the grouped controls and visual movement paths. New code should use schema 3's grouped fields. Future schema versions and unknown fields fail explicitly.

## Conversion

Opening schema 2 creates a complete copy under Recovery/schema3-projects/<Projects-or-Mods>/<project-id>-<original-manifest-SHA256-prefix>. Conversion stages the complete project, updates references, validates all assets and graphs, copies nonconflicting new files and atomically replaces the manifest. Failed validation leaves the original manifest intact. Opening schema 3 again is a no-op.

Each old node maps independently; adjacent nodes are never merged. Old friend components become separate. Old global arcs become outgoing per-point geometry. Old random path offsets remain marked legacySpawnOffset; old raw movement becomes an explicit compatibility Action Move. Existing drain-and-heal sequencing, nested branches, boss mappings and timing remain intact.

Audio uses recognizable original basenames and deterministic numeric suffixes. WAV music keeps audio/Boss_Theme.wav and converts to audio/Boss_Theme_toOgg.ogg; Ogg keeps its recognizable basename. Legacy filenames use the best available logical ID without inventing a lost original name. Old files remain recoverable. Successful new conversions retire obsolete audio copies under Recovery/schema3-retired-audio; the final transaction addition still needs its verification rerun. Previously converted active projects retain their legacy copies until that check passes. Deployed music uses WorkshopAudio/<project-id>/<readable-basename>. Different content never overwrites a colliding deployed basename.
