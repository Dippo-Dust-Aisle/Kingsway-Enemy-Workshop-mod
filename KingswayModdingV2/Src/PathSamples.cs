using System.Text;
namespace KingswayWorkshop;
public sealed partial class Compiler {
 void SamplePaths(){var code=new StringBuilder("var file=file_text_open_write(\"v2-path-samples.json\");file_text_write_string(file,\"{\");");bool first=true;foreach(var path in catalog.Paths){if(!first)code.Append("file_text_write_string(file,\",\");");first=false;code.Append("file_text_write_string(file,"+Q(Q(path.Name)+":[")+");for(var i=0;i<=2000;i+=1){if(i>0)file_text_write_string(file,\",\");var t=i/2000;file_text_write_string(file,\"[\"+string_format(path_get_x("+path.Name+",t),0,6)+\",\"+string_format(path_get_y("+path.Name+",t),0,6)+\",\"+string_format(path_get_speed("+path.Name+",t),0,6)+\"]\");}file_text_write_string(file,\"]\");");}code.Append("file_text_write_string(file,\"}\");file_text_close(file);");Queue("gml_Script_scr_v2_test_path_samples",code.ToString());}
}
