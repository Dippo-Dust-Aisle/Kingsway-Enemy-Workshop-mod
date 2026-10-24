var win=argument0;
if(!variable_instance_exists(win,"v2_motion_x"))return;
var actor=win.v2_motion_actor;var paused=global.gameSpeed<=0;
if(instance_exists(actor) && variable_instance_exists(actor,"v2_enabled")){
    paused=paused || actor.escaped || actor.currentHealth<=0 || (actor.v2_pause_stun && actor.stunAmount>0) || (actor.v2_pause_minimized && win.minimized) || (actor.v2_pause_attack && (actor.attackReady<1 || actor.attackReady>9));
}
if(!paused && win.v2_motion_elapsed<win.v2_motion_duration){
    var dt=delta_time/1000000;if(argument_count>1)dt=argument1;
    win.v2_motion_elapsed=min(win.v2_motion_duration,win.v2_motion_elapsed+dt);
    var t=win.v2_motion_elapsed/win.v2_motion_duration;
    if(win.v2_motion_easing=="ease")t=t*t*(3-2*t);
    win.v2_motion_x=lerp(win.v2_motion_from_x,win.v2_motion_to_x,t);
    win.v2_motion_y=lerp(win.v2_motion_from_y,win.v2_motion_to_y,t);
}
scr_v2_motion_render(win);
