local _, ns = ...
ns.ADDON_VERSION = GetAddOnMetadata("moetQOL", "Version")

--OPTIONS
local pFrame = {anchor = "CENTER", x = -370, y = -238}
local tFrame = {anchor = "CENTER", x = 370, y = -238}
local altPower = {x = -390, y = 800}
local ALPHA = 0.2
local SCALE = 0.95
local FULLSCREEN_WORLDMAP = true
--


local hiddenFrame = CreateFrame("FRAME")
hiddenFrame:Hide()

local MICRO_BUTTONS = {
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
    MainMenuMicroButto,
}

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
    UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomLeft"].baseY = 5
    --UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomRight"].xOffset = 4
    MultiBarBottomRightButton7:ClearAllPoints()
    MultiBarBottomRightButton7:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton1, "TOPLEFT", 0, 5)
end

local function MoveAlternatePowerBar()
    -- UI Parent manage position
    UIPARENT_ALTERNATE_FRAME_POSITIONS["PlayerPowerBarAlt_Bottom"] = {baseY = false, yOffset = altPower.y, xOffset = altPower.x};

    --keep status text shown
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
    if MicroButtonAndBagsBar:IsShown() then
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

    SetupMouseoverMicroBar()
    HideBlizzardFrames()
end

local addonLoadedEvents = CreateFrame("FRAME")
addonLoadedEvents:RegisterEvent("ADDON_LOADED")
addonLoadedEvents:SetScript("OnEvent", Init)
addonLoadedEvents:Hide()
