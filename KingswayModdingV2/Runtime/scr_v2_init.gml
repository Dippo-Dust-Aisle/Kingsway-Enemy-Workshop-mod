if (variable_global_exists("v2_registry")) return;

global.v2_registry = ds_map_create();
global.v2_groups = ds_map_create();
global.v2_weights = ds_map_create();
global.v2_time = 0;
global.v2_sequences=ds_list_create();
global.v2_context="";global.v2_spawning_projectile=0;
global.v3_after_death=0;global.v3_gone_self=0;global.v3_gone_depth=0;
global.v3_hit_magic=0;global.v3_cast_spell=-4;global.v3_cast_hits=-1;
global.v2_group_serial = 0;
global.v2_audio=ds_map_create();global.v2_music_paths=ds_map_create();global.v2_music_stream=-1;global.v2_music_paused=-1;scr_v2_audio_registry();
scr_v2_registry();
