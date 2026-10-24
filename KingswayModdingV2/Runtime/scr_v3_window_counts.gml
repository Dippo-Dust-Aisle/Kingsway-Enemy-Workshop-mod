// Once per frame: how many v3 windows are dimmed (opacity < 10) or Always behind.
// While both are 0, wrapped Draw and Mouse events skip their per-call scripts.
// Window init and opacity/layer actions bump the counts at once (no one-frame lag).
global.v3_dim_count=0;global.v3_behind_count=0;
with(obj_Window){if(variable_instance_exists(id,"v3_window") && v3_window){if(v3_opacity<10)global.v3_dim_count+=1;if(v3_layer=="behind")global.v3_behind_count+=1;}}
