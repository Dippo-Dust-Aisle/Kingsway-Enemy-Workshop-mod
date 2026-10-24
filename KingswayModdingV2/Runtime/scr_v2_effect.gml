var actor = argument0;
var group = argument1;
if (!variable_instance_exists(actor,"v2_effects")) actor.v2_effects = ds_map_create();
if (ds_map_exists(actor.v2_effects,group)) ds_list_destroy(ds_map_find_value(actor.v2_effects,group));
var effect = ds_list_create();
ds_list_add(effect,argument2,argument3,argument4);
ds_map_replace(actor.v2_effects,group,effect);
if (group == "next_attack_damage") actor.doubleDamage = 0;
// Native Bolster's icon is replaced by this group's single presentation.
if (actor == global.player && group == "next_attack_damage") with (obj_BolsterEffect) instance_destroy();
