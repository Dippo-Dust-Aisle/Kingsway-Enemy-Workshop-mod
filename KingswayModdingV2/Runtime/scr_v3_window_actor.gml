var win=argument0;
if(variable_instance_exists(win,"enemy") && instance_exists(win.enemy))return win.enemy;
if(variable_instance_exists(win,"owner") && instance_exists(win.owner))return win.owner;
return noone;
