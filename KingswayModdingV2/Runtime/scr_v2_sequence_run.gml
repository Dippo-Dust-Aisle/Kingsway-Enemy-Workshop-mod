var seq=argument0;
var actor=seq[?"actor"];
if(!instance_exists(actor)){seq[?"script"]=-1;seq[?"wake"]=global.v2_time;return;}
// Started by the actor's own "When thing dies/disappears" trigger: keeps running (and
// its actions keep working) after the actor's death, while the actor still exists.
var dying=seq[?"dying"];
if((actor.currentHealth<=0 && !dying) || actor.escaped){seq[?"script"]=-1;seq[?"wake"]=global.v2_time;return;}
if(ds_map_exists(seq,"wait_move") && seq[?"wait_move"]){if(actor.v3_active)return;seq[?"wait_move"]=0;}
if(seq[?"wake"]>global.v2_time || global.gameSpeed<=0)return;
var budget=1024;
while(seq[?"script"]!=-1 && budget>0){
    budget-=1;seq[?"wait"]=0;
    global.v3_after_death=dying;
    seq[?"script"]=script_execute(seq[?"script"],seq);
    global.v3_after_death=0;
    if(ds_map_exists(seq,"wait_move") && seq[?"wait_move"])return;
    if(seq[?"wait"]>0){seq[?"wake"]=global.v2_time+seq[?"wait"];return;}
    if(!instance_exists(actor) || (actor.currentHealth<=0 && !dying)){seq[?"script"]=-1;return;}
}
