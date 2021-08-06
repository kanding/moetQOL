-- moet, 2020

---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns	= ...
ns.Core	= {} -- add the core to the namespace
ns.ADDON_VERSION = GetAddOnMetadata("moetQOL", "Version")
local Core = ns.Core

-- Chat cmds
Core.CHATCMD = "/mq"
Core.CLEAR = "/clear"
Core.RELOAD = "/rl"
Core.PIN = "/pin"
Core.PINSHARE = "/pinshare"

local Func = ns.Func
local F_COLOR = "00CC0F00" -- red
local F_COLOR2 = "FF00FF00" -- green
--indices for state, description and associated function in default table
Core.STATE = 1
Core.DESC = 2
Core.FUNC = 3
Core.OPTION = 4
local STATE, DESC, FUNC, OPTION = Core.STATE, Core.DESC, Core.FUNC, Core.OPTION

local function enum(tbl)
    local length = #tbl
    for i = 1, length do
        local v = tbl[i]
        tbl[v] = i
    end

    return tbl
end

Core.FunctionCategory = enum {
    "Misc",
    "UI",
    "Quest",
    "Combat",
}

---------------------------------------------------
-- INVOKE ON LOGIN
---------------------------------------------------
local function InvokeLoginFunctions()
    for i=1, #Func.onLogin do
        if type(Func.onLogin[i]) == "function" then
            Func.onLogin[i]()
        end
    end

    Func.onLogin = nil
    eventFrame = nil
end

local eventFrame = CreateFrame("FRAME")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", InvokeLoginFunctions)
eventFrame:Hide()
---------------------------------------------------
-- CORE FUNCTIONS
---------------------------------------------------
function Core:PrintFlags(state)
    --[[
    for key, value in pairs(moetQOLDB) do
        if Core.MQdefault[key] then
            if state then
                state = state:lower()
                if value[STATE]:lower() == state then
                    if state == "off" then
                        print(string.format("|c%s%s|r: %s", F_COLOR, key, value[STATE]))
                    else
                        if value[OPTION] then
                            print(string.format("|c%s%s|r: |c%s%s|r, %s", F_COLOR, key, F_COLOR2, value[STATE], value[OPTION]))
                        else
                            print(string.format("|c%s%s|r: |c%s%s|r", F_COLOR, key, F_COLOR2, value[STATE]))
                        end
                    end
                end
            else
                if value[STATE] == "Off" then
                    print(string.format("|c%s%s|r: %s", F_COLOR, key, value[STATE]))
                else
                    if value[OPTION] then
                        print(string.format("|c%s%s|r: |c%s%s|r, %s", F_COLOR, key, F_COLOR2, value[STATE], value[OPTION]))
                    else
                        print(string.format("|c%s%s|r: |c%s%s|r", F_COLOR, key, F_COLOR2, value[STATE]))
                    end
                end
            end
        else
            moetQOLDB[key] = nil -- remove unsupported key
        end
    end
    ]]
end

function Core:PrintHelp()
    --[[
    print("|c"..F_COLOR.."moetQOL|r v"..ns.ADDON_VERSION.." List of commands:")
    print("/mq |c" .. F_COLOR2 .. "flags|r - to show your current settings.")
    print("/mq |c" .. F_COLOR2 .. "hardreset|r - to reset all saved settings to default (off).")
    for key, value in pairs(Core.MQdefault) do
        print(string.format("/mq |c%s%s|r - %s.", F_COLOR, key, value[DESC]))
    end
    ]]
end

function Core:PrintMessage(str)
    print(string.format("|c%smq:|r %s", F_COLOR, str))
end

function Core:MapPinUsage()
    print(string.format("|c%smq|r: Pass only positive X and Y values to create a pin! Usage: /pin x y", F_COLOR))
end

function Core:MapPinError(X, Y)
    print(string.format("|c%smq|r: Could not convert %s and %s to numbers.", F_COLOR, X or "", Y or ""))
end

function Core:CreateMapPin(X, Y)
    local mapID = C_Map.GetBestMapForUnit("player")
    if not C_Map.CanSetUserWaypointOnMap(mapID) then
        print(string.format("|c%smq|r: Cannot create pins on this mapID.", F_COLOR))
        return
    end

    C_Map.SetUserWaypoint({uiMapID=mapID, position={x=X, y=Y}})
    DEFAULT_CHAT_FRAME:AddMessage(
        string.format("|c%smq|r: Created map pin at (%s, %s).", F_COLOR, X, Y), 255, 255, 0
    )
end

function Core:GetKeyName(table, value)
    for k,v in pairs(table) do
        if v == value then return k end
    end
end

