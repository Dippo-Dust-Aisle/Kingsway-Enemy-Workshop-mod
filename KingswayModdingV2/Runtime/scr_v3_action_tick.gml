var actor=argument0;if(!actor.v3_active || !instance_exists(actor.screen))return;
var win=actor.screen;
if(actor.currentHealth<=0 || actor.escaped){actor.v3_active=0;return;}
if(global.gameSpeed<=0 || (actor.v2_pause_stun && actor.stunAmount>0) || (actor.v2_pause_minimized && win.minimized) || (actor.v2_pause_attack && (actor.attackReady<1 || actor.attackReady>9)))return;
var dt=delta_time/1000000;if(argument_count>1)dt=argument1;
dt*=actor.v2_move_intensity;if(actor.v2_use_game_speed){dt*=global.setting_enemyMoveSpeed/max(.001,global.player.quickness);if(actor.coldAmount>0)dt*=.5;}
if(actor.v3_action_wait>0){actor.v3_action_wait=max(0,actor.v3_action_wait-dt);return;}
var move=actor.v3_action_cfg;var points=move[?"points"];var meta=move[?"meta"];var count=ds_list_size(points) div 8;
var index=actor.v3_action_index;var phase=actor.v3_action_phase;var tx=0;var ty=0;var duration=0;
if(phase==3){tx=actor.v3_action_radius_x;ty=actor.v3_action_radius_y;}
else if(phase==2){if(actor.v3_action_mode=="detour"){tx=actor.v3_return_x+actor.v3_saved_offset_x;ty=actor.v3_return_y+actor.v3_saved_offset_y;}}
else {tx=points[|index*8];ty=points[|index*8+1];if(actor.v3_mirrored){if(actor.v3_action_mode=="variation"){tx=-tx;ty=-ty;}else{tx=1-tx;ty=1-ty;}}}
var fx=actor.v3_action_from_x;var fy=actor.v3_action_from_y;
if(phase==3)duration=point_distance(fx,fy,tx,ty)/meta[|index*9+4];
else if(phase==0 || phase==2){
    // Transition speed 0 = instant. Entry "none" always jumps straight to Point 1.
    duration=0;if(move[?"speed"]>0 && !(phase==0 && move[?"entry"]=="none"))duration=scr_v3_iso_distance(win,fx,fy,tx,ty)/move[?"speed"];
}
else {var moveSpeed=points[|index*8+7];duration=points[|index*8+2];if(moveSpeed>0)duration=point_distance(fx,fy,tx,ty)/moveSpeed;}
actor.v3_action_time+=dt;var t=min(1,actor.v3_action_time/max(.000001,duration));
actor.v3_action_x=lerp(fx,tx,t);actor.v3_action_y=lerp(fy,ty,t);
if(phase==1 && index>0 && meta[|(index-1)*9]>=1){var bend=meta[|(index-1)*9+1];if(meta[|(index-1)*9]==2){if(!variable_instance_exists(actor,"v3_action_arc_index") || actor.v3_action_arc_index!=index || actor.v3_action_time<=dt){actor.v3_action_arc_index=index;actor.v3_action_arc_sign=choose(1,-1);}bend*=actor.v3_action_arc_sign;}if(meta[|(index-1)*9+8])bend=-bend;actor.v3_action_x-= (ty-fy)*bend*4*t*(1-t);actor.v3_action_y+=(tx-fx)*bend*4*t*(1-t);}
if(t>=1){
    actor.v3_action_time=0;actor.v3_action_from_x=tx;actor.v3_action_from_y=ty;
    if(phase==2){actor.v3_active=0;win.v2_motion_x=0;win.v2_motion_y=0;if(actor.v3_action_mode=="detour"){win.v2_motion_x=actor.v3_saved_offset_x;win.v2_motion_y=actor.v3_saved_offset_y;}win.v2_motion_to_x=win.v2_motion_x;win.v2_motion_to_y=win.v2_motion_y;}
    else if(phase!=3 && meta[|index*9+2]==1){
        actor.v3_action_wait=points[|index*8+3];actor.v3_action_phase=3;
        var left=meta[|index*9+5];var right=meta[|index*9+6];var angle=0;
        if(random(left+right)<left)angle=180+random_range(-left/2,left/2);else angle=random_range(-right/2,right/2);
        angle+=meta[|index*9+7];if(meta[|index*9+8])angle+=180;if(actor.v3_mirrored)angle+=180;
        actor.v3_action_radius_x=tx+dcos(angle)*meta[|index*9+3];actor.v3_action_radius_y=ty+dsin(angle)*meta[|index*9+3];
    }
    else {actor.v3_action_wait=0;if(phase!=3)actor.v3_action_wait=points[|index*8+3];actor.v3_action_index+=1;actor.v3_action_phase=1;if(actor.v3_action_index>=count)actor.v3_action_phase=2;}
}
scr_v2_motion_render(win);
