var actor=argument0;var meta=actor.v3_point_meta;var i=actor.v2_move_segment*9;var dt=argument1;
var dx=actor.v3_radius_to_x-actor.v3_radius_x;var dy=actor.v3_radius_to_y-actor.v3_radius_y;var distance=point_distance(0,0,dx,dy);var step=meta[|i+4]*dt;
if(distance<=step){actor.v3_radius_x=actor.v3_radius_to_x;actor.v3_radius_y=actor.v3_radius_to_y;actor.v3_radius_active=0;actor.v3_segment_override=1;}
else{actor.v3_radius_x+=dx/distance*step;actor.v3_radius_y+=dy/distance*step;}
var px=actor.v3_radius_x;var py=actor.v3_radius_y;if(actor.v3_mirrored){px=1-px;py=1-py;}scr_v2_motion_render(actor.screen,px+actor.v2_offset_x,py+actor.v2_offset_y);
