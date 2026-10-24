var actor = argument0;
if (!variable_instance_exists(actor, "v2_enabled")) return;
var members = scr_v2_group(actor);
for (var i = ds_list_size(members) - 1; i >= 0; i -= 1) {
    var member = ds_list_find_value(members, i);
    if (instance_exists(member)) {
        member.escaped = 1;
        if (instance_exists(member.screen)) { member.screen.escaped = 1; member.screen.battleOver = 1; }
        else with (member) instance_destroy();
    }
}
