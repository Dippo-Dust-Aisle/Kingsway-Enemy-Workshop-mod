var actor = argument0;
if (actor.v2_death_done) return 0;
actor.v2_death_done = 1;
var members = scr_v2_group(actor);
if (actor.role == "head") {
    for (var i = 0; i < ds_list_size(members); i += 1) {
        var member = ds_list_find_value(members, i);
        if (instance_exists(member) && member.role == "limb" && member.ownerHeadId == actor){if(member.v3_cosmetic){with(member)instance_destroy();}else member.currentHealth=0;}
    }
}
if (actor.role == "limb") {
    var head = actor.ownerHeadId;
    if (instance_exists(head) && head.currentHealth > 0) {
        var damage = actor.v2_structural_amount;
        if (actor.v2_structural_percent) damage = head.maxHealth * damage / 100;
        head.currentHealth -= damage;
    }
}
if (actor.role == "limb" || actor.role == "summon") {
    if (instance_exists(actor.screen)) actor.screen.battleOver = 1;
    return 0;
}
if (!actor.v2_loot_done) {
    actor.v2_loot_done = 1;
    with (actor) script_execute(v2_loot_script);
}
return 1;
