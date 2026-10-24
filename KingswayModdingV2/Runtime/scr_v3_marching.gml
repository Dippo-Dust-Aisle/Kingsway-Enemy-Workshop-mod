// Black "marching ants" over the 1-pixel window border of draggable actor
// windows. One rectangle per dash; about 90 per window at 254 x 264.
var win=argument0;
if(!variable_instance_exists(win,"v3_actor") || !win.v3_actor || win.minimized || !scr_v3_can_drag(win))return;
var w=win.width-3;var h=win.height-3;var x0=win.x+win.shake;var y0=win.y;
var t=(current_time div 90) mod 12;
draw_set_color(global.black);draw_set_alpha(scr_v3_opacity(win));
// Clockwise perimeter: top (left to right), right (down), bottom (right to left), left (up).
for(var edge=0;edge<4;edge+=1){
    var len=w;var start=0;
    if(edge==1){len=h;start=w;}
    if(edge==2){len=w;start=w+h;}
    if(edge==3){len=h;start=w+w+h;}
    for(var a=((t-start) mod 12+12) mod 12-12;a<len;a+=12){
        var s=max(0,a);var e=min(len,a+6);if(e<=s)continue;
        if(edge==0)draw_rectangle(x0+s,y0,x0+e-1,y0,0);
        if(edge==1)draw_rectangle(x0+w,y0+s,x0+w,y0+e-1,0);
        if(edge==2)draw_rectangle(x0+w-e+1,y0+h,x0+w-s,y0+h,0);
        if(edge==3)draw_rectangle(x0,y0+h-e+1,x0,y0+h-s,0);
    }
}
draw_set_alpha(1);
