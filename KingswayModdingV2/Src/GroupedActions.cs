using System;
namespace KingswayWorkshop;
public sealed partial class Compiler {
 string GroupedAction(Manifest m,ActionNode a,string target){
  string amount="scr_v3_amount("+target+","+Q(a.Resource)+","+Q(a.Mode=="fromDamage"?"fixed":a.Basis)+","+N(a.Amount)+")";
  switch(a.Kind){
   case "trueDamage":case "magicDamage":return "damage=scr_v3_damage(actor,"+target+",window,"+N(a.Amount)+","+Q(a.Kind=="trueDamage"?"true":"magic")+","+Q(a.Basis)+","+(a.Blockable?"1":"0")+");";
   case "resourceChange":return "drained=scr_v3_resource(actor,"+target+","+Q(a.Resource)+","+Q(a.DestinationResource)+","+Q(a.Mode)+","+amount+","+N(a.Multiplier)+",damage);";
   case "presentation":return "scr_v3_presentation(actor,window,"+Q(a.Mode)+","+Q(a.Text)+","+(a.Mode=="portrait"?Image(m,a.Asset):"-1")+","+N(a.Amount)+","+Q(a.Operation)+","+N(a.RestoreAfter)+","+Q(a.Layer)+");";
   case "returnToPoint":return "scr_v3_return_point(actor,"+a.PathPoint+","+N(a.WindowDuration)+","+N(a.PathShape=="line"?0:a.Bend)+","+(a.PathShape=="arcRandom"?"1":"0")+");";
   case "actionMove":return "scr_v3_action_move(actor,"+Q(a.Move)+","+(a.Mode=="returnToBase"?"1":"0")+","+N(a.WindowDuration)+");";
   default:return "";
  }
 }
}
