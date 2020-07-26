-- Load and set namespace
local _, core = ...

-- Stored default options.
core.options = {}
core.charOptions = {}
core.data = {}
core.options.debug = false -- print debug statements
core.options.chat = false -- activate to allow arrows and meta in chat edit box

-- LoadDB tries to load the SavedVariables
function core:LoadDB()
	if _G["PRDUIDBCHAR"] == nil then
		_G["PRDUIDBCHAR"] = {
			charOptions = core.charOptions
		}
	end

	if _G["PRDUIDB"] == nil then
		_G["PRDUIDB"] = {
			options = core.options,
			data = core.data
		}
		_G["PRDUIDBCHAR"] = {
			charOptions = core.charOptions
		}
		core:Debug("Core: LoadDB: defaults")
	else
		-- Check if options are nil or not and then link it to core.options
		if _G["PRDUIDB"].options then
			core.options = _G["PRDUIDB"].options
		else
			_G["PRDUIDB"].options = core.options
		end

		if _G["PRDUIDBCHAR"].charOptions then
			core.charOptions = _G["PRDUIDBCHAR"].charOptions
		else
			_G["PRDUIDBCHAR"].charOptions = core.charOptions
		end

		core.data = _G["PRDUIDB"].data
		core:Debug("Core: LoadDB: user")
	end
end

function core:RestoreDefaults()
	_G["PRDUIDB"].options = nil
	_G["PRDUIDBCHAR"].charOptions = nil
	core:Print("Restored defaults.")
	ReloadUI()
end

-- Print is a prefixed print function
function core:Print(...)
	print("|cff" .. "f59c0a" .. "PrdUI:|r", ...)
end

-- PrintPlain is a non-prefixed print function
function core:PrintPlain(...)
	print("|cff" .. "f59c0a", ...)
end

-- Debug is a prefixed print function, which only prints if debug is activated
function core:Debug(...)
	if core.options.debug then
		print("|cff" .. "f59c0a" .. "PrdUI-DEBUG:|r", ...)
	end
end
function core:ToggleDebug()
	if core.options.debug then
		core.options.debug = false
		core:Print("Debugging off.")
	else
		core.options.debug = true
		core:Print("Debugging on.")
	end
end

-- RegisterEvents sets events for the obj using the handlerFunc
function core:RegisterEvents(obj, handlerFunc, ...)
	core:Debug("Core: RegisterEvents:", tostringall(...))
	for i = 1, select("#", ...) do
		local ev = select(i, ...)
		obj:RegisterEvent(ev)
	end
	obj:SetScript("OnEvent", handlerFunc)
end

-- SetChat sets editing with arrows in chat message based on core.options.chat
function core:SetChat()
	core:Debug("Core: SetChat:", core.options.chat)
	local maybe = true
	if core.options.chat then
		maybe = false
	end
	for i = 1, NUM_CHAT_WINDOWS do
		_G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(maybe)
	end
end
