-- Load and set namespace
local _, core = ...
core.Range = {}
local Range = core.Range

core.charOptions.rangeSpell = ""

local rangeTimer = GetTime()
local rangeUnitTarget = "target"
local rangeunitTargetGUID = nil
local inRange = nil

-- Create the range frame
function Range:Create()
	core:Debug("Range: Create")

	local t = CreateFrame("Frame")
	t:ClearAllPoints()
	t:SetHeight(300)
	t:SetWidth(300)
	t:SetScript("OnUpdate", function()
		if not core.charOptions.rangeSpell then return end -- do nothing if no spell is chosen

		if (rangeTimer < GetTime() - 2) then -- magic number in seconds
			local alpha = t:GetAlpha()
			if (alpha ~= 0) then t:SetAlpha(alpha - .05) end
		end

		if UnitExists(rangeUnitTarget) and UnitIsVisible(rangeUnitTarget) then
			local guid = UnitGUID(rangeUnitTarget)
			local r = IsSpellInRange(core.charOptions.rangeSpell, rangeUnitTarget)
			if r == inRange and guid == rangeunitTargetGUID then return end -- do not write text if status for same mob is the same as before
			rangeunitTargetGUID = guid
			inRange = r
			if inRange then -- inRange is not nil, hence not invalid spell/target combo
				Range:Show()
			end
		end
	end)
	t:Show()
	t.text = t:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	t.text:SetAllPoints()
	t:SetPoint("CENTER", 0, -135)

	Range.Frame = t
end

-- Show range in UI text popup
function Range:Show()
	core:Debug("Range: Show")

	local str = ""

	if inRange == 1 then
		str = "|cffeeeeee" .. core.charOptions.rangeSpell .. "|r"
	else
		str = "|cffdd1111" .. core.charOptions.rangeSpell .. "|r"
	end

	rangeTimer = GetTime()
	Range.Frame.text:SetText(str)
	Range.Frame:SetAlpha(1)
end

-- Set ranged spell
function Range:SetSpell(spell)
	if not spell or spell == "" then
		if not core.charOptions.rangeSpell then
			core.charOptions.rangeSpell = ""
		end
		core:Print("Range: Current spell: " .. core.charOptions.rangeSpell)
		return
	end

	name, _, _, _, _, _, _ = GetSpellInfo(spell)
	if name then
		core:Print("Range: Setting new spell: " .. name)
		core.charOptions.rangeSpell = name
	else
		core:Print("Range: Invalid spell: " .. spell)
		core.charOptions.rangeSpell = ""
	end

	-- Update configuration panel
	core.Config:UpdateFields()
end
