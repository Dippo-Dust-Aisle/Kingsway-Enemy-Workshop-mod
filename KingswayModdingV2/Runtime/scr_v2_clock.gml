scr_v2_init();
global.v2_time+=(delta_time/1000000)*(global.gameSpeed>0);

if(!variable_global_exists("v3_frame"))global.v3_frame=0;
global.v3_frame+=1;
scr_v3_window_counts();
