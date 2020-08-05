-- moet, 2020

---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns	= ...
ns.Core	= {} -- add the core to the namespace
local Core = ns.Core
local Func = ns.Func
local F_COLOR = "00CC0F00" -- red
local F_COLOR2 = "FF00FF00" -- green
--indices for state, description and associated function in default table
Core.STATE = 1
Core.DESC = 2
Core.FUNC = 3
Core.OPTION = 4
local STATE, DESC, FUNC, OPTION = Core.STATE, Core.DESC, Core.FUNC, Core.OPTION

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
end

function Core:PrintHelp()
	print("|c00CC0F00moetQOL|r v"..ns.ADDON_VERSION.." List of commands:")
	print("/mq |c" .. F_COLOR2 .. "flags|r - to show your current settings.")
	print("/mq |c" .. F_COLOR2 .. "hardreset|r - to reset all saved settings to default (off).")
	for key, value in pairs(Core.MQdefault) do
		print(string.format("/mq |c%s%s|r - %s.", F_COLOR, key, value[DESC]))
	end
end

---------------------------------------------------
-- MAIN FUNCTION
---------------------------------------------------
Core.MQdefault = {
	-- key = name, value[1] = state, value[2] = description, value[3] = function to execute if state is On
	-- values beyond that are custom options
	-- TODO: consider using dictionary, state = "off", desc = .. etc
	["maxzoom"]	= {"Off", "sets camera distance to maximum available", Func.SetMaxZoom},
	["portraitnumbers"] = {"Off", "hide combat numbers on your portrait", Func.HidePortraitNumbers},
	["fastloot"] = {"Off", "faster auto looting", Func.EnableFastLoot},
	["errormsg"] = {"Off", "hide generic red error messages", Func.HideErrorMessages},
	["easydelete"] = {"Off", "remove the need to type 'delete' on rare+ items", Func.EnableEasyDelete},
	["chatbuttons"] = {"Off", "hide chat buttons", Func.HideChatButtons},
	["skipmovies"] = {"Off", "auto skip all cutscenes", Func.AutoCancelCutscenes},
	["infostring"] = {"Off", "show addon usage, MS and FPS beneath minimap, click to collect garbage (moveable with ALT+LClick)", Func.CreateInfoStrings},
	["sell"] = {"Off", "adds a button on merchants to sell grey items", Func.CreateSellButton, "manual"},
	["oldguild"] = {"Off", "Reverts to old guild frame if you're in a guild", Func.HideCommunities},
	["talkinghead"] = {"Off", "hides talking head frames", Func.HideTalkingHead},
	["fastislands"] = {"Off", "instantly queues mythic islands upon opening the table", Func.InstantQueueMythicIsland},
	["autorepair"] = {"Off", "automatically repair items when possible using player funds", Func.AutoRepair},
	["paragontooltip"] = {"Off", "adds total completions to paragon tooltip", Func.ParagonTooltip},
	["realidcounter"] = {"Off", "adds a counter that shows current out of total friends", Func.RealIDCounter},
	["combattooltip"] = {"Off", "hides tooltip if in combat", Func.HideTooltipInCombat, "normal"},
	["dynamicspellqueue"] = {"Off", "automatically adjust spellqueue based on ranged or melee", Func.DynamicSpellQueue, 280},
	["autoquest"] = {"Off", "auto accept/deliver/share quests (hold SHIFT to disable)", Func.AutoQuest},
	["combatchat"] = {"Off", "NYI: fades chat when in Boss/Encounter combat", Func.HideChatInCombat},
}

function Core:ActivateFunctions()
	for k,v in pairs(moetQOLDB) do
		if v[STATE] == "On" and Core.MQdefault[k] then
			if Core.MQdefault[k][FUNC] then
				Core.MQdefault[k][FUNC]()
			else
				print("|c"..F_COLOR.."mq|r: "..k.." is missing an associated function.")
			end
		end
	end
end
