--[[
	Provides settings to stream line the true solo experience in vermintide 1.
	This version was modified to be usuable with bots and had other smaller adjustments done.
	Author: Prop joe, j_sat
]]--

local mod_name = "TrueSolo"

local user_setting = Application.user_setting

local MOD_SETTINGS = {
	ENABLED = {
		["save"] = "cb_true_solo",
		["widget_type"] = "stepper",
		["text"] = "True Solo Mode",
		["tooltip"] = "True Solo Mode\n" ..
			"Gameplay modifications aimed at solo play.\n",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
		["hide_options"] = {
			{
				false,
				mode = "hide",
				options = {
					"cb_true_solo_hide_frames",
					"cb_true_solo_assassin_spawn_sound",
					"cb_true_solo_no_hordes_when_ogre_alive",
					"cb_true_solo_orge_dmg_taken",
					"cb_true_solo_specials_ratio",
					"cb_true_solo_horde_size",
					"cb_true_solo_skip_cutscenes",
				}
			},
			{
				true,
				mode = "show",
				options = {
					"cb_true_solo_kill_bots",
					"cb_true_solo_hide_frames",
					"cb_true_solo_assassin_spawn_sound",
					"cb_true_solo_no_hordes_when_ogre_alive",
					"cb_true_solo_orge_dmg_taken",
					"cb_true_solo_specials_ratio",
					"cb_true_solo_horde_size",
					"cb_true_solo_skip_cutscenes",
				}
			},
		},
	},
	KILL_BOTS = {
		["save"] = "cb_true_solo_kill_bots",
		["widget_type"] = "stepper",
		text = "Kill Bots",
		tooltip = "Automatically kills bots",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
	},
	HIDE_OTHER_FRAMES = {
		["save"] = "cb_true_solo_hide_frames",
		["widget_type"] = "stepper",
		text = "Remove Other Player/Bot UI",
		tooltip = "Remove Other Player/Bot UI\n" ..
				"Hide the UI elements of other players or bots",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
	},
	ASSASSIN_SPAWN_SOUND = {
		["save"] = "cb_true_solo_assassin_spawn_sound",
		["widget_type"] = "stepper",
		text = "Assassin Spawn Sound",
		tooltip = "Assassin Spawn Sound\n" ..
				"Use different assassin spawn sound to prevent silend spawns.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
	},
	NO_HORDES_WHEN_OGRE_ALIVE = {
		["save"] = "cb_true_solo_no_hordes_when_ogre_alive",
		["widget_type"] = "stepper",
		["text"] = "No Hordes When Ogre Alive",
		["tooltip"] = "No Hordes When Ogre Alive\n" ..
			"Delay horde while an orge alive.\n",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
	},
	ORGE_DMG_TAKEN = {
		["save"] = "cb_true_solo_orge_dmg_taken",
		["widget_type"] = "dropdown",
		["text"] = "Ogre Damage Taken Multiplier",
		["tooltip"] =  "Ogre Damage Taken Multiplier\n" ..
			"Ogre will take damage multiplied by a value.",
		["value_type"] = "number",
		["options"] = {
			{text = "1x", value = 1},
			{text = "1.75x", value = 2},
			{text = "2.5x", value = 3},
		},
		["default"] = 1, -- 1x
	},
	SPECIALS_RATIO = {
		["save"] = "cb_true_solo_specials_ratio",
		["widget_type"] = "dropdown",
		["text"] = "Specials Ratio",
		["tooltip"] =  "Specials Ratio\n" ..
			"Change ratio of spawned specials:\n" ..
			"Default: Don't change anything\n" ..
			"Less disablers: 40%, 40%, 10%, 10%\n" ..
			"No disablers: 50%, 50%, 0%, 0%\n",
		["value_type"] = "number",
		["options"] = {
			{text = "Default", value = 1},
			{text = "Less disablers", value = 2},
			{text = "No disablers", value = 3},
		},
		["default"] = 1, -- Default
	},
	HORDE_SIZE = {
		["save"] = "cb_true_solo_horde_size",
		["widget_type"] = "slider",
		["text"] = "Horde Size",
		["tooltip"] =  "Horde Size\n" ..
			"Adjust horde size. 300 = 3x",
		["range"] = {10, 300},
		["default"] = 100,
	},
	SKIP_CUTSCENES = {
		["save"] = "cb_true_solo_skip_cutscenes",
		["widget_type"] = "stepper",
		text = "Skip Cutscenes",
		tooltip = "Skip Cutscenes\n" ..
				"Allows you to skip cutscenes by pressing space.",
		["value_type"] = "boolean",
		["options"] = {
			{text = "Off", value = false},
			{text = "On", value = true},
		},
		["default"] = 1, -- Off
	},
}

