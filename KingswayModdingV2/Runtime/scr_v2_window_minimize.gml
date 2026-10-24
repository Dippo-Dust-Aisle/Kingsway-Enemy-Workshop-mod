var win=argument0;if(!instance_exists(win) || win.minimized)return;
// Complete native creation before it can select/reopen the window on its first
// Begin Step. Capture the window origin, not the minimize button's +3px inset.
if(!win.init || (variable_instance_exists(win,"thisInit") && !win.thisInit)){with(win)event_perform(ev_step,ev_step_begin);}
if(variable_instance_exists(win,"enemy") && instance_exists(win.enemy)){
    var actor=win.enemy;
    if(variable_instance_exists(actor,"v2_enabled") && !actor.v2_move_started && ds_list_size(actor.v2_points)>=16)scr_v2_move(actor);
}
win.minimizedPos=win.y;win.active=0;win.minimized=1;
// Freeze immediately, including a minimize issued after the driver's Begin Step.
// Never end/restart the driver path or copy the animated window into its anchor.
if(variable_instance_exists(win,"v2_path_driver") && instance_exists(win.v2_path_driver)){win.v2_path_driver.path_speed=0;win.path_speed=0;}
win.updateWindowSurface=1;
