-- moet, 2020
-- Some functionality is inspired or moved
-- here for future maintenance
-- Credit is always given above the function.
---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns	= ... -- namespace
ns.Core	= {} -- add the core to the namespace
local Core = ns.Core
local F_COLOR = "00CC0F00" -- red
local F_COLOR2 = "FF00FF00" -- green
--indices for state, description and associated function in default table
Core.STATE = 1
Core.DESC = 2
Core.FUNC = 3
local STATE, DESC, FUNC = Core.STATE, Core.DESC, Core.FUNC

---------------------------------------------------
-- HELPER FUNCTIONS (see main function below)
---------------------------------------------------
function Core:PrintFlags()
	for key, value in pairs(moetQOLDB) do
		if Core.MQdefault[key] then
			if (value[STATE] == "Off") then
				print(string.format("|c%s%s|r: %s", F_COLOR, key, value[STATE]))
			else
				print(string.format("|c%s%s|r: |c%s%s|r", F_COLOR, key, F_COLOR2, value[STATE]))
			end
		end
	end
end

function Core:PrintHelp()
	print("|c00CC0F00moetQOL|r V"..ns.ADDON_VERSION.." List of commands:")
	print("/mq |c" .. F_COLOR2 .. "flags|r - to show your current settings.")
	print("/mq |c" .. F_COLOR2 .. "hardreset|r - to reset all saved settings to default (off).")
	for key, value in pairs(Core.MQdefault) do
		print(string.format("/mq |c%s%s|r - %s.", F_COLOR, key, value[DESC]))
	end
end

local function HidePortraitNumbers()
	PlayerHitIndicator.Show = function() end
	PetHitIndicator.Show = function() end
	CombatFeedback_OnCombatEvent = function() end
end

local function EnableFastLoot()
	SetCVar("autoLootDefault", "1") -- set auto loot to enabled

	local tDelay = 0

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

-- EasyDelete by Kesava
-- Moved here to maintain
-- https://github.com/kesava-wow/easydeleteconfirm
local function EnableEasyDelete()
	local deleteFrame = CreateFrame('Frame','EasyDeleteConfirmFrame')

	function deleteFrame:DELETE_ITEM_CONFIRM(...)
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
	if not MerchantFrame:IsVisible() then return end

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local item = GetContainerItemLink(bag, slot)
			if item ~= nil then
				local grey = string.find(item, "|cff9d9d9d") -- grey
				if grey then
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

local function CreateSellButton()
	local merchantButton = CreateFrame("Button", "moetQOL_SellButton", MerchantFrame, "LFGListMagicButtonTemplate") 
	merchantButton:SetPoint("BOTTOMLEFT", 87, 4)
	merchantButton:SetText("Sell Greys")
	merchantButton:SetScript("OnClick", SellGreyItems)

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

-- Inspired by rInfostring by zork
-- Moved here to rework and maintain.
-- https://github.com/zorker/rothui
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
	posFrame:SetMovable(true)
	posFrame:RegisterForDrag("LeftButton")
	posFrame:SetScript("OnDragStart", function() 
		if IsAltKeyDown() then 
			posFrame:StartMoving()
		end
	end)
	posFrame:SetScript("OnDragStop", posFrame.StopMovingOrSizing)

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
	local f = CreateFrame("FRAME")
	f:RegisterEvent("PLAYER_LOGIN")
	f:SetScript("OnEvent", function()
		if IsInGuild() then
			GuildFrame_LoadUI()
			tinsert(UISpecialFrames, "GuildFrame")

			ToggleGuildFrame = function()
				if GuildFrame:IsVisible() then
					HideUIPanel(GuildFrame)
				else
					ShowUIPanel(GuildFrame)
				end
			end
		end

		f:UnregisterEvent("PLAYER_LOGIN")
		f = nil
	end)

	-- All this to be able to open the guild frame in combat :-)
	-- Above function will still cause 'taint'.
	hooksecurefunc("ShowUIPanel",function(frame,force,duplicated)
		if frame and not frame:GetName() == "GuildFrame" then return end
        
        if frame and not frame:IsShown() and not duplicated and InCombatLockdown() and not WorldMapFrame:IsShown() then
            local point,_,relativePoint,xOff,yOff = frame:GetPoint()
            frame:ClearAllPoints()
            frame:SetPoint(point or "TOPLEFT",UIParent,relativePoint or "TOPLEFT",xOff or 16,yOff or -116.00000762939)
			frame:Show()
        end
	end)

	hooksecurefunc("HideUIPanel",function(frame,force,duplicated)
		if frame and not frame:GetName() == "GuildFrame" then return end
        
        if frame and frame:IsShown() and not duplicated and InCombatLockdown() then
			frame:Hide()
        end
	end)
