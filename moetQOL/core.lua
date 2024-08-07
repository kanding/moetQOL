-- moet, 2020

local _, ns	= ...
ns.Core	= {} 
ns.ADDON_VERSION = C_AddOns.GetAddOnMetadata("moetQOL", "Version")
ns.SOURCE = "https://github.com/kanding/moetQOL/"

local Core = ns.Core
local Func = ns.Func

ns.Core.CHATCMD = "/mq"
ns.Core.CLEAR = "/clear"
ns.Core.RELOAD = "/rl"
ns.Core.PIN = "/pin"
ns.Core.PINSHARE = "/pinshare"

ns.Core.ChatCommands = {
    [1] = {ns.Core.CHATCMD.." [option]", "Toggle [option] on/off."},
    [2] =  {ns.Core.CLEAR, "Clears the primary chat window."},
    [3] = {ns.Core.RELOAD, "Reloads the UI."},
    [4] = {ns.Core.PIN, "Creates a map pin. Usage: /pin x y"},
    [5] = {ns.Core.PINSHARE, "Creates a map pin and shares it in chat."},
}

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
-- CORE FUNCTIONS
---------------------------------------------------
function Core:PrintFlags()
    for key, value in pairs(moetQOLDB) do
        if Core.MQdefault[key] then
            print(string.format("|c%s%s|r: |c%s%s|r", ns.REDCOLOR, key, value.state and ns.GREENCOLOR or "ffffffff", tostring(value.state)))
        else
            moetQOLDB[key] = nil -- remove unsupported key
        end
    end
end

function Core:PrintMessage(str)
    print(string.format("|c%smq:|r %s", ns.REDCOLOR, str))
end

function Core:MapPinUsage()
    print(string.format("|c%smq|r: Pass only positive X and Y values to create a pin! Usage: /pin x y", ns.REDCOLOR))
end

function Core:MapPinError(X, Y)
    print(string.format("|c%smq|r: Could not convert %s and %s to numbers.", ns.REDCOLOR, X or "", Y or ""))
end

