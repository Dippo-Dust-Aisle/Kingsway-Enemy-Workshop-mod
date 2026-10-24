// A Workshop hazard's Close/Avoid button (replaces the native `destroy` button script).
// Runs the hazard's When closed actions, then closes its window with the native close
// effect. The hazard does not activate; scr_v2_hazard_step removes it once those
// actions (including their waits) have finished.
var actor=argument0;
if(!instance_exists(actor))return;
if(!variable_instance_exists(actor,"v2_hazard") || !actor.v2_hazard){with(actor)instance_destroy();return;}
if(actor.v2_expired)return;
actor.v2_expired=1;
var win=actor.screen;
with(actor)script_execute(v2_attacked_script,id,global.player,win,0,0);
if(instance_exists(actor)){win=actor.screen;actor.screen=-4;}
if(instance_exists(win))with(win)instance_destroy();
scr_v3_gone(actor);
