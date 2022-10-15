-- Load and set namespace
local _, core = ...
core.UI = {}
local UI = core.UI

-- Options
core.options.scale = 0.9 -- default scale
core.options.uienable = false

local inCombat = false

-- Create the area from which other elements will position into
function UI:Create()
	core:Debug("UI: Create")

	-- Create UIFrame based on ActionButton size
	local aw = ActionButton1:GetWidth() + 6
	local ah = ActionButton1:GetHeight() + 6
	UI.Frame = CreateFrame("Frame", "PrdUIFrame", UIParent)
	UI.Frame:SetFrameStrata("MEDIUM")
	UI.Frame:SetSize(12*aw, (4+1)*ah) -- cols and rows
	UI.Frame:ClearAllPoints()
	UI.Frame:SetPoint("BOTTOM", UIParent)
	UI.Frame:Hide()

	-- Events
	core:RegisterEvents(UI.Frame, UI.HandleEvents,
		"LOADING_SCREEN_DISABLED", -- Returning from loading screen
		-- "PLAYER_ENTERING_WORLD",

		"CURRENT_SPELL_CAST_CHANGED", -- recreates the castingbar
		"UNIT_SPELLCAST_START",
		"UNIT_SPELLCAST_SUCCEEDED",
		"UNIT_SPELLCAST_STOP",
		"PLAYER_MOUNT_DISPLAY_CHANGED",

		"UPDATE_FACTION", -- Rep bar
		"UPDATE_BONUS_ACTIONBAR", -- leave vehicle/flight

		"PLAYER_REGEN_ENABLED",
		"PLAYER_REGEN_DISABLED", -- best markers for in and out of combat

		"UNIT_ENTERED_VEHICLE",
		"UNIT_EXITED_VEHICLE",
		"VEHICLE_PASSENGERS_CHANGED",
		"VEHICLE_UPDATE",
		"UPDATE_VEHICLE_ACTIONBAR"

		-- "UPDATE_ALL_UI_WIDGETS"
		-- "ACTIONBAR_UPDATE_USABLE", -- flight makes actionbar inactive
		-- "PET_BAR_UPDATE",
		-- "UNIT_PET",
		-- "UPDATE_SHAPESHIFT_FORM",
		-- "UPDATE_SHAPESHIFT_FORMS",
		-- "UPDATE_SHAPESHIFT_USABLE",
		-- "UPDATE_ALL_UI_WIDGETS"
		-- "UNIT_PORTRAIT_UPDATE"
		-- "PORTRAITS_UPDATED"
	)

end

-- Handle events and reposition some stuff that is otherwise immovable
function UI:HandleEvents(event, arg1, ...)
	if event == "LOADING_SCREEN_DISABLED" or event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "VEHICLE_PASSENGERS_CHANGED" or event == "VEHICLE_UPDATE" or event == "UPDATE_VEHICLE_ACTIONBAR" then
		core:Debug("UI: HandleEvents:", event)
		core.UI:MoveAll()

	-- Casting spell
	elseif event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_SUCCEEDED" then
		if arg1 == "player" then
			core:Debug("UI: HandleEvents:", event)
			core.UI:MoveCastingBar(event)
		end
	elseif event == "CURRENT_SPELL_CAST_CHANGED" or event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
			core:Debug("UI: HandleEvents:", event)
			core.UI:MoveCastingBar(event)

	-- Reputation
	elseif event == "UPDATE_FACTION" then
		core:Debug("UI: HandleEvents:", event)
		core.UI:MoveRepBar()

	elseif event == "UPDATE_BONUS_ACTIONBAR" then
		core:Debug("UI: HandleEvents:", event)
		core.UI:MoveVehicleLeave()

	elseif event == "PLAYER_REGEN_ENABLED" then
		core:Debug("UI: HandleEvents:", event)
		inCombat = false
		core.UI:MoveUnitFrames() -- in case they got screwed up during instance in/out while in combat

	elseif event == "PLAYER_REGEN_DISABLED" then
		core:Debug("UI: HandleEvents:", event)
		inCombat = true

	else
		core:Debug("UI: HandleEvents: not handled:", event)
	end
end