TrueSolo = TrueSolo or {}
TrueSolo.ogres = TrueSolo.ogres or {}

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

--- shrink or increase horde size
local function adjust_horde_sizes(horde_ratio)
	if not Mods.CurrentHordeSettings_compositions_backup then
	    Mods.CurrentHordeSettings_compositions_backup = {}
	end

	if not CurrentHordeSettings.compositions then
		return
		--CurrentHordeSettings.compositions = HordeSettings.default.compositions
	end

	for event_name, event_table in pairs(CurrentHordeSettings.compositions) do
	    local event_table_length = tablelength(event_table)
	    local index = 0
	    for event_table_index, event_table_value in pairs(event_table) do
	        index = index + 1
	        if index < event_table_length then
	            for table_with_breeds_index, table_with_breeds in pairs(event_table_value) do
	                if type(table_with_breeds) == "table" then
	                    for breed_index, breed_value in pairs(table_with_breeds) do
	                        if type(breed_value) == "table" then
	                            for breed_name, breed_num in pairs(breed_value) do
	                                if type(breed_num) == "number" then
	                                    local key = "CurrentHordeSettings.compositions['"..event_name.."']["..event_table_index.."]['"..table_with_breeds_index.."']["..breed_index.."]["..breed_name.."]"
	                                    if not Mods.CurrentHordeSettings_compositions_backup[key] then
	                                        Mods.CurrentHordeSettings_compositions_backup[key] = CurrentHordeSettings.compositions[event_name][event_table_index][table_with_breeds_index][breed_index][breed_name]
	                                    end
	                                    local new_breed_num = math.ceil(Mods.CurrentHordeSettings_compositions_backup[key] * horde_ratio)
	                                    loadstring(key.." = "..tostring(new_breed_num))()
	                                end
	                            end
	                        elseif type(breed_value) == "number" then
	                            local key = "CurrentHordeSettings.compositions['"..event_name.."']["..event_table_index.."]['"..table_with_breeds_index.."']["..breed_index.."]"
	                            if not Mods.CurrentHordeSettings_compositions_backup[key] then
	                                Mods.CurrentHordeSettings_compositions_backup[key] = CurrentHordeSettings.compositions[event_name][event_table_index][table_with_breeds_index][breed_index]
	                            end
	                            local new_breed_num = math.ceil(Mods.CurrentHordeSettings_compositions_backup[key] * horde_ratio)
	                            loadstring(key.." = "..tostring(new_breed_num))()
	                        end
	                    end
	                end
	            end
	        end
	    end
	end
end

--- mod logic, mod menu options changes tracking and autokill bots on round start
Mods.hook.set(mod_name, "MatchmakingManager.update", function(func, self, ...)
	func(self, ...)

	for i, ogre in ipairs(TrueSolo.ogres) do
		if not Unit.alive(ogre) then
			table.remove(TrueSolo.ogres, i)
		end
	end

	local true_solo_enabled = user_setting(MOD_SETTINGS.ENABLED.save)
	local skip_cutscenes_enabled = user_setting(MOD_SETTINGS.SKIP_CUTSCENES.save)

	local horde_size_ratio = user_setting(MOD_SETTINGS.HORDE_SIZE.save)
	local ratio = true_solo_enabled and horde_size_ratio / 100 or 1
	local kill_bots = user_setting(MOD_SETTINGS.KILL_BOTS.save)

	-- adjust hordes when true solo mode gets toggled
	if true_solo_enabled ~= rawget(_G, "_true_solo_mode_enabled") then
		adjust_horde_sizes(ratio)
		rawset(_G, "_true_solo_mode_enabled", true_solo_enabled)
	end

	-- adjust cutscene skip when true solo mode and skip cutscenes are changed in mod menu options
	if skip_cutscenes_enabled ~= rawget(_G, "_skip_cutscenes_enabled") then
		script_data.skippable_cutscenes = true_solo_enabled and skip_cutscenes_enabled or false
		rawset(_G, "_skip_cutscenes_enabled", skip_cutscenes_enabled)
	end

	if not self.last_horde_size_ratio then
		self.last_horde_size_ratio = horde_size_ratio
	end
	if true_solo_enabled and self.last_horde_size_ratio ~= horde_size_ratio then
		adjust_horde_sizes(horde_size_ratio / 100)
	end

	self.last_horde_size_ratio = horde_size_ratio
	if self.adjust_hordes_next_round_start == nil then
		self.adjust_hordes_next_round_start = true
	end

	if true_solo_enabled then
		local game_mode_manager = Managers.state.game_mode
		if game_mode_manager then
			local round_started = game_mode_manager.is_round_started(game_mode_manager)

			if not round_started then
				if self.adjust_hordes_next_round_start then
					adjust_horde_sizes(ratio)
					self.adjust_hordes_next_round_start = false
				end

				if kill_bots then
					for _, player in pairs(Managers.player:bots()) do
						local status_extension = nil
						if player.player_unit then
							status_extension = ScriptUnit.extension(player.player_unit, "status_system")
						end
						if status_extension and not status_extension.is_ready_for_assisted_respawn(status_extension) then
							StatusUtils.set_dead_network(player.player_unit, true)
						end
					end
				end

			else
				self.adjust_hordes_next_round_start = true
			end
		end
	end
end)

