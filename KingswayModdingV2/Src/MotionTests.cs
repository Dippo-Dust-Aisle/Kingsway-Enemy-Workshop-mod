using System;
using System.Linq;
using System.Text.Json;
using System.Collections.Generic;
namespace KingswayWorkshop;
public static class MotionTests {
 static ActionNode Mana(double n)=>new(){Kind="mana",Target="attacker",Amount=n};
 static ActionNode Toggle(double a=1,double b=10)=>new(){Kind="alternate",Children=new(){Mana(a)},Else=new(){Mana(b)}};
 public static IEnumerable<Enemy> Fixtures(){
  yield return new(){Id="alternator",Stats=new(){MaxHealth=10000,AttackSpeed=0},Actions=new(){Toggle()},WhenAttacked=new(){Toggle(100,1000)},Periodic=new(){Toggle(10000,100000)}};
  var delayed=Toggle();delayed.Children.Insert(0,new(){Kind="wait",WaitMin=.1,WaitMax=.1});delayed.Else.Insert(0,new(){Kind="wait",WaitMin=.1,WaitMax=.1});delayed.Children[1].Repeat=2;delayed.Children[1].Interval=.1;delayed.Else[1].Repeat=2;delayed.Else[1].Interval=.1;
  yield return new(){Id="alternate_delayed",Stats=new(){MaxHealth=10000,AttackSpeed=0},Actions=new(){delayed}};
  yield return new(){Id="alternate_gated",Stats=new(){MaxHealth=10000,AttackSpeed=0},Actions=new(){new(){Kind="condition",Target="attacker",Condition="healthBelow",Threshold=50,Children=new(){Toggle(),Toggle(100,1000)}}},WhenAttacked=new(){new(){Kind="alternate",Children=new(){new(){Kind="chance",Chance=0,Children=new(){Mana(1)}}}},new(){Kind="alternate",Chance=0,Children=new(){Mana(1)}}}};
  yield return new(){Id="motion",Stats=new(){MaxHealth=10000,AttackSpeed=0},Movement=new(){Points=new(){new(){X=.2,Y=.2,Duration=2},new(){X=.8,Y=.2,Duration=2}}},Actions=new(){new(){Kind="window",Operation="move",WindowBasis="relative",WindowOffsetY=.2,WindowDuration=1},new(){Kind="attackSpeed",Target="attacker",AttackSpeedValue=.2}}};
 }
 public static void Run(Store store,Action<bool,string> check){
  var old=JsonSerializer.Deserialize<ActionNode>("{\"kind\":\"window\",\"operation\":\"move\",\"x\":0.2,\"y\":0.8}",Json.Options);
  check(old.WindowBasis=="absolute"&&old.WindowDuration==0&&old.WindowEasing=="linear"&&old.X==.2&&old.Y==.8,"Old moves default to immediate absolute positions");
  check(!old.ResetAttackProgress&&old.Placement=="randomXY","New defaults preserve attack progress and projectile placement");
  check(!JsonSerializer.Deserialize<FightOptions>("{\"fullscreen\":false}",Json.Options).Fullscreen&&JsonSerializer.Deserialize<FightOptions>("{\"fullscreen\":true}",Json.Options).Fullscreen,"FightOptions deserialization preserves explicit false and true");
  var m=new Manifest{Id="motion_tests",Enemies=Fixtures().ToList()};
  check(Validation.Check(new(){m},store.Catalog).Count==0,"Alternation, relative moves and attack speed validate in composed actions");
  var e=m.Enemies.Last();var move=e.Actions[0];move.WindowPlacement="randomXY";move.WindowMinX=-.25;move.WindowMaxX=.25;move.WindowMinY=-.4;move.WindowMaxY=.1;
  var copy=JsonSerializer.Deserialize<Manifest>(Json.Text(m),Json.Options).Enemies.Last().Actions[0];
  check(copy.WindowBasis=="relative"&&copy.WindowMinY==-.4&&copy.WindowMaxY==.1&&copy.WindowDuration==1,"Asymmetric movement ranges survive serialization exactly");
  move.WindowMaxY=-.5;check(Validation.Check(new(){m},store.Catalog).Any(x=>x.Field.EndsWith(".windowMaxY")),"Inverted relative ranges rejected");move.WindowMaxY=.1;
  foreach(var bad in new[]{-1d,double.NaN,double.PositiveInfinity}){move.WindowDuration=bad;check(Validation.Check(new(){m},store.Catalog).Any(x=>x.Field.EndsWith(".windowDuration")),"Invalid transition duration rejected: "+bad);}move.WindowDuration=1;
  move.WindowBasis="unknown";check(Validation.Check(new(){m},store.Catalog).Any(x=>x.Field.EndsWith(".windowBasis")),"Unknown position basis rejected");move.WindowBasis="relative";
  var speed=e.Actions[1];foreach(string op in new[]{"set","add","multiply","restoreBase"}){speed.AttackSpeedOperation=op;check(Validation.Check(new(){m},store.Catalog).Count==0,"Attack-speed operation validates: "+op);}
  speed.AttackSpeedOperation="set";speed.AttackSpeedValue=0;check(Validation.Check(new(){m},store.Catalog).Count==0,"Zero attack speed is authorable");speed.AttackSpeedValue=-1;check(Validation.Check(new(){m},store.Catalog).Any(x=>x.Field.EndsWith(".attackSpeedValue")),"Negative set speed rejected");speed.AttackSpeedOperation="add";check(Validation.Check(new(){m},store.Catalog).Count==0,"Signed additive speed changes are authorable with runtime result validation");
  speed.Target="victim";check(Validation.Check(new(){m},store.Catalog).Any(x=>x.Field.EndsWith(".target")),"Unsafe player attack-speed targeting rejected");speed.Target="attacker";
  var schema=JsonSerializer.SerializeToElement(Schema.Create(),Json.Options).GetProperty("$defs").GetProperty("ActionNode").GetProperty("properties");
  check(schema.GetProperty("windowBasis").GetProperty("default").GetString()=="absolute"&&schema.GetProperty("windowDuration").GetProperty("minimum").GetDouble()==0,"Schema publishes compatible movement defaults and limits");
  check(schema.GetProperty("minDamage").GetProperty("anyOf").EnumerateArray().Any(x=>x.GetProperty("type").GetString()=="null"),"Schema retains nullable damage overrides in older manifests");
  var method=typeof(Compiler).GetMethod("Sequence",System.Reflection.BindingFlags.NonPublic|System.Reflection.BindingFlags.Instance);
  var field=typeof(Compiler).GetField("queued",System.Reflection.BindingFlags.NonPublic|System.Reflection.BindingFlags.Instance);
  var compiler=new Compiler(null,store.Catalog,store.Root);
  foreach(string section in new[]{"actions","whenAttacked","periodic"})method.Invoke(compiler,new object[]{m,e,e.Actions,section});
  var source=string.Join("\n",((Dictionary<string,string>)field.GetValue(compiler)).Values);
  check(source.Contains("scr_v2_motion_move")==false&&source.Contains("scr_v2_window(window,\"move\"")&&source.Contains("\"relative\""),"Generated action sequences pass distinct movement parameters to the shared window helper");
  check(source.Contains("scr_v2_attack_speed(actor,\"add\",-1,0,0)")&&source.Contains("scr_v2_action_commit"),"Speed result is checked before branch and reaction commitment");
 }
}
