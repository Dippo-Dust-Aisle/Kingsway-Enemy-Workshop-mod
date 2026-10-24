// True while the actor's window is held by the player or is travelling back
// to its Base Path after a drag. Every movement driver yields during that time.
var actor=argument0;if(!instance_exists(actor))return 0;
if(variable_instance_exists(actor,"v3_drag_return") && actor.v3_drag_return)return 1;
if(variable_instance_exists(actor,"screen") && instance_exists(actor.screen) && variable_instance_exists(actor.screen,"v3_dragging") && actor.screen.v3_dragging)return 1;
return 0;
