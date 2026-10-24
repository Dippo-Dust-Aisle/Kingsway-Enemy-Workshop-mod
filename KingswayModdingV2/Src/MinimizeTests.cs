using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Collections.Generic;
namespace KingswayWorkshop;
public static class MinimizeTests {
 public static IEnumerable<Enemy> Fixtures(){
  yield return JsonSerializer.Deserialize<Enemy>("{\"id\":\"min_old\",\"name\":\"Old manifest, no path\",\"actions\":[{\"kind\":\"window\",\"operation\":\"minimize\"}]}",Json.Options);
  yield return new(){Id="min_new",Name="Fresh enemy, no path",Actions=new(){new(){Kind="window",Operation="minimize"}}};
  yield return new(){Id="min_custom",Name="Custom path",Movement=new(){Points=new(){new(){X=.2,Y=.3,Duration=5},new(){X=.8,Y=.3,Duration=5}}},Actions=new(){new(){Kind="window",Operation="minimize"}}};
  yield return new(){Id="min_native",Name="Native path",Movement=new(){Profile="pth_Skeleton"},Actions=new(){new(){Kind="window",Operation="minimize"}}};
  yield return new(){Id="min_hazard",Name="Native-path hazard",Mode="hazard",ActivationSeconds=1000,Movement=new(){Profile="pth_Skeleton"},Actions=new(){new(){Kind="window",Operation="minimize"}}};
 }
 public static void AddProjects(Store store,List<Manifest> mods){
  foreach(var source in store.List().Where(m=>m.Enemies.Any(e=>e.Name=="Nuclear Warhead"||e.Name=="Astra Apparently"))){
   var errors=Validation.Check(new(){source},store.Catalog);if(errors.Count>0)throw new Exception("Minimize reproduction project fails validation: "+Json.Text(errors));
   // Loaded objects are disposable copies. Preserve enemy actions, movement and
   // asset files, but keep encounter registration out of the conformance fixture.
   source.Overrides.Clear();foreach(var e in source.Enemies)e.Encounters.Clear();mods.Add(source);
  }
 }
 public static void Run(Store store,Action<bool,string> check){
  var old=Fixtures().First();check(old.Actions[0].WindowBasis=="absolute"&&old.Movement.PauseMinimized,"Old minimize actions load with compatible movement defaults");
  check(Validation.Check(new(){new(){Id="minimize_fixtures",Enemies=Fixtures().ToList()}},store.Catalog).Count==0,"Minimize fixtures validate for old/new, custom/native, and hazard windows");
  foreach(var m in store.List().Where(m=>m.Enemies.Any(e=>e.Name=="Nuclear Warhead"||e.Name=="Astra Apparently")))check(Validation.Check(new(){m},store.Catalog).Count==0,"Reported project validates without migration: "+m.Id);
  using var native=new Game(store.Original);
  check(native.Source("gml_Object_obj_Window_Step_0").Contains("y += 64;")&&native.Source("gml_Object_obj_MinimizeButton_Step_0").Contains("window.minimizedPos = y;")&&native.Source("gml_Script_scr_SelectWindow").Contains("global.selectedWindow.y = global.selectedWindow.minimizedPos;"),"Verified native minimize slides offscreen and native selection restores saved Y");
 }
}
public sealed partial class Compiler {
 public bool MinimizeOnly;
 void InstrumentMinimize(List<Manifest> mods){
  var fixture=mods.FirstOrDefault(m=>m.Id=="verification");if(fixture==null){Queue("gml_Script_scr_v2_test_minimize_create","return noone;");return;}
  var cases=new List<(Manifest Mod,Enemy Enemy,string Mode)>();void Add(string id,string mode)=>cases.Add((fixture,fixture.Enemies.First(e=>e.Id==id),mode));
  Add("min_old","plain");Add("min_new","button");Add("min_custom","plain");Add("min_native","plain");Add("min_new","absolute");Add("min_custom","relative");Add("min_custom","smooth");Add("min_native","smooth");Add("min_hazard","relative");
  foreach(string name in new[]{"Nuclear Warhead","Astra Apparently"}){var match=mods.SelectMany(m=>m.Enemies.Select(e=>(m,e))).FirstOrDefault(x=>x.e.Name==name);if(match.e!=null)cases.Add((match.m,match.e,"plain"));}
  Add("min_new","hiddenMove");Add("min_custom","continue");
  var code=new StringBuilder("var actor=noone;switch(argument0){");
  for(int i=0;i<cases.Count;i++){
   var (m,e,mode)=cases[i];ActionNode Find(List<ActionNode> list){foreach(var a in list){if(a.Kind=="window"&&a.Operation=="minimize")return a;var child=Find(a.Children)??Find(a.Else);if(child!=null)return child;}return null;}
   var action=Find(e.Actions)??Find(e.Periodic)??Find(e.WhenAttacked)??new(){Kind="window",Operation="minimize"};
   string script="scr_v2_test_minimize_action_"+i;
   Queue("gml_Script_"+script,"var actor=argument0;var victim=argument1;var window=argument2;var damage=0;var drained=0;"+Sequence(m,e,new(){action},"minimizeVerification"));
   code.Append("case "+i+":actor=instance_create_depth(0,0,0,"+Obj(m,e.Id)+");actor.v2_min_test_mode="+Q(mode)+";actor.v2_min_test_label="+Q(m.Id+":"+e.Id+" / "+e.Name+" / "+mode)+";actor.v2_min_test_script="+script+";break;");
  }
  code.Append("}return actor;");Queue("gml_Script_scr_v2_test_minimize_create",code.ToString());
  Queue("gml_Script_scr_v2_test_minimize_empty","return;");
 }
}
