var requested="";var live=0;
with(obj_Enemy){if(variable_instance_exists(id,"v2_enabled") && currentHealth>0 && !escaped){if(!v2_expired || v2_pending>0){live+=1;if(requested=="" && v2_music!="")requested=v2_music;}}}
if(global.v2_music_stream==-1 && requested!=""){
    var file="Music/"+requested+".ogg";
    if(ds_map_exists(global.v2_music_paths,requested))file=global.v2_music_paths[?requested];
    var stream=audio_create_stream(file);
    if(stream!=-1){global.v2_music_stream=stream;global.v2_music_paused=-1;
        with(obj_MusicPlayer){if(currentSong!=-4 && audio_is_playing(currentSong) && !audio_is_paused(currentSong)){global.v2_music_paused=currentSong;audio_pause_sound(currentSong);}}
        audio_sound_gain(stream,global.musicVolume*global.masterVolume,0);audio_play_sound(stream,10,1);
    }
}
if(global.v2_music_stream!=-1){
    audio_sound_gain(global.v2_music_stream,global.musicVolume*global.masterVolume,0);
    if(live==0){audio_stop_sound(global.v2_music_stream);audio_destroy_stream(global.v2_music_stream);global.v2_music_stream=-1;if(global.v2_music_paused!=-1 && audio_is_paused(global.v2_music_paused))audio_resume_sound(global.v2_music_paused);global.v2_music_paused=-1;}
}
