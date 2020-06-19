-- moet, 2020

---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns = ...
_G.moetQOLDB = moetQOLDB or {}
ns.ADDON_VERSION = GetAddOnMetadata("moetQOL", "Version")
local SHORTCUT = "/mq"
local COLOR	= "00CC0F00" -- red
local COLOR2 = "FF00FF00" -- green
local WELCOME_MESSAGE = string.format("|c%smoetQOL|r loaded: v%s - |c%s%s|r to toggle features.", COLOR, ns.ADDON_VERSION, COLOR, SHORTCUT)
local statesChanged = 0 -- avoid spamming with /reload requests
local default = ns.Core.MQdefault
--indices for state, description and associated function in default table
local STATE, DESC, FUNC, OPTION = ns.Core.STATE, ns.Core.DESC, ns.Core.FUNC, ns.Core.OPTION

---------------------------------------------------
-- CUSTOM SLASH COMMANDS
-- For special commands. If no equal key in mqCommands then
-- argument is passed to ChangeState() or ChangeOptions().
---------------------------------------------------
local mqCommands = {
	["help"] = ns.Core.PrintHelp,
	["flags"] = ns.Core.PrintFlags,
	["hardreset"] = function()
		moetQOLDB = default
		print(string.format("|c%smq:|r Database set to default, values set to Off.", COLOR))
	end,
}

---------------------------------------------------
-- FUNCTIONS
---------------------------------------------------
local function ChangeState(str)
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
end

local function ChangeOptions(str, option)
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
		print(string.format(
			"|c%smq|r: Make sure you |c%s/reload|r for the change to take effect.", 
			COLOR, COLOR2))
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

local function CheckDatabaseErrors()
	for k,v in pairs(default) do
		--create if not exist
		if not moetQOLDB[k] then
			if v[OPTION] then
				moetQOLDB[k] = {v[STATE], v[DESC], v[OPTION]}
			else
				moetQOLDB[k] = {v[STATE], v[DESC]}
			end
		end
		
		--update if outdated
		if moetQOLDB[k][DESC] and moetQOLDB[k][DESC] ~= default[k][DESC] then
			moetQOLDB[k][DESC] = default[k][DESC]
		end

		if default[k][OPTION] and (not moetQOLDB[k][OPTION] or 
		(moetQOLDB[k][OPTION] and type(moetQOLDB[k][OPTION]) ~= type(default[k][OPTION])))
		then
			moetQOLDB[k][OPTION] = default[k][OPTION]
		elseif moetQOLDB[k][OPTION] and not default[k][OPTION] then
			moetQOLDB[k][OPTION] = nil
		end
	end
end

local function Init(self, event, name)
	if name ~= "moetQOL" then return end

	-- custom slash commands
	SLASH_moetQOL1 = SHORTCUT
	SLASH_CLEAR1 = "/clear"
	SLASH_RL1 = "/rl"
	SlashCmdList.moetQOL = HandleSlashCommands
	SlashCmdList.CLEAR = function() ChatFrame1:Clear() end
	SlashCmdList.RL = function() ReloadUI() end

	CheckDatabaseErrors()
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
