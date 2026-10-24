// Called from the window's global left-press after native code decided the
// title bar is being dragged. Battle windows are natively immovable, so the
// window is movable only for the duration of the drag.
var win=argument0;
if(!variable_instance_exists(win,"v3_window") || !win.v3_window || !win.v3_actor || win.v3_dragging)return;
win.v3_dragging=1;win.v3_saved_moveable=win.moveable;win.moveable=1;
if(variable_instance_exists(win,"v2_motion_base_x")){var gx=win.v2_motion_base_x+win.v2_motion_x;var gy=win.v2_motion_base_y+win.v2_motion_y;}else{var gx=win.x/max(1,global.resolutionW/global.gameScale-win.width);var gy=win.y/max(1,global.resolutionH/global.gameScale-win.height-24);}
var actor=scr_v3_window_actor(win);
if(instance_exists(actor) && variable_instance_exists(actor,"v3_rtp_active"))actor.v3_rtp_active=0;
// Where the window was picked up (logical position), for If dragged Entry "none".
if(instance_exists(actor)){actor.v3_drag_grab_x=gx;actor.v3_drag_grab_y=gy;}
if(instance_exists(actor) && variable_instance_exists(actor,"v2_enabled")){actor.v3_active=0;actor.v3_drag_return=0;}
if(variable_instance_exists(win,"v2_motion_x"))win.v2_motion_elapsed=win.v2_motion_duration;
if(variable_instance_exists(win,"v2_path_driver") && instance_exists(win.v2_path_driver))win.v2_path_driver.path_speed=0;
