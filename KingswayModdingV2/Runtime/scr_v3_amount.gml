var target=argument0;var resource=argument1;var basis=argument2;var amount=argument3;
if(basis=="fixed")return amount;
var field="currentHealth";if(resource=="mana")field="currentMana";
if(basis=="maxPercent"){field="maxHealth";if(resource=="mana")field="maxMana";}
if(!instance_exists(target) || !variable_instance_exists(target,field))return 0;
return max(0,variable_instance_get(target,field))*amount/100;
