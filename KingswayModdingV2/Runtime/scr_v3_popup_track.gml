// Status popups ("POISONED!" and similar) are native message windows created
// with message ID 0, so every application opens another one. Keep the newest
// 20; the 21st closes the oldest. Other message windows are never touched.
var win=argument0;if(!instance_exists(win))return;
var tracked=variable_global_exists("v3_in_status") && global.v3_in_status>0;
if(!tracked){var text=string_upper(string(win.message));tracked=text=="POISONED!" || text=="CHILLED!" || text=="BURNED!" || text=="STUNNED!" || text=="CURSED!" || text=="FROZEN!";}
if(!tracked)return;
if(!variable_global_exists("v3_popups"))global.v3_popups=ds_list_create();
var list=global.v3_popups;
for(var i=ds_list_size(list)-1;i>=0;i-=1)if(!instance_exists(list[|i]))ds_list_delete(list,i);
if(ds_list_find_index(list,win)<0)ds_list_add(list,win);
while(ds_list_size(list)>20){var old=list[|0];ds_list_delete(list,0);if(instance_exists(old))with(old)instance_destroy();}
