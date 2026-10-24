using System;
namespace KingswayWorkshop;
public sealed partial class Compiler {
 void ConfigureStatusPresentation(){
  Queue("gml_Script_newMessage","if(variable_global_exists(\"v3_status_popup\") && global.v3_status_popup!=\"familyDefault\")return noone;\n"+Existing("gml_Script_newMessage"));
  Patch("gml_Script_newMessage","_nb.messageID = _id;","_nb.messageID = _id;\nscr_v3_popup_track(_nb);");
  Queue("gml_Script_scr_BattleText","if(instance_exists(argument2) && string_pos(\"*BURNED*\",argument1)>0 && variable_instance_exists(argument2,\"v3_burn_popup\") && argument2.v3_burn_popup!=\"familyDefault\")return;\n"+Existing("gml_Script_scr_BattleText"));
  var damage=Existing("gml_Script_scr_DoDamage");damage="var v3_before=0;if(instance_exists(argument0))v3_before=max(0,argument0.currentHealth);\n"+damage;
  damage=damage.Replace("return totalDamage;","if(instance_exists(target))scr_v3_status_hit(target,max(0,v3_before-max(0,target.currentHealth)),damageType);return totalDamage;");Queue("gml_Script_scr_DoDamage",damage);
  game.Data.GameObjects.Add(new(){Name=game.Str("obj_v3_status_hit"),Visible=true});
  Queue("gml_Object_obj_v3_status_hit_Create_0","window=noone;life=.7;icon=-1;iconFrame=0;amount=0;");
  Queue("gml_Object_obj_v3_status_hit_Step_0","life-=delta_time/1000000;if(life<=0 || !instance_exists(window))instance_destroy();");
  Queue("gml_Object_obj_v3_status_hit_Draw_0","if(!instance_exists(window) || window.minimized)exit;var px=window.x+window.width/2;var py=window.y+35-(.7-life)*20;var a=scr_v3_opacity(id)*min(1,life*4);draw_set_alpha(a);if(icon>=0)draw_sprite_ext(icon,iconFrame,px-18,py,14/sprite_get_width(icon),14/sprite_get_height(icon),0,c_white,a);draw_set_font(global.spriteFont);draw_set_color(global.red);draw_text(px,py-7,string(amount));draw_set_alpha(1);");
 }
}
