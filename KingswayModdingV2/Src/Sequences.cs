using System;
using System.Collections.Generic;
using System.Text.Json;
namespace KingswayWorkshop;
public sealed partial class Compiler {
 string Sequence(Manifest m,Enemy e,List<ActionNode> actions,string section){
  bool reaction=section=="whenAttacked";
  int sequenceIndex=0;
  // Section-local identities do not change when another enemy/section changes.
  // Length prefixes keep underscore-containing mod/enemy IDs unambiguous.
  string Make(string body){string name=$"scr_v2seq_m{m.Id.Length}_{m.Id}_e{e.Id.Length}_{e.Id}_{section}_{++sequenceIndex}";Queue("gml_Script_"+name,"var seq=argument0;var actor=seq[?\"actor\"];var victim=seq[?\"victim\"];var window=seq[?\"window\"];var damage=seq[?\"damage\"];var drained=seq[?\"drained\"];\n"+body);return name;}
  string Wait(double low,double high,string next)=>low==0&&high==0?next:Make("seq[?\"wait\"]=random_range("+N(low)+","+N(high)+");return "+next+";");
  string Nodes(List<ActionNode> nodes,string next,string location,bool reactionRoot=false){
   for(int i=nodes.Count-1;i>=0;i--){var a=nodes[i];string after=Wait(a.WaitMin,a.WaitMax,next),entry=after;
    for(int repeat=a.Repeat-1;repeat>=0;repeat--){string tail=repeat==a.Repeat-1?after:Wait(a.Interval,a.Interval,entry);
     string branchTail=a.Kind=="alternate"?Make("scr_v2_toggle_leave(seq);return "+tail+";"):tail;
     string yes=Nodes(a.Children,branchTail,location+"["+i+"].children"),no=Nodes(a.Else,branchTail,location+"["+i+"].else");
     string target=a.Target=="attacker"?"actor":"victim",cond="instance_exists("+target+")";
     if(a.PositiveDamageOnly)cond+=" && damage>0";
     string blocked=reaction?"seq[?\"blocked\"]":"victim.blocking";
     if(!a.DespiteBlocking)cond+=" && !"+blocked;
     if(a.Chance<100)cond+=" && random(100)<"+N(a.Chance);
     if(a.Kind=="window")cond+=" && instance_exists(window)";
     if(a.Kind=="attackSpeed")cond+=" && scr_v2_attack_speed("+target+","+Q(a.AttackSpeedOperation)+","+N(a.AttackSpeedValue)+",0,0)";
     if(a.Kind=="cooldown"&&!reactionRoot)cond+=" && scr_v2_cooldown(actor,"+Q(m.Id+":"+e.Id+":"+location+"["+i+"]:gate")+","+N(a.Cooldown)+")";
     string code;
     if(a.Kind=="alternate"&&a.PathCount>2){
      // Path 1 runs the 1st time, path 2 the 2nd time, ... path N the Nth time, then it starts over.
      var paths=new List<string>{yes,no};
      for(int p=0;p<a.PathCount-2;p++)paths.Add(Nodes(p<a.MorePaths.Count?a.MorePaths[p].Children:new(),branchTail,location+"["+i+"].morePaths["+p+"].children"));
      code="var side=scr_v2_toggle_enter(seq,"+Q(m.Id+":"+e.Id+":"+location+"["+i+"]:alternate")+","+a.PathCount+");";
      for(int p=1;p<paths.Count;p++)code+="if(side=="+p+")return "+paths[p]+";";
      code+="return "+yes+";";
     }
     else if(a.Kind=="alternate")code="if(scr_v2_toggle_enter(seq,"+Q(m.Id+":"+e.Id+":"+location+"["+i+"]:alternate")+"))return "+no+";return "+yes+";";
     else if(a.Kind=="condition"){
      string test=a.Condition switch{"blocked"=>blocked,"healthBelow"=>target+".currentHealth/"+target+".maxHealth*100<"+N(a.Threshold),"manaBelow"=>"variable_instance_exists("+target+",\"currentMana\") && "+target+".currentMana<"+N(a.Threshold),"alive"=>target+".currentHealth>0","killedByPlayer"=>KilledByPlayer,"killedBySelf"=>KilledBySelf,"chance"=>"random(100)<"+N(a.Threshold),_=>"damage>0"};
      code="if("+test+")return "+yes+";return "+no+";";
     }else if(a.Kind=="chance"||a.Kind=="cooldown")code="return "+yes+";";
     else if(a.Kind=="variableBranch")code="return "+tail+";"; // skipped in normal order; see VariableHandler
     else {var leaf=JsonSerializer.Deserialize<ActionNode>(Json.Text(a),Json.Options);leaf.Children=new();leaf.Else=new();leaf.Chance=100;leaf.PositiveDamageOnly=false;leaf.DespiteBlocking=true;
      code="if(!scr_v2_action_commit(seq))return -1;"+Actions(m,new(){leaf},false)+"seq[?\"damage\"]=damage;seq[?\"drained\"]=drained;"+(a.Kind=="actionMove"&&a.WaitForCompletion?"if(actor.v3_active){seq[?\"wait_move\"]=1;seq[?\"wait\"]=0.000001;}":"")+"return "+yes+";";}
     entry=Make("global.v2_context="+Q(m.Id+":"+e.Id+" "+location+"["+i+"] "+a.Kind)+";show_debug_message(\"WORKSHOP: \"+global.v2_context);if("+cond+"){"+code+"}return "+(a.Kind=="chance"?no:tail)+";");
     // Play action move: "Pause before move" waits first, then runs the move.
     if(a.Kind=="actionMove"&&a.Mode!="returnToBase"&&a.PauseBefore>0)entry=Wait(a.PauseBefore,a.PauseBefore,entry);
    }next=entry;
   }return next;
  }
  if(section=="actions"||section.StartsWith("variable")||section.StartsWith("gone"))return "scr_v2_sequence(actor,victim,window,"+Nodes(actions,"-1",section)+");";
  string result="";
  for(int i=0;i<actions.Count;i++){
   var a=actions[i];string entry=Nodes(new(){a},"-1",section+"_"+i,reaction),key=Q(m.Id+":"+e.Id+":"+section+":"+i);
   // Spell/skill hits (global.v3_hit_magic) only run reactions that opted in with "Also on spells & skills".
   if(reaction)result+=(a.MagicHits?"":"if(!global.v3_hit_magic)")+"if(!ds_map_exists(actor.v2_cooldowns,"+key+") || global.v2_time>=ds_map_find_value(actor.v2_cooldowns,"+key+"))scr_v2_sequence(actor,victim,window,"+entry+",damage,"+key+","+N(a.Cooldown)+",blocked);";
   else result+="if(scr_v2_cooldown(actor,"+key+","+N(a.Cooldown)+"))scr_v2_sequence(actor,victim,window,"+entry+");";
  }
  return result;
 }
}
public sealed partial class Compiler {
 // Variable Branches are skipped in normal order. This handler runs the ones whose
 // number matches when anything in the project activates a Variable (scr_v3_variable_fire).
 string VariableHandler(Manifest m,Enemy e){
  var branches=new List<ActionNode>();
  void Collect(List<ActionNode> list){foreach(var a in list){if(a.Kind=="variableBranch")branches.Add(a);Collect(a.Children);Collect(a.Else);foreach(var p in a.MorePaths)Collect(p.Children);}}
  Collect(e.Actions);Collect(e.Periodic);Collect(e.WhenAttacked);foreach(var t in e.WhenGone)Collect(t.Children);
  var sb=new System.Text.StringBuilder("var actor=argument0;var victim=argument1;var window=argument2;var variable=argument3;var damage=0;var drained=0;\n");
  // The branch itself runs as a Cooldown branch, so its own cooldown, chance, repeat
  // and waits apply however often its Variable is activated.
  for(int j=0;j<branches.Count;j++){var gate=JsonSerializer.Deserialize<ActionNode>(Json.Text(branches[j]),Json.Options);gate.Kind="cooldown";gate.Else=new();sb.AppendLine("if(variable=="+N(branches[j].Threshold)+"){"+Sequence(m,e,new(){gate},"variable"+j)+"}");}
  return sb.ToString();
 }
}
public sealed partial class Compiler {
 // Killing-blow attribution: v3_hurt_by holds whoever last damaged the actor (scr_Attack, damage actions,
 // scr_v3_damage / scr_v3_resource). Native damage with no Workshop source (spells, statuses) counts as the player.
 const string KilledByPlayer="(instance_exists(actor) && actor.currentHealth<=0 && !actor.escaped && (!variable_instance_exists(actor,\"v3_hurt_by\") || actor.v3_hurt_by==global.player))";
 const string KilledBySelf="(instance_exists(actor) && actor.currentHealth<=0 && variable_instance_exists(actor,\"v3_hurt_by\") && actor.v3_hurt_by==actor)";
}
public sealed partial class Compiler {
 // "When thing dies/disappears": scr_v3_gone calls this on every live actor of a project
 // with triggers (argument3 = the thing, argument4 = its object, argument5 = it is this actor).
 string GoneHandler(Manifest m,Enemy e){
  var sb=new System.Text.StringBuilder("var actor=argument0;var victim=argument1;var window=argument2;var thing=argument3;var thingObject=argument4;var isSelf=argument5;var damage=0;var drained=0;\n");
  for(int j=0;j<e.WhenGone.Count;j++){var t=e.WhenGone[j];
   string test=t.Entity==""?"isSelf":"!isSelf && thingObject=="+(SafeHazards.Contains(t.Entity)?t.Entity:Obj(m,t.Entity));
   sb.AppendLine("if("+test+"){"+Sequence(m,e,t.Children,"gone"+j)+"}");}
  return sb.ToString();
 }
}
