# Actions and reactions

Attack Actions contains the ordered attack, When attacked and Periodic sequences. Cosmetics expose Periodic only. Add a group once, then change its prominent Mode control. Fields update for the selected operation.

| Group | Modes and behavior |
| --- | --- |
| Damage | Weapon Attack uses native rolls, dodge, block, defence/protection, shields, reflection and on-hit effects, with multiplier and optional min/max overrides. Physical Damage has no attack roll and still uses defence. True Damage ignores defence, protection, dodge and blocking. Lifesteal from last damage retains the last resolved positive health damage. Damaging modes can also heal a percentage of resolved damage. |
| Magic / Status | Fixed, maximum-health or current-health magic damage bypasses defence with explicit blockability. Apply, Reduce or Clear a native family/variant using nonnegative strength. Exclusive next-attack effects replace the prior effect in their group. |
| Health / Mana | Choose resource, restore/drain/transfer/gain-from-last-damage operation, source/target, amount basis and amount. Transfer can restore a different resource with a multiplier, including the old mana-to-health behavior. |
| Text / Sound | Battle Message, Adventure Log, Play Sound, live title/name, portrait set/restore and timed restoration, portrait rotation, opacity and layering. Live renaming does not change the saved enemy ID. |
| Movement Actions | Named Action Move, Return to Base Path, Shake, Minimize, Maximize or Restore. See MOVEMENT-ACTIONS.md. |
| Summon / Spawn | Enemy, Cosmetic or Projectile / Hazard. Reviewed native adapters retain their effects. Supported trap buttons can say Close or Avoid. |
| Branches / Waits | Conditional, Chance, Alternating, Cooldown or Wait. Nested OTHERWISE branches and per-instance alternating/cooldown state survive pauses and continuation. |
| Kill attribution | Inside a **When thing dies/disappears** trigger for the enemy itself, a Conditional branch can test **This enemy was killed by the player** or **This enemy killed itself**. The last damage source wins: player attacks and native spells/statuses count as the player; the enemy's own Damage, Magic/True Damage, Health drain and self-targeted Strike count as itself. Escaping or being closed is neither. |
| Attack Speed | Set, Add, Multiply or Restore Base in native charge units, with optional meter reset. Chill continues to modify the live rate. |

Physical Damage does not ignore defence. Blockability and defence bypass are independent. Healing uses positive Health / Mana operations; negative authored damage is rejected.

Common timing and gate controls retain activation chance, repeat/interval, wait-before-next-action, target, positive-damage and blocking gates where applicable. Periodic and reaction roots have independent cooldowns. Native next-attack effects are consumed on the next attempted attack, including a dodge. Damage dependencies track actual positive health loss, excluding overkill and blocked damage.

Copy/Paste deep-copies a node and its branches between all applicable sections. **Copy to…** in the tab header replaces or appends the complete Attack Actions section on another enemy. Edits remain independent. Sequence limits are 12 levels, 256 nodes per enemy and bounded expansion.
