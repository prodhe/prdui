-- Load and set namespace
local addonName, core = ...
core.Config = {}
local Config = core.Config

local f

-- Create the config frame
function Config:Create()
	core:Debug("Config: Create")

	-- Create ConfigFrame
	f = CreateFrame("Frame", "PrdUIConfigFrame", UIParent)

	-- Add to Blizzard Interface Options
	f.name = "PrdUI"
	InterfaceOptions_AddCategory(f)

	-- Title
	f.sectionHeader = Config:CreateSectionFrame("TOPLEFT", f, "TOPLEFT", 17, -16, 100, 30)
	f.headerTitle = Config:CreateHeaderText("TOPLEFT", f.sectionHeader, "TOPLEFT", 0, "PrdUI", 20)
	f.headerTitle:SetFont("Fonts/MORPHEUS.ttf", 30) -- override with Diablo font
	
	-- Section UI
	f.sectionUI = Config:CreateSectionFrame("TOPLEFT", f.sectionHeader, "BOTTOMLEFT", 0, -20, 285, 120)
	f.sectionUI.header = Config:CreateHeaderText("TOPLEFT", f.sectionUI, "TOPLEFT", 0, "User interface", 14)
	f.sectionUI.checkbtnUIEnable = Config:CreateCheckButton("TOPLEFT", f.sectionUI.header, "BOTTOMLEFT", -15, "ChkBtnUIEnable", "Redesign UI", "Use the PrdUI GUI design.\n\nToggling this will force a UI reload.", core.options.uienable, function(self)
		if self:GetChecked() then
			core.options.uienable = true
		else
			core.options.uienable = false
		end
		ReloadUI()
	end)
	f.sectionUI.sliderScale = Config:CreateSlider("TOPLEFT", f.sectionUI.checkbtnUIEnable, "BOTTOMLEFT", -20, "SliderScale", "Scale", "Adjust to set the scaling of the redesigned UI elements.", "Small", "Large", 5, 15, core.options.scale*10, 1, function(self, value)
		local s = math.ceil(value*100)/1000
		core.options.scale = s
		if core.options.uienable then
			core.UI:Scale()
			core.UI:MoveAll()
		end
	end)
	f.sectionUI.sliderScale:SetPoint("TOPLEFT", f.sectionUI.checkbtnUIEnable, "BOTTOMLEFT", 10, -20)
	f.sectionUI.sliderScale:SetEnabled(core.options.uienable)

	-- Section system
	f.sectionSystem = Config:CreateSectionFrame("TOPLEFT", f.sectionUI, "BOTTOMLEFT", 0, -20, 285, 120)
	f.sectionSystem.header = Config:CreateHeaderText("TOPLEFT", f.sectionSystem, "TOPLEFT", 0, "System", 14)
	f.sectionSystem.checkbtnChatMeta = Config:CreateCheckButton("TOPLEFT", f.sectionSystem.header, "BOTTOMLEFT", -15, "ChkBtnChatMeta", "Allow editing in chat box", "Enable the use of meta characters in chat, such as arrow keys for moving the cursor in the edit box.", core.options.chat, function(self)
		if self:GetChecked() then
			core.options.chat = true
		else
			core.options.chat = false
		end
		core:SetChat()
	end)
	f.sectionSystem.checkbtnDebug = Config:CreateCheckButton("TOPLEFT", f.sectionSystem.checkbtnChatMeta, "BOTTOMLEFT", -5, "ChkBtnDebug", "Console debug", "Enable to print a lot of internal console debug messages.", core.options.debug, function(self)
		core:ToggleDebug()
	end)
	f.sectionSystem.btnDefaults = Config:CreateButton("TOPLEFT", f.sectionSystem.checkbtnDebug, "BOTTOMLEFT", -10, "Reset to defaults", function()
		core:RestoreDefaults()
	end)

	-- Section notepad
	f.sectionNotepad = Config:CreateSectionFrame("TOPLEFT", f.sectionUI, "TOPRIGHT", 20, 0, 285, 60)
	f.sectionNotepad.header = Config:CreateHeaderText("TOPLEFT", f.sectionNotepad, "TOPLEFT", 0, "Notepad", 14)
	f.sectionNotepad.btnNotepad = Config:CreateButton("TOPLEFT", f.sectionNotepad.header, "BOTTOMLEFT", -10, "Toggle", function()
		core.Notes:Toggle()
	end)

	-- Section coords
	f.sectionCoords = Config:CreateSectionFrame("TOPLEFT", f.sectionNotepad, "BOTTOMLEFT", 0, -20, 285, 60)
	f.sectionCoords.header = Config:CreateHeaderText("TOPLEFT", f.sectionCoords, "TOPLEFT", 0, "Coords", 14)
	f.sectionCoords.btnCoords = Config:CreateButton("TOPLEFT", f.sectionCoords.header, "BOTTOMLEFT", -10, "Show coordinates", function()
		core.Coords:Show()
	end)

	-- Section merchant
	f.sectionMerchant = Config:CreateSectionFrame("TOPLEFT", f.sectionCoords, "BOTTOMLEFT", 0, -20, 285, 60)
	f.sectionMerchant.header = Config:CreateHeaderText("TOPLEFT", f.sectionMerchant, "TOPLEFT", 0, "Merchant", 14)
	f.sectionMerchant.checkbtnMerchantEnable = Config:CreateCheckButton("TOPLEFT", f.sectionMerchant.header, "BOTTOMLEFT", -15, "ChkBtnMerchantEnable", "Show Sell trash", "This will add a new button in all merchant windows, enabling you to sell all poor (gray) quality items with one click.\n\nToggling this will force a UI reload.", core.options.merchantenable, function(self)
		if self:GetChecked() then
			core.options.merchantenable = true
		else
			core.options.merchantenable = false
		end
		ReloadUI()
	end)

	-- Section range
	f.sectionRange = Config:CreateSectionFrame("TOPLEFT", f.sectionMerchant, "BOTTOMLEFT", 0, -20, 285, 60)
	f.sectionRange.header = Config:CreateHeaderText("TOPLEFT", f.sectionRange, "TOPLEFT", 0, "Range", 14)
	f.sectionRange.currentSpell = Config:CreateText("TOPLEFT", f.sectionRange, "TOPLEFT", -30, "", 14)

	-- Section chat filter
	f.sectionChatFilter = Config:CreateSectionFrame("TOPLEFT", f.sectionRange, "BOTTOMLEFT", 0, -20, 285, 60)
	f.sectionChatFilter.header = Config:CreateHeaderText("TOPLEFT", f.sectionChatFilter, "TOPLEFT", 0, "Chat filter", 14)
	f.sectionChatFilter.currentNeedle = Config:CreateText("TOPLEFT", f.sectionChatFilter, "TOPLEFT", -30, "", 14)

	-- Lastly, update dynamic text fields. This is supposed to be called from sub modules, if they have
	-- something up here that needs to be updated.
	Config:UpdateFields()
