var probe=instance_create_depth(0,0,0,obj_v2_verification_enchantments);
with(probe){event_perform(ev_step,ev_step_begin);currentHealth=0;event_user(10);}
scr_v2_test_assert(ds_list_size(probe.loot)==22,"Enchantment choices preserve exact loot quantities");
var selected=ds_list_find_value(probe.loot,0);with(selected)event_perform(ev_step,ev_step_begin);
scr_v2_test_assert(selected.enchanted==1 && selected.identified==1 && selected.chanceToEnchant==0,"Selected enchantment is guaranteed and identified");
var strength=0;var steal=0;for(var j=0;j<9;j+=1){if(selected.bonus[j,0]=="strength")strength+=selected.bonus[j,1];if(selected.bonus[j,0]=="vampirismPercent")steal+=selected.bonus[j,1];}
scr_v2_test_assert(strength==7 && steal==12,"Both selected bonuses have exact requested amounts");
var randoms=0;for(var j=1;j<=20;j+=1){var item=ds_list_find_value(probe.loot,j);with(item)event_perform(ev_step,ev_step_begin);if(item.enchanted==1)randoms+=1;}
scr_v2_test_assert(randoms==20,"Twenty random enchantment drops are all positively enchanted");
var plain=ds_list_find_value(probe.loot,21);with(plain)event_perform(ev_step,ev_step_begin);scr_v2_test_assert(plain.object_index==obj_PotionAntidote && plain.enchanted==0,"Native consumable retains its ordinary behavior");
var prior=global.player.weapon;global.player.weapon=selected;selected.equipped=1;scr_UpdatePlayerStats();scr_v2_test_assert(global.player.strengthBonus>=7 && global.player.vampirismPercentBonus>=12,"Selected bonuses participate in native player stat calculation");global.player.weapon=prior;selected.equipped=0;scr_UpdatePlayerStats();
with(selected)event_perform(ev_step,ev_step_begin);scr_v2_test_assert(selected.enchanted==1 && selected.chanceToEnchant==0,"Guaranteed selected item does not reroll on later frames");
