-- Load and set namespace
local _, core = ...
core.Merchant = {}
local Merchant = core.Merchant

local merchantOpen = false

-- Create the area from which other elements will position into
function Merchant:Create()
	core:Debug("Merchant: Create")

	-- Create MerchantFrame 
	Merchant.Frame = core.Config:CreateButton("TOPLEFT", MerchantFrameTab1, "TOPLEFT", 25, "Sell trash", function()
		Merchant:SellJunk()
	end)
	Merchant.Frame:SetFrameStrata("HIGH") -- above the wow merchant window
	Merchant.Frame:SetWidth(160)
	Merchant.Frame:Hide()

	-- Events
	core:RegisterEvents(Merchant.Frame, Merchant.HandleEvents,
		"MERCHANT_SHOW",
		"MERCHANT_CLOSED"
	)

end

-- Handle events and reposition some stuff that is otherwise immovable
function Merchant:HandleEvents(event, arg1, ...)
	if event == "MERCHANT_SHOW" then
		core:Debug("Merchant: HandleEvents:", event)
		merchantOpen = true
		Merchant.Frame:Show()

	elseif event == "MERCHANT_CLOSED" then
		core:Debug("Merchant: HandleEvents:", event)
		merchantOpen = false
		Merchant.Frame:Hide()

	else
		core:Debug("Merchant: HandleEvents: not handled:", event)
	end
end

function Merchant:SellJunk()
	if not merchantOpen then return end

	local nItems = 0

	for bagID = BACKPACK_CONTAINER, NUM_BAG_SLOTS, 1
	do
		for bagSlot = 1, 20, 1
		do
			_, _, _, itemRarity, _, _, itemLink = GetContainerItemInfo(bagID, bagSlot)
			if itemLink and itemRarity < 1 then
				core:Debug("Merchant: SellJunk: Selling:", itemLink)
				UseContainerItem(bagID, bagSlot)
				nItems = nItems + 1
			end
		end
	end

	if nItems > 0 then
		core:Debug("Merchant: Sold", nItems, "slots of poor quality items.")
	end
end