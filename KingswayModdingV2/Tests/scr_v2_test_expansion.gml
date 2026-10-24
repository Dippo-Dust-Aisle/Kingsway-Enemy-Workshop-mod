if(global.v2_expand_stage==0){
    with(obj_DemonBossSpawner)instance_destroy();with(obj_Enemy)instance_destroy();with(obj_Trap_Base)instance_destroy();
    global.player.currentHealth=100000;global.player.maxHealth=100000;global.player.poisonAmount=0;global.player.burnAmount=0;
    var actor=instance_create_depth(0,0,0,obj_v2_verification_self);with(actor)event_perform(ev_step,ev_step_begin);
    scr_v2_music_tick();scr_v2_test_assert(audio_is_playing(ds_map_find_value(global.v2_audio,"verification:probe_sound")),"Embedded PCM WAV spawn sound is playing through native audio resources");scr_v2_test_assert(global.v2_music_stream!=-1 && audio_is_playing(global.v2_music_stream),"Preconverted WAV music plays through the native OGG stream loader");
    actor.maxHealth=100;actor.currentHealth=100;actor.attackSpeed=0;actor.defence=0;actor.minDamage=4;actor.maxDamage=4;actor.poisonAmount=6;
    script_execute(actor.v2_attack_script,actor,global.player,actor.screen);
    scr_v2_test_assert(actor.currentHealth==93 && actor.poisonAmount==2,"Attacker self-strike and direct physical damage target the source; status reduction is not healing");
    with(actor)script_execute(v2_loot_script);var item=actor.loot[|0];with(item)event_perform(ev_step,ev_step_begin);
    item.identified=1;with(item)event_perform(ev_step,ev_step_begin);
    scr_v2_test_assert(item.name=="The Test Blade","Per-drop custom name survives native random enchantment and identification");
    with(actor)instance_destroy();scr_v2_music_tick();scr_v2_test_assert(global.v2_music_stream==-1,"Encounter music stream is stopped and destroyed when encounter ends");
    var hazard=instance_create_depth(0,0,0,obj_v2_verification_hazard);with(hazard)event_perform(ev_step,ev_step_begin);var win=hazard.screen;
    scr_v2_test_assert(win.object_index==obj_TrapWindow && !variable_instance_exists(win,"skillButtons"),"Dedicated hazard window has no player attack controls");
    global.v2_closed_window=win;with(hazard)instance_destroy();scr_v2_test_assert(!instance_exists(win),"Closing a hazard destroys its owned window");
    global.v2_probe_max_frame=0;global.v2_probe_projectiles=ds_list_create();global.v2_probe_times=ds_list_create();
    global.v2_expand_hazard=instance_create_depth(0,0,0,obj_v2_verification_hazard);
    global.v2_expand_frame=global.v2_test_frames;global.v2_expand_started=current_time/1000;global.v2_expand_stage=1;
}
else if(global.v2_expand_stage==1 && global.v2_test_frames-global.v2_expand_frame>=30 && current_time/1000-global.v2_expand_started>1.7){
    scr_v2_test_assert(ds_list_size(global.v2_probe_times)==3,"One-shot hazard finishes three delayed fireballs after its window expires");
    if(ds_list_size(global.v2_probe_times)==3){scr_v2_test_log("TIMES: "+string(ds_list_find_value(global.v2_probe_times,0))+", "+string(ds_list_find_value(global.v2_probe_times,1))+", "+string(ds_list_find_value(global.v2_probe_times,2)));var times=global.v2_probe_times;var d1=times[|1]-times[|0];var d2=times[|2]-times[|1];scr_v2_test_assert(d1>=.24 && d1<=.25+global.v2_probe_max_frame+.01 && d2>=.24 && d2<=.25+global.v2_probe_max_frame+.01,"Fireball waits are 0.25 seconds within one measured frame, including startup stalls");}
    if(instance_exists(global.v2_expand_hazard))scr_v2_test_log("HAZARD pending="+string(global.v2_expand_hazard.v2_pending)+" expired="+string(global.v2_expand_hazard.v2_expired)+" sequences="+string(ds_list_size(global.v2_sequences)));
    scr_v2_test_assert(!instance_exists(global.v2_expand_hazard),"Expired hazard releases actor after delayed sequence; no corpse");
    with(obj_Trap_Base)instance_destroy();ds_list_clear(global.v2_probe_times);ds_list_clear(global.v2_probe_projectiles);
    var actor=instance_create_depth(0,0,0,obj_v2_verification_nine);with(actor)event_perform(ev_step,ev_step_begin);actor.attackSpeed=0;global.v2_expand_source=actor;
    script_execute(actor.v2_attack_script,actor,global.player,actor.screen);script_execute(actor.v2_attack_script,actor,global.player,actor.screen);
    global.v2_expand_frame=global.v2_test_frames;global.v2_expand_started=current_time/1000;global.v2_expand_stage=2;
}
else if(global.v2_expand_stage==2 && global.v2_test_frames-global.v2_expand_frame>=30 && current_time/1000-global.v2_expand_started>1.8){
    scr_v2_test_assert(ds_list_size(global.v2_probe_times)==54,"Two overlapping activations each spawn nine hazards with independent three-shot volleys");
    var actor=global.v2_expand_source;script_execute(actor.v2_attack_script,actor,global.player,actor.screen);actor.currentHealth=0;
    global.v2_expand_frame=global.v2_test_frames;global.v2_expand_started=current_time/1000;global.v2_expand_stage=3;
}
else if(global.v2_expand_stage==3 && global.v2_test_frames-global.v2_expand_frame>=30 && current_time/1000-global.v2_expand_started>1){
    scr_v2_test_assert(ds_list_size(global.v2_probe_times)==57,"Source death cancels remaining spawns while activated hazard sequence finishes");
    with(obj_DemonBossSpawner)instance_destroy();with(obj_Enemy)instance_destroy();with(obj_Trap_Base)instance_destroy();
    var objects=[obj_Trap_Fireball,obj_Trap_Arrow,obj_Trap_Boulder,obj_Trap_BlackFireball,obj_Trap_Curse,obj_Trap_Icicle,obj_Trap_PoisonDart,obj_Trap_MagicArrow,obj_Trap_ThrowingAxe,obj_Trap_Fireball2];
    for(var i=0;i<array_length_1d(objects);i+=1){var projectile=scr_v2_projectile(objects[i],0,"randomXY",.5,.5,0);with(projectile)event_perform(ev_step,ev_step_begin);scr_v2_test_assert(instance_exists(projectile.window),"Native hazard adapter initializes "+object_get_name(objects[i]));}
    var first=scr_v2_projectile(obj_Trap_BlackFireball,0,"randomXY",.5,.5,0);repeat(16)scr_v2_projectile(obj_Trap_BlackFireball,0,"randomXY",.5,.5,0);scr_v2_test_assert(instance_exists(first) && instance_number(obj_Trap_BlackFireball)==18,"Authored black fireballs preserve intentional duplicates");
    with(obj_Trap_Base){duration=1;timer=10;event_perform(ev_step,ev_step_end);}
    var v3_live=0;with(obj_TrapWindow){if(!(variable_instance_exists(id,"v3_parked") && v3_parked))v3_live+=1;}scr_v2_test_assert(v3_live==0,"All native projectile expiry adapters destroy owned windows (parked Workshop hazard windows excluded)");
    global.v2_expand_stage=4;global.v2_expand_frame=global.v2_test_frames;global.v2_expand_started=current_time/1000;
}
else if(global.v2_expand_stage==4 && global.v2_test_frames-global.v2_expand_frame>=30 && current_time/1000-global.v2_expand_started>.2){
    ds_list_clear(global.v2_probe_times);global.v2_probe_max_frame=0;global.v2_expand_hazard=instance_create_depth(0,0,0,obj_v2_verification_hazard);global.v2_expand_frame=global.v2_test_frames;global.v2_expand_started=current_time/1000;global.v2_expand_stage=5;
}
else if(global.v2_expand_stage==5 && global.v2_test_frames-global.v2_expand_frame>=30 && current_time/1000-global.v2_expand_started>1.5){
    var times=global.v2_probe_times;if(ds_list_size(times)==3){var d1=ds_list_find_value(times,1)-ds_list_find_value(times,0);var d2=ds_list_find_value(times,2)-ds_list_find_value(times,1);scr_v2_test_log("WARM VOLLEY: 0, "+string_format(d1,0,4)+", "+string_format(d1+d2,0,4)+" seconds; maximum frame "+string_format(global.v2_probe_max_frame,0,4));scr_v2_test_assert(d1>=.25 && d1<.25+global.v2_probe_max_frame+.005 && d2>=.25 && d2<.25+global.v2_probe_max_frame+.005,"Warmed three-fireball volley preserves quarter-second spacing");}else scr_v2_test_assert(false,"Warmed volley has three fireballs");
    scr_v2_test_boundaries();
    var branch=instance_create_depth(0,0,0,obj_v2_verification_branch);with(branch)event_perform(ev_step,ev_step_begin);branch.currentHealth=100;branch.maxHealth=100;branch.defence=0;branch.damageProtection=0;branch.protectionPercent=0;global.gameSpeed=.1;
    script_execute(branch.v2_attack_script,branch,global.player,branch.screen);
    var sequence=ds_list_find_value(global.v2_sequences,ds_list_size(global.v2_sequences)-1);
    scr_v2_test_log("BRANCH health="+string(branch.currentHealth)+" wake="+string(ds_map_find_value(sequence,"wake"))+" now="+string(global.v2_time)+" script="+string(ds_map_find_value(sequence,"script")));
    scr_v2_test_assert(branch.currentHealth==99 && abs(ds_map_find_value(sequence,"wake")-global.v2_time-.12)<.001,"Final nested branch wait carries through to the following action");
    var oldtime=global.v2_time;var oldspeed=global.gameSpeed;global.v2_time+=1;global.gameSpeed=0;scr_v2_sequence_run(sequence);
    scr_v2_test_assert(branch.currentHealth==99,"Paused game does not advance a ready action sequence");
    global.gameSpeed=oldspeed;scr_v2_sequence_run(sequence);global.v2_time=oldtime;
    scr_v2_test_assert(branch.currentHealth==97,"Resuming continues after branch delay without replaying its action");with(branch)instance_destroy();
    scr_v2_test_reactions();scr_v2_test_motion();global.v2_expand_stage=6;
}
else if(global.v2_expand_stage==6 && scr_v2_test_native_motion()){global.v2_expand_stage=7;}
else if(global.v2_expand_stage==7 && scr_v2_test_minimize())global.v2_expand_stage=8;
else if(global.v2_expand_stage==8 && scr_v3_test_windows()){screen_save("v2-expansion.png");scr_v2_test_log("RESULT: "+string(global.v2_test_assertions)+" assertions, "+string(global.v2_test_failures)+" failures");game_end();
}

