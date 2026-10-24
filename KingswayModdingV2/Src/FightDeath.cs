using System;
using System.IO;
using System.Diagnostics;
namespace KingswayWorkshop;
public sealed partial class FightSessions {
 Process ownedProcess;string commandFile="",commandToken="";
 public object RequestDeath(){lock(gate){if(ownedProcess==null||ownedProcess.HasExited||monitor==null||monitor.IsCompleted||commandFile=="")throw new Exception("Test death animation is available only while this workshop's isolated playable test is running");string temp=commandFile+".tmp";File.WriteAllText(temp,commandToken+":death");File.Move(temp,commandFile,true);return new{requested=true,pid=ownedProcess.Id,message="Playing the native death animation in the isolated test."};}}
 public static object VerifyDeathCommand(Store store){
  var session=new FightSessions(store);bool rejected=false;try{session.RequestDeath();}catch{rejected=true;}if(!rejected)throw new Exception("Idle controller accepted a death command");
  var started=DateTime.UtcNow;session.Start("","",new(){Mode="level",Level=10,ClassOverride="Mage",Verify="command"});
  string report=Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),"KingswayWorkshopV2Fight","v2-fight.txt");
  try{
   var deadline=DateTime.UtcNow.AddSeconds(50);bool ready=false;while(DateTime.UtcNow<deadline&&!session.monitor.IsCompleted){try{ready=File.Exists(report)&&File.GetLastWriteTimeUtc(report)>=started&&File.ReadAllText(report).Contains("READY:");}catch(IOException){}if(ready)break;System.Threading.Thread.Sleep(100);}if(!ready)throw new Exception("Isolated fight did not become ready for command verification");
   File.WriteAllText(session.commandFile,"invalid-token:death");System.Threading.Thread.Sleep(600);if(session.monitor.IsCompleted)throw new Exception("Unauthenticated command ended the test");
   var requested=DateTime.UtcNow;session.RequestDeath();if(!session.monitor.Wait(TimeSpan.FromSeconds(30)))throw new Exception("Death presentation did not complete");
   var state=System.Text.Json.JsonSerializer.SerializeToElement(session.Status(),Json.Options);string log=state.GetProperty("report").GetString();if(!state.GetProperty("saveIntegrityPassed").GetBoolean()||state.GetProperty("exitCode").GetInt32()!=0||!log.Contains("END: intentional player death")||!log.Contains("DEATH PRESENTATION:")||DateTime.UtcNow-requested<TimeSpan.FromSeconds(2))throw new Exception("Death command verification failed: "+state);
   var result=new{passed=true,idleRejected=rejected,authenticationChecked=true,nativePresentationCompleted=true,session=state};Json.Save(Path.Combine(store.Root,"Evidence","death-command-verification.json"),result);return result;
  }finally{if(session.ownedProcess!=null&&!session.ownedProcess.HasExited){session.ownedProcess.Kill();session.monitor.Wait(TimeSpan.FromSeconds(5));}}
 }
}
