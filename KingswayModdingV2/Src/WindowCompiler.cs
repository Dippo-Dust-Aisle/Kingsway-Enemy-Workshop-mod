using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Collections.Generic;
using UndertaleModLib.Models;
namespace KingswayWorkshop;
public sealed partial class Compiler {
 void RegisterWindow(Enemy e,Action<string,string> set,StringBuilder registry){
  set("v3_cosmetic",e.Mode=="cosmetic"?"1":"0");set("v3_portrait_size",N(e.Appearance.Size));set("v3_rotation",N(e.Appearance.Rotation));set("v3_draggable",e.Appearance.Draggable?"1":"0");set("v3_layer",Q(e.Appearance.Layer));set("v3_opacity",N(e.Appearance.Opacity));set("v3_trails",e.Appearance.Trails?"1":"0");set("v3_style",e.Mode=="cosmetic"?Q(e.Appearance.CosmeticStyle):"\"\"");set("v3_auto_close",e.Mode=="cosmetic"?N(e.Appearance.AutoClose):"0");set("v3_close_bar",e.Mode=="cosmetic"&&e.Appearance.ShowCloseIndicator?"1":"0");set("v3_sky_portrait",e.Appearance.SkyPortrait&&e.Mode!="cosmetic"?"1":"0");set("v3_button_text",Q(e.Appearance.ButtonText));
  set("v3_start_x",N(e.Movement.StartX));set("v3_start_y",N(e.Movement.StartY));set("v3_random_mirror",e.Movement.RandomMirror?"1":"0");set("v3_legacy_spawn",e.Movement.LegacySpawnOffset?"1":"0");set("v3_drag_entry",Q(e.Movement.DragReturn.Entry));set("v3_drag_speed",N(e.Movement.DragReturn.TransitionSpeed));
  void Meta(List<Waypoint> points){registry.AppendLine("meta=ds_list_create();");foreach(var p in points)registry.AppendLine("ds_list_add(meta,"+string.Join(",",new[]{p.Shape=="arc"?1d:p.Shape=="arcRandom"?2d:0,p.Bend,p.Behavior=="radiusRandom"?1d:0,p.Radius,p.RadiusSpeed,p.LeftSpread,p.RightSpread,p.Rotation,p.Direction=="opposite"?1d:0}.Select(N))+");");}
  Meta(e.Movement.Points);set("v3_point_meta","meta");registry.AppendLine("moves=ds_map_create();");
  foreach(var a in e.Movement.ActionMoves){registry.AppendLine("move=ds_map_create();pts=ds_list_create();");foreach(var p in a.Points)registry.AppendLine("ds_list_add(pts,"+string.Join(",",new[]{p.X,p.Y,p.Duration,p.Wait,p.Variance,p.ControlX,p.ControlY,p.Speed}.Select(N))+");");Meta(a.Points);registry.AppendLine("ds_map_add(move,\"points\",pts);ds_map_add(move,\"meta\",meta);ds_map_add(move,\"mode\","+Q(a.Mode)+");ds_map_add(move,\"entry\","+Q(a.Entry)+");ds_map_add(move,\"speed\","+N(a.TransitionSpeed)+");ds_map_add(moves,"+Q(a.Id)+",move);");}
  set("v3_moves","moves");
 }
 void PrepareCosmetics(){
  var cosmetic=new UndertaleGameObject{Name=game.Str("obj_v3_cosmetic"),Visible=false};game.Data.GameObjects.Add(cosmetic);
  Queue("gml_Object_obj_v3_cosmetic_Create_0",game.Source("gml_Object_obj_Enemy_Create_0")+"\ntemp=0;readOnly=1;v3_active=0;");
  Queue("gml_Object_obj_v3_cosmetic_Step_1","scr_v3_cosmetic_step(id);");
  Queue("gml_Object_obj_v3_cosmetic_Step_0","if(instance_exists(screen) && scr_v3_group_alive(scr_v2_group(id))>0){script_execute(v2_periodic_script,id,global.player,screen);scr_v2_move(id);}");
  Queue("gml_Object_obj_v3_cosmetic_Destroy_0","scr_v3_gone(id);if(instance_exists(screen))with(screen)instance_destroy();if(ds_exists(loot,ds_type_list))ds_list_destroy(loot);if(variable_instance_exists(id,\"v2_cooldowns\"))ds_map_destroy(v2_cooldowns);if(variable_instance_exists(id,\"v2_toggles\"))ds_map_destroy(v2_toggles);");
  var parent=game.Data.GameObjects.First(x=>x.Name.Content=="obj_Window");game.Data.GameObjects.Add(new(){Name=game.Str("obj_v3_cosmetic_window"),ParentId=parent,Sprite=parent.Sprite,Visible=true});
  Queue("gml_Object_obj_v3_cosmetic_window_Create_0","event_inherited();closeable=0;minimizable=0;resizable=0;hasContents=0;hasSurface=0;hasScrollBarV=0;hasStartBarButton=0;battleOver=0;enemy=noone;regionColor=global.grey;icon=-1;");
  Queue("gml_Object_obj_v3_cosmetic_window_Draw_0","y=floor(y);event_inherited();if(instance_exists(enemy))scr_v2_portrait(enemy,x+8+enemy.v3_portrait_size/2,y+21+enemy.v3_portrait_size/2,c_white);if(instance_exists(enemy))scr_v3_close_bar(id,enemy);");
  Queue("gml_Object_obj_v3_cosmetic_window_Destroy_0","if(variable_instance_exists(id,\"v2_path_driver\") && instance_exists(v2_path_driver))with(v2_path_driver){path_end();instance_destroy();}if(variable_instance_exists(id,\"v2_owned_path\"))path_delete(v2_owned_path);event_inherited();");
  Queue("gml_Object_obj_v3_cosmetic_window_Step_2","event_inherited();scr_v2_native_path_render(id);");
 }
 void ConfigurePresentation(){
  // Every native drawable gets the same window alpha, including separately
  // drawn controls. Explicit-alpha drawing calls must also obey it.
  // Title-bar drag/pin icons and the draggable outline. The outline is drawn every
  // frame (it animates), inside the window's own Draw so it follows opacity and trails.
  // Title icons and Canon/Alt frames, plus generated Dark/Yellow/Pink variants
  // (scr_v3_themed picks the one matching the current window theme).
  foreach(var theme in new[]{"","_dark","_yellow","_pink"}){
   foreach(var file in new[]{"drag","pin","lock","pin_blue","count1","count2","count3"})game.AddSprite("spr_v3_icon_"+file+theme,Path.Combine(root,"Web","icons",file+theme+".png"));
   foreach(var file in new[]{"canon","alt"})game.AddSprite("spr_v3_cosmetic_"+file+theme,Path.Combine(root,"Web","cosmetic",file+theme+".png"));
  }
  game.AddSprite("spr_v3_cosmetic_icon",Path.Combine(root,"Web","cosmetic","title_icon.png"));
  Append("gml_Object_obj_Window_Draw_0","scr_v3_marching(id);");
  // Pressing a hazard's Close/Avoid button no longer raises the hazard window first
  // (vanilla selects it), so closing several hazards quickly does not flash.
  Patch("gml_Object_obj_BaseInterface_Other_25","        scr_SelectWindow(window);","        if(window.object_index!=obj_TrapWindow)scr_SelectWindow(window);");
  // "NEW MESSAGE" notifications (bottom right) sit below every window instead of above them
  // (z -900); still above desktop icons and Always behind windows (z -2).
  Append("gml_Object_obj_Notification_Create_0","z=-4;");
  // obj_Loader is the first instance created (rm_Load), before anything draws.
  Queue("gml_Object_obj_Loader_Create_0","global.v3_dim_count=0;global.v3_behind_count=0;\n"+Existing("gml_Object_obj_Loader_Create_0"));
  Patch("gml_Object_obj_Window_Step_1","draw_sprite(652, icon, 2, 2);","if(icon>=0)draw_sprite(652, icon, 2, 2);");
  foreach(var code in game.Data.Code.Where(c=>c.Name.Content.StartsWith("gml_Object_")&&c.Name.Content.EndsWith("_Draw_0")).Select(c=>c.Name.Content).Concat(new[]{"gml_Object_obj_v3_cosmetic_window_Draw_0"}).Distinct().ToArray()){
   string source=Existing(code);source=ScaleAlphaCalls(source).Replace("event_inherited();","event_inherited();draw_set_alpha("+Dim+");").Replace("action_inherited();","action_inherited();draw_set_alpha("+Dim+");");
   // Windows draw normally; trails sample them afterwards (scr_v3_trail_sample).
   Queue(code,"draw_set_alpha("+Dim+");\n"+source+"\ndraw_set_alpha(1);"+(IsWindowCode(code)?"scr_v3_trail_sample(id);":""));
  }
  foreach(var code in game.Data.Code.Where(c=>c.Name.Content.StartsWith("gml_Object_")&&c.Name.Content.Contains("_Mouse_")).Select(c=>c.Name.Content).ToArray())Queue(code,"if(global.v3_behind_count>0)if(scr_v3_click_through(id))exit;\n"+Existing(code));
  Append("gml_Object_obj_BaseInterface_Step_2","if(global.v3_behind_count>0)if(scr_v3_click_through(id)){hover=0;pressed=0;clicked=0;}");
  // Non-draggable windows still get the native press (select + bring to front); only the drag is blocked.
  Queue("gml_Object_obj_Window_Mouse_53","if(variable_instance_exists(id,\"v3_actor\") && v3_actor && scr_v3_on_icon(id,\"pin\"))exit;\n"+Existing("gml_Object_obj_Window_Mouse_53")+"\nif(moving){if(scr_v3_can_drag(id))scr_v3_drag_begin(id);else moving=0;}");
  // Selecting a pinned window makes it the highest pinned window.
  Queue("gml_Script_scr_SelectWindow","if(scr_v3_click_through(argument0))return argument0;\nvar v3_pick=instance_find(argument0,0);if(instance_exists(v3_pick) && scr_v3_pinned(v3_pick))scr_v3_raise_top(v3_pick);\n"+Existing("gml_Script_scr_SelectWindow"));
  Append("gml_Object_obj_Window_Step_2","scr_v3_layer_pass();scr_v3_window_step(id);");
  Queue("gml_Object_obj_Window_Step_1","var v3_repaint=updateWindowSurface;\n"+Existing("gml_Object_obj_Window_Step_1")+"\nif(v3_repaint)scr_v3_decorate(id);");
  Append("gml_Object_obj_Window_Destroy_0","if(variable_instance_exists(id,\"v3_snapshot\") && surface_exists(v3_snapshot))surface_free(v3_snapshot);if(variable_instance_exists(id,\"v3_children\"))ds_list_destroy(v3_children);with(obj_v3_ghost){if(owner==other.id)instance_destroy();}");
  // A parked hazard window (scr_v3_hazard_park) already left the taskbar and window list;
  // re-register it so the native Destroy bookkeeping below stays balanced.
  Queue("gml_Object_obj_Window_Destroy_0","if(variable_instance_exists(id,\"v3_parked\") && v3_parked){v3_parked=0;global.windowsCount+=1;windowIndex=global.windowsCount-1;if(instance_exists(obj_DesktopControler))ds_list_add(obj_DesktopControler.windows,id);if(variable_global_exists(\"v3_hazard_pool\")){var v3_at=ds_list_find_index(global.v3_hazard_pool,id);if(v3_at>=0)ds_list_delete(global.v3_hazard_pool,v3_at);}}\n"+Existing("gml_Object_obj_Window_Destroy_0"));
  game.Data.GameObjects.Add(new(){Name=game.Str("obj_v3_ghost"),Visible=true});
  Queue("gml_Object_obj_v3_ghost_Create_0","owner=noone;image=-1;life=.18;global.v3_ghost_count+=1;");
  Queue("gml_Object_obj_v3_ghost_Step_0","life-=delta_time/1000000;if(life<=0 || !instance_exists(owner))instance_destroy();else depth=owner.depth+1;");
  Queue("gml_Object_obj_v3_ghost_Draw_0","scr_v3_draw_premultiplied(image,x,y,max(0,life/.18)*.32*opacity);");
  Queue("gml_Object_obj_v3_ghost_Destroy_0","if(surface_exists(image))surface_free(image);global.v3_ghost_count=max(0,global.v3_ghost_count-1);");
 }
 // True for gml_Object_X_Draw_0 when X is obj_Window or descends from it.
 bool IsWindowCode(string code){string name=code["gml_Object_".Length..^"_Draw_0".Length];var o=game.Data.GameObjects.FirstOrDefault(x=>x.Name.Content==name);for(int guard=0;o!=null&&guard<32;guard++){if(o.Name.Content=="obj_Window")return true;o=o.ParentId;}return false;}
 // Window opacity factor for wrapped draw calls. The script call is skipped unless some
 // v3 window is dimmed (opacity < 10), which is almost never, so ordinary drawables pay
 // only a global read. global.v3_dim_count / v3_behind_count: scr_v3_window_counts.
 const string Dim="(global.v3_dim_count>0?scr_v3_opacity(id):1)";
 static string ScaleAlphaCalls(string source){foreach(string name in new[]{"draw_sprite_ext","draw_sprite_part_ext","draw_sprite_stretched_ext","draw_surface_ext","draw_surface_part_ext","draw_set_alpha"}){int start=0;while((start=source.IndexOf(name+"(",start,StringComparison.Ordinal))>=0){int begin=start+name.Length+1,depth=1,last=begin,end=begin;bool quoted=false;for(;end<source.Length;end++){char c=source[end];if(c=='"'&&(end==0||source[end-1]!='\\'))quoted=!quoted;if(quoted)continue;if(c=='(')depth++;if(c==')')depth--;if(c==')'&&depth==0)break;if(c==','&&depth==1)last=end+1;}if(end>=source.Length)break;string arg=source[last..end];string replacement="("+arg+")*"+Dim;source=source[..last]+replacement+source[end..];start=last+replacement.Length+1;}}return source;}

}
