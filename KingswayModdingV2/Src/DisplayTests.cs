using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text.Json;
using UndertaleModLib.Models;
namespace KingswayWorkshop;
public sealed partial class FightSessions {
 static object VerifyDisplay(Store store){
  var results=new List<object>();
  foreach(var test in new[]{("level",false,1280,720,2),("level",true,1280,720,2),("random",false,1366,768,2),("random",true,1366,768,2),("level",true,7680,4320,4)}){
   string before=LaunchWindow.DesktopDimensions();
   var options=new FightOptions{Mode=test.Item1,Verify="escape",ClassOverride="Mage",Level=10,Fullscreen=test.Item2,DisplayWidth=test.Item3,DisplayHeight=test.Item4,GameScale=test.Item5};
   var session=new FightSessions(store);var started=JsonSerializer.SerializeToElement(session.Start("","",options),Json.Options);
   bool initialFlags;
   using(var game=new Game(Path.Combine(store.GameRoot,"data.v2-fight.win"))){initialFlags=game.Data.Options.Info.HasFlag(UndertaleOptions.OptionsFlags.FullScreen)==options.Fullscreen&&game.Data.GeneralInfo.Info.HasFlag(UndertaleGeneralInfo.InfoFlags.Fullscreen)==options.Fullscreen&&!game.Data.Options.Info.HasFlag(UndertaleOptions.OptionsFlags.ChangeResolution);}
   if(!session.monitor.Wait(TimeSpan.FromSeconds(55))){using var owned=Process.GetProcessById(started.GetProperty("pid").GetInt32());if(!owned.HasExited)owned.Kill();session.monitor.Wait(TimeSpan.FromSeconds(5));throw new Exception("Display verification timed out");}
   var result=JsonSerializer.SerializeToElement(session.Status(),Json.Options);string report=result.GetProperty("report").GetString()??"";string after=LaunchWindow.DesktopDimensions();
   bool passed=initialFlags&&before==after&&result.GetProperty("saveIntegrityPassed").GetBoolean()&&result.GetProperty("exitCode").GetInt32()==0&&report.Contains("END: escaped")&&!report.Contains("FAIL:")&&report.Contains("PASS: requested display mode and logical dimensions")&&report.Contains("requestedFullscreen="+(options.Fullscreen?1:0)+" actualFullscreen="+(options.Fullscreen?1:0));
   results.Add(new{passed,requested=options,initialFlags,desktopBefore=before,desktopAfter=after,session=result});
   Json.Save(Path.Combine(store.Root,"Evidence","display-verification.json"),new{passed=results.All(x=>JsonSerializer.SerializeToElement(x,Json.Options).GetProperty("passed").GetBoolean()),cases=results});
   if(!passed)throw new Exception("Display verification failed: "+result);
  }
  return new{passed=true,cases=results};
 }
}
