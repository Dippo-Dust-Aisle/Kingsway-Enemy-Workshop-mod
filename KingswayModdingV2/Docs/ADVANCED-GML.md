# Advanced GML authoring

An enemy's optional `advancedGml` names a local `.gml` file. It runs after that enemy's declarative attack graph in the same compiled script. Available locals are `actor`, `victim`, `window`, `damage` (most recent strike's positive HP damage) and `drained` (most recent mana drain). Legacy GameMaker 2.2 syntax applies: use scripts and argumentN, not 2.3 structs/functions.

Advanced code is trusted local game code. It is not executed by the desktop backend, but runs with the game's normal capabilities after installation. Static validation cannot prove arbitrary GML safe or correct; use the isolated enemy test and review code from other authors.

Useful scripts:

| Helper | Contract |
| --- | --- |
| scr_v2_strike(actor, target, window, multiplier, min, max, blockable) | Native combat; min/max = -1 preserve scaled actor values. Returns actual positive HP damage, capped by pre-hit HP. |
| scr_v2_status(target, family, amount, name, icon) | Add to native family amount; optional display name and sprite. Native player immunity/cure behavior remains. |
| scr_v2_effect(target, group, name, multiplier, icon) | Replace the active member of a reusable exclusive group. `next_attack_damage` is consumed by native scr_Attack. |
| scr_v2_consume(target, group, fallback) | Remove a group member and return its multiplier, or fallback. Custom groups may be consumed by advanced code. |
| scr_v2_spawn(actor, object, role, structuralAmount, percent) | Adds an explicitly owned member. Use role `summon` for dynamic summoning. Returns noone when capped or on cooldown. |
| scr_v2_cooldown(actor, key, seconds) | True once per named cooldown interval. Namespace custom keys. |
| scr_v2_group(actor) | Returns the encounter's member list. Do not destroy or mutate it from ordinary author code. |
| scr_v2_escape(actor) | Escape the complete encounter group. |

`patches` can introduce extension scripts under `gml_Script_scr_v2x_<mod_id>_<name>`, each with a relative `source` file. They are compiled in the same group and can call each other. Existing vanilla event/script replacement is deliberately restricted to reviewed manager adapters; a patch manifest cannot overwrite native progression or core hooks. Conflicting extension names fail validation.

Native object IDs are preserved. Namespaced custom IDs are regenerated deterministically from the same enabled set. Do not persist generated numeric resource IDs in external mod data. The manager has no runtime code loader and performs no incremental patching.
