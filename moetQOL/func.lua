-- moet, 2020
-- Some functionality is inspired or moved
-- here from other addons, for future maintenance
-- Credit is always given above the function.
---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns	= ...
ns.Func	= {} -- add the core to the namespace
local Func = ns.Func
local DATA = ns.Data
local F_COLOR = "00CC0F00" -- red
local F_COLOR2 = "FF00FF00" -- green

Func.onLogin = {}
---------------------------------------------------
-- HELPER FUNCTIONS, local
---------------------------------------------------
local function RunOnLogin(func)
    table.insert(Func.onLogin, func)
end

local function IsInArray(array, s)
    for _, v in pairs(array) do
		if v == s then
			return true
		end
	end
	return false
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
    local color = { r=156/255, g=144/255, b=125/255 }
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_NONE")
    GameTooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -90, 90)
    local blizz = collectgarbage("count")
    local addons = {}
    local total = 0
    local nr = 0
    UpdateAddOnMemoryUsage()
    GameTooltip:AddLine("Top 50 AddOns", color.r, color.g, color.b)
    GameTooltip:AddLine(" ")
    for i=1, GetNumAddOns(), 1 do
        if GetAddOnMemoryUsage(i) > 0  then
            local memory = GetAddOnMemoryUsage(i)
            entry = {name = GetAddOnInfo(i), memory = memory}
            table.insert(addons, entry)
            total = total + memory
        end
    end
    table.sort(addons, addoncompare)
    for _, entry in pairs(addons) do
        if nr < 50 then
            GameTooltip:AddDoubleLine(entry.name, memoryformat(entry.memory), 1, 1, 1, 1, 1, 1)
            nr = nr+1
        end
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Total", memoryformat(total), color.r, color.g, color.b, color.r, color.g, color.b)
    GameTooltip:AddDoubleLine("Total incl. Blizzard", memoryformat(blizz), color.r, color.g, color.b, color.r, color.g, color.b)
    GameTooltip:Show()
    addons = nil
end

local function SetupGuildFrame()
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
end

local function IsPlayerRanged()
    local ranged = {
        ["MAGE"] = true,
        ["HUNTER"] = {["Marksmanship"]=true, ["Beast Mastery"]=true},
        ["WARLOCK"] = true,
        ["SHAMAN"] = {["Elemental"]=true,["Restoration"]=true},
        ["DRUID"] = {["Balance"]=true, ["Restoration"]=true},
        ["PRIEST"] = true,
    }

    local currentSpec = GetSpecialization()
    local _, CLASS = UnitClass("player")
    local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None"

    if not ranged[CLASS] then return false end

    if (ranged[CLASS] and ranged[CLASS] == true) or ranged[CLASS][currentSpecName] then
        return true
    end

    return false
end

local function AutoShareQuest(questID)
    if C_QuestLog.IsPushableQuest(questID) then
        local title = C_QuestLog.GetTitleForQuestID(questID)
        C_QuestLog.SetSelectedQuest(questID)
        QuestLogPushQuest();
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|c%smq|r: Attempting to share %s with your group...", F_COLOR, title));
    end
end

local function HandleQuests(self, e, ...)
    print(e)
    if e == "QUEST_ACCEPTED" then
        if IsInGroup() then
            AutoShareQuest(...)
        end
    end

    if IsShiftKeyDown() then return end

    if e == "QUEST_DETAIL" then
        if not QuestGetAutoAccept() then
            AcceptQuest()
        end

        CloseQuest()
    elseif e == "QUEST_PROGRESS" then
        if IsQuestCompletable() then
            CompleteQuest()
        end
    elseif e == "QUEST_COMPLETE" then
        if GetNumQuestChoices() == 0 then
            GetQuestReward(nil);
        elseif GetNumQuestChoices() == 1 then
            GetQuestReward(1);
        end
        -- possibly add option to brute force item value etc
        -- GetQuestReward(QuestFrameRewardPanel.itemChoice);
    end
end

