with(obj_Enemy)instance_destroy();with(obj_Trap_Base)instance_destroy();
var actor=instance_create_depth(0,0,0,obj_v2_verification_self);with(actor)event_perform(ev_step,ev_step_begin);
var points=ds_list_create();ds_list_add(points,.1,.5,.01,0,0,.1,.5,0,1.25,-.25,.01,0,0,1.25,-.25,0);
actor.v2_points=points;actor.v2_move_started=1;actor.v2_move_loop=0;actor.v2_move_mode="linear";actor.v2_move_intensity=1;
var oldW=global.resolutionW;var oldH=global.resolutionH;var oldScale=global.gameScale;global.resolutionW=1366;global.resolutionH=768;global.gameScale=2;
var rw=683-actor.screen.width;var rh=384-actor.screen.height-24;
var policies=["clamp","wrap","reverse","restart"];var xs=[1,.25,.75,.1];var ys=[0,.75,.25,.5];
for(var i=0;i<4;i+=1){actor.v2_move_boundary=policies[i];actor.v2_move_segment=0;actor.v2_move_time=1;scr_v2_move(actor);scr_v2_test_assert(abs(actor.screen.x-xs[i]*rw)<.01 && abs(actor.screen.y-ys[i]*rh)<.01,"Logical screen dimensions and "+policies[i]+" boundary apply to calculated positions");}
scr_v2_test_assert(ds_list_find_value(points,8)==1.25 && ds_list_find_value(points,9)==-.25,"Boundary behavior preserves authored off-screen points");
actor.v2_start_mode="randomX";actor.v2_move_started=0;actor.v2_move_time=0;actor.v2_move_segment=0;scr_v2_move(actor);var firstX=actor.screen.x;var offset=actor.v2_offset_x;
scr_v2_test_assert(firstX>=0 && firstX<=rw && abs(actor.screen.y-.5*rh)<.01,"Random X preserves fixed Y and keeps new window within logical travel bounds");scr_v2_move(actor);scr_v2_test_assert(actor.v2_offset_x==offset,"Random movement start is sampled once per spawn");
global.resolutionW=oldW;global.resolutionH=oldH;global.gameScale=oldScale;with(actor)instance_destroy();ds_list_destroy(points);