end

-- Update dynamic text fields
function Config:UpdateFields()
	local rs = core.charOptions.rangeSpell
	if not rs or rs == "" then rs = "<none>" end
	f.sectionRange.currentSpell:SetText("Current ability: " .. rs)

	local cfn = core.ChatFilter:GetNeedle()
	if not cfn or cfn == "" then cfn = "<disabled>" end
	f.sectionChatFilter.currentNeedle:SetText("Current search: " .. cfn)
end

-- Create a section frame
function Config:CreateSectionFrame(point, relativeFrame, relativePoint, xOffset, yOffset, width, height)
	local sf = CreateFrame("Frame", nil, f)
	sf:SetSize(width, height)
	sf:SetPoint(point, relativeFrame, relativePoint, xOffset, yOffset)
	return sf
end

-- Create a header text
function Config:CreateHeaderText(point, relativeFrame, relativePoint, yOffset, text, size)
    local t = relativeFrame:CreateFontString(nil, "ARTWORK")
	t:SetPoint(point, relativeFrame, relativePoint, 0, yOffset)
    -- t:SetFont("Fonts/MORPHEUS.ttf", size)
	t:SetFont("Fonts/FRIZQT__.ttf", size)
    t:SetJustifyV("CENTER")
    t:SetJustifyH("CENTER")
    t:SetText(text)
	t:SetTextColor(1, 0.9, 0, 1)
    return t
