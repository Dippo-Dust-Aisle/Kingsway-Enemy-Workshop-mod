using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Text.Json;
namespace KingswayWorkshop;

// Version 3 stores author-facing groups. Lowering is deliberately one node in,
// one node out: sequence identities, children, gates and result dependencies survive.
public static class Revision {
 public const int Current=3;
 public static readonly Dictionary<string,string[]> Modes=new(){
  ["damage"]=new[]{"weapon","physical","true","lifesteal"},
  ["magic"]=new[]{"damage","apply","reduce","clear","effect"},
  ["resource"]=new[]{"restore","drain","transfer","fromDamage"},
  ["text"]=new[]{"message","log","sound","rename","portrait","restorePortrait","rotation","rotate","opacity","layer"},
  ["movement"]=new[]{"actionMove","returnToBase","returnToPoint","shake","minimize","maximize","restore","opacity","layer","delete"},
  ["spawn"]=new[]{"enemy","cosmetic","projectile"},
  ["branch"]=new[]{"conditional","chance","alternate","cooldown","wait","variable"},
  ["attackSpeed"]=new[]{"set","add","multiply","restoreBase","variable"}
 };
 static readonly JsonSerializerOptions CloneOptions=new(Json.Options){NumberHandling=System.Text.Json.Serialization.JsonNumberHandling.AllowNamedFloatingPointLiterals};
 public static T Clone<T>(T value)=>JsonSerializer.Deserialize<T>(JsonSerializer.Serialize(value,CloneOptions),CloneOptions);
 public static void Upgrade(Manifest m){
  if(m.SchemaVersion==Current)return;
  if(m.SchemaVersion!=2)throw new Exception("Unsupported schema version: "+m.SchemaVersion);
  foreach(var e in m.Enemies){
   foreach(var c in e.Components)if(c.Role=="friend")c.Role="separate";
   var motion=e.Movement;
   if(motion.Points.Count>0){motion.StartX=motion.Points[0].X;motion.StartY=motion.Points[0].Y;if(motion.StartMode=="fixed")motion.StartMode="firstPoint";else motion.LegacySpawnOffset=true;}
   if(motion.Shape=="arc")foreach(var p in motion.Points){p.Shape="arc";p.Bend=motion.Bend;}
   motion.Shape="path";
   int moveIndex=0;
   void Convert(List<ActionNode> nodes){foreach(var a in nodes){
    if(a.Mode=="")switch(a.Kind){
     case "strike":a.Kind="damage";a.Mode="weapon";break;
     case "damage":a.Mode="physical";break;
     case "lifesteal":a.Kind="damage";a.Mode="lifesteal";break;
     case "status":a.Kind="magic";a.Mode=a.StatusOperation=="add"?"apply":a.StatusOperation;break;
     case "effect":a.Kind="magic";a.Mode="effect";break;
     case "manaDrain":a.Kind="resource";a.Mode="transfer";a.Resource="mana";a.DestinationResource="health";a.Multiplier=a.HealPerMana;break;
     case "heal":case "mana":a.Resource=a.Kind=="mana"?"mana":"health";a.Kind="resource";a.Mode="restore";break;
     case "message":case "log":case "sound":a.Mode=a.Kind;a.Kind="text";break;
     case "window":
      a.Kind="movement";a.Mode=a.Operation=="clearMoveOffset"?"returnToBase":a.Operation;
      if(a.Operation=="move"){
       string id;do{id="converted_move_"+(++moveIndex);}while(motion.ActionMoves.Any(x=>x.Id==id));
       var legacy=Clone(a);legacy.Kind="window";legacy.Mode="";legacy.Children.Clear();legacy.Else.Clear();
       motion.ActionMoves.Add(new(){Id=id,Name="Converted Move "+moveIndex,Mode="variation",LegacyPlacement=legacy,Points=new(){new(){X=a.WindowBasis=="relative"?a.WindowOffsetX:a.X,Y=a.WindowBasis=="relative"?a.WindowOffsetY:a.Y,Duration=Math.Max(.01,a.WindowDuration)}}});
       a.Mode="actionMove";a.Move=id;
      }break;
     case "projectile":case "hazard":a.Kind="spawn";a.Mode="projectile";break;
     case "spawn":a.Mode="enemy";break;
     case "condition":a.Kind="branch";a.Mode="conditional";break;
     case "chance":case "cooldown":case "alternate":case "wait":a.Mode=a.Kind;a.Kind="branch";break;
     case "attackSpeed":a.Mode=a.AttackSpeedOperation;break;
    }
    Convert(a.Children);Convert(a.Else);
   }}
   Convert(e.Actions);Convert(e.WhenAttacked);Convert(e.Periodic);
  }
  foreach(var v in m.StatusVariants)v.Popup=v.Message==""?"familyDefault":"custom";
  m.SchemaVersion=Current;
 }
 public static ActionNode Lower(ActionNode source,Enemy enemy=null){
  var a=Clone(source);a.Children=source.Children.Select(x=>Lower(x,enemy)).ToList();a.Else=source.Else.Select(x=>Lower(x,enemy)).ToList();a.MorePaths=source.MorePaths.Select(p=>new ActionPath{Children=p.Children.Select(x=>Lower(x,enemy)).ToList()}).ToList();
  if(a.Mode=="")return a; // Internal test fixtures and legacy import conversion.
  switch(a.Kind){
   case "damage":a.Kind=a.Mode switch{"weapon"=>"strike","physical"=>"damage","true"=>"trueDamage","lifesteal"=>"lifesteal",_=>"invalid"};break;
   case "magic":a.Kind=a.Mode=="damage"?"magicDamage":a.Mode=="effect"?"effect":"status";a.StatusOperation=a.Mode=="apply"?"add":a.Mode;break;
   case "resource":a.Kind="resourceChange";break;
   case "text":a.Kind=new[]{"message","log","sound"}.Contains(a.Mode)?a.Mode:"presentation";break;
   case "movement":
    if(a.Mode=="actionMove" && enemy?.Movement.ActionMoves.FirstOrDefault(x=>x.Id==a.Move)?.LegacyPlacement is ActionNode legacy){
     // Preserve the complete old placement, but keep this node's sequence gates.
     a.Kind="window";a.Operation="move";a.WindowBasis=legacy.WindowBasis;a.WindowPlacement=legacy.WindowPlacement;
     a.X=legacy.X;a.Y=legacy.Y;a.WindowOffsetX=legacy.WindowOffsetX;a.WindowOffsetY=legacy.WindowOffsetY;
     a.WindowMinX=legacy.WindowMinX;a.WindowMaxX=legacy.WindowMaxX;a.WindowMinY=legacy.WindowMinY;a.WindowMaxY=legacy.WindowMaxY;
     a.WindowDuration=legacy.WindowDuration;a.WindowEasing=legacy.WindowEasing;a.WindowBoundary=legacy.WindowBoundary;
    }else if(a.Mode=="delete")a.Kind="deleteSelf";
    else if(a.Mode=="returnToPoint")a.Kind="returnToPoint";
    else if(a.Mode=="opacity"||a.Mode=="layer")a.Kind="presentation"; // Movement / Window group (formerly Text / Sound)
    else if(a.Mode=="actionMove"||a.Mode=="returnToBase")a.Kind="actionMove";
    else {a.Kind="window";a.Operation=a.Mode;}break;
   case "spawn":if(a.Mode=="projectile")a.Kind="projectile";break;
   case "branch":a.Kind=a.Mode=="conditional"?"condition":a.Mode=="variable"?"variableBranch":a.Mode;break;
   case "attackSpeed":if(a.Mode=="variable")a.Kind="variableAction";else a.AttackSpeedOperation=a.Mode;break;
  }
  return a;
 }
 // Briefly, "Thing dies/disappears" and "This enemy died" were Conditional conditions. They are
 // now "When thing dies/disappears" triggers; lift any such branch into one (its Otherwise is dropped).
 static void LiftGone(Enemy e){List<ActionNode> Lift(List<ActionNode> list){var keep=new List<ActionNode>();foreach(var a in list){if(a.Kind=="branch"&&a.Mode=="conditional"&&(a.Condition=="thingGone"||a.Condition=="died")){e.WhenGone.Add(new(){Entity=a.Condition=="died"?"":a.Enemy,Children=Lift(a.Children)});continue;}a.Children=Lift(a.Children);a.Else=Lift(a.Else);foreach(var p in a.MorePaths)p.Children=Lift(p.Children);keep.Add(a);}return keep;}e.Actions=Lift(e.Actions);e.WhenAttacked=Lift(e.WhenAttacked);e.Periodic=Lift(e.Periodic);}
 public static Manifest Runtime(Manifest source){var m=Clone(source);m.Directory=source.Directory;foreach(var e in m.Enemies){LiftGone(e);e.Actions=e.Actions.Select(a=>Lower(a,e)).ToList();e.WhenAttacked=e.WhenAttacked.Select(a=>Lower(a,e)).ToList();e.Periodic=e.Periodic.Select(a=>Lower(a,e)).ToList();foreach(var t in e.WhenGone)t.Children=t.Children.Select(a=>Lower(a,e)).ToList();}return m;}
 public static Manifest Load(Store store,string path){
  var m=Json.Read<Manifest>(path);m.Directory=Path.GetDirectoryName(path);
  if(m.SchemaVersion==Current&&!AudioAssets.NeedsConversion(m))return m;
  if(m.SchemaVersion!=2&&m.SchemaVersion!=Current)throw new Exception("Unsupported schema version: "+m.SchemaVersion);
  string hash=Game.Hash(path),kind=Path.GetFileName(Path.GetDirectoryName(m.Directory));
  string backup=Path.Combine(store.Root,"Recovery","schema3-projects",kind,m.Id+"-"+hash[..12]);
  if(!Directory.Exists(backup)){Directory.CreateDirectory(backup);CopyFiles(m.Directory,backup);}
  string stage=Path.Combine(store.Root,"Builds","conversion-"+Guid.NewGuid().ToString("N"));Directory.CreateDirectory(stage);var added=new List<string>();var retired=new List<(string Source,string Destination)>();bool committed=false;var oldAudio=m.Audio.Values.SelectMany(a=>new[]{a.File,a.Original}).Where(p=>p!="").Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
  try{
   CopyFiles(m.Directory,stage);string source=m.Directory;m.Directory=stage;Upgrade(m);AudioAssets.ConvertLegacy(m);
   var errors=Validation.Check(new(){m},store.Catalog);if(errors.Count>0)throw new Exception("Project conversion could not validate; original is unchanged. Backup: "+backup+"\n"+Json.Text(errors));
   Json.Save(Path.Combine(stage,"mod.json"),m);
   if(Game.Hash(path)!=hash)throw new Exception("Project changed during conversion; original retained. Retry after saving.");
   // Assets are added before the only commit point. Never replace an existing asset.
   foreach(var f in Directory.GetFiles(stage,"*",SearchOption.AllDirectories)){string rel=Path.GetRelativePath(stage,f);if(rel=="mod.json")continue;string dest=Validation.Within(source,rel,false);if(File.Exists(dest)){if(Game.Hash(dest)!=Game.Hash(f))throw new Exception("Conversion asset collision: "+rel);}else{Directory.CreateDirectory(Path.GetDirectoryName(dest));File.Copy(f,dest);added.Add(dest);}}
   string prepared=path+".schema3.tmp";File.Copy(Path.Combine(stage,"mod.json"),prepared,true);File.Replace(prepared,path,null);committed=true;
   var retained=m.Audio.Values.SelectMany(a=>new[]{a.File,a.Original}).Concat(m.Assets.Values).ToHashSet(StringComparer.OrdinalIgnoreCase);string callbacks=string.Join("\n",Directory.GetFiles(source,"*.gml",SearchOption.AllDirectories).Select(File.ReadAllText));
   foreach(string rel in oldAudio.Where(p=>!retained.Contains(p)&&!callbacks.Contains(Path.GetFileName(p)))){string old=Validation.Within(source,rel);if(Game.Hash(old)!=Game.Hash(Validation.Within(backup,rel)))throw new Exception("Legacy audio changed during conversion");string dest=Validation.Within(Path.Combine(store.Root,"Recovery","schema3-retired-audio",kind,m.Id+"-"+hash[..12]),rel,false);Directory.CreateDirectory(Path.GetDirectoryName(dest));File.Move(old,dest);retired.Add((old,dest));}
   m.Directory=source;return m;
  }catch{foreach(var item in retired)File.Move(item.Destination,item.Source);if(committed){string restore=path+".restore.tmp";File.Copy(Path.Combine(backup,"mod.json"),restore,true);File.Replace(restore,path,null);}foreach(var file in added)if(File.Exists(file))File.Delete(file);throw;}finally{if(Directory.Exists(stage))Directory.Delete(stage,true);}
 }
 public static void CopyFiles(string source,string dest){foreach(var f in Directory.GetFiles(source,"*",SearchOption.AllDirectories)){string rel=Path.GetRelativePath(source,f);string p=Validation.Within(dest,rel,false);Validation.Within(source,rel);Directory.CreateDirectory(Path.GetDirectoryName(p));File.Copy(f,p,false);}}
}
