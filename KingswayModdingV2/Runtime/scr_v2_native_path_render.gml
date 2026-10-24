// The inherited window Step can finish a close and destroy the window just before this runs.
var win=argument0;if(!instance_exists(win) || win.minimized)return;
if(!variable_instance_exists(win,"v2_path_driver") || !instance_exists(win.v2_path_driver))return;
if(scr_v3_drag_busy(scr_v3_window_actor(win)))return;
var driver=win.v2_path_driver;
var px=driver.x/max(1,global.resolutionW/global.gameScale-win.width);var py=driver.y/max(1,global.resolutionH/global.gameScale-win.height-24);var actor=win.v2_motion_actor;if(instance_exists(actor) && actor.v3_mirrored){px=1-px;py=1-py;}
if(variable_instance_exists(win,"v3_path_shift_x")){px+=win.v3_path_shift_x;py+=win.v3_path_shift_y;}
scr_v2_motion_render(win,px,py);
