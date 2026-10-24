// Kingsway saves an item's Required level but not its Strength / Agility / Intelligence
// requirements. Loot with "Override requirements" keeps them in a side file next to the
// world save (world<id>.v3req), keyed by the item's fileID; scr_v3_req_load restores them.
var path=argument0;
if(file_exists(path))file_delete(path);
var any=0;
with(obj_ItemBase){if(variable_instance_exists(id,"v3_req") && v3_req)any=1;}
if(!any)return;
ini_open(path);
with(obj_ItemBase){
    if(variable_instance_exists(id,"v3_req") && v3_req){
        var s=string(fileID);
        ini_write_real(s,"strength",v3_req_str);ini_write_real(s,"agility",v3_req_agi);ini_write_real(s,"intelligence",v3_req_int);
    }
}
ini_close();
