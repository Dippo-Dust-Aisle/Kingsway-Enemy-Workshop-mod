// "Show hazard indicator": the auto-close countdown as a bar that fills across the
// dark band at the bottom of the Canon / Alt frame, like a hazard's activation bar.
var win=argument0;var actor=argument1;
if(!instance_exists(actor) || !variable_instance_exists(actor,"v3_close_bar") || !actor.v3_close_bar || actor.v3_auto_close<=0 || win.minimized)return;
var n=actor.v3_portrait_size;var x0=win.x+8;var y0=win.y+21+n-6;var w=n;var h=5;
var t=clamp(actor.v3_alive/actor.v3_auto_close,0,1);
var a=scr_v3_opacity(win);
draw_set_alpha(a);draw_set_color(global.black);draw_rectangle(x0,y0,x0+w-1,y0+h-1,0);
draw_set_color(make_color_rgb(237,155,39));if(t>0)draw_rectangle(x0+1,y0+1,x0+1+max(0,round((w-3)*t)),y0+h-2,0);
draw_set_alpha(1);