local function HandleGossip(self, e, ...)
    print(e)
    if IsShiftKeyDown() then return end

    local numAvailableQuests = 0
    local numActiveQuests = 0
    local gossipOptions = C_GossipInfo.GetNumOptions()
    local gossip = true --don't gossip if handing-in/picking up

    if e == "QUEST_GREETING" then
        -- fired if NPC only has quests
        numAvailableQuests = GetNumAvailableQuests()
        numActiveQuests = GetNumActiveQuests()
    elseif e == "GOSSIP_SHOW" then
        -- fired if NPC has gossip as well as quests.
        numAvailableQuests = C_GossipInfo.GetNumAvailableQuests()
        numActiveQuests = C_GossipInfo.GetNumActiveQuests()
    end

    print("GOSSIP OPTIONS: "..gossipOptions)
    print("AVAIL QUESTS: "..numAvailableQuests)
    print("ACTIVE QUESTS: "..numActiveQuests)

    if numAvailableQuests > 0 then
        gossip = false
        for i = 1, numAvailableQuests do
            if e == "QUEST_GREETING" then
                SelectAvailableQuest(i);
            elseif e == "GOSSIP_SHOW" then
                C_GossipInfo.SelectAvailableQuest(i);
            end
        end
    end

    if numActiveQuests > 0 then
        local quests = C_GossipInfo.GetActiveQuests()
        --quests can be empty on quest greeting event.
        --getactivequests/getavailablequests returns empty table
        if #quests ~= 0 then
            for i, quest in pairs(quests) do
                if quest.isComplete then
                    gossip = false
                    if e == "QUEST_GREETING" then
                        SelectActiveQuest(i);
                    elseif e == "GOSSIP_SHOW" then
                        C_GossipInfo.SelectActiveQuest(i);
                    end
                end
            end
        else
            --fallback just select quests, cant check if complete?
            for i = 1, numActiveQuests do
                if e == "QUEST_GREETING" then
                    SelectActiveQuest(i);
                elseif e == "GOSSIP_SHOW" then
                    C_GossipInfo.SelectActiveQuest(i);
                end
            end
        end
    end

    if gossip and gossipOptions > 0 then
        local target = UnitName("target")
        if not DATA.SHADOWLANDS_GOSSIP[target] then
            print(string.format("GOSSIP: %s NOT IN TABLE.", target))
            return
        end
        local choice = DATA.SHADOWLANDS_GOSSIP[target]

        -- doesnt cover extreme obscure cases but most
        if type(choice) == "table" then
            local max = math.max(unpack(DATA.SHADOWLANDS_GOSSIP[target]))
            choice = max
            if max >= gossipOptions then choice = gossipOptions end
        end
        print("GOSSIP: PICKING CHOICE "..tostring(choice))
        C_GossipInfo.SelectOption(choice)
    end
end

local function ChatFrame_OnLeave(self)
    if not self.ShouldHide then return end

    local f = GetMouseFocus()
    if f then
        -- Ensure frame is not just higher strata than mouseover frame
		if f.messageInfo then return end
        if IsInArray(self.Frames, f) then return end

        if not f:GetName() then
            --most likely scrollbar
        elseif f:GetParent() then
            f = f:GetParent()
			if IsInArray(self.Frames, f) then
				return
			end
			if f:GetParent() then
				f = f:GetParent()
				if IsInArray(self.Frames, f) then
					return
				end
			end
		end
	end

    for _, frame in pairs(self.Frames) do
        local alpha = frame:GetAlpha()
        UIFrameFadeOut(frame, 0.5*alpha, alpha, 0)
        frame.Show = function() end --fixes boss spell icons etcc
        --frame.fadeInfo.finishedArg1 = frame
        --frame.fadeInfo.finishedFunc = frame.Hide
    end
end

local function ChatFrame_OnEnter(self)
    for _, frame in pairs(self.Frames) do
        local alpha = frame:GetAlpha()
        frame.Show = Show
        frame:Show()
        UIFrameFadeIn(frame, 0.5*(1-alpha), alpha, 1)
    end
end

