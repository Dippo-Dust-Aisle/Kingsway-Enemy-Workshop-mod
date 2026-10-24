using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading.Tasks;
namespace KingswayWorkshop;
public sealed partial class FightSessions {
 readonly Store store;readonly object gate=new();object state=new{running=false};Task monitor;
 public FightSessions(Store s){store=s;}
 public object Status(){lock(gate)return state;}
 public object Start(string project,string enemy,FightOptions options){lock(gate){
  if(monitor!=null&&!monitor.IsCompleted)throw new Exception("Finish the current test fight first");Store.Closed();
  commandToken=Convert.ToHexString(System.Security.Cryptography.RandomNumberGenerator.GetBytes(24));commandFile=Path.Combine(store.Root,"Builds","fight-"+commandToken+".command");options.CommandToken=commandToken;options.CommandFile=commandFile;
  var before=Snapshot();store.Build(true,project,enemy,options);var start=DateTime.UtcNow;
  var psi=new ProcessStartInfo(Path.Combine(store.GameRoot,"Kingsway.exe")){WorkingDirectory=store.GameRoot,UseShellExecute=false,WindowStyle=ProcessWindowStyle.Normal,RedirectStandardOutput=true,RedirectStandardError=true};
  psi.ArgumentList.Add("-game");psi.ArgumentList.Add(Path.Combine(store.GameRoot,"data.v2-fight.win"));psi.ArgumentList.Add("-debugoutput");psi.ArgumentList.Add(Path.Combine(store.Root,"Evidence","fight-debug.log"));
  var proc=Process.Start(psi)??throw new Exception("Kingsway could not start");ownedProcess=proc;var output=new System.Text.StringBuilder();void Capture(string line){if(line!=null)lock(output){output.AppendLine(line);if(output.Length>200000)output.Remove(0,output.Length-160000);}}proc.OutputDataReceived+=(s,e)=>Capture(e.Data);proc.ErrorDataReceived+=(s,e)=>Capture(e.Data);proc.BeginOutputReadLine();proc.BeginErrorReadLine();_ = LaunchWindow.Focus(proc);int pid=proc.Id;state=new{running=true,pid,mode=options.Mode,level=options.Level,started=start};
  monitor=Task.Run(async()=>{try{while(!proc.HasExited){string native=LaunchWindow.Diagnostics(proc);if(native!=""){Capture(native);lock(gate)state=new{running=true,pid,error="Kingsway reported a native error. Close the test game to finish.",details=native};}await Task.Delay(500);}await proc.WaitForExitAsync();var after=Snapshot();bool unchanged=before.Count==after.Count&&before.All(x=>after.TryGetValue(x.Key,out var h)&&h==x.Value);string file=Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),"KingswayWorkshopV2Fight","v2-fight.txt");string report=File.Exists(file)&&File.GetLastWriteTimeUtc(file)>=start?File.ReadAllText(file):"";string details;lock(output)details=output.ToString();File.WriteAllText(Path.Combine(store.Root,"Evidence","fight-console.log"),details);string error="";if(!report.Contains("END:")||proc.ExitCode!=0){var lines=details.Split('\n');var marker=Array.FindIndex(lines,l=>l.Contains("FATAL ERROR")||l.Contains("ERROR in action")||l.Contains("not set before reading"));error=marker>=0?string.Join("\n",lines.Skip(Math.Max(0,marker-1)).Take(14)):"The game exited without an encounter completion report (exit code "+proc.ExitCode+"). No useful native error was captured.";}var context=details.Split('\n').LastOrDefault(l=>l.StartsWith("WORKSHOP:"))??"";var result=new{running=false,pid,error,context,details,mode=options.Mode,level=options.Level,saveFilesUnchanged=unchanged?before.Count:0,saveIntegrityPassed=unchanged,exitCode=proc.ExitCode,report,ended=DateTime.UtcNow};Json.Save(Path.Combine(store.Root,"Evidence","fight-session.json"),result);lock(gate)state=result;}catch(Exception e){lock(gate)state=new{running=false,error=e.Message};}finally{lock(gate){ownedProcess=null;if(File.Exists(commandFile))File.Delete(commandFile);commandFile="";commandToken="";}proc.Dispose();}});
  return state;
 }}
 static Dictionary<string,string> Snapshot(){string dir=Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),"Kingsway");return Directory.Exists(dir)?Directory.GetFiles(dir,"*",SearchOption.AllDirectories).ToDictionary(p=>p,Game.Hash):new();}
 public static object Verify(Store store,string only=""){
  if(only=="display")return VerifyDisplay(store);if(only=="command")return VerifyDeathCommand(store);
  var results=only!=""&&File.Exists(Path.Combine(store.Root,"Evidence","fight-verification.json"))?Json.Read<List<System.Text.Json.JsonElement>>(Path.Combine(store.Root,"Evidence","fight-verification.json")).Cast<object>().ToList():new List<object>();var cases=new[]{("level","escape","Mage",10),("level","close","Mage",10),("level","death","Mage",10),("level","hazardclose","Mage",10),("random","loot","Warrior",10),("random","escape","Mage",1),("random","escape","Worthless",1),("random","escape","Adventurer",10),("random","escape","Rogue",10),("random","escape","Beastkin",10),("random","escape","Ascended",25),("random","escape","Demonblood",10),("random","escape","Necromancer",10)};
  foreach(var test in cases.Where(x=>only==""||x.Item3==only||x.Item2==only)){
   var session=new FightSessions(store);var started=System.Text.Json.JsonSerializer.SerializeToElement(session.Start("","",new(){Mode=test.Item1,Verify=test.Item2,ClassOverride=test.Item3,Level=test.Item4}),Json.Options);
   if(!session.monitor.Wait(TimeSpan.FromSeconds(55))){using var owned=Process.GetProcessById(started.GetProperty("pid").GetInt32());if(!owned.HasExited)owned.Kill();session.monitor.Wait(TimeSpan.FromSeconds(5));throw new Exception("Fight verification timed out. The owned test process was closed; see fight-debug.log");}
   var result=System.Text.Json.JsonSerializer.SerializeToElement(session.Status(),Json.Options);string report=result.GetProperty("report").GetString()??"";
   if(report.Contains("FAIL:")||!result.GetProperty("saveIntegrityPassed").GetBoolean()||result.GetProperty("exitCode").GetInt32()!=0||!report.Contains("END: "+(test.Item2=="escape"?"escaped":test.Item2=="death"?"defeated":"looted"))||!report.Contains("PASS: playable session")||!report.Contains(" / "+test.Item3+" / level "+test.Item4))throw new Exception("Fight verification failed: "+result);
   if(report.Split("SKILL ").Length!=6)throw new Exception("Five battle skills were not assigned");if(test.Item1=="level"&&(!report.Contains("Fireball II")||!report.Contains("Chill II")))throw new Exception("Level Test skills incorrect");if(test.Item1=="random"&&report.Split("GEAR ").Length!=9)throw new Exception("Random Fight did not fill all eight slots");
   string save=Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),"KingswayWorkshopV2Fight");foreach(string name in new[]{"v2-fight-ready.png","v2-fight-loot.png"})if(File.Exists(Path.Combine(save,name)))File.Copy(Path.Combine(save,name),Path.Combine(store.Root,"Evidence",test.Item3+"-"+test.Item4+"-"+name),true);
   results.Add(session.Status());Json.Save(Path.Combine(store.Root,"Evidence","fight-verification.json"),results);
  }return results;
 }
}
