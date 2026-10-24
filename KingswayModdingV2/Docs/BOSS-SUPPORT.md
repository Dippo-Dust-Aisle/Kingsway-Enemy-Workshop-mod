# Boss and quest support

Adapter classification is explicit. Catalog dependency evidence is not sufficient by itself to allow an override. `Adapters.cs` and `Compiler.ApplyOverride` encode reviewed protected and replaceable behavior.

| Slot | Classification | Protected behavior |
| --- | --- | --- |
| obj_Brogt | Supported | Original object ID/Create initializer, guaranteed Charm of Fortitude and King's Icon slots, other vanilla drop choices, cannot-escape rule, native reward flow. |
| obj_TombBoss | Supported | Original object ID, native drops/init, tomb baseEncounterRate change and obj_Requirement_KillSkeletons completion credit. Callback deferred while group hostiles remain. |
| obj_HauntedHouseBoss | Supported | Original object ID/drop slots, haunted-house cleansed/finished flags and obj_Requirement_HauntedHouse completion credit. Callback deferred while group hostiles remain. |
| obj_ThiefBoss | Supported | Original quest encounter identity, native randomized reward slots, cannot-escape rule and native kill-credit processing. |
| obj_DemonBossSpawner | Conditionally supported | Original controller, original Head/Body/Arms/Legs objects and controller's placement/initialization. Explicit ownership replaces global limb damage. |
| Spirit bosses: obj_DarkBrogt, obj_Corym, obj_DarkCorym, obj_Kytgol, obj_DarkKytgol, obj_Falront, obj_DarkFalront, obj_Moorv, obj_DarkMoorv, obj_Myrgel, obj_DarkMyrgel | Supported | Same shape as Brogt (spawned by Guardian Fire): original Create, relic/quest drop slots, cannot-escape rule and native trap timers (Falront, Myrgel). Kytgol's illusion cleanup runs as the deferred death tail. |
| obj_Princess, obj_DemonLord, obj_CosmosKing, obj_CosmosWorm | Supported | Spawned by the throne / Cosmos events, which continue on their own option buttons; original drops, cannot-escape rule and summon timers are kept. |
| obj_Skyeater | Supported | The Shadow ending: original summons timer and the ending object created when it is killed. An authored replacement keeps its own health and movement instead of the forced 9999 health and centred window. |
| Other objects | No adapter | Ordinary enemies are not override slots; use encounters instead. |

Overrides replace User 0 (the attack event), so native alternate attacks such as Brogt's boulders or the Cosmos Worm's wiggle do not run for an overridden boss; the authored actions do.

For single-slot adapters, original Create code runs before combat/presentation fields are applied. Native mandatory drop arrays, quest fields and flags remain intact. Generated attacks replace User 0 only. Original native reward logic runs once; any specialized completion tail is queued and runs after the final hostile friend/summon dies. A pending completion prevents the head's Leave button from destroying the callback owner early.

For the four-part Demon King, map **Head, Body, Arms, Legs** explicitly. Head must map to the override's selected head enemy. The spawner still creates obj_DemonBossHead, obj_DemonBossButt, obj_DemonBossArms and obj_DemonBossLegs. V2 appends ownership attachment. Their original globally targeted cross-part damage/deletion is the replaceable structural layer. Head death kills owned limbs; limb death uses the head definition's named component death action, default zero. No progression item slots exist on those vanilla parts.

Engine evidence covers original IDs, exact slots, head cleanup, mandatory King's Icon delivery, tomb/haunted-house flags and deferred callbacks. Conditional Demon King support covers its isolated original spawner and four-part fight, not a full playthrough of every ending. All other endgame controllers remain untouched. Select a different unsupported boss only after implementing and testing a dedicated adapter.

The catalog contains per-adapter protected/replaceable lists, required component slots and source evidence. Local extracted GML in Catalog/source makes review reproducible against the pinned original checksum.
