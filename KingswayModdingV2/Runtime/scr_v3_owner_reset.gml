// Invalidates every cached window owner (see scr_v3_owned_window). Called when a
// window becomes a v3 window, so its children pick it up on their next draw.
if(!variable_global_exists("v3_owner_epoch"))global.v3_owner_epoch=0;
global.v3_owner_epoch+=1;
