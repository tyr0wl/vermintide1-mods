--[[
	Plays the electricity sound from the Krench fight when an assassin spawns to prevent silent spawns.
	Author: Prop joe, j_sat
]]--
Mods.hook.set("custom_gutter_warning", "ConflictDirector.spawn_unit", function (func, self, breed, ...)
	if breed.name == "skaven_gutter_runner" then
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
