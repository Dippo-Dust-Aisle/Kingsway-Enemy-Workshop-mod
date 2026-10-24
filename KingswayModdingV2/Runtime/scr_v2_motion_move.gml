// win, placement, x, y, basis, dx, dy, minX, maxX, minY, maxY,
// duration, easing, boundary, clearOffset
var win=argument0;scr_v2_motion_init(win);
var actor=win.v2_motion_actor;
if(instance_exists(actor) && variable_instance_exists(actor,"v2_enabled")){
    // A first-frame periodic move may run before the battle window Begin Step.
    // Establish the native path anchor before calculating an action offset.
    if(actor.v2_path!=-4 && !actor.v2_hazard && variable_instance_exists(win,"thisInit") && !win.thisInit){with(win)event_perform(ev_step,ev_step_begin);}
    if(!actor.v2_move_started && ds_list_size(actor.v2_points)>=16)scr_v2_move(actor);
}
var rw=max(0,global.resolutionW/global.gameScale-win.width);var rh=max(0,global.resolutionH/global.gameScale-win.height-24);
var cx=win.x/max(1,rw);var cy=win.y/max(1,rh);
if(win.minimized){var currentPolicy=scr_v2_motion_policy(win);cx=scr_v2_motion_bound(win.v2_motion_base_x+win.v2_motion_x,currentPolicy);cy=scr_v2_motion_bound(win.v2_motion_base_y+win.v2_motion_y,currentPolicy);}
var mode=argument1;var relative=argument4=="relative";
var rx=mode=="randomX" || mode=="randomXY";var ry=mode=="randomY" || mode=="randomXY";
var px=argument2;var py=argument3;
if(relative){px=cx+argument5;py=cy+argument6;}
if(rx && !ry)py=cy;if(ry && !rx)px=cx;
// Use the visible starting point, including previous boundary correction, when
// retargeting. Do not carry an invisible overshoot into the next relative move.
win.v2_motion_x=cx-win.v2_motion_base_x;win.v2_motion_y=cy-win.v2_motion_base_y;
win.v2_motion_boundary=argument13;var policy=scr_v2_motion_policy(win);
repeat(48){
    if(rx)px=relative?cx+random_range(argument7,argument8):random(1);
    if(ry)py=relative?cy+random_range(argument9,argument10):random(1);
    var free=1;var xx=scr_v2_motion_bound(px,policy)*rw;var yy=scr_v2_motion_bound(py,policy)*rh;
    with(obj_BattleScreen){if(id!=win && xx<x+width && xx+win.width>x && yy<y+height && yy+win.height>y)free=0;}
    with(obj_TrapWindow){if(id!=win && xx<x+width && xx+win.width>x && yy<y+height && yy+win.height>y)free=0;}
    if(free || (!rx && !ry))break;
}
win.v2_motion_from_x=win.v2_motion_x;win.v2_motion_from_y=win.v2_motion_y;
win.v2_motion_to_x=px-win.v2_motion_base_x;win.v2_motion_to_y=py-win.v2_motion_base_y;
if(argument14){win.v2_motion_to_x=0;win.v2_motion_to_y=0;}
win.v2_motion_duration=argument11;win.v2_motion_elapsed=0;win.v2_motion_easing=argument12;win.v2_motion_boundary=argument13;
if(win.v2_motion_duration<=0){win.v2_motion_x=win.v2_motion_to_x;win.v2_motion_y=win.v2_motion_to_y;}
scr_v2_motion_render(win);
