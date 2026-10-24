global.v2_fight_frames+=1;
if(global.v2_fight_display_room!=room){
    global.v2_fight_display_room=room;window_set_fullscreen(global.v2_fight_fullscreen);
    if(!global.v2_fight_fullscreen)window_set_rectangle(max(0,(display_get_width()-global.resolutionW)/2),max(0,(display_get_height()-global.resolutionH)/2),global.resolutionW,global.resolutionH);
    scr_SetCameraView();
}
if(global.v2_fight_stage<3 && global.v2_fight_frames>1800){scr_v2_fight_finish("startup failed");exit;}
// Advance as soon as each screen is ready instead of waiting fixed frame counts.
if(room==rm_PlayerCreate && global.v2_fight_stage==0 && instance_exists(obj_PlayerCreateWindow) && global.v2_fight_frames>5){
    obj_Profile.tutorial=0;ds_list_clear(obj_Profile.gifts);global.setting_leaderboard=0;
    with(obj_PlayerCreateWindow){hidden=0;nameBox.text="Enemy Tester";classDropDown._value=global.v2_fight_class;acceptButton.clicked=1;}
    global.v2_fight_stage=1;
}
if(room!=rm_Main || global.loading || !instance_exists(global.player))exit;
if(!variable_global_exists("v2_fight_main_frame"))global.v2_fight_main_frame=global.v2_fight_frames;
if(global.v2_fight_stage==1 && global.v2_fight_frames-global.v2_fight_main_frame>20){
    global.day=0;global.hour=12;obj_TheShadow.x=-100000;
    var gx=floor(obj_PlayerOverworld.x/global.currentWorld.mapTileWidth);var gy=floor((obj_PlayerOverworld.y+4)/global.currentWorld.mapTileWidth);
    ds_grid_set_region(global.currentWorld.grid,gx-1,gy-1,gx+1,gy+1,15000);ds_grid_clear(global.currentWorld.difficultyGrid,global.v2_fight_level);
    with(global.player){
        var skillLevelLimit=global.v2_fight_level;if(global.v2_fight_mode=="random")skillLevelLimit=25;
        for(var lvl=2;lvl<=skillLevelLimit;lvl+=1){level=lvl;scr_GetNewSkills();}
        level=global.v2_fight_level;XP=0;
        if(level>1)XP=levelXPs[level-2];
        var points=(level-1)*3;
        for(var n=0;n<points;n+=1){var stat=n mod 4;if(global.v2_fight_mode=="random")stat=irandom(3);switch(stat){case 0:strength+=1;break;case 1:vitality+=1;break;case 2:intelligence+=1;break;case 3:agility+=1;break;}}
        if(global.v2_fight_mode=="random"){
            var slots=["amulet","head","chest","weapon","offhand","feet","ring1","ring2"];
            var kinds=["Charm","Head","Chest","Weapon","Offhand","Feet","Ring","Ring"];
            for(var j=0;j<8;j+=1){var old=variable_instance_get(id,slots[j]);if(instance_exists(old)){ds_list_delete(contents,ds_list_find_index(contents,old));with(old)instance_destroy();}var item=scr_v2_fight_gear(kinds[j]);variable_instance_set(id,slots[j],item);}
        }
    }
    global.v2_fight_stage=2;global.v2_fight_next=global.v2_fight_frames+10;
}
else if(global.v2_fight_stage==2 && global.v2_fight_frames>=global.v2_fight_next){
    scr_v2_fight_skill(obj_Skill_Attack,0,0);scr_v2_fight_skill(obj_Skill_Block,1,0);scr_v2_fight_skill(obj_Skill_Escape,4,0);global.player.battleSkill[5]=-4;
    if(global.v2_fight_mode=="level"){scr_v2_fight_skill(obj_Skill_FireBall,2,1);scr_v2_fight_skill(obj_Skill_Chill,3,1);}
    else{
        var pool=ds_list_create();with(obj_BaseSkill){if(attackSpell && !passive && !equipSkill && object_index!=obj_Skill_Attack && object_index!=obj_Skill_Block && object_index!=obj_Skill_Escape)ds_list_add(pool,id);}
        scr_v2_fight_log("Class skill pool: "+string(ds_list_size(pool)));
        for(var slot=2;slot<=3;slot+=1){if(ds_list_size(pool)<1){scr_v2_fight_finish("Insufficient class battle skills");exit;}var pick=irandom(ds_list_size(pool)-1);var skill=ds_list_find_value(pool,pick);scr_v2_fight_log("Selecting "+skill.name);ds_list_delete(pool,pick);scr_v2_fight_skill(skill.object_index,slot,0);}ds_list_destroy(pool);
    }
    with(global.player){var slots=["amulet","head","chest","weapon","offhand","feet","ring1","ring2"];for(var j=0;j<8;j+=1){var item=variable_instance_get(id,slots[j]);if(instance_exists(item)){with(item)event_user(11);scr_v2_fight_log("GEAR "+slots[j]+": "+item.name);}}}
    // Supply the native backpack, visible from the desktop and B shortcut.
    var bag=instance_find(obj_BackPack,0);if(!instance_exists(bag))bag=instance_find(obj_LargeBackPack,0);if(!instance_exists(bag))bag=instance_create_depth(160,32,0,obj_LargeBackPack);
    bag.maxWeight=max(bag.maxWeight,100);bag.maxContents=max(bag.maxContents,32);
    repeat(6)ds_list_add(bag.contents,instance_create_depth(-9000,-9000,0,obj_FullPotion));
    repeat(4)ds_list_add(bag.contents,instance_create_depth(-9000,-9000,0,obj_FullPotionOfMana));
    repeat(4)ds_list_add(bag.contents,instance_create_depth(-9000,-9000,0,obj_ScrollPoison));
    scr_UpdatePlayerStats();global.player.currentHealth=global.player.maxHealth;global.player.currentMana=global.player.maxMana;
    global.v2_fight_actor=instance_create_depth(0,0,0,__ENEMY__);global.v2_fight_actor.level=global.v2_fight_level;
    scr_v2_fight_log("READY: "+global.v2_fight_mode+" / "+global.player.class+" / level "+string(global.player.level));
    // "Load random Vanilla Song": the music player only exists while its window is open,
    // so open it like the Start menu does; the track starts once it has initialized.
    if(global.v3_fight_random_music){var mf=instance_find(obj_MusicFile,0);if(instance_exists(mf)){global.v3_fight_music_window=scr_OpenWindowB(mf,obj_MusicPlayer);global.v3_fight_music_state=1;}else scr_v2_fight_log("MUSIC: no music file on the desktop");}
    global.v2_fight_stage=3;scr_v2_fight_display();global.v2_fight_ready_frame=global.v2_fight_frames;
}
else if(global.v2_fight_stage==3){
    // Play a random track once the player window has built its playlist, then minimize it.
    var mp=global.v3_fight_music_window;
    if(global.v3_fight_music_state==1 && instance_exists(mp) && mp.initialized && ds_list_size(mp.playlist)>0){
        with(mp){var song=ds_list_find_value(playlist,irandom(ds_list_size(playlist)-1));playlistBox.selected=ds_list_find_index(playlistBox.items,song);playlistBox.refresh=1;selectedSong=song;event_user(2);}
        scr_v2_fight_log("MUSIC: playing "+string(mp.currentSongObject.name));global.v3_fight_music_state=2;global.v3_fight_music_frame=global.v2_fight_frames;
    }
    else if(global.v3_fight_music_state==2 && global.v2_fight_frames>=global.v3_fight_music_frame+2){if(instance_exists(mp))scr_v2_window_minimize(mp);global.v3_fight_music_state=3;}
    if(global.v2_fight_frames==global.v2_fight_ready_frame+120)scr_v2_fight_log("STARTUP WINDOWS: quests="+string(instance_number(obj_QuestWindow))+" musicPlayer="+string(instance_number(obj_MusicPlayer))+" musicMinimized="+string(instance_exists(mp) && mp.minimized));
    if(global.player.currentHealth<=0)exit;
    if(global.v2_fight_looted || !instance_exists(global.v2_fight_actor)){
        var alive=0;with(obj_Enemy){if(currentHealth>0)alive+=1;}
        var pending=0;for(var j=0;j<ds_list_size(global.v2_fight_corpses);j+=1){var corpse=ds_list_find_value(global.v2_fight_corpses,j);if(instance_exists(corpse)){if(ds_list_size(corpse.contents)>0 && instance_exists(corpse.v2_fight_window))pending+=1;}}
        // Do not finish while another defeated enemy still has unopened loot.
        with(obj_Enemy){if(killed && instance_exists(screen) && instance_exists(screen.lootButton)){if(screen.lootButton.canPress)pending+=1;}}
        // A just-defeated enemy shows its Loot button only after its death presentation;
        // once something else was looted, finishing in that gap closed the test early.
        with(obj_Enemy){if(currentHealth<=0 && !escaped && instance_exists(screen) && screen.lootButton==-4){if(!variable_instance_exists(id,"v2_fight_dead_frame"))v2_fight_dead_frame=global.v2_fight_frames;if(global.v2_fight_frames-v2_fight_dead_frame<600)pending+=1;}}
        if(alive==0 && pending==0 && instance_number(obj_Trap_Base)==0 && ds_list_size(global.v2_sequences)==0){scr_v2_fight_finish("looted");exit;}
    }
}
