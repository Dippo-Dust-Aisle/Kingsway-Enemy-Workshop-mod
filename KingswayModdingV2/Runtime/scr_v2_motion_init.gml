var win=argument0;if(variable_instance_exists(win,"v2_motion_x"))return;
win.v2_motion_x=0;win.v2_motion_y=0;win.v2_motion_from_x=0;win.v2_motion_from_y=0;
win.v2_motion_to_x=0;win.v2_motion_to_y=0;win.v2_motion_elapsed=0;win.v2_motion_duration=0;
win.v2_motion_easing="linear";win.v2_motion_boundary="inherit";
win.v2_motion_base_x=win.x/max(1,global.resolutionW/global.gameScale-win.width);
win.v2_motion_base_y=(win.minimized?win.minimizedPos:win.y)/max(1,global.resolutionH/global.gameScale-win.height-24);
win.v2_motion_actor=noone;
if(variable_instance_exists(win,"enemy") && instance_exists(win.enemy))win.v2_motion_actor=win.enemy;
else if(variable_instance_exists(win,"owner") && instance_exists(win.owner))win.v2_motion_actor=win.owner;
