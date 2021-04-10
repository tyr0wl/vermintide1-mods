--[[
	Disables camera shake on weapon attacks
	This mod was ported from v1 workshop mod "No Wobble" to QoL
	Original Author: SkacikPL
]] --
local mod_name = "NoWobble"

local mod = { }

mod.update = function()
	if Managers.state.network ~= nil and Unit.alive(Managers.player:local_player().player_unit) then
		local first_person_ext = ScriptUnit.extension(Managers.player:local_player().player_unit, "first_person_system")
		local FPU = first_person_ext.get_first_person_unit(first_person_ext)
		local camerabone = Unit.node(FPU, "camera_node")

		Unit.set_local_rotation(FPU, camerabone, Quaternion.identity())
		Unit.set_local_position(FPU, camerabone, Vector3.zero())
	end
end

Mods.hook.set(mod_name, "ModManager.update", function (func, ...)
	mod.update()
	func(...)
end)

mod.update()
