using System;
using System.Linq;
using System.Collections.Generic;
namespace KingswayWorkshop;
public static class RevisionValidation {
 public static List<ValidationError> Check(List<Manifest> manifests,Catalog catalog){var errors=new List<ValidationError>();foreach(var m in manifests){string enemy="";
  void Error(string field,object value,string message)=>errors.Add(new(){Mod=m.Id,Enemy=enemy,Field=field,Value=value??"null",Message=message});
  void Range(string f,double v,double min,double max){if(!double.IsFinite(v)||v<min||v>max)Error(f,v,$"Expected {min} through {max}");}
  void Choice(string f,string v,params string[] values){if(!values.Contains(v))Error(f,v,"Choose "+string.Join(", ",values));}
  foreach(var v in m.StatusVariants)Choice("statusVariants.popup",v.Popup,"familyDefault","none","custom");
  foreach(var e in m.Enemies){enemy=e.Id;var w=e.Appearance;
   if(!new[]{68,102,136,170,204,272}.Contains(w.Size))Error("appearance.size",w.Size,"Choose 68, 102, 136, 170, 204, or 272 logical pixels");
   if(!new[]{0,90,180,270}.Contains(w.Rotation))Error("appearance.rotation",w.Rotation,"Choose 0, 90, 180, or 270 degrees");
   Choice("appearance.layer",w.Layer,"normal","top","timer","behind");Choice("appearance.cosmeticStyle",w.CosmeticStyle,"canon","alt");Range("appearance.autoClose",w.AutoClose,0,3600);Range("appearance.opacity",w.Opacity,0,10);Choice("appearance.buttonText",w.ButtonText,"Close","Avoid");
   var motion=e.Movement;Range("movement.startX",motion.StartX,-1,2);Range("movement.startY",motion.StartY,-1,2);
   void Points(List<Waypoint> points,string f){for(int i=0;i<points.Count;i++){var p=points[i];string k=f+"["+i+"]";Choice(k+".shape",p.Shape,"line","arc","arcRandom");Choice(k+".behavior",p.Behavior,"target","radiusRandom");Choice(k+".direction",p.Direction,"forward","opposite");Range(k+".bend",p.Bend,-2,2);Range(k+".radius",p.Radius,0,2);Range(k+".radiusSpeed",p.RadiusSpeed,.001,10);Range(k+".leftSpread",p.LeftSpread,0,180);Range(k+".rightSpread",p.RightSpread,0,180);Range(k+".rotation",p.Rotation,0,360);Range(k+".x",p.X,-1,2);Range(k+".y",p.Y,-1,2);Range(k+".duration",p.Duration,.01,3600);Range(k+".speed",p.Speed,0,10);Range(k+".wait",p.Wait,0,3600);}}
   Points(motion.Points,"movement.points");Choice("movement.dragReturn.entry",motion.DragReturn.Entry,"first","closest","none");Range("movement.dragReturn.transitionSpeed",motion.DragReturn.TransitionSpeed,0,10);var ids=new HashSet<string>();foreach(var move in motion.ActionMoves){string f="movement.actionMoves."+move.Id;if(!Validation.Identifier(move.Id)||!ids.Add(move.Id))Error(f,move.Id,"Action Move IDs must be unique identifiers");Choice(f+".mode",move.Mode,"variation","detour");Choice(f+".entry",move.Entry,"first","closest","none");Choice(f+".overlap",move.Overlap,"ignore");Range(f+".transitionSpeed",move.TransitionSpeed,0,10);if(move.Points.Count<1||move.Points.Count>64)Error(f+".points",move.Points.Count,"Use 1–64 points");Points(move.Points,f+".points");}
   foreach(var c in e.Components)if(m.Enemies.FirstOrDefault(x=>x.Id==c.Enemy)?.Mode=="cosmetic"&&c.DeathAction.Amount!=0)Error("components.deathAction.amount",c.DeathAction.Amount,"A Cosmetic cannot cause structural death damage");
   void Actions(List<ActionNode> list,string f,int depth=0){if(depth>12)return;for(int i=0;i<list.Count;i++){var a=list[i];string k=f+"["+i+"]";if(a.Mode!=""&&Revision.Modes.TryGetValue(a.Kind,out var modes)&&!modes.Contains(a.Mode))Error(k+".mode",a.Mode,"Unknown mode for "+a.Kind);
    Choice(k+".basis",a.Basis,"fixed","maxPercent","currentPercent");Choice(k+".resource",a.Resource,"health","mana");Choice(k+".destinationResource",a.DestinationResource,"health","mana");Range(k+".lifesteal",a.Lifesteal,0,100);Range(k+".restoreAfter",a.RestoreAfter,0,3600);
    if(a.Kind=="movement"&&a.Mode=="actionMove"&&!ids.Contains(a.Move))Error(k+".move",a.Move,"Choose an Action Move defined on this actor");
    if((a.Kind=="text"||a.Kind=="movement")&&a.Mode=="opacity"){Choice(k+".operation",a.Operation,"set","add","subtract");Range(k+".amount",a.Amount,0,10);if(a.Amount!=Math.Floor(a.Amount))Error(k+".amount",a.Amount,"Opacity uses whole steps from 0 through 10");}
    if(a.Kind=="text"&&a.Mode=="rotation"&&!new[]{0d,90d,180d,270d}.Contains(a.Amount))Error(k+".amount",a.Amount,"Choose 0, 90, 180, or 270 degrees");
    if(a.Kind=="text"&&a.Mode=="rotate"&&(a.Amount%90!=0||a.Amount>1080))Error(k+".amount",a.Amount,"Rotate by 90-degree increments");
    if((a.Kind=="text"||a.Kind=="movement")&&a.Mode=="layer")Choice(k+".layer",a.Layer,"normal","top","timer","behind");
    if((a.Kind=="attackSpeed"||a.Kind=="branch")&&a.Mode=="variable"){Range(k+".threshold",a.Threshold,1,99);if(a.Threshold!=Math.Floor(a.Threshold))Error(k+".threshold",a.Threshold,"Variables are whole numbers from 1 through 99");}
    if(a.Kind=="text"&&a.Mode=="portrait"&&!m.Assets.ContainsKey(a.Asset)&&!catalog.Sprites.Contains(a.Asset))Error(k+".asset",a.Asset,"Choose a native sprite or project image");
    if(a.Kind=="spawn"&&a.Mode!=""&&a.Mode!="projectile"){var child=m.Enemies.FirstOrDefault(x=>x.Id==a.Enemy);if(child!=null&&(a.Mode=="cosmetic")!=(child.Mode=="cosmetic"))Error(k+".enemy",a.Enemy,"Choose an actor matching the spawn mode");}
    if(e.Mode=="cosmetic"&&(new[]{"damage","magic","resource","attackSpeed"}.Contains(a.Kind)||new[]{"strike","status","effect","heal","mana","manaDrain","lifesteal"}.Contains(a.Kind)))Error(k+".kind",a.Kind,"Cosmetics run choreography, text, movement, and spawn actions; combat requires an Enemy or Hazard");
    Choice(k+".buttonText",a.ButtonText,"Close","Avoid");Actions(a.Children,k+".children",depth+1);Actions(a.Else,k+".else",depth+1);for(int pi=0;pi<a.MorePaths.Count;pi++)Actions(a.MorePaths[pi].Children,k+".morePaths["+pi+"].children",depth+1);
   }}
   Actions(e.Actions,"actions");Actions(e.WhenAttacked,"whenAttacked");Actions(e.Periodic,"periodic");for(int gi=0;gi<e.WhenGone.Count;gi++)Actions(e.WhenGone[gi].Children,"whenGone["+gi+"].children",1);
  }
 }return errors;}
}
