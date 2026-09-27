local _, ns = ...
ns.ADDON_VERSION = (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("moetQOL", "Version"))
    or (_G.GetAddOnMetadata and _G.GetAddOnMetadata("moetQOL", "Version")) or "unknown"
_G.moetUIDB = moetUIDB or {}

--OPTIONS
local pFrame = {anchor = "CENTER", x = -310, y = -270}
local tFrame = {anchor = "CENTER", x = 310, y = -270}
local altPower = {x = -390, y = 800}
local ALPHA = 0.2
local SCALE = 0.8
local FULLSCREEN_WORLDMAP = true

local FINDER_POS_ANCHOR = "CENTER"
local FINDER_POS_X = -70
local FINDER_POS_Y = -35
local IsLoadingBars = false

local MAX_ACTION_BAR_SLOT = 132
--

local MICRO_BUTTONS = {
    MicroButtonAndBagsBar,
    BagsBar,
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
    MainMenuMicroButton,
    ProfessionMicroButton,
    PlayerSpellsMicroButton,
    HousingMicroButton,
}

local hiddenFrame = CreateFrame("FRAME")
hiddenFrame:Hide()

local function UpdatePlayerFramePosition(pFrame, tFrame)
    if not PlayerFrame or not TargetFrame then return end
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
    if FULLSCREEN_WORLDMAP and WorldMapFrame then
        WorldMapFrame:SetFrameStrata("FULLSCREEN")
    end
end

local function HideBlizzardFrames()
    if MicroButtonAndBagsBar then MicroButtonAndBagsBar:Hide() end

    if MicroButtonAndBagsBar and UpdateMicroButtons then hooksecurefunc("UpdateMicroButtons", function()
        if not MicroButtonAndBagsBar:IsShown() then
            for _, frame in pairs(MICRO_BUTTONS) do
                if frame then frame:Hide() end
            end
        end
    end) end

    if EssencePlayerFrame then
        EssencePlayerFrame:HookScript("OnShow", function()
            if EssencePlayerFrame:IsVisible() then
                EssencePlayerFrame:Hide()
            end
        end)
    end
end

local function AnchorDungeonFinderIconToMinimap()
    if not QueueStatusButton or not Minimap or not QueueStatusButtonIcon then return false end
    QueueStatusButton:ClearAllPoints()
    QueueStatusButton:SetParent(Minimap)
    QueueStatusButton:SetMovable(true)
    QueueStatusButton:SetPoint(FINDER_POS_ANCHOR, Minimap, FINDER_POS_ANCHOR, FINDER_POS_X, FINDER_POS_Y)
    QueueStatusButton:SetUserPlaced(true)
    QueueStatusButtonIcon:SetScale(0.8)
    return true
end

local function OnLogin()
    if AnchorDungeonFinderIconToMinimap() then
        hooksecurefunc(QueueStatusButton, "SetPoint", function(self, point, relativeTo, relativePoint, xOfs, yOfs)
            if relativeTo == Minimap and xOfs == FINDER_POS_X and yOfs == FINDER_POS_Y then
                return -- Allow setting to the desired position
            end
            AnchorDungeonFinderIconToMinimap() -- Reapply the desired position
        end)
    end

    UpdatePlayerFramePosition(pFrame, tFrame)
    UpdateAlphasAndScale()
    HideBlizzardFrames()
    --DurabilityFrame update position
end

local function DumpAllMacros()
    -- Print header
    print("Dumping all macros:")

    -- Iterate through general (account-wide) macros
    for i = 1, MAX_ACCOUNT_MACROS do
        local macroName = GetMacroInfo(i)
        if macroName then
            print("General Macro:", i, "-", macroName)
        end
    end

    -- Iterate through character-specific macros
    for i = (MAX_ACCOUNT_MACROS + 1), (MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS) do
        local macroName = GetMacroInfo(i)
        if macroName then
            print("Character-Specific Macro:", i, "-", macroName)
        end
    end

    print("Macro dump complete.")
end

local function GetClassSpecKey()
    local _, class = UnitClass("player")
    local specIndex = GetSpecialization and GetSpecialization()
    local specName = specIndex and GetSpecializationInfo
        and select(2, GetSpecializationInfo(specIndex)) or "NoSpec"
    return class .. "_" .. specName  -- Return a unique key (e.g., "WARRIOR_Arms")
end

local function GetMountDisplayIndexByID(mountID)
    for i = 1, C_MountJournal.GetNumDisplayedMounts() do
        local displayedMountID = select(12, C_MountJournal.GetDisplayedMountInfo(i))
        if displayedMountID == mountID then
            return i  -- Return the display index
        end
    end
    return nil  -- Return nil if the mountID is not found
end

local function SaveProfile()
    local profile = {}
    for slot = 1, MAX_ACTION_BAR_SLOT do
        local type, id, subType = GetActionInfo(slot)
        if type then
            if type == "macro" then
                local macroName = GetActionText(slot)
                profile[slot] = {type = type, name = macroName, isCharacterSpecific = id > MAX_ACCOUNT_MACROS}
            else
                profile[slot] = {type = type, id = id, subType = subType}
            end
        else
            profile[slot] = {type = "empty"}
        end
    end

    local key = GetClassSpecKey()
    moetUIDB[key] = profile
    print("Saved action bar profile to "..key)
end

