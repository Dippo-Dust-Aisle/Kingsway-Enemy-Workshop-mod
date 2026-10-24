if(variable_global_exists("v3_composing") && global.v3_composing)return 1;
var win=scr_v3_owned_window(argument0);if(!instance_exists(win))return 1;
return clamp(win.v3_opacity,0,10)/10;