local function SetupMouseoverFrames()
    local frames = {}

    for i = 1, NUM_CHAT_WINDOWS do
        local chat = Chat_GetChatFrame(i)
        if chat:IsShown() then
            local chatMouseover = CreateFrame("Frame", "moetQOL_ChatHide"..i, UIParent)
            --Increment mouseover area to cover tabs and scroll as well.
            chatMouseover:SetPoint("TOPLEFT", chat ,"TOPLEFT", 0, 25)
            chatMouseover:SetPoint("BOTTOMRIGHT", chat ,"BOTTOMRIGHT", 0, 0)
            chatMouseover.ShouldHide = false
            chatMouseover.Frames = {
                _G["ChatFrame"..i],
                _G["ChatFrame"..i.."Tab"],
                _G["ChatFrame"..i.."ButtonFrame"]
            }
            chatMouseover:SetFrameStrata("BACKGROUND")
            chatMouseover.FadeOut = function(self) ChatFrame_OnLeave(self) end
			chatMouseover.FadeIn = function(self) ChatFrame_OnEnter(self) end
            chatMouseover:SetScript("OnEnter", function(self) self:FadeIn(self) end)
            chatMouseover:SetScript("OnLeave", function(self) self:FadeOut(self) end)

            --add tabs and buttons to chatframe1 to be hidden
			if i == 1 then
				table.insert(chatMouseover.Frames, GeneralDockManager)
				table.insert(chatMouseover.Frames, GeneralDockManagerScrollFrame)
				if ChatFrameMenuButton:IsShown() then
					table.insert(chatMouseover.Frames, ChatFrameMenuButton)
                end
                if ChatFrameChannelButton:IsShown() then
                    table.insert(chatMouseover.Frames, ChatFrameChannelButton)
                end
				table.insert(chatMouseover.Frames, QuickJoinToastButton)
			end

			table.insert(frames, chatMouseover)
		end
    end

    return frames
end

---------------------------------------------------
-- MAIN FUNCTIONS
---------------------------------------------------
function Func:HidePortraitNumbers()
    PlayerHitIndicator.Show = function() end
    PetHitIndicator.Show = function() end
    CombatFeedback_OnCombatEvent = function() end
end

function Func:EnableFastLoot()
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
    lootEventFrame:Hide()
end

-- EasyDelete by Kesava
-- Moved here to maintain
-- https://github.com/kesava-wow/easydeleteconfirm
function Func:EnableEasyDelete()
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

function Func:CreateSellButton()
    local option = moetQOLDB["sell"][ns.Core.OPTION]
    local auto = option == "auto"
    local manual = option == "manual"
    if not manual and not auto then
        print(string.format("|c%ssell:|r ineligible custom option: %s", F_COLOR, option))
        print(string.format("|c%smq:|r Please see https://github.com/kanding/moetQOL/releases for possible options.", F_COLOR))
    end

    local merchantButton = CreateFrame("Button", "moetQOL_SellButton", MerchantFrame, "LFGListMagicButtonTemplate")
    merchantButton:SetPoint("BOTTOMLEFT", 87, 4)
    merchantButton:SetText("Sell Greys")
    merchantButton:SetScript("OnClick", SellGreyItems)

    merchantButton:RegisterEvent("MERCHANT_SHOW")
    merchantButton:SetScript("OnEvent", function()
        if auto then SellGreyItems() end

        if MerchantExtraCurrencyBg:IsVisible() then
            MerchantMoneyFrame:Hide()
            MerchantExtraCurrencyBg:Hide()
        else
            MerchantMoneyFrame:Show()
        end
    end)
end

function Func:HideChatButtons()
    local hiddenFrame = CreateFrame("Frame")
    hiddenFrame:Hide()

    for i=1,NUM_CHAT_WINDOWS do
        local f = _G["ChatFrame"..i.."ButtonFrame"]
        if f:IsShown() then
            f:SetParent(hiddenFrame)
        end
    end

    QuickJoinToastButton:SetParent(hiddenFrame)
    ChatFrameMenuButton:SetParent(hiddenFrame)
    ChatFrameChannelButton:SetParent(hiddenFrame)
    ChatFrameToggleVoiceDeafenButton:SetParent(hiddenFrame)
    ChatFrameToggleVoiceMuteButton:SetParent(hiddenFrame)
