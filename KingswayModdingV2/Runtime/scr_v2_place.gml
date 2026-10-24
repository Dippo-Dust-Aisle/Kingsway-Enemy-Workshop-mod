var win=argument0;var mode=argument1;
var rw=max(0,global.resolutionW/global.gameScale-win.width);
var rh=max(0,global.resolutionH/global.gameScale-win.height-24);
var rx=(mode=="randomX" || mode=="randomXY");var ry=(mode=="randomY" || mode=="randomXY");
var px=argument2*rw;var py=argument3*rh;
repeat(48){
    if(rx)px=random(rw);if(ry)py=random(rh);
    var free=1;
    with(obj_BattleScreen){if(id!=win && px<x+width && px+win.width>x && py<y+height && py+win.height>y)free=0;}
    with(obj_TrapWindow){if(id!=win && px<x+width && px+win.width>x && py<y+height && py+win.height>y)free=0;}
    if(free || (!rx && !ry))break;
}
win.x=px;win.y=py;
