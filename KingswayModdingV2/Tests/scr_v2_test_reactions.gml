// Exercise the native player's Attack skill and generated reaction sequences.
var player=global.player;
var actor=instance_create_depth(0,0,0,obj_v2_verification_reaction);
var otherEnemy=instance_create_depth(0,0,0,obj_v2_verification_reaction);
with(actor)event_perform(ev_step,ev_step_begin);
with(otherEnemy)event_perform(ev_step,ev_step_begin);
actor.maxHealth=1000;actor.currentHealth=1000;actor.maxMana=10000;actor.currentMana=0;actor.defence=0;actor.damageProtection=0;actor.protectionPercent=0;actor.blocking=0;actor.damageReflectionPercent=0;actor.attackersTakeDamage=0;actor.isBurned=0;actor.poisonAura=0;actor.coldAura=0;
player.minDamage=7;player.maxDamage=7;player.damagePercent=100;player.criticalChance=-1;player.fireDamage=0;player.extraDamage=0;player.astralDamage=0;player.doubleDamage=0;player.damageToUndead=0;player.damageToMinions=0;player.poisonDamage=0;player.poisonOnAttack=0;player.stunOnAttack=0;player.chillOnAttack=0;player.blocking=0;player.vampirismPercent=0;
scr_v2_consume(player,"next_attack_damage",1);
var skill=instance_create_depth(0,0,0,obj_Skill_Attack);skill.target=actor;
var win=actor.screen;var otherWin=otherEnemy.screen;otherWin.x=15;otherWin.y=17;
var oldTime=global.v2_time;var oldSpeed=global.gameSpeed;global.gameSpeed=.1;

// A zero-damage hit must not spend the positive-damage reaction's cooldown.
actor.blocking=1;actor.blockingPercent=100;with(skill)event_user(0);
scr_v2_test_assert(actor.currentHealth==1000 && actor.currentMana==100,"Resolved blocked incoming hit selects blocked branch using the attacked enemy state");
scr_v2_test_assert(!ds_map_exists(actor.v2_cooldowns,"verification:reaction:whenAttacked:0"),"Failed positive-damage branch leaves its reaction cooldown available");
actor.currentMana=0;actor.blocking=0;win.x=0;win.y=0;
var beforeSequences=ds_list_size(global.v2_sequences);with(skill)event_user(0);
scr_v2_test_assert(actor.currentHealth==993 && actor.currentMana==1,"One native incoming Attack triggers the positive-damage reaction exactly once");
scr_v2_test_assert(ds_list_size(global.v2_sequences)==beforeSequences+1,"Only eligible top-level reaction creates a new sequence during the other reaction cooldown");
var seq=ds_list_find_value(global.v2_sequences,ds_list_size(global.v2_sequences)-1);
scr_v2_test_assert(ds_map_find_value(seq,"damage")==7 && ds_map_find_value(seq,"actor")==actor && ds_map_find_value(seq,"victim")==player,"Reaction sequence retains actual resolved incoming damage and enemy/player context");
scr_v2_test_assert(win.text[win.textLines-1,0]=="Reaction received" && win.text[win.textLines-1,1]==actor,"Reaction Battle Message appears in the attacked enemy's native window");
scr_v2_test_assert(audio_is_playing(ds_map_find_value(global.v2_audio,"verification:probe_sound")),"Reaction sound uses the existing native audio helper");
var rw=max(0,global.resolutionW/global.gameScale-win.width);var rh=max(0,global.resolutionH/global.gameScale-win.height-24);
scr_v2_test_assert((win.x!=0 || win.y!=0) && win.x>=0 && win.x<=rw && win.y>=0 && win.y<=rh && otherWin.x==15 && otherWin.y==17,"When attacked randomXY moves only the attacked battle window within its travel area");
scr_v2_test_assert(ds_map_find_value(actor.v2_cooldowns,"verification:reaction:whenAttacked:0")==global.v2_time+2,"Reaction cooldown starts at successful execution");
with(skill)event_user(0);
scr_v2_test_assert(actor.currentHealth==986 && actor.currentMana==1 && ds_list_size(global.v2_sequences)==beforeSequences+1,"Second native attack resolves damage but cooldown suppresses repeated reaction");
repeat(3){script_execute(actor.v2_periodic_script,actor,player,win);scr_v2_sequence_run(seq);}
scr_v2_test_assert(actor.currentMana==1,"Periodic frames do not replay an incoming reaction or its waiting actions");
global.v2_time+=.11;scr_v2_sequence_run(seq);scr_v2_test_assert(actor.currentMana==11,"Reaction resumes nested actions after its wait");
global.v2_time+=.11;scr_v2_sequence_run(seq);scr_v2_test_assert(actor.currentMana==21 && ds_map_find_value(seq,"script")==-1,"Reaction repeat executes once more then completes");
global.v2_time=oldTime+2;with(skill)event_user(0);
scr_v2_test_assert(actor.currentMana==22,"Reaction cooldown expires and the next native incoming attack triggers again");
// Negative-source checks run with an expired cooldown so a spurious dispatch
// cannot be hidden by cooldown suppression.
global.v2_time=oldTime+4.1;
var pending=ds_list_size(global.v2_sequences);var mana=actor.currentMana;
scr_DoDamage(actor,3,"physical");actor.currentHealth-=1;
script_execute(actor.v2_attack_script,actor,player,win);
scr_v2_test_assert(actor.currentMana==mana && ds_list_size(global.v2_sequences)==pending+1,"Direct damage, direct health changes and outgoing native strike do not dispatch reactions");
// An outgoing strike does create its own action sequence, hence +1 above.
scr_v2_test_assert(otherEnemy.currentMana==0,"Unattacked V2 enemy never receives another enemy's reactions");
var vanilla=instance_create_depth(0,0,0,obj_Skeleton);with(vanilla)event_perform(ev_step,ev_step_begin);
scr_Attack(player,vanilla,vanilla.screen);
scr_v2_test_assert(actor.currentMana==mana && otherEnemy.currentMana==0,"Incoming attack on a vanilla enemy does not dispatch any V2 reaction");
with(vanilla)instance_destroy();

