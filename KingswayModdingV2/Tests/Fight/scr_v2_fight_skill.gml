var obj=argument0;var slot=argument1;var upgrade=argument2;
var skill=instance_find(obj,0);
if(!instance_exists(skill))skill=instance_create_depth(0,0,0,obj);
with(skill){if(!init)event_perform(ev_step,ev_step_begin);if(upgrade && skillLevel==0)event_user(2);known=1;}
if(ds_list_find_index(global.player.skills.knownSkills,skill)<0)ds_list_add(global.player.skills.knownSkills,skill);
global.player.battleSkill[slot]=skill;
scr_v2_fight_log("SKILL "+string(slot)+": "+skill.name);
