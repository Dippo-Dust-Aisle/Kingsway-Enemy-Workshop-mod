var seq=argument0;
if(!scr_v2_reaction_commit(seq))return 0;
var actor=seq[?"actor"];var stack=seq[?"toggles"];
for(var i=0;i<ds_list_size(stack);i+=3){
    if(!ds_list_find_value(stack,i+2)){
        ds_map_replace(actor.v2_toggles,ds_list_find_value(stack,i),ds_list_find_value(stack,i+1)); // the next path (scr_v2_toggle_enter)
        ds_list_replace(stack,i+2,1);
    }
}
return 1;
