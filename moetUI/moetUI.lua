local _, ns = ...
ns.ADDON_VERSION = GetAddOnMetadata("moetQOL", "Version")

--OPTIONS
local pFrame = {anchor = "CENTER", x = -370, y = -238}
local tFrame = {anchor = "CENTER", x = 370, y = -238}
local ALPHA = 0.2




local hiddenFrame = CreateFrame("FRAME")
hiddenFrame:Hide()

local MICRO_BUTTONS = {
    "CharacterMicroButton",
    "SpellbookMicroButton",
    "TalentMicroButton",
    "AchievementMicroButton",
    "QuestLogMicroButton",
    "GuildMicroButton",
    "LFDMicroButton",
    "CollectionsMicroButton",
    "EJMicroButton",
    "StoreMicroButton",
    "MainMenuMicroButton"
}

local function UpdatePlayerFramePosition(pFrame, tFrame)
	local anchor, _, _, x, y = PlayerFrame:GetPoint()

	if anchor ~= pFrame.anchor or x ~= pFrame.x or y ~= pFrame.y then
		PlayerFrame:ClearAllPoints()
		PlayerFrame:SetPoint("CENTER", -370, -238)
		PlayerFrame:SetUserPlaced(true);
	end

	anchor, _, relative, x, y = TargetFrame:GetPoint()

	if anchor ~= tFrame.anchor or x ~= tFrame.x or y ~= tFrame.y then
		TargetFrame:ClearAllPoints()
		TargetFrame:SetPoint("CENTER", 370, -238)
		TargetFrame:SetUserPlaced(true);
	end
end

local function HideBlizzardFrames()

	--[[local toggleFrame = CreateFrame("FRAME")
	toggleFrame:SetAllPoints("MultiBarLeft")
	toggleFrame:SetFrameStrata("HIGH")
	toggleFrame:HookScript("OnEnter", function() MultiBarLeft:SetAlpha(1.0) end)
	toggleFrame:HookScript("OnLeave", function() MultiBarLeft:SetAlpha(ALPHA) end)
	toggleFrame:Show()--]]

	for _,v in pairs(MICRO_BUTTONS) do
		_G[v]:SetAlpha(ALPHA)
	end

	CastingBarFrame.Border:SetParent(hiddenFrame)
	CastingBarFrame.Flash:SetParent(hiddenFrame)
	TargetFrameSpellBar.Border:SetParent(hiddenFrame)
	TargetFrameSpellBar.Flash:SetParent(hiddenFrame)
	MirrorTimer1Border:SetParent(hiddenFrame)
	MicroButtonAndBagsBar:Hide()

	WorldMapFrame:SetFrameStrata("FULLSCREEN")
	MultiBarLeft:SetAlpha(ALPHA)
	MultiBarRight:SetAlpha(ALPHA)
end



---------------------------------------------------
-- INIT
---------------------------------------------------
local function Init(self, event, name)
	if name ~= "moetUI" then return end

	HideBlizzardFrames()
    UpdatePlayerFramePosition(pFrame, tFrame)
end

local addonLoadedEvents = CreateFrame("FRAME")
addonLoadedEvents:RegisterEvent("ADDON_LOADED")
addonLoadedEvents:SetScript("OnEvent", Init)
addonLoadedEvents:Hide()
