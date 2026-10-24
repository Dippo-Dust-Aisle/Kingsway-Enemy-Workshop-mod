// Draws a premultiplied trail snapshot at the given opacity (0-1) without
// darkening or thinning it: colour and alpha are both scaled by the opacity.
var image=argument0;var o=clamp(argument3,0,1);if(!surface_exists(image) || o<=0)return;
gpu_set_blendmode_ext(2,6);
draw_surface_ext(image,argument1,argument2,1,1,0,make_color_rgb(255*o,255*o,255*o),o);
gpu_set_blendmode(0);
