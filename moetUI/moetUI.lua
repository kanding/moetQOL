local _, ns = ...
ns.ADDON_VERSION = C_AddOns.GetAddOnMetadata("moetQOL", "Version")
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

local function HideBlizzardFrames()
    MicroButtonAndBagsBar:Hide()

    hooksecurefunc("UpdateMicroButtons", function()
        if not MicroButtonAndBagsBar:IsShown() then
            for _, frame in pairs(MICRO_BUTTONS) do
                frame:Hide()
            end
        end
    end)

    EssencePlayerFrame:HookScript("OnShow", function()
        if EssencePlayerFrame:IsVisible() then
          EssencePlayerFrame:Hide()
        end
    end)
end

local function AnchorDungeonFinderIconToMinimap()
    QueueStatusButton:ClearAllPoints()
    QueueStatusButton:SetParent(Minimap)
    QueueStatusButton:SetMovable(true)
    QueueStatusButton:SetPoint(FINDER_POS_ANCHOR, Minimap, FINDER_POS_ANCHOR, FINDER_POS_X, FINDER_POS_Y)
    QueueStatusButton:SetUserPlaced(true)
    QueueStatusButtonIcon:SetScale(0.8)
    
end

local function OnLogin()
    AnchorDungeonFinderIconToMinimap()
    hooksecurefunc(QueueStatusButton, "SetPoint", function(self, point, relativeTo, relativePoint, xOfs, yOfs)
        if relativeTo == Minimap and xOfs == FINDER_POS_X and yOfs == FINDER_POS_Y then
            return -- Allow setting to the desired position
        end
        AnchorDungeonFinderIconToMinimap() -- Reapply the desired position
    end)
    
    UpdatePlayerFramePosition(pFrame, tFrame)
    UpdateAlphasAndScale()
    HideBlizzardFrames()
end

-- Helper function to find a macro index by its name
    --[[
local function GetMacroIndexByName(macroName, isCharacterSpecific)
    if isCharacterSpecific then
        for i = (MAX_ACCOUNT_MACROS + 1), (MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS) do
            if GetMacroInfo(i) == macroName then
                return i
            end
        end
    else
        for i = 1, MAX_ACCOUNT_MACROS do
            if GetMacroInfo(i) == macroName then
                return i
            end
        end
    end
    return nil
end
--]]
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
    local specIndex = GetSpecialization()
    local specName = specIndex and select(2, GetSpecializationInfo(specIndex)) or "NoSpec"
    return class .. "_" .. specName  -- Return a unique key (e.g., "WARRIOR_Arms")
end

local function TryFindMacroBySpell(id)
    -- Attempt to check if the spell is from a macro by iterating over all macros
    for i = 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
        local macroSpellId = GetMacroSpell(i)
        if macroSpellId and macroSpellId == id then
            local macroName = GetMacroInfo(i)
            return macroName, i > MAX_ACCOUNT_MACROS
        end
    end

    return nil
end

local function SaveProfile()
    local profile = {}
    for slot = 1, 120 do
        local type, id, subType = GetActionInfo(slot)
        if type then
            if type == "macro" then
                if subType ~= "" and subType ~= "spell" then
                    --GetActionInfo currently returns slot - 1 as id on these things
                    --Which means we have no way of knowing what macro is on the slot so we cannot look for anything
                    print("Unable to save macro on slot "..slot.." due to a current API Bug.\nSlot will not be modified on load.")
                else 
                    --If id was actually a macro id try locate it
                    local macroName, icon, body = GetMacroInfo(id)
                    if macroName then
                        profile[slot] = {type = type, name = macroName, isCharacterSpecific = id > MAX_ACCOUNT_MACROS}
                    else
                        -- For spell macros the returned id can be a spell id
                        -- Try to find a macro with that spell id and save that.
                        local n, isCharSpecific = TryFindMacroBySpell(id)
                        if n then
                            profile[slot] = {type = type, name = n, isCharacterSpecific = isCharSpecific}
                        else
                            print("Warning: Failed to retrieve macro name for slot " .. slot)
                        end
                    end
                end
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
                C_Spell.PickupSpell(action.id)
                PlaceAction(slot)
            elseif action.type == "macro" then
                local macroIndex = GetMacroIndexByName(action.name)
                if macroIndex then
                    PickupMacro(macroIndex)
                    PlaceAction(slot)
                elseif action.isCharacterSpecific then
                    print("Macro '"..action.name.."' not found. It may be a character specific macro instead of a general macro.")
                else
                    print("Macro '"..action.name.."' not found. Was it deleted or renamed since save?")
                end
            elseif action.type == "item" then
                C_Item.PickupItem(action.id)
                PlaceAction(slot)
            elseif action.type == "companion" then
                PickupCompanion(action.subType, action.id)
            elseif action.type == "empty" then
                -- Clear the slot if it was saved as empty
                PickupAction(slot)
                ClearCursor()
            end
        end
    end

    -- Apply actions with delays since api is rate limited
    local function LoadNextSlot(slot)
        if slot == 100 then
            C_Timer.After(1, function() LoadNextSlot(slot + 1) end)
            return
        end
        
        if slot <= 120 then
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

    for slot = 1, 120 do
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
    for slot = 1, 120 do
        local type, id, subType = GetActionInfo(slot)
        if type then
            if type == "macro" then
                if subType ~= "" and subType ~= "spell" then
                    --GetActionInfo currently returns slot - 1 as id on these things
                    --Which means we have no way of knowing what macro is on the slot so we cannot look for anything
                    print("Unable to save macro on slot "..slot.." due to a current API Bug.\nSlot will not be modified on load.")
                else 
                    --If id was actually a macro id try locate it
                    local macroName, icon, body = GetMacroInfo(id)
                    if macroName then
                        profile[slot] = {type = type, name = macroName, isCharacterSpecific = id > MAX_ACCOUNT_MACROS}
                    else
                        -- For spell macros the returned id can be a spell id
                        -- Try to find a macro with that spell id and save that.
                        local n, isCharSpecific = TryFindMacroBySpell(id)
                        if n then
                            profile[slot] = {type = type, name = n, isCharacterSpecific = isCharSpecific}
                        else
                            print("Warning: Failed to retrieve macro name for slot " .. slot)
                        end
                    end
                end
            else
                profile[slot] = {type = type, id = id, subType = subType}
            end
        else
            print("Slot "..slot..": Empty")
        end
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
