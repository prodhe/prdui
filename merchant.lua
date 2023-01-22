-- Load and set namespace
local _, core = ...
core.Merchant = {}
local Merchant = core.Merchant

core.options.merchantenable = false

-- Create the area from which other elements will position into
function Merchant:Create()
	core:Debug("Merchant: Create")

	-- Create MerchantFrame 
	Merchant.Frame = core.Config:CreateButton("TOPLEFT", MerchantFrameTab1, "TOPLEFT", 25, "Sell trash", function()
		Merchant:SellJunk()
	end)
	Merchant.Frame:SetFrameStrata("HIGH") -- above the wow merchant window
	Merchant.Frame:SetWidth(160)
	Merchant.Frame:Disable()
	Merchant.Frame:Hide()

	-- Events
	core:RegisterEvents(Merchant.Frame, Merchant.HandleEvents,
		"MERCHANT_SHOW",
		"MERCHANT_CLOSED",
		"BAG_UPDATE_DELAYED" -- for selling and buying back when merchant windows is open
	)

end

-- Handle events
function Merchant:HandleEvents(event, arg1, ...)
	core:Debug("Merchant: HandleEvents:", event)

	if event == "MERCHANT_SHOW" then
		if Merchant:FindTrash() then
			Merchant.Frame:Enable()
		end
		Merchant.Frame:Show()

	elseif event == "MERCHANT_CLOSED" then
		Merchant.Frame:Disable()
		Merchant.Frame:Hide()

	elseif event == "BAG_UPDATE_DELAYED" then
		if Merchant.Frame:IsShown() and Merchant:FindTrash() then
			Merchant.Frame:Enable()
		end

	else
		core:Debug("Merchant: HandleEvents: not handled:", event)
	end
end

function Merchant:FindTrash()
	for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS, 1
	do
		for bagSlot = 1, 20, 1
		do
			local ci = C_Container.GetContainerItemInfo(bagID, bagSlot)
			if ci ~= nil then -- there was an item at pos bagID,bagSlot
				if ci.quality < 1 then
					return true -- found one, no need to loop more
				end
			end
		end
	end
	return false -- no poor quality items found
end

function Merchant:SellJunk()
	if not Merchant.Frame:IsShown() then return end

	local nItems = 0
	local sellValueCopper = 0

	for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS, 1
	do
		for bagSlot = 1, 20, 1
		do
			local ci = C_Container.GetContainerItemInfo(bagID, bagSlot)
			if ci ~= nil then
				if ci.quality < 1 then
					core:Debug("Merchant: SellJunk: Selling:", ci.hyperlink)
					_, _, _, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(ci.itemID)
					sellValueCopper = sellValueCopper + itemSellPrice
					C_Container.UseContainerItem(bagID, bagSlot)
					nItems = nItems + 1
				end
			end
		end
	end

	if nItems > 0 then
		core:Debug("Merchant: Sold", nItems, "slots of poor quality items.")
		core:PrintPlain("Sold vendor trash for " .. Merchant:MoneyToString(Merchant:Money(sellValueCopper)) .. ".")
		Merchant.Frame:Disable()
	end
end

function Merchant:Money(m)
	local c = m % 100
	m = (m - c) / 100
	local s = m % 100
	local g = (m - s) / 100

	return g, s, c
end

function Merchant:MoneyToString(g, s, c)
	if g > 0 then
		return g .. "g " .. s .. "s " .. c .. "c"
	elseif s > 0 then
		return s .. "s " .. c .. "c"
	else
		return c .. "c"
	end
end
