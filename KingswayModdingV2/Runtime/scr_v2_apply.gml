scr_v2_init();
var cfg = ds_map_find_value(global.v2_registry, argument0);
var key = ds_map_find_first(cfg);
while (!is_undefined(key)) {
    variable_instance_set(id, key, ds_map_find_value(cfg, key));
    key = ds_map_find_next(cfg, key);
}
currentHealth = maxHealth;
healthTween = currentHealth;
v2_enabled = 1;
encounterGroupId = -1;
role = "head";
ownerHeadId = id;
summonerId = noone;
v2_death_done = 0;
v2_components_done = 0;
v2_loot_done = 0;
v2_spawn_time = -100;
v2_structural_amount = 0;
v2_structural_percent = 0;
v2_cooldowns = ds_map_create();
v2_reacting = 0;
v2_toggles = ds_map_create();
v2_move_segment = 0;
v2_move_started = 0;
v2_move_time = 0;
v2_move_wait = 0;
v2_move_direction = 1;
v2_variance_x = 0;
v2_variance_y = 0;
maxMana = 100;
currentMana = 0;
path = v2_path;
pathSpeed = v2_path_speed;

v2_pending=0;v2_expired=0;v2_elapsed=0;v2_offset_x=0;v2_offset_y=0;

// Pitch variance: each spawn sound plays up to half a semitone higher or lower.
var v3_spawn_voice=scr_v2_audio_play(v2_spawn_sound,0);if(v3_spawn_voice>=0 && variable_instance_exists(id,"v3_spawn_pitch") && v3_spawn_pitch)audio_sound_pitch(v3_spawn_voice,power(2,random_range(-.5,.5)/12));

v3_original_sprite=sprite_index;v3_portrait_until=0;v3_active=0;v3_action_mode="";v3_mirrored=v3_random_mirror && random(1)<.5;v3_spawn_active=0;v3_spawn_time=0;v3_radius_active=0;v3_segment_override=0;v3_drag_return=0;v3_drag_index=-1;v3_drag_time=0;
