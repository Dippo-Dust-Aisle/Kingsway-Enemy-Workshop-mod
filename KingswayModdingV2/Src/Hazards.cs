using System;
using System.Linq;
namespace KingswayWorkshop;
public sealed partial class Compiler {
 void ConfigureHazard(Manifest m,Enemy e){
  string obj="gml_Object_"+Obj(m,e.Id);
  Append(obj+"_Create_0","temp=0;readOnly=1;finished=0;trapName=name;");
  Queue(obj+"_Step_1","if(!init){init=1;screen=scr_v3_hazard_window(id);screen.owner=id;screen.hasContents=0;screen.battleOver=0;screen.enemy=id;screen.minimized=0;if(!variable_instance_exists(screen,\"v3_parked\"))screen.button=-4;scr_v3_place_start(screen,id);scr_v2_group(id);v2_components_done=1;script_execute(v2_components_script);}");
  Queue(obj+"_Step_0","scr_v2_hazard_step(id);");
  Append(obj+"_Step_1","if(v2_path!=-4 && (!variable_instance_exists(screen,\"v2_owned_path\") || screen.v2_owned_path<0)){screen.v2_owned_path=path_duplicate(v2_path);path_rescale(screen.v2_owned_path,max(1,global.resolutionW/global.gameScale-screen.width)/386,max(1,global.resolutionH/global.gameScale-screen.height-24)/192);scr_v2_native_path_start(screen,screen.v2_owned_path);}");
  Queue(obj+"_Other_20","exit;");Queue(obj+"_Other_21","exit;");
 }
 void ConfigureMovementAndHazards(){
  // Native minimization owns display coordinates; selecting the window restores
  // its logical movement position without copying animated coordinates to a path.
  Patch("gml_Script_scr_SelectWindow","global.selectedWindow.y = global.selectedWindow.minimizedPos;","global.selectedWindow.y = global.selectedWindow.minimizedPos;\nif(variable_instance_exists(global.selectedWindow,\"v2_motion_x\"))scr_v2_motion_render(global.selectedWindow);");
  var minimizeButton=Existing("gml_Object_obj_MinimizeButton_Step_0");
  Queue("gml_Object_obj_MinimizeButton_Step_0","if(clicked && variable_instance_exists(window,\"enemy\") && instance_exists(window.enemy) && variable_instance_exists(window.enemy,\"v2_enabled\")){z=window.z-1;scr_v2_window_minimize(window);}else{\n"+minimizeButton+"\n}");
  Patch("gml_Script_scr_Draw_Text_ext","draw_set_color(variable_instance_get(id, string(i)));","if(variable_instance_exists(id,string(i)))draw_set_color(variable_instance_get(id,string(i)));else draw_set_color(pc);");
  Queue("gml_Script_scr_BattleText","if(!instance_exists(argument0) || !variable_instance_exists(argument0,\"textLines\")){scr_Log(argument1);return;}\n"+Existing("gml_Script_scr_BattleText"));
  foreach(var type in new[]{"obj_BattleScreen","obj_TrapWindow"}){string destroy="gml_Object_"+type+"_Destroy_0";Queue(destroy,"if(variable_instance_exists(id,\"v2_path_driver\") && instance_exists(v2_path_driver)){with(v2_path_driver){path_end();instance_destroy();}}\n"+Existing(destroy));}
  Append("gml_Object_obj_TrapWindow_Destroy_0","if(variable_instance_exists(id,\"v2_owned_path\") && v2_owned_path>=0){path_end();path_delete(v2_owned_path);}");
  var native=Existing("gml_Object_obj_BattleScreen_Step_1");
  native=native.Replace("__view_get(2, 0)","(global.resolutionW/global.gameScale)").Replace("__view_get(3, 0)","(global.resolutionH/global.gameScale)");
  native=native.Replace("path = path_duplicate(enemy.path);","path = path_duplicate(enemy.path);\npath_rescale(path,max(1,global.resolutionW/global.gameScale-width)/max(1,640-width),max(1,global.resolutionH/global.gameScale-height-24)/max(1,480-height-24));");
  native=native.Replace("if (enemy.path != -4)","if(variable_instance_exists(enemy,\"v2_enabled\"))scr_v3_place_start(id,enemy);\nif (enemy.path != -4)");
  native=native.Replace("path_start(path, 1, 1, 0);","if(variable_instance_exists(enemy,\"v2_enabled\"))scr_v2_native_path_start(id,path);else path_start(path,1,1,0);");
  Queue("gml_Object_obj_BattleScreen_Step_1","scr_v2_native_path_begin(id);\n"+native+"\nscr_v2_native_path_sync(id);");
  foreach(var type in new[]{"obj_BattleScreen","obj_TrapWindow"}){string step="gml_Object_"+type+"_Step_2";Queue(step,"scr_v2_native_path_render(id);\n"+(Existing(step)==""?"event_inherited();":Existing(step)));}
  // Preserve native effects and movement; suppress duplicate removal only during authored creation.
  string black="gml_Object_obj_Trap_BlackFireball_Create_0";
  var source=Existing(black);int index=source.IndexOf("var tempX",StringComparison.Ordinal);
  if(index<0)throw new Exception("Black fireball adapter anchor missing");
  Queue(black,source[..index]+"if(!variable_global_exists(\"v2_spawning_projectile\") || !global.v2_spawning_projectile){"+source[index..]+"}");
  foreach(var obj in SafeHazards){string name="gml_Object_"+obj+"_Create_0";Queue(name,Existing(name).Replace("__view_get(2, 0)","(global.resolutionW/global.gameScale)").Replace("__view_get(3, 0)","(global.resolutionH/global.gameScale)"));}
  Append("gml_Object_obj_Trap_Base_Step_1","if(variable_instance_exists(id,\"v2_placement\") && instance_exists(window) && !v2_placed){v2_placed=1;scr_v2_place(window,v2_placement,v2_x,v2_y);if(v2_outside && object_index!=obj_Trap_Curse){if((object_index==obj_Trap_PoisonDart || object_index==obj_Trap_ThrowingAxe))window.x=global.resolutionW/global.gameScale;else if((object_index==obj_Trap_Icicle || object_index==obj_Trap_Boulder))window.y=-window.height;else if((object_index==obj_Trap_BlackFireball || object_index==obj_Trap_Fireball2))window.y=global.resolutionH/global.gameScale-24;else window.x=-window.width;}}");
  Append("gml_Object_obj_TrapWindow_Step_1","if(instance_exists(owner) && variable_instance_exists(owner,\"v3_button_text\") && instance_exists(button))button.name=string_upper(owner.v3_button_text);");
  // Close/Avoid on a Workshop hazard runs its When closed actions (scr_v3_hazard_closed).
  Append("gml_Object_obj_TrapWindow_Step_1","if(instance_exists(owner) && variable_instance_exists(owner,\"v2_hazard\") && owner.v2_hazard && instance_exists(button))button.script=asset_get_index(\"scr_v3_hazard_closed\");");
  Append("gml_Object_obj_ItemBase_Step_1","if(variable_instance_exists(id,\"v2_custom_name\") && identified){name=v2_custom_name;if(variable_instance_exists(id,\"v2_cursed_name\")){for(var v3_b=0;v3_b<9;v3_b+=1)if(bonus[v3_b,1]<0){name=\"Cursed \"+name;break;}}}");
  Patch("gml_Object_obj_TrapWindow_Draw_0","draw_sprite(owner.sprite_index, owner.image_index, x + (width * 0.5), y + 47);","if(variable_instance_exists(owner,\"v2_hazard\"))scr_v2_portrait(owner,x+width*0.5,y+47,c_white);else draw_sprite(owner.sprite_index,owner.image_index,x+width*0.5,y+47);");
 }
}