end

local function HideTalkingHead()
	LoadAddOn("Blizzard_TalkingHeadUI")
	hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
		TalkingHeadFrame_CloseImmediately()
	end)
end

local function InstantQueueMythicIsland()
	local f = CreateFrame("FRAME")
	f:RegisterEvent("ISLANDS_QUEUE_OPEN")
	f:SetScript("OnEvent", function(self, event, ...)
		if event == "ISLANDS_QUEUE_OPEN" then
			C_IslandsQueue.QueueForIsland(1737)
		end
	end)
end

local function SetMaxZoom()
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)
end

-- Hide Error Messages inspired by zork rError (here for continued maintenance)
-- https://github.com/zorker/rothui
local function HideErrorMessages()
	local blacklist = {
		["ERR_ABILITY_COOLDOWN"] = true,           -- Ability is not ready yet. (Ability)
		["ERR_ITEM_COOLDOWN"] = true,
		["ERR_SPELL_OUT_OF_RANGE"] = true,
		["ERR_BADATTACKPOS"] = true,
		["ERR_OUT_OF_ENERGY"] = true,              -- Not enough energy. (Err)
		["ERR_OUT_OF_RANGE"] = true,
		["ERR_OUT_OF_RAGE"] = true,                -- Not enough rage.
		["ERR_OUT_OF_FOCUS"] = true,                -- Not enough focus
		["ERR_ATTACK_MOUNTED"] = true,
		["ERR_NO_ATTACK_TARGET"] = true,           -- There is nothing to attack.
		["SPELL_FAILED_MOVING"] = true,
		["SPELL_FAILED_AFFECTING_COMBAT"] = true,
		["ERR_NOT_IN_COMBAT"] = true,
		["SPELL_FAILED_UNIT_NOT_INFRONT"] = true,
		["ERR_BADATTACKFACING"] = true,
		["SPELL_FAILED_TOO_CLOSE"] = true,
		["ERR_INVALID_ATTACK_TARGET"] = true,      -- You cannot attack that target.
		["ERR_SPELL_COOLDOWN"] = true,             -- Spell is not ready yet. (Spell)
		["SPELL_FAILED_NO_COMBO_POINTS"] = true,   -- That ability requires combo points.
		["SPELL_FAILED_TARGETS_DEAD"] = true,      -- Your target is dead.
		["SPELL_FAILED_SPELL_IN_PROGRESS"] = true, -- Another action is in progress. (Spell)
		["SPELL_FAILED_TARGET_AURASTATE"] = true,  -- You can't do that yet. (TargetAura)
		["SPELL_FAILED_CASTER_AURASTATE"] = true,  -- You can't do that yet. (CasterAura)
		["SPELL_FAILED_NO_ENDURANCE"] = true,      -- Not enough endurance
		["SPELL_FAILED_BAD_TARGETS"] = true,       -- Invalid target
		["SPELL_FAILED_NOT_MOUNTED"] = true,       -- You are mounted
		["SPELL_FAILED_NOT_ON_TAXI"] = true,       -- You are in flight
	}

	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")

	local function OnUIErrorMessage(self, event, messageType, message)
		local errorName, soundKitID, voiceID = GetGameMessageInfo(messageType)
	
		if blacklist[errorName] then return end
		UIErrorsFrame:AddMessage(message, 1, .1, .1)
	end

	local eventHandler = CreateFrame("Frame")
	eventHandler:SetScript("OnEvent", OnUIErrorMessage)
	eventHandler:RegisterEvent("UI_ERROR_MESSAGE")
end

local function MoetTweaks()
	WorldMapFrame:SetFrameStrata("FULLSCREEN")
end

-- Inspired by AutoRepair
-- Credit: https://www.curseforge.com/wow/addons/autorepair
local function AutoRepair()
	local f = CreateFrame("FRAME")
	f:RegisterEvent("MERCHANT_SHOW")
	f:SetScript("OnEvent", function(self, event, ...)
		if event == "MERCHANT_SHOW" and CanMerchantRepair() then
			repairAllCost, canRepair = GetRepairAllCost()
			if canRepair and repairAllCost <= GetMoney() then
				RepairAllItems(false) -- use player funds
				DEFAULT_CHAT_FRAME:AddMessage("Your items have been repaired for "..GetCoinText(repairAllCost,", ")..".",255,255,0)
			end
		end
	end)
end

