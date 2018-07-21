---------------------------------------------------
-- TODO
---------------------------------------------------
-- remove class colouring in chat
-- add FPS / garbage collector / MS , rInfoStrings replacement
-- easy delete confirm

---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns			= ... -- namespace
ns.Core				= {} -- add the core to the namespace

---------------------------------------------------
-- FUNCTIONS (see helper functions below)
---------------------------------------------------

function ns:ActivateFunctions()
	-- CAMERA ZOOM
	if (moetQOLDB["maxzoom"][1] == "On") then
		SetCVar("cameraDistanceMaxZoomFactor", 2.6)
	end

	-- HIDE PORTRAIT NUMBERS
	if (moetQOLDB["hideportraitnumbers"][1] == "On") then
		ns.HidePortraitNumbers()
	end

	-- ENABLE FASTER AUTO LOOT
	if (moetQOLDB["fastloot"][1] == "On") then
		ns.EnableFastLoot()
	end

	-- DISABLE UI_ERROR_MESSAGES, NOTE: This still shows UI_INFO_MESSAGES
	if (moetQOLDB["errormsg"][1] == "On") then
		UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	end

	-- EASY DELETE CONFIRM modified by moet
	-- written by Kesava-Auchindoun, all credits go to creator
	if (moetQOLDB["easydelete"][1] == "On") then
		ns.EnableEasyDelete()
	end
end

---------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------

function ns:HidePortraitNumbers()
	PlayerHitIndicator.Show = function() end
	PetHitIndicator.Show = function() end
	CombatFeedback_OnCombatEvent = function() end
end

function ns:EnableFastLoot()
	SetCVar("autoLootDefault", "1") -- set auto loot to enabled

	local tDelay = 0 -- Time delay

	local function FastLoot()
		if GetTime() - tDelay >= 0.3 then
			tDelay = GetTime()
 				if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
					for i = GetNumLootItems(), 1, -1 do
						LootSlot(i)
					end
				tDelay = GetTime()
			end
		end
	end

	local lootEventFrame = CreateFrame("Frame")
	lootEventFrame:RegisterEvent("LOOT_READY")
	lootEventFrame:SetScript("OnEvent", FastLoot)
end

-- rework so its not a function within a function
function ns:EnableEasyDelete()
	local deleteFrame = CreateFrame('Frame','EasyDeleteConfirmFrame')

	function deleteFrame:DELETE_ITEM_CONFIRM(...) -- cant be local, calls to global
		if StaticPopup1EditBox:IsShown() then
			StaticPopup1EditBox:Hide()
			StaticPopup1Button1:Enable()

			local link = select(3,GetCursorInfo())

			deleteFrame.link:SetText(link)
			deleteFrame.link:Show()
		end
	end

	-- create item link container
	deleteFrame.link = StaticPopup1:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	deleteFrame.link:SetPoint('CENTER', StaticPopup1EditBox)
	deleteFrame.link:Hide()

	StaticPopup1:HookScript('OnHide', function(self)
		deleteFrame.link:Hide()
	end)

	deleteFrame:SetScript('OnEvent', function(self,event,...)
		self[event](self,...)
	end)

	deleteFrame:RegisterEvent('DELETE_ITEM_CONFIRM')
end
