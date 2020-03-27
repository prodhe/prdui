-- Load and set namespace
local _, core = ...
core.Notes = {}
local Notes = core.Notes

-- Stored data
core.data.notepad = ""
core.options.notepadOpen = nil
core.options.notepadWidth = 240
core.options.notepadHeight = 280

local f
local ed

-- Create the notes frame
function Notes:Create()
	core:Debug("Notes: Create")

	-- Create NotesFrame
	f = CreateFrame("Frame", "PrdUINotesFrame", UIParent, "UIPanelDialogTemplate")
	f.DialogBG = _G[f:GetName() .. "DialogBG"]
	local w = 240
	local h = 280
	if not core.options.notepadWidth and not core.options.notepadHeight then
		w = core.options.notepadWidth
		h = core.options.notepadHeight
		core:Debug("Notes: Using user size")
	end
	f:SetSize(w, h)
	f:SetAlpha(1)
	f.DialogBG:SetAlpha(0.8)
	f:SetPoint("CENTER", UIParent, "CENTER")
	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	f.title:SetPoint("CENTER", f.Title, "CENTER", 0, -7)
	f.title:SetText("Notepad")

	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	f:SetClampedToScreen(true)

	-- f:EnableKeyboard(true)
	-- f:SetScript("OnKeyDown", function(self, key)
		-- if key == "ESCAPE" then
			-- core.Notes:Toggle()
			-- f:SetPropagateKeyboardInput(false)
		-- else
			-- f:SetPropagateKeyboardInput(true)
		-- end
	-- end)

	f.ScrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
	f.ScrollFrame:SetPoint("TOPLEFT", f.DialogBG, "TOPLEFT", 4, -8)
	f.ScrollFrame:SetPoint("BOTTOMRIGHT", f.DialogBG, "BOTTOMRIGHT", -3, 4)
	f.ScrollFrame:SetClipsChildren(true)

	f.ScrollFrame.ScrollBar:ClearAllPoints()
	f.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", f.ScrollFrame, "TOPRIGHT", -12, -18)
	f.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", f.ScrollFrame, "BOTTOMRIGHT", -7, 18)

	-- Create EditBox
	ed = CreateFrame("EditBox")
	ed:SetMultiLine(true)
	ed:SetFontObject(ChatFontNormal)
	ed:SetWidth(w-50) -- minus scrollbar
	ed:ClearAllPoints()
	ed:SetPoint("TOPLEFT", 8, 0)
	ed:SetAutoFocus(false)
	ed:SetTextColor(1, 0.8, 0.85, 1) -- 255, 204, 217

	ed:SetText(core.data.notepad)

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

	-- Add onlick focus
	f.ScrollFrame:SetScript("OnMouseDown", function()
		ed:SetFocus()
	end)

	-- Add the EditBox to the scroll
	f.ScrollFrame:SetScrollChild(ed)

	-- Hide
	f:Hide()
end

function Notes:Toggle()
	core:Debug("Notes: Toggle")
	f:SetShown(not f:IsShown())
	core.options.notepadOpen = f:IsShown()
end

function Notes:SetSize(w, h)
	core:Debug("Notes: SetSize: ", w, h)
	if w == nil or w == "" then
		w = 200
	end
	if h == nil or h == "" then
		h = 240
	end
	
	if w and h then
		core.options.notepadWidth = w
		core.options.notepadHeight = h
	end

	f:SetSize(w, h)
	ed:SetWidth(w-50) -- minus scrollbar
end
