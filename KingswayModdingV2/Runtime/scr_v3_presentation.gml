var actor=argument0;var win=argument1;var mode=argument2;var amount=argument5;var operation=argument6;
if(!instance_exists(actor))return;
if(mode=="rename"){
    actor.name=argument3;actor.title="";
    if(variable_instance_exists(actor,"trapName"))actor.trapName=argument3;
    if(instance_exists(win)){win.titleText=argument3;win.extraTitleText="";if(variable_instance_exists(win,"enemyName"))win.enemyName=argument3;if(instance_exists(win.title))win.title.text=argument3;}
}
if(mode=="portrait"){actor.sprite_index=argument4;actor.v3_portrait_until=0;if(argument7>0)actor.v3_portrait_until=global.v2_time+argument7;}
if(mode=="restorePortrait"){actor.sprite_index=actor.v3_original_sprite;actor.v3_portrait_until=0;}
if(mode=="rotation")actor.v3_rotation=amount;
if(mode=="rotate")actor.v3_rotation=(actor.v3_rotation+amount) mod 360;
if(instance_exists(win)){
    scr_v3_window_step(win);
    // A Delete earlier in the same sequence closes the window (and actor) right here.
    if(!instance_exists(win) || !instance_exists(actor))return;
    if(mode=="opacity"){if(operation=="set")win.v3_opacity=amount;else if(operation=="add")win.v3_opacity+=amount;else win.v3_opacity-=amount;win.v3_opacity=clamp(win.v3_opacity,0,10);if(win.v3_opacity<10)global.v3_dim_count+=1;}
    if(mode=="layer"){var before=win.v3_layer;win.v3_layer=argument8;if(win.v3_layer=="behind")global.v3_behind_count+=1;win.v3_timer_end=0;win.v3_timer_shown=-1;win.extraTitleText="";if(win.v3_layer=="top" || win.v3_layer=="timer"){win.v3_pin_allowed=1;if(before!=win.v3_layer)scr_v3_raise_top(win);}if(win.v3_layer=="normal" && before!="normal")scr_SelectWindow(win);}
    win.updateWindowSurface=1;win.refreshSurface=1;
}
