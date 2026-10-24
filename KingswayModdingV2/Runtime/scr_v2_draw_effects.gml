var actor=argument0;var px=argument1;var py=argument2;
if(variable_instance_exists(actor,"v2_effects")){
    var key=ds_map_find_first(actor.v2_effects);
    while(!is_undefined(key)){
        var effect=ds_map_find_value(actor.v2_effects,key);
        var icon=ds_list_find_value(effect,2);
        if(icon>=0)draw_sprite_ext(icon,0,px,py,16/sprite_get_width(icon),16/sprite_get_height(icon),0,c_white,1);
        else {draw_set_color(c_purple);draw_rectangle(px-7,py-7,px+7,py+7,0);draw_set_color(c_white);draw_text(px,py-6,string_char_at(ds_list_find_value(effect,0),1));}
        px-=18;key=ds_map_find_next(actor.v2_effects,key);
    }
}