-- Hide hides Blizzard UI stuff
function UI:HideBlizzard()
	if not core.options.uienable then return end

	core:Debug("UI: HideBlizzard: Hiding Blizzard UI")

	-- Gryphons
	MainMenuBarLeftEndCap:Hide()
	MainMenuBarRightEndCap:Hide()

	-- Textures
	MainMenuBarTexture0:Hide()
	MainMenuBarTexture1:Hide()
	MainMenuBarTexture2:Hide()
	MainMenuBarTexture3:Hide()

	-- Action bar arrows
	MainMenuBarPageNumber:Hide()
	ActionBarUpButton:Hide()
	ActionBarDownButton:Hide()

	-- Latency bar
	MainMenuBarPerformanceBarFrame:Hide()

	-- Max level XP bar
	MainMenuBarMaxLevelBar:Hide()
	MainMenuMaxLevelBar0:Hide()
	MainMenuMaxLevelBar1:Hide()
	MainMenuMaxLevelBar2:Hide()
	MainMenuMaxLevelBar3:Hide()
end

-- Scale rescales all the UI elements we care about
function UI:Scale()
	if not core.options.uienable then return end

	core:Debug("UI: Scale:", core.options.scale)

	-- Exp bar
	MainMenuExpBar:SetScale(core.options.scale)
	ReputationWatchBar:SetScale(core.options.scale)

	-- Action bars
	for i = 1,12,1 do
		_G["ActionButton"..i]:SetScale(core.options.scale)
		_G["MultiBarBottomRightButton"..i]:SetScale(core.options.scale)
		_G["MultiBarBottomLeftButton"..i]:SetScale(core.options.scale)
		_G["MultiBarLeftButton"..i]:SetScale(core.options.scale)
		-- _G["MultiBarRightButton"..i]:SetScale(core.options.scale) -- this get scaled with VerticalMultiBarsContainer
	end
	VerticalMultiBarsContainer:SetScale(core.options.scale) -- to get relative positioning right later on

	-- Pet and stance bars
	for i = 1,10,1 do
		_G["PetActionButton"..i]:SetScale(core.options.scale)
		_G["StanceButton"..i]:SetScale(core.options.scale)
	end

	-- MultiCastActionBar
	_G["MultiCastActionBarFrame"]:SetScale(core.options.scale)

	-- Backpacks
	MainMenuBarBackpackButton:SetScale(core.options.scale)
	for i = 0,3,1 do
		_G["CharacterBag"..i.."Slot"]:SetScale(core.options.scale)
	end
	KeyRingButton:SetScale(core.options.scale)

	-- System buttons
	CharacterMicroButton:SetScale(core.options.scale)
	SpellbookMicroButton:SetScale(core.options.scale)
	TalentMicroButton:SetScale(core.options.scale)
	AchievementMicroButton:SetScale(core.options.scale)
	QuestLogMicroButton:SetScale(core.options.scale)
	SocialsMicroButton:SetScale(core.options.scale)
	-- WorldMapMicroButton:SetScale(core.options.scale) -- deprecated
	LFGMicroButton:SetScale(core.options.scale)
	PVPMicroButton:SetScale(core.options.scale)
	MainMenuMicroButton:SetScale(core.options.scale)
	HelpMicroButton:SetScale(core.options.scale)
end

