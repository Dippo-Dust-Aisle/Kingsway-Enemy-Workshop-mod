// Window stacking, once per frame, only while some window is pinned (otherwise
// the vanilla order is untouched). Like Windows "always on top":
//  - unpinned windows keep the native click order (last clicked on top);
//  - pinned windows sit above them (scr_v3_window_step; last clicked pinned on top);
//  - Start-menu windows and messages that were clicked/opened after every other
//    unpinned window rise above the pinned ones. Clicking any other unpinned
//    window afterwards drops them back into the normal order.
// Bands: normal z > -500, pinned -500..-680, raised system windows -700..-890,
// menus/held items -900, cursor -998.
if(!variable_global_exists("v3_frame"))return;
if(variable_global_exists("v3_layer_stamp") && global.v3_layer_stamp==global.v3_frame)return;
global.v3_layer_stamp=global.v3_frame;
// Pinned windows, ordered once here (last clicked on top) instead of each pinned
// window scanning every window itself.
var order=ds_priority_create();
with(obj_Window){if(scr_v3_pinned(id) && variable_instance_exists(id,"v3_top_order"))ds_priority_add(order,id,v3_top_order);}
var pinned=ds_priority_size(order);var rank=0;
while(!ds_priority_empty(order)){var p=ds_priority_delete_min(order);p.z=-500-min(rank,36)*5;p.depth=p.z;p.v3_pin_stamp=global.v3_frame;rank+=1;}
ds_priority_destroy(order);
if(!pinned || !instance_exists(obj_DesktopControler))return;
var list=obj_DesktopControler.windows;
// The trailing run of system windows at the top of the unpinned click order.
var first=ds_list_size(list);
for(var i=ds_list_size(list)-1;i>=0;i-=1){
    var w=list[|i];if(!instance_exists(w) || scr_v3_pinned(w))continue;
    if(!scr_v3_system_window(w))break;
    first=i;
}
var k=0;
for(var i=first;i<ds_list_size(list);i+=1){
    var w=list[|i];if(!instance_exists(w) || scr_v3_pinned(w) || w.minimized)continue;
    w.z=-700-min(k,38)*5;w.depth=w.z;k+=1;
}
