// Start-menu windows (World, Player, Skills, Status, Quests, Log, Music, Settings,
// Information) and message/confirm windows (Quit, death and other messages).
// Combat status popups ("POISONED!" etc.) are not system windows.
var w=argument0;
switch(w.object_index){
    case obj_WorldWindow:case obj_CharacterWindow:case obj_SkillsWindow:case obj_StatusWindow:case obj_QuestWindow:
    case obj_LogWindow:case obj_MusicPlayer:case obj_SettingsWindow:case obj_DescriptionWindow:return 1;
    case obj_MessageWindow:return !(variable_global_exists("v3_popups") && ds_list_find_index(global.v3_popups,w)>=0);
}
return 0;
