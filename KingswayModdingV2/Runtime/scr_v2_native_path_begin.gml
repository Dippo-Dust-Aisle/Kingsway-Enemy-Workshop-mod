var win=argument0;if(win.minimized)return;
if(!variable_instance_exists(win,"v2_path_driver") || !instance_exists(win.v2_path_driver))return;
if(scr_v3_drag_busy(scr_v3_window_actor(win)))return;
win.v2_display_x=win.x;win.v2_display_y=win.y;
win.x=win.v2_path_driver.x;win.y=win.v2_path_driver.y;
