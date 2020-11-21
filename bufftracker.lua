-- Load and set namespace
local _, core = ...
core.BuffTracker = {}
local BuffTracker = core.BuffTracker

core.options.bufftrackerenable = false

local f
local maxBuffs = 33

-- Create the buffTracker frame
function BuffTracker:Create()
	core:Debug("BuffTracker: Create")

	f = CreateFrame("Frame", "PrdUIBuffTrackerFrame", UIParent)
	f:SetHeight(16)
	f:SetWidth(20)
	f.text = f:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	f.text:SetAllPoints()
	f:SetPoint("CENTER", UIParent, "CENTER")

	-- Make the window movable and resizable
	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetClampedToScreen(true)

	f:Hide()

	-- Events
	core:RegisterEvents(f, BuffTracker.HandleEvents,
		"UNIT_AURA"
	)

	if core.options.bufftrackerenable then
		BuffTracker:Toggle()
	end
end

-- Handle events
function BuffTracker:HandleEvents(event, arg1, ...)
	if not core.options.bufftrackerenable then return end

	core:Debug("BuffTracker: HandleEvents:", event)

	if event == "UNIT_AURA" then
		BuffTracker:Count()
	else
		core:Debug("BuffTracker: HandleEvents: not handled:", event)
	end
end

function BuffTracker:Toggle()
	core:Debug("BuffTracker: Toggle")
	f:SetShown(not f:IsShown())
	core.options.bufftrackerenable = f:IsShown()
	if f:IsShown() then
		BuffTracker:Count()
	end
end

-- Recount the current buffs
function BuffTracker:Count()
	if not f:IsShown() then return end

	core:Debug("BuffTracker: Count")

	local buffCount = 0
	
	for i=1,maxBuffs
	do
		-- name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitBuff("player", i)
		name, _, _, _, _, _, _, _, _, _, _ = UnitBuff("player", i)

		if name == nil then
			break
		else
			core:Debug("BuffTracker: UnitBuff: ", name)
			buffCount = buffCount + 1
		end
	end

	f.text:SetText(buffCount)
end
