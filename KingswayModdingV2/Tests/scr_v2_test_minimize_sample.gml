var actor=argument0;var win=actor.screen;var sample=ds_map_create();
ds_map_add(sample,"case",global.v2_min_case);ds_map_add(sample,"label",actor.v2_min_test_label);ds_map_add(sample,"frame",argument1);
ds_map_add(sample,"mode",actor.v2_min_test_mode);ds_map_add(sample,"hazard",actor.v2_hazard);
var pathType="none";if(ds_list_size(actor.v2_points)>=16)pathType="custom";if(actor.v2_path!=-4)pathType="native";
ds_map_add(sample,"pathType",pathType);
ds_map_add(sample,"x",win.x);ds_map_add(sample,"y",win.y);ds_map_add(sample,"width",win.width);ds_map_add(sample,"height",win.height);
ds_map_add(sample,"imageXScale",win.image_xscale);ds_map_add(sample,"imageYScale",win.image_yscale);
ds_map_add(sample,"minimized",win.minimized);ds_map_add(sample,"minimizedPos",win.minimizedPos);ds_map_add(sample,"active",win.active);ds_map_add(sample,"moving",win.moving);
ds_map_add(sample,"time",actor.v2_move_time);ds_map_add(sample,"segment",actor.v2_move_segment);ds_map_add(sample,"direction",actor.v2_move_direction);ds_map_add(sample,"wait",actor.v2_move_wait);ds_map_add(sample,"intensity",actor.v2_move_intensity);
var phase=0;var speedValue=0;var driverX=0;var driverY=0;var flip=1;var stopped=0;
if(variable_instance_exists(win,"v2_path_driver") && instance_exists(win.v2_path_driver)){var driver=win.v2_path_driver;phase=driver.path_position;speedValue=driver.path_speed;driverX=driver.x;driverY=driver.y;}
if(variable_instance_exists(win,"pathFlip"))flip=win.pathFlip;if(variable_instance_exists(win,"pathStopped"))stopped=win.pathStopped;
ds_map_add(sample,"phase",phase);ds_map_add(sample,"pathSpeed",speedValue);ds_map_add(sample,"pathX",driverX);ds_map_add(sample,"pathY",driverY);ds_map_add(sample,"pathFlip",flip);ds_map_add(sample,"pathStopped",stopped);
var baseX=0;var baseY=0;var offsetX=0;var offsetY=0;var elapsed=0;var durationValue=0;
if(variable_instance_exists(win,"v2_motion_x")){baseX=win.v2_motion_base_x;baseY=win.v2_motion_base_y;offsetX=win.v2_motion_x;offsetY=win.v2_motion_y;elapsed=win.v2_motion_elapsed;durationValue=win.v2_motion_duration;}
ds_map_add(sample,"baseX",baseX);ds_map_add(sample,"baseY",baseY);ds_map_add(sample,"offsetX",offsetX);ds_map_add(sample,"offsetY",offsetY);ds_map_add(sample,"elapsed",elapsed);ds_map_add(sample,"duration",durationValue);
var file=file_text_open_append("v2-minimize-samples.jsonl");file_text_write_string(file,json_encode(sample));file_text_writeln(file);file_text_close(file);
return sample;
