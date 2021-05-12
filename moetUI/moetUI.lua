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
end

local function ModifyActionBar()
    --taint
    UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomLeft"].baseY = 5
    --UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomRight"].xOffset = 4
    --MultiBarBottomLeft:ClearAllPoints()
    --MultiBarBottomLeft:SetPoint("TOP", MainMenuBarArtFrame, "TOP", 0, 16) -- default anchor
    --[[
    MultiBarBottomLeft:HookScript("OnUpdate", function()
        if not InCombatLockdown() then
            MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, 5)
        end
    end)]]
    MultiBarBottomRightButton7:ClearAllPoints()
    MultiBarBottomRightButton7:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton1, "TOPLEFT", 0, 5)
end

local function MoveAlternatePowerBar()
    -- UI Parent manage position
    -- taint?
    UIPARENT_ALTERNATE_FRAME_POSITIONS["PlayerPowerBarAlt_Bottom"] = {baseY = false, yOffset = altPower.y, xOffset = altPower.x};

    --keep status text shown
    --[[
    hooksecurefunc("UnitPowerBarAlt_OnEvent", function(self, event, ...)
        if self.statusFrame and self.statusFrame:IsShown() or MouseIsOver(self) then return end

        local arg1, arg2 = ...

        if event == "UNIT_POWER_UPDATE" then
            if arg1 == self.unit and arg2 == "ALTERNATE" then
                self.statusFrame:Show()
            end
        end
    end)

    hooksecurefunc("UnitPowerBarAlt_OnEnter", function(self)
        if self.displayedValue and self.displayedValue > 0 then
            self.statusFrame:Hide()
        end
    end)

    hooksecurefunc("UnitPowerBarAlt_OnLeave", function(self)
        if self.displayedValue and self.displayedValue > 0 then
            self.statusFrame:Show()
        end
    end)
    ]]
end

local function MicroFrame_OnLeave(self)
    local f = GetMouseFocus()
    -- we are on the same strata to prevent absorbing clicks
    -- so check if we are leaving mouseover frame into microbutton or bags
    if f.GetBagID or f.OnEnter then return end

    if self.HideFrame then
        for _, frame in pairs(self.HideFrame) do
            local alpha = frame:GetAlpha()
            UIFrameFadeOut(frame, 0.5 * alpha, alpha, 0)
        end
    end
end

local function MicroFrame_OnEnter(self)
    if self.HideFrame then
        for _, frame in pairs(self.HideFrame) do
            local alpha = frame:GetAlpha()
            UIFrameFadeIn(frame, 0.5 * (1 - alpha), alpha, 1)
        end
    end
end

