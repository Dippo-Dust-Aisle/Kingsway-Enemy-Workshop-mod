using System;
using System.IO;
using System.Linq;
using System.Text;
namespace KingswayWorkshop;
public sealed partial class Compiler {
 void InstrumentFight(){
  Queue("gml_Script_scr_v3_fight_command","if(global.v3_fight_command_file!=\"\" && file_exists(global.v3_fight_command_file)){var f=file_text_open_read(global.v3_fight_command_file);var command=file_text_read_string(f);file_text_close(f);if(command==global.v3_fight_command_token+\":death\")global.v3_fight_death_requested=1;}if(global.v3_fight_die_on_ready && global.v2_fight_stage==3 && global.v2_fight_frames>=global.v2_fight_ready_frame+30)global.v3_fight_death_requested=1;if(global.v3_fight_death_requested && instance_exists(global.player))global.player.currentHealth=0;");
  if(Fight.Mode!="level"&&Fight.Mode!="random")throw new Exception("Choose Level Test or Random Fight");
  foreach(var pair in new[]{("test.displayWidth",(double)Fight.DisplayWidth),("test.displayHeight",(double)Fight.DisplayHeight),("test.gameScale",(double)Fight.GameScale),("test.quickness",Fight.Quickness??1)}){var error=Limits.Check(pair.Item1,pair.Item2);if(error!="")throw new Exception(error);}if(!new[]{.3,.5,.75,1,1.15,1.3,1.45}.Contains(Fight.ScreenMovement))throw new Exception("Choose a native Screen Movement setting");
  if(Fight.Level<1||Fight.Level>25)throw new Exception("Fight level must be between 1 and 25");
  game.Data.GeneralInfo.Name=game.Str("KingswayWorkshopV2Fight");game.Data.GeneralInfo.FileName=game.Str("KingswayWorkshopV2Fight");game.Data.GeneralInfo.DisplayName=game.Str("Kingsway — playable enemy test");game.Data.GeneralInfo.SteamAppID=0;
  game.Data.Options.Info &= ~(UndertaleModLib.Models.UndertaleOptions.OptionsFlags.FullScreen|UndertaleModLib.Models.UndertaleOptions.OptionsFlags.ChangeResolution);
  game.Data.GeneralInfo.Info &= ~UndertaleModLib.Models.UndertaleGeneralInfo.InfoFlags.Fullscreen;
  if(Fight.Fullscreen){game.Data.Options.Info |= UndertaleModLib.Models.UndertaleOptions.OptionsFlags.FullScreen;game.Data.GeneralInfo.Info |= UndertaleModLib.Models.UndertaleGeneralInfo.InfoFlags.Fullscreen;}
  game.Data.GeneralInfo.DefaultWindowWidth=(uint)Fight.DisplayWidth;game.Data.GeneralInfo.DefaultWindowHeight=(uint)Fight.DisplayHeight;
  // Keep the selected logical render area while the native fullscreen window fills the desktop.
  Patch("gml_Script_scr_SetCameraView","_w = display_get_width();","_w = global.resolutionW;");
  Patch("gml_Script_scr_SetCameraView","_h = display_get_height();","_h = global.resolutionH;");
  Queue("gml_Object_obj_Profile_Other_10","exit;");Queue("gml_Object_obj_Profile_Other_11","exit;");Queue("gml_Object_obj_BootScreen_Step_0","window_set_fullscreen(global.v2_fight_fullscreen);room_goto(rm_PlayerCreate);");
  string classes="choose(\"Adventurer\",\"Warrior\",\"Mage\",\"Rogue\",\"Beastkin\",\"Ascended\",\"Demonblood\",\"Worthless\",\"Necromancer\")";
  var loader=Existing("gml_Object_obj_Loader_Create_0").Replace("scr_LoadSounds();","global.resolutionW="+Fight.DisplayWidth+";global.resolutionH="+Fight.DisplayHeight+";global.gameScale="+Fight.GameScale+";global.windowed="+(Fight.Fullscreen?0:1)+";if(global.resolutionW>display_get_width() || global.resolutionH>display_get_height()){global.resolutionW=display_get_width();global.resolutionH=display_get_height();show_debug_message(\"WORKSHOP: display preset exceeds desktop; using desktop size\");}if(global.resolutionH/global.gameScale<360 || global.resolutionW/global.gameScale<640){global.gameScale=max(1,min(floor(global.resolutionH/360),floor(global.resolutionW/640)));show_debug_message(\"WORKSHOP: reduced scale so important windows fit\");}scr_LoadSounds();");
  Queue("gml_Object_obj_BootScreen_Alarm_1","window_set_fullscreen(global.v2_fight_fullscreen);");
  loader+="\nwindow_set_fullscreen(global.v2_fight_fullscreen);";
  Append("gml_Object_obj_Player_Other_11","global.setting_enemyMoveSpeed="+N(Fight.ScreenMovement)+";"+(Fight.Quickness.HasValue?"quickness="+N(Fight.Quickness.Value)+";":""));
  Queue("gml_Object_obj_Loader_Create_0","global.v3_fight_death_requested=0;global.v3_fight_die_on_ready="+(Fight.DieOnReady?"1":"0")+";global.v3_fight_random_music="+(Fight.RandomMusic?"1":"0")+";global.v3_fight_music_state=0;global.v3_fight_music_window=-4;global.v3_fight_music_frame=0;global.v3_fight_command_file="+Q(Fight.CommandFile.Replace('\\','/'))+";global.v3_fight_command_token="+Q(Fight.CommandToken)+";global.v2_fight_fullscreen="+(Fight.Fullscreen?"1":"0")+";global.v2_fight_requested_w="+Fight.DisplayWidth+";global.v2_fight_requested_h="+Fight.DisplayHeight+";global.v2_fight_display_room=-1;global.v2_fight_stage=0;global.v2_fight_frames=0;global.v2_fight_looted=0;global.v2_fight_corpses=ds_list_create();global.v2_fight_level="+Fight.Level+";global.v2_fight_mode="+Q(Fight.Mode)+";global.v2_fight_class="+(Fight.ClassOverride!=""?Q(Fight.ClassOverride):Fight.Mode=="random"?classes:Q("Mage"))+";var log=file_text_open_write(\"v2-fight.txt\");file_text_close(log);\n"+loader);
  foreach(var f in Directory.GetFiles(Path.Combine(root,"Tests","Fight"),"*.gml"))if(!f.EndsWith("scr_v2_fight_verify.gml"))Queue("gml_Script_"+Path.GetFileNameWithoutExtension(f),File.ReadAllText(f).Replace("__ENEMY__",PreviewEnemy));
  var gear=new StringBuilder("var kind=argument0;var candidates=ds_list_create();var fallback=ds_list_create();\n");
  foreach(var item in catalog.Objects.Where(x=>x.Kind=="item"&&x.Object!="obj_ItemBase"&&x.Object!="obj_BlockedOffhand"&&Enchantments.Supported(x)&&Enchantments.Value(x,"unique")!="1")){
   bool numeric=true;string Conditions(string field,string target){if(!double.TryParse(Enchantments.Value(item,field),System.Globalization.NumberStyles.Float,System.Globalization.CultureInfo.InvariantCulture,out double n)){numeric=false;return "false";}return target+">="+N(n);}
   string req=Conditions("requiredLevel","global.player.level")+" && "+Conditions("requiredStrength","global.player.strength")+" && "+Conditions("requiredAgility","global.player.agility")+" && "+Conditions("requiredIntelligence","global.player.intelligence");
   if(numeric){gear.AppendLine("if(kind=="+Q(Enchantments.Value(item,"itemType"))+" && "+req+")ds_list_add(candidates,"+item.Object+");");gear.AppendLine("if(kind=="+Q(Enchantments.Value(item,"itemType"))+" && global.player.level>="+Enchantments.Value(item,"requiredLevel")+")ds_list_add(fallback,"+item.Object+");");}
  }
  gear.AppendLine("if(ds_list_size(candidates)==0)ds_list_copy(candidates,fallback);ds_list_destroy(fallback);if(ds_list_size(candidates)==0){ds_list_destroy(candidates);scr_v2_fight_finish(\"No equipment available for \"+kind);return noone;}var obj=ds_list_find_value(candidates,irandom(ds_list_size(candidates)-1));ds_list_destroy(candidates);var item=instance_create_depth(-9000,-9000,0,obj);item.identified=1;ds_list_add(global.player.contents,item);return item;");Queue("gml_Script_scr_v2_fight_gear",gear.ToString());
  Queue("gml_Script_scr_Escape","scr_v2_fight_finish(\"escaped\");");
  // Playable tests: "NEW MESSAGE" notifications fade out at once, silently.
  Append("gml_Object_obj_Notification_Create_0","alertSound=0;goAway=1;alpha=.04;visible=0;");
  // With the tutorial off, the quest controller opens the Quests window on its first step;
  // skip only that, so the Quests window still opens from the desktop or Start menu.
  Patch("gml_Object_obj_QuestController_Step_2","alarm[2] = 10;","");
  Append("gml_Object_obj_Enemy_Other_21","var lootNames=\"\";for(var li=0;li<ds_list_size(loot);li+=1){var lootItem=ds_list_find_value(loot,li);if(instance_exists(lootItem))lootNames+=lootItem.name+\"; \";}scr_v2_fight_log(\"LOOT \"+name+\" (\"+object_get_name(object_index)+\"): \"+lootNames);global.v2_fight_looted=1;if(ds_list_size(loot)>0 && instance_exists(corpse)){ds_list_add(global.v2_fight_corpses,corpse);corpse.v2_fight_window=corpseWindow;}");
  Queue("gml_Script_scr_GameOver","if(instance_exists(global.player) && global.player.currentHealth<=0){scr_v2_fight_log(\"DEATH PRESENTATION: \"+string(global.player.deadTimer)+\" native frames\");scr_v2_fight_finish(global.v3_fight_death_requested?\"intentional player death\":\"defeated\");exit;}\n"+game.Source("gml_Script_scr_GameOver"));
  Append("gml_Object_obj_DesktopControler_Step_0","if(global.v2_fight_frames mod 15==0)scr_v3_fight_command();scr_v2_fight_step();");
  if(Fight.Verify!=""){Queue("gml_Script_scr_v2_fight_verify",File.ReadAllText(Path.Combine(root,"Tests","Fight","scr_v2_fight_verify.gml")).Replace("__VERIFY__",Q(Fight.Verify)));Append("gml_Object_obj_DesktopControler_Step_0","scr_v2_fight_verify();");}
 }
}
