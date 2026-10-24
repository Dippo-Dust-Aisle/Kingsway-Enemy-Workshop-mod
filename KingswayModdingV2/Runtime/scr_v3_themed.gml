// The current theme's variant of a Workshop sprite: spr_v3_icon_pin -> spr_v3_icon_pin_dark
// under the Dark theme (also _yellow, _pink). Variants are generated from the game's own
// theme colours, so no runtime recolouring is needed. Falls back to the Light sprite.
var base=argument0;var suffix="";
if(instance_exists(obj_Profile)){
    var name=sprite_get_name(obj_Profile.windowStyles[obj_Profile.currentWindowStyle,0]);
    if(string_pos("Dark",name)>0)suffix="_dark";else if(string_pos("Yellow",name)>0)suffix="_yellow";else if(string_pos("Pink",name)>0)suffix="_pink";
}
var themed=asset_get_index(sprite_get_name(base)+suffix);
if(themed<0 || !sprite_exists(themed))return base;
return themed;
