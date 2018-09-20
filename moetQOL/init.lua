---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns			= ... -- namespace
_G.moetQOLDB		= moetQOLDB or {} -- database
local addonVersion	= GetAddOnMetadata("moetQOL", "Version")
local shortcut		= "/mq"
local color			= "00CC0F00" -- red
local color2		= "FF00FF00" -- green
local welcomeMSG	= string.format("|c%s%s|r to turn features on/off.", color, shortcut)
local statesChanged = 0 -- avoid spamming with /reload requests

local default = {
							-- value[1] = state, value[2] = description
	["maxzoom"]				= {"Off", "sets camera distance to max"},
	["portraitnumbers"]		= {"Off", "show/hide combat numbers on your portrait"},
	["fastloot"]			= {"Off", "faster auto looting"},
	["errormsg"]			= {"Off", "show/hide red error messages"},
	["easydelete"]			= {"Off", "remove the need to type 'delete' on rare+ items"},
	["voicebuttons"]		= {"Off", "show/hide Voice chat buttons"},
	["skipmovies"]			= {"Off", "auto skip all cutscenes"},
	["borders"]				= {"Off", "hides some Blizzard UI borders"},
	["infostring"]			= {"Off", "shows MS and FPS beneath minimap"},
	["sell"]				= {"Off", "adds a button on merchants to sell grey items"},
	["communities"]			= {"Off", "Reverts to old guild frame if you're in a guild"},
}

---------------------------------------------------
-- CUSTOM SLASH COMMANDS
---------------------------------------------------
-- sell[arg] is not recognized as function in HandleSlashCommands (is nil)
-- unless wrapped in function
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

	-- not added to help automatically atm
	["sell"] = function(self)
		ChangeState(self)
	end,

	["maxzoom"] = function(self)
		ChangeState(self)
	end,

	["portraitnumbers"] = function(self)
		ChangeState(self)
	end,
	
	["fastloot"] = function(self)
		ChangeState(self)
	end,

	["errormsg"] = function(self)
		ChangeState(self)
	end,

	["easydelete"] = function(self)
		ChangeState(self)
	end,

	["voicebuttons"] = function(self)
		ChangeState(self)
	end,

	["skipmovies"] = function(self)
		ChangeState(self)
	end,

	["borders"] = function(self)
		ChangeState(self)
	end,

	["infostring"] = function(self)
		ChangeState(self)
	end,

	["communities"] = function(self)
		ChangeState(self)
	end,
	
}

---------------------------------------------------
-- FUNCTIONS
---------------------------------------------------
function ChangeState(str)
	if (str == nil) then
		print("string was nil in ChangeState.")
		return
	end

	if (moetQOLDB[str][1] == "On") then
		moetQOLDB[str][1] = "Off"
		print("|c" .. color .. str .. "|r: Off")
		statesChanged = statesChanged + 1
	elseif (moetQOLDB[str][1] == "Off") then
		moetQOLDB[str][1] = "On"
		print("|c" .. color .. str .. "|r: |c" .. color2 .. "On|r")
		statesChanged = statesChanged + 1
	else
		print("Requested ChangeState: " .. tostring(moetQOLDB[str][1]))
		return
	end
	-- only 1 reload needed per set of changes
	if (statesChanged == 1) then
		print(string.format(
			"|c%smq|r: Make sure you |c%s/reload|r for the change to take effect.", 
			color, color2)
		)
	end
end

local function HandleSlashCommands(str)
	if (#str == 0) then -- player entered /mq
		mqCommands.help()
	end
	-- figure out what the player wrote
	-- insert each word into a table and remove any spaces
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
			arg = arg:lower() -- make the command into lowercase
			if (path[arg]) then
				if (type(path[arg]) == "function") then
					-- if we reached a function in command,
					path[arg](arg)
					--[[ save this if we want any extra arguments to be passed,
						 example: /mq fastloot on (will pass "fastloot" + "on")
						 path[arg](select(id + 1, unpack(args))) --]]
					return
				elseif (type(path[arg]) == "table") then
					path = path[arg] -- enter found subtable
				end
			else
				mqCommands.help()
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

-- first function to run on ADDON_LOADED
function ns:init(event, name)
	if (name ~= "moetQOL") then return end -- checks if the correct addon loaded

	SLASH_moetQOL1 = shortcut
	SlashCmdList.moetQOL = HandleSlashCommands

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