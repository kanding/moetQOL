---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns = ... -- namespace
_G.moetQOLDB = moetQOLDB or {} -- database
ns.ADDON_VERSION = GetAddOnMetadata("moetQOL", "Version")
local SHORTCUT = "/mq"
local COLOR	= "00CC0F00" -- red
local COLOR2 = "FF00FF00" -- green
local WELCOME_MESSAGE = string.format("|c%smoetQOL|r loaded: V%s - |c%s%s|r to toggle features.", COLOR, ns.ADDON_VERSION, COLOR, SHORTCUT)
local statesChanged = 0 -- avoid spamming with /reload requests
local default = ns.Core.MQdefault
--indices for state, description and associated function in default table
local STATE, DESC, FUNC = ns.Core.STATE, ns.Core.DESC, ns.Core.FUNC

---------------------------------------------------
-- CUSTOM SLASH COMMANDS
-- For special commands. If no equal key in mqCommands then
-- argument is passed to ChangeState() and executed if valid.
---------------------------------------------------
local mqCommands = {
	["help"] = ns.Core.PrintHelp,
	["flags"] = ns.Core.PrintFlags,
	["hardreset"] = function()
		moetQOLDB = default
		print(string.format("|c%smq:|r Database set to default, values set to Off.", COLOR))
	end,
	["showbonus"] = function()
		BonusRollFrame:Show()
	end,
}

---------------------------------------------------
-- FUNCTIONS
---------------------------------------------------
function ChangeState(str)
	if (str == nil) then return end

	if moetQOLDB[str] then
		if (moetQOLDB[str][STATE] == "On") then
			moetQOLDB[str][STATE] = "Off"
			print("|c" .. COLOR .. str .. "|r: Off")
		elseif (moetQOLDB[str][STATE] == "Off") then
			moetQOLDB[str][STATE] = "On"
			print("|c" .. COLOR .. str .. "|r: |c" .. COLOR2 .. "On|r")
		end
		statesChanged = statesChanged + 1
	else
		print(string.format("|c%smq:|r %s is not a valid command.", COLOR, str))
		return
	end

	-- only 1 reload needed per set of changes
	if (statesChanged == 1) then
		print(string.format(
			"|c%smq|r: Make sure you |c%s/reload|r for the change to take effect.", 
			COLOR, COLOR2))
	end
end

local function HandleSlashCommands(str)
	if (#str == 0) then -- player entered /mq
		mqCommands.help()
	end

	local args = {}
	local path = mqCommands

	for _, arg in ipairs({ string.split(' ', str) }) do
		if (#arg > 0) then
			table.insert(args, arg) -- args is now a table with each word
		end
	end

	-- iterate through commands until we find the correct one
	for id, arg in ipairs(args) do
		if (#arg > 0) then
			arg = arg:lower()
			if (path[arg]) then
				if (type(path[arg]) == "function") then
					path[arg](arg)
					--[[ save this if we want any extra arguments to be passed,
						 example: /mq fastloot on (will pass "fastloot" + "on")
						 path[arg](select(id + 1, unpack(args))) --]]
					return
				elseif (type(path[arg]) == "table") then
					path = path[arg] -- enter found subtable
				end
			else
				ChangeState(arg)
				return
			end
		end
	end
end

local function CheckDatabaseErrors()
	for k,v in pairs(default) do
		if not moetQOLDB[k] then
			moetQOLDB[k] = {v[STATE], v[DESC]}
		end
		
		if moetQOLDB[k][DESC] and moetQOLDB[k][DESC] ~= default[k][DESC] then
			moetQOLDB[k][DESC] = default[k][DESC]
		end
	end
end

function ns:init(event, name)
	if (name ~= "moetQOL") then return end

	-- custom slash commands
	SLASH_moetQOL1 = SHORTCUT
	SLASH_CLEAR1 = "/clear"
	SlashCmdList.moetQOL = HandleSlashCommands
	SlashCmdList.CLEAR = function() ChatFrame1:Clear() end

	CheckDatabaseErrors()
	ns.Core.ActivateFunctions()

	print(WELCOME_MESSAGE)
end

---------------------------------------------------
-- INIT
---------------------------------------------------
local addonLoadedEvents = CreateFrame("frame")
addonLoadedEvents:RegisterEvent("ADDON_LOADED")
addonLoadedEvents:SetScript("OnEvent", ns.init)