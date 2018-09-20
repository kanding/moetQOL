---------------------------------------------------
-- TODO
---------------------------------------------------
-- make infostrings dragable & lockable
-- fix hide ui and infostrings
---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns			= ... -- namespace
ns.Core				= {} -- add the core to the namespace
local Core			= ns.Core
local fColor		= "00CC0F00" -- red
local fColor2		= "FF00FF00" -- green

---------------------------------------------------
-- HELPER FUNCTIONS (see main function below)
---------------------------------------------------
function Core:PrintFlags()
	print(" ")
	local tablecount = 0
	for key, value in pairs(moetQOLDB) do
		tablecount = tablecount + 1
		if (value[1] == "Off") then
			print(string.format("|c%s%s|r: %s", fColor, key, value[1]))
		else
			print(string.format("|c%s%s|r: |c%s%s|r", fColor, key, fColor2, value[1]))
		end
	end

	-- maybe database versioning instead
	if (tablecount > ns.GetDefaultTableCount()) then
		print(string.format(
		"You may have outdated keys, consider using |c%s/mq|r |c%shardreset|r", 
		fColor, fColor2))
	end
end

function Core:PrintHelp()
	print("List of commands:")
	print("/mq |c" .. fColor2 .. "flags|r - to show your current settings.")
	print("/mq |c" .. fColor2 .. "hardreset|r - to reset all saved settings to default (off).")
	print(" ")
end

local function HidePortraitNumbers()
	PlayerHitIndicator.Show = function() end
	PetHitIndicator.Show = function() end
	CombatFeedback_OnCombatEvent = function() end
end

local function EnableFastLoot()
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
local function EnableEasyDelete()
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

--NOTE: this only sells 12 items at a time, rest will say object is busy.
local function SellGreyItems()
	if (MerchantFrame:IsVisible()) then
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				local item = GetContainerItemLink(bag, slot)
				if (item ~= nil) then
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
	end
end

local function CreateSellButton()
	local merchantButton = CreateFrame("Button", "moetQOL_SellButton", MerchantFrame, "LFGListMagicButtonTemplate") 
	merchantButton:SetPoint("BOTTOMLEFT", 87, 4)
	merchantButton:SetText("Sell Greys")
	merchantButton:SetScript("OnClick", function() 
		SellGreyItems() 
	end)

	merchantButton:RegisterEvent("MERCHANT_SHOW")
	merchantButton:SetScript("OnEvent", function()
		if MerchantExtraCurrencyBg:IsVisible() then
			MerchantMoneyFrame:Hide()
			MerchantExtraCurrencyBg:Hide()
		else
			MerchantMoneyFrame:Show()
		end
	end)
end

local function HideVoiceButtons()
	local hiddenFrame = CreateFrame("Frame")
	hiddenFrame:Hide()

	ChatFrameMenuButton:SetParent(hiddenFrame)
	ChatFrameChannelButton:SetParent(hiddenFrame)
	ChatFrameToggleVoiceDeafenButton:SetParent(hiddenFrame)
	ChatFrameToggleVoiceMuteButton:SetParent(hiddenFrame)
end

local function AutoCancelCutscenes()
	CancelCutsceneFrame = CreateFrame("Frame")
	CancelCutsceneFrame:RegisterEvent("CINEMATIC_START")
	-- CancelCutsceneFrame:RegisterEvent("PLAY_MOVIE")

	CancelEventLoop = CancelCutsceneFrame:CreateAnimationGroup()
	CancelEventLoop.anim = CancelEventLoop:CreateAnimation()
	CancelEventLoop.anim:SetDuration(2)
	CancelEventLoop:SetLooping("REPEAT")
	CancelEventLoop:SetScript("OnLoop", function(self, event, ...)
		CancelEventLoop:Stop()
		CinematicFrame_CancelCinematic()
	end)

	CancelCutsceneFrame:SetScript("OnEvent", function(self, event, ...)
		CinematicFrame_CancelCinematic()
		CancelEventLoop:Play()
	end)
end

local function HideBlizzardBorders()
	local hiddenFrame = CreateFrame("Frame")
	hiddenFrame:Hide()

	CastingBarFrame.Border:SetParent(hiddenFrame)
	TargetFrameSpellBar.Border:SetParent(hiddenFrame)
	MirrorTimer1Border:SetParent(hiddenFrame)
end

local function InfoStringsGetFps() 
	return floor(GetFramerate()) .. "fps"
end

local function InfoStringsGetMs() 
	return select(3, GetNetStats()) .. "ms"
end

local function memoryformat(number)
	if number > 1024 then
		return string.format("%.2fmb", (number / 1024))
	else
		return string.format("%.1fkb", floor(number))
	end
end

-- from rInfoStrings by zork
local function CleanGarbage()
	UpdateAddOnMemoryUsage()
	local before = gcinfo()
	collectgarbage()
	UpdateAddOnMemoryUsage()
	local after = gcinfo()
	print("Cleaned: "..memoryformat(before-after))
end

local function addoncompare(a, b)
	return a.memory > b.memory
end

