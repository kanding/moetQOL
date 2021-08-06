-- moet, 2020

---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns = ...
_G.moetQOLDB = moetQOLDB or {}
local COLOR	= "00CC0F00" -- red
local COLOR2 = "FF00FF00" -- green
local WELCOME_MESSAGE = string.format("|c%smoetQOL|r loaded: v%s - |c%s%s|r to toggle features.", COLOR, ns.ADDON_VERSION, COLOR, ns.Core.CHATCMD)
local statesChanged = 0 -- avoid spamming with /reload requests
--indices for state, description and associated function in default table
local STATE, DESC, FUNC, OPTION = ns.Core.STATE, ns.Core.DESC, ns.Core.FUNC, ns.Core.OPTION

---------------------------------------------------
-- CUSTOM SLASH COMMANDS
-- For special commands. If no equal key in mqCommands then
-- argument is passed to ChangeState() or ChangeOptions().
---------------------------------------------------
local mqCommands = {
    ["help"] = ns.Config.ToggleFrame,
    ["flags"] = ns.Core.PrintFlags,
    ["mappinhelp"] = ns.Core.MapPinUsage,
    ["mappinvalue"] = ns.Core.MapPinError,
    ["hardreset"] = function()
        moetQOLDB = ns.Core.MQdefault
        print(string.format("|c%smq:|r Database set to default, values set to Off.", COLOR))
    end,
}

---------------------------------------------------
-- FUNCTIONS
---------------------------------------------------
local function ChangeState(str)
    --[[
    if str == nil then return end

    if moetQOLDB[str] then
        if moetQOLDB[str][STATE] == "On" then
            moetQOLDB[str][STATE] = "Off"
            print(string.format("|c%s%s|r: Off", COLOR, str))
        elseif moetQOLDB[str][STATE] == "Off" then
            moetQOLDB[str][STATE] = "On"
            print(string.format("|c%s%s|r: |c%sOn|r", COLOR, str, COLOR2))
        end
        statesChanged = statesChanged + 1
    else
        print(string.format("|c%smq:|r %s is not a valid command.", COLOR, str))
        return
    end

    -- only 1 reload needed per set of changes
    if statesChanged == 1 then
        print(string.format(
            "|c%smq|r: Make sure you |c%s/reload|r for the change to take effect.",
            COLOR, COLOR2))
    end
    --]]
end

local function ChangeOptions(str, option)
    --[[
    if str == nil or option == nil then return end

    if moetQOLDB[str][OPTION] then
        local isNumber = tonumber(option)
        if isNumber then option = isNumber end

        if type(option) == type(moetQOLDB[str][OPTION]) then
            moetQOLDB[str][OPTION] = option
            print(string.format("|c%s%s|r: |c%s%s|r", COLOR, str, COLOR2, moetQOLDB[str][OPTION]))
            statesChanged = statesChanged + 1
        else
            print(string.format("|c%smq:|r %s custom option must be of type: %s", COLOR, str, type(moetQOLDB[str][OPTION])))
            print(string.format("|c%smq:|r Please see https://github.com/kanding/moetQOL/releases for possible options.", COLOR))
        end
    else
        print(string.format("|c%smq:|r %s does not have custom options.", COLOR, str))
        print(string.format("|c%smq:|r See https://github.com/kanding/moetQOL/releases for details.", COLOR))
    end

    if statesChanged == 1 then
        print(string.format("|c%smq|r: Make sure you |c%s/reload|r for the change to take effect.", COLOR, COLOR2))
    end
    ]]
end

local function HandleSlashCommands(str)
    if #str == 0 then mqCommands.help() return end

    local args = {}
    local path = mqCommands

    for _, arg in ipairs({ string.split(' ', str) }) do
        if (#arg > 0) then
            table.insert(args, arg)
        end
    end

    -- iterate through commands until we find the correct one
    for id, arg in ipairs(args) do
        if (#arg > 0) then
            arg = arg:lower()
            if (path[arg]) then
                if (type(path[arg]) == "function") then
                    path[arg](select(id, unpack(args)))
                    return
                elseif (type(path[arg]) == "table") then
                    path = path[arg] -- enter found subtable
                end
            else
                if #args > 1 then
                    ChangeOptions(select(id, unpack(args)))
                else
                    ChangeState(arg)
                end
                return
            end
        end
    end
end

local function HandlePin(str, ...)
    if #str == 0 then mqCommands.mappinhelp() return false end
    local args = { string.split(' ', str) }
    -- Two coordinates: X and Y.
    if #args ~= 2 then mqCommands.mappinhelp() return false end

    local x = tonumber(args[1])
    local y = tonumber(args[2])
    if type(x) ~= "number" or type(y) ~= "number" then
        mqCommands:mappinvalue(args[1], args[2])
        return false
    end

    if x < 0 or y < 0 then mqCommands.mappinhelp() return false end
    -- Coordinates have to be between 0 (top) and 1 (bottom).
    -- If we typed in 34.4 or something we map it between 0 and 1
    if x > 1 then x = x / 100 end
    if y > 1 then y = y / 100 end

    ns.Core:CreateMapPin(x, y)
end

local function HandlePinShare(str, ...)
    HandlePin(str, ...)
    local waypointlink = C_Map.GetUserWaypointHyperlink()
    if UnitInRaid("player") then
        SendChatMessage(waypointlink, "RAID")
    elseif UnitInParty("player") then
        SendChatMessage(waypointlink, "PARTY")
    else
        SendChatMessage(waypointlink)
    end
end

local function Init(self, event, name)
    if name ~= "moetQOL" then return end

    -- specify keybinds header
    BINDING_HEADER_MOETQOL = "moetQOL"
    BINDING_NAME_USEMOSTRECENTQUESTITEM = "Use the closest watched quest item (requires feature enabled)"

    -- custom slash commands
    SLASH_moetQOL1 = ns.Core.CHATCMD
    SLASH_CLEAR1 = ns.Core.CLEAR
    SLASH_RL1 = ns.Core.RELOAD
    SLASH_PIN1 = ns.Core.PIN
    SLASH_PINSHARE1 = ns.Core.PINSHARE
    SlashCmdList.moetQOL = HandleSlashCommands
    SlashCmdList.CLEAR = function() ChatFrame1:Clear() end
    SlashCmdList.RL = function() ReloadUI() end
    SlashCmdList.PIN = HandlePin
    SlashCmdList.PINSHARE = HandlePinShare

    ns.Core.CheckDatabaseErrors()
    ns.Core.ActivateFunctions()

    print(WELCOME_MESSAGE)
end

---------------------------------------------------
-- INIT
---------------------------------------------------
local addonLoadedEvents = CreateFrame("FRAME")
addonLoadedEvents:RegisterEvent("ADDON_LOADED")
addonLoadedEvents:SetScript("OnEvent", Init)
addonLoadedEvents:Hide()
