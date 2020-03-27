-- Load and set namespace
local _, core = ...
core.Coords = {}
local Coords = core.Coords

local coordsTimer

-- Create the coords frame
function Coords:Create()
	core:Debug("Coords: Create")

	local t = CreateFrame("Frame")
	t:ClearAllPoints()
	t:SetHeight(300)
	t:SetWidth(300)
	t:SetScript("OnUpdate", function()
	  if (coordsTimer < GetTime() - 3) then -- magic number in seconds
		local alpha = t:GetAlpha()
		if (alpha ~= 0) then t:SetAlpha(alpha - .05) end
		if (alpha == 0) then t:Hide() end
	  end
	end)
	t:Hide()
	t.text = t:CreateFontString(nil, "BACKGROUND", "GameFontNormalLarge")
	t.text:SetAllPoints()
	t:SetPoint("CENTER", 0, 150)

	Coords.Frame = t
end

-- Show coords in UI text popup
function Coords:Show()
	core:Debug("Coords: Show")

	local str = GetInstanceInfo() -- either continent or instance

	local z = C_Map.GetBestMapForUnit("player") -- valid for open world
	if z then
		local pos = C_Map.GetPlayerMapPosition(z,"player")
		str = str .. "\n" .. C_Map.GetMapInfo(z).name .. " (" .. math.ceil(pos.x*10000)/100 .. ", " .. math.ceil(pos.y*10000)/100 ..")"
	end

	coordsTimer = GetTime()
	Coords.Frame.text:SetText(str)
	Coords.Frame:SetAlpha(1)
	Coords.Frame:Show()
end
