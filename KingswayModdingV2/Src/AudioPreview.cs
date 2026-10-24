using System;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Text.RegularExpressions;
namespace KingswayWorkshop;
// Lets the editor play Spawn sound / Encounter music choices: project audio,
// vanilla music from Music/*.ogg, and native sounds taken from the verified
// original data.win (extracted once into Catalog/audio, then served from disk).
public static class AudioPreview {
 static readonly object gate=new();
 public static (byte[] data,string mime) Get(Store store,string projectId,string key){
  if(string.IsNullOrWhiteSpace(key))throw new Exception("No audio selected");
  if(projectId!=""){
   string dir=store.Project(projectId);string manifest=Path.Combine(dir,"mod.json");
   if(File.Exists(manifest)){
    using var doc=JsonDocument.Parse(File.ReadAllText(manifest));
    if(doc.RootElement.TryGetProperty("audio",out var audio)&&audio.ValueKind==JsonValueKind.Object&&audio.TryGetProperty(key,out var entry)&&entry.TryGetProperty("file",out var file)){
     string path=Validation.Within(dir,file.GetString()??"");return (File.ReadAllBytes(path),Mime(path));
    }
   }
  }
  string music=Path.Combine(store.GameRoot,"Music",Path.GetFileName(key)+".ogg");
  if(File.Exists(music))return (File.ReadAllBytes(music),"audio/ogg");
  return Native(store,key);
 }
 static (byte[],string) Native(Store store,string key){
  if(!Regex.IsMatch(key,@"^[A-Za-z0-9_]+$"))throw new Exception("Unknown sound");
  string cache=Path.Combine(store.Root,"Catalog","audio");
  lock(gate){
   foreach(var ext in new[]{".wav",".ogg"}){string hit=Path.Combine(cache,key+ext);if(File.Exists(hit))return (File.ReadAllBytes(hit),Mime(hit));}
   if(Directory.Exists(cache)&&File.Exists(Path.Combine(cache,".done")))throw new Exception("Sound not found: "+key);
   Directory.CreateDirectory(cache);
   // global.sound_x = N in scr_LoadSounds names the sound asset index N.
   var aliases=Regex.Matches(File.ReadAllText(Path.Combine(store.Root,"Catalog","source","gml_Script_scr_LoadSounds.gml")),@"global\.(sound_\w+) = (\d+);").GroupBy(m=>int.Parse(m.Groups[2].Value)).ToDictionary(g=>g.Key,g=>g.Select(m=>m.Groups[1].Value).Distinct().ToArray()); // several names can share one sound
   using var game=new Game(store.Original);
   for(int i=0;i<game.Data.Sounds.Count;i++){
    var sound=game.Data.Sounds[i];byte[] bytes=sound.AudioFile?.Data;string ext=".wav";
    if(bytes==null){string external=Path.Combine(store.GameRoot,sound.File?.Content??"");if(sound.File==null||!File.Exists(external))continue;bytes=File.ReadAllBytes(external);ext=Path.GetExtension(external);}
    else if(bytes.Length>4&&bytes[0]=='O'&&bytes[1]=='g'&&bytes[2]=='g')ext=".ogg";
    File.WriteAllBytes(Path.Combine(cache,sound.Name.Content+ext),bytes);
    if(aliases.TryGetValue(i,out var names))foreach(var alias in names)File.WriteAllBytes(Path.Combine(cache,alias+ext),bytes);
   }
   File.WriteAllText(Path.Combine(cache,".done"),"");
   foreach(var ext in new[]{".wav",".ogg"}){string hit=Path.Combine(cache,key+ext);if(File.Exists(hit))return (File.ReadAllBytes(hit),Mime(hit));}
  }
  throw new Exception("Sound not found: "+key);
 }
 static string Mime(string path)=>Path.GetExtension(path).ToLowerInvariant()==".ogg"?"audio/ogg":"audio/wav";
}
