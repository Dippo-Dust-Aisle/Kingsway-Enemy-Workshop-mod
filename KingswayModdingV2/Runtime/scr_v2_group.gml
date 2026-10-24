var actor = argument0;
if (actor.encounterGroupId < 0) {
    global.v2_group_serial += 1;
    actor.encounterGroupId = global.v2_group_serial;
    var members = ds_list_create();
    ds_list_add(members, actor);
    ds_map_add(global.v2_groups, string(actor.encounterGroupId), members);
}
return ds_map_find_value(global.v2_groups, string(actor.encounterGroupId));
