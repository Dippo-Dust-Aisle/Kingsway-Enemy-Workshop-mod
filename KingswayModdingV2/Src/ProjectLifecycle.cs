using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Runtime.InteropServices;
namespace KingswayWorkshop;
public sealed partial class Store {
 public Manifest Duplicate(string id){using var mutation=MutationLock();var source=List().Single(x=>x.Id==id);var m=Revision.Clone(source);string stem=id[..Math.Min(id.Length,37)]+"_copy",newId=stem;for(int n=2;Directory.Exists(Project(newId))||Directory.Exists(Project(newId,"Mods"));n++)newId=stem+"_"+n;
  string staging=Path.Combine(Root,"Builds","duplicate-"+Guid.NewGuid().ToString("N"));Directory.CreateDirectory(staging);
  try{Revision.CopyFiles(source.Directory,staging);m.Id=newId;m.Name=source.Name+" Copy";m.Directory=staging;
   // Project extension script names are identities, so re-scope them with the copy.
   foreach(var patch in m.Patches)patch.Code=patch.Code.Replace("gml_Script_scr_v2x_"+source.Id+"_","gml_Script_scr_v2x_"+newId+"_");
   Json.Save(Path.Combine(staging,"mod.json"),m);var errors=Validation.Check(new(){m},Catalog);if(errors.Count>0)throw new Exception("Duplicate did not validate: "+Json.Text(errors));Directory.Move(staging,Project(newId));m.Directory=Project(newId);return m;
  }finally{if(Directory.Exists(staging))Directory.Delete(staging,true);}
 }
 public object RemovalInfo(string id){var m=List().Single(x=>x.Id==id);bool installed=false;string active=Game.Hash(Path.Combine(GameRoot,"data.win"));if(File.Exists(LastBuild+".json")){var report=System.Text.Json.JsonDocument.Parse(File.ReadAllText(LastBuild+".json")).RootElement;installed=report.GetProperty("sha256").GetString()==active&&report.GetProperty("loadOrder").EnumerateArray().Any(x=>x.GetString()==id);}return new{m.Id,m.Name,installed,message=installed?"The installed game remains unchanged until managed mods are rebuilt and installed.":"Removing a project does not change the installed game. Rebuild and install managed mods to update it."};}
 public object Remove(string id,string confirmation,Action<string> recycler=null){using var mutation=MutationLock();var m=List().Single(x=>x.Id==id);if(confirmation!=m.Name)throw new Exception("Confirm removal using the current project name");var info=RemovalInfo(id);string source=Project(id),managed=Project(id,"Mods"),backup=Path.Combine(Root,"Recovery","removed-projects",id+"-"+DateTime.UtcNow.ToString("yyyyMMdd-HHmmss-fffffff"));Directory.CreateDirectory(backup);
  Revision.CopyFiles(source,Path.Combine(backup,"project"));bool hadManaged=Directory.Exists(managed);if(hadManaged)Revision.CopyFiles(managed,Path.Combine(backup,"managed"));string enabledPath=Path.Combine(Root,"enabled.json");bool hadEnabled=File.Exists(enabledPath);byte[] enabledBytes=hadEnabled?File.ReadAllBytes(enabledPath):Array.Empty<byte>();if(hadEnabled)File.WriteAllBytes(Path.Combine(backup,"enabled.json"),enabledBytes);
  recycler??=RecycleBin.Move;
  try{var enabled=Enabled();enabled.Remove(id);Json.Save(enabledPath,enabled);if(hadManaged)recycler(managed);recycler(source);if(Directory.Exists(source)||Directory.Exists(managed))throw new Exception("Recycle Bin did not remove the selected project");return new{removed=id,recovery=backup,installation=info};}
  catch(Exception ex){
   void Recover(string from,string to){Directory.CreateDirectory(to);foreach(var file in Directory.GetFiles(from,"*",SearchOption.AllDirectories)){string target=Validation.Within(to,Path.GetRelativePath(from,file),false);Directory.CreateDirectory(Path.GetDirectoryName(target));if(!File.Exists(target))File.Copy(file,target);}}
   try{Recover(Path.Combine(backup,"project"),source);if(hadManaged)Recover(Path.Combine(backup,"managed"),managed);if(hadEnabled)File.WriteAllBytes(enabledPath,enabledBytes);else if(File.Exists(enabledPath))File.Delete(enabledPath);}catch(Exception recovery){throw new Exception("Removal failed and recovery needs attention. Complete backup: "+backup+". "+ex.Message+"; "+recovery.Message);}
   throw new Exception("Removal failed; project and managed state were recovered. Backup: "+backup+". "+ex.Message);
  }
 }
}
