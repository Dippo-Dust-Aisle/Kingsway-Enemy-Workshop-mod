global.v2_spawning_projectile=1;
var projectile=instance_create_depth(0,0,0,argument0);
global.v2_spawning_projectile=0;
projectile.damage=argument1;projectile._damage=argument1;
projectile.v2_placement=argument2;projectile.v2_x=argument3;projectile.v2_y=argument4;
if(argument_count>6)projectile.v3_button_text=argument6;projectile.v2_outside=argument5;projectile.v2_placed=0;
return projectile;
