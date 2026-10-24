var actor=argument0;if(scr_v3_delete_now(actor))return;
// Auto-close: after this many seconds of game time the Cosmetic closes like a hazard.
if(!variable_instance_exists(actor,"v3_alive"))actor.v3_alive=0;
if(global.gameSpeed>0)actor.v3_alive+=delta_time/1000000;
if(variable_instance_exists(actor,"v3_auto_close") && actor.v3_auto_close>0 && actor.v3_alive>=actor.v3_auto_close)actor.v3_deleting=1;
var members=scr_v2_group(actor);
if(actor.escaped || scr_v3_group_alive(members)==0 || (actor.role=="limb" && (!instance_exists(actor.ownerHeadId) || actor.ownerHeadId.currentHealth<=0))){with(actor)instance_destroy();return;}
if(!instance_exists(actor.screen)){
    var win=instance_create_depth(0,0,0,obj_v3_cosmetic_window);actor.screen=win;win.owner=actor;win.enemy=actor;
    // Canon/Alt frame: 8 px left, 10 px right (shadow included), 21 px title, 7 px band.
    win.width=actor.v3_portrait_size+18;win.height=actor.v3_portrait_size+28;win.drawWindow=0;win.titleText=actor.name;
    scr_v3_place_start(win,actor);
    if(actor.v2_path!=-4){win.v2_owned_path=path_duplicate(actor.v2_path);path_rescale(win.v2_owned_path,max(1,global.resolutionW/global.gameScale-win.width)/386,max(1,global.resolutionH/global.gameScale-win.height-24)/192);scr_v2_native_path_start(win,win.v2_owned_path);}
}
if(!actor.v2_components_done){actor.v2_components_done=1;with(actor)script_execute(v2_components_script);}

var win=actor.screen;if(variable_instance_exists(win,"v2_path_driver") && instance_exists(win.v2_path_driver)){var driver=win.v2_path_driver;driver.path_speed=actor.v2_path_speed*.8;driver.path_speed*=global.setting_enemyMoveSpeed/max(.001,global.player.quickness);if(actor.coldAmount>0)driver.path_speed*=.5;if(global.gameSpeed<=0 || (actor.v2_pause_minimized && win.minimized) || (actor.v2_pause_stun && actor.stunAmount>0) || (actor.v3_active && actor.v3_action_mode=="detour") || scr_v3_drag_busy(actor))driver.path_speed=0;}
