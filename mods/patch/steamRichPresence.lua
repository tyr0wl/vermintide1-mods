--[[
	Attempts to enable Steam Rich Presence for Vermintide 1.
	This mod was ported from https://github.com/danreeves/vermintide-2-mods/tree/master/steam-rich-presence to QoL
	Original Author: raindish, Zaphio
]] --

-- local mod = get_mod("steam_rich_presence")

local mod_name = "SteamRichPresence"

local function lobby_level(lobby_data)
    local lvl = lobby_data.selected_level_key or lobby_data.level_key
    local lvl_setting = lvl and LevelSettings[lvl]
    local lvl_display_name = lvl_setting and lvl_setting.display_name
    local lvl_text = lvl_display_name and Localize(lvl_display_name)

    return lvl_text or "No Level"
end

local function lobby_difficulty(lobby_data)
    local diff = lobby_data.difficulty
    local diff_setting = diff and DifficultySettings[diff]
    local diff_display_name = diff_setting and diff_setting.display_name
    local diff_text = diff_display_name and Localize(diff_display_name)

    return diff_text or "No Difficulty"
end

local function lobby_act(lobby_data)
    local act_key = lobby_data.act_key
    return act_key and Localize(act_key .. "_ls" .. test)
end

local function lobby_info_string(lobby_data, num_players)
    return string.format(
        "(%s/4) %s | %s",
        num_players,
        lobby_difficulty(lobby_data),
        lobby_level(lobby_data)
    )
end

local mod = {}

function mod.update_presence()
    if not Managers.state then
        return
    end

    if not Managers.state.network then
        return
    end

    local lobby = Managers.state.network:lobby()
    if not lobby then
        return
    end

    local lobby_data = lobby:get_stored_lobby_data()
    if not lobby_data then
        return
    end

    local num_players = lobby_data.num_players or Managers.player:num_human_players()

    local status = lobby_info_string(lobby_data, num_players)
    Presence.set_presence("status", status)
    Presence.set_presence("steam_display", status)
    Presence.set_presence("steam_player_group", lobby:id())
    Presence.set_presence("steam_player_group_size", num_players)
end

Mods.hook.set(mod_name, "ModManager.on_game_state_changed", function (func, self, status, new_state)
    mod.update_presence()
    func(self, status, new_state)
end)

Mods.hook.set(mod_name, "PlayerManager.add_player", function (func, ...)
    mod.update_presence()
    func(...)
end)

Mods.hook.set(mod_name, "PlayerManager.add_remote_player", function (func, ...)
    mod.update_presence()
    func(...)
end)

Mods.hook.set(mod_name, "PlayerManager.remove_player", function (func, ...)
    mod.update_presence()
    func(...)
end)

Mods.hook.set(mod_name, "PlayerManager.on_exit", function (func, ...)
    mod.update_presence()
    func(...)
end)

mod.update_presence()
