var actor=argument0;
var key=argument1;
var delay=argument2;
if(ds_map_exists(actor.v2_cooldowns,key) && global.v2_time < ds_map_find_value(actor.v2_cooldowns,key)) return 0;
ds_map_replace(actor.v2_cooldowns,key,global.v2_time+delay);
return 1;
