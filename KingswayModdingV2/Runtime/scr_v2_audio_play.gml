var key=argument0;
if(key=="" || !ds_map_exists(global.v2_audio,key))return -1;
var sound=global.v2_audio[?key];
audio_sound_gain(sound,global.volume*global.masterVolume,0);
return audio_play_sound(sound,10,0);
