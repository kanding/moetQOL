-- moet, 2020
-- Some functionality is inspired or moved
-- here from other addons, for future maintenance
-- Credit is always given above the function.
---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns	= ...
ns.Func	= {} -- add the core to the namespace
ns.REDCOLOR = "00CC0F00"
ns.GREENCOLOR = "FF00FF00"

local Func = ns.Func
local DATA = ns.Data

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
--[[
local function VerifyCustomOption(key)
    if not Core.MQdefault[key] then
        ns.Core:PrintMessage("Failed to verify custom option for non-existing key: "..key)
        return false
    end

    local current_option = moetQOLDB[key].custom
    if not current_option then
        ns.Core:PrintMessage("Failed to verify custom option with no current option for: "..key)
        return false
    end

    local available_options = Core.MQdefault[key].custom

    if available_options.min and available_options.max then
        --numerical custom option
        current_option = tonumber(current_option)
        if not current_option then return false end
        if current_option >= available_options.min and current_option <= available_options.max then
            return true
        end
    else
        --choice custom option
        for i=1,#available_options do
            if available_options[i] == current_option then return true end
        end
    end

    ns.Core:PrintMessage(string.format("|c%s%s:|r unable to verify custom option: %s", ns.REDCOLOR, key, tostring(current_option)))
    return false
end
--]]

--NOTE: this only sells 12 items at a time, rest will say object is busy.
local function SellGreyItems()
    if not MerchantFrame:IsVisible() then return end

    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemLink(bag, slot)
            if item ~= nil then
                local grey = string.find(item, "|cff9d9d9d") -- grey
                if grey then
                    local sellPrice = (select(11, GetItemInfo(item)) or 0)
                    --local itemCount = (select(2, C_Container.GetContainerItemInfo(bag, slot)) or 0)
                    currPrice = sellPrice
                    if currPrice > 0 then
                        C_Container.PickupContainerItem(bag, slot)
                        PickupMerchantItem()
                    end
                end
            end
        end
    end
end

local function GetFps()
    return floor(GetFramerate()) .. "fps"
end