// Legacy call plus all four placements at different resolution/scale pairs.
var oldW=global.resolutionW;var oldH=global.resolutionH;var oldScale=global.gameScale;
var widths=[1280,1920,640];var heights=[960,1080,480];var scales=[2,1,4];
for(var s=0;s<3;s+=1){
 global.resolutionW=widths[s];global.resolutionH=heights[s];global.gameScale=scales[s];
 rw=max(0,global.resolutionW/global.gameScale-win.width);rh=max(0,global.resolutionH/global.gameScale-win.height-24);
 scr_v2_window(win,"move",0,.2,.8);
 scr_v2_test_assert(abs(win.x-.2*rw)<.001 && abs(win.y-.8*rh)<.001,"Legacy Window Move remains fixed at scale "+string(scales[s]));
 var modes=["fixed","randomX","randomY","randomXY"];
 for(var m=0;m<4;m+=1){
  var currentX=win.x;var currentY=win.y;scr_v2_window(win,"move",0,.2,.8,modes[m]);
  var valid=win.x>=0 && win.x<=rw && win.y>=0 && win.y<=rh;
  if(m==0)valid=valid && abs(win.x-.2*rw)<.001;if(m==2)valid=valid && abs(win.x-currentX)<.001;
  if(m==0)valid=valid && abs(win.y-.8*rh)<.001;if(m==1)valid=valid && abs(win.y-currentY)<.001;
  scr_v2_test_assert(valid,"Window Move "+modes[m]+" honors axes and available travel at scale "+string(scales[s]));
  var previousX=win.x;var previousY=win.y;scr_v2_window(win,"move",0,.2,.8,modes[m]);
  var changes=1;
  if((m==1 || m==3) && rw>0)changes=changes && previousX!=win.x;
  if((m==2 || m==3) && rh>0)changes=changes && previousY!=win.y;
  if(m==0 || m==2)changes=changes && previousX==win.x;
  if(m==0 || m==1)changes=changes && previousY==win.y;
  scr_v2_test_assert(changes,"Repeated Window Move "+modes[m]+" randomizes only selected nonzero axes at scale "+string(scales[s]));
 }
}
global.resolutionW=oldW;global.resolutionH=oldH;global.gameScale=oldScale;
var gated=instance_create_depth(0,0,0,obj_v2_verification_reactiongate);with(gated)event_perform(ev_step,ev_step_begin);
gated.blocking=1;gated.blockingPercent=100;gated.defence=0;gated.damageProtection=0;gated.protectionPercent=0;gated.currentMana=0;
scr_Attack(player,gated,gated.screen);
scr_v2_test_assert(gated.currentMana==0 && ds_map_size(gated.v2_cooldowns)==0,"Top-level cooldown group with a failed child does not spend reaction cooldown");
gated.blocking=0;scr_Attack(player,gated,gated.screen);
scr_v2_test_assert(gated.currentMana==1 && ds_map_size(gated.v2_cooldowns)==1,"Top-level cooldown group commits once only after a child actually triggers");
with(gated)instance_destroy();
with(skill)instance_destroy();with(actor)instance_destroy();with(otherEnemy)instance_destroy();
global.v2_time=oldTime;global.gameSpeed=oldSpeed;scr_v2_tick();
var orphan=0;for(var i=0;i<ds_list_size(global.v2_sequences);i+=1){var item=ds_list_find_value(global.v2_sequences,i);if(ds_map_find_value(item,"actor")==actor)orphan+=1;}
scr_v2_test_assert(orphan==0,"Destroying the attacked enemy cancels delayed reactions and releases their sequence maps");
