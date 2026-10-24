
scr_v2_init();

{for(var si=ds_list_size(global.v2_sequences)-1;si>=0;si-=1){var seq=global.v2_sequences[|si];scr_v2_sequence_run(seq);if(seq[?"script"]==-1 && seq[?"wake"]<=global.v2_time){var source=seq[?"actor"];if(instance_exists(source))source.v2_pending=max(0,source.v2_pending-1);ds_list_destroy(ds_map_find_value(seq,"toggles"));ds_map_destroy(seq);ds_list_delete(global.v2_sequences,si);}}}

var key = ds_map_find_first(global.v2_groups);
while (!is_undefined(key)) {
    var members = ds_map_find_value(global.v2_groups, key);
    var alive = scr_v2_hostiles(members);
    if (alive > 0) global.battling = 1;
    var existing = 0;
    for (var i = ds_list_size(members) - 1; i >= 0; i -= 1) {
        var member = ds_list_find_value(members, i);
        if (instance_exists(member)) {
            if(variable_instance_exists(member,"v3_cosmetic") && member.v3_cosmetic && alive==0){with(member)instance_destroy();continue;}
            existing += 1;
            if (alive == 0 && variable_instance_exists(member,"v2_completion") && member.v2_completion != -1) {
                var callback = member.v2_completion;
                member.v2_completion = -1;
                with (member) script_execute(callback);
            }
        } else ds_list_delete(members, i);
    }
    var next_key = ds_map_find_next(global.v2_groups, key);
    if (existing == 0) {
        ds_list_destroy(members);
        ds_map_delete(global.v2_groups, key);
    }
    key = next_key;
}

scr_v2_music_tick();

