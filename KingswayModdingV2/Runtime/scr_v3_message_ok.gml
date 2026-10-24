// Battle-log spam limit for Workshop messages: the same text in the same window
// is posted at most once per 0.5 s. Each post re-renders the whole battle log.
var win=argument0;var text=argument1;
if(!instance_exists(win))return 0;
if(variable_instance_exists(win,"v3_last_message") && win.v3_last_message==text && current_time-win.v3_last_message_at<500)return 0;
win.v3_last_message=text;win.v3_last_message_at=current_time;
return 1;
