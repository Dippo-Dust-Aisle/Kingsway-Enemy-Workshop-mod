// Authored positive bonuses are added to existing native properties, never rerolled.
var item = argument0;
var stat = argument1;
var amount = argument2;
var label = argument3;
var slot = -1;
for (var n = 0; n < 9; n += 1) {
    if (item.bonus[n,0] == stat) {
        item.bonus[n,1] += amount;
        return;
    }
    if (slot < 0 && item.bonus[n,0] == "") slot = n;
}
if (slot < 0) show_error("V2 loot has no free bonus slot for " + stat, true);
item.bonus[slot,0] = stat;
item.bonus[slot,1] = amount;
item.bonus[slot,2] = label;
