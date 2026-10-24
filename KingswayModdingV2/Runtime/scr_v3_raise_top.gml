// Makes a pinned (Always on top) window the highest of the pinned windows.
var win=argument0;if(!instance_exists(win))return;
if(!variable_global_exists("v3_top_seq"))global.v3_top_seq=0;
global.v3_top_seq+=1;win.v3_top_order=global.v3_top_seq;
