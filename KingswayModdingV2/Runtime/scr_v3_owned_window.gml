// The v3 window an instance belongs to (itself, or via window/owner/screen links),
// or noone. Every wrapped Draw event and alpha call asks this, so the answer is
// cached per instance for 250 ms; a new v3 window invalidates all caches at once.
var node=argument0;if(!instance_exists(node))return noone;
if(variable_instance_exists(node,"v3_owner_at") && node.v3_owner_epoch==global.v3_owner_epoch && current_time<node.v3_owner_at){
    var cached=node.v3_owner;if(cached==noone || instance_exists(cached))return cached;
}
var start=node;var found=noone;
repeat(5){
    if(!instance_exists(node))break;
    if(variable_instance_exists(node,"v3_window") && node.v3_window){found=node;break;}
    var next=noone;
    if(variable_instance_exists(node,"window") && instance_exists(node.window))next=node.window;
    else if(variable_instance_exists(node,"owner") && instance_exists(node.owner))next=node.owner;
    else if(variable_instance_exists(node,"screen") && instance_exists(node.screen))next=node.screen;
    if(next==node || next==noone)break;node=next;
}
if(!variable_global_exists("v3_owner_epoch"))global.v3_owner_epoch=0;
start.v3_owner=found;start.v3_owner_epoch=global.v3_owner_epoch;start.v3_owner_at=current_time+250;
return found;
