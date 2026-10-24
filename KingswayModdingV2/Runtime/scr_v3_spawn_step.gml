var actor=argument0;var win=actor.screen;var points=actor.v2_points;
var dt=argument1;var tx=points[|0];var ty=points[|1];if(actor.v3_mirrored){tx=1-tx;ty=1-ty;}
var fx=actor.v3_spawn_x;var fy=actor.v3_spawn_y;var moveSpeed=points[|7];var duration=points[|2];
if(moveSpeed>0)duration=point_distance(fx,fy,tx,ty)/moveSpeed;
if(actor.v2_use_game_speed)duration=point_distance(fx*max(1,global.resolutionW/global.gameScale-win.width),fy*max(1,global.resolutionH/global.gameScale-win.height-24),tx*max(1,global.resolutionW/global.gameScale-win.width),ty*max(1,global.resolutionH/global.gameScale-win.height-24))/(actor.v2_game_speed*.8*room_speed);
actor.v3_spawn_time+=dt;var t=min(1,actor.v3_spawn_time/max(.000001,duration));scr_v2_motion_render(win,lerp(fx,tx,t),lerp(fy,ty,t));
if(t>=1){actor.v3_spawn_active=0;actor.v2_move_wait=points[|3];scr_v3_radius_begin(actor,0);}