function Core:CreateMapPin(X, Y)
    local mapID = C_Map.GetBestMapForUnit("player")
    if not C_Map.CanSetUserWaypointOnMap(mapID) then
        print(string.format("|c%smq|r: Cannot create pins on this mapID.", ns.REDCOLOR))
        return
    end

    C_Map.SetUserWaypoint({uiMapID=mapID, position={x=X, y=Y}})
    DEFAULT_CHAT_FRAME:AddMessage(
        string.format("|c%smq|r: Created map pin at (%s, %s).", ns.REDCOLOR, X, Y), 255, 255, 0
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
        if moetQOLDB[k].desc and moetQOLDB[k].desc ~= v.desc then
            moetQOLDB[k].desc = v.desc
        end

        if v.custom and not moetQOLDB[k].custom then
            moetQOLDB[k].custom = v.custom[1] or v.custom.min
        elseif moetQOLDB[k].custom and not v.custom then
            moetQOLDB[k].custom = nil
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

local function InvokeLoginFunctions()
    for i=1, #Func.onLogin do
        if type(Func.onLogin[i]) == "function" then
            Func.onLogin[i]()
        end
    end

    Func.onLogin = {}
    eventFrame = nil
end

local eventFrame = CreateFrame("FRAME")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", InvokeLoginFunctions)
eventFrame:Hide()

---------------------------------------------------
-- MAIN FUNCTION
---------------------------------------------------
Core.MQdefault = {
    ["maxzoom"]	= {state = false, desc = "Set the camera distance to maximum available", func = Func.SetMaxZoom, category = Core.FunctionCategory.UI},
    ["portraitnumbers"] = {state = false, desc = "Hide combat text feedback on your portrait", func = Func.HidePortraitNumbers, category = Core.FunctionCategory.UI},
    ["fastloot"] = {state = false, desc = "Faster auto looting", func = Func.EnableFastLoot, category = Core.FunctionCategory.Combat},
    ["errormsg"] = {state = false, desc="Hide certain generic red error messages", func=Func.HideErrorMessages, category=Core.FunctionCategory.UI},
    ["easydelete"] = {state = false, desc="Remove the need to type 'delete' on rare+ items", func=Func.EnableEasyDelete, category=Core.FunctionCategory.UI},
    ["chatbuttons"] = {state = false, desc="Hide voice buttons on your chat", func=Func.HideChatButtons, category=Core.FunctionCategory.UI},
    ["skipmovies"] = {state = false, desc="Auto skip all cinematics and cutscenes immediately", func=Func.AutoCancelCutscenes, category=Core.FunctionCategory.Misc},
    ["infostring"] = {state = false, desc="Show addon usage, MS and FPS beneath minimap. Additionally you can click the frame to clear garbage memory. The frame is moveable with ALT+LClick", func=Func.CreateInfoStrings, category=Core.FunctionCategory.UI},
    ["sell"] = {state = false, desc="Add a button on merchants to sell grey items. Alternatively select auto to automatically sell up to 12 grey items when speaking with a vendor", func=Func.CreateSellButton, custom={"manual", "auto"}, category=Core.FunctionCategory.Misc},
    ["talkinghead"] = {state = false, desc="Hide talking head frames", func=Func.HideTalkingHead, custom={"audio", "muteaudio"}, category=Core.FunctionCategory.UI},
    ["autorepair"] = {state = false, desc="Automatically repair items when possible using player funds", func=Func.AutoRepair, category=Core.FunctionCategory.Misc},
    ["realidcounter"] = {state = false, desc="Add a counter that shows current out of the maximum allowed friends to your social window", func=Func.RealIDCounter, category=Core.FunctionCategory.UI},
    ["combattooltip"] = {state = false, desc="Hide tooltip if in combat. Select always to hide in combat everywhere, instance to hide in combat inside instances and raid to hide in combat inside raids", func=Func.HideTooltipInCombat, custom={"always", "instance", "raid"}, category=Core.FunctionCategory.UI},
    ["dynamicspellqueue"] = {state = false, desc="automatically adjust spellqueue based on ranged or melee", func=Func.DynamicSpellQueue, custom={min=90, max=500}, category=Core.FunctionCategory.Combat},
    ["autoquest"] = {state = false, desc="Auto accept/deliver/share quests (hold SHIFT to disable). Additionally will automatically gossip certain quest NPCs. Select force to auto turn in quests with rewards (WARNING! This is irrevocable)", func=Func.AutoQuest, custom={"noforce", "force"}, category=Core.FunctionCategory.Quest},
    ["combatchat"] = {state = false, desc="Fade chat when in combat. Select always to fade chat in combat everywhere, instance to fade in combat in instances, or boss to fade when in an encounter (usually a boss)", func=Func.HideChatInCombat, custom={"always","instance","boss"}, category=Core.FunctionCategory.UI},
    ["questitembind"] = {state = false, desc="Add a keybind to use the closest watched quest item. This keybind can be set in Key Bindings/AddOns", func = Func.QuestItemBind, category=Core.FunctionCategory.Quest},
    ["minimaptracking"] = {state = false, desc="Disables target and focus icons on minimap, alternatively disables all tracking except for flight masters and crucial quests or dots", func = Func.DisableMinimapTracking, custom = {"target", "all"}, category=Core.FunctionCategory.UI},
    ["spellidtooltip"] = {state = false, desc="Adds spell id to item, auras and spell tooltips.", func = Func.AddSpellIdTooltipPostHooks, category=Core.FunctionCategory.UI},
}

function Core:ActivateFunctions()
    for k,v in pairs(moetQOLDB) do
        if v.state == true and Core.MQdefault[k] then
            if Core.MQdefault[k].func then
                Core.MQdefault[k].func()
            else
                print("|c"..ns.REDCOLOR.."mq|r: "..k.." is missing an associated function.")
            end
        end
    end
end
