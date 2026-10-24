using System;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Globalization;
using System.Text.RegularExpressions;
using System.Security.Cryptography;
using UndertaleModLib;
using UndertaleModLib.Models;
using UndertaleModLib.Decompiler;
using UndertaleModLib.Compiler;
using UndertaleModLib.Util;
using Underanalyzer.Decompiler;
namespace KingswayWorkshop;
public sealed class Game : IDisposable {
 public const string OriginalHash="7BE7530EC424F9F5972E142E08E043B71A94D7E894D95D5A67AC26CB0B9184F9";
 public UndertaleData Data; public GlobalDecompileContext Context; public DecompileSettings Settings=new(); public Dictionary<string,string> Sources=new(StringComparer.Ordinal);
 public Game(string p){using var s=File.OpenRead(p);Data=UndertaleIO.Read(s);Context=new(Data);}
 public static string Hash(string p){using var s=File.OpenRead(p);return Convert.ToHexString(SHA256.HashData(s));}
 public static void VerifyOriginal(string p){if(Hash(p)!=OriginalHash)throw new Exception("Unsupported or altered original data.win. Expected Kingsway 1.2.1 SHA-256 "+OriginalHash);}
 // Uses the V1 backup when one exists; otherwise the Workshop keeps its own copy of the unmodded data.win.
 public static string OriginalPath(string gameRoot){string legacy=Path.Combine(gameRoot,"KingswayModding","backup","data.win");if(File.Exists(legacy))return legacy;string own=Path.Combine(Program.Root,"Recovery","original","data.win");if(File.Exists(own))return own;
  string active=Path.Combine(gameRoot,"data.win");if(!File.Exists(active)||Hash(active)!=OriginalHash)throw new Exception("The Workshop needs the unmodded Kingsway 1.2.1 data.win to make its backup. In Steam, use Properties > Installed Files > Verify integrity of game files, then start the Workshop again.");
  Directory.CreateDirectory(Path.GetDirectoryName(own)!);string temp=own+".tmp";File.Copy(active,temp,true);if(Hash(temp)!=OriginalHash){File.Delete(temp);throw new Exception("Original backup copy did not match; nothing was changed");}File.Move(temp,own);return own;}
 public string Source(string name){if(Sources.TryGetValue(name,out var s))return s;var c=Data.Code.FirstOrDefault(x=>x.Name.Content==name);return Sources[name]=c==null?"":new DecompileContext(Context,c,Settings).DecompileToString();}
 public UndertaleString Str(string s){var v=new UndertaleString(s);Data.Strings.Add(v);return v;}
 public void Write(string p){Directory.CreateDirectory(Path.GetDirectoryName(p)!);using var s=File.Create(p);UndertaleIO.Write(s,Data);}
 public void Dispose(){Data.Dispose();}
 public bool Descends(UndertaleGameObject o,string name){for(var p=o;p!=null;p=p.ParentId){if(p.Name.Content==name)return true;}return false;}
 public Catalog Extract(string dir){
  Directory.CreateDirectory(dir);Directory.CreateDirectory(Path.Combine(dir,"images"));Directory.CreateDirectory(Path.Combine(dir,"source"));
  foreach(var c in Data.Code){var s=Source(c.Name.Content);File.WriteAllText(Path.Combine(dir,"source",c.Name.Content+".gml"),s);}
  var cat=new Catalog{OriginalSha256=OriginalHash};
  using(var worker=new TextureWorker())foreach(var sprite in Data.Sprites){cat.Sprites.Add(sprite.Name.Content);for(int i=0;i<sprite.Textures.Count;i++){var t=sprite.Textures[i]?.Texture;if(t!=null)worker.ExportAsPNG(t,Path.Combine(dir,"images",sprite.Name.Content+"_"+i+".png"),null,true);}}
  var table=Source("gml_Object_obj_EnemyTable_Create_0");
  foreach(Match m in Regex.Matches(table,@"(?m)^(\w+) = ds_list_create\(\);")){
   string n=m.Groups[1].Value;var pool=new Pool{Name=n,Terrain=Regex.Match(n,@"^[a-z]+").Value,Time=n.Contains("Night")?"night":"day / any",Bracket=n.Contains("Low")?"low (1–7; elites 1–9)":n.Contains("Mid")?"middle (8–14)":n.Contains("High")?"high (15+; elites 10+)":"any",Placement=n.Contains("Boss")?"boss":n.Contains("Elites")?"elite":"ordinary"};
   foreach(Match add in Regex.Matches(table,@"ds_list_add\("+n+@", ([0-9]+)\);")){int id=int.Parse(add.Groups[1].Value);if(id<Data.GameObjects.Count)pool.Members.Add(Data.GameObjects[id].Name.Content);}cat.Pools.Add(pool);
  }
  Dictionary<string,Dictionary<string,Field>> fieldCache=new();
  Dictionary<string,Field> Fields(UndertaleGameObject o){
   if(fieldCache.TryGetValue(o.Name.Content,out var cached))return new(cached);
   var f=o.ParentId==null?new Dictionary<string,Field>():Fields(o.ParentId);string code="gml_Object_"+o.Name.Content+"_Create_0";var src=Source(code);
   // Only top-level assignments are considered definite. Branch assignments retain their source expressions.
   int depth=0;foreach(var line in src.Split('\n')){depth+=line.Count(c=>c=='{')-line.Count(c=>c=='}');var a=Regex.Match(line,@"^\s*(\w+(?:\[[^\]]+\])?) = (.*);$");if(!a.Success)continue;var key=a.Groups[1].Value;var expression=a.Groups[2].Value;object v=null;string certainty="dynamic";
    if(depth==0){if(double.TryParse(expression,NumberStyles.Float,CultureInfo.InvariantCulture,out var num)&&double.IsFinite(num)){v=num;certainty="literal";}else if(expression.StartsWith('"')&&expression.EndsWith('"')&&!expression.Contains(" + ")){v=expression.Substring(1,expression.Length-2);certainty="literal";}}
    f[key]=new(){Value=v,Expression=expression,Certainty=certainty,Source=code};
   }fieldCache[o.Name.Content]=new(f);return f;
  }
  foreach(var o in Data.GameObjects){var fields=Fields(o);string name=o.Name.Content;string kind=Descends(o,"obj_Enemy")?"enemy":(fields.TryGetValue("fileType",out var itemType)&&Equals(itemType.Value,"item"))?"item":Descends(o,"obj_StatusEffect")?"status":name.Contains("Projectile",StringComparison.OrdinalIgnoreCase)?"projectile":name.Contains("Summon")?"summon":name.Contains("Quest")||name.Contains("Event_")?"quest":name.Contains("Trap_")||name.Contains("Fireball")||name.Contains("Spike")||name.Contains("Bomb")?"hazard":"object";
   var r=new ReferenceObject{Object=name,Parent=o.ParentId?.Name.Content??"",Kind=kind,Sprite=o.Sprite?.Name.Content??"",Fields=fields};
   string Val(string k,string fallback)=>fields.TryGetValue(k,out var f)&&f.Certainty=="literal"?Convert.ToString(f.Value,CultureInfo.InvariantCulture)??fallback:fallback;
   r.DisplayName=Val("name",name);r.Description=Val("description","");
   if(fields.TryGetValue("sprite_index",out var sf)&&sf.Value is double sid&&sid>=0&&sid<Data.Sprites.Count)r.Sprite=Data.Sprites[(int)sid].Name.Content;
   // Item icons often use a shared sprite sheet with image_index; dynamic indices remain marked in fields.
   int frame=0;if(fields.TryGetValue("image_index",out var ff)&&ff.Value is double fi)frame=(int)fi;
   if(File.Exists(Path.Combine(dir,"images",r.Sprite+"_"+frame+".png")))r.Icon="images/"+r.Sprite+"_"+frame+".png";
   foreach(var p in cat.Pools)if(p.Members.Contains(name))r.Pools.Add(p.Name);
   foreach(var c in Sources.Where(x=>x.Key.StartsWith("gml_Object_"+name+"_",StringComparison.Ordinal))){foreach(Match match in Regex.Matches(c.Value,@"\b(?:obj_|scr_|path_|pth_|spr_)\w+\b"))if(!r.Dependencies.Contains(match.Value))r.Dependencies.Add(match.Value);}
   cat.Objects.Add(r);
   if(kind=="enemy"&&(Val("rank","")=="Boss"||name.Contains("Quest"))){var a=new Adapter{Slot=name,Dependencies=r.Dependencies,ProtectedEvents=Sources.Keys.Where(x=>x.StartsWith("gml_Object_"+name+"_")).OrderBy(x=>x,StringComparer.Ordinal).ToList()};foreach(var c in a.ProtectedEvents)if(Regex.IsMatch(Sources[c],"quest|Quest|drops\\[|flag|complete|Complete|world|World"))a.MandatoryEvidence.Add(c);cat.Adapters.Add(a);}
  }
  for(int i=0;i<Data.Paths.Count;i++){var p=Data.Paths[i];var profile=new PathProfile{Name=p.Name.Content,Smooth=p.IsSmooth,Closed=p.IsClosed};foreach(var pt in p.Points)profile.Points.Add(new[]{(double)pt.X,(double)pt.Y,(double)pt.Speed});foreach(var o in cat.Objects)if(o.Kind=="enemy"&&o.Fields.TryGetValue("path",out var f)&&f.Value is double id&&id==i)profile.Users.Add(o.Object);cat.Paths.Add(profile);}
  foreach(var entry in cat.Objects){if(entry.Fields.TryGetValue("path",out var pf)&&pf.Value is double pi&&pi>=0&&pi<Data.Paths.Count)pf.Value=Data.Paths[(int)pi].Name.Content;foreach(var kv in entry.Fields.Where(x=>System.Text.RegularExpressions.Regex.IsMatch(x.Key,@"^drops\[\d+, 0\]$"))){if(kv.Value.Value is double oi&&oi>=0&&oi<Data.GameObjects.Count)kv.Value.Value=Data.GameObjects[(int)oi].Name.Content;}}Adapters.Configure(cat);Json.Save(Path.Combine(dir,"catalog.json"),cat);return cat;
 }
 public string AddSprite(string name,string file){var gm=GMImage.FromPng(File.ReadAllBytes(file));if(gm.Width<1||gm.Width>2048||gm.Height<1||gm.Height>2048)throw new Exception("PNG dimensions must be 1–2048");var t=new UndertaleEmbeddedTexture{Name=new("Texture "+Data.EmbeddedTextures.Count)};t.TextureData.Image=gm;Data.EmbeddedTextures.Add(t);var p=new UndertaleTexturePageItem{Name=new("PageItem "+Data.TexturePageItems.Count),SourceWidth=(ushort)gm.Width,SourceHeight=(ushort)gm.Height,TargetWidth=(ushort)gm.Width,TargetHeight=(ushort)gm.Height,BoundingWidth=(ushort)gm.Width,BoundingHeight=(ushort)gm.Height,TexturePage=t};Data.TexturePageItems.Add(p);var template=Data.Sprites.First(x=>x.Name.Content=="spr_Skeleton");var spr=new UndertaleSprite{Name=Str(name),Width=(uint)gm.Width,Height=(uint)gm.Height,MarginRight=gm.Width-1,MarginBottom=gm.Height-1,OriginX=gm.Width/2,OriginY=gm.Height/2,IsSpecialType=template.IsSpecialType,SVersion=template.SVersion,GMS2PlaybackSpeed=0,GMS2PlaybackSpeedType=template.GMS2PlaybackSpeedType};spr.Textures.Add(new(){Texture=p});var mask=new UndertaleSprite.MaskEntry{Data=new byte[((gm.Width+7)/8)*gm.Height]};Array.Fill(mask.Data,(byte)255);spr.CollisionMasks.Add(mask);Data.Sprites.Add(spr);return name;}
}
