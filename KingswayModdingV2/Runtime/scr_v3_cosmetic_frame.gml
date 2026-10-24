// Draws a Canon/Alt cosmetic frame (86 x 96 at portrait 68, shadow included)
// stretched to the window size. Column 30 and row 50 are uniform, so they are
// the only stretched strips; every corner, edge and the title boxes stay crisp.
var win=argument0;var spr=spr_v3_cosmetic_canon;if(win.v3_style=="alt")spr=spr_v3_cosmetic_alt;spr=scr_v3_themed(spr);
var ex=max(0,win.width-86);var ey=max(0,win.height-96);
draw_clear_alpha(c_black,0);
draw_sprite_part(spr,0,0,0,30,50,0,0);
draw_sprite_part(spr,0,31,0,55,50,31+ex,0);
draw_sprite_part(spr,0,0,51,30,45,0,51+ey);
draw_sprite_part(spr,0,31,51,55,45,31+ex,51+ey);
draw_sprite_part_ext(spr,0,30,0,1,50,30,0,ex+1,1,c_white,1);
draw_sprite_part_ext(spr,0,30,51,1,45,30,51+ey,ex+1,1,c_white,1);
draw_sprite_part_ext(spr,0,0,50,30,1,0,50,1,ey+1,c_white,1);
draw_sprite_part_ext(spr,0,31,50,55,1,31+ex,50,1,ey+1,c_white,1);
draw_sprite_part_ext(spr,0,30,50,1,1,30,50,ex+1,ey+1,c_white,1);
// Title: icon and black text, no stripes.
draw_sprite(spr_v3_cosmetic_icon,0,2+sprite_get_xoffset(spr_v3_cosmetic_icon),2+sprite_get_yoffset(spr_v3_cosmetic_icon));
draw_set_font(global.spriteFont);draw_set_valign(0);draw_set_halign(0);
var text=win.titleText+win.extraTitleText;var cut=0;
while(string_length(text)>0 && string_width(string_hash_to_newline(text))>win.width-64){text=string_delete(text,string_length(text),1);cut=1;}
if(cut)text+="...";
draw_set_color(global.black);draw_text(22,2,string_hash_to_newline(text));
