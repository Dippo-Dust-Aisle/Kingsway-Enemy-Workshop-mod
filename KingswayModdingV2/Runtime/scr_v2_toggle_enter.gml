// Alternating branch: returns which path runs this time (0 = path 1). The next path is
// stored only once an action under this branch actually runs (scr_v2_action_commit).
// argument2 = number of paths (default 2).
var seq=argument0;var key=argument1;var actor=seq[?"actor"];
var count=2;if(argument_count>2)count=max(2,argument2);
var side=0;if(ds_map_exists(actor.v2_toggles,key))side=ds_map_find_value(actor.v2_toggles,key);
if(side>=count)side=0;
ds_list_add(seq[?"toggles"],key,(side+1) mod count,0);
return side;
