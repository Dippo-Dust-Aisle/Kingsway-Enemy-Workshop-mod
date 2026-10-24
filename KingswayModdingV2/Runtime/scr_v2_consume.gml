var actor = argument0;
var group = argument1;
var value = argument2;
if (variable_instance_exists(actor,"v2_effects") && ds_map_exists(actor.v2_effects,group)) {
    var effect = ds_map_find_value(actor.v2_effects,group);
    value = ds_list_find_value(effect,1);
    ds_list_destroy(effect);
    ds_map_delete(actor.v2_effects,group);
}
return value;
