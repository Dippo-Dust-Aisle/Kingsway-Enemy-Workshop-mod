// Movement / Window "Delete": asks this Cosmetic or hazard to close. The actor may be
// mid-Step (its periodic actions run before its movement), so the actual removal
// happens at the end of the frame in scr_v3_delete_now. (Not for combat enemies.)
var actor=argument0;if(!instance_exists(actor))return;
actor.v3_deleting=1;
