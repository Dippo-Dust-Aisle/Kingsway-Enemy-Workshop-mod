var actor = argument0;
var object = argument1;
var memberRole = argument2;
if (!instance_exists(actor) || (actor.currentHealth <= 0 && !global.v3_after_death)) return noone;
var members = scr_v2_group(actor);
// Object -> registry config, built once instead of searching the registry per spawn.
if(!variable_global_exists("v3_object_cfg")){global.v3_object_cfg=ds_map_create();var registryKey=ds_map_find_first(global.v2_registry);while(!is_undefined(registryKey)){var entry=ds_map_find_value(global.v2_registry,registryKey);ds_map_replace(global.v3_object_cfg,string(ds_map_find_value(entry,"v2_object")),entry);registryKey=ds_map_find_next(global.v2_registry,registryKey);}}
var objectCfg=ds_map_find_value(global.v3_object_cfg,string(object));
var cosmetic=0;var customHazard=0;if(!is_undefined(objectCfg)){cosmetic=ds_map_find_value(objectCfg,"v3_cosmetic");customHazard=ds_map_find_value(objectCfg,"v2_hazard");}
if(cosmetic){var visuals=0;for(var ci=0;ci<ds_list_size(members);ci+=1){var cm=members[|ci];if(instance_exists(cm) && cm.v3_cosmetic)visuals+=1;}if(visuals>=32 || scr_v2_hostiles(members)==0)return noone;}
if (memberRole == "summon" && !cosmetic) {
    var count = 0;
    for (var i = 0; i < ds_list_size(members); i += 1) {
        var member = ds_list_find_value(members, i);
        // Pending hazards (spawned with role summon) do not use up the combat summon cap.
        if (instance_exists(member) && member.role == "summon" && !member.v3_cosmetic && !(variable_instance_exists(member,"v2_hazard") && member.v2_hazard) && member.currentHealth > 0 && !member.escaped) count += 1;
    }
    if((!customHazard && (count>=3 || global.v2_time-actor.v2_spawn_time<0.25)) || count>=128)return noone;
    actor.v2_spawn_time = global.v2_time;
}
var child = instance_create_depth(0, 0, 0, object);
child.level = actor.level;
child.encounterGroupId = actor.encounterGroupId;
child.role = memberRole;
child.ownerHeadId = actor.ownerHeadId;
child.summonerId = actor;
child.v2_structural_amount = argument3;
child.v2_structural_percent = argument4;
child.v2_spawn_time = global.v2_time;
ds_list_add(members, child);
return child;
