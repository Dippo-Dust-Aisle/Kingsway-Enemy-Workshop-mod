using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.Loader;
namespace KingswayWorkshop;
public static class Program {
 public static string Root=AppContext.BaseDirectory.TrimEnd(Path.DirectorySeparatorChar);
 public static string GameRoot=Path.GetDirectoryName(Root)!;
 public static int Main(string[] args){
  var lib=Path.Combine(GameRoot,"UndertaleModdingTool");AssemblyLoadContext.Default.Resolving+=(ctx,name)=>{var p=Path.Combine(lib,name.Name+".dll");return File.Exists(p)?ctx.LoadFromAssemblyPath(p):null;};
  Environment.SetEnvironmentVariable("PATH",lib+Path.PathSeparator+Environment.GetEnvironmentVariable("PATH"));
  try{return Run(args);}catch(Exception e){Console.Error.WriteLine(e);File.WriteAllText(Path.Combine(Root,"startup-error.txt"),e.ToString());return 1;}
 }
 static int Run(string[] args){var original=Game.OriginalPath(GameRoot);Game.VerifyOriginal(original);var cmd=args.FirstOrDefault()??"serve";
  if(cmd=="catalog"){using var game=new Game(original);var cat=game.Extract(Path.Combine(Root,"Catalog"));Console.WriteLine($"Catalog: {cat.Objects.Count} objects, {cat.Objects.Count(x=>x.Kind=="enemy")} enemies, {cat.Objects.Count(x=>x.Kind=="item")} items, {cat.Paths.Count} paths");return 0;}
  if((cmd=="serve"||cmd=="stop")&&File.Exists(Path.Combine(Root,"server.json"))){try{var state=System.Text.Json.JsonDocument.Parse(File.ReadAllText(Path.Combine(Root,"server.json"))).RootElement;var address=new Uri(state.GetProperty("url").GetString());if(address.Host=="127.0.0.1"&&address.Scheme=="http"){using var client=new System.Net.Http.HttpClient{Timeout=TimeSpan.FromSeconds(2)};client.DefaultRequestHeaders.Add("X-Workshop-Token",address.Fragment.TrimStart('#'));var baseUrl=address.GetLeftPart(UriPartial.Authority);var response=cmd=="stop"?client.PostAsync(baseUrl+"/api/shutdown",new System.Net.Http.StringContent("{}")).GetAwaiter().GetResult():client.GetAsync(baseUrl+"/api/status").GetAwaiter().GetResult();if(response.IsSuccessStatusCode){if(cmd=="serve"&&!args.Contains("--no-open"))System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo(address.ToString()){UseShellExecute=true});return 0;}}}catch{}}if(cmd=="stop")return 0;
  if(!File.Exists(Path.Combine(Root,"Catalog","catalog.json"))){using var game=new Game(original);game.Extract(Path.Combine(Root,"Catalog"));}
  var store=new Store(Root,GameRoot);Json.Save(Path.Combine(Root,"Docs","manifest.schema.json"),Schema.Create());if(cmd=="serve"){new Server(store).Run(!args.Contains("--no-open"));return 0;}
  object result=cmd switch {
   "minimizetest"=>EngineTests.Run(store,minimizeOnly:true),"fighttest"=>FightSessions.Verify(store,args.Skip(1).FirstOrDefault()??""),"selftest"=>SelfTests.Run(store),"revisiontest"=>RevisionTests.Run(store),"test"=>EngineTests.Run(store),"status"=>store.Status(),"build"=>store.Build(args.Contains("--test")),"install"=>store.Install(),"restore"=>store.Install(true),"recover-v1"=>store.Install(false,true),"validate"=>Validation.Check(store.Active(),store.Catalog),"import"=>args.Skip(1).Select(p=>{try{return (object)new{file=Path.GetFileName(p),id=store.Import(File.ReadAllBytes(p))};}catch(Exception e){return new{file=Path.GetFileName(p),error=e.Message};}}).ToArray(),_=>throw new Exception("Unknown command: "+cmd)
  };Console.WriteLine(Json.Text(result));return 0;
 }
}
