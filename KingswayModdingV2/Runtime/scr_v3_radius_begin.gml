var actor=argument0;var index=argument1;var meta=actor.v3_point_meta;var points=actor.v2_points;
if(ds_list_size(meta)<=index*9+8 || meta[|index*9+2]!=1)return;
var left=meta[|index*9+5];var right=meta[|index*9+6];var angle=0;
if(random(left+right)<left)angle=180+random_range(-left/2,left/2);else angle=random_range(-right/2,right/2);
angle+=meta[|index*9+7];if(meta[|index*9+8])angle+=180;
actor.v3_radius_x=points[|index*8];actor.v3_radius_y=points[|index*8+1];
actor.v3_radius_to_x=actor.v3_radius_x+dcos(angle)*meta[|index*9+3];
actor.v3_radius_to_y=actor.v3_radius_y+dsin(angle)*meta[|index*9+3];actor.v3_radius_active=1;