--- delay horde while ogre alive
Mods.hook.set(mod_name, "ConflictDirector.update_horde_pacing", function (func, self, t, dt)
	if not user_setting(MOD_SETTINGS.ENABLED.save) or not user_setting(MOD_SETTINGS.NO_HORDES_WHEN_OGRE_ALIVE.save) then
		return func(self, t, dt)
	end

	if #TrueSolo.ogres > 0 and self._next_horde_time and self._next_horde_time < t then
		self._next_horde_time = t + 1
	end

	return func(self, t, dt)
end)

--- ogre damage taken modifier
local ORGE_DMG_TAKEN_1 = 1
local ORGE_DMG_TAKEN_2 = 2
local ORGE_DMG_TAKEN_3 = 3

Mods.hook.set(mod_name, "DamageUtils.add_damage_network", function(func, attacked_unit, attacker_unit, original_damage_amount, ...)
	if not user_setting(MOD_SETTINGS.ENABLED.save) then
		return func(attacked_unit, attacker_unit, original_damage_amount, ...)
	end

	local breed = Unit.get_data(attacked_unit, "breed")
	if breed ~= nil then
		if breed.name == "skaven_rat_ogre" then
			local damage_amount = original_damage_amount
			local method_used = user_setting(MOD_SETTINGS.ORGE_DMG_TAKEN.save)
			if method_used == ORGE_DMG_TAKEN_2 then
				damage_amount = damage_amount * 1.75
			elseif method_used == ORGE_DMG_TAKEN_3 then
				damage_amount = damage_amount * 2.5
			end
			return func(attacked_unit, attacker_unit, damage_amount, ...)
		end
	end

	return func(attacked_unit, attacker_unit, original_damage_amount, ...)
end)

--- specials ratio
local SPECIALS_RATIO_DEFAULT = 1
local SPECIALS_RATIO_LESS_DISABLERS = 2
local SPECIALS_RATIO_NO_DISABLERS = 3

Mods.hook.set(mod_name, "SpecialsPacing.select_breed_functions.get_random_breed", function (func, slots, breeds, method_data)
	local specials_ratio_method = user_setting(MOD_SETTINGS.SPECIALS_RATIO.save)
	if not user_setting(MOD_SETTINGS.ENABLED.save) or specials_ratio_method == SPECIALS_RATIO_DEFAULT then
		return func(slots, breeds, method_data)
	end

	local rand = math.random(100)
	local breed = nil
	if specials_ratio_method == SPECIALS_RATIO_LESS_DISABLERS then
		if rand < 11 then
			breed = "skaven_pack_master"
		elseif rand < 21 then
			breed = "skaven_gutter_runner"
		elseif rand < 61 then
			breed = "skaven_ratling_gunner"
		else
			breed = "skaven_poison_wind_globadier"
		end
	elseif specials_ratio_method == SPECIALS_RATIO_NO_DISABLERS then
		if rand < 51 then
			breed = "skaven_ratling_gunner"
		else
			breed = "skaven_poison_wind_globadier"
		end
	end

	return breed or func(slots, breeds, method_data)
end)

