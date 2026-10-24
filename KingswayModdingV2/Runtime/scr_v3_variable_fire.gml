// Variable Action: activates a Variable (1-99) for the whole project. Every live
// enemy, limb, summon, hazard and Cosmetic from the same project runs its matching
// Variable Branches (scr_v2m_..._variable). Nested activations are capped so a
// branch that re-fires its own Variable cannot loop forever.
var source=argument0;var variable=argument1;
if(!instance_exists(source) || !variable_instance_exists(source,"v2_key"))return;
if(!variable_global_exists("v3_variable_depth"))global.v3_variable_depth=0;
if(global.v3_variable_depth>=8)return;
var colon=string_pos(":",source.v2_key);var prefix=string_copy(source.v2_key,1,colon);
global.v3_variable_depth+=1;
var targets=ds_list_create();
with(obj_Enemy){if(variable_instance_exists(id,"v3_variable_script") && string_copy(v2_key,1,colon)==prefix)ds_list_add(targets,id);}
with(obj_v3_cosmetic){if(variable_instance_exists(id,"v3_variable_script") && string_copy(v2_key,1,colon)==prefix)ds_list_add(targets,id);}
for(var i=0;i<ds_list_size(targets);i+=1){
    var t=targets[|i];
    if(!instance_exists(t) || t.currentHealth<=0 || t.escaped || (variable_instance_exists(t,"v2_expired") && t.v2_expired))continue;
    script_execute(t.v3_variable_script,t,global.player,t.screen,variable);
}
ds_list_destroy(targets);
global.v3_variable_depth-=1;
