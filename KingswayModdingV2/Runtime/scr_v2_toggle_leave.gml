var stack=ds_map_find_value(argument0,"toggles");
repeat(3){if(ds_list_size(stack)>0)ds_list_delete(stack,ds_list_size(stack)-1);}