function Core:CheckDatabaseErrors()
    for k,v in pairs(Core.MQdefault) do
        --create if not exist
        if not moetQOLDB[k] then
            if v.custom then
                moetQOLDB[k] = {state = v.state, desc = v.desc, custom = v.custom[1]}
            else
                moetQOLDB[k] = {state = v.state, desc = v.desc}
            end 
        end

        --update if outdated
        --todo double check we cant just use v?
        if moetQOLDB[k].desc and moetQOLDB[k].desc ~= v.desc then
            moetQOLDB[k].desc = v.desc
        end

        if v.custom and not moetQOLDB[k].custom then
            moetQOLDB[k].custom = v.custom[1] or v.custom.min
        elseif moetQOLDB[k].custom and not v.custom then
            moetQOLDB[k][OPTION] = nil
        end

        --Check for pre3.0
        local oldstate = moetQOLDB[k][1]
        if oldstate and (oldstate == "On" or oldstate == "Off") then
            local option = moetQOLDB[k][4]
            if v.custom then
                local isNumber = tonumber(option)
                --check old custom key is not outdated
                if isNumber and v.custom.min and v.custom.max then
                    if isNumber >= v.custom.min and isNumber <= v.custom.max then
                        moetQOLDB[k] = {state = oldstate == "On" and true or false, desc = v.desc, custom = isNumber}
                    else
                        moetQOLDB[k] = {state = oldstate == "On" and true or false, desc = v.desc, custom = v.custom.min}
                    end
                elseif option then
                    local found = false
                    for i=1,#v.custom do 
                        if v.custom[i] == option then found = true end
                    end

                    moetQOLDB[k] = {state = oldstate == "On" and true or false, desc = v.desc, custom = found and option or v.custom[1]}
                end
            else
                moetQOLDB[k] = {state = oldstate == "On" and true or false, desc = v.desc}
            end
        end
    end
end

---------------------------------------------------
-- MAIN FUNCTION
---------------------------------------------------
Core.MQdefault = {
    ["maxzoom"]	= {state = false, desc = "sets camera distance to maximum available", func = Func.SetMaxZoom, category = Core.FunctionCategory.UI},
    ["portraitnumbers"] = {state = false, desc = "hide combat numbers on your portrait", func = Func.HidePortraitNumbers, category = Core.FunctionCategory.UI},
    ["fastloot"] = {state = false, desc = "faster auto looting", func = Func.EnableFastLoot, category = Core.FunctionCategory.Combat},
    ["errormsg"] = {state = false, desc="hide generic red error messages", func=Func.HideErrorMessages, category=Core.FunctionCategory.UI},
    ["easydelete"] = {state = false, desc="remove the need to type 'delete' on rare+ items", func=Func.EnableEasyDelete, category=Core.FunctionCategory.UI},
    ["chatbuttons"] = {state = false, desc="hide chat buttons", func=Func.HideChatButtons, category=Core.FunctionCategory.UI},
    ["skipmovies"] = {state = false, desc="auto skip all cinematics and cutscenes", func=Func.AutoCancelCutscenes, category=Core.FunctionCategory.Misc},
    ["infostring"] = {state = false, desc="show addon usage, MS and FPS beneath minimap, click to collect garbage (moveable with ALT+LClick)", func=Func.CreateInfoStrings, category=Core.FunctionCategory.UI},
    ["sell"] = {state = false, desc="adds a button on merchants to sell grey items", func=Func.CreateSellButton, custom={"manual", "auto"}, category=Core.FunctionCategory.Misc},
    ["oldguild"] = {state = false, desc="Reverts to old guild frame if you're in a guild", func=Func.HideCommunities, category=Core.FunctionCategory.UI},
    ["talkinghead"] = {state = false, desc="hides talking head frames", func=Func.HideTalkingHead, category=Core.FunctionCategory.UI},
    ["autorepair"] = {state = false, desc="automatically repair items when possible using player funds", func=Func.AutoRepair, category=Core.FunctionCategory.Misc},
    ["paragontooltip"] = {state = false, desc="adds total completions to paragon tooltip", func=Func.ParagonTooltip, category=Core.FunctionCategory.UI},
    ["realidcounter"] = {state = false, desc="adds a counter that shows current out of total friends", func=Func.RealIDCounter, category=Core.FunctionCategory.UI},
    ["combattooltip"] = {state = false, desc="hides tooltip if in combat", func=Func.HideTooltipInCombat, custom={"always", "instance", "raid"}, category=Core.FunctionCategory.UI},
    ["dynamicspellqueue"] = {state = false, desc="automatically adjust spellqueue based on ranged or melee", func=Func.DynamicSpellQueue, custom={min=90, max=500}, category=Core.FunctionCategory.Combat},
    ["autoquest"] = {state = false, desc="auto accept/deliver/share quests (hold SHIFT to disable)", func=Func.AutoQuest, custom={"noforce", "force"}, category=Core.FunctionCategory.Quest},
    ["combatchat"] = {state = false, desc="fades chat when in combat", func=Func.HideChatInCombat, custom={"always","instance","boss"}, category=Core.FunctionCategory.UI},
    ["questitembind"] = {state = false, desc="adds a keybind (set in Key Bindings/AddOns) to use the closest watched quest item", func = Func.QuestItemBind, category=Core.FunctionCategory.Quest},
}

function Core:ActivateFunctions()
    for k,v in pairs(moetQOLDB) do
        if v.state == true and Core.MQdefault[k] then
            if Core.MQdefault[k].func then
                Core.MQdefault[k].func()
            else
                print("|c"..F_COLOR.."mq|r: "..k.." is missing an associated function.")
            end
        end
    end
end
