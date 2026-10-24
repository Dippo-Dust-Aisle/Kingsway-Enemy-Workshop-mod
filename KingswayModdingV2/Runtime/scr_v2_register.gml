scr_v2_init();
var key=string(argument0);
if (!ds_map_exists(global.v2_weights,key)) ds_map_add(global.v2_weights,key,ds_list_create());
var list=ds_map_find_value(global.v2_weights,key);
for(var i=0;i<ds_list_size(list);i+=2) if(ds_list_find_value(list,i)==argument1) {ds_list_replace(list,i+1,argument2);return;}
ds_list_add(list,argument1,argument2);