--- hide non-player ui frames
Mods.hook.set(mod_name, "UnitFrameUI.draw", function (func, self, dt)
	local true_solo_mode_enabled = user_setting(MOD_SETTINGS.ENABLED.save)
	if self.last_true_solo_mode_enabled == nil then
		self.last_true_solo_mode_enabled = true_solo_mode_enabled
	end
	if self.last_true_solo_mode_enabled ~= true_solo_mode_enabled then
		if not true_solo_mode_enabled and Managers.state.game_mode and Managers.state.game_mode._game_mode_key ~= "inn" then
			self.set_visible(self, true)
			self.set_dirty(self)
		end
	end

	self.last_true_solo_mode_enabled = true_solo_mode_enabled

	if not true_solo_mode_enabled then
		return func(self, dt)
	end

	local portait_static_widget = self._widgets["portait_static"]
	if self.peer_id and self.peer_id == Network.peer_id() and portait_static_widget.content.player_level and portait_static_widget.content.player_level ~= "BOT" then
		return func(self, dt)
	end

	local hide_other_frames = user_setting(MOD_SETTINGS.HIDE_OTHER_FRAMES.save)
	if self._is_visible ~= not hide_other_frames then
		self.set_visible(self, not hide_other_frames)
		self.set_dirty(self)
	end

	return func(self, dt)
end)
Mods.hook.front(mod_name, "UnitFrameUI.draw")

--- change assassin spawn sound
Mods.hook.set(mod_name, "ConflictDirector.spawn_unit", function (func, self, breed, ...)
	if breed.name == "skaven_rat_ogre" then
		local ogre = func(self, breed, ...)
		table.insert(TrueSolo.ogres, ogre)
		return ogre
	end

	local assassin_spawn_sound_enabled = user_setting(MOD_SETTINGS.ASSASSIN_SPAWN_SOUND.save)
	if not user_setting(MOD_SETTINGS.ENABLED.save) or not assassin_spawn_sound_enabled then
		Breeds.skaven_gutter_runner.combat_spawn_stinger = "enemy_gutterrunner_stinger"
		return func(self, breed, ...)
	end

	Breeds.skaven_gutter_runner.combat_spawn_stinger = nil

	if breed.name == "skaven_gutter_runner" and assassin_spawn_sound_enabled then
		TerrorEventBlueprints.custom_gutter_warning = {
			{
				"play_stinger",
				stinger_name = "Play_enemy_stormvermin_champion_electric_floor"
			},
		}
		Managers.state.conflict:start_terror_event("custom_gutter_warning")
	end

	return func(self, breed, ...)
end)

--- skip cutscenes, ported from the Mod Framework
Mods.hook.set(mod_name, "CutsceneSystem.skip_pressed", function (func, self)
	rawset(_G, "_skip_cutscenes_skip_next_fade", true)

	func(self)
end)


Mods.hook.set(mod_name, "CutsceneSystem.flow_cb_cutscene_effect", function (func, self, name, flow_params)
	if rawget(_G, "_skip_cutscenes_skip_next_fade") and name == "fx_fade" then
		rawset(_G, "_skip_cutscenes_skip_next_fade", false)
		return
	end

	func(self, name, flow_params)
end)

-- Don't restore player input if player already has active input
Mods.hook.set(mod_name, "CutsceneSystem.flow_cb_deactivate_cutscene_logic", function (func, self, event_on_deactivate)
	-- If a popup is open or cursor present, skip the input restore
	if ShowCursorStack.stack_depth > 0 or Managers.popup:has_popup() then
		if event_on_deactivate then
			local level = LevelHelper:current_level(self.world)
			Level.trigger_event(level, event_on_deactivate)
		end

		self.event_on_skip = nil
	else
		func(self, event_on_deactivate)
	end
end)

-- Prevent invalid cursor pop crash if another mod interferes
Mods.hook.set(mod_name, "ShowCursorStack.pop", function (func)
	-- Catch a starting depth of 0 or negative cursors before pop
	if ShowCursorStack.stack_depth <= 0 then
		EchoConsole("[Warning]: Attempt to remove non-existent cursor.")
	else
		func()
	end
end)

--- options
local function create_options()
	Mods.option_menu:add_group("true_solo_group", "True Solo")
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.ENABLED, true)

	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.KILL_BOTS)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.HIDE_OTHER_FRAMES)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.ASSASSIN_SPAWN_SOUND)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.NO_HORDES_WHEN_OGRE_ALIVE)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.ORGE_DMG_TAKEN)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.SPECIALS_RATIO)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.HORDE_SIZE)
	Mods.option_menu:add_item("true_solo_group", MOD_SETTINGS.SKIP_CUTSCENES)
end

safe_pcall(create_options)