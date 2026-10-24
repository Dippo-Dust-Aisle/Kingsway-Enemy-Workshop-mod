// A newly spawned enemy, hazard or Cosmetic window goes on top of every unpinned
// window except a Settings window the player opened most recently.
// Pinned spawns are ordered by scr_v3_raise_top instead.
var win=argument0;if(!instance_exists(obj_DesktopControler))return;
var list=obj_DesktopControler.windows;var at=ds_list_find_index(list,win);if(at<0)return;
ds_list_delete(list,at);
var slot=ds_list_size(list);
for(var i=ds_list_size(list)-1;i>=0;i-=1){
    var w=list[|i];if(!instance_exists(w) || scr_v3_pinned(w))continue;
    if(w.object_index!=obj_SettingsWindow)break;
    slot=i;
}
ds_list_insert(list,slot,win);
// Same z formula as native scr_SelectWindow.
with(obj_Window){var index=ds_list_find_index(obj_DesktopControler.windows,id)+1;if(index>0){if(active)z=-6-(index*5);else z=-index*5;}}
