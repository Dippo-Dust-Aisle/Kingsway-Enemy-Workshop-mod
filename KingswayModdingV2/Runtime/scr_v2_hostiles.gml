var members = argument0;
var count = 0;
for (var i = 0; i < ds_list_size(members); i += 1) {
    var member = ds_list_find_value(members, i);
    if (instance_exists(member) && member.currentHealth > 0 && !member.escaped && (!variable_instance_exists(member,"v3_cosmetic") || !member.v3_cosmetic)) count += 1;
}
return count;
