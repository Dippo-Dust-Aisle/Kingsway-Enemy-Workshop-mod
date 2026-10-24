var actor=argument0;if(scr_v3_delete_now(actor))return;
if(actor.currentHealth<=0){with(actor)instance_destroy();return;}
if(actor.v2_expired){if(actor.v2_pending==0){with(actor)instance_destroy();}return;}
if(!instance_exists(actor.screen))return;
if(global.gameSpeed<=0){if(variable_instance_exists(actor.screen,"v2_path_driver") && instance_exists(actor.screen.v2_path_driver))actor.screen.v2_path_driver.path_speed=0;return;}
var win=actor.screen;
if(variable_instance_exists(win,"v2_owned_path")){win.path_speed=actor.v2_path_speed*0.8*global.setting_enemyMoveSpeed/max(0.001,global.player.quickness);if(actor.coldAmount>0)win.path_speed*=0.5;if(actor.stunAmount>0||win.minimized)win.path_speed=0;}
if(scr_v3_drag_busy(actor))win.path_speed=0;
if(variable_instance_exists(win,"v2_path_driver") && instance_exists(win.v2_path_driver))win.v2_path_driver.path_speed=win.path_speed;
scr_v2_move(actor);
actor.v2_elapsed+=delta_time/1000000;
win.progressBar.target=actor.v2_activation;win.progressBar.progress=actor.v2_elapsed;
if(instance_exists(win.button))win.button.name=string_upper(actor.v3_button_text);
script_execute(actor.v2_periodic_script,actor,global.player,win);
if(actor.v2_elapsed>=actor.v2_activation){
    actor.v2_expired=1;
    script_execute(actor.v2_attack_script,actor,global.player,win);
    scr_v3_hazard_park(win);actor.screen=-4;
    scr_v3_gone(actor);
}
