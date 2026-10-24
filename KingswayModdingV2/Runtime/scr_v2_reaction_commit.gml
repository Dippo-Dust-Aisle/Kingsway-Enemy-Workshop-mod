// A failed gate/empty branch does not spend its top-level reaction cooldown.
// Commit before the first action, once for the entire delayed/repeated sequence.
var seq=argument0;var key=seq[?"reaction_key"];
if(key=="" || seq[?"reaction_committed"])return 1;
if(!scr_v2_cooldown(seq[?"actor"],key,seq[?"reaction_cooldown"]))return 0;
seq[?"reaction_committed"]=1;
return 1;