--function to create tooltip from rInfoStrings by zork
local function InfoStringTooltip(self)
	local addonlist = 50
	local color = { r=156/255, g=144/255, b=125/255 }
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -90, 90)
	local blizz = collectgarbage("count")
	local addons = {}
	local memory
	local total = 0
	local nr = 0
	UpdateAddOnMemoryUsage()
	GameTooltip:AddLine("Top "..addonlist.." AddOns", color.r, color.g, color.b)
	GameTooltip:AddLine(" ")
	for i=1, GetNumAddOns(), 1 do
		if (GetAddOnMemoryUsage(i) > 0 ) then
		memory = GetAddOnMemoryUsage(i)
		entry = {name = GetAddOnInfo(i), memory = memory}
		table.insert(addons, entry)
		total = total + memory
		end
	end
	table.sort(addons, addoncompare)
	for _, entry in pairs(addons) do
		if nr < addonlist then
		GameTooltip:AddDoubleLine(entry.name, memoryformat(entry.memory), 1, 1, 1, 1, 1, 1)
		nr = nr+1
		end
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("Total", memoryformat(total), color.r, color.g, color.b, color.r, color.g, color.b)
	GameTooltip:AddDoubleLine("Total incl. Blizzard", memoryformat(blizz), color.r, color.g, color.b, color.r, color.g, color.b)
	GameTooltip:Show()
end

-- pretty dirty, refactor .. later :^)
local function CreateInfoStrings()
	-- create clickable frame
	local posFrame = CreateFrame("FRAME", "moetQOL_Infostring", UIParent)
	posFrame:RegisterEvent("PET_BATTLE_OPENING_START")
	posFrame:RegisterEvent("PET_BATTLE_CLOSE")
	posFrame:RegisterEvent("CINEMATIC_START")
	posFrame:RegisterEvent("CINEMATIC_STOP")
	posFrame:SetPoint("TOP", Minimap, "BOTTOM", 0, -27)
	posFrame:SetWidth(65)
	posFrame:SetHeight(15)
	posFrame:EnableMouse(true)

	-- add mouse events
	posFrame:SetScript("OnMouseDown", function() CleanGarbage() end)
	posFrame:SetScript("OnEnter", function() InfoStringTooltip(posFrame) end)
	posFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
	posFrame:SetScript("OnEvent", function(self, event, ...)
		if event == "PET_BATTLE_OPENING_START" then
			self:Hide()
		elseif event == "PET_BATTLE_CLOSE" then
			self:Show()
		elseif event == "CINEMATIC_START" then
			self:Hide()
		elseif event == "CINEMATIC_STOP" then
			self:Show()
		end
	end)

	-- create text in frame
	local frameFontString = posFrame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	frameFontString:SetFont(STANDARD_TEXT_FONT, 11, "THINOUTLINE")
	frameFontString:SetText(InfoStringsGetFps() .. "  " .. InfoStringsGetMs())
	frameFontString:SetPoint("CENTER", posFrame)
	frameFontString:SetHeight(frameFontString:GetStringHeight())
	frameFontString:SetWidth(frameFontString:GetStringWidth() + 5)

	-- create animation loop group
	local infoStringEvents = CreateFrame("FRAME")
	local infoAnimation = infoStringEvents:CreateAnimationGroup()
	infoAnimation.anim = infoAnimation:CreateAnimation()
	infoAnimation.anim:SetDuration(1)
	infoAnimation:SetLooping("REPEAT")
	infoAnimation:SetScript("OnLoop", function()
		frameFontString:SetText(InfoStringsGetFps() .. " " .. InfoStringsGetMs())
	end)

	-- update text in frame on loop
	infoStringEvents:RegisterEvent("ADDON_LOADED")
	infoStringEvents:SetScript("OnEvent", function(self, event, ...)
		if event == "ADDON_LOADED" then
			infoAnimation:Play()
		end
	end)
end

local function HideCommunities()
	LoadAddOn("Blizzard_GuildUI") -- Load Guild UI
	LoadAddOn("Blizzard_Communities") -- Load Communities
	ToggleGuildFrame = function() 
		if GuildFrame:IsVisible() or CommunitiesFrame:IsVisible() then
			HideUIPanel(GuildFrame)
			HideUIPanel(CommunitiesFrame)
		else
			if IsInGuild() then
				ShowUIPanel(GuildFrame)
			else 
				ShowUIPanel(CommunitiesFrame)
			end
		end
	end
end

---------------------------------------------------
-- MAIN FUNCTION
---------------------------------------------------
-- will fire on load and activate all features that are On
function Core:ActivateFunctions()
	if (moetQOLDB["maxzoom"][1] == "On") then
		SetCVar("cameraDistanceMaxZoomFactor", 2.6)
	end

	if (moetQOLDB["portraitnumbers"][1] == "On") then
		HidePortraitNumbers()
	end

	if (moetQOLDB["fastloot"][1] == "On") then
		EnableFastLoot()
	end

	-- NOTE: This still shows UI_INFO_MESSAGES
	if (moetQOLDB["errormsg"][1] == "On") then
		UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	end

	-- EASY DELETE CONFIRM
	-- written by Kesava-Auchindoun, all credits go to creator
	if (moetQOLDB["easydelete"][1] == "On") then
		EnableEasyDelete()
	end

	if (moetQOLDB["voicebuttons"][1] == "On") then
		HideVoiceButtons()
	end

	if (moetQOLDB["skipmovies"][1] == "On") then
		AutoCancelCutscenes()
	end

	if (moetQOLDB["borders"][1] == "On") then
		HideBlizzardBorders()
	end

	-- from rInfostrings by zork in 50400
	-- fixed for 80000
	if (moetQOLDB["infostring"][1] == "On") then
		CreateInfoStrings()
	end

	if (moetQOLDB["sell"][1] == "On") then
		CreateSellButton()
	end

	if (moetQOLDB["communities"][1] == "On") then
		HideCommunities()
	end

end