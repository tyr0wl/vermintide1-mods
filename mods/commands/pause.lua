--[[
	Pauses the game.
	Author: Prop joe
]]--

-- luacheck: globals Managers

if not Managers.player.is_server then
	EchoConsole("You need to be host to pause")
	return
end

if Managers.state.debug.time_paused then
	Managers.state.debug:set_time_scale(Managers.state.debug.time_scale_index)
	EchoConsole("Game unpaused")
else
	Managers.state.debug:set_time_paused()
	EchoConsole("Game paused")
end
