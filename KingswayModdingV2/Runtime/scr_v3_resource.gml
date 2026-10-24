var actor=argument0;var target=argument1;var resource=argument2;var destination=argument3;var mode=argument4;var amount=max(0,argument5);var ratio=argument6;
var current="currentHealth";var maximum="maxHealth";
if(resource=="mana"){current="currentMana";maximum="maxMana";}
if(!instance_exists(target) || !variable_instance_exists(target,current))return 0;
if(mode=="fromDamage")amount=max(0,argument7)*amount/100;
if(mode=="restore" || mode=="fromDamage"){variable_instance_set(target,current,min(variable_instance_get(target,maximum),variable_instance_get(target,current)+amount));return amount;}
if(resource!="mana")target.v3_hurt_by=actor;
var taken=min(max(0,variable_instance_get(target,current)),amount);
variable_instance_set(target,current,variable_instance_get(target,current)-taken);
if(mode=="transfer" && instance_exists(actor)){
    var to="currentHealth";var cap="maxHealth";if(destination=="mana"){to="currentMana";cap="maxMana";}
    if(variable_instance_exists(actor,to))variable_instance_set(actor,to,min(variable_instance_get(actor,cap),variable_instance_get(actor,to)+taken*ratio));
}
return taken;
