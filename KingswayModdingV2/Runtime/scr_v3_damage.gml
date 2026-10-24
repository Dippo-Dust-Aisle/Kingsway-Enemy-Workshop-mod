var actor=argument0;var target=argument1;var window=argument2;
if(!instance_exists(target))return 0;
if(variable_instance_exists(target,"v3_cosmetic") && target.v3_cosmetic)return 0;
var value=max(0,scr_v3_amount(target,"health",argument5,argument3));var kind=argument4;
var before=max(0,target.currentHealth);
if(kind=="true")target.currentHealth-=round(value);
else {
    if(argument6 && target.blocking)value*=max(0,1-target.blockingPercent/100);
    scr_DoDamage(target,value,"magic");
}
target.v3_hurt_by=actor;
var resolved=max(0,before-max(0,target.currentHealth));
if(instance_exists(window))scr_BattleText(window,string(resolved),target,0);
return resolved;
