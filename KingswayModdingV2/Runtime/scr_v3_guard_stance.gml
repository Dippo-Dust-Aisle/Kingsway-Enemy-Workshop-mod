// Guard Stance (native passive: "Attack bar slowly fills while blocking"). Kingsway sets
// player.guardStance when it is learned but never reads it, and empties the attack bar
// every frame no skill is charging, which is always the case while blocking. Runs in the
// player's Step in place of that reset: with Guard Stance the bar fills at a quarter of the
// normal Attack charge rate while blocking (chill slows it, stun stops it) and keeps its
// charge after unblocking, so the next skill starts part-way (a full bar attacks at once).
if(!guardStance){attackReady=0;return;}
if(!blocking || stunAmount>0)return;
var rate=0.025;if(instance_exists(obj_Skill_Attack))rate=obj_Skill_Attack.skillSpeed*0.01*0.25;
if(coldAmount>0)rate*=0.4;
attackReady=min(10,attackReady+rate*_gameSpeed);
