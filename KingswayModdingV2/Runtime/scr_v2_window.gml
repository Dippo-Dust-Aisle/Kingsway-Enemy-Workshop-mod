var win=argument0;if(!instance_exists(win))return;
var operation=argument1;
if(operation=="shake")win.shakeAmount=argument2;
if(operation=="minimize")scr_v2_window_minimize(win);
if(operation=="maximize"){
    if(win.minimized)scr_SelectWindow(win);
    if(!variable_instance_exists(win,"v2_restore_width") || win.v2_restore_width<0){win.v2_restore_width=win.width;win.v2_restore_height=win.height;win.v2_restore_x=win.x;win.v2_restore_y=win.y;}
    win.minimized=0;win.width=max(win.width,(global.resolutionW/global.gameScale)-32);win.height=max(win.height,(global.resolutionH/global.gameScale)-64);win.x=16;win.y=16;
}
if(operation=="restore"){
    if(win.minimized)scr_SelectWindow(win);
    if(variable_instance_exists(win,"v2_restore_width") && win.v2_restore_width>=0){win.width=win.v2_restore_width;win.height=win.v2_restore_height;win.x=win.v2_restore_x;win.y=win.v2_restore_y;win.v2_restore_width=-1;}
}
if(operation=="move" || operation=="clearMoveOffset"){
    // Legacy five-argument calls and manifests retain fixed normalized moves.
    var placement="fixed";if(argument_count>5)placement=argument5;
    var basis="absolute";var dx=0;var dy=0;var minX=-0.25;var maxX=0.25;var minY=-0.25;var maxY=0.25;var duration=0;var easing="linear";var boundary="inherit";
    if(argument_count>6){basis=argument6;dx=argument7;dy=argument8;minX=argument9;maxX=argument10;minY=argument11;maxY=argument12;duration=argument13;easing=argument14;boundary=argument15;}
    scr_v2_motion_move(win,placement,argument3,argument4,basis,dx,dy,minX,maxX,minY,maxY,duration,easing,boundary,operation=="clearMoveOffset");
}
win.updateWindowSurface=1;
