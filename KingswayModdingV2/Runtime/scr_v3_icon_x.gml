// Window-relative left edge of a title-bar icon ("pin" or "drag"), or -1.
// Icons sit at the far right where close/minimize would be, left of any
// native title buttons that this window actually has. Pin is rightmost.
var win=argument0;var which=argument1;
if(!variable_instance_exists(win,"v3_actor") || !win.v3_actor || win.v3_layer=="behind")return -1;
var showPin=win.v3_pin_allowed;var showDrag=win.v3_draggable;
var count=0;
if(instance_exists(win.closeButton))count+=1;
if(instance_exists(win.minButton))count+=1;
if(instance_exists(win.infoButton))count+=1;
var base=win.width-16;
if(count>0)base=win.width-win.sprite_width+2-(count-1)*(win.sprite_width-2)-16;
if(which=="pin"){if(showPin)return base;return -1;}
if(!showDrag)return -1;
if(showPin)return base-16;
return base;
