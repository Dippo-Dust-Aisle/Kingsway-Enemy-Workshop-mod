using System;
using System.Linq;
using System.Text.Json;
namespace KingswayWorkshop;
public static class ActionTests {
 public static Enemy GatedReactionFixture()=>new(){Id="reactiongate",Name="Cooldown branch probe",Stats=new(){MaxHealth=1000,AttackSpeed=0},WhenAttacked=new(){new(){Kind="cooldown",Cooldown=2,Children=new(){new(){Kind="condition",Condition="positiveDamage",Children=new(){new(){Kind="mana",Target="attacker",Amount=1}}}}}}};
 public static Enemy ReactionFixture()=>new(){Id="reaction",Name="Incoming attack probe",Stats=new(){MaxHealth=1000,MinDamage=0,MaxDamage=0,AttackSpeed=0},Actions=new(){new(){Kind="strike"}},WhenAttacked=new(){
  new(){Kind="condition",Condition="positiveDamage",Cooldown=2,Children=new(){
   new(){Kind="mana",Target="attacker",Amount=1},
   new(){Kind="window",Operation="move",WindowPlacement="randomXY"},
   new(){Kind="message",Text="Reaction received"},
   new(){Kind="sound",Asset="probe_sound"},
   new(){Kind="wait",WaitMin=.1,WaitMax=.1},
   new(){Kind="mana",Target="attacker",Amount=10,Repeat=2,Interval=.1}
  }},
  new(){Kind="condition",Condition="blocked",Cooldown=2,Children=new(){new(){Kind="mana",Target="attacker",Amount=100}}}
 }};
 public static void Run(Store store,Action<bool,string> check){
  var old=JsonSerializer.Deserialize<Manifest>("{\"schemaVersion\":2,\"id\":\"old\",\"enemies\":[{\"actions\":[{\"kind\":\"window\",\"operation\":\"move\",\"x\":0.2,\"y\":0.8}]}]}",Json.Options);
  check(old.Enemies[0].WhenAttacked.Count==0,"Old manifests default When attacked to an empty collection");
  check(old.Enemies[0].Actions[0].WindowPlacement=="fixed"&&old.Enemies[0].Actions[0].Placement=="randomXY","Old Window Move remains fixed independently of projectile placement");
  Revision.Upgrade(old);check(Validation.Check(new(){old},store.Catalog).Count==0,"Converted old action manifest validates");
  foreach(string mode in new[]{"fixed","randomX","randomY","randomXY"}){
   old.Enemies[0].WhenAttacked=new(){new(){Kind="condition",Cooldown=2,Children=new(){new(){Kind="window",Operation="move",WindowPlacement=mode}}}};
   check(Validation.Check(new(){old},store.Catalog).Count==0,"When attacked accepts nested Window Move "+mode);
  }
  var roundtrip=JsonSerializer.Deserialize<Manifest>(Json.Text(old),Json.Options);
  check(roundtrip.Enemies[0].WhenAttacked[0].Children[0].WindowPlacement=="randomXY","Reaction branches and placement survive JSON serialization");
  old.Enemies[0].WhenAttacked[0].Children[0].WindowPlacement="bad";
  check(Validation.Check(new(){old},store.Catalog).Any(x=>x.Field=="whenAttacked[0].children[0].windowPlacement"),"Invalid nested reaction placement identifies its exact field");
  old.Enemies[0].WhenAttacked=new(){new(){Cooldown=-1}};
  check(Validation.Check(new(){old},store.Catalog).Any(x=>x.Field=="whenAttacked[0].cooldown"),"Reaction cooldown validates with a reaction field path");
  old.Enemies[0].WhenAttacked=new(){new(){Repeat=64,Children=new(){new(){Repeat=64}}}};
  check(Validation.Check(new(){old},store.Catalog).Any(x=>x.Message.Contains("4096")),"Reaction repeat expansion is bounded");
  var schema=JsonSerializer.SerializeToElement(Schema.Create(),Json.Options).GetProperty("$defs");
  check(schema.GetProperty("Enemy").GetProperty("properties").TryGetProperty("whenAttacked",out _)&&schema.GetProperty("ActionNode").GetProperty("properties").TryGetProperty("windowPlacement",out _),"Generated schema includes both optional compatible fields");
  // Check generation directly: unrelated collections must not rename scripts
  // or cooldown keys, and underscore-containing identifiers cannot collide.
  var method=typeof(Compiler).GetMethod("Sequence",System.Reflection.BindingFlags.NonPublic|System.Reflection.BindingFlags.Instance);
  var queued=typeof(Compiler).GetField("queued",System.Reflection.BindingFlags.NonPublic|System.Reflection.BindingFlags.Instance);
  var compiler=new Compiler(null,store.Catalog,store.Root);var fixture=ReactionFixture();
  string Emit(Compiler c,Manifest m,Enemy e,string section)=>(string)method.Invoke(c,new object[]{m,e,e.WhenAttacked,section});
  old.Id="a_b";fixture.Id="c";string first=Emit(compiler,old,fixture,"whenAttacked");
  var names=((System.Collections.Generic.Dictionary<string,string>)queued.GetValue(compiler)).Keys.ToArray();
  var second=new Compiler(null,store.Catalog,store.Root);Emit(second,old,fixture,"actions");
  check(first==Emit(second,old,fixture,"whenAttacked"),"Reaction generation and cooldown identities are stable across unrelated collections");
  old.Id="a";fixture.Id="b_c";Emit(compiler,old,fixture,"whenAttacked");
  check(((System.Collections.Generic.Dictionary<string,string>)queued.GetValue(compiler)).Count==names.Length*2,"Generated reaction scripts distinguish underscore-containing mod and enemy IDs");
 }
}
