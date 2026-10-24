using System;
using System.IO;
using System.Linq;
namespace KingswayWorkshop;
public static class AssetUploads {
 public record ImageUpload(string Name,string File);
 public record AudioUpload(string Name,AudioAsset Audio);
 static string NewName(string prefix){
  if(!Validation.Identifier(prefix))throw new Exception("Invalid asset ID");
  return prefix[..Math.Min(prefix.Length,15)]+"_"+Guid.NewGuid().ToString("N");
 }
 public static ImageUpload Image(Store store,string id,string prefix,byte[] bytes){
  AssetValidation.Png(bytes);
  var project=store.List().First(x=>x.Id==id);
  string name=NewName(prefix),file=name+".png",dest=Validation.Within(project.Directory,file,false);
  // Every upload is a new asset, even when several enemies used the same old
  // portrait. Never overwrite or delete an existing user image.
  using(var output=new FileStream(dest,FileMode.CreateNew,FileAccess.Write))output.Write(bytes);
  project.Assets.Add(name,file);store.Save(project);return new(name,file);
 }
 public static AudioUpload Audio(Store store,string id,string prefix,string kind,string extension,byte[] bytes,string originalFilename=""){
  string name=AudioAssets.NewId(store.List().First(x=>x.Id==id),originalFilename==""?prefix:originalFilename);
  var project=AudioAssets.Import(store,id,name,kind,extension,bytes,originalFilename);
  return new(name,project.Audio[name]);
 }
}
