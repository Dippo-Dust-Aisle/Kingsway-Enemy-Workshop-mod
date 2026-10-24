var actor=argument0;var family=argument1;var icon=-1;
if(variable_instance_exists(actor,"v2_"+family+"_icon"))icon=variable_instance_get(actor,"v2_"+family+"_icon");
if(icon>=0)draw_sprite_ext(icon,0,argument4,argument5,16/sprite_get_width(icon),16/sprite_get_height(icon),0,c_white,scr_v3_opacity(actor));
else draw_sprite(argument2,argument3,argument4,argument5);
