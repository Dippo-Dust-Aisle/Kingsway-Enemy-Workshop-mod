using System;
using System.Linq;
using ImageMagick;
namespace KingswayWorkshop;
public static class AssetValidation {
 public static void Png(byte[] bytes){
  if(bytes.Length<24||bytes.Length>16*1024*1024||!bytes.Take(8).SequenceEqual(new byte[]{137,80,78,71,13,10,26,10}))throw new Exception("Choose a PNG image no larger than 16 MB");
  int width=System.Buffers.Binary.BinaryPrimitives.ReadInt32BigEndian(bytes.AsSpan(16,4)),height=System.Buffers.Binary.BinaryPrimitives.ReadInt32BigEndian(bytes.AsSpan(20,4));
  if(width<1||height<1||width>2048||height>2048)throw new Exception("PNG dimensions must be 1–2048 pixels on each side");
  try{using var image=new MagickImage(bytes);if(image.Width!=width||image.Height!=height)throw new Exception("Invalid image dimensions");}catch(Exception e){throw new Exception("The PNG could not be decoded: "+e.Message);}
 }
}