end

function Func:AutoCancelCutscenes()
    hooksecurefunc("MovieFrame_PlayMovie", function()
        MovieFrame:Hide()
    end)

    CinematicFrame:HookScript("OnShow", function(self, ...)
        CinematicFrame_CancelCinematic()
    end)
end

-- Inspired by rInfostring by zork
-- Moved here to rework and maintain.
-- https://github.com/zorker/rothui
function Func:CreateInfoStrings()
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

function Func:HideCommunities()
    RunOnLogin(SetupGuildFrame)
end

function Func:HideTalkingHead()
    LoadAddOn("Blizzard_TalkingHeadUI")
    hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
        TalkingHeadFrame_CloseImmediately()
    end)
end

function Func:InstantQueueMythicIsland()
    local f = CreateFrame("FRAME")
    f:RegisterEvent("ISLANDS_QUEUE_OPEN")
    f:SetScript("OnEvent", function(self, event, ...)
        if event == "ISLANDS_QUEUE_OPEN" then
            C_IslandsQueue.QueueForIsland(1737)
        end
    end)
    f:Hide()
end

function Func:SetMaxZoom()
    RunOnLogin(function() SetCVar("cameraDistanceMaxZoomFactor", 2.6) end)
end

-- Hide Error Messages inspired by zork rError (here for continued maintenance)
-- https://github.com/zorker/rothui
function Func:HideErrorMessages()
    local blacklist = {
        ["ERR_ABILITY_COOLDOWN"] = true,           -- Ability is not ready yet. (Ability)
        ["ERR_ITEM_COOLDOWN"] = true,
        ["ERR_SPELL_OUT_OF_RANGE"] = true,
        ["ERR_BADATTACKPOS"] = true,
        ["ERR_OUT_OF_ENERGY"] = true,              -- Not enough energy. (Err)
        ["ERR_OUT_OF_RANGE"] = true,
        ["ERR_OUT_OF_FURY"] = true,
        ["ERR_OUT_OF_RAGE"] = true,                -- Not enough rage.
        ["ERR_OUT_OF_FOCUS"] = true,               -- Not enough focus
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
    eventHandler:Hide()
end

-- Inspired by AutoRepair
-- Credit: https://www.curseforge.com/wow/addons/autorepair
function Func:AutoRepair()
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
-- reworked :>
-- original: https://www.curseforge.com/wow/addons/exaltedplus
function Func:ParagonTooltip()
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
function Func:RealIDCounter()
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

function Func:HideTooltipInCombat()
    local option = moetQOLDB["combattooltip"][ns.Core.OPTION]
    local always = option == "always"
    local instance = option == "instance"
    local raid = option == "raid"
    if not instance and not raid and not always then
        print(string.format("|c%scombattooltip:|r ineligible custom option: %s", F_COLOR, option))
        print(string.format("|c%smq:|r Please see https://github.com/kanding/moetQOL/releases for possible options.", F_COLOR))
    end

    --hide if player enters combat with unit as mouseover
    local f = CreateFrame("FRAME")
    f:RegisterEvent("PLAYER_REGEN_DISABLED")
    f:SetScript("OnEvent", function()
        if instance and select(2, GetInstanceInfo()) == "none" then return end
        if raid and select(2, GetInstanceInfo()) == "none" and not UnitInRaid("player") then return end

        if GameTooltip:IsShown() then
            local point, t = GameTooltip:GetPoint()
            if t and t.firstTimeLoaded and (UnitExists("mouseover") or UnitIsPlayer("mouseover")) then
                GameTooltip:Hide()
            end
        end
    end)
    f:Hide()

    -- Doesn't work if you mouseover portrait.
    -- unit/player both nil "OnShow".
    GameTooltip:SetScript("OnShow", function()
        if instance and select(2, GetInstanceInfo()) == "none" then return end
        if raid and select(2, GetInstanceInfo()) == "none" and not UnitInRaid("player") then return end

        if InCombatLockdown() then
            local _, t = GameTooltip:GetPoint()
            if t and t.firstTimeLoaded and (UnitExists("mouseover") or UnitIsPlayer("mouseover")) then
                GameTooltip:Hide()
            end
        end
    end)
end

function Func:DynamicSpellQueue()
    local function AdjustSpellQueue()
        local ranged = IsPlayerRanged()
        local rangedValue = moetQOLDB["dynamicspellqueue"][ns.Core.OPTION] or 280

        if ranged then
            SetCVar("SpellQueueWindow", rangedValue)
        else
            SetCVar("SpellQueueWindow", 125)
        end
    end

    RunOnLogin(AdjustSpellQueue)

    -- check if specialization changed
    local f = CreateFrame("FRAME")
    f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    f:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_SPECIALIZATION_CHANGED" and ... == "player" then
            AdjustSpellQueue()
        end
    end)
    f:Hide()
