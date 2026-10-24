// Restores overridden Strength / Agility / Intelligence requirements (scr_v3_req_save)
// after Kingsway recreates the saved items. Runs before the items initialise, like a drop.
var path=string_copy(argument0,1,string_length(argument0)-3)+".v3req"; // world<id>.wr -> .v3req
if(string_copy(argument0,string_length(argument0)-2,3)!=".wr" || !file_exists(path))return;
ini_open(path);
with(obj_ItemBase){
    var s=string(fileID);
    if(ini_section_exists(s)){
        v3_req=1;
        v3_req_str=ini_read_real(s,"strength",requiredStrength);v3_req_agi=ini_read_real(s,"agility",requiredAgility);v3_req_int=ini_read_real(s,"intelligence",requiredIntelligence);
        requiredStrength=v3_req_str;requiredAgility=v3_req_agi;requiredIntelligence=v3_req_int;
    }
}
ini_close();