local function LoadProfile()
    local key = GetClassSpecKey()
    local profile = moetUIDB[key]
    if not profile then 
        print("No action bar profile was saved to "..key)
        print("Use /mui save on a character with that class and specialization to save one.")
        return
    end

    local function ApplyActions(slot)
        local action = profile[slot]
        if action then
            if action.type == "spell" then
                if C_Spell and C_Spell.PickupSpell then
                    C_Spell.PickupSpell(action.id)
                elseif PickupSpell then
                    PickupSpell(action.id)
                else
                    print("Spell actions are not supported by this game client.")
                    return
                end
                PlaceAction(slot)
            elseif action.type == "macro" then
                local macroIndex = GetMacroIndexByName(action.name)
                if macroIndex then
                    PickupMacro(macroIndex)
                    PlaceAction(slot)
                else
                    print("Macro '"..action.name.."' not found. Was it deleted or renamed since save or is it char specific?")
                end
            elseif action.type == "item" then
                if C_Item and C_Item.PickupItem then
                    C_Item.PickupItem(action.id)
                elseif PickupItem then
                    PickupItem(action.id)
                else
                    print("Item actions are not supported by this game client.")
                    return
                end
                PlaceAction(slot)
            elseif action.type == "companion" then
                if action.subType == "MOUNT" then
                    PickupCompanion(action.subType, action.id)
                else
                    C_PetJournal.PickupPet(action.id)
                end

                PlaceAction(slot)
            elseif action.type == "summonmount" then
                local displayIndex = GetMountDisplayIndexByID(action.id)
                if displayIndex then
                    C_MountJournal.Pickup(displayIndex)
                    PlaceAction(slot)
                else
                    print("Mount with ID "..action.id.." not found in the Mount Journal.")
                end
            elseif action.type == "empty" then
                -- Clear the slot if it was saved as empty
                PickupAction(slot)
                ClearCursor()
            end
        end
    end

    -- Apply actions with possibility of delays
    local function LoadNextSlot(slot)
        if slot <= MAX_ACTION_BAR_SLOT then
            ApplyActions(slot)
            LoadNextSlot(slot + 1)
        else
            print("Loaded action bar profile "..key)
            IsLoadingBars = false
        end
    end

    --Start from first slot
    if IsLoadingBars then
        print("Load already in progress.")
        return
    end
    
    print("Loading action bar profile "..key.."...")
    IsLoadingBars = true
    LoadNextSlot(1)
end

local function DumpProfile()
    local key = GetClassSpecKey()
    local profile = moetUIDB[key]
    if not profile then 
        print("No action bar profile was saved to "..key)
        print("Use /mui save on a character with that class and specialization to save one.")
        return
    end

    for slot = 1, MAX_ACTION_BAR_SLOT do
        local action = profile[slot]
        if action then
            if action.type == "item" then
                print("Slot "..slot..": Item: "..action.id)
            elseif action.type == "spell" then
                print("Slot "..slot..": Spell: "..action.id)
            elseif action.type == "macro" then
                print("Slot "..slot..": Macro: "..action.name)
            elseif action.type == "companion" then
                print("Slot "..slot..": Companion: "..action.id)
            elseif action.type == "empty" then
                print("Slot "..slot..": Empty.")
            end
        end
    end
end

local function DumpCurrent()
    for slot = 1, MAX_ACTION_BAR_SLOT do
        local type, id, subType = GetActionInfo(slot)
        if type then
            if type == "spell" then
                local spellInfo = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(id)
                if not spellInfo and GetSpellInfo then
                    local spellName = GetSpellInfo(id)
                    if spellName then spellInfo = { name = spellName } end
                end
                if spellInfo then
                    print("Slot "..slot..": "..spellInfo.name.." - "..id)
                else
                    print("Unable to fetch spell from id "..id.." on slot "..slot)
                end
            elseif type == "macro" then
                local macroName = GetActionText(slot)
                print("Slot "..slot..": "..macroName.." - "..id)
            elseif type == "item" then
                local itemName = C_Item and C_Item.GetItemInfo and C_Item.GetItemInfo(id)
                if not itemName and GetItemInfo then itemName = GetItemInfo(id) end
                print("Slot "..slot..": "..itemName.." - "..id)
            elseif type == "summonmount" then
                local mountInfo = C_MountJournal.GetMountInfoByID(id)
                if mountInfo then
                    print("Slot "..slot..": "..mountInfo.." - "..id)
                else
                    print("Unable to fetch mount from id "..id.." on slot "..slot)
                end
            else
                if subType then
                    print("Slot "..slot..": "..type.." - "..id.." - "..subType)
                else
                    print("Slot "..slot..": "..type.." - "..id)
                end
            end
        else
            print("Slot "..slot..": Empty")
        end
    end
end

local function ClearActionBars()
    for slot = 1, MAX_ACTION_BAR_SLOT do
        PickupAction(slot)
        ClearCursor()
    end
end

local function HandleSlashCommands(str)
    if not str then return end
    
    str = string.lower(str)

    if str == "save" then
        SaveProfile()
        return
    end

    if str == "load" then
        LoadProfile()
        return
    end

    if str == "dump" then
        DumpProfile()
        return
    end

    if str == "cur" then
        DumpCurrent()
        return
    end

    if str == "clear" then
        ClearActionBars()
        return
    end
end

---------------------------------------------------
-- INIT
---------------------------------------------------
local function Init(self, event, name)
    if name ~= "moetUI" then return end

    -- Slash cmd
    SLASH_MOETUI1 = "/mui"
    SlashCmdList.MOETUI = HandleSlashCommands

    local loginEvent = CreateFrame("FRAME")
    loginEvent:RegisterEvent("PLAYER_LOGIN")
    loginEvent:SetScript("OnEvent", OnLogin)
    loginEvent:Hide()
end

local addonLoadedEvents = CreateFrame("FRAME")
addonLoadedEvents:RegisterEvent("ADDON_LOADED")
addonLoadedEvents:SetScript("OnEvent", Init)
addonLoadedEvents:Hide()
