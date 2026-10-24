var win=argument0;var actor=argument1;var sx=actor.v3_start_x;var sy=actor.v3_start_y;if(actor.v2_start_mode=="center"){sx=.5;sy=.5;}if(actor.v2_start_mode=="firstPoint" && ds_list_size(actor.v2_points)>=2){sx=ds_list_find_value(actor.v2_points,0);sy=ds_list_find_value(actor.v2_points,1);}if(actor.v3_mirrored && actor.v2_path==-4){sx=1-sx;sy=1-sy;}scr_v2_place(win,actor.v2_start_mode,sx,sy);

// A window that already has movement state (a reused hazard window) starts from
// where it was just placed, not from its previous owner's position.
if(variable_instance_exists(win,"v2_motion_x")){win.v2_motion_x=0;win.v2_motion_y=0;win.v2_motion_from_x=0;win.v2_motion_from_y=0;win.v2_motion_to_x=0;win.v2_motion_to_y=0;win.v2_motion_elapsed=0;win.v2_motion_duration=0;win.v2_motion_base_x=win.x/max(1,global.resolutionW/global.gameScale-win.width);win.v2_motion_base_y=win.y/max(1,global.resolutionH/global.gameScale-win.height-24);}
