// The window for a new Workshop hazard: a parked one if available (scr_v3_hazard_park),
// otherwise a new obj_TrapWindow. A reused window is re-registered exactly like a new
// one (window list, taskbar button, selection) and re-initialised by scr_v3_window_step.
var actor=argument0;var win=noone;
if(variable_global_exists("v3_hazard_pool")){
    while(ds_list_size(global.v3_hazard_pool)>0 && !instance_exists(win)){win=global.v3_hazard_pool[|0];ds_list_delete(global.v3_hazard_pool,0);}
}
if(!instance_exists(win) || !instance_exists(obj_DesktopControler))return instance_create_depth(0,0,0,obj_TrapWindow);
with(win){
    v3_parked=0;visible=1;hidden=0;owner=actor;enemy=actor;battleOver=0;alert=1;
    windowIndex=global.windowsCount;global.windowsCount+=1;ds_list_add(obj_DesktopControler.windows,id);
    if(instance_number(obj_StartBar)>0){startButton=instance_create(-900,-900,obj_StartBarButton);startButton.width=global.startButtonWidth;startButton.icon=icon;startButton.owner=id;hasStartBarButton=1;}
    if(instance_exists(button)){button.visible=1;button.arguments[0]=actor;}
    if(instance_exists(progressBar)){progressBar.visible=1;progressBar.progress=0;}
    // Fresh logical motion state (scr_v2_motion_init only initialises once per window).
    v2_motion_x=0;v2_motion_y=0;v2_motion_from_x=0;v2_motion_from_y=0;v2_motion_to_x=0;v2_motion_to_y=0;
    v2_motion_elapsed=0;v2_motion_duration=0;v2_motion_easing="linear";v2_motion_boundary="inherit";
    v2_motion_base_x=0;v2_motion_base_y=0;v2_motion_actor=actor;
    updateWindowSurface=1;
    scr_SelectWindow(id);scr_v3_raise_top(id);
}
return win;
