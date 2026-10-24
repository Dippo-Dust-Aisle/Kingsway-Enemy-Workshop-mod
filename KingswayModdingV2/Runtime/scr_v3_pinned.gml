// True while a window is pinned above normal windows: Always on top, or Timer
// on Top when its 3-second countdown is not running.
var win=argument0;
if(!variable_instance_exists(win,"v3_layer"))return 0;
if(win.v3_layer=="top")return 1;
return win.v3_layer=="timer" && win.v3_timer_end<=0;
