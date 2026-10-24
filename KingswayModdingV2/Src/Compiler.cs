using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Globalization;
using System.Collections.Generic;
using UndertaleModLib.Models;
using UndertaleModLib.Compiler;
namespace KingswayWorkshop;
public sealed partial class Compiler {
 public static readonly string[] SafeHazards={"obj_Trap_Fireball","obj_Trap_Arrow","obj_Trap_Boulder","obj_Trap_BlackFireball","obj_Trap_Curse","obj_Trap_Icicle","obj_Trap_PoisonDart","obj_Trap_MagicArrow","obj_Trap_ThrowingAxe","obj_Trap_Fireball2"};
 readonly Game game; readonly Catalog catalog;readonly string root;readonly Dictionary<string,string> queued=new(StringComparer.Ordinal);int nodeIndex;
 public string PreviewEnemy="";
 public FightOptions Fight;
 public Compiler(Game game,Catalog catalog,string root){this.game=game;this.catalog=catalog;this.root=root;}
 public static string Q(string s)=>"\""+s.Replace("\\","\\\\").Replace("\"","\\\"").Replace("\r","\\r").Replace("\n","\\n")+"\"";
 // GML has no exponent literals, so small or large numbers are written out in full ("1E-06" does not compile).
 public static string N(double v)=>v.ToString("0.###############",CultureInfo.InvariantCulture);
 public static string Obj(Manifest m,string id)=>"obj_v2_"+m.Id+"_"+id;
 static string Script(Manifest m,Enemy e,string suffix)=>"scr_v2m_"+m.Id+"_"+e.Id+"_"+suffix;
 string Image(Manifest m,string image)=>m.Assets.ContainsKey(image)?"spr_v2_"+m.Id+"_"+image:image==""?"-1":image;
 public void Queue(string n,string src){
  // Use the legacy runner's explicit DS functions, including global map writes.
  const string accessor=@"([A-Za-z0-9_.]+)\[\?(""[^""]*""|[A-Za-z0-9_.]+)\]";
  src=System.Text.RegularExpressions.Regex.Replace(src,accessor+@"\s*=(?!=)([^;]+);", "ds_map_replace($1,$2,$3);");
  src=System.Text.RegularExpressions.Regex.Replace(src,accessor,"ds_map_find_value($1,$2)");
  src=System.Text.RegularExpressions.Regex.Replace(src,@"([A-Za-z0-9_.]+)\[\|([^\]\r\n]+)\]","ds_list_find_value($1,$2)");
  queued[n]=src;
 }
 string Existing(string n)=>queued.TryGetValue(n,out var s)?s:game.Source(n);
 void Patch(string name,string old,string replacement){string src=Existing(name);if(!src.Contains(old))throw new Exception("Unsupported code anchor in "+name+": "+old);Queue(name,src.Replace(old,replacement));}
 void Append(string name,string src)=>Queue(name,Existing(name)+"\n"+src);
 public object Build(List<Manifest> input,string output,bool test=false){
  var mods=input.Select(Revision.Runtime).OrderBy(x=>x.LoadOrder).ThenBy(x=>x.Id,StringComparer.Ordinal).ToList();var errors=Validation.Check(mods,catalog);if(errors.Count>0)throw new Exception(Json.Text(new{errors}));
  var inputDigests=mods.SelectMany(m=>Directory.GetFiles(m.Directory,"*",SearchOption.AllDirectories)).Distinct().ToDictionary(p=>p,Game.Hash);
  foreach(var f in Directory.GetFiles(Path.Combine(root,"Runtime"),"*.gml").Order(StringComparer.Ordinal))Queue("gml_Script_"+Path.GetFileNameWithoutExtension(f),File.ReadAllText(f));
  PrepareAudio(mods);PrepareCosmetics();Append("gml_Script_scr_v2_init","global.v3_menu_trails="+(mods.Any(m=>m.MenuTrails)?"1":"0")+";");
  var registry=new StringBuilder("var cfg; var pts;var meta;var moves;var move;\n");var registration=new StringBuilder();
  game.Data.GameObjects.Add(new UndertaleGameObject{Name=game.Str("obj_v2_path_driver"),Visible=false});
  Queue("gml_Object_obj_v2_path_driver_Create_0","v2_window=noone;");
  Queue("gml_Object_obj_v2_path_driver_Step_0","if(!instance_exists(v2_window)){path_end();instance_destroy();}");
  var parent=game.Data.GameObjects.First(x=>x.Name.Content=="obj_Enemy");
  foreach(var m in mods){foreach(var a in m.Assets.OrderBy(x=>x.Key,StringComparer.Ordinal))game.AddSprite(Image(m,a.Key),Validation.Within(m.Directory,a.Value));
   foreach(var e in m.Enemies.OrderBy(x=>x.Id,StringComparer.Ordinal)){
    var o=new UndertaleGameObject{Name=game.Str(Obj(m,e.Id)),ParentId=e.Mode=="cosmetic"?game.Data.GameObjects.First(x=>x.Name.Content=="obj_v3_cosmetic"):parent,Sprite=game.Data.Sprites.First(x=>x.Name.Content==Image(m,e.Image)),Visible=e.Mode!="cosmetic"};game.Data.GameObjects.Add(o);
    string key=m.Id+":"+e.Id;registry.AppendLine("cfg=ds_map_create();");void Set(string n,string value)=>registry.AppendLine("ds_map_add(cfg,"+Q(n)+","+value+");");
    RegisterWindow(e,Set,registry);Set("v2_spawn_sound",Q(AudioKey(m,e.SpawnSound)));Set("v3_spawn_pitch",e.SpawnPitchVariance?"1":"0");Set("v2_music",Q(AudioKey(m,e.Music)));Set("v2_object",Obj(m,e.Id));Set("v2_hazard",e.Mode=="hazard"?"1":"0");Set("v2_activation",N(e.ActivationSeconds));Set("v2_start_mode",Q(e.Movement.StartMode));Set("v2_move_shape",Q(e.Movement.Shape));Set("v2_move_bend",N(e.Movement.Bend));Set("v2_use_game_speed",e.Movement.UseGameSpeed?"1":"0");Set("v2_game_speed",N(e.Movement.GameSpeed));Set("name",Q(e.Name));Set("description",Q(e.Description));Set("type",Q(e.Type));Set("rank",Q(e.Rank));Set("sprite_index",Image(m,e.Image));Set("v2_key",Q(key));
    foreach(var pair in JsonSerializer.SerializeToElement(e.Stats,Json.Options).EnumerateObject())Set(pair.Name,pair.Value.GetRawText());foreach(var pair in JsonSerializer.SerializeToElement(e.Advanced,Json.Options).EnumerateObject())Set(pair.Name,pair.Value.GetRawText());
    Set("v2_attack_script",Script(m,e,"attack"));Set("v2_periodic_script",Script(m,e,"periodic"));Set("v2_attacked_script",Script(m,e,"attacked"));Set("v2_loot_script",Script(m,e,"loot"));Set("v2_components_script",Script(m,e,"components"));Set("v3_variable_script",Script(m,e,"variable"));if(e.WhenGone.Count>0)Set("v3_gone_script",Script(m,e,"gone"));Set("v2_path",e.Movement.Profile==""?"-4":e.Movement.Profile);
    double nativeSpeed=1;var user=catalog.Paths.FirstOrDefault(x=>x.Name==e.Movement.Profile)?.Users.FirstOrDefault();var refObj=catalog.Objects.FirstOrDefault(x=>x.Object==user);if(refObj!=null&&refObj.Fields.TryGetValue("pathSpeed",out var speed))nativeSpeed=NumberValue(speed.Value,1);
    Set("v2_path_speed",N(nativeSpeed*e.Movement.Intensity/100));Set("v2_move_intensity",N(e.Movement.Intensity/100));Set("v2_move_loop",N(e.Movement.LoopStart-1));Set("v2_move_mode",Q(e.Movement.Interpolation));Set("v2_move_boundary",Q(e.Movement.Boundary));Set("v2_pause_attack",e.Movement.PauseAttacking?"1":"0");Set("v2_pause_stun",e.Movement.PauseStunned?"1":"0");Set("v2_pause_minimized",e.Movement.PauseMinimized?"1":"0");Set("v2_pause_dead",e.Movement.PauseDead?"1":"0");
    registry.AppendLine("pts=ds_list_create();");foreach(var p in e.Movement.Points)registry.AppendLine("ds_list_add(pts,"+string.Join(",",new[]{p.X,p.Y,p.Duration,p.Wait,p.Variance,p.ControlX,p.ControlY,p.Speed}.Select(N))+");");Set("v2_points","pts");registry.AppendLine("ds_map_add(global.v2_registry,"+Q(key)+",cfg);");
    Queue("gml_Object_"+Obj(m,e.Id)+"_Create_0","event_inherited();\nscr_v2_apply("+Q(key)+");");
    Queue("gml_Object_"+Obj(m,e.Id)+"_Other_10","if(currentHealth>0 && instance_exists(global.player) && global.player.currentHealth>0 && instance_exists(screen) && !screen.battleOver){attackReady=0;script_execute(v2_attack_script,id,global.player,screen);}");
    string preamble="var actor=argument0;var victim=argument1;var window=argument2;var damage=0;var drained=0;\n";Queue("gml_Script_"+Script(m,e,"attack"),preamble+Sequence(m,e,e.Actions,"actions")+(e.AdvancedGml==""?"":"\n"+File.ReadAllText(Validation.Within(m.Directory,e.AdvancedGml))));
    Queue("gml_Script_"+Script(m,e,"attacked"),"var actor=argument0;var victim=argument1;var window=argument2;var damage=argument3;var blocked=argument4;var drained=0;\n"+Sequence(m,e,e.WhenAttacked,"whenAttacked"));
    if(e.Mode=="hazard")ConfigureHazard(m,e);
    Queue("gml_Script_"+Script(m,e,"periodic"),preamble+Sequence(m,e,e.Periodic,"periodic"));Queue("gml_Script_"+Script(m,e,"variable"),VariableHandler(m,e));if(e.WhenGone.Count>0)Queue("gml_Script_"+Script(m,e,"gone"),GoneHandler(m,e));Queue("gml_Script_"+Script(m,e,"loot"),LootCode(e));
    var components=new StringBuilder();foreach(var c in e.Components)components.AppendLine("scr_v2_spawn(id,"+Obj(m,c.Enemy)+","+Q(c.Role)+","+N(c.DeathAction.Amount)+","+(c.DeathAction.Percent?"1":"0")+");");Queue("gml_Script_"+Script(m,e,"components"),components.ToString());
    foreach(var enc in e.Encounters.OrderBy(x=>x.Pool,StringComparer.Ordinal))registration.AppendLine("scr_v2_register("+enc.Pool+","+Obj(m,e.Id)+","+N(enc.Weight)+");");
   }
   foreach(var p in m.Patches)Queue(p.Code,File.ReadAllText(Validation.Within(m.Directory,p.Source)));
  }
  Queue("gml_Script_scr_v2_registry",registry.ToString());Queue("gml_Script_scr_v2_pools",registration.ToString());
  Append("gml_Object_obj_EnemyTable_Create_0","scr_v2_init();\nscr_v2_pools();");
  Patch("gml_Script_scr_GetNewEnemy","enemyType = ds_list_find_value(table, _rand);","enemyType = scr_v2_pick(table);");
  Append("gml_Object_obj_DesktopControler_Step_1","scr_v2_clock();");
  Append("gml_Object_obj_DesktopControler_Step_0","scr_v2_tick();");
  Append("gml_Object_obj_Enemy_Step_1","if(variable_instance_exists(id,\"v2_enabled\")){if(!variable_instance_exists(id,\"v2_base_attack_speed\"))v2_base_attack_speed=attackSpeed;scr_v2_group(id);if(!v2_components_done){v2_components_done=1;script_execute(v2_components_script);}}");
  Append("gml_Object_obj_Enemy_Step_0","if(variable_instance_exists(id,\"v2_enabled\") && currentHealth>0 && instance_exists(screen) && !screen.battleOver){script_execute(v2_periodic_script,id,global.player,screen);scr_v2_move(id);}");
  // Thing dies/disappears: count deaths, escapes and removals (scr_v3_gone).
  Append("gml_Object_obj_Enemy_Step_0","if((currentHealth<=0 || escaped) && !(variable_instance_exists(id,\"v3_gone\") && v3_gone))scr_v3_gone(id);");
  Append("gml_Object_obj_Enemy_Destroy_0","scr_v3_gone(id);");Append("gml_Object_obj_Trap_Base_Destroy_0","scr_v3_gone(id);");
  // Workshop credits under Information > System; the text box scrolls to fit them.
  Append("gml_Object_obj_DescriptionWindow_Create_0","systemTextBox.text+=scr_v3_credits();systemTextBox.hasScrollBar=1;");
  // Loot requirement overrides: Kingsway does not save Strength / Agility / Intelligence requirements.
  Append("gml_Object_obj_WorldData_Other_11","scr_v3_req_save(working_directory+\"world\"+string(uniqueID)+\".v3req\");");
  Patch("gml_Script_scr_LoadWorldData","return _dataObject;","scr_v3_req_load(argument0);\nreturn _dataObject;");
  // Guard Stance never worked in the base game (scr_v3_guard_stance).
  Patch("gml_Object_obj_Player_Step_0","        attackReady = 0;","        scr_v3_guard_stance();");
  Queue("gml_Object_obj_Enemy_Other_20","if(variable_instance_exists(id,\"v2_enabled\")){if(!scr_v2_death(id))exit;}\n"+game.Source("gml_Object_obj_Enemy_Other_20"));
  // Optional V2 loot is generated exactly once at death. Vanilla slots remain for protected overrides.
  var lootNative=game.Source("gml_Object_obj_Enemy_Other_21");int display=lootNative.IndexOf("if (ds_list_size(loot)",StringComparison.Ordinal);if(display<0)throw new Exception("Loot display anchor missing");Queue("gml_Object_obj_Enemy_Other_21","if(!variable_instance_exists(id,\"v2_enabled\") || variable_instance_exists(id,\"v2_preserve_drops\")){\n"+lootNative[..display]+"}\n"+lootNative[display..]);
  Patch("gml_Script_scr_Escape","_enemy.screen.battleOver = 1;","_enemy.screen.battleOver = 1;\nscr_v2_escape(_enemy);");
  // Consume before the native calculation so a dodged next attack also consumes the effect.
  var attack=game.Source("gml_Script_scr_Attack");attack=attack.Replace("var _battleWindow = argument2;","var _battleWindow = argument2;\nvar v2_next = scr_v2_consume(_attacker,\"next_attack_damage\",1);");
  attack=attack.Replace("if (_attacker.doubleDamage)","_damage *= v2_next;\nif (v2_next == 0) _reflectDamage = 0;\nif (_attacker.doubleDamage)");attack=attack.Replace("var _doVampirism = 1;","var _doVampirism = (v2_next != 0);");Queue("gml_Script_scr_Attack",attack);
  Patch("gml_Script_scr_Attack","var _battleWindow = argument2;","var _battleWindow = argument2;\nvar v2_incoming_attacker=argument0;var v2_incoming_enemy=argument1;var v2_incoming_blocked=v2_incoming_enemy.blocking;");
  Patch("gml_Script_scr_Attack","_victim.currentHealth -= round(_damage);","var v2_health_before=max(0,_victim.currentHealth);\n_victim.currentHealth -= round(_damage);\nvar v2_incoming_damage=max(0,v2_health_before-max(0,_victim.currentHealth));");
  Append("gml_Script_scr_Attack","if(instance_exists(v2_incoming_enemy))v2_incoming_enemy.v3_hurt_by=v2_incoming_attacker;if(global.v3_cast_hits!=-1 && instance_exists(v2_incoming_enemy))ds_list_add(global.v3_cast_hits,v2_incoming_enemy);scr_v2_attacked(v2_incoming_attacker,v2_incoming_enemy,v2_incoming_damage,v2_incoming_blocked);");
  // Native damage (spells, statuses) is attributed to the player; Workshop damage re-attributes after the call.
  // A player spell/skill (scr_CastSpell) reports each enemy it damages as a spell hit once per cast, so
  // "Also on spells & skills" reactions run; status ticks and Workshop damage actions are not casts.
  string spellHit="if(global.v3_cast_spell!=-4 && id==global.v3_cast_spell && instance_exists(target) && target!=global.player && ds_list_find_index(global.v3_cast_hits,target)<0){ds_list_add(global.v3_cast_hits,target);var v3_prev_magic=global.v3_hit_magic;global.v3_hit_magic=1;scr_v2_attacked(global.player,target,max(0,v3_hp_before-max(0,target.currentHealth)),0);global.v3_hit_magic=v3_prev_magic;}\n";
  string doDamage=game.Source("gml_Script_scr_DoDamage");if(!doDamage.Contains("return totalDamage;"))throw new Exception("Unsupported code anchor in gml_Script_scr_DoDamage: return totalDamage;");
  Queue("gml_Script_scr_DoDamage","if(instance_exists(argument0))argument0.v3_hurt_by=global.player;var v3_hp_before=0;if(instance_exists(argument0))v3_hp_before=max(0,argument0.currentHealth);\n"+doDamage.Replace("return totalDamage;",spellHit+"return totalDamage;"));
  // The cast's own target also counts once when the spell dealt no direct damage (Poison, Chill, scrolls).
  Patch("gml_Script_scr_CastSpell","event_user(0);","var v3_prev_spell=global.v3_cast_spell;var v3_prev_hits=global.v3_cast_hits;var v3_cast_hp=0;if(instance_exists(target))v3_cast_hp=max(0,target.currentHealth);global.v3_cast_spell=id;global.v3_cast_hits=ds_list_create();\nevent_user(0);\nif(attacker==global.player && instance_exists(target) && target!=global.player && ds_list_find_index(global.v3_cast_hits,target)<0){var v3_prev_magic=global.v3_hit_magic;global.v3_hit_magic=1;scr_v2_attacked(global.player,target,max(0,v3_cast_hp-max(0,target.currentHealth)),0);global.v3_hit_magic=v3_prev_magic;}\nds_list_destroy(global.v3_cast_hits);global.v3_cast_spell=v3_prev_spell;global.v3_cast_hits=v3_prev_hits;");
  Queue("gml_Object_obj_BolsterEffect_Create_0",game.Source("gml_Object_obj_BolsterEffect_Create_0").Replace("global.player.doubleDamage = 1;","scr_v2_effect(global.player,\"next_attack_damage\",\"Bolster\",2,-1);"));
  var portrait=game.Source("gml_Object_obj_BattleScreen_Other_24");portrait=portrait.Replace("draw_sprite(enemy.sprite_index, enemy.image_index, round(barPosX + 36 + _avatarsOffsetX), (barPosY + (barHeight * 0.5)) - 2);","scr_v2_portrait(enemy,round(barPosX+36+_avatarsOffsetX),(barPosY+barHeight*0.5)-2,c_white,1);");portrait=portrait.Replace("draw_sprite_ext(enemy.sprite_index, enemy.image_index, round(barPosX + 36 + _avatarsOffsetX), (barPosY + (barHeight * 0.5)) - 2, 1, 1, 0, global.darkGrey, 1);","scr_v2_portrait(enemy,round(barPosX+36+_avatarsOffsetX),(barPosY+barHeight*0.5)-2,global.darkGrey,1);");Queue("gml_Object_obj_BattleScreen_Other_24",portrait);
  Append("gml_Object_obj_BattleScreen_Draw_0","if(!minimized && !battleOver){scr_v2_draw_effects(enemy,x+width-22,y+78);scr_v2_draw_effects(global.player,x+width-22,y+height-24);}");
  Queue("gml_Object_obj_BattleScreen_Other_22","if(variable_instance_exists(enemy,\"v2_completion\") && enemy.v2_completion!=-1 && scr_v2_hostiles(scr_v2_group(enemy))>0){enemy.killTimer=1;exit;}\n"+game.Source("gml_Object_obj_BattleScreen_Other_22"));
  Append("gml_Object_obj_Enemy_Destroy_0","if(variable_instance_exists(id,\"v2_toggles\"))ds_map_destroy(v2_toggles);if(variable_instance_exists(id,\"v2_cooldowns\"))ds_map_destroy(v2_cooldowns);if(variable_instance_exists(id,\"v2_effects\")){var key=ds_map_find_first(v2_effects);while(!is_undefined(key)){ds_list_destroy(ds_map_find_value(v2_effects,key));key=ds_map_find_next(v2_effects,key);}ds_map_destroy(v2_effects);}");
  foreach(var pair in new[]{("burn","0"),("poison","1"),("cold","2")})Patch("gml_Object_obj_BattleScreen_Draw_0","draw_sprite(138, "+pair.Item2+", x + 170 + statusIconX, y + 83);","scr_v2_status_icon(enemy,"+Q(pair.Item1)+",138,"+pair.Item2+",x+170+statusIconX,y+83);");
  Patch("gml_Object_obj_StatusEffect_Draw_0","draw_sprite(sprite_index, image_index, x, y);","if(variable_instance_exists(id,\"v2_variant_icon\") && v2_variant_icon>=0)draw_sprite_ext(v2_variant_icon,0,x,y,14/sprite_get_width(v2_variant_icon),14/sprite_get_height(v2_variant_icon),0,c_white,1);else draw_sprite(sprite_index,image_index,x,y);");
  foreach(var effect in new[]{"obj_SlowPoisonEffect","obj_ChilledEffect","obj_BurnedEffect","obj_CurseEffect_Strength","obj_CurseEffect_Agility","obj_CurseEffect_Intellect","obj_CurseEffect_Vitality"})Append("gml_Object_"+effect+"_Step_0","if(variable_instance_exists(id,\"v2_variant_name\") && v2_variant_name!=\"\"){description=v2_variant_name;hoverText=description;}");
  Append("gml_Object_obj_ToolBar_Draw_0","if(instance_exists(global.player))scr_v2_draw_effects(global.player,x+width-18,y+8);");
  ConfigureMovementAndHazards();ConfigurePresentation();ConfigureStatusPresentation();
  foreach(var m in mods)foreach(var over in m.Overrides)ApplyOverride(m,over);
  if(test)Instrument(mods);
  Directory.CreateDirectory(Path.Combine(root,"Builds","generated"));var group=new CodeImportGroup(game.Data,game.Context,game.Settings){AutoCreateAssets=true,ThrowOnNoOpFindReplace=true};
  foreach(var q in queued.OrderBy(x=>x.Key,StringComparer.Ordinal)){group.QueueReplace(q.Key,q.Value);File.WriteAllText(Path.Combine(root,"Builds","generated",q.Key+".gml"),q.Value);}
  var result=group.Import();if(!result.Successful)throw new Exception("GML compilation failed: "+string.Join("\n",result.Errors));if(inputDigests.Any(kv=>!File.Exists(kv.Key)||Game.Hash(kv.Key)!=kv.Value))throw new Exception("Mod source changed during compilation; rebuild after saving edits");game.Write(output);
  using(var reload=new Game(output)){foreach(var q in queued){if(!reload.Data.Code.Any(x=>x.Name.Content==q.Key))throw new Exception("Compiled code missing: "+q.Key);_ = reload.Source(q.Key);}foreach(var m in mods)foreach(var e in m.Enemies){var o=reload.Data.GameObjects.First(x=>x.Name.Content==Obj(m,e.Id));if(o.ParentId.Name.Content!=(e.Mode=="cosmetic"?"obj_v3_cosmetic":"obj_Enemy"))throw new Exception("Inheritance validation failed");}if(!test&&reload.Data.Code.Any(x=>(x.Name.Content.Contains("v2_test")||x.Name.Content.Contains("v2_fight"))))throw new Exception("Test instrumentation leaked into release");}
  var report=new{schemaVersion=Revision.Current,originalSha256=Game.OriginalHash,sha256=Game.Hash(output),testBuild=test,roundtrip="passed",loadOrder=mods.Select(m=>m.Id).ToArray(),inputs=mods.Select(m=>new{m.Id,manifestSha256=Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(Encoding.UTF8.GetBytes(Json.Text(m)))),files=Directory.GetFiles(m.Directory,"*",SearchOption.AllDirectories).Order(StringComparer.Ordinal).ToDictionary(p=>Path.GetRelativePath(m.Directory,p),Game.Hash)}).ToArray(),modifiedCode=queued.Keys.Order(StringComparer.Ordinal).ToArray(),objects=game.Data.GameObjects.Count,sprites=game.Data.Sprites.Count,scripts=game.Data.Scripts.Count,overrides=mods.SelectMany(m=>m.Overrides).ToArray()};Json.Save(output+".json",report);return report;
 }
 static double NumberValue(object value,double fallback)=>value is double d?d:value is JsonElement j&&j.ValueKind==JsonValueKind.Number?j.GetDouble():fallback;
 string Actions(Manifest m,List<ActionNode> list,bool periodic){var sb=new StringBuilder();foreach(var a in list){int key=++nodeIndex;string target=a.Target=="attacker"?"actor":"victim";string condition="instance_exists(actor) && (actor.currentHealth>0 || global.v3_after_death) && instance_exists("+target+")";if(a.PositiveDamageOnly)condition+=" && damage>0";if(!a.DespiteBlocking)condition+=" && !victim.blocking";condition+=" && "+(a.Chance==100?"true":a.Chance==0?"false":"random(100)<"+N(a.Chance));if(periodic||a.Kind=="cooldown")condition+=" && scr_v2_cooldown(actor,"+Q("node"+key)+","+N(a.Cooldown)+")";sb.AppendLine("if("+condition+"){");string code=GroupedAction(m,a,target);
   switch(a.Kind){
    case "strike":code=$"damage=scr_v2_strike(actor,{target},window,{N(a.Multiplier)},{N(a.MinDamage??-1)},{N(a.MaxDamage??-1)},{(a.Blockable?1:0)});";break;
    case "wait":code="";break;
    case "damage":code=$"var hp_before=max(0,{target}.currentHealth);scr_DoDamage({target},{N(a.Amount)},\"physical\");{target}.v3_hurt_by=actor;damage=max(0,hp_before-max(0,{target}.currentHealth));";break;
    case "sound":code="scr_v2_audio_play("+Q(AudioKey(m,a.Asset))+",0);";break;
    case "lifesteal":code=$"actor.currentHealth=min(actor.maxHealth,actor.currentHealth+damage*{N(a.Amount)}/100);";break;
    case "manaDrain":code=$"if(variable_instance_exists({target},\"currentMana\")){{drained=min({target}.currentMana,{N(a.Amount)});{target}.currentMana-=drained;actor.currentHealth=min(actor.maxHealth,actor.currentHealth+drained*{N(a.HealPerMana)});}}";break;
    case "heal":code=$"{target}.currentHealth=min({target}.maxHealth,{target}.currentHealth+{N(a.Amount)});";break;
    case "mana":code=$"if(variable_instance_exists({target},\"currentMana\")){target}.currentMana=min({target}.maxMana,{target}.currentMana+{N(a.Amount)});";break;
    case "status":var v=m.StatusVariants.FirstOrDefault(x=>x.Id==a.Variant);code="global.v3_status_popup="+Q(v?.Popup??"familyDefault")+";"+$"scr_v2_status({target},{Q(a.Family)},{N(a.StatusOperation=="reduce"?-a.Amount:a.StatusOperation=="clear"?-100000:a.Amount)},{Q(v?.Name??"")},{Image(m,v?.Icon??"")});"+"global.v3_status_popup=\"familyDefault\";";if(v?.Message!=""&&v!=null&&v.Popup=="custom")code+="if(scr_v3_message_ok(window,"+Q(v.Message)+"))scr_BattleText(window,"+Q(v.Message)+","+target+",0);";break;
    case "effect":double multiplier=a.Effect=="Nullify"?0:a.Effect=="Bolster"?2:a.Multiplier;code=$"scr_v2_effect({target},{Q(a.Group)},{Q(a.Effect)},{N(multiplier)},{Image(m,a.Icon)});";break;
    case "message":code="if(scr_v3_message_ok(window,"+Q(a.Text)+"))scr_BattleText(window,"+Q(a.Text)+",actor,0);";break;
    case "log":code="scr_Log("+Q(a.Text)+");";break;
    case "spawn":code="scr_v2_spawn(actor,"+Obj(m,a.Enemy)+",\"summon\",0,0);";break;
    case "projectile":case "hazard":code="scr_v2_projectile("+a.Asset+","+N(a.Amount)+","+Q(a.Placement)+","+N(a.X)+","+N(a.Y)+","+(a.OutsideEntry?1:0)+","+Q(a.ButtonText)+");";break;
    case "window":code="scr_v2_window(window,"+Q(a.Operation)+","+N(a.Amount)+","+N(a.X)+","+N(a.Y)+","+Q(a.WindowPlacement)+","+Q(a.WindowBasis)+","+N(a.WindowOffsetX)+","+N(a.WindowOffsetY)+","+N(a.WindowMinX)+","+N(a.WindowMaxX)+","+N(a.WindowMinY)+","+N(a.WindowMaxY)+","+N(a.WindowDuration)+","+Q(a.WindowEasing)+","+Q(a.WindowBoundary)+");";break;
    case "attackSpeed":code="scr_v2_attack_speed("+target+","+Q(a.AttackSpeedOperation)+","+N(a.AttackSpeedValue)+","+(a.ResetAttackProgress?"1":"0")+");";break;
    case "condition":string c=a.Condition switch{"blocked"=>"victim.blocking","healthBelow"=>target+".currentHealth/"+target+".maxHealth*100<"+N(a.Threshold),"manaBelow"=>"variable_instance_exists("+target+",\"currentMana\") && "+target+".currentMana<"+N(a.Threshold),"alive"=>target+".currentHealth>0","killedByPlayer"=>KilledByPlayer,"killedBySelf"=>KilledBySelf,"chance"=>"random(100)<"+N(a.Threshold),_=>"damage>0"};code="if("+c+"){"+Actions(m,a.Children,false)+"}else{"+Actions(m,a.Else,false)+"}";break;
    case "chance":case "cooldown":code=Actions(m,a.Children,false);break;
    case "variableAction":code="scr_v3_variable_fire(actor,"+N(a.Threshold)+");";break;
    case "deleteSelf":code="scr_v3_delete_self(actor);";break;
    case "variableBranch":code="";break; // runs only when its Variable is activated (scr_v3_variable_fire)
   }if(a.Lifesteal>0 && new[]{"strike","damage","trueDamage","magicDamage"}.Contains(a.Kind))code+="actor.currentHealth=min(actor.maxHealth,actor.currentHealth+max(0,damage)*"+N(a.Lifesteal)+"/100);";sb.AppendLine(code);if(a.Kind!="condition"&&a.Kind!="chance"&&a.Kind!="cooldown"&&a.Kind!="variableBranch")sb.Append(Actions(m,a.Children,false));sb.AppendLine("}");if(a.Kind=="chance"&&a.Else.Count>0)sb.AppendLine("else{"+Actions(m,a.Else,false)+"}");
  }return sb.ToString();}
 string LootCode(Enemy e){var sb=new StringBuilder();string Drop(Loot l){string code="repeat(irandom_range("+l.Min+","+l.Max+")){var item=instance_create_depth(0,0,0,"+l.Item+");";
   // Kingsway curses an item when its enchant rarity is 75-100: one negative stat, one boosted bonus, a name prefix.
   if(l.Cursed&&l.Enchantment!="selected")code+="item.chanceToEnchant=100;item.enchanted=0;item.enchant=1;item.forcedRarity=irandom_range(75,100);";
   else if(l.Enchantment=="random")code+="item.chanceToEnchant=100;item.enchanted=0;item.enchant=1;item.forcedRarity=irandom_range(25,74);";
   if(l.Enchantment=="selected"){code+="for(var n=0;n<9;n+=1){item.bonus[n,0]=\"\";item.bonus[n,1]=0;item.bonus[n,2]=\"\";}"+(l.Cursed?"item.chanceToEnchant=0;item.enchant=0;if(!item.unique){item.enchanted=2;item.icon=2;}item.identified=1;item.name=\"Cursed \"+item.name;":"item.chanceToEnchant=0;item.enchant=0;if(!item.unique)item.enchanted=1;item.identified=1;item.name+=\" (Enchanted)\";");foreach(var b in l.Enchantments){var c=Enchantments.Choices.First(x=>x.Id==b.Stat);code+="scr_v2_loot_bonus(item,"+Q(b.Stat)+","+b.Amount+","+Q((c.Unit=="%"?"% ":" ")+c.Name.ToLowerInvariant())+");";}}
   if(l.Name!="")code+="item.v2_custom_name="+Q(l.Name)+";"+(l.Cursed&&l.Enchantment=="selected"?"item.v2_cursed_name=1;":"")+"if(item.identified)item.name=item.v2_custom_name;";
   // Stat overrides replace the item's native values (saved games keep them).
   if(l.DamageOverride)code+="item.minDamage="+l.DamageMin+";item.maxDamage="+l.DamageMax+";";
   // "Override requirements": Required level (rolled), Strength, Agility, Intelligence (0 = none).
   if(l.LevelOverride)code+="item.requiredLevel=irandom_range("+l.RequiredLevelMin+","+l.RequiredLevelMax+");item.v3_req=1;item.v3_req_str="+l.RequiredStrength+";item.v3_req_agi="+l.RequiredAgility+";item.v3_req_int="+l.RequiredIntelligence+";item.requiredStrength=item.v3_req_str;item.requiredAgility=item.v3_req_agi;item.requiredIntelligence=item.v3_req_int;";
   return code+"ds_list_add(loot,item);}";
  }string Eligible(Loot l)=>"level>="+l.MinLevel+" && level<="+l.MaxLevel;
  foreach(var l in e.Loot.Where(x=>x.Group==""))sb.AppendLine("if("+Eligible(l)+" && "+(l.Chance==100?"true":l.Chance==0?"false":"random(100)<"+N(l.Chance))+"){"+Drop(l)+"}");
  foreach(var gr in e.Loot.Where(x=>x.Group!="").GroupBy(x=>x.Group)){sb.AppendLine("if(random(100)<"+N(gr.First().Chance)+"){var total=0;");foreach(var l in gr)sb.AppendLine("if("+Eligible(l)+")total+="+N(l.Weight)+";");sb.AppendLine("var roll=random(total);var chosen=0;");foreach(var l in gr)sb.AppendLine("if(!chosen && "+Eligible(l)+"){if(roll<"+N(l.Weight)+"){chosen=1;"+Drop(l)+"}else roll-="+N(l.Weight)+";}");sb.AppendLine("}");}
  // Random treasure tables: the same area-level tables the native specialTreasure drop uses (scr_GenerateTreasure).
  if(e.TreasureRolls>0)sb.AppendLine("repeat("+e.TreasureRolls+"){if("+(e.TreasureChance>=100?"true":e.TreasureChance<=0?"false":"random(100)<"+N(e.TreasureChance))+")ds_list_add(loot,instance_create(x,y,scr_GenerateTreasure(scr_GetCurrentNodeLevel())));}");
  return sb.ToString();}
 void ApplyOverride(Manifest m,SlotOverride over){
  void Configure(string obj,string enemyId,bool limb){var e=m.Enemies.First(x=>x.Id==enemyId);string prefix="gml_Object_"+obj;
   Append(prefix+"_Create_0","scr_v2_apply("+Q(m.Id+":"+e.Id)+");v2_preserve_drops=1;v2_completion=-1;v2_completion_scheduled=0;");
   Queue(prefix+"_Other_10","if(currentHealth>0 && instance_exists(global.player) && global.player.currentHealth>0 && instance_exists(screen) && !screen.battleOver){attackReady=0;script_execute(v2_attack_script,id,global.player,screen);}");
   string tail=game.Source(prefix+"_Other_20").Replace("action_inherited();","").Replace("event_inherited();","");
   if(limb||over.Slot=="obj_DemonBossSpawner"){Queue(prefix+"_Other_20","event_inherited();");return;}
   if(!string.IsNullOrWhiteSpace(tail)){string callback="scr_v2_complete_"+obj;Queue("gml_Script_"+callback,tail);Queue(prefix+"_Other_20","event_inherited();if(!v2_completion_scheduled){v2_completion_scheduled=1;v2_completion="+callback+";}");}
  }
  if(Adapters.Single.Contains(over.Slot)){Configure(over.Slot,over.Enemy,false);
   // The Shadow forces 9999 health and pins its window to the centre every frame;
   // an authored replacement keeps its own health and movement instead.
   if(over.Slot=="obj_Skyeater")Queue("gml_Object_obj_Skyeater_Step_1","action_inherited();\nif(!variable_instance_exists(id,\"v2_enabled\")){\n"+game.Source("gml_Object_obj_Skyeater_Step_1").Replace("action_inherited();","")+"\n}");
   return;}
  if(over.Slot=="obj_DemonBossSpawner"){
   foreach(var pair in Adapters.DemonParts)Configure(pair.Value,over.Components[pair.Key],pair.Key!="Head");var e=m.Enemies.First(x=>x.Id==over.Enemy);var code=new StringBuilder("\nif(created && instance_exists(head) && variable_instance_exists(head,\"v2_enabled\") && head.encounterGroupId<0){scr_v2_group(head);\n");
   foreach(var pair in new[]{("Body","butt"),("Arms","arms"),("Legs","legs")}){var death=e.Components.FirstOrDefault(x=>string.Equals(x.Slot,pair.Item1,StringComparison.OrdinalIgnoreCase))?.DeathAction??new();code.AppendLine("scr_v2_attach(head,"+pair.Item2+","+N(death.Amount)+","+(death.Percent?1:0)+");");}code.AppendLine("}");Append("gml_Object_obj_DemonBossSpawner_Step_2",code.ToString());
   // Required vanilla slots are supplied by the original spawner; only additional friends use the custom component spawner.
   var friends=new StringBuilder();foreach(var comp in e.Components.Where(x=>x.Role=="separate"))friends.AppendLine("scr_v2_spawn(id,"+Obj(m,comp.Enemy)+",\"separate\",0,0);");Queue("gml_Script_"+Script(m,e,"components"),friends.ToString());return;
  }throw new Exception("Unknown adapter: "+over.Slot);
 }
 void Instrument(List<Manifest> mods){Append("gml_Script_scr_v2_clock","if(variable_global_exists(\"v2_probe_max_frame\"))global.v2_probe_max_frame=max(global.v2_probe_max_frame,delta_time/1000000);");Patch("gml_Script_scr_v2_projectile","return projectile;","if(variable_global_exists(\"v2_probe_projectiles\")){ds_list_add(global.v2_probe_projectiles,projectile);ds_list_add(global.v2_probe_times,global.v2_time);}return projectile;");SamplePaths();if(Fight!=null){InstrumentFight();return;}game.Data.GeneralInfo.Name=game.Str("KingswayWorkshopV2Test");game.Data.GeneralInfo.FileName=game.Str("KingswayWorkshopV2Test");game.Data.GeneralInfo.DisplayName=game.Str("Kingsway V2 isolated verification");game.Data.GeneralInfo.SteamAppID=0;
  Queue("gml_Object_obj_Profile_Other_10","exit;");Queue("gml_Object_obj_Profile_Other_11","exit;");
  Queue("gml_Object_obj_BootScreen_Step_0","room_goto(rm_PlayerCreate);");var loader=Existing("gml_Object_obj_Loader_Create_0").Replace("scr_LoadSounds();","global.resolutionW=1280;global.resolutionH=960;global.gameScale=2;global.windowed=1;scr_LoadSounds();");Queue("gml_Object_obj_Loader_Create_0","global.v2_test_stage=0;global.v2_test_frames=0;global.v2_test_failures=0;global.v2_test_assertions=0;var log=file_text_open_write(\"v2-tests.txt\");file_text_close(log);\n"+loader);
  Append("gml_Object_obj_Notification_Create_0","alertSound=0;goAway=1;alpha=.04;visible=0;"); // no "NEW MESSAGE" popups in tests
  InstrumentMinimize(mods);
  foreach(var f in Directory.GetFiles(Path.Combine(root,"Tests"),"*.gml"))if(PreviewEnemy==""||!f.EndsWith("scr_v2_test_step.gml"))Queue("gml_Script_"+Path.GetFileNameWithoutExtension(f),File.ReadAllText(f));
  if(PreviewEnemy!=""){var bootstrap=File.ReadAllText(Path.Combine(root,"Tests","scr_v2_test_step.gml"));bootstrap=bootstrap[..bootstrap.IndexOf("if(global.v2_test_stage==1 &&",StringComparison.Ordinal)];Queue("gml_Script_scr_v2_test_step",bootstrap+"\nif(global.v2_test_stage==1 && global.v2_test_frames>180){global.v2_test_actor=instance_create_depth(0,0,0,"+PreviewEnemy+");global.v2_test_actor.level=2;global.v2_test_hazard=global.v2_test_actor.v2_hazard;global.player.maxHealth=10000000;global.player.currentHealth=10000000;scr_v2_test_assert(global.v2_test_actor.v2_enabled,\"Selected project enemy created from compiled registry\");global.v2_test_stage=2;global.v2_test_next=global.v2_test_frames+10;}else if(global.v2_test_stage==2 && global.v2_test_frames>=global.v2_test_next){var actor=global.v2_test_actor;if(!instance_exists(actor) || (global.v2_test_hazard && actor.v2_expired)){scr_v2_test_assert(global.v2_test_hazard,\"One-shot hazard completed its activation and cleanup\");}else{scr_v2_test_assert(actor.init && instance_exists(actor.screen),\"Native battle window initialized\");scr_v2_test_assert(actor.maxHealth>=1,\"Native level scaling produces positive health\");if(!actor.v2_hazard)with(actor)event_user(0);}global.v2_test_stage=3;global.v2_test_next=global.v2_test_frames+60;}else if(global.v2_test_stage==3 && global.v2_test_frames>=global.v2_test_next){scr_v2_test_assert(true,\"Generated attack and periodic actions ran in the actual engine\");screen_save(\"v2-battle.png\");scr_v2_test_log(\"RESULT: \"+string(global.v2_test_assertions)+\" assertions, \"+string(global.v2_test_failures)+\" failures\");game_end();}");}
  if(MinimizeOnly){var bootstrap=File.ReadAllText(Path.Combine(root,"Tests","scr_v2_test_step.gml"));bootstrap=bootstrap[..bootstrap.IndexOf("if(global.v2_test_stage==1 &&",StringComparison.Ordinal)];Queue("gml_Script_scr_v2_test_step",bootstrap+"\nif(global.v2_test_stage==1 && global.v2_test_frames>180){global.v2_test_stage=20;global.player.maxHealth=1000000;global.player.currentHealth=1000000;global.gameSpeed=.1;}if(global.v2_test_stage==20 && scr_v2_test_minimize()){scr_v2_test_log(\"RESULT: \"+string(global.v2_test_assertions)+\" assertions, \"+string(global.v2_test_failures)+\" failures\");game_end();}");}
  Patch("gml_Object_obj_QuestController_Step_2","alarm[2] = 10;",""); // no Quests window auto-open on start; manual opening stays
  Append("gml_Object_obj_DesktopControler_Step_0","scr_v2_test_step();if(global.v2_test_frames==1)scr_v2_test_path_samples();");
 }
}
