var table = argument0;
if (!ds_map_exists(global.v2_weights,string(table))) return ds_list_find_value(table,irandom(ds_list_size(table)-1));
var extra = ds_map_find_value(global.v2_weights,string(table));
var total = ds_list_size(table);
for (var i=1;i<ds_list_size(extra);i+=2) total += ds_list_find_value(extra,i);
var roll = random(total);
if (roll < ds_list_size(table)) return ds_list_find_value(table,floor(roll));
roll -= ds_list_size(table);
for (var i=0;i<ds_list_size(extra);i+=2) {
    var weight = ds_list_find_value(extra,i+1);
    if (roll < weight) return ds_list_find_value(extra,i);
    roll -= weight;
}
return ds_list_find_value(table,0);
