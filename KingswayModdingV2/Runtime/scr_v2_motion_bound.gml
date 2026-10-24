var value=argument0;var mode=argument1;
if(mode=="none")return value;
if(mode=="wrap"){if(value<0 || value>1)return ((value mod 1)+1) mod 1;return value;}
if(mode=="reverse")return 1-abs((abs(value) mod 2)-1);
return clamp(value,0,1);
