// Distance between two normalized positions measured in real screen pixels,
// expressed in screen widths. Normalized x and y span different pixel ranges
// (width vs height), so plain point_distance made vertical travel slower.
var win=argument0;
var rw=max(1,global.resolutionW/global.gameScale-win.width);var rh=max(1,global.resolutionH/global.gameScale-win.height-24);
return point_distance(argument1*rw,argument2*rh,argument3*rw,argument4*rh)/rw;
