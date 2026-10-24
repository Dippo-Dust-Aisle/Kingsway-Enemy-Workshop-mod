// scr_v2_hostiles for an encounter group, counted at most once per frame. Every
// Cosmetic asks this twice per frame, which was (Cosmetics x members) work.
var members=argument0;
if(!variable_global_exists("v3_frame"))return scr_v2_hostiles(members);
if(!variable_global_exists("v3_alive_frame")){global.v3_alive_frame=ds_map_create();global.v3_alive_count=ds_map_create();}
if(ds_map_find_value(global.v3_alive_frame,members)==global.v3_frame)return ds_map_find_value(global.v3_alive_count,members);
var alive=scr_v2_hostiles(members);
ds_map_replace(global.v3_alive_frame,members,global.v3_frame);ds_map_replace(global.v3_alive_count,members,alive);
return alive;
