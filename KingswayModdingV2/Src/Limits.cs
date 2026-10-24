using System;
using System.Collections.Generic;
namespace KingswayWorkshop;
public record NumericLimit(double Min,double Max,string Unit="",double Step=0.01);
public static class Limits {
 public static readonly Dictionary<string,NumericLimit> Rules=new(){
 ["action.windowOffsetX"]=new(-2,2),["action.windowOffsetY"]=new(-2,2),["action.windowMinX"]=new(-2,2),["action.windowMaxX"]=new(-2,2),["action.windowMinY"]=new(-2,2),["action.windowMaxY"]=new(-2,2),["action.windowDuration"]=new(0,3600,"seconds"),["action.attackSpeedValue"]=new(-100000,100000,"native units"),
 ["stats.maxHealth"]=new(1,100000),["stats.default"]=new(0,100000),["advanced.default"]=new(.001,100000),
 ["activationSeconds"]=new(.01,3600,"seconds"),["movement.intensity"]=new(0,1000,"%"),["movement.loopStart"]=new(1,64,"point",1),
 ["movement.bend"]=new(-2,2),["movement.transitionSpeed"]=new(0,10,"screen units/s; 0 = instant"),["movement.gameSpeed"]=new(.01,100,"pixels/frame"),["movement.x"]=new(-1,2),["movement.y"]=new(-1,2),["movement.duration"]=new(.01,3600,"seconds"),["movement.speed"]=new(0,10,"screen units/second"),["movement.wait"]=new(0,3600,"seconds"),["movement.variance"]=new(0,1),["movement.controlX"]=new(-2,3),["movement.controlY"]=new(-2,3),
 ["action.chance"]=new(0,100,"%"),["action.amount"]=new(0,100000),["action.multiplier"]=new(0,100),["action.healPerMana"]=new(0,100),["action.cooldown"]=new(.25,3600,"seconds"),["action.waitMin"]=new(0,3600,"seconds"),["action.pauseBefore"]=new(0,3600,"seconds"),["action.waitMax"]=new(0,3600,"seconds"),["action.interval"]=new(0,3600,"seconds"),["action.repeat"]=new(1,64,"times",1),["action.pathCount"]=new(2,16,"paths",1),["action.pathPoint"]=new(1,64,"point",1),["action.bend"]=new(-2,2),["action.x"]=new(-1,2),["action.y"]=new(-1,2),["action.threshold"]=new(0,100000),["action.minDamage"]=new(0,100000),["action.maxDamage"]=new(0,100000),
 ["loot.chance"]=new(0,100,"%"),["loot.min"]=new(1,100,"items",1),["loot.max"]=new(1,100,"items",1),["loot.minLevel"]=new(1,999,"level",1),["loot.maxLevel"]=new(1,999,"level",1),["loot.weight"]=new(.000001,1000000),["encounters.weight"]=new(0,1000000),
 ["test.level"]=new(1,25,"level",1),["test.quickness"]=new(.01,100),["test.displayWidth"]=new(640,7680,"pixels",1),["test.displayHeight"]=new(480,4320,"pixels",1),["test.gameScale"]=new(1,4,"×",1)
 };
 public static string Check(string key,double value){var r=Rules[key];return !double.IsFinite(value)||value<r.Min||value>r.Max||(r.Step==1&&value!=Math.Truncate(value))?$"Expected {r.Min}–{r.Max} {r.Unit}" : "";}
}
