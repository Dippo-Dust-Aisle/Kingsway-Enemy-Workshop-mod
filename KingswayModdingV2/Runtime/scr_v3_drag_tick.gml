// Advances the return transition. Returns 1 while it owns the window.
var actor=argument0;var dt=argument1;
if(!variable_instance_exists(actor,"v3_drag_return") || !actor.v3_drag_return)return 0;
var win=actor.screen;if(!instance_exists(win)){actor.v3_drag_return=0;return 0;}
var fx=actor.v3_drag_from_x;var fy=actor.v3_drag_from_y;var tx=actor.v3_drag_to_x;var ty=actor.v3_drag_to_y;
var duration=0;if(actor.v3_drag_speed>0)duration=scr_v3_iso_distance(win,fx,fy,tx,ty)/actor.v3_drag_speed; // speed 0 = instant
actor.v3_drag_time+=dt;var t=1;if(duration>0)t=min(1,actor.v3_drag_time/duration);
win.v2_motion_x=0;win.v2_motion_y=0;
scr_v2_motion_render(win,lerp(fx,tx,t),lerp(fy,ty,t));
if(t>=1){
    actor.v3_drag_return=0;win.v2_motion_boundary="inherit";
    var i=actor.v3_drag_index;
    if(i>=0){
        var points=actor.v2_points;
        actor.v2_move_started=1;actor.v3_spawn_active=0;actor.v3_radius_active=0;actor.v3_segment_override=0;
        actor.v2_move_segment=i;actor.v2_move_time=0;actor.v2_variance_x=0;actor.v2_variance_y=0;actor.v2_move_wait=points[|i*8+3];
        scr_v3_radius_begin(actor,i);
    }
}
return 1;
