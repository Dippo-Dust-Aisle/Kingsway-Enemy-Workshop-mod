var target=argument0;var operation=argument1;var value=argument2;
if(!instance_exists(target))return 0;
if(!variable_instance_exists(target,"v2_enabled") || !variable_instance_exists(target,"v2_base_attack_speed"))return 0;
if(target.v2_hazard || !variable_instance_exists(target,"attackReady"))return 0;
var next=target.attackSpeed;
if(operation=="set")next=value;
else if(operation=="add")next+=value;
else if(operation=="multiply")next*=value;
else if(operation=="restoreBase")next=target.v2_base_attack_speed;
else return 0;
// Range comparisons also reject NaN and infinity; no invalid result is applied.
// sign also rejects tiny negative values inside the runner comparison epsilon.
if(!(next>=0 && next<=100000) || sign(next)==-1)return 0;
if(argument_count>4 && !argument4)return 1;
target.attackSpeed=next;
if(argument3)target.attackReady=0;
return 1;
