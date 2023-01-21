-- Load and set namespace
local _, core = ...

-- Handler for console slash commands
function core:Console(args)
	arg, subarg = strsplit(" ", args, 2)

	-- Print help if no arg
	if arg == "" then
		s = [[

/pui coords - Print current zone and coordinates (Key Bindings > Other > PrdUI)
/pui notepad - Open notepad (Key Bindings > Other > PrdUI)
/pui range <spell> - Disable or set spell to check when in range
/pui filter <pattern> - Disable or set LFG chat filter using Lua pattern matching
/pui fishing <on|off> - Disable or set system sounds to enhance fishing effect
/pui uireload - Manually trigger a reload of UI elements
/pui defaults - Reset PrdUI to (very neutral) default settings]]
		core:Print(s)
		InterfaceOptionsFrame_OpenToCategory("PrdUI")
		InterfaceOptionsFrame_OpenToCategory("PrdUI") -- need this twice for some reason

	-- Toggle debug
	elseif arg == "debug" then
		core:ToggleDebug()

	-- Rerun all the scaling, hiding and moving around of UI widget
	elseif arg == "uireload" then
		core:Print("UI parts reload.")
		core.UI:Scale()
		core.UI:HideBlizzard()
		core.UI:MoveAll()

	-- Print coords
	elseif arg == "coords" then
		core.Coords:Show()

	-- Open notes
	elseif arg == "notepad" then
		core.Notes:Toggle()

	-- Set or show range
	elseif arg == "range" then
		core.Range:SetSpell(subarg)

	-- Set or clear filter
	elseif arg == "filter" then
		core.ChatFilter:SetNeedle(subarg)

	-- Set or restore fishing sounds
	elseif arg == "fishing" then
		if subarg == "on" then
			core.Fishing:SetSound()
		else
			core.Fishing:Reset()
		end

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
	end

	-- core:Debug("Init: Create Coords module")
	-- core.Coords:Create() -- error as of 230121

	-- core:Debug("Init: Create Range module")
	-- core.Range:Create() -- error as of 230121

	if core.options.merchantenable then
		core:Debug("Init: Create Merchant module")
		core.Merchant:Create()
	end

	core:Debug("Init: Create ChatFilter module")
	core.ChatFilter:Create()

	-- core:Debug("Init: Create Notes module")
	-- core.Notes:Create() -- error as of 230121
	-- if core.options.notepadOpen then
		-- core.Notes:Toggle()
	-- end

	-- Hijack item links for notepad
	-- core:Debug("Init: Setup chat links for notes")
	-- core.Notes:SetupChatLinks()

	core:Debug("Init: Create Fishing module")
	core.Fishing:Create()

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
