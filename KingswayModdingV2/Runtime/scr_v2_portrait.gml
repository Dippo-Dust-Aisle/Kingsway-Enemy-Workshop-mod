var actor=argument0;var fitW=68;var fitH=68;var rotation=0;var cosmetic=0;
if(variable_instance_exists(actor,"v3_cosmetic")){cosmetic=actor.v3_cosmetic;rotation=actor.v3_rotation;if(cosmetic){fitW=actor.v3_portrait_size;fitH=fitW;}}
// Sky Monster portrait: the native Shadow fits 97 x 99 and bleeds past the 68 x 68 frame.
if(!cosmetic && variable_instance_exists(actor,"v3_sky_portrait") && actor.v3_sky_portrait){fitW=97;fitH=99;}
var sw=sprite_get_width(actor.sprite_index);var sh=sprite_get_height(actor.sprite_index);var rotated=(rotation mod 180)!=0;
var scale=min(fitW/(rotated?sh:sw),fitH/(rotated?sw:sh));
if(cosmetic){if(scale>=1)scale=max(1,floor(scale));}else scale=min(1,scale);
var dx=(sprite_get_xoffset(actor.sprite_index)-sw/2)*scale;var dy=(sprite_get_yoffset(actor.sprite_index)-sh/2)*scale;
var px=argument1+dx*dcos(rotation)-dy*dsin(rotation);var py=argument2+dx*dsin(rotation)+dy*dcos(rotation);
// Whole-pixel placement keeps the portrait locked to the frame while the window moves.
if(cosmetic){px=floor(px);py=floor(py);}
draw_sprite_ext(actor.sprite_index,actor.image_index,px,py,scale,scale,-rotation,argument3,(argument_count>4?argument4:scr_v3_opacity(actor)));
