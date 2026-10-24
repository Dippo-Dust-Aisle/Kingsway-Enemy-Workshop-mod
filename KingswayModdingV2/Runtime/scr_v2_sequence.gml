scr_v2_init();
var seq=ds_map_create();
seq[?"toggles"]=ds_list_create();
seq[?"actor"]=argument0;seq[?"victim"]=argument1;seq[?"window"]=argument2;
seq[?"script"]=argument3;seq[?"damage"]=0;seq[?"drained"]=0;seq[?"wait"]=0;seq[?"wake"]=global.v2_time;
seq[?"reaction_key"]="";seq[?"reaction_cooldown"]=0;seq[?"reaction_committed"]=0;seq[?"blocked"]=0;
if(argument_count>4)seq[?"damage"]=argument4;
if(argument_count>5){seq[?"reaction_key"]=argument5;seq[?"reaction_cooldown"]=argument6;seq[?"blocked"]=argument7;}
// A "When thing dies/disappears" trigger for the actor itself keeps running after its death.
seq[?"dying"]=global.v3_gone_self;
ds_list_add(global.v2_sequences,seq);
var source=argument0;source.v2_pending+=1;
scr_v2_sequence_run(seq);