-- Move repositions static elements into our UI
function UI:Move()
	if not core.options.uienable then return end
	if inCombat then return end

	core:Debug("UI: Move")

	-- Get width and height of buttons
	local sw = CharacterMicroButton:GetWidth()
	local sh = CharacterMicroButton:GetHeight()
	local aw = ActionButton1:GetWidth() + 3
	-- local ah = ActionButton1:GetHeight() + 6
	-- local pw = PetActionButton1:GetWidth()
	-- local ph = PetActionButton1:GetHeight()
	-- local bh = MainMenuBarBackpackButton:GetHeight()

	core:Debug("UI: Move: Backpacks")
	-- Backpacks
	MainMenuBarBackpackButton:ClearAllPoints()
	MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", UIParent, 0, 3)

	core:Debug("UI: Move: System buttons")
	-- System buttons
	CharacterMicroButton:ClearAllPoints()
	CharacterMicroButton:SetPoint("RIGHT", KeyRingButton, "LEFT", -sw*9, sh/6)

	core:Debug("UI: Move: Exp bar")
	-- Exp bar
	MainMenuExpBar:ClearAllPoints()
	MainMenuExpBar:SetPoint("TOP", UIParent)

	core:Debug("UI: Move: Action bars")
	-- Action bars
	_G["ActionButton1"]:ClearAllPoints()
	_G["ActionButton1"]:SetPoint("BOTTOM", UI.Frame, -aw*6+3, 6)
	_G["MultiBarBottomLeftButton1"]:ClearAllPoints()
	_G["MultiBarBottomLeftButton1"]:SetPoint("BOTTOM", ActionButton1, "TOP", 0, 6)
	_G["MultiBarBottomRightButton1"]:ClearAllPoints()
	_G["MultiBarBottomRightButton1"]:SetPoint("BOTTOM", MultiBarBottomLeftButton1, "TOP", 0, 6)

	core:Debug("UI: Move: Vertical action bars")
	-- Vertical action bars
	_G["VerticalMultiBarsContainer"]:ClearAllPoints()
	VerticalMultiBarsContainer:SetPoint("RIGHT", UIParent, "RIGHT", 0, 0)
	_G["VerticalMultiBarsContainer"]:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "TOP", 0, 6)

	core:Debug("UI: Move: Pet and stance buttons")
	-- Pet and stance
	_G["PetActionButton1"]:ClearAllPoints()
	_G["PetActionButton1"]:SetPoint("BOTTOM", MultiBarBottomRightButton1, "TOP", -3, 6)
	_G["StanceButton1"]:ClearAllPoints()
	_G["StanceButton1"]:SetPoint("BOTTOM", MultiBarBottomRightButton1, "TOP", -3, 6)

	core:Debug("UI: Move: Multicast action bar buttons")
	-- Multicast action
	_G["MultiCastActionBarFrame"]:ClearAllPoints()
	_G["MultiCastActionBarFrame"]:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton1, "TOP", -3, 6)
end

-- Move casting bar
function UI:MoveCastingBar(event)
	if not core.options.uienable then return end
	if inCombat then return end

	core:Debug("UI: MoveCastingBar")
	local ah = (ActionButton1:GetHeight() + 6)*core.options.scale
	-- Regular casting bar
	CastingBarFrame:ClearAllPoints()
	CastingBarFrame:SetPoint("BOTTOM", UI.Frame, 0, ah*4+12)
end

-- Player and target unit frames
function UI:MoveUnitFrames()
	if not core.options.uienable then return end
	if inCombat then return end

	core:Debug("UI: MoveUnitFrames")
	local ah = ActionButton1:GetHeight() + 6
	-- Player and target frames
	PlayerFrame:ClearAllPoints()
	PlayerFrame:SetPoint("BOTTOM", MultiBarBottomRightButton1, "TOP", 0, ah*3)
	TargetFrame:ClearAllPoints()
	TargetFrame:SetPoint("BOTTOM", MultiBarBottomRightButton12, "TOP", 0, ah*3)
end

-- Vehicle (leave flight)
function UI:MoveVehicleLeave()
	if not core.options.uienable then return end
	if inCombat then return end

	core:Debug("UI: MoveVehicleLeave")
	MainMenuBarVehicleLeaveButton:ClearAllPoints()
	MainMenuBarVehicleLeaveButton:SetPoint("BOTTOM", MultiBarBottomRightButton12, "TOP", 3, 6)
end

-- Reputation bar
function UI:MoveRepBar()
	if not core.options.uienable then return end
	if inCombat then return end

	core:Debug("UI: MoveRepBar")
	local y = 15
	if UnitLevel("player") == 60 then
		y = 0
	end
	-- Rep bar
	ReputationWatchBar:ClearAllPoints()
	ReputationWatchBar:SetPoint("TOP", UIParent, 0, -y)
end

-- MoveAll is a convenient redo-move-it-all function
function UI:MoveAll()
	if not core.options.uienable then return end
	if inCombat then return end

	UI:Move()
	UI:MoveCastingBar()
	UI:MoveRepBar()
	UI:MoveUnitFrames()
	UI:MoveVehicleLeave()
end

-- Reload makes a reload of UI in-place
function UI:Reload()
	if not core.options.uienable then
		core:Print("UI Redesign not enabled.")
		return
	end

	if inCombat then
		core:Print("Must be out of combat for UI quick reload.")
		return
	end

	core:Print("Reload.")
	core.UI:Scale()
	core.UI:HideBlizzard()
	core.UI:MoveAll()
end
