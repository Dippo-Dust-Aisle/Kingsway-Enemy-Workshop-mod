// Only native player attacks resolve this event. Direct damage, statuses and
// enemy/reaction strikes do not dispatch it. The enemy owns the action context.
var attacker=argument0;var enemy=argument1;
if(attacker!=global.player || !instance_exists(enemy))return;
if(!variable_instance_exists(enemy,"v2_enabled") || !enemy.v2_enabled)return;
if(enemy.currentHealth<=0 || enemy.escaped || enemy.v2_reacting)return;
var win=enemy.screen;
if(!instance_exists(win) || win.battleOver)return;
enemy.v2_reacting=1;
// Native combat uses instance-scoped scratch variables. Run the immediate
// reaction on the enemy so a counterstrike cannot overwrite its caller's state.
var damage=argument2;var blocked=argument3;
with(enemy)script_execute(v2_attacked_script,id,attacker,win,damage,blocked);
if(instance_exists(enemy))enemy.v2_reacting=0;
