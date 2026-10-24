var win=argument0;
// Parked hazard windows (scr_v3_hazard_park) wait invisibly for reuse.
if(variable_instance_exists(win,"v3_parked") && win.v3_parked)return;
var actor=scr_v3_window_actor(win);
// Movement / Window "Delete" closes here, at the end of the frame, after the actor's Step.
if(scr_v3_delete_now(actor))return;
if(!variable_instance_exists(win,"v3_window") || !win.v3_window){
    if(!instance_exists(actor) || !variable_instance_exists(actor,"v3_cosmetic")){
        if(!variable_global_exists("v3_menu_trails") || !global.v3_menu_trails)return;
        win.v3_opacity=10;win.v3_layer="normal";win.v3_draggable=1;win.v3_trails=1;win.v3_actor=0;win.v3_pin_allowed=0;win.v3_style="";
    }else{
        win.v3_opacity=actor.v3_opacity;win.v3_layer=actor.v3_layer;win.v3_draggable=actor.v3_draggable;win.v3_trails=actor.v3_trails;win.v3_actor=1;win.v3_pin_allowed=(actor.v3_layer=="top" || actor.v3_layer=="timer");
        win.v3_style="";if(variable_instance_exists(actor,"v3_style"))win.v3_style=actor.v3_style;
    }
    win.v3_window=1;win.updateWindowSurface=1;win.v3_snapshot=-1;win.v3_trail_frame=0;win.v3_last_x=win.x;win.v3_last_y=win.y;win.v3_dragging=0;win.v3_saved_moveable=win.moveable;
    win.v3_timer_end=0;win.v3_timer_shown=-1;win.v3_lock_until=0;
    scr_v3_owner_reset();
    if(win.v3_opacity<10)global.v3_dim_count+=1;if(win.v3_layer=="behind")global.v3_behind_count+=1;
    if(win.v3_actor && !scr_v3_pinned(win))scr_v3_spawn_order(win);
}
if(instance_exists(actor) && variable_instance_exists(actor,"v3_portrait_until") && actor.v3_portrait_until>0 && global.v2_time>=actor.v3_portrait_until){actor.sprite_index=actor.v3_original_sprite;actor.v3_portrait_until=0;win.updateWindowSurface=1;}
// Native Step clamps a released window onto the screen before End Step runs,
// so remember where it was while still held; that is where it was dropped.
if(win.v3_dragging && win.moving){win.v3_drop_x=win.x;win.v3_drop_y=win.y;}
if(win.v3_dragging && !win.moving)scr_v3_drag_end(win);
// Movement is computed in the actor's Step, but the native window Step can run after
// it and pull an offscreen window back onto the screen (or the window may not have
// moved yet this frame). Re-apply this frame's logical position here, after every
// Step, so teleports (transition speed 0), Wrap jumps and offscreen positions show
// on the very frame they happen.
else if(win.v3_actor && variable_instance_exists(win,"v2_motion_x"))scr_v2_motion_render(win);
if(!scr_v3_can_drag(win))win.moving=0;
// Timer on Top: after its pin is clicked the window is unpinned for 3 seconds,
// counting 3, 2, 1 on the pin and in the title/taskbar ("Battle (3)"), then re-pins.
if(win.v3_timer_end>0){
    var left=ceil((win.v3_timer_end-current_time)/1000);
    if(left<=0){win.v3_timer_end=0;win.v3_timer_shown=-1;win.extraTitleText="";scr_v3_raise_top(win);playSound(global.sound_magic5);win.updateWindowSurface=1;}
    else if(win.v3_timer_shown!=left){win.v3_timer_shown=left;win.extraTitleText=" ("+string(left)+")";win.updateWindowSurface=1;}
}
if(win.v3_lock_until>0 && current_time>=win.v3_lock_until){win.v3_lock_until=0;win.updateWindowSurface=1;}
// Pinned windows stay above every normal window but below Start-menu windows and
// messages (scr_v3_layer_pass), menus, held items (-900) and the cursor (-998). Among pinned windows the most recently
// selected one is highest. Always behind stays below every window but above
// the desktop logo and desktop icons (normal windows use z <= -5).
if(scr_v3_pinned(win)){
    if(!variable_instance_exists(win,"v3_top_order"))scr_v3_raise_top(win);
    // Normally ordered by scr_v3_layer_pass this frame; a window pinned just now orders itself.
    if(!variable_instance_exists(win,"v3_pin_stamp") || win.v3_pin_stamp!=global.v3_frame){
        var rank=0;var mine=win.v3_top_order;
        with(obj_Window){if(id!=win && variable_instance_exists(id,"v3_top_order") && scr_v3_pinned(id) && v3_top_order<mine)rank+=1;}
        win.z=-500-min(rank,36)*5;win.depth=win.z;
    }
    if(!win.v3_pin_allowed){win.v3_pin_allowed=1;win.updateWindowSurface=1;}
}
if(win.v3_layer=="behind"){win.z=-2;win.depth=win.z;win.active=0;win.pressed=0;win.clicked=0;}
if(win.v3_layer!="behind" && mouse_check_button_pressed(mb_left) && global.hoverObject==win && scr_v3_on_icon(win,"pin")){
    if(win.v3_layer=="top"){
        // Always on top is locked in game: show the lock and say so.
        win.v3_lock_until=current_time+1500;
        newMessage("PIN IS LOCKED!",7777,0);
    }else if(win.v3_layer=="timer"){
        if(win.v3_timer_end<=0){win.v3_timer_end=current_time+3000;win.v3_timer_shown=-1;playSound(global.sound_dropKey);scr_SelectWindow(win);}
    }else{win.v3_layer="top";scr_v3_raise_top(win);}
    win.moving=0;win.updateWindowSurface=1;
}
if(instance_exists(actor) && variable_instance_exists(actor,"v3_cosmetic") && actor.v3_cosmetic){if(win.titleText!=actor.name){win.titleText=actor.name;win.updateWindowSurface=1;}}