local function SetupMouseoverMicroBar()
    if not MicroButtonAndBagsBar:IsShown() then return end

    local mouseoverFrame = CreateFrame("Frame", "moetUI_MicroHide", UIParent)
    mouseoverFrame:SetPoint("TOPLEFT", MicroButtonAndBagsBar, "TOPLEFT", 0, 0)
    mouseoverFrame:SetPoint("BOTTOMRIGHT", MicroButtonAndBagsBar, "BOTTOMRIGHT", 0, 0)
    mouseoverFrame:SetFrameStrata("MEDIUM")

    mouseoverFrame.HideFrame = {
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

    mouseoverFrame.FadeOut = function(self) MicroFrame_OnLeave(self) end
    mouseoverFrame.FadeIn = function(self) MicroFrame_OnEnter(self) end
    mouseoverFrame:SetScript("OnEnter", function(self) self:FadeIn(self) end)
    mouseoverFrame:SetScript("OnLeave", function(self) self:FadeOut(self) end)

    for _, frame in pairs(mouseoverFrame.HideFrame) do
        frame:Hide()
    end

    -- for some reason StoreMicroButton is the only button with a show in update
    -- so we have hook to ensure it stays hidden.
    hooksecurefunc("UpdateMicroButtons", function()
        if not MicroButtonAndBagsBar:IsShown() then
            StoreMicroButton:Hide()
        end
    end)
end

local function MultiBar_OnEnter(self)
    local Lalpha = self.LeftBar:GetAlpha()
    local Ralpha = self.RightBar:GetAlpha()

    for i=1,12 do
        local fl = "MultiBarLeftButton"..i
        local fr = "MultiBarRightButton"..i
        fl:Show()
        fr:Show()
    end

    UIFrameFadeIn(self.LeftBar, 0.5 * (1 - Lalpha), Lalpha, 1)
    UIFrameFadeIn(self.RightBar, 0.5 * (1 - Ralpha), Ralpha, 1)
end

local function MultiBar_OnLeave(self)
    local Lalpha = self.LeftBar:GetAlpha()
    local Ralpha = self.RightBar:GetAlpha()

    for i=1,12 do
        local fl = "MultiBarLeftButton"..i
        local fr = "MultiBarRightButton"..i
        fl:Hide()
        fr:Hide()
    end

    UIFrameFadeOut(self.LeftBar, 0.5 * Lalpha, Lalpha, 0)
    UIFrameFadeOut(self.RightBar, 0.5 * Ralpha, Ralpha, 0)
end

local function SetupHideRightActionBars()
    --if not MultiBarLeft:IsShown() and not MultiBarRight:IsShown() then return end

    local mouseoverFrame = CreateFrame("Frame", "moetUI_MultiBarHide", UIParent)
    -- Problem if only 1 of them is shown.
    mouseoverFrame:SetPoint("TOPLEFT", MultiBarLeft, "TOPLEFT", 0, 0)
    mouseoverFrame:SetPoint("BOTTOMRIGHT", MultiBarRight, "BOTTOMRIGHT", 0, 0)
    mouseoverFrame:SetFrameStrata("HIGH")

    mouseoverFrame.LeftBar = MultiBarLeft
    mouseoverFrame.RightBar = MultiBarRight

    mouseoverFrame.FadeOut = function(self) MultiBar_OnLeave(self) end
    mouseoverFrame.FadeIn = function(self) MultiBar_OnEnter(self) end
    mouseoverFrame:SetScript("OnEnter", function(self) self:FadeIn(self) end)
    mouseoverFrame:SetScript("OnLeave", function(self) self:FadeOut(self) end)
    
    MultiBarLeft:Hide();
    MultiBarRight:Hide();
end

local function HideBlizzardFrames()
    CastingBarFrame.Border:SetParent(hiddenFrame)
    CastingBarFrame.Flash:SetParent(hiddenFrame)
    PetCastingBarFrame.Border:SetParent(hiddenFrame)
    PetCastingBarFrame.Flash:SetParent(hiddenFrame)
    TargetFrameSpellBar.Border:SetParent(hiddenFrame)
    TargetFrameSpellBar.Flash:SetParent(hiddenFrame)
    MirrorTimer1Border:SetParent(hiddenFrame)
    MainMenuBarArtFrame.LeftEndCap:SetParent(hiddenFrame)
    MainMenuBarArtFrame.RightEndCap:SetParent(hiddenFrame)
    MainMenuBarArtFrameBackground:Hide()
    RegisterStateDriver(StanceBarFrame, 'visibility', 'hide') -- hide stance bar
    MicroButtonAndBagsBar:Hide()

    VERTICAL_MULTI_BAR_HEIGHT = 800;

    MultiBarRight:HookScript('OnUpdate', function()
        if not InCombatLockdown() and MultiBarRight:GetScale() ~= SCALE then
            MultiBarRight:SetScale(SCALE)
        end
    end)

    MultiBarLeft:HookScript('OnUpdate', function()
        if not InCombatLockdown() and MultiBarLeft:GetScale() ~= SCALE then
            MultiBarLeft:SetScale(SCALE)
        end
    end)

    hooksecurefunc("UpdateMicroButtons", function()
        if not MicroButtonAndBagsBar:IsShown() then
            for _, frame in pairs(MICRO_BUTTONS) do
                frame:Hide()
            end
        end
    end)
end

local function OnLogin()
    UpdatePlayerFramePosition(pFrame, tFrame)
    UpdateAlphasAndScale()
    MoveAlternatePowerBar()
    ModifyActionBar()
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
end

local addonLoadedEvents = CreateFrame("FRAME")
addonLoadedEvents:RegisterEvent("ADDON_LOADED")
addonLoadedEvents:SetScript("OnEvent", Init)
addonLoadedEvents:Hide()
