---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns	= ... -- namespace
_G.moetQOLDB = moetQOLDB or {} -- database
local addonVersion = GetAddOnMetadata("moetQOL", "Version")
local shortcut = "/mq"
local color	= "00CC0F00" -- red
local color2 = "FF00FF00" -- green
local welcomeMSG = string.format("|c%s%s|r to turn features on/off.", color, shortcut)
local statesChanged = 0 -- avoid spamming with /reload requests

local default = {
	-- key = name, value[1] = state, value[2] = description
	["maxzoom"]	= {"Off", "sets camera distance to max"},
	["portraitnumbers"]	= {"Off", "show/hide combat numbers on your portrait"},
	["fastloot"] = {"Off", "faster auto looting"},
	["errormsg"] = {"Off", "show/hide red error messages"},
	["easydelete"] = {"Off", "remove the need to type 'delete' on rare+ items"},
	["voicebuttons"] = {"Off", "show/hide Voice chat buttons"},
	["skipmovies"] = {"Off", "auto skip all cutscenes"},
	["borders"] = {"Off", "hides some Blizzard UI borders"},
	["infostring"] = {"Off", "shows MS and FPS beneath minimap"},
	["sell"] = {"Off", "adds a button on merchants to sell grey items"},
	["communities"]	= {"Off", "Reverts to old guild frame if you're in a guild"},
	["talkinghead"] = {"Off", "hides talking head frames"},
	["fastislands"] = {"Off", "instantly queues mythic islands upon opening the table"},
}

---------------------------------------------------
-- CUSTOM SLASH COMMANDS
-- For special commands. If no equal key in mqCommands then
-- argument is passed to ChangeState() and executed if valid.
---------------------------------------------------
local mqCommands = {
	["help"] = function()
		ns.Core.PrintHelp()
		for key, value in pairs(default) do
			print(string.format("/mq |c%s%s|r - %s.", color, key, value[2]))
		end
	end,

	["flags"] = function()
		ns.Core.PrintFlags()
	end,

	["hardreset"] = function()
		moetQOLDB = default
		print(string.format("|c%smq:|r Database set to default, values set to Off.", color))
	end,
}

---------------------------------------------------
-- FUNCTIONS
---------------------------------------------------
--[[
local function CheckDatabaseKeysNil(database, default)
	for key, value in pairs(default) do
		if database[key] == nil then
			database[key] = value
		end
		if (database[key][2] ~= default[key][2]) then
			database[key][2] = default[key][2]
		end
		if (database[key][3] ~= default[key][3]) then
			database[key][3] = default[key][3]
		end
		elseif (type(database[key]) == "table") then
			CheckDatabaseKeysNil(database[key], default[key])
		end
	end
end]]

-- Checks if valid string and if true changes On/Off.
function ChangeState(str)
	if (str == nil) then return end

	if moetQOLDB[str] then
		if (moetQOLDB[str][1] == "On") then
			moetQOLDB[str][1] = "Off"
			print("|c" .. color .. str .. "|r: Off")
		elseif (moetQOLDB[str][1] == "Off") then
			moetQOLDB[str][1] = "On"
			print("|c" .. color .. str .. "|r: |c" .. color2 .. "On|r")
		end
		statesChanged = statesChanged + 1
	else
		print(string.format("|c%smq:|r %s is not a valid command.", color, str))
		return
	end

	-- only 1 reload needed per set of changes
	if (statesChanged == 1) then
		print(string.format(
			"|c%smq|r: Make sure you |c%s/reload|r for the change to take effect.", 
			color, color2))
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

local function CheckDataBaseForNil()
	for key, value in pairs(default) do
		if (moetQOLDB[key] == nil) then
			moetQOLDB[key] = value
		end
	end
end

local function UpdateDataBaseDescriptions()
	for key, value in pairs(default) do
		if (moetQOLDB[key][2] ~= default[key][2]) then
			moetQOLDB[key][2] = default[key][2]
		end
	end
end

function ns:GetDefaultTableCount() 
	local count = 0
	for _ in pairs(default) do
		count = count + 1
	end
	return count
end

function ns:init(event, name)
	if (name ~= "moetQOL") then return end

	-- custom slash commands
	SLASH_moetQOL1 = shortcut
	SLASH_CLEAR1 = "/clear"
	SlashCmdList.moetQOL = HandleSlashCommands
	SlashCmdList.CLEAR = function() ChatFrame1:Clear() end

	CheckDataBaseForNil()
	UpdateDataBaseDescriptions()
	-- ns.CheckDataBaseKeyNames()
	ns.Core.ActivateFunctions()

	print("|c" .. color .. "moetQOL" .. "|r loaded: Version " .. addonVersion .. ".")
	print(welcomeMSG)
end

---------------------------------------------------
-- INIT
---------------------------------------------------
local addonLoadedEvents = CreateFrame("frame")
addonLoadedEvents:RegisterEvent("ADDON_LOADED")
addonLoadedEvents:SetScript("OnEvent", ns.init)