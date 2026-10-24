// Closes a Cosmetic or hazard flagged by scr_v3_delete_self, like pressing its
// Close/Avoid button: the window closes (native close effect) and the actor is
// removed. A deleted hazard does not activate. Returns 1 if it closed.
var actor=argument0;
if(!instance_exists(actor) || !variable_instance_exists(actor,"v3_deleting") || !actor.v3_deleting)return 0;
actor.v3_deleting=0;scr_v3_gone(actor);
if(variable_instance_exists(actor,"v2_hazard") && actor.v2_hazard){actor.v2_expired=1;var win=actor.screen;actor.screen=-4;if(instance_exists(win))with(win)instance_destroy();}
with(actor)instance_destroy();
return 1;
