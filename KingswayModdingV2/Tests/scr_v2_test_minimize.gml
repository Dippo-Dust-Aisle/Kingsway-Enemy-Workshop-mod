if(!variable_global_exists("v2_min_case")){
    global.v2_min_case=0;global.v2_min_frame=0;
    // A first-frame action may run before the new window's own Begin Step.
    repeat(2){
        var probe=instance_create_depth(0,0,0,obj_v2_verification_min_custom);
        if(global.v2_min_case==1){with(probe)instance_destroy();probe=instance_create_depth(0,0,0,obj_v2_verification_min_native);}
        with(probe)event_perform(ev_step,ev_step_begin);
        var probeWindow=probe.screen;scr_v2_window(probeWindow,"minimize",0,0,0);
        scr_v2_test_assert(probeWindow.init && probeWindow.thisInit && probeWindow.minimized,"First-frame minimize completes creation without reopening the window: "+string(global.v2_min_case));
        if(global.v2_min_case==0)scr_v2_test_assert(probe.v2_move_started,"First-frame minimize establishes custom path before capturing restore position");
        else scr_v2_test_assert(instance_exists(probeWindow.v2_path_driver) && probeWindow.v2_path_driver.path_speed==0,"First-frame minimize preserves and freezes the native driver");
        with(probe)instance_destroy();global.v2_min_case+=1;
    }
    global.v2_min_case=0;
    with(obj_Enemy)instance_destroy();with(obj_Trap_Base)instance_destroy();scr_v2_tick();
    var file=file_text_open_write("v2-minimize-samples.jsonl");file_text_close(file);
}
if(global.v2_min_frame==0){
    var created=scr_v2_test_minimize_create(global.v2_min_case);if(!instance_exists(created))return 1;
    global.v2_min_actor=created;created.attackSpeed=0;created.attackReady=5;created.v2_activation=1000;
    created.v2_periodic_script=scr_v2_test_minimize_empty;created.v2_components_script=scr_v2_test_minimize_empty;
    with(created)event_perform(ev_step,ev_step_begin);
    with(created.screen)event_perform(ev_step,ev_step_begin);
    created.stunAmount=0;created.coldAmount=0;created.poisonAmount=0;created.burnAmount=0;
    scr_v2_move(created);
    var otherActor=instance_create_depth(0,0,0,obj_v2_verification_min_new);otherActor.attackSpeed=0;otherActor.attackReady=5;with(otherActor)event_perform(ev_step,ev_step_begin);with(otherActor.screen)event_perform(ev_step,ev_step_begin);
    global.v2_min_other=otherActor;global.v2_min_monotonic=1;global.v2_min_phase_stable=1;
    scr_v2_test_log("MINIMIZE CASE: "+created.v2_min_test_label);
}
var frame=global.v2_min_frame;var actor=global.v2_min_actor;var win=actor.screen;var mode=actor.v2_min_test_mode;
if(frame==8){
    if(mode=="continue")actor.v2_pause_minimized=0;
    if(mode=="absolute" || mode=="hiddenMove")scr_v2_window(win,"move",0,.3,.3);
    if(mode=="relative")scr_v2_window(win,"move",0,0,0,"fixed","relative",.05,.1,0,0,0,0,0,"linear","clamp");
    if(mode=="smooth" || mode=="continue")scr_v2_window(win,"move",0,0,0,"fixed","relative",0,.2,0,0,0,0,2,"ease","clamp");
}
if(frame==20){
    global.v2_min_before=scr_v2_test_minimize_sample(actor,frame);global.v2_min_last_y=win.y;
    screen_save("v2-minimize-"+string(global.v2_min_case)+"-before.png");
    if(mode=="button"){var button=win.minButton;if(!instance_exists(button)){button=instance_create_depth(win.x,win.y+3,win.depth-1,obj_MinimizeButton);button.window=win;win.minButton=button;}button.clicked=1;with(button)event_perform(ev_step,ev_step_normal);button.clicked=0;}
    else script_execute(actor.v2_min_test_script,actor,global.player,win);
    scr_v2_test_assert(win.minimized && !global.v2_min_other.screen.minimized,"Minimize targets only its own window: "+actor.v2_min_test_label);
}
if(frame>20 && frame<=60){
    var before=global.v2_min_before;
    if(win.y<global.v2_min_last_y-1)global.v2_min_monotonic=0;global.v2_min_last_y=win.y;
    if(actor.v2_move_time!=ds_map_find_value(before,"time") || actor.v2_move_segment!=ds_map_find_value(before,"segment") || actor.v2_move_direction!=ds_map_find_value(before,"direction") || actor.v2_move_wait!=ds_map_find_value(before,"wait"))global.v2_min_phase_stable=0;
    if(variable_instance_exists(win,"v2_path_driver") && instance_exists(win.v2_path_driver)){
        if(win.v2_path_driver.path_position!=ds_map_find_value(before,"phase") || win.v2_path_driver.x!=ds_map_find_value(before,"pathX") || win.v2_path_driver.y!=ds_map_find_value(before,"pathY"))global.v2_min_phase_stable=0;
    }
    if(frame==22)screen_save("v2-minimize-"+string(global.v2_min_case)+"-during.png");
    if(frame==24){scr_v2_test_assert(win.y>ds_map_find_value(before,"y")+100,"Native minimize advances visibly over four frames: "+actor.v2_min_test_label);}
    if(frame==32){var savedY=win.minimizedPos;var currentY=win.y;scr_v2_window(win,"minimize",0,0,0);scr_v2_test_assert(win.y==currentY && win.minimizedPos==savedY,"Repeated minimize does not recapture animated position: "+actor.v2_min_test_label);}
    if(frame==45 && mode=="hiddenMove")scr_v2_window(win,"move",0,0,0,"fixed","relative",0,.1,0,0,0,0,0,"linear","clamp");
}
if(frame==60){
    var before=global.v2_min_before;
    scr_v2_test_assert(win.minimized && win.y>=__view_get(3,0)*2 && global.v2_min_monotonic,"Window completes native offscreen transition and stays minimized: "+actor.v2_min_test_label);
    if(mode=="continue")scr_v2_test_assert(!global.v2_min_phase_stable && win.v2_motion_elapsed>ds_map_find_value(before,"elapsed"),"Disabling Pause minimized advances only logical path and transition state: "+actor.v2_min_test_label);
    else scr_v2_test_assert(global.v2_min_phase_stable,"Minimization preserves path phase, direction, wait and driver anchor: "+actor.v2_min_test_label);
    scr_v2_test_assert(win.width==ds_map_find_value(before,"width") && win.height==ds_map_find_value(before,"height"),"Native minimize preserves surface dimensions while sliding: "+actor.v2_min_test_label);
    if(mode=="smooth")scr_v2_test_assert(win.v2_motion_elapsed==ds_map_find_value(before,"elapsed") && win.v2_motion_y==ds_map_find_value(before,"offsetY"),"Minimize pauses the active smooth offset without corrupting it: "+actor.v2_min_test_label);
    screen_save("v2-minimize-"+string(global.v2_min_case)+"-minimized.png");
    var sample=scr_v2_test_minimize_sample(actor,frame);ds_map_destroy(sample);
    var expectedX=ds_map_find_value(before,"x");var logicalY=ds_map_find_value(before,"y");
    if(mode=="continue"){expectedX=scr_v2_motion_bound(win.v2_motion_base_x+win.v2_motion_x,scr_v2_motion_policy(win))*max(0,global.resolutionW/global.gameScale-win.width);logicalY=scr_v2_motion_bound(win.v2_motion_base_y+win.v2_motion_y,scr_v2_motion_policy(win))*max(0,global.resolutionH/global.gameScale-win.height-24);}
    if((global.v2_min_case mod 2)==0)scr_v2_window(win,"restore",0,0,0);else scr_SelectWindow(win);
    var expectedY=logicalY;if(mode=="hiddenMove")expectedY+=.1*max(0,global.resolutionH/global.gameScale-win.height-24);
    // Both action and native taskbar selection restore the logical origin immediately.
    scr_v2_test_assert(!win.minimized && abs(win.y-expectedY)<1.1 && abs(win.x-expectedX)<1.1,"Restore returns to the correct logical position without a jump: "+actor.v2_min_test_label);
}
if(frame==61)screen_save("v2-minimize-"+string(global.v2_min_case)+"-restored.png");
if(frame==66){
    var before=global.v2_min_before;
    if(ds_list_size(actor.v2_points)>=16)scr_v2_test_assert(actor.v2_move_time!=ds_map_find_value(before,"time") || actor.v2_move_segment!=ds_map_find_value(before,"segment"),"Custom path resumes from its retained phase: "+actor.v2_min_test_label);
    if(variable_instance_exists(win,"v2_path_driver") && instance_exists(win.v2_path_driver))scr_v2_test_assert(win.v2_path_driver.path_position!=ds_map_find_value(before,"phase") && abs(win.v2_path_driver.path_speed)>0,"Native path resumes on the existing driver: "+actor.v2_min_test_label);
    if(mode=="smooth")scr_v2_test_assert(win.v2_motion_elapsed>ds_map_find_value(before,"elapsed"),"Smooth offset resumes after restoration: "+actor.v2_min_test_label);
}
if(frame==70){
    var oldWidth=win.width;var oldHeight=win.height;scr_v2_window(win,"maximize",0,0,0);
    scr_v2_test_assert(!win.minimized && win.width>=global.resolutionW/global.gameScale-32 && win.height>=global.resolutionH/global.gameScale-64,"Maximize still expands the restored window: "+actor.v2_min_test_label);
    scr_v2_window(win,"restore",0,0,0);scr_v2_test_assert(win.width==oldWidth && win.height==oldHeight,"Restore retains pre-maximize dimensions: "+actor.v2_min_test_label);
    scr_v2_window(win,"shake",6,0,0);scr_v2_test_assert(win.shakeAmount==6,"Shake remains available after restore: "+actor.v2_min_test_label);
}
var sample=scr_v2_test_minimize_sample(actor,frame);ds_map_destroy(sample);
if(frame==75){
    var driver=noone;if(variable_instance_exists(win,"v2_path_driver"))driver=win.v2_path_driver;
    var toggles=actor.v2_toggles;var label=actor.v2_min_test_label;scr_v2_window(win,"minimize",0,0,0);with(actor)instance_destroy();with(global.v2_min_other)instance_destroy();scr_v2_tick();
    scr_v2_test_assert(!instance_exists(driver) && !instance_exists(win) && !ds_exists(toggles,ds_type_map),"Destroying minimized actor releases window, driver and state: "+label);
    ds_map_destroy(global.v2_min_before);global.v2_min_case+=1;global.v2_min_frame=0;return 0;
}
global.v2_min_frame+=1;return 0;