end

function Func:AutoQuest()
    local questFrame = CreateFrame("FRAME", "moetQOL_QuestFrame")
    questFrame:RegisterEvent("QUEST_DETAIL")
    questFrame:RegisterEvent("QUEST_PROGRESS")
    questFrame:RegisterEvent("QUEST_ACCEPTED")
    questFrame:RegisterEvent("QUEST_COMPLETE")
    questFrame:SetScript("OnEvent", HandleQuests)

    local gossipFrame = CreateFrame("FRAME", "moetQOL_GossipFrame")
    gossipFrame:RegisterEvent("GOSSIP_SHOW")
    gossipFrame:RegisterEvent("QUEST_GREETING")
    gossipFrame:SetScript("OnEvent", HandleGossip)
end

-- Inspired by Hide Chat in Combat
-- by Urtgard
-- https://www.curseforge.com/wow/addons/hcic
function Func:HideChatInCombat()
    local option = moetQOLDB["combatchat"][ns.Core.OPTION]
    local always = option == "always"
    local instance = option == "instance"
    local boss = option == "boss"
    if not always and not instance and not boss then
        print(string.format("|c%scombatchat:|r ineligible custom option: %s", F_COLOR, option))
        print(string.format("|c%smq:|r Please see https://github.com/kanding/moetQOL/releases for possible options.", F_COLOR))
    end

    local MouseoverFrames = SetupMouseoverFrames()

    -- Update ChatFrame to hide if tab changed
    hooksecurefunc("FCF_Tab_OnClick", function(self, button)
        if button ~= "LeftButton" then return end

        local chatFrame = _G["ChatFrame"..self:GetID()]
        if chatFrame.isDocked then
            -- wont cover if multiple chat frames with tabs
            moetQOL_ChatHide1.Frames[1] = chatFrame
        end
    end)

    local f = CreateFrame("FRAME")
    f:RegisterEvent("ENCOUNTER_START")
    f:RegisterEvent("ENCOUNTER_END")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:RegisterEvent("PLAYER_REGEN_DISABLED")
    f:SetScript("OnEvent", function(self, e, ...)
        if instance and select(2, GetInstanceInfo()) == "none" then return end

        if boss then
            if e == "ENCOUNTER_START" then
                for _, f in pairs(MouseoverFrames) do
                    f.ShouldHide = true
                    f:FadeOut()
                end
            elseif e == "ENCOUNTER_END" then
                -- if this doesnt fire chat stays hidden
                -- i.e hearth out etc
                for _, f in pairs(MouseoverFrames) do
                    f.ShouldHide = false
                    f:FadeIn()
                end
            end
        else
            if e == "PLAYER_REGEN_DISABLED" then
                for _, f in pairs(MouseoverFrames) do
                    f.ShouldHide = true
                    f:FadeOut()
                end
            elseif e == "PLAYER_REGEN_ENABLED" then
                for _, f in pairs(MouseoverFrames) do
                    f.ShouldHide = false
                    f:FadeIn()
                end
            end
        end
    end)
end