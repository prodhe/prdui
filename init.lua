-- Load and set namespace
local _, core = ...

-- Set default values
core.options.debug = false
core.options.chat = false
core.options.scale = 0.9
core.options.uienable = false
core.options.notepadWidth = 300
core.options.notepadHeight = 340
core.options.notepadOpen = false

-- Handler for console slash commands
function core:Console(args)
	arg, subarg = strsplit(" ", args, 2)

	-- Print help if no arg
	if arg == "" then
		s = [[

Console commands:

/pui coords - Print current zone and coordinates (Key Bindings > Other > PrdUI)
/pui notepad - Open notepad (Key Bindings > Other > PrdUI)
/pui uireload - Reload UI affecting parts (can fix broken stuff)
/pui defaults - Reset PrdUI to (very neutral) default settings]]
		core:Print(s)
		InterfaceOptionsFrame_OpenToCategory("PrdUI")
		InterfaceOptionsFrame_OpenToCategory("PrdUI") -- need this twice for some reason

	-- Rerun all the scaling, hiding and moving around of UI widget
	elseif arg == "uireload" then
		core:Print("UI parts reload.")
		core.UI:Scale()
		core.UI:HideBlizzard()
		core.UI:MoveAll()

	-- Open notes
	elseif arg == "notepad" then
		core.Notes:Toggle()

	-- Print coords
	elseif arg == "coords" then
		core.Coords:Show()

	-- Set or show range
	elseif arg == "range" then
		core.Range:SetSpell(subarg)

	-- Toggle debug
	elseif arg == "debug" then
		core:ToggleDebug()

	-- Reset and restore entire AddOn to default values
	elseif arg == "defaults" then
		core:RestoreDefaults()

	-- Print error
	else
		core:Print("Unknown command. Type /pui for options.")
	end
end

-- Init is the main entry point
function core:Init(event, name)
	if (name ~= "PrdUI") then return end

	core:Debug("Core: Initializing")

	-- Set or load options
	core:LoadDB()

	core:Debug(core.options.notepadWidth, ",", core.options.notepadHeight)
	
	core:Debug("Init: Create configuration panel.")
	core.Config:Create()

	if core.options.chat then
		core:Debug("Init: SetChat")
		core:SetChat()
	end

	if core.options.uienable then
		core:Debug("Init: UI enabled")
		core.UI:Create()
		core.UI:HideBlizzard()
		core.UI:Scale()
		core.UI:Move()
	end

	core:Debug("Init: Create Coords module")
	core.Coords:Create()

	core:Debug("Init: Create Range module")
	core.Range:Create()

	core:Debug("Init: Create Notes module")
	core.Notes:Create()
	if core.options.notepadWidth and core.options.notepadHeight then
		core:Debug("Init: Notes: Setting user width and height")
		core.Notes:SetSize(core.options.notepadWidth, core.options.notepadHeight)
	end
	if core.options.notepadOpen then
		core.Notes:Toggle()
	end

	-- Hijack item links for notepad
	core:Debug("Init: Setup chat links for notes")
	core.Notes:SetupChatLinks()

	-- Functions for key binds
	_G["KeyBinding_ToggleNotepad"] = function()
		core.Notes:Toggle()
	end
	_G["KeyBinding_ShowCoords"] = function()
		core.Coords:Show()
	end

	-- Register slash command
	SLASH_PRDUI1 = "/pui"
	SLASH_PRDUI2 = "/prdui"
	SlashCmdList["PRDUI"] = function(args)
		core:Console(args)
	end

	-- Register key bindings
	BINDING_HEADER_PRDUI = "PrdUI"
	BINDING_NAME_PRDUI_NOTES = "Toggle Notepad"
	BINDING_NAME_PRDUI_COORDS = "Show coordinates"

	-- Announce loaded
	core:Print("Loaded. Type /pui for options.")
end

-- Init on loaded
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", core.Init)
