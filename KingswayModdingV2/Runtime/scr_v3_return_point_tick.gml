// Advances "Return to path point" (scr_v3_return_point); on arrival the Base Path resumes
// from that point (its wait and Radius Random apply as if the path had arrived there).
var actor=argument0;var win=actor.screen;if(!instance_exists(win)){actor.v3_rtp_active=0;return;}
if((actor.v2_pause_stun && actor.stunAmount>0) || (actor.v2_pause_minimized && win.minimized) || (actor.v2_pause_dead && actor.currentHealth<=0))return;
var dt=delta_time/1000000*(global.gameSpeed>0);if(argument_count>1)dt=argument1;
actor.v3_rtp_time+=dt;
var t=1;if(actor.v3_rtp_duration>0)t=min(1,actor.v3_rtp_time/actor.v3_rtp_duration);
var fx=actor.v3_rtp_fx;var fy=actor.v3_rtp_fy;var tx=actor.v3_rtp_tx;var ty=actor.v3_rtp_ty;
var px=lerp(fx,tx,t);var py=lerp(fy,ty,t);
if(actor.v3_rtp_bend!=0){px+=-(ty-fy)*actor.v3_rtp_bend*4*t*(1-t);py+=(tx-fx)*actor.v3_rtp_bend*4*t*(1-t);}
scr_v2_motion_render(win,px,py);
if(t>=1){
    var n=actor.v3_rtp_point;
    actor.v3_rtp_active=0;actor.v2_move_started=1;actor.v3_spawn_active=0;actor.v3_radius_active=0;actor.v3_segment_override=0;
    actor.v2_move_segment=n;actor.v2_move_time=0;actor.v2_move_wait=ds_list_find_value(actor.v2_points,n*8+3);
    scr_v3_radius_begin(actor,n);
}
