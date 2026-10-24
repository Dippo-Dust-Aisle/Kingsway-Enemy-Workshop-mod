var actor = argument0;
var family = argument1;
var amount = argument2;
if(amount<0){if(family=="curse"){var remaining=ceil(-amount);with(obj_CurseEffect_Strength){if(remaining>0){remaining-=1;instance_destroy();}}with(obj_CurseEffect_Agility){if(remaining>0){remaining-=1;instance_destroy();}}with(obj_CurseEffect_Intellect){if(remaining>0){remaining-=1;instance_destroy();}}with(obj_CurseEffect_Vitality){if(remaining>0){remaining-=1;instance_destroy();}}}else{var field=family+"Amount";variable_instance_set(actor,field,max(0,variable_instance_get(actor,field)+amount));}return;}
var popup="familyDefault";if(variable_global_exists("v3_status_popup"))popup=global.v3_status_popup;variable_instance_set(actor,"v3_"+family+"_popup",popup);
variable_instance_set(actor,"v2_"+family+"_name",argument3);variable_instance_set(actor,"v2_"+family+"_icon",argument4);
var statusObject=noone;
if(actor==global.player){
    if(family=="poison"){if(actor.charm_poisonImmunity)return;statusObject=obj_SlowPoisonEffect;}
    if(family=="cold")statusObject=obj_ChilledEffect;
    if(family=="burn"){if(actor.class=="Demonblood")return;statusObject=obj_BurnedEffect;}
    if(family=="stun" && actor.charm_stunImmunity)return;
    if(family=="curse" && actor.charm_curseImmunity)return;
}
global.v3_in_status=1;
if (family == "curse") {
    if (actor == global.player) repeat(ceil(amount)) {var effect=instance_create_depth(0,0,0,choose(obj_CurseEffect_Strength,obj_CurseEffect_Agility,obj_CurseEffect_Intellect,obj_CurseEffect_Vitality));if(argument3!=""){effect.v2_variant_name=argument3;effect.v2_variant_icon=argument4;}}
} else {
    var field = family + "Amount";
    var before=variable_instance_get(actor,field);
    if(statusObject!=noone){if(!instance_exists(statusObject))instance_create_depth(0,0,0,statusObject);var statusInstance=instance_find(statusObject,0);statusInstance.v2_variant_name=argument3;statusInstance.v2_variant_icon=argument4;}
    variable_instance_set(actor, field, max(0,before + amount));
}
global.v3_in_status=0;
if (argument3 != "") {
    variable_instance_set(actor,"v2_" + family + "_name",argument3);
    variable_instance_set(actor,"v2_" + family + "_icon",argument4);
}
