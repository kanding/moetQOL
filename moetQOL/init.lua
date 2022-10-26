-- moet, 2020

local _, ns = ...
_G.moetQOLDB = moetQOLDB or {}

local WELCOME_MESSAGE = string.format("|c%smoetQOL|r loaded: v%s - |c%s%s|r to toggle features.", ns.REDCOLOR, ns.ADDON_VERSION, ns.REDCOLOR, ns.Core.CHATCMD)
local statesChanged = 0

---------------------------------------------------
-- CUSTOM SLASH COMMANDS
---------------------------------------------------
local mqCommands = {
    ["help"] = ns.Config.ToggleFrame,
    ["flags"] = ns.Core.PrintFlags,
    ["mappinhelp"] = ns.Core.MapPinUsage,
    ["mappinvalue"] = ns.Core.MapPinError,
    ["hardreset"] = function()
        moetQOLDB = ns.Core.MQdefault
        ReloadUI()
        ns.Core.PrintMessage("Database set to default, all functions set to off.")
    end,
}

local function ChangeState(str)
    if str == nil then return end

    if moetQOLDB[str] then
        if moetQOLDB[str].state == true then
            moetQOLDB[str].state = false
            print(string.format("|c%s%s|r: Off", ns.REDCOLOR, str))
        elseif moetQOLDB[str].state == false then
            moetQOLDB[str].state = true
            print(string.format("|c%s%s|r: |c%sOn|r", ns.REDCOLOR, str, ns.GREENCOLOR))
        end

        ns.Config:UpdateStates()
        statesChanged = statesChanged + 1
    else
        ns.Core:PrintMessage(string.format("%s is not a valid command.", str))
        return
    end

    -- only 1 reload needed per set of changes
    if statesChanged == 1 then
        ns.Core:PrintMessage(string.format("Make sure you |c%s/reload|r for the change to take effect.", ns.GREENCOLOR))
    end
end

local function ChangeOptions(str, option)
    if str == nil or option == nil then return end
    if moetQOLDB[str] then
        ns.Core.PrintMessage("Use /mq to change custom options.")
    end
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

---------------------------------------------------
-- FUNCTIONS
---------------------------------------------------
local function StoreDBSnapshot()
    local t = {}
    for k,v in pairs(moetQOLDB) do t[k] = v.state end
    return t
end

local function Init(self, event, name)
    if name ~= "moetQOL" then return end

    -- specify keybinds header
    BINDING_HEADER_MOETQOL = "moetQOL"
    BINDING_NAME_USEMOSTRECENTQUESTITEM = "Use the closest watched quest item (requires feature enabled)"

    -- slash commands
    SLASH_moetQOL1 = ns.Core.CHATCMD
    SLASH_CLEAR1 = ns.Core.CLEAR
    SLASH_RL1 = ns.Core.RELOAD
    SLASH_PIN1 = ns.Core.PIN
    SLASH_PINSHARE1 = ns.Core.PINSHARE
    SlashCmdList.moetQOL = HandleSlashCommands
    SlashCmdList.CLEAR = function() ChatFrame1:Clear() end
    SlashCmdList.RL = function() ReloadUI() end
    SlashCmdList.PIN = ns.Core.HandlePin
    SlashCmdList.PINSHARE = ns.Core.HandlePinShare

    ns.Core.CheckDatabaseErrors()
    ns.Core.ActivateFunctions()
    ns.Config.SetupInterfaceOption()

    ns.LOADED_DB = StoreDBSnapshot() -- store copy of DB we loaded with
    print(WELCOME_MESSAGE)
    addonLoadedEvents = nil
end

---------------------------------------------------
-- INIT
---------------------------------------------------
local addonLoadedEvents = CreateFrame("FRAME")
addonLoadedEvents:RegisterEvent("ADDON_LOADED")
addonLoadedEvents:SetScript("OnEvent", Init)
addonLoadedEvents:Hide()
