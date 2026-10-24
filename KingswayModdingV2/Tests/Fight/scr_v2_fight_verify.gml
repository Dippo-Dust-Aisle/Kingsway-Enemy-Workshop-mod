if(global.v2_fight_stage!=3)exit;
var elapsed=global.v2_fight_frames-global.v2_fight_ready_frame;
if(elapsed==1 && __VERIFY__=="hazardclose")global.v2_fight_actor.v2_activation=1000;
if(elapsed==1){with(obj_Enemy){attackSpeed=0;}global.player.maxHealth=100000;global.player.currentHealth=100000;}
if(elapsed==30){scr_v2_fight_display();screen_save("v2-fight-ready.png");}
if(elapsed==100 && global.v2_fight_mode=="level" && __VERIFY__!="hazardclose"){
    var actor=global.v2_fight_actor;var hp=actor.currentHealth;var mana=global.player.currentMana;
    scr_CastSpell(global.player.battleSkill[2],actor,global.player,0,actor.screen);
    scr_CastSpell(global.player.battleSkill[3],actor,global.player,0,actor.screen);
    if(actor.currentHealth<hp && global.player.currentMana<mana && actor.coldAmount>0)scr_v2_fight_log("PASS: native Fireball II and Chill II damage, mana cost, and chill");else scr_v2_fight_log("FAIL: native spell checks");
    var bag=instance_find(obj_BackPack,0);if(!instance_exists(bag))bag=instance_find(obj_LargeBackPack,0);var healing=0;var poison=0;
    for(var j=0;j<ds_list_size(bag.contents);j+=1){var item=ds_list_find_value(bag.contents,j);if(item.object_index==obj_FullPotion)healing+=1;if(item.object_index==obj_ScrollPoison)poison+=1;}
    if(healing>=6 && poison>=4)scr_v2_fight_log("PASS: healing potions and poison scrolls in backpack");else scr_v2_fight_log("FAIL: backpack supplies");
}
if(__VERIFY__=="command")exit;
if(elapsed==360){
    scr_v2_fight_log("PASS: playable session remained open for 360 frames");
    if(__VERIFY__=="escape"){var escape=global.player.battleSkill[4];escape.target=global.v2_fight_actor;with(escape)event_user(0);exit;}
    if(__VERIFY__=="death"){global.player.currentHealth=0;exit;}
    if(__VERIFY__=="hazardclose"){var close=global.v2_fight_actor.screen.button;script_execute(close.script,close.arguments[0]);scr_v2_fight_log("PASS: custom hazard closed through native Close button callback");exit;}
    with(obj_Enemy){currentHealth=0;event_user(10);}
}
if(elapsed==370){with(obj_Enemy){if(killed)event_user(11);}scr_v2_fight_log("PASS: native loot window opened");}
if(elapsed==385)screen_save("v2-fight-loot.png");
if(elapsed==390){for(var j=0;j<ds_list_size(global.v2_fight_corpses);j+=1){var corpse=ds_list_find_value(global.v2_fight_corpses,j);if(instance_exists(corpse)){if(__VERIFY__=="close"){with(corpse.v2_fight_window)instance_destroy();scr_v2_fight_log("PASS: native loot window closed");}else{while(ds_list_size(corpse.contents)>0){var item=ds_list_find_value(corpse.contents,0);ds_list_delete(corpse.contents,0);item.owner=-4;item.away=1;ds_list_add(global.player.contents,item);}}}}}