-- Inspired by ExaltedPlus
-- massively reworked :>
-- original: https://www.curseforge.com/wow/addons/exaltedplus
local function ParagonTooltip()
	local line = "" --safety

	hooksecurefunc("ReputationParagonFrame_SetupParagonTooltip", function(frame)
		id = frame.factionID

		curValue, threshold, _, rewardpending = C_Reputation.GetFactionParagonInfo(id)
		if curValue then
			turnins = (rewardpending and math.modf(curValue/threshold)-1) or (math.modf(curValue/threshold))
		end

		line = format(ARCHAEOLOGY_COMPLETION, turnins)

		EmbeddedItemTooltip:AddLine(line)
		EmbeddedItemTooltip:Show()

	end)

	hooksecurefunc("ReputationParagonFrame_OnLeave", function(self)
		if line then
			line = ""
		end
	end)
end

-- Inspired by RealIDCounter
-- reworked
-- original: https://www.curseforge.com/wow/addons/ridc
local function RealIDCounter()
	local f = CreateFrame("FRAME", "moetQOL_RealIDCounter", FriendsTabHeaderTab3)
	f:SetPoint("TOPLEFT", FriendsTabHeaderTab3, "TOPRIGHT", 7, -12)
	f:SetWidth(50)
	f:SetHeight(20)

	local fstring = f:CreateFontString("moetQOL_RealIDCounterString", "OVERLAY", "GameFontNormal")
	fstring:SetFont(STANDARD_TEXT_FONT, 11, "NONE")
	fstring:SetPoint("CENTER", f)
	fstring:SetWidth(fstring:GetStringWidth())
	fstring:SetHeight(fstring:GetStringHeight())
	local k,_ = BNGetNumFriends()
	fstring:SetText(k.."/200")
	
	f:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
	f:SetScript("OnEvent", function()
		local k,_ = BNGetNumFriends()
		fstring:SetText(k.."/200")
	end)
end

local function HideTooltipInCombat()
	GameTooltip:SetScript("OnShow", function()
		if InCombatLockdown() then
			local point, t = GameTooltip:GetPoint()
			if t and t.firstTimeLoaded then
				GameTooltip:Hide()
			end
		end
	end)
end

---------------------------------------------------
-- MAIN FUNCTION
---------------------------------------------------
Core.MQdefault = {
	-- key = name, value[1] = state, value[2] = description, value[3] = function to execute if state is On
	["maxzoom"]	= {"Off", "sets camera distance CVar to maximum available", SetMaxZoom},
	["portraitnumbers"] = {"Off", "show/hide combat numbers on your portrait", HidePortraitNumbers},
	["fastloot"] = {"Off", "faster auto looting", EnableFastLoot},
	["errormsg"] = {"Off", "hide generic red error messages", HideErrorMessages},
	["easydelete"] = {"Off", "remove the need to type 'delete' on rare+ items", EnableEasyDelete},
	["voicebuttons"] = {"Off", "show/hide Voice chat buttons", HideVoiceButtons},
	["skipmovies"] = {"Off", "auto skip all cutscenes", AutoCancelCutscenes},
	["borders"] = {"Off", "hides some Blizzard UI borders", HideBlizzardBorders},
	["infostring"] = {"Off", "shows MS and FPS beneath minimap (moveable with ALT+LClick)", CreateInfoStrings},
	["sell"] = {"Off", "adds a button on merchants to sell grey items", CreateSellButton},
	["oldguild"] = {"Off", "Reverts to old guild frame if you're in a guild", HideCommunities},
	["talkinghead"] = {"Off", "hides talking head frames", HideTalkingHead},
	["fastislands"] = {"Off", "instantly queues mythic islands upon opening the table", InstantQueueMythicIsland},
	["tweaks"] = {"Off", "small random tweaks for myself", MoetTweaks},
	["autorepair"] = {"Off", "automatically repair items when possible using player funds", AutoRepair},
	["paragontooltip"] = {"Off", "adds total completions to paragon tooltip", ParagonTooltip},
	["realidcounter"] = {"Off", "adds a counter that shows current out of total friends", RealIDCounter},
	["combattooltip"] = {"Off", "hides tooltip if in combat", HideTooltipInCombat},
}

function Core:ActivateFunctions()
	for k,v in pairs(moetQOLDB) do
		if v[STATE] == "On" and Core.MQdefault[k] then
			if Core.MQdefault[k][FUNC] then
				Core.MQdefault[k][FUNC]()
			else
				print("|c"..F_COLOR.."mq|r: "..k.." is missing an associated function.")
			end
		end
	end
end