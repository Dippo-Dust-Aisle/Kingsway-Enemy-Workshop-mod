// The player released a dragged window. Keep it where it was dropped (even
// offscreen), then travel back at the actor's "If dragged" Transition speed:
// to the Base Path via Entry, to where a native path paused, or, without any
// path, by the smallest move that puts the window fully back on screen.
var win=argument0;win.v3_dragging=0;win.moving=0;win.moveable=win.v3_saved_moveable;
var actor=scr_v3_window_actor(win);
scr_v2_motion_init(win);
var rw=max(1,global.resolutionW/global.gameScale-win.width);var rh=max(1,global.resolutionH/global.gameScale-win.height-24);
var dropX=win.x;var dropY=win.y;
if(variable_instance_exists(win,"v3_drop_x")){dropX=win.v3_drop_x;dropY=win.v3_drop_y;}
var cx=dropX/rw;var cy=dropY/rh;
win.v2_motion_x=0;win.v2_motion_y=0;win.v2_motion_from_x=0;win.v2_motion_from_y=0;win.v2_motion_to_x=0;win.v2_motion_to_y=0;
win.v2_motion_elapsed=0;win.v2_motion_duration=0;win.v2_motion_boundary="inherit";
win.v2_motion_base_x=cx;win.v2_motion_base_y=cy;
win.x=dropX;win.y=dropY;
if(!instance_exists(actor) || !variable_instance_exists(actor,"v2_enabled") || !variable_instance_exists(actor,"v3_drag_entry"))return;
var points=actor.v2_points;var count=ds_list_size(points) div 8;
var hasDriver=variable_instance_exists(win,"v2_path_driver") && instance_exists(win.v2_path_driver);
// Entry "none" (Don't move): stay exactly where dropped. A Base Path or native
// profile continues from here, shifted by how far the window was dragged.
if(actor.v3_drag_entry=="none"){
    var heldX=actor.v3_drag_grab_x;var heldY=actor.v3_drag_grab_y;
    if(hasDriver){if(!variable_instance_exists(win,"v3_path_shift_x")){win.v3_path_shift_x=0;win.v3_path_shift_y=0;}win.v3_path_shift_x+=cx-heldX;win.v3_path_shift_y+=cy-heldY;}
    else if(count>=1){actor.v2_offset_x+=cx-heldX;actor.v2_offset_y+=cy-heldY;
        // Remember the drag shift separately so "Return to path point" can go to the real point.
        if(!variable_instance_exists(actor,"v3_drag_shift_x")){actor.v3_drag_shift_x=0;actor.v3_drag_shift_y=0;}actor.v3_drag_shift_x+=cx-heldX;actor.v3_drag_shift_y+=cy-heldY;}
    scr_v2_motion_render(win,cx,cy);return;
}
var tx=clamp(cx,0,1);var ty=clamp(cy,0,1);var index=-1;
if(hasDriver){
    tx=win.v2_path_driver.x/rw;ty=win.v2_path_driver.y/rh;if(actor.v3_mirrored){tx=1-tx;ty=1-ty;}
}else if(count>=1){
    index=0;
    if(actor.v3_drag_entry=="closest"){
        var best=100000;
        for(var i=0;i<count;i+=1){var px=points[|i*8];var py=points[|i*8+1];if(actor.v3_mirrored){px=1-px;py=1-py;}px+=actor.v2_offset_x;py+=actor.v2_offset_y;var d=point_distance(cx,cy,px,py);if(d<best){best=d;index=i;}}
    }
    tx=points[|index*8];ty=points[|index*8+1];if(actor.v3_mirrored){tx=1-tx;ty=1-ty;}tx+=actor.v2_offset_x;ty+=actor.v2_offset_y;
}
// Boundary is "None" for the whole return so an offscreen drop never snaps.
win.v2_motion_boundary="none";
actor.v3_drag_return=1;actor.v3_drag_index=index;actor.v3_drag_time=0;
actor.v3_drag_from_x=cx;actor.v3_drag_from_y=cy;actor.v3_drag_to_x=tx;actor.v3_drag_to_y=ty;
scr_v2_motion_render(win,cx,cy);
