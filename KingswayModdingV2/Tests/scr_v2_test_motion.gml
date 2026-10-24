with(obj_Enemy)instance_destroy();with(obj_Trap_Base)instance_destroy();scr_v2_tick();
var actor=instance_create_depth(0,0,0,obj_v2_verification_alternator);with(actor)event_perform(ev_step,ev_step_begin);
var otherEnemy=instance_create_depth(0,0,0,obj_v2_verification_alternator);with(otherEnemy)event_perform(ev_step,ev_step_begin);
var win=actor.screen;var rw=max(1,global.resolutionW/global.gameScale-win.width);var rh=max(1,global.resolutionH/global.gameScale-win.height-24);
var oldTime=global.v2_time;var oldSpeed=global.gameSpeed;global.gameSpeed=.1;
// All movement checks run in the actual runner's normalized travel area.
scr_v2_window(win,"move",0,.3,.4);
scr_v2_test_assert(abs(win.x/rw-.3)<.0001 && abs(win.y/rh-.4)<.0001,"Legacy fixed Window Move is an immediate absolute move");
var oldY=win.y;scr_v2_window(win,"move",0,.8,.9,"randomX");scr_v2_test_assert(win.y==oldY && win.x>=0 && win.x<=rw,"Absolute randomX preserves current Y");
var oldX=win.x;scr_v2_window(win,"move",0,.8,.9,"randomY");scr_v2_test_assert(win.x==oldX && win.y>=0 && win.y<=rh,"Absolute randomY preserves current X");
scr_v2_window(win,"move",0,.3,.4);scr_v2_window(win,"move",0,0,0,"randomXY");scr_v2_test_assert(win.x!=.3*rw && win.y!=.4*rh && win.x>=0 && win.y>=0 && win.x<=rw && win.y<=rh,"Absolute randomXY samples both axes");
scr_v2_window(win,"move",0,.3,.4);
scr_v2_window(win,"move",0,0,0,"fixed","relative",.1,-.1,0,0,0,0,0,"linear","clamp");
scr_v2_test_assert(abs(win.x/rw-.4)<.0001 && abs(win.y/rh-.3)<.0001,"Relative fixed adds offsets to current position");
scr_v2_window(win,"move",0,0,0,"randomX","relative",0,0,.1,.1,-.2,-.2,0,"linear","clamp");
scr_v2_test_assert(abs(win.x/rw-.5)<.0001 && abs(win.y/rh-.3)<.0001,"Relative randomX adds only X");
scr_v2_window(win,"move",0,0,0,"randomY","relative",0,0,.1,.1,-.1,-.1,0,"linear","clamp");
scr_v2_test_assert(abs(win.x/rw-.5)<.0001 && abs(win.y/rh-.2)<.0001,"Relative randomY adds only Y");
scr_v2_window(win,"move",0,0,0,"randomXY","relative",0,0,-.1,-.1,.2,.2,0,"linear","clamp");
scr_v2_test_assert(abs(win.x/rw-.4)<.0001 && abs(win.y/rh-.4)<.0001,"Relative randomXY adds both independently sampled offsets");
var asymmetric=1;repeat(30){scr_v2_window(win,"move",0,.5,.5);scr_v2_window(win,"move",0,0,0,"randomXY","relative",0,0,-.25,.25,-.4,.1,0,"linear","none");if(win.x/rw<.25 || win.x/rw>.75 || win.y/rh<.1 || win.y/rh>.6)asymmetric=0;}
scr_v2_test_assert(asymmetric,"Explicit asymmetric random ranges remain within authored signed limits");
scr_v2_window(win,"move",0,.3,.3);scr_v2_window(win,"move",0,0,0,"fixed","relative",.4,.4,0,0,0,0,1,"linear","none");
scr_v2_test_assert(abs(win.x/rw-.3)<.0001,"Positive duration starts at the currently displayed position");
scr_v2_motion_step(win,.25);scr_v2_test_assert(abs(win.x/rw-.4)<.0001 && abs(win.y/rh-.4)<.0001,"Linear transition interpolates by game seconds");
scr_v2_window(win,"move",0,0,0,"fixed","relative",.4,0,0,0,0,0,1,"ease","none");scr_v2_motion_step(win,.25);
scr_v2_test_assert(abs(win.x/rw-(.4+.4*.15625))<.0001 && abs(win.y/rh-.4)<.0001,"Ease transition retargets from the visible point without a jump");
var elapsed=win.v2_motion_elapsed;global.gameSpeed=0;scr_v2_motion_step(win,.5);scr_v2_test_assert(win.v2_motion_elapsed==elapsed,"Paused game freezes the offset transition");global.gameSpeed=.1;
actor.stunAmount=1;scr_v2_motion_step(win,.5);scr_v2_test_assert(win.v2_motion_elapsed==elapsed,"Stun follows the authored movement pause setting");actor.stunAmount=0;
win.minimized=1;scr_v2_motion_step(win,.5);scr_v2_test_assert(win.v2_motion_elapsed==elapsed,"Minimization pauses the offset transition");win.minimized=0;
scr_v2_window(win,"move",0,.5,.5);repeat(100){scr_v2_window(win,"move",0,0,0,"fixed","relative",.01,-.01,0,0,0,0,0,"linear","none");scr_v2_window(win,"move",0,0,0,"fixed","relative",-.01,.01,0,0,0,0,0,"linear","none");}
scr_v2_test_assert(abs(win.x/rw-.5)<.0001 && abs(win.y/rh-.5)<.0001,"Repeated opposite relative moves do not accumulate hidden drift");
var oldW=global.resolutionW;var oldH=global.resolutionH;var oldScale=global.gameScale;
for(var scale=1;scale<=3;scale+=1){global.resolutionW=1920;global.resolutionH=1080;global.gameScale=scale;scr_v2_window(win,"move",0,2,-1,"fixed","absolute",0,0,0,0,0,0,0,"linear","clamp");scr_v2_test_assert(win.x==max(0,1920/scale-win.width) && win.y==0,"Combined clamp respects logical bounds at scale "+string(scale));}
global.resolutionW=oldW;global.resolutionH=oldH;global.gameScale=oldScale;
// Attack speed uses the live native field and the post-level-initialization base.
var base=actor.v2_base_attack_speed;actor.attackReady=4;var otherSpeed=otherEnemy.attackSpeed;
scr_v2_test_assert(scr_v2_attack_speed(actor,"set",.2,0) && actor.attackSpeed==.2 && actor.attackReady==4,"Set attack speed preserves native meter progress");
scr_v2_attack_speed(actor,"add",.1,0);scr_v2_test_assert(abs(actor.attackSpeed-.3)<.0001,"Add adjusts live attack speed");
scr_v2_attack_speed(actor,"multiply",2,0);scr_v2_test_assert(abs(actor.attackSpeed-.6)<.0001,"Multiply scales live attack speed");
scr_v2_test_assert(!scr_v2_attack_speed(actor,"add",-1,1) && abs(actor.attackSpeed-.6)<.0001 && actor.attackReady==4,"Negative result is rejected without resetting progress");
scr_v2_test_assert(!scr_v2_attack_speed(global.player,"set",1,0) && !scr_v2_attack_speed(win,"set",1,0),"Objects without the compatible native enemy meter are rejected safely");
scr_v2_test_assert(!scr_v2_attack_speed(actor,"set",-.000001,0),"Even a negative result smaller than the native comparison epsilon is rejected");
scr_v2_attack_speed(actor,"restoreBase",0,1);scr_v2_test_assert(actor.attackSpeed==base && actor.attackReady==0,"RestoreBase uses captured base and explicit reset clears the meter");
scr_v2_attack_speed(actor,"set",0,0);actor.attackReady=4;with(actor)event_perform(ev_step,ev_step_normal);scr_v2_test_assert(actor.attackReady==4,"Zero speed pauses native attack charging");
scr_v2_attack_speed(actor,"set",.2,0);actor.coldAmount=0;var ready=actor.attackReady;with(actor)event_perform(ev_step,ev_step_normal);var warm=actor.attackReady-ready;
actor.coldAmount=10;ready=actor.attackReady;with(actor)event_perform(ev_step,ev_step_normal);scr_v2_test_assert(abs((actor.attackReady-ready)-warm*.65)<.0001,"Native chill retains its independent 0.65 charge modifier");actor.coldAmount=0;
scr_v2_test_assert(otherEnemy.attackSpeed==otherSpeed,"Attack-speed actions affect only their target enemy");actor.attackSpeed=0;
// Generated action nodes alternate independently by enemy and section.
actor.maxMana=1000000;actor.currentMana=0;otherEnemy.maxMana=1000000;otherEnemy.currentMana=0;
var expected=[1,11,12,22];for(var i=0;i<4;i+=1){script_execute(actor.v2_attack_script,actor,global.player,win);scr_v2_test_assert(actor.currentMana==expected[i],"Alternating branch activation "+string(i+1)+" selects A/B/A/B");}
script_execute(otherEnemy.v2_attack_script,otherEnemy,global.player,otherEnemy.screen);scr_v2_test_assert(otherEnemy.currentMana==1,"A separate enemy starts its own toggle at A");
script_execute(actor.v2_attacked_script,actor,global.player,win,1,0);script_execute(actor.v2_attacked_script,actor,global.player,win,1,0);
scr_v2_test_assert(actor.currentMana==122,"Incoming reaction cooldown blocks execution without advancing its independent toggle");
global.v2_time+=2;script_execute(actor.v2_attacked_script,actor,global.player,win,1,0);scr_v2_test_assert(actor.currentMana==1122,"Incoming reaction continues with B after its cooldown");
ds_map_clear(actor.v2_cooldowns);script_execute(actor.v2_periodic_script,actor,global.player,win);global.v2_time+=2;script_execute(actor.v2_periodic_script,actor,global.player,win);scr_v2_test_assert(actor.currentMana==111122,"Periodic actions use their own A/B toggle state");
var gated=instance_create_depth(0,0,0,obj_v2_verification_alternate_gated);with(gated)event_perform(ev_step,ev_step_begin);gated.maxMana=10000;gated.currentMana=0;gated.currentHealth=gated.maxHealth;
script_execute(gated.v2_attack_script,gated,global.player,gated.screen);scr_v2_test_assert(ds_map_size(gated.v2_toggles)==0,"Failed outer condition does not advance nested toggles");
gated.currentHealth=1;script_execute(gated.v2_attack_script,gated,global.player,gated.screen);scr_v2_test_assert(gated.currentMana==101 && ds_map_size(gated.v2_toggles)==2,"Separate nested toggle nodes each begin at A");script_execute(gated.v2_attack_script,gated,global.player,gated.screen);scr_v2_test_assert(gated.currentMana==1111,"Separate nested toggle nodes each continue to B");
var toggleCount=ds_map_size(gated.v2_toggles);script_execute(gated.v2_attacked_script,gated,global.player,gated.screen,1,0);scr_v2_test_assert(ds_map_size(gated.v2_toggles)==toggleCount && ds_map_size(gated.v2_cooldowns)==0,"Failed chance and selected branches with no successful leaf do not commit toggles or reaction cooldowns");
var delayed=instance_create_depth(0,0,0,obj_v2_verification_alternate_delayed);with(delayed)event_perform(ev_step,ev_step_begin);delayed.maxMana=100;delayed.currentMana=0;
script_execute(delayed.v2_attack_script,delayed,global.player,delayed.screen);var first=ds_list_find_value(global.v2_sequences,ds_list_size(global.v2_sequences)-1);
script_execute(delayed.v2_attack_script,delayed,global.player,delayed.screen);var second=ds_list_find_value(global.v2_sequences,ds_list_size(global.v2_sequences)-1);
global.v2_time+=.11;scr_v2_sequence_run(first);scr_v2_sequence_run(second);scr_v2_test_assert(delayed.currentMana==11,"Overlapping delayed sequences retain the A and B selected on activation");global.v2_time+=.11;scr_v2_sequence_run(second);scr_v2_sequence_run(first);scr_v2_test_assert(delayed.currentMana==22,"Repeats retain their selected side even when another activation intervenes");
var toggleMap=delayed.v2_toggles;var stack=ds_map_find_value(first,"toggles");with(delayed)instance_destroy();scr_v2_tick();scr_v2_test_assert(!ds_exists(toggleMap,ds_type_map) && !ds_exists(stack,ds_type_list),"Enemy cleanup releases toggle maps and completed sequence stacks");
global.v2_time=oldTime;global.gameSpeed=oldSpeed;
with(obj_Enemy)instance_destroy();scr_v2_tick();
// Custom path and offset interpolation advance together, without changing phase.
actor=instance_create_depth(0,0,0,obj_v2_verification_motion);with(actor)event_perform(ev_step,ev_step_begin);win=actor.screen;scr_v2_move(actor);rw=max(1,global.resolutionW/global.gameScale-win.width);rh=max(1,global.resolutionH/global.gameScale-win.height-24);
actor.v2_move_time=.5;var moveDirection=actor.v2_move_direction;script_execute(actor.v2_attack_script,actor,global.player,win);scr_v2_motion_step(win,.5);scr_v2_move(actor);
scr_v2_test_assert(win.x/rw>.3 && win.y/rh>.29 && win.y/rh<.33 && actor.v2_move_time>.5 && actor.v2_move_direction==moveDirection,"Straight custom path plus relative Y transition produces a swerve while phase and direction advance");
scr_v2_motion_step(win,1);scr_v2_move(actor);scr_v2_test_assert(abs(win.y/rh-.4)<.0001,"Custom path does not overwrite the completed movement offset");
var phase=actor.v2_move_time;scr_v2_window(win,"clearMoveOffset",0,0,0,"fixed","absolute",0,0,0,0,0,0,1,"linear","inherit");scr_v2_motion_step(win,1);scr_v2_test_assert(abs(win.y/rh-.2)<.0001 && actor.v2_move_time==phase,"Clearing the offset returns smoothly to the authored path without restarting it");
scr_v2_test_assert(actor.attackSpeed==.2,"Generated composed Attack Speed action writes the live native field");
with(actor)instance_destroy();
// Native path verification continues across real runner frames.
actor=instance_create_depth(0,0,0,obj_v2_verification_alternator);with(actor)event_perform(ev_step,ev_step_begin);actor.path=pth_Skeleton;actor.v2_path=pth_Skeleton;actor.pathSpeed=1;actor.attackSpeed=0;actor.attackReady=5;ds_map_replace(actor.v2_cooldowns,"verification:alternator:periodic:0",global.v2_time+1000);
win=actor.screen;scr_v2_window(win,"move",0,0,0,"fixed","relative",0,0,0,0,0,0,0,"linear","none");
scr_v2_test_assert(win.thisInit && instance_exists(win.v2_path_driver),"First-frame Window Move initializes the native path anchor before rebasing");var driver=win.v2_path_driver;
global.v2_motion_native=actor;global.v2_motion_driver=driver;global.v2_motion_phase=driver.path_position;global.v2_motion_base_x=win.v2_motion_base_x;global.v2_motion_base_y=win.v2_motion_base_y;global.v2_motion_frames=0;
scr_v2_window(win,"move",0,0,0,"fixed","relative",0,.15,0,0,0,0,.25,"linear","none");
scr_v2_test_assert(driver.path_position==global.v2_motion_phase && driver.path_index==win.path,"Native move retains driver path phase and resource");
