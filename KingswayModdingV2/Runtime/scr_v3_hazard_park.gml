// A Workshop hazard finished normally: keep its window for the next hazard instead
// of destroying it (creating a window allocates surfaces, a taskbar button, a close
// effect and re-sorts every window). Up to 8 are kept; the rest are destroyed.
// Parked windows are invisible, offscreen, off the taskbar and out of the window list.
var win=argument0;if(!instance_exists(win))return;
if(!variable_global_exists("v3_hazard_pool"))global.v3_hazard_pool=ds_list_create();
if(win.object_index!=obj_TrapWindow || ds_list_size(global.v3_hazard_pool)>=8 || !instance_exists(obj_DesktopControler)){with(win)instance_destroy();return;}
with(win){
    // Same bookkeeping as the native window Destroy event.
    if(instance_exists(startButton))with(startButton)instance_destroy();startButton=-4;hasStartBarButton=0; // native Step_1 updates startButton every frame while this is set
    global.windowsCount-=1;var closed=windowIndex;with(obj_Window){if(windowIndex>closed)windowIndex-=1;}
    var at=ds_list_find_index(obj_DesktopControler.windows,id);if(at>=0)ds_list_delete(obj_DesktopControler.windows,at);
    if(variable_instance_exists(id,"v2_path_driver") && instance_exists(v2_path_driver))with(v2_path_driver){path_end();instance_destroy();}
    if(variable_instance_exists(id,"v2_owned_path") && v2_owned_path>=0 && path_exists(v2_owned_path))path_delete(v2_owned_path);
    v2_owned_path=-1;v3_path_shift_x=0;v3_path_shift_y=0;
    if(variable_instance_exists(id,"v3_children"))ds_list_clear(v3_children);v3_children_count=-1;
    owner=-4;enemy=-4;active=0;pressed=0;clicked=0;moving=0;minimized=0;shakeAmount=0;shake=0;extraTitleText="";
    if(variable_instance_exists(id,"v3_dragging") && v3_dragging){v3_dragging=0;moveable=v3_saved_moveable;}
    v3_window=0;v3_layer="normal";v3_parked=1;visible=0;hidden=1;x=-9000;
    if(instance_exists(button)){button.visible=0;button.x=-9000;button.y=-9000;button.pressed=0;button.clicked=0;}
    if(instance_exists(progressBar)){progressBar.visible=0;}
}
ds_list_add(global.v3_hazard_pool,win);
