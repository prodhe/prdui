-- Load and set namespace
local _, core = ...
core.ChatFilter = {}
local ChatFilter = core.ChatFilter

local chatFilterNeedle = ""
local f = nil

-- Create the area from which other elements will position into
function ChatFilter:Create()
	core:Debug("ChatFilter: Create")

	-- Create ChatFilterFrame
	f = CreateFrame("Frame")
	f:Hide()

	-- Events
	core:RegisterEvents(f, ChatFilter.HandleEvents,
		"CHAT_MSG_CHANNEL"
	)
	f:UnregisterEvent("CHAT_MSG_CHANNEL")

end

function ChatFilter:HandleEvents(event, ...)
	core:Debug("ChatFilter: HandleEvents:", event)

	if event == "CHAT_MSG_CHANNEL" then
		if chatFilterNeedle == "" then return end

		local text, pn, _, channelName, _, _, _, channelIndex, _, _, _, guid = ...
		local t = date("%H:%M:%S", GetServerTime())
		core:Debug("ChatFilter: HandleEvents:", event)
		ChatFilter:ParseMsg(t, channelName, channelIndex, pn, guid, text)

	else
		core:Debug("ChatFilter: HandleEvents: not handled:", event)
	end
end

function ChatFilter:SetNeedle(needle)
	core:Debug("ChatFilter: SetNeedle")
	if not needle then
		needle = ""
	end
	chatFilterNeedle = needle

	core.Config:UpdateFields()

	if needle == "" then
		f:UnregisterEvent("CHAT_MSG_CHANNEL")
		core:Print("LFG filter cleared and disabled.")
	else
		f:RegisterEvent("CHAT_MSG_CHANNEL")
		core:Print("LFG filter set to:", needle)
	end
end

function ChatFilter:GetNeedle()
	return chatFilterNeedle
end

function ChatFilter:ParseMsg(t, channelName, channelIndex, pn, guid, text)
	core:Debug("ChatFilter: ParseMsg")

	-- Filter text
	local found = false

	if channelIndex ~= 4 then -- LFG channel only
		return
	end

	needle = string.match(string.lower(text), chatFilterNeedle)
	if needle then found = true end

	if not found then return end -- do nothing (return) if no match

	-- Go on and print the message
	local msg = ""
	if guid then -- could be empty if it is an in-game message without player sender
		_, _, _, _, _, pn = GetPlayerInfoByGUID(guid)
	end
	pn = "|Hplayer:" .. pn .. "|h[" .. pn .. "]|h"
	channel = "[" .. channelIndex .. "]"
	msg = "|cffFFC0C0" .. t .. " [Filter] " .. channel .. " " .. pn .. ": " .. text .."|r"

	core:PrintPlain(msg)
end
