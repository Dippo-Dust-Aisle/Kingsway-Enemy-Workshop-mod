var win=argument0;var px=scr_v3_icon_x(win,argument1);if(px<0)return 0;
return mouse_x>=win.x+px && mouse_x<win.x+px+12 && mouse_y>=win.y+3 && mouse_y<win.y+15;
