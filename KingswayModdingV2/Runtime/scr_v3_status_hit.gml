var target=argument0;var amount=argument1;var family=argument2;if(family=="fire")family="burn";
if(amount<=0 || (family!="poison" && family!="burn"))return;
var field="v2_"+family+"_icon";if(!variable_instance_exists(target,field))return;
var win=noone;if(variable_instance_exists(target,"screen") && instance_exists(target.screen))win=target.screen;
if(target==global.player){with(obj_BattleScreen){if(!battleOver)win=id;}}
if(!instance_exists(win))return;
var hit=instance_create_depth(win.x,win.y,win.depth-20,obj_v3_status_hit);hit.window=win;hit.amount=amount;hit.icon=variable_instance_get(target,field);
if(hit.icon<0){hit.icon=spr_StatusEffectIcons;hit.iconFrame=4;if(family=="burn")hit.iconFrame=20;}
