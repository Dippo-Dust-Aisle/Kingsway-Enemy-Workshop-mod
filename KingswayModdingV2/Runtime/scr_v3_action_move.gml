var actor=argument0;if(!instance_exists(actor) || !instance_exists(actor.screen))return 0;
var win=actor.screen;scr_v2_motion_init(win);
if(argument2){
    if(actor.v3_active){actor.v3_action_phase=2;actor.v3_action_time=0;actor.v3_action_wait=0;actor.v3_action_from_x=actor.v3_action_x;actor.v3_action_from_y=actor.v3_action_y;return 1;}
    scr_v2_window(win,"clearMoveOffset",0,0,0,"fixed","absolute",0,0,0,0,0,0,argument3,"linear","inherit");return 1;
}
if(actor.v3_active || scr_v3_drag_busy(actor) || !ds_map_exists(actor.v3_moves,argument1))return 0;
var move=ds_map_find_value(actor.v3_moves,argument1);var points=move[?"points"];var count=ds_list_size(points) div 8;if(count==0)return 0;
actor.v3_active=1;actor.v3_action_cfg=move;actor.v3_action_phase=0;actor.v3_action_time=0;actor.v3_action_wait=0;
actor.v3_action_mode=move[?"mode"];actor.v3_action_index=0;
actor.v3_return_x=win.v2_motion_base_x;actor.v3_return_y=win.v2_motion_base_y;
actor.v3_saved_offset_x=win.v2_motion_x;actor.v3_saved_offset_y=win.v2_motion_y;
actor.v3_action_x=win.v2_motion_base_x+win.v2_motion_x;actor.v3_action_y=win.v2_motion_base_y+win.v2_motion_y;
if(actor.v3_action_mode=="variation"){actor.v3_action_x-=win.v2_motion_base_x;actor.v3_action_y-=win.v2_motion_base_y;}
actor.v3_action_from_x=actor.v3_action_x;actor.v3_action_from_y=actor.v3_action_y;
win.v2_motion_elapsed=win.v2_motion_duration;
// Entry "none": no entry transition; the window starts the move at its first point.
if(move[?"entry"]=="none"){var nx=points[|0];var ny=points[|1];if(actor.v3_mirrored){if(actor.v3_action_mode=="variation"){nx=-nx;ny=-ny;}else{nx=1-nx;ny=1-ny;}}actor.v3_action_from_x=nx;actor.v3_action_from_y=ny;actor.v3_action_x=nx;actor.v3_action_y=ny;}
if(move[?"entry"]=="closest"){
    var best=100000;for(var i=0;i<count;i+=1){var px=points[|i*8];var py=points[|i*8+1];if(actor.v3_mirrored){if(actor.v3_action_mode=="variation"){px=-px;py=-py;}else{px=1-px;py=1-py;}}
        var distance=point_distance(actor.v3_action_x,actor.v3_action_y,px,py);if(distance<best){best=distance;actor.v3_action_index=i;}}
}
return 1;
