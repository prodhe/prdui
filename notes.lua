-- Load and set namespace
local _, core = ...
core.Notes = {}
local Notes = core.Notes

-- Stored data
core.data.notepad = ""
core.options.notepadOpen = false

local f
local ed

-- Create the notes frame
function Notes:Create()
	core:Debug("Notes: Create")

	-- Create NotesFrame
	f = CreateFrame("Frame", "PrdUINotesFrame", UIParent, "UIPanelDialogTemplate")
	f.DialogBG = _G[f:GetName() .. "DialogBG"]
	local w = 300
	local h = 340
	f:SetSize(w, h)
	f:SetAlpha(1)
	f.DialogBG:SetAlpha(0.8)
	f:SetPoint("CENTER", UIParent, "CENTER")
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	f.title:SetPoint("CENTER", f.Title, "CENTER", 0, -7)
	f.title:SetText("Notepad")

	-- Create scroll frame
	f.ScrollFrame = CreateFrame("ScrollFrame", "PrdUINotesFrameScrollFrame", f, "UIPanelScrollFrameTemplate")
	f.ScrollFrame:SetPoint("TOPLEFT", f.DialogBG, "TOPLEFT", 4, -6)
	f.ScrollFrame:SetPoint("BOTTOMRIGHT", f.DialogBG, "BOTTOMRIGHT", -3, 4)
	f.ScrollFrame:SetClipsChildren(true)

	-- Make the window movable and resizable
	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetClampedToScreen(true)

	f:SetResizable(true)
	f:SetMinResize(170, 100)
	local rb = CreateFrame("Button", "PrdUINotesFrameResizeButton", PrdUINotesFrame)
	rb:SetPoint("BOTTOMRIGHT", -5, 7)
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

	-- Create EditBox
	ed = CreateFrame("EditBox", "PrdUINotesFrameEditBox")
	ed:SetMultiLine(true)
	ed:SetFontObject(ChatFontNormal)
	ed:SetWidth(w-50) -- minus scrollbar
	ed:ClearAllPoints()
	ed:SetPoint("TOPLEFT", 8, 0)
	ed:SetAutoFocus(false)
	ed:SetTextColor(1, 0.8, 0.85, 1) -- 255, 204, 217
	ed:SetIgnoreParentAlpha(true)

	-- Add the EditBox to the scroll
	f.ScrollFrame:SetScrollChild(ed)

	-- Set default text
	ed:SetText(core.data.notepad)
	ed:SetCursorPosition(0)

	-- Set handlers for events and pressed keys
	ed:SetScript("OnEscapePressed", function()
		ed:ClearFocus()
	end)
	ed:SetScript("OnTabPressed", function(self)
		self:Insert("    "); -- (4 spaces)
	end)
	ed:SetScript("OnKeyUp", function(self, key)
		core.data.notepad = ed:GetText() -- save text
	end)
	ed:SetScript("OnCursorChanged", function(self, arg1, arg2, arg3, arg4)
		-- Autoscroll on input
		local vs = f.ScrollFrame:GetVerticalScroll()
		local h  = f.ScrollFrame:GetHeight()
		if vs+arg2 > 0 or 0 > vs+arg2-arg4+h then
			f.ScrollFrame:SetVerticalScroll(arg2*-1);
		end
	end)

	-- Add onlick focus outside editbox
	f.ScrollFrame:SetScript("OnMouseDown", function()
		ed:SetCursorPosition(ed:GetText():len())
		ed:SetFocus()
	end)

	f:Hide()
end

function Notes:Toggle()
	core:Debug("Notes: Toggle")
	f:SetShown(not f:IsShown())
	core.options.notepadOpen = f:IsShown()
end

-- This hijacks the global chatedit link insertion and listens for hyperlink clicks
function Notes:SetupChatLinks()
	core:Debug("Notes: SetupChatLinks")

	-- Enable inserting link items
	local old_ChatEdit_InsertLink = ChatEdit_InsertLink
	function ChatEdit_InsertLink(text)
		if ed:HasFocus() then
			ed:Insert(text)
			return true -- prevents the stacksplit frame from showing
		else
			return old_ChatEdit_InsertLink(text)
		end
	end

	-- Enable clicking on link items
	ed:SetHyperlinksEnabled(true)
	ed:SetScript("OnHyperlinkClick", function(self, link, text, button)
		core:Debug("Notes: Hyperlink clicked")
		SetItemRef(link, text, button)
	end)

end