end

-- Create text
function Config:CreateText(point, relativeFrame, relativePoint, yOffset, text, size)
    local t = relativeFrame:CreateFontString(nil, "ARTWORK")
	t:SetPoint(point, relativeFrame, relativePoint, 0, yOffset)
    -- t:SetFont("Fonts/MORPHEUS.ttf", size)
	t:SetFont("Fonts/FRIZQT__.ttf", size)
    t:SetJustifyV("CENTER")
    t:SetJustifyH("CENTER")
    t:SetText(text)
    return t
end

-- Create a check button with title and tooltip
function Config:CreateCheckButton(point, relativeFrame, relativePoint, yOffset, name, text, tooltip, checked, handlerFunc)
	local btn = CreateFrame("CheckButton", "PrdUIConfig" .. name, f, "ChatConfigCheckButtonTemplate")
	btn.text = _G[btn:GetName().."Text"]
	btn.text:SetText(text)
	btn.text:SetPoint("LEFT", btn, "RIGHT", 4, 0)
	btn.tooltip = tooltip
	btn:SetPoint(point, relativeFrame, relativePoint, 0, yOffset)
	btn:SetScale(1.1)
	btn:SetChecked(checked)
	btn:SetScript("OnClick", function(self) handlerFunc(self) end)
	return btn
end

-- Create a clickable button
function Config:CreateButton(point, relativeFrame, relativePoint, yOffset, text, handlerFunc)
	local btn = CreateFrame("Button", nil, f, "GameMenuButtonTemplate")
	btn:SetPoint(point, relativeFrame, relativePoint, 0, yOffset)
	btn:SetSize(145, 22)
	btn:SetText(text)
	btn.tooltip = ""
	btn:SetNormalFontObject("GameFontNormal")
	btn:SetHighlightFontObject("GameFontHighlight")
	btn:SetScript("OnClick", function(self) handlerFunc(self) end)
	return btn
end

-- Create a slider with title
function Config:CreateSlider(point, relativeFrame, relativePoint, yOffset, gname, title, tooltip, lowText, highText, minVal, maxVal, initVal, stepVal, handlerFunc)
	local slider = CreateFrame("Slider", addonName .. gname, f, "OptionsSliderTemplate")
	slider:SetPoint(point, relativeFrame, relativePoint, 0, yOffset)
	slider:SetMinMaxValues(minVal, maxVal)
	slider:SetValue(initVal)
	slider:SetValueStep(stepVal)
	slider:SetObeyStepOnDrag(true)
	slider.tooltipText = tooltip
	slider.lowText = _G[slider:GetName().."Low"]
	slider.lowText:SetText(lowText)
	slider.highText = _G[slider:GetName().."High"]
	slider.highText:SetText(highText)
	slider.text = _G[slider:GetName().."Text"]
	slider.text:SetText(title)
	slider:SetScript("OnValueChanged", function(self, value)
		handlerFunc(self, value)
	end)
	return slider
end

-- Create an inbut text editing box
function Config:CreateInputBox(point, relativeFrame, relativePoint, yOffset, title, w, initVal, handleFunc)
	local e = CreateFrame("EditBox", nil, f)
	e:SetPoint(point, relativeFrame, relativePoint, 0, yOffset)
	e.title_text = Config:CreateText("TOP", e, "TOP", 12, title, 12)
	e:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 26,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4}
	})
	e:SetBackdropColor(0.1,0.1,0.1,1)
	e:SetFontObject(GameFontNormal)
	e:SetJustifyH("CENTER")
	e:SetJustifyV("CENTER")
	e:SetSize(w, 25)
	e:SetMultiLine(false)
	e:SetAutoFocus(false)
	e:SetMaxLetters(3)
	e:SetText(initVal)
	e:SetCursorPosition(0)

	e:SetScript("OnEnterPressed", function(self)
		handleFunc(self)
		self:ClearFocus()
	end)
	e:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)
	return e
end
