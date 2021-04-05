--[[
	author: Aussiemon and bi

	-----

	Copyright 2018 Aussiemon and bi

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

	-----

	Provides better UI scaling for higher-resolution displays.
	Ported from vmf to QoL.
--]]

local mod_name = "HiDefUIScaling"

HiDefUIScaling = {
	SETTINGS = {
		ACTIVE = {
			["save"] = "cb_hi_def",
			["widget_type"] = "stepper",
			["text"] = "Enabled",
			["tooltip"] = "Hi-Def UI Scaling\n" ..
					"Scales the UI and loading screens better for QHD+ resolutions.",
			["value_type"] = "boolean",
			["options"] = {
				{text = "Off", value = false},
				{text = "On", value = true},
			},
			["default"] = 2, -- Default first option is enabled. In this case Off
			["hide_options"] = {
				{
					false,
					mode = "hide",
					options = {
						"cb_hi_def_scale",
					}
				},
				{
					true,
					mode = "show",
					options = {
						"cb_hi_def_scale",
					}
				},
			},
		},
		SCALE = {
			["save"] = "cb_hi_def_scale",
			["widget_type"] = "dropdown",
			["text"] = "UI Scale",
			["tooltip"] =  "Scale to size the UI to.",
			["value_type"] = "number",
			["options"] = {
				{text = "133%", value = 133}, -- 1440p
				{text = "166%", value = 166},
				{text = "200%", value = 200},
				{text = "233%", value = 233},
				{text = "266%", value = 266}, -- 5k
				{text = "300%", value = 300},
				{text = "333%", value = 333},
				{text = "366%", value = 366},
				{text = "400%", value = 400},  -- 8k
			},
			["default"] = 1, -- 1440p
		},
	},
}

local me = HiDefUIScaling

local get = Application.user_setting

-- ##########################################################
-- #################### Hooks ###############################

Mods.hook.set(mod_name, "UIResolutionScale", function (func, ...)
	local width, height = UIResolution()
	local modEnabled = get(me.SETTINGS.ACTIVE.save)

	if modEnabled and width > UIResolutionWidthFragments() and height > UIResolutionHeightFragments() then
		local scale = get(me.SETTINGS.SCALE.save)

		local max_scaling_factor = math.max((((scale or 4) + 1) / 100), 1)

		-- Changed to allow scaling up to quadruple the original max scale (1 -> 4)
		local width_scale = math.min(width / UIResolutionWidthFragments(), max_scaling_factor)
		local height_scale = math.min(height / UIResolutionHeightFragments(), max_scaling_factor)

		return math.min(width_scale, height_scale)
	else
		return func(...)
	end
end)

me.create_options = function()
	Mods.option_menu:add_group("hi_def_group", "Hi-Def UI Scaling")
	Mods.option_menu:add_item("hi_def_group", me.SETTINGS.ACTIVE, true)
	Mods.option_menu:add_item("hi_def_group", me.SETTINGS.SCALE)
end

me.create_options()
