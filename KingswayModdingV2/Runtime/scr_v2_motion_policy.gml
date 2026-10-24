var win=argument0;var policy=win.v2_motion_boundary;var actor=win.v2_motion_actor;
if(policy=="inherit"){
    policy="none";
    if(instance_exists(actor) && variable_instance_exists(actor,"v2_enabled")){
        if(actor.v2_path!=-4 || ds_list_size(actor.v2_points)>=16)policy=actor.v2_move_boundary;
    }
}
return policy;
