var actor=argument0;if(!instance_exists(actor))return;
var points=actor.v2_points;
var count=ds_list_size(points) div 8;
if(!instance_exists(actor.screen))return;
var win=actor.screen;
if(variable_instance_exists(win,"v3_dragging") && win.v3_dragging)return;
if(actor.v3_drag_return){scr_v3_drag_tick(actor,delta_time/1000000*(global.gameSpeed>0));return;}
// "Return to path point" owns the window until it arrives.
if(variable_instance_exists(actor,"v3_rtp_active") && actor.v3_rtp_active){scr_v3_return_point_tick(actor);return;}
var wasDetour=actor.v3_active && actor.v3_action_mode=="detour";scr_v3_action_tick(actor);if(wasDetour){scr_v2_motion_render(win);return;}scr_v2_motion_step(win);
if(count<1)return;
if(!actor.v2_move_started && win.minimized)return;
if(!actor.v2_move_started && !actor.v3_legacy_spawn){actor.v2_move_started=1;var sx=actor.v3_start_x;var sy=actor.v3_start_y;if(actor.v2_start_mode=="center"){sx=.5;sy=.5;}if(actor.v2_start_mode=="firstPoint"){sx=points[|0];sy=points[|1];}if(actor.v3_mirrored){sx=1-sx;sy=1-sy;}scr_v2_place(win,actor.v2_start_mode,sx,sy);actor.v3_spawn_x=win.x/max(1,global.resolutionW/global.gameScale-win.width);actor.v3_spawn_y=win.y/max(1,global.resolutionH/global.gameScale-win.height-24);actor.v3_spawn_active=actor.v2_start_mode!="firstPoint";actor.v3_spawn_time=0;actor.v2_move_wait=0;if(!actor.v3_spawn_active){actor.v2_move_wait=points[|3];scr_v3_radius_begin(actor,0);}scr_v2_motion_render(win,actor.v3_spawn_x,actor.v3_spawn_y);return;}
if(!actor.v2_move_started){actor.v2_move_started=1;win.x=ds_list_find_value(points,0)*max(0,(global.resolutionW/global.gameScale)-win.width);win.y=ds_list_find_value(points,1)*max(0,(global.resolutionH/global.gameScale)-win.height-24);scr_v2_place(win,actor.v2_start_mode,ds_list_find_value(points,0),ds_list_find_value(points,1));actor.v2_offset_x=win.x/max(1,global.resolutionW/global.gameScale-win.width)-ds_list_find_value(points,0);actor.v2_offset_y=win.y/max(1,global.resolutionH/global.gameScale-win.height-24)-ds_list_find_value(points,1);actor.v2_move_wait=ds_list_find_value(points,3);scr_v2_motion_render(win,win.x/max(1,global.resolutionW/global.gameScale-win.width),win.y/max(1,global.resolutionH/global.gameScale-win.height-24));return;}
if((actor.v2_pause_dead && actor.currentHealth<=0)||(actor.v2_pause_stun && actor.stunAmount>0)||(actor.v2_pause_minimized && win.minimized)||(actor.v2_pause_attack && (actor.attackReady<1 || actor.attackReady>9))) return;
var dt=delta_time/1000000*(global.gameSpeed>0)*actor.v2_move_intensity;
if(actor.v2_use_game_speed){if((!actor.v2_hazard && (actor.attackReady<1 || actor.attackReady>9)) || actor.stopped>0 || actor.stunAmount>0)return;dt*=global.setting_enemyMoveSpeed/max(0.001,global.player.quickness);if(actor.coldAmount>0)dt*=0.5;}
if(actor.v3_spawn_active){scr_v3_spawn_step(actor,dt);return;}
if(actor.v2_move_wait>0){actor.v2_move_wait=max(0,actor.v2_move_wait-dt);return;}
if(actor.v3_radius_active){scr_v3_radius_step(actor,dt);return;}
if(count<2)return;
var a=actor.v2_move_segment;
var b=a+actor.v2_move_direction;
if(b>=count)b=actor.v2_move_loop;
if(actor.v2_move_direction<0 && b<actor.v2_move_loop)b=count-1;
var ax=ds_list_find_value(points,a*8);
var ay=ds_list_find_value(points,a*8+1);
var bx=ds_list_find_value(points,b*8);
var by=ds_list_find_value(points,b*8+1);
if(actor.v3_segment_override){ax=actor.v3_radius_x;ay=actor.v3_radius_y;}
var duration=ds_list_find_value(points,b*8+2);
var segmentSpeed=ds_list_find_value(points,b*8+7);
if(actor.v2_use_game_speed)duration=max(0.01,point_distance(ax*max(0,global.resolutionW/global.gameScale-win.width),ay*max(0,global.resolutionH/global.gameScale-win.height-24),bx*max(0,global.resolutionW/global.gameScale-win.width),by*max(0,global.resolutionH/global.gameScale-win.height-24))/(actor.v2_game_speed*0.8*room_speed));
else if(segmentSpeed>0)duration=max(0.01,point_distance(ax,ay,bx,by)/segmentSpeed);
actor.v2_move_time+=dt;
var t=min(1,actor.v2_move_time/duration);
var px;var py;
if(actor.v2_move_mode=="ease")t=t*t*(3-2*t);
px=lerp(ax,bx,t);py=lerp(ay,by,t);
if(actor.v2_move_mode=="bezier"){
    var cx=ds_list_find_value(points,a*8+5);var cy=ds_list_find_value(points,a*8+6);
    var dx=ds_list_find_value(points,b*8+5);var dy=ds_list_find_value(points,b*8+6);
    var u=1-t;px=u*u*u*ax+3*u*u*t*cx+3*u*t*t*dx+t*t*t*bx;py=u*u*u*ay+3*u*u*t*cy+3*u*t*t*dy+t*t*t*by;
}
if(actor.v2_move_mode=="catmullRom"){
    var previous=max(actor.v2_move_loop,a-1);if(a==0)previous=0;
    var next=b+1;if(next>=count)next=actor.v2_move_loop;
    var x0=ds_list_find_value(points,previous*8);var y0=ds_list_find_value(points,previous*8+1);
    var x3=ds_list_find_value(points,next*8);var y3=ds_list_find_value(points,next*8+1);
    px=0.5*((2*ax)+(-x0+bx)*t+(2*x0-5*ax+4*bx-x3)*t*t+(-x0+3*ax-3*bx+x3)*t*t*t);
    py=0.5*((2*ay)+(-y0+by)*t+(2*y0-5*ay+4*by-y3)*t*t+(-y0+3*ay-3*by+y3)*t*t*t);
}
var meta=actor.v3_point_meta;var shape=0;var bend=actor.v2_move_bend;if(ds_list_size(meta)>a*9+8){shape=meta[|a*9];bend=meta[|a*9+1];if(meta[|a*9+8])bend=-bend;}
// Arc 50/50 (shape 2): above or below at random, chosen each time the segment starts.
if(shape==2){if(!variable_instance_exists(actor,"v3_arc_segment") || actor.v3_arc_segment!=a){actor.v3_arc_segment=a;actor.v3_arc_sign=choose(1,-1);}bend*=actor.v3_arc_sign;}
if(shape>=1 || actor.v2_move_shape=="arc"){px+=-(by-ay)*bend*4*t*(1-t);py+=(bx-ax)*bend*4*t*(1-t);}
if(actor.v3_mirrored){px=1-px;py=1-py;}
px+=actor.v2_variance_x+actor.v2_offset_x;py+=actor.v2_variance_y+actor.v2_offset_y;
if(px<0||px>1||py<0||py>1){
    if(actor.v2_move_boundary=="restart"){actor.v2_move_segment=0;actor.v2_move_time=0;t=0;px=ds_list_find_value(points,0);py=ds_list_find_value(points,1);}
}
scr_v2_motion_render(win,px,py);
if(t>=1){actor.v3_arc_segment=-1;actor.v2_move_segment=b;actor.v2_move_time=0;actor.v2_move_wait=ds_list_find_value(points,b*8+3);var variance=ds_list_find_value(points,b*8+4);actor.v2_variance_x=random_range(-variance,variance);actor.v2_variance_y=random_range(-variance,variance);}

if(t>=1){actor.v3_segment_override=0;scr_v3_radius_begin(actor,b);}
