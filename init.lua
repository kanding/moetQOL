---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns			= ... -- namespace
_G.moetQOLDB		= moetQOLDB or {} -- database
local addonVersion	= "1.0"
local color			= "00CC0F00" -- red
local color2		= "FF00FF00" -- green
local shortcut		= "/mq"
local welcomeMSG	= string.format("|c%s%s|r to turn features on/off.", color, shortcut)

local default = {
							-- value[1] = state, value[2] = description
	["maxzoom"]				= {"Off", "sets camera distance to max"},
	["hideportraitnumbers"]	= {"Off", "show/hide combat numbers on your portrait"},
	["fastloot"]			= {"Off", "faster auto looting"},
	["errormsg"]			= {"Off", "show/hide red error messages"},
	["easydelete"]			= {"Off", "remove the need to type 'delete' on rare+ items"}
}

---------------------------------------------------
-- CUSTOM SLASH COMMANDS
---------------------------------------------------
local commands = {
	["help"] = function()
		print("List of commands:")
		print("/mq |c" .. color2 .. "flags|r - to show your current settings.")
		print("/mq |c" .. color2 .. "hardreset|r - to reset all saved settings to default (off).")
		print(" ")
		for key, value in pairs(default) do
			print(string.format("/mq |c%s%s|r - %s.", color, key, value[2]))
		end
	end,

	["flags"] = function()
		print(" ")
		for key, value in pairs(moetQOLDB) do
			if (value[1] == "Off") then
				print(string.format("|c%s%s|r: %s", color, key, value[1]))
			else
				print(string.format("|c%s%s|r: |c%s%s|r", color, key, color2, value[1]))
			end
		end
	end,

	["hardreset"] = function()
		moetQOLDB = default
	end,

	["maxzoom"] = function(self)
		ChangeFlag(self)
	end,

	["hideportraitnumbers"] = function(self)
		ChangeFlag(self)
	end,
	
	["fastloot"] = function(self)
		ChangeFlag(self)
	end,

	["errormsg"] = function(self)
		ChangeFlag(self)
	end,

	["easydelete"] = function(self)
		ChangeFlag(self)
	end,

}

---------------------------------------------------
-- FUNCTIONS
---------------------------------------------------
function ChangeFlag(str)
	if (str == nil) then
		print("string was nil in ChangeState.")
		return
	end

	if (moetQOLDB[str][1] == "On") then
		moetQOLDB[str][1] = "Off"
		print("|c" .. color .. str .. "|r: Off")
	else
		moetQOLDB[str][1] = "On"
		print(string.format(
			"|c%s%s|r: |c%sOn|r - Make sure you |c%s/reload|r for the change to take effect.", 
			color, str, color2, color)
		)
	end
end

local function HandleSlashCommands(str)
	if (#str == 0) then -- player entered /mq
		commands.help()
	end

	-- figure out what the player wrote
	-- insert each word into a table and remove any spaces
	local args = {}
	local path = commands

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
				commands.help()
				return
			end
		end
	end
end

function ns:CheckDataBaseForNil()
	for key, value in pairs(default) do
		if (moetQOLDB[key] == nil) then
			moetQOLDB[key] = value
		end
	end
end

function ns:UpdateDataBaseDescriptions()
	for key, value in pairs(default) do
		if (moetQOLDB[key][2] ~= default[key][2]) then
			moetQOLDB[key][2] = default[key][2]
		end
	end
end

function ns:init(event, name)
	if (name ~= "moetQOL") then return end -- checks if the correct addon loaded

	SLASH_moetQOL1 = shortcut
	SlashCmdList.moetQOL = HandleSlashCommands

	ns.CheckDataBaseForNil()
	ns.UpdateDataBaseDescriptions()
	ns.ActivateFunctions()

	print("|c" .. color .. "moetQOL" .. "|r loaded: Version " .. addonVersion .. ".")
	print(welcomeMSG)
end

---------------------------------------------------
-- INIT
---------------------------------------------------
local addonLoadedEvents = CreateFrame("frame")
addonLoadedEvents:RegisterEvent("ADDON_LOADED")
addonLoadedEvents:SetScript("OnEvent", ns.init)