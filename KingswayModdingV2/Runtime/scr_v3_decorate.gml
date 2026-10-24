var win=argument0;if(!variable_instance_exists(win,"v3_window") || !win.v3_window || !surface_exists(win.windowSurface))return; // v3_window is 0 while a reused hazard window waits to be re-initialised
surface_set_target(win.windowSurface);
if(win.v3_style!="")scr_v3_cosmetic_frame(win);
if(win.v3_layer=="behind"){
    draw_set_alpha(.16);draw_set_color(global.darkGrey);
    for(var s=-win.height;s<win.width;s+=12)draw_line(max(0,s),max(0,-s),min(win.width,s+win.height),min(win.height,win.width-s));
    draw_set_alpha(1);
}
if(win.v3_actor){
    // Each icon sits on the window sprite's title-button box (frame 8), as native close/minimize do.
    var px=scr_v3_icon_x(win,"pin");
    if(px>=0)draw_sprite(win.sprite_index,8,px-3,0);
    var dx=scr_v3_icon_x(win,"drag");
    if(dx>=0)draw_sprite(win.sprite_index,8,dx-3,0);
    // Pinned windows replace the 1-pixel grey border: red for Always on top,
    // blue for Timer on Top (hidden while its countdown runs).
    if(scr_v3_pinned(win)){draw_set_color(make_color_rgb(207,57,57));if(win.v3_layer=="timer")draw_set_color(make_color_rgb(42,143,222));draw_rectangle(0,0,win.width-3,win.height-3,1);}
    if(px>=0){
        var icon=spr_v3_icon_pin;var alpha=.45;
        if(win.v3_layer=="top"){alpha=1;if(win.v3_lock_until>0)icon=spr_v3_icon_lock;}
        if(win.v3_layer=="timer"){alpha=1;icon=spr_v3_icon_pin_blue;if(win.v3_timer_end>0){icon=spr_v3_icon_count3;if(win.v3_timer_shown==2)icon=spr_v3_icon_count2;if(win.v3_timer_shown==1)icon=spr_v3_icon_count1;}}
        icon=scr_v3_themed(icon);draw_sprite_ext(icon,0,px+sprite_get_xoffset(icon),3+sprite_get_yoffset(icon),1,1,0,c_white,alpha);
    }
    if(dx>=0){var dragIcon=scr_v3_themed(spr_v3_icon_drag);draw_sprite(dragIcon,0,dx+sprite_get_xoffset(dragIcon),3+sprite_get_yoffset(dragIcon));}
}
surface_reset_target();
