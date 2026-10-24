var win=argument0;
if(win.minimized && !variable_instance_exists(win,"v2_motion_x"))return;
scr_v2_motion_init(win);
var rw=max(0,global.resolutionW/global.gameScale-win.width);var rh=max(0,global.resolutionH/global.gameScale-win.height-24);
if(argument_count>2){win.v2_motion_base_x=argument1;win.v2_motion_base_y=argument2;}
// Native Window Step owns displayed position throughout minimization. Logical
// state may still advance when the author explicitly disables Pause minimized.
if(win.minimized)return;
if(variable_instance_exists(win,"v3_dragging") && win.v3_dragging)return;
var policy=scr_v2_motion_policy(win);
var px=win.v2_motion_base_x+win.v2_motion_x;var py=win.v2_motion_base_y+win.v2_motion_y;var actor=win.v2_motion_actor;
if(instance_exists(actor) && variable_instance_exists(actor,"v3_active") && actor.v3_active){px=actor.v3_action_x;py=actor.v3_action_y;if(actor.v3_action_mode=="variation"){px+=win.v2_motion_base_x;py+=win.v2_motion_base_y;}}
var oldX=win.x;var oldY=win.y;
win.x=scr_v2_motion_bound(px,policy)*rw;win.y=scr_v2_motion_bound(py,policy)*rh;
// Moving never changes the window frame, so only realign title buttons (as native
// dragging does). Rebuilding the frame surface every frame was the main per-window cost.
if(win.x!=oldX || win.y!=oldY)with(win)scr_AlignWindowButtons();
if(!surface_exists(win.windowSurface))win.updateWindowSurface=1;
