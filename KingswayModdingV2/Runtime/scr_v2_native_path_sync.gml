var win=argument0;
if(!variable_instance_exists(win,"v2_path_driver") || !instance_exists(win.v2_path_driver))return;
var driver=win.v2_path_driver;var source=win.v2_motion_actor;if(instance_exists(source) && ((source.v3_active && source.v3_action_mode=="detour") || scr_v3_drag_busy(source))){driver.path_speed=0;return;}
if(win.minimized){driver.path_speed=0;return;}
driver.x=win.x;driver.y=win.y;driver.path_speed=win.path_speed;
var actor=win.v2_motion_actor;
if(global.gameSpeed<=0 || win.minimized || win.moveable || !instance_exists(actor))driver.path_speed=0;
else if(actor.currentHealth<=0 || actor.escaped)driver.path_speed=0;
scr_v2_native_path_render(win);
