using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.Json;
using System.Security.Cryptography;
using System.Diagnostics;
namespace KingswayWorkshop;
public sealed class Server {
 readonly Store store;readonly string token=Convert.ToHexString(RandomNumberGenerator.GetBytes(24));readonly HttpListener listener=new();string origin;
 readonly FightSessions fights;
 public Server(Store s){store=s;fights=new(s);}
 public void Run(bool open){var probe=new TcpListener(IPAddress.Loopback,0);probe.Start();int port=((IPEndPoint)probe.LocalEndpoint).Port;probe.Stop();origin="http://127.0.0.1:"+port;listener.Prefixes.Add(origin+"/");listener.Start();string url=origin+"/#"+token;Json.Save(Path.Combine(store.Root,"server.json"),new{url,pid=Environment.ProcessId});Console.WriteLine(url);if(open)Process.Start(new ProcessStartInfo(url){UseShellExecute=true});while(listener.IsListening){var ctx=listener.GetContext();try{Handle(ctx);}catch(Exception e){Send(ctx,400,"application/json",Encoding.UTF8.GetBytes(Json.Text(new{error=e.Message})));}}}
 static byte[] Read(HttpListenerRequest req,int max=64*1024*1024){if(req.ContentLength64>max)throw new Exception("Request too large");using var ms=new MemoryStream();var buf=new byte[8192];int read;while((read=req.InputStream.Read(buf,0,buf.Length))>0){if(ms.Length+read>max)throw new Exception("Request too large");ms.Write(buf,0,read);}return ms.ToArray();}
 static void Send(HttpListenerContext c,int code,string type,byte[] bytes){c.Response.StatusCode=code;c.Response.ContentType=type;c.Response.Headers["X-Content-Type-Options"]="nosniff";c.Response.Headers["Cache-Control"]="no-store";c.Response.ContentLength64=bytes.Length;c.Response.OutputStream.Write(bytes);c.Response.Close();}
 void Handle(HttpListenerContext c){var req=c.Request;string path=req.Url.AbsolutePath;if(req.Url.Host!="127.0.0.1")throw new Exception("Invalid host");if(req.Headers["Origin"] is string supplied&&supplied!=origin)throw new Exception("Cross-origin requests are forbidden");
  if(path.StartsWith("/api/")){if(req.Headers["X-Workshop-Token"]!=token)throw new Exception("Session token required");string id=req.QueryString["id"]??"";object result=new{ok=true};bool post=req.HttpMethod=="POST";if(req.HttpMethod!="GET"&&!post)throw new Exception("Method not allowed");
   if(path=="/api/audio-preview"){var clip=AudioPreview.Get(store,id,req.QueryString["key"]??"");Send(c,200,clip.mime,clip.data);return;}
   if(!post)result=path switch {"/api/status"=>store.Status(),"/api/fight-status"=>fights.Status(),"/api/removal-info"=>store.RemovalInfo(id),"/api/authoring"=>new{pathSamples=File.Exists(Path.Combine(store.Root,"Evidence","v2-path-samples.json"))?Json.Read<System.Collections.Generic.Dictionary<string,double[][]>>(Path.Combine(store.Root,"Evidence","v2-path-samples.json")):new(),sounds=System.Text.RegularExpressions.Regex.Matches(File.ReadAllText(Path.Combine(store.Root,"Catalog","source","gml_Script_scr_LoadSounds.gml")),@"global\.(sound_\w+) = (\d+);").Select(x=>new{name=x.Groups[1].Value,id=int.Parse(x.Groups[2].Value)}),music=Directory.GetFiles(Path.Combine(store.GameRoot,"Music"),"*.ogg").Select(Path.GetFileNameWithoutExtension),limits=Limits.Rules,hazards=Compiler.SafeHazards,enchantments=Enchantments.Choices,enchantable=store.Catalog.Objects.Where(Enchantments.Supported).Select(x=>new{x.Object,random=Enchantments.Value(x,"unique")!="1"}),statusIcons=new[]{new{family="poison",name="Poison",icon="images/spr_StatusEffectIcons_4.png"},new{family="cold",name="Chill",icon="images/spr_StatusEffectIcons_7.png"},new{family="burn",name="Burn",icon="images/spr_StatusEffectIcons_20.png"},new{family="stun",name="Stun",icon="images/spr_HitEffect_Stun_0.png"},new{family="curse",name="Curse",icon="images/spr_StatusEffectIcons_18.png"}}},"/api/catalog"=>store.Catalog,"/api/projects"=>store.List(),"/api/schema"=>Schema.Create(),"/api/validate"=>store.ValidateProject(id),"/api/gml"=>store.ReadGml(id,req.QueryString["file"]??""),_=>throw new Exception("Unknown read operation")};
   else switch(path){
    case "/api/save":var m=JsonSerializer.Deserialize<Manifest>(Read(req),Json.Options)??throw new Exception("Missing project");store.Save(m);result=m;break;
    case "/api/duplicate-project":result=store.Duplicate(id);break;
    case "/api/remove-project":result=store.Remove(id,JsonDocument.Parse(Read(req)).RootElement.GetProperty("confirmation").GetString());break;
    case "/api/fight-death":result=fights.RequestDeath();break;
    case "/api/stage":store.Stage(id);break;
    case "/api/enable":store.Enable(id,req.QueryString["enabled"]=="true");break;
    case "/api/build":result=store.Build();break;
    case "/api/install":result=store.Install();break;
    case "/api/restore":result=store.Install(true);break;
    case "/api/recover-v1":result=store.Install(false,true);break;
    case "/api/test":result=EngineTests.Run(store);break;case "/api/preview":result=EngineTests.Run(store,id,req.QueryString["enemy"]??"");break;
    case "/api/fight":result=fights.Start(id,req.QueryString["enemy"]??"",JsonSerializer.Deserialize<FightOptions>(Read(req),Json.Options)??throw new Exception("Missing fight options"));break;
    case "/api/import":result=new{id=store.Import(Read(req))};break;
    case "/api/export":c.Response.Headers["Content-Disposition"]="attachment; filename="+id+".kingswaymod.zip";Send(c,200,"application/zip",store.Export(id));return;
    case "/api/audio":result=AssetUploads.Audio(store,id,req.QueryString["name"]??"sound",req.QueryString["kind"]??"sound",req.QueryString["extension"]??".wav",Read(req,32*1024*1024),req.QueryString["filename"]??"");break;
    case "/api/asset":result=AssetUploads.Image(store,id,req.QueryString["name"]??"portrait",Read(req,16*1024*1024));break;
    case "/api/gml":var body=JsonDocument.Parse(Read(req,1024*1024)).RootElement;string file=body.GetProperty("file").GetString();if(!System.Text.RegularExpressions.Regex.IsMatch(file??"",@"^[a-z][a-z0-9_]*\.gml$"))throw new Exception("Invalid GML filename");string dir=store.Project(id);if(body.TryGetProperty("unique",out var unique)&&unique.GetBoolean()){string stem=Path.GetFileNameWithoutExtension(file);int suffix=2;while(File.Exists(Validation.Within(dir,file,false)))file=stem+"_"+(suffix++)+".gml";}File.WriteAllText(Validation.Within(dir,file,false),body.GetProperty("source").GetString());result=new{file};break;
    case "/api/shutdown":Send(c,200,"application/json",Encoding.UTF8.GetBytes("{\"ok\":true}"));listener.Stop();return;
    default:throw new Exception("Unknown operation");
   }Send(c,200,"application/json",Encoding.UTF8.GetBytes(Json.Text(result)));return;
  }
  string filePath;bool html=false;if(path=="/"||path=="/index.html"){filePath=Path.Combine(store.Root,"Web","index.html");html=true;}else if(path.StartsWith("/catalog/"))filePath=Validation.Within(Path.Combine(store.Root,"Catalog"),Uri.UnescapeDataString(path[9..]));else if(path.StartsWith("/project-image/")){var parts=path[15..].Split('/',2);filePath=Validation.Within(store.Project(parts[0]),Uri.UnescapeDataString(parts[1]));if(Path.GetExtension(filePath)!=".png")throw new Exception("Only PNG previews are served");}else filePath=Validation.Within(Path.Combine(store.Root,"Web"),Uri.UnescapeDataString(path[1..]));
  string mime=Path.GetExtension(filePath) switch{".html"=>"text/html; charset=utf-8",".js"=>"text/javascript; charset=utf-8",".css"=>"text/css; charset=utf-8",".png"=>"image/png",".json"=>"application/json",_=>"text/plain; charset=utf-8"};if(html)c.Response.Headers["Content-Security-Policy"]="default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; media-src 'self' blob:; connect-src 'self'; frame-ancestors 'none'";Send(c,200,mime,File.ReadAllBytes(filePath));
 }
}
