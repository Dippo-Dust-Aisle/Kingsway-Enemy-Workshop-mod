// A thing (Workshop enemy, hazard, Cosmetic or native projectile) died, escaped, was
// closed, went off or was deleted. Runs once per thing: every live Workshop actor with
// a matching "When thing dies/disappears" trigger runs it (scr_v2m_..._gone). The thing's
// own triggers run even though it is dead or leaving. Nested triggers are capped.
var inst=argument0;
if(!instance_exists(inst))return;
if(variable_instance_exists(inst,"v3_gone") && inst.v3_gone)return;
inst.v3_gone=1;
if(!variable_global_exists("v3_gone_depth") || global.v3_gone_depth>=8)return;
var obj=inst.object_index;
global.v3_gone_depth+=1;
var targets=ds_list_create();
with(obj_Enemy){if(variable_instance_exists(id,"v3_gone_script"))ds_list_add(targets,id);}
with(obj_v3_cosmetic){if(variable_instance_exists(id,"v3_gone_script"))ds_list_add(targets,id);}
for(var i=0;i<ds_list_size(targets);i+=1){
    var t=targets[|i];
    if(!instance_exists(t))continue;
    var isSelf=(t==inst);
    if(!isSelf && (t.currentHealth<=0 || t.escaped || (variable_instance_exists(t,"v2_expired") && t.v2_expired) || (variable_instance_exists(t,"v3_gone") && t.v3_gone)))continue;
    global.v3_gone_self=isSelf;
    script_execute(t.v3_gone_script,t,global.player,t.screen,inst,obj,isSelf);
    global.v3_gone_self=0;
}
ds_list_destroy(targets);
global.v3_gone_depth-=1;
