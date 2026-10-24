// Window trails. The window itself always draws normally; this runs at the end of
// a window's Draw. Every third frame while the window moves it re-draws the window
// and its children into a fresh surface and leaves that as a fading ghost just
// behind the window, so ghosts only show where the window has been.
var win=argument0;
if(!variable_global_exists("v3_composing")){global.v3_composing=0;global.v3_ghost_count=0;}
if(global.v3_composing || !variable_instance_exists(win,"v3_window") || !win.v3_window || !win.v3_trails || win.minimized)return;
win.v3_trail_frame+=1;
var moved=point_distance(win.x,win.y,win.v3_last_x,win.v3_last_y)>.5;
win.v3_last_x=win.x;win.v3_last_y=win.y;
if(!moved || win.v3_trail_frame mod 3!=0 || global.v3_ghost_count>=24)return;
var image=surface_create(win.width+8,win.height+8);if(!surface_exists(image))return;
// Children are found by scanning every instance; keep that list and rescan only when
// the instance count changes (ghosts excluded) or every 250 ms.
if(!variable_instance_exists(win,"v3_children")){win.v3_children=ds_list_create();win.v3_children_count=-1;win.v3_children_at=0;}
var children=win.v3_children;var population=instance_count-instance_number(obj_v3_ghost);
if(population!=win.v3_children_count || current_time>=win.v3_children_at){ds_list_clear(children);with(all){if(id!=win && scr_v3_owned_window(id)==win)ds_list_add(children,id);}win.v3_children_count=population;win.v3_children_at=current_time+250;}
var saved=matrix_get(matrix_world);
surface_set_target(image);draw_clear_alpha(c_black,0);
// Normal blending squares alpha inside a surface; accumulate alpha separately so
// the ghost is a faithful (premultiplied) copy of the window.
gpu_set_blendmode_ext_sepalpha(5,6,2,6);
matrix_set(matrix_world,matrix_build(-win.x,-win.y,0,0,0,0,1,1,1));global.v3_composing=1;
with(win)event_perform(ev_draw,0);
var nodes=ds_priority_create();
for(var ci=0;ci<ds_list_size(children);ci+=1){var child=children[|ci];if(instance_exists(child) && child.visible)ds_priority_add(nodes,child,child.depth);}
while(!ds_priority_empty(nodes)){var node=ds_priority_delete_max(nodes);if(instance_exists(node))with(node)event_perform(ev_draw,0);}
ds_priority_destroy(nodes);
gpu_set_blendmode(0);matrix_set(matrix_world,saved);surface_reset_target();global.v3_composing=0;draw_set_alpha(1);
var ghost=instance_create_depth(win.x,win.y,win.depth+1,obj_v3_ghost);ghost.owner=win;ghost.image=image;ghost.opacity=win.v3_opacity/10;
