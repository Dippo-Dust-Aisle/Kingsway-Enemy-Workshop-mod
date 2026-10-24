global.v2_test_frames+=1;
if(global.v2_test_frames>5000){scr_v2_test_log("FAIL: timeout in stage "+string(global.v2_test_stage));game_end();exit;}
if(room==rm_PlayerCreate && global.v2_test_stage==0 && global.v2_test_frames>30){
    obj_Profile.tutorial=0;ds_list_clear(obj_Profile.gifts);global.setting_leaderboard=0;global.setting_customSeed=12345;
    with(obj_PlayerCreateWindow){hidden=0;nameBox.text="V2 Tester";classDropDown._value="Adventurer";acceptButton.clicked=1;}
    global.v2_test_stage=1;scr_v2_test_log("Disposable V2 adventurer created");
}
if(room!=rm_Main || global.loading || !instance_exists(global.player))exit;
if(global.v2_test_stage==1 && global.v2_test_frames>180){
    random_set_seed(71427);global.day=0;global.hour=12;obj_TheShadow.x=-100000;
    var gx=floor(obj_PlayerOverworld.x/global.currentWorld.mapTileWidth);var gy=floor((obj_PlayerOverworld.y+4)/global.currentWorld.mapTileWidth);
    ds_grid_set_region(global.currentWorld.grid,gx-1,gy-1,gx+1,gy+1,15000);ds_grid_clear(global.currentWorld.difficultyGrid,1);
    var slots=ds_list_size(obj_EnemyTable.grassLowLevel);with(obj_EnemyTable)scr_v2_pools();
    scr_v2_test_assert(slots==3 && ds_list_size(obj_EnemyTable.grassLowLevel)==3,"Vanilla encounter slots unchanged; registration idempotent");
    var custom=0;repeat(800){if(scr_v2_pick(obj_EnemyTable.grassLowLevel)==obj_v2_verification_head)custom+=1;}
    scr_v2_test_assert(custom>390 && custom<530,"Weighted selection approximates exact 4/7 share without duplicate slots");
    var forced=scr_GetNewEnemy(obj_Skeleton,0,0);scr_v2_test_assert(forced.object_index==obj_Skeleton,"Explicit scripted encounter preserved");with(forced)instance_destroy();
    global.v2_test_actor=noone;var travel=scr_NewWindow(obj_AventureWindow);travel.target=100000;global.fastTraveling=0;global.player.invisible=0;
    repeat(128){if(!instance_exists(global.v2_test_actor)){global.battling=0;global.gameSpeed=.1;with(travel){encounterChance=0;event_perform(ev_step,ev_step_normal);}if(variable_instance_exists(travel,"_enemy")){var candidate=travel._enemy;if(candidate.object_index==obj_v2_verification_head)global.v2_test_actor=candidate;else with(candidate)instance_destroy();}}}
    with(travel)instance_destroy();var actor=global.v2_test_actor;scr_v2_test_assert(instance_exists(actor),"Actual travel event creates V2 custom enemy");if(!instance_exists(actor)){game_end();exit;}
    scr_v2_test_assert(actor.maxHealth==20 && actor.name=="V2 Verification Head","Compiled configuration registry applies base stats");
    scr_v2_test_assert(actor.sprite_index==spr_v2_verification_portrait && sprite_get_height(actor.sprite_index)>100,"Custom PNG is loaded by actual engine");
    actor.attackSpeed=0;global.v2_test_next=global.v2_test_frames+8;global.v2_test_stage=2;
}
else if(global.v2_test_stage==2 && global.v2_test_frames>=global.v2_test_next){
    var actor=global.v2_test_actor;var victim=global.player;var win=actor.screen;
    scr_v2_test_assert(actor.init==1 && instance_exists(win) && actor.maxHealth==10,"Native battle window and level-scaled stats");
    actor.maxHealth=100;actor.currentHealth=50;actor.minDamage=4;actor.maxDamage=4;
    victim.maxHealth=1000;victim.currentHealth=100;victim.maxMana=100;victim.currentMana=20;victim.defence=0;victim.protectionPercent=0;victim.damageProtection=0;victim.damageReflectionPercent=0;victim.attackersTakeDamage=0;victim.dodgeChance=0;victim.blocking=0;victim.burnAmount=0;victim.poisonAmount=0;victim.charm_manaShield=0;
    with(actor){attackReady=10;event_perform(ev_step,ev_step_normal);}
    scr_v2_test_assert(victim.currentHealth==94,"Generated action dispatched through native Step and physical combat");
    scr_v2_test_assert(victim.currentMana==18 && actor.currentHealth==55,"Lifesteal plus mana drain and healing");
    scr_v2_test_assert(victim.poisonAmount==2 && victim.v2_poison_name=="Violet Venom","Native poison variant shares native amount");
    victim.poisonAmount=0;victim.currentHealth=100;victim.currentMana=20;victim.dodgeChance=100;script_execute(actor.v2_attack_script,actor,victim,win);
    scr_v2_test_assert(victim.currentHealth==100 && victim.currentMana==20 && victim.poisonAmount==0,"Dodge prevents positive-damage followup effects");
    victim.dodgeChance=0;victim.blocking=1;victim.blockingPercent=100;script_execute(actor.v2_attack_script,actor,victim,win);
    scr_v2_test_assert(victim.currentHealth==100 && victim.currentMana==20,"Full block prevents gated damage effects");victim.blocking=0;
    scr_v2_effect(actor,"next_attack_damage","Bolster",2,-1);scr_v2_effect(actor,"next_attack_damage","Nullify",0,-1);
    var hp=victim.currentHealth;scr_v2_strike(actor,victim,win,1,-1,-1,1);
    scr_v2_test_assert(victim.currentHealth==hp && !ds_map_exists(actor.v2_effects,"next_attack_damage"),"Nullify replaces Bolster and consumes next attack");
    scr_v2_effect(actor,"next_attack_damage","Nullify",0,-1);scr_v2_effect(actor,"next_attack_damage","Bolster",2,-1);hp=victim.currentHealth;scr_v2_strike(actor,victim,win,1,-1,-1,1);
    scr_v2_test_assert(victim.currentHealth==hp-8 && ds_map_size(actor.v2_effects)==0,"Bolster replaces Nullify with one exclusive effect");
    var points=actor.v2_points;actor.v2_move_segment=0;actor.v2_move_time=0;actor.v2_move_intensity=1;global.gameSpeed=1;repeat(20)scr_v2_move(actor);
    scr_v2_test_assert(actor.v2_move_segment>=1 && actor.v2_move_segment<=2,"Custom movement reaches configured looping section");repeat(30)scr_v2_move(actor);scr_v2_test_assert(actor.v2_move_segment!=0,"Introductory waypoint does not repeat");
    var otherHead=instance_create_depth(0,0,0,obj_v2_verification_head);with(otherHead)event_perform(ev_step,ev_step_begin);global.v2_test_other=otherHead;
    var limb=scr_v2_spawn(actor,obj_v2_verification_limb,"limb",25,1);with(limb)event_perform(ev_step,ev_step_begin);global.v2_test_limb=limb;
    var friend=scr_v2_spawn(actor,obj_v2_verification_friend,"friend",0,0);with(friend)event_perform(ev_step,ev_step_begin);global.v2_test_friend=friend;
    var foreign=scr_v2_spawn(otherHead,obj_v2_verification_limb,"limb",0,0);with(foreign)event_perform(ev_step,ev_step_begin);global.v2_test_foreign=foreign;
    scr_v2_test_assert(limb.ownerHeadId==actor && limb.encounterGroupId==actor.encounterGroupId && foreign.encounterGroupId!=limb.encounterGroupId,"Explicit head ownership isolated between encounter groups");
    global.v2_time+=1;var first=scr_v2_spawn(actor,obj_v2_verification_summon,"summon",0,0);with(first)event_perform(ev_step,ev_step_begin);global.v2_test_summon=first;
    global.v2_time+=1;script_execute(first.v2_periodic_script,first,victim,first.screen);
    var members=scr_v2_group(actor);var child=ds_list_find_value(members,ds_list_size(members)-1);with(child)event_perform(ev_step,ev_step_begin);
    scr_v2_test_assert(child.summonerId==first,"Generated periodic action recursively summons");
    global.v2_time+=1;script_execute(child.v2_periodic_script,child,victim,child.screen);global.v2_time+=1;
    var fourth=scr_v2_spawn(actor,obj_v2_verification_summon,"summon",0,0);scr_v2_test_assert(fourth==noone,"Three active summon cap across recursive group");
    var xp=victim.XP;var gold=victim.gold;first.currentHealth=0;with(first)event_user(10);
    scr_v2_test_assert(victim.XP==xp && victim.gold==gold && ds_list_size(first.loot)==0,"Summon death grants no XP, gold, or loot");
    global.v2_time+=1;var replacement=scr_v2_spawn(actor,obj_v2_verification_summon,"summon",0,0);with(replacement)event_perform(ev_step,ev_step_begin);scr_v2_test_assert(instance_exists(replacement),"Dead summon releases a slot");
    actor.currentHealth=100;limb.currentHealth=0;with(limb)event_user(10);
    scr_v2_test_assert(actor.currentHealth==75 && victim.XP==xp && victim.gold==gold && ds_list_size(limb.loot)==0,"Limb structural damage is percent of head maximum; limb rewards suppressed");
    var liveLimb=scr_v2_spawn(actor,obj_v2_verification_limb,"limb",0,0);with(liveLimb)event_perform(ev_step,ev_step_begin);global.v2_test_live_limb=liveLimb;
    actor.currentHealth=0;with(actor)event_user(10);
    scr_v2_test_assert(liveLimb.currentHealth==0 && foreign.currentHealth>0,"Head death kills only its owned limbs");
    scr_v2_test_assert(friend.currentHealth>0 && replacement.currentHealth>0,"Friends and summons survive head death");
    scr_v2_test_assert(ds_list_size(actor.loot)==2,"100 percent quantity-two drop and zero-percent drop boundaries");
    global.battling=0;scr_v2_tick();scr_v2_test_assert(global.battling==1 && scr_v2_hostiles(members)>0,"Combat remains active for surviving hostile members");
    xp=victim.XP;gold=victim.gold;friend.currentHealth=0;with(friend)event_user(10);
    scr_v2_test_assert(victim.XP>xp && victim.gold>gold && ds_list_size(friend.loot)==1,"Friend receives independent configured rewards");
    scr_v2_escape(replacement);var remaining=0;for(var i=0;i<ds_list_size(members);i+=1){var member=ds_list_find_value(members,i);if(instance_exists(member)&&member.currentHealth>0&&!member.escaped)remaining+=1;}
    scr_v2_test_assert(remaining==0 && foreign.currentHealth>0,"Escape clears complete recursive group without affecting another head");
    global.player.currentHealth=1000;global.player.poisonAmount=0;
    scr_v2_status(victim,"poison",7,"Venom",spr_v2_verification_portrait);var antidote=instance_create_depth(0,0,0,obj_PotionAntidote);with(antidote)event_user(4);
    scr_v2_test_assert(victim.poisonAmount==0,"Actual Antidote cures custom poison variant");
    victim.currentHealth=100;victim.currentMana=20;victim.charm_manaShield=1;otherHead.minDamage=4;otherHead.maxDamage=4;scr_v2_effect(otherHead,"next_attack_damage","Nullify",0,-1);scr_v2_strike(otherHead,victim,otherHead.screen,1,-1,-1,1);
    scr_v2_test_assert(victim.currentHealth==100 && victim.currentMana==20,"Nullify prevents damage before native mana shield spending");victim.charm_manaShield=0;
    scr_v2_effect(victim,"next_attack_damage","Nullify",0,-1);instance_create_depth(0,0,0,obj_BolsterEffect);
    var effect=ds_map_find_value(victim.v2_effects,"next_attack_damage");scr_v2_test_assert(ds_map_size(victim.v2_effects)==1 && ds_list_find_value(effect,1)==2 && instance_number(obj_BolsterEffect)==0,"Native Bolster replaces Nullify with exactly one group icon");
    var brogt=scr_GetNewEnemy(obj_Brogt,0,0);with(brogt)event_perform(ev_step,ev_step_begin);
    scr_v2_test_assert(brogt.object_index==obj_Brogt && brogt.name=="V2 Slot Override" && brogt.drops[0,0]==obj_Charm_SlowerHealthDrain && brogt.drops[1,0]==obj_KingKey,"Boss adapter preserves original object identity and mandatory drop slots");
    brogt.currentHealth=0;with(brogt){event_user(10);event_user(11);}var keyCount=0;for(var i=0;i<ds_list_size(brogt.loot);i+=1){var item=ds_list_find_value(brogt.loot,i);if(item.object_index==obj_KingKey)keyCount+=1;}
    scr_v2_test_assert(keyCount==1,"Original mandatory King's Icon actually drops through boss loot event");
    var house=instance_create_depth(-900,-900,0,obj_Event_HauntedHouse);var questBoss=scr_GetNewEnemy(obj_HauntedHouseBoss,0,0);with(questBoss)event_perform(ev_step,ev_step_begin);var group=scr_v2_group(questBoss);var companion=ds_list_find_value(group,1);with(companion)event_perform(ev_step,ev_step_begin);
    questBoss.currentHealth=0;with(questBoss)event_user(10);scr_v2_tick();scr_v2_test_assert(!house.cleansed && questBoss.v2_completion!=-1,"Quest completion delayed while hostile friend remains");
    companion.currentHealth=0;with(companion)event_user(10);scr_v2_tick();scr_v2_test_assert(house.cleansed && house.finished && instance_exists(obj_Requirement_HauntedHouse),"Original quest flags and completion reward callback preserved");
    var originalWorld=global.currentWorld;var dungeon=instance_create_depth(-900,-900,0,obj_DungeonGen);var tomb=scr_GetNewEnemy(obj_TombBoss,0,0);with(tomb)event_perform(ev_step,ev_step_begin);var tombMembers=scr_v2_group(tomb);var tombFriend=ds_list_find_value(tombMembers,1);with(tombFriend)event_perform(ev_step,ev_step_begin);global.currentWorld=dungeon;tomb.currentHealth=0;with(tomb)event_user(10);scr_v2_tick();scr_v2_test_assert(dungeon.baseEncounterRate!=-1,"Tomb progression waits for hostile companion");tombFriend.currentHealth=0;with(tombFriend)event_user(10);scr_v2_tick();scr_v2_test_assert(dungeon.baseEncounterRate==-1 && instance_exists(obj_Requirement_KillSkeletons),"Tomb original world flag and quest kill credit preserved");global.currentWorld=originalWorld;
    var thief=scr_GetNewEnemy(obj_ThiefBoss,0,0);with(thief)event_perform(ev_step,ev_step_begin);scr_v2_test_assert(thief.object_index==obj_ThiefBoss && thief.drops[0,0]!=noone && thief.canEscape==0,"Bandit quest slot retains native identity, loot and escape rules");
    var controller=instance_create_depth(0,0,0,obj_DemonBossSpawner);with(controller)event_perform(ev_step,ev_step_end);var demonHead=controller.head;var body=controller.butt;var arms=controller.arms;var legs=controller.legs;
    with(demonHead)event_perform(ev_step,ev_step_begin);with(body)event_perform(ev_step,ev_step_begin);with(arms)event_perform(ev_step,ev_step_begin);with(legs)event_perform(ev_step,ev_step_begin);
    scr_v2_test_assert(demonHead.object_index==obj_DemonBossHead && body.object_index==obj_DemonBossButt && arms.object_index==obj_DemonBossArms && legs.object_index==obj_DemonBossLegs,"Multipart adapter preserves all four required vanilla object slots");
    scr_v2_test_assert(body.ownerHeadId==demonHead && arms.ownerHeadId==demonHead && legs.ownerHeadId==demonHead,"Original multipart spawner assigns explicit isolated ownership");
    var headHealth=demonHead.currentHealth;arms.currentHealth=0;with(arms)event_user(10);scr_v2_test_assert(demonHead.currentHealth==headHealth,"Vanilla limb-to-head global damage replaced by default-zero structural action");demonHead.currentHealth=0;with(demonHead)event_user(10);scr_v2_test_assert(body.currentHealth==0 && legs.currentHealth==0,"Multipart head death cleans up required owned slots");
    scr_v2_test_enchantments();screen_save("v2-battle.png");
    global.v2_test_stage=10;global.v2_expand_stage=0;

}

if(global.v2_test_stage==10)scr_v2_test_expansion();
