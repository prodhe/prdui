-- Load and set namespace
local _, core = ...
core.Fishing = {}
local Fishing = core.Fishing

-- Stored data
core.data.fishingSounds = nil

-- Options
core.options.fishingmv = 100 -- default master volume in percentage

local fishingSounds = {
	Sound_MasterVolume = core.options.fishingmv,
	Sound_MusicVolume = 0,
	Sound_AmbienceVolume = 0,
	Sound_SFXVolume = 100
}

-- Create the coords frame
function Fishing:Create()
	core:Debug("Fishing: Create")

	Fishing:Reset()
end

-- Reset system sound settings
function Fishing:Reset()
	core:Debug("Fishing: Reset")
    if (core.data.fishingSounds) then
        for key, val in pairs(core.data.fishingSounds) do
			core:Debug("Fishing: Reset: setting " .. key .. ":" .. val)
            BlizzardOptionsPanel_SetCVarSafe(key, tonumber(val))
        end
        core.data.fishingSounds = nil
    end	
end

-- Fetch and save current system values
function Fishing:SaveSound()
	core:Debug("Fishing: SaveSound")
	core.data.fishingSounds = {}
	for key in pairs(fishingSounds) do
		core:Debug("Fishing: SaveSound: saving " .. key .. ":" .. BlizzardOptionsPanel_GetCVarSafe(key))
		core.data.fishingSounds[key] = BlizzardOptionsPanel_GetCVarSafe(key)
	end
end

-- Set system sounds to enhance bobbing effect
-- Credits to FishingBuddy for showing how this can be done
function Fishing:SetSound()
	core:Debug("Fishing: SetSound")
	
	Fishing:SaveSound()
	
	-- Set new values
	for key, val in pairs(fishingSounds) do
		if key == "Sound_MasterVolume" then
			val = core.options.fishingmv
		end
		core:Debug("Fishing: SetSound: setting " .. key .. ":" .. val)
		BlizzardOptionsPanel_SetCVarSafe(key, tonumber(val));
	end
end
