--[[
	Always roll the highest possible trait proc when upgrading or rerolling traits.
	Author: UnShame
]] --

local mod_name = "MaxTraitProc"
-- local mod, mod_name, oi = Mods.new_mod("MaxTraitProc")

-- Max trait percentile roll
Mods.hook.set(mod_name, "ForgeLogic._randomize_trait_variable", function(func, self, item_data, trait_name, variable_name, reroll)
    local trait_config = BuffTemplates[trait_name]
    local buff_data = trait_config.buffs[1]
    local variable = nil
    local variable_base = buff_data[variable_name]
    if variable_base then
        if type(variable_base) == "table" then
            local rarity = item_data.rarity

            if rarity == "unique" then
                variable = variable_base[2]
            else
                local steps = ForgeSettings.trait_steps
                local value = steps

                if reroll and value == 0 then
                    value = 1
                end

                local diff = variable_base[2] - variable_base[1]
                local scaled = value / steps * diff
                variable = variable_base[1] + scaled
            end

            variable = math.floor(variable * 1000 + 0.5) / 1000
        elseif type(variable_base) == "number" then
            variable = variable_base
        end
    end

    return variable
end)
