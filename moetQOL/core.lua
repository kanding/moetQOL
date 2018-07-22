---------------------------------------------------
-- TODO
---------------------------------------------------
-- remove class colouring in chat
-- only suggest /reload if actually needed (if user flip once without change)
-- add FPS / garbage collector / MS , rInfoStrings replacement
-- HIDE CHAT BUTTONS
---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns			= ... -- namespace
ns.Core				= {} -- add the core to the namespace
local Core			= ns.Core
local fColor		= "00CC0F00" -- red
local fColor2		= "FF00FF00" -- green

---------------------------------------------------
-- FUNCTIONS (see helper functions below)
---------------------------------------------------
-- main function will fire on load and activate all features that are On
function Core:ActivateFunctions()
	if (moetQOLDB["maxzoom"][1] == "On") then
		SetCVar("cameraDistanceMaxZoomFactor", 2.6)
	end

	if (moetQOLDB["hideportraitnumbers"][1] == "On") then
		ns.Core.HidePortraitNumbers()
	end

	if (moetQOLDB["fastloot"][1] == "On") then
		ns.Core.EnableFastLoot()
	end

	-- NOTE: This still shows UI_INFO_MESSAGES
	if (moetQOLDB["errormsg"][1] == "On") then
		UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	end

	-- EASY DELETE CONFIRM modified by moet
	-- written by Kesava-Auchindoun, all credits go to creator
	if (moetQOLDB["easydelete"][1] == "On") then
		ns.Core.EnableEasyDelete()
	end
end

---------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------

function Core:PrintFlags()
	print(" ")
	for key, value in pairs(moetQOLDB) do
		if (value[1] == "Off") then
			print(string.format("|c%s%s|r: %s", fColor, key, value[1]))
		else
			print(string.format("|c%s%s|r: |c%s%s|r", fColor, key, fColor2, value[1]))
		end
	end
end

function Core:PrintHelp()
	print("List of commands:")
	print("/mq |c" .. fColor2 .. "flags|r - to show your current settings.")
	print("/mq |c" .. fColor2 .. "hardreset|r - to reset all saved settings to default (off).")
	print("/mq |c" .. fColor2 .. "sell|r - sell up to 12 |cff9d9d9dGrey|r items to vendor at a time.")
	print(" ")
end

function Core:HidePortraitNumbers()
	PlayerHitIndicator.Show = function() end
	PetHitIndicator.Show = function() end
	CombatFeedback_OnCombatEvent = function() end
end

function Core:EnableFastLoot()
	SetCVar("autoLootDefault", "1") -- set auto loot to enabled

	local tDelay = 0 -- Time delay

	local function FastLoot()
		if GetTime() - tDelay >= 0.3 then
			tDelay = GetTime()
 				if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
					for i = GetNumLootItems(), 1, -1 do
						LootSlot(i)
					end
				tDelay = GetTime()
			end
		end
	end

	local lootEventFrame = CreateFrame("Frame")
	lootEventFrame:RegisterEvent("LOOT_READY")
	lootEventFrame:SetScript("OnEvent", FastLoot)
end

-- TODO: rework so its not a function within a function URGH (^_^)>/
function Core:EnableEasyDelete()
	local deleteFrame = CreateFrame('Frame','EasyDeleteConfirmFrame')

	function deleteFrame:DELETE_ITEM_CONFIRM(...) -- cant be local, calls to global
		if StaticPopup1EditBox:IsShown() then
			StaticPopup1EditBox:Hide()
			StaticPopup1Button1:Enable()

			local link = select(3,GetCursorInfo())

			deleteFrame.link:SetText(link)
			deleteFrame.link:Show()
		end
	end

	-- create item link container
	deleteFrame.link = StaticPopup1:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	deleteFrame.link:SetPoint('CENTER', StaticPopup1EditBox)
	deleteFrame.link:Hide()

	StaticPopup1:HookScript('OnHide', function(self)
		deleteFrame.link:Hide()
	end)

	deleteFrame:SetScript('OnEvent', function(self,event,...)
		self[event](self,...)
	end)

	deleteFrame:RegisterEvent('DELETE_ITEM_CONFIRM')
end

function Core:FlipLuaErrorsFlag()
	if (GetCVar("ScriptErrors")=="1") then
		SetCVar("ScriptErrors", "0")
		moetQOLDB["luaerrors"][1] = "Off"
		print("|c" .. fColor .. "luaerrors" .. "|r: Off")
	else
		SetCVar("ScriptErrors", "1")
		moetQOLDB["luaerrors"][1] = "On"
		print(string.format(
		"|c%sluaerrors|r: |c%sOn|r - Make sure you |c%s/reload|r for the change to take effect.", 
		fColor, fColor2, fColor))
	end	
end

--NOTE: this only sells 12 items at a time, rest will say
--object is busy.
function Core:SellGreyItems()
	if (MerchantFrame:IsVisible()) then
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				local item = GetContainerItemLink(bag, slot)
				if item then
					local grey = string.find(item, "|cff9d9d9d") -- grey
					if (grey) then
						currPrice = (select(11, GetItemInfo(item)) or 0) * select(2, GetContainerItemInfo(bag, slot))
						if currPrice > 0 then
							PickupContainerItem(bag, slot)
							PickupMerchantItem()
						end
					end
				end
			end
		end
	else
		print("|c" .. fColor .. "mq|r: You need to open trade with a merchant to sell.")
		return
	end
end