-- Load and set namespace
local _, core = ...
core.CherryPick = {}
local CherryPick = core.CherryPick

local f = nil
local ed = nil
local needle = nil

-- Create the area from which other elements will position into
function CherryPick:Create()
	core:Debug("CherryPick: Create")

	-- Create CherryPickFrame 
	f = CreateFrame("Frame", "PrdUICherryPickFrame", UIParent, "DialogBoxFrame")
	local w = 500
	local h = 200
	f:SetSize(w, h)
	f:SetPoint("CENTER", UIParent, "CENTER")

	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetClampedToScreen(true)

	f.ScrollFrame = CreateFrame("ScrollFrame", "PrdUICherryPickFrameScrollFrame", f, "UIPanelScrollFrameTemplate")
	f.ScrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -6)
	f.ScrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -3, 4)
	f.ScrollFrame:SetClipsChildren(true)

	-- Move the scrollbar to within the graphical frame
	f.ScrollFrame.ScrollBar:ClearAllPoints()
	f.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", f.ScrollFrame, "TOPRIGHT", -8, -18)
	f.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", f.ScrollFrame, "BOTTOMRIGHT", -7, 16)

	-- Create EditBox
	ed = CreateFrame("EditBox", "PrdUICherryPickFrameEditBox")
	ed:SetMultiLine(true)
	ed:SetFontObject(ChatFontNormal)
	ed:SetWidth(w-50) -- minus scrollbar
	ed:ClearAllPoints()
	ed:SetPoint("TOPLEFT", 8, 0)
	ed:SetAutoFocus(false)
	ed:SetEnabled(false)
	ed:SetTextColor(1, 0.8, 0.85, 1) -- 255, 204, 217
	ed:SetIgnoreParentAlpha(true)

	-- Add the EditBox to the scroll
	f.ScrollFrame:SetScrollChild(ed)

	-- Set default text
	ed:SetText("")
	ed:SetCursorPosition(0)

	ed:SetScript("OnCursorChanged", function(self, arg1, arg2, arg3, arg4)
		-- Autoscroll on input
		local vs = f.ScrollFrame:GetVerticalScroll()
		local h  = f.ScrollFrame:GetHeight()
		if vs+arg2 > 0 or 0 > vs+arg2-arg4+h then
			f.ScrollFrame:SetVerticalScroll(arg2*-1);
		end
	end)

	-- Enable clicking on link items
	ed:SetHyperlinksEnabled(true)
	ed:SetScript("OnHyperlinkClick", function(self, link, text, button)
		core:Debug("CherryPick: Hyperlink clicked")
		SetItemRef(link, text, button)
	end)

	-- Resizable
	f:SetResizable(true)
	f:SetMinResize(150, 100)
	local rb = CreateFrame("Button", "PrdUICherryPickFrameResizeButton", PrdUICherryPickFrame)
	rb:SetPoint("BOTTOMRIGHT", -6, 7)
	rb:SetSize(16, 16)
	
	rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	
	rb:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
			f:StartSizing("BOTTOMRIGHT")
			self:GetHighlightTexture():Hide() -- more noticeable
		end
	end)
	rb:SetScript("OnMouseUp", function(self, button)
		f:StopMovingOrSizing()
		self:GetHighlightTexture():Show()
		ed:SetWidth(f.ScrollFrame:GetWidth()-50) -- minus scrollbar
	end)

	-- Events
	core:RegisterEvents(f, CherryPick.HandleEvents,
		"CHAT_MSG_CHANNEL"
	)

end

function CherryPick:HandleEvents(event, ...)
	if event == "CHAT_MSG_CHANNEL" then
		local text, _, _, channelName, _, _, _, channelIndex, _, _, _, guid = ...
		core:Debug("CherryPick: HandleEvents:", event)
		CherryPick:ParseMsg(channelIndex, guid, text)

	else
		core:Debug("CherryPick: HandleEvents: not handled:", event)
	end
end

function CherryPick:ParseMsg(channel, guid, text)
	-- Filter text
	local found = false

	needle = string.match(text, "")
	if needle then found = true end

	if not found then return end
	
	-- Go on and print the message
	local msg = ""
	local _, _, _, _, _, pn = GetPlayerInfoByGUID(guid)
	pn = "|Hplayer:" .. pn .. "|h[" .. pn .. "]|h"
	channel = "[" .. channel .. "]"
	msg = channel .. " " .. pn .. ": " .. text
	
	ed:Insert(msg .. "\n")
end