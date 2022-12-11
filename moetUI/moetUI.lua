local _, ns = ...
ns.ADDON_VERSION = GetAddOnMetadata("moetQOL", "Version")

--OPTIONS
local pFrame = {anchor = "CENTER", x = -310, y = -270}
local tFrame = {anchor = "CENTER", x = 310, y = -270}
local altPower = {x = -390, y = 800}
local ALPHA = 0.2
local SCALE = 0.8
local FULLSCREEN_WORLDMAP = true
--

local MICRO_BUTTONS = {
    MicroButtonAndBagsBar,
    CharacterMicroButton,
    SpellbookMicroButton,
    TalentMicroButton,
    AchievementMicroButton,
    QuestLogMicroButton,
    GuildMicroButton,
    LFDMicroButton,
    CollectionsMicroButton,
    EJMicroButton,
    StoreMicroButton,
    MainMenuMicroButton
}

local hiddenFrame = CreateFrame("FRAME")
hiddenFrame:Hide()

local function UpdatePlayerFramePosition(pFrame, tFrame)
    local anchor, _, _, x, y = PlayerFrame:GetPoint()

    if anchor ~= pFrame.anchor or x ~= pFrame.x or y ~= pFrame.y then
        PlayerFrame:ClearAllPoints()
        PlayerFrame:SetPoint(pFrame.anchor, pFrame.x, pFrame.y)
        PlayerFrame:SetUserPlaced(true);
    end

    anchor, _, relative, x, y = TargetFrame:GetPoint()

    if anchor ~= tFrame.anchor or x ~= tFrame.x or y ~= tFrame.y then
        TargetFrame:ClearAllPoints()
        TargetFrame:SetPoint(tFrame.anchor, tFrame.x, tFrame.y)
        TargetFrame:SetUserPlaced(true);
    end
end

local function UpdateAlphasAndScale()
    if FULLSCREEN_WORLDMAP then
        WorldMapFrame:SetFrameStrata("FULLSCREEN")
    end

    -- for i=1,5 do
    --    local f = "ContainerFrame"..i
    --    print(f)
    --    if f then f:SetFrameStrata("HIGH") end
    -- end
end

local function HideBlizzardFrames()
    MicroButtonAndBagsBar:Hide()

    hooksecurefunc("UpdateMicroButtons", function()
        if not MicroButtonAndBagsBar:IsShown() then
            for _, frame in pairs(MICRO_BUTTONS) do
                frame:Hide()
            end
        end
    end)
end

local function MakeDungeonFinderIconMoveable()
    QueueStatusButton:SetMovable(true);    
    QueueStatusButton:EnableMouse(true);    
    QueueStatusButton:RegisterForDrag("LeftButton");    
    QueueStatusButton:SetScript("OnDragStart", function(self) self:StartMoving() end);    
    QueueStatusButton:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end);
end

local function OnLogin()
    UpdatePlayerFramePosition(pFrame, tFrame)
    UpdateAlphasAndScale()
end


---------------------------------------------------
-- INIT
---------------------------------------------------
local function Init(self, event, name)
    if name ~= "moetUI" then return end

    local loginEvent = CreateFrame("FRAME")
    loginEvent:RegisterEvent("PLAYER_LOGIN")
    loginEvent:SetScript("OnEvent", OnLogin)
    loginEvent:Hide()

    --SetupMouseoverMicroBar()
    --SetupHideRightActionBars()
    HideBlizzardFrames()
    MakeDungeonFinderIconMoveable()
end

local addonLoadedEvents = CreateFrame("FRAME")
addonLoadedEvents:RegisterEvent("ADDON_LOADED")
addonLoadedEvents:SetScript("OnEvent", Init)
addonLoadedEvents:Hide()