local function GetMs()
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
        hooksecurefunc("ShowUIPanel", function(frame, force, duplicated)
            if frame and not frame:GetName() == "GuildFrame" then return end

            if frame and not frame:IsShown() and not duplicated and InCombatLockdown() and not WorldMapFrame:IsShown() then
                local point,_,relativePoint,xOff,yOff = frame:GetPoint()
                frame:ClearAllPoints()
                frame:SetPoint(point or "TOPLEFT",UIParent,relativePoint or "TOPLEFT",xOff or 16,yOff or -116)
                frame:Show()
            end
        end)

        hooksecurefunc("HideUIPanel", function(frame, force, duplicated)
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
        ["EVOKER"] = true,
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
        DEFAULT_CHAT_FRAME:AddMessage(string.format("|c%smq|r: Sharing [%s] with your group...", ns.REDCOLOR, title), 255, 255, 0);
    end
end

local function GetGreedyRewardIndex()
    local index = 1 --guard
    local money = 0

    for i=1, GetNumQuestChoices() do
        local link = GetQuestItemLink("choice", i)
        if link then
            local m = select(11, GetItemInfo(link))
            if m > money then
                money = m
                index = i
            end
        end
    end

    return index
end

local function HandleQuests(self, e, ...)
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
            GetQuestReward(nil)
        elseif GetNumQuestChoices() == 1 then
            GetQuestReward(1)
        elseif GetNumQuestChoices() > 1 then
            local force = moetQOLDB["autoquest"].custom == "force"
            if not force then return end

            --GetQuestReward(GetGreedyRewardIndex())
            GetQuestReward(1)
        end
    end
end

local function HandleGossip(self, e, ...)
    if IsShiftKeyDown() then return end

    local numAvailableQuests = 0
    local numActiveQuests = 0
    local gossipOptions = C_GossipInfo.GetOptions()
    local numGossipOptions = #gossipOptions
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
                        C_GossipInfo.SelectActiveQuest(quest.questID);
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

    if gossip and numGossipOptions > 0 then
        local target = UnitName("target") or GameTooltipTextLeft1:GetText()
        local player_level = UnitLevel("player")
        local gossip_data = nil

        if (player_level >= DATA.SHADOWLANDS_GOSSIP.MinLevel and player_level <= DATA.SHADOWLANDS_GOSSIP.MaxLevel) then
            gossip_data = DATA.SHADOWLANDS_GOSSIP[target]
        end

        if (player_level >= DATA.DRAGONLANDS_GOSSIP.MinLevel and player_level <= DATA.DRAGONLANDS_GOSSIP.MaxLevel) then
            gossip_data = DATA.DRAGONLANDS_GOSSIP[target]
        end

        if gossip_data == nil then return end
        local choice = gossip_data.choice
        
        -- doesnt cover extreme obscure cases but most
        if type(choice) == "table" then
            local max = math.max(unpack(DATA.SHADOWLANDS_GOSSIP[target]))
            choice = max
            if choice >= numGossipOptions then choice = numGossipOptions end
        end
        
        local gossipTable = gossipOptions[choice] or nil
        local c = gossipTable.gossipOptionID or nil

        if c ~= nil and choice <= numGossipOptions then
            C_GossipInfo.SelectOption(c)
        end
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
        --fixes boss spell icons etc
        frame.Show = function() end
        frame.fadeInfo.finishedArg1 = frame
        frame.fadeInfo.finishedFunc = frame.Hide
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

local function AdjustSpellQueue()
    local ranged = IsPlayerRanged()
    local rangedValue = moetQOLDB["dynamicspellqueue"].custom or 280

    if ranged then
        SetCVar("SpellQueueWindow", rangedValue)
    else
        SetCVar("SpellQueueWindow", 125)
    end
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

            local link = select(3, GetCursorInfo())

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
    --if not VerifyCustomOption("sell") then return end
    local option = moetQOLDB["sell"].custom
    local auto = option == "auto"
    local manual = option == "manual"

    local merchantButton = CreateFrame("Button", "moetQOL_SellButton", MerchantFrame, "LFGListMagicButtonTemplate")
    merchantButton:SetPoint("BOTTOMLEFT", 87, 4)
    merchantButton:SetText("Sell Greys")
    merchantButton:SetScript("OnClick", SellGreyItems)

    MerchantFrame:HookScript("OnShow", function()
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
    frameFontString:SetText(GetFps() .. "  " .. GetMs())
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
        frameFontString:SetText(GetFps() .. " " .. GetMs())
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
    hooksecurefunc(TalkingHeadFrame, "PlayCurrent", function(self)
        self:Hide()
        local option = moetQOLDB["talkinghead"].custom
        local should_mute = option == "muteaudio"
        if should_mute then C_TalkingHead.IgnoreCurrentTalkingHead() end
    end)
end

function Func:SetMaxZoom()
    RunOnLogin(function() SetCVar("cameraDistanceMaxZoomFactor", 2.6) end)
end

-- Hide Error Messages inspired by zork rError (here for continued maintenance)
-- https://github.com/zorker/rothui
function Func:HideErrorMessages()
    UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")

    local function OnUIErrorMessage(self, event, messageType, message)
        local errorName, soundKitID, voiceID = GetGameMessageInfo(messageType)

        if DATA.ERROR_BLACKLIST[errorName] then return end
        UIErrorsFrame:AddMessage(message, 1, .1, .1)
    end

    local eventHandler = CreateFrame("FRAME")
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
                DEFAULT_CHAT_FRAME:AddMessage(
                    "Your items have been repaired for "..GetCoinText(repairAllCost,", ")..".", 255, 255, 0
                )
            end
        end
    end)
end

-- Inspired by ExaltedPlus
-- reworked :-)
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

        GameTooltip:AddLine(line)
        GameTooltip:Show()
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
    --if not VerifyCustomOption("combattooltip") then return end
    local option = moetQOLDB["combattooltip"].custom
    local always = option == "always"
    local instance = option == "instance"
    local raid = option == "raid"

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
    --if not VerifyCustomOption("autoquest") then return end
    local option = moetQOLDB["autoquest"].custom
    local noforce = option == "noforce"
    local force = option == "force"

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
    --if not VerifyCustomOption("combatchat") then return end
    local option = moetQOLDB["combatchat"].custom
    local always = option == "always"
    local instance = option == "instance"
    local boss = option == "boss"

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
    f:RegisterEvent("PLAYER_ENTERING_WORLD") -- If we zone out always show chat
    f:SetScript("OnEvent", function(self, e, ...)
        if e == "PLAYER_ENTERING_WORLD" then
            for _, f in pairs(MouseoverFrames) do
                f.ShouldHide = false
                f:FadeIn()
            end
        end

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

function Func:QuestItemBind()
    local buttonFrame = CreateFrame("FRAME", "moetQOL_QuestItemButton")
    buttonFrame:Hide()
    buttonFrame.lastItem = ""
    buttonFrame.lastQuest = 0
    buttonFrame.lastDist = 0
    buttonFrame.CheckAfter = false;

    buttonFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    buttonFrame:SetScript("OnEvent", function(self, e)
        if not self.CheckAfter then return end
        self.CheckAfter = false

        if e == "PLAYER_REGEN_ENABLED" and self.lastItem ~= "" then
            ClearOverrideBindings(self)
            SetOverrideBindingItem(self, false, GetBindingKey("USEMOSTRECENTQUESTITEM"), self.lastItem)
            DEFAULT_CHAT_FRAME:AddMessage(
                string.format("|c%smq:|r Created temporary keybind %s to use %s.", ns.REDCOLOR, GetBindingKey("USEMOSTRECENTQUESTITEM"), self.lastLink), 255, 255, 0
            )
        end
    end)

    hooksecurefunc("QuestObjectiveItem_Initialize", function(itemButton, questLogIndex)
        local questID = C_QuestLog.GetQuestIDForLogIndex(questLogIndex)
        local distanceSq, onContinent = C_QuestLog.GetDistanceSqToQuest(questID)

        -- UPDATE DISTANCE IF SAME QUEST
        if buttonFrame.lastQuest and buttonFrame.lastQuest == questID then
            buttonFrame.lastDist = distanceSq
            return
        end

        -- GET NEW ITEM TO USE
        local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
        local itemName = GetItemInfo(link)

        -- If last quest is valid and closer than the new quest then don't change.
        if buttonFrame.lastQuest then
            if C_QuestLog.IsOnQuest(buttonFrame.lastQuest) then
                if not onContinent then return end
                -- Add 20000 as a safety in case two quests are on top of each other.
                if C_QuestLog.ReadyForTurnIn(buttonFrame.lastQuest) and C_QuestLog.ReadyForTurnIn(questID) then return end
                if not C_QuestLog.ReadyForTurnIn(buttonFrame.lastQuest) then
                    if buttonFrame.lastDist and distanceSq and buttonFrame.lastDist < distanceSq + 20000 then return end
                end
            end
        end

        -- UPDATE QUEST TO KEYBIND
        buttonFrame.lastItem = itemName
        buttonFrame.lastQuest = questID
        buttonFrame.lastDist = distanceSq
        buttonFrame.lastLink = link

        -- CREATE A TEMPORARY KEYBIND
        local keybind = GetBindingKey("USEMOSTRECENTQUESTITEM")
        if not keybind then
            print(string.format("|c%smq:|r Attempted to create Keybind to use %s, but none is set! Set bind to use in Key Bindings/AddOns!", ns.REDCOLOR, link))
            return
        end

        if InCombatLockdown() then
            DEFAULT_CHAT_FRAME:AddMessage(
                string.format("|c%smq:|r Unable to set keybind for %s while |cffff0000in combat|r. Trying again after.. ", ns.REDCOLOR, link), 255, 255, 0
            )
            buttonFrame.CheckAfter = true
        else
            ClearOverrideBindings(buttonFrame)
            SetOverrideBindingItem(buttonFrame, false, keybind, itemName)
            DEFAULT_CHAT_FRAME:AddMessage(
                string.format("|c%smq:|r Created temporary keybind %s to use %s.", ns.REDCOLOR, GetBindingKey("USEMOSTRECENTQUESTITEM"), link), 255, 255, 0
            )
        end
    end)
end

function Func:DisableMinimapTracking()
    local TARGET_TRACKING_ID = 20
    local option = moetQOLDB["minimaptracking"].custom
    if option == "all" then
        RunOnLogin(function()
            for i=1,C_Minimap.GetNumTrackingTypes() do
                C_Minimap.SetTracking(i, false)
            end
        end)
    end
    
    RunOnLogin(function() C_Minimap.SetTracking(TARGET_TRACKING_ID, false) end)
end