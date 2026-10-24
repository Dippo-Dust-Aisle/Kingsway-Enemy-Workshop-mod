var win=argument0;scr_v2_motion_init(win);
// The native path advances on an invisible driver. Display offsets never alter
// its phase, direction, anchor or speed, and native interpolation stays native.
if(!variable_instance_exists(win,"v2_path_driver") || !instance_exists(win.v2_path_driver)){
    var driver=instance_create_depth(win.x,win.y,0,obj_v2_path_driver);
    driver.v2_window=win;win.v2_path_driver=driver;
    var nativePath=argument1;with(driver)path_start(nativePath,1,1,false);
}
