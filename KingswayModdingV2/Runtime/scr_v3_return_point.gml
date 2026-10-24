// Movement / Window "Return to path point": the window travels from where it is now to
// Base Path point argument1 (1-based) in argument2 seconds (0 = instant) along a line, or
// an arc of bend argument3 (argument4 = 1: above or below at random), then the Base Path
// continues from that point. Any running Action Move or window move offset is dropped.
// Does nothing while the window is held or travelling back from a drag: its "If dragged"
// Entry rule applies then.
var actor=argument0;if(!instance_exists(actor) || !instance_exists(actor.screen) || scr_v3_drag_busy(actor))return 0;
var points=actor.v2_points;var count=ds_list_size(points) div 8;if(count<1 || actor.v2_path!=-4)return 0;
var win=actor.screen;scr_v2_motion_init(win);
var n=clamp(round(argument1),1,count)-1;
var rw=max(1,global.resolutionW/global.gameScale-win.width);var rh=max(1,global.resolutionH/global.gameScale-win.height-24);
var fx=win.x/rw;var fy=win.y/rh;if(win.minimized){fx=win.v2_motion_base_x+win.v2_motion_x;fy=win.v2_motion_base_y+win.v2_motion_y;}
actor.v3_active=0;
win.v2_motion_x=0;win.v2_motion_y=0;win.v2_motion_from_x=0;win.v2_motion_from_y=0;win.v2_motion_to_x=0;win.v2_motion_to_y=0;win.v2_motion_elapsed=0;win.v2_motion_duration=0;
// Go to the real point: drop the shift left by a drag released with Entry "None" and the
// point's random variance, so the Base Path continues from the point as authored.
if(variable_instance_exists(actor,"v3_drag_shift_x")){actor.v2_offset_x-=actor.v3_drag_shift_x;actor.v2_offset_y-=actor.v3_drag_shift_y;actor.v3_drag_shift_x=0;actor.v3_drag_shift_y=0;}
actor.v2_variance_x=0;actor.v2_variance_y=0;
var tx=points[|n*8];var ty=points[|n*8+1];if(actor.v3_mirrored){tx=1-tx;ty=1-ty;}
tx+=actor.v2_offset_x;ty+=actor.v2_offset_y;
actor.v3_rtp_active=1;actor.v3_rtp_point=n;actor.v3_rtp_time=0;actor.v3_rtp_duration=max(0,argument2);
actor.v3_rtp_fx=fx;actor.v3_rtp_fy=fy;actor.v3_rtp_tx=tx;actor.v3_rtp_ty=ty;
actor.v3_rtp_bend=argument3;if(argument4)actor.v3_rtp_bend*=choose(1,-1);
scr_v3_return_point_tick(actor,0);
return 1;
