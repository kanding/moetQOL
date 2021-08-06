--moet 2021

local _, ns = ...
ns.Config = {}
local Config = ns.Config

local DISTANCE_BETWEEN_TABS = -14
local HEIGHT_PER_FUNCTION_ENTRY = 30
local CUSTOM_OPTION_WIDTH = 100
local TAB_LINE_ALPHA = 0.25
local CHANGES_MADE = false

---------------------------------------------------
-- WIDGET EVENT HANDLERS
---------------------------------------------------
local function Line_OnEnter(self)
    GameTooltip:Hide()
    GameTooltip:SetOwner(self, "TOP")
    GameTooltip:AddLine(self.title:GetText())
    GameTooltip:AddLine(self.desc)
    GameTooltip:Show()
end

local function Line_OnLeave(self)
    GameTooltip:Hide()
end

local function Tab_OnClick(self)
    PanelTemplates_SetTab(self:GetParent(), self:GetID())
    local scrollChild = self:GetParent().ScrollFrame:GetScrollChild()
	if scrollChild then
		scrollChild:Hide()
	end

	self:GetParent().ScrollFrame:SetScrollChild(self.content)
	self.content:Show()
end

local function DropDown_OnClick(self, frame)
    if moetQOLDB[frame.key] then
        moetQOLDB[frame.key].custom = self:GetText()
        ns.Config:UpdatePendingChanges()
        UIDropDownMenu_SetSelectedID(frame, self:GetID())
    end
end

local function ScrollFrame_OnMouseWheel(self, delta)
	local newValue = self:GetVerticalScroll() - (delta * HEIGHT_PER_FUNCTION_ENTRY);

	if newValue < 0 then
		newValue = 0
	elseif newValue > self:GetVerticalScrollRange() then
		newValue = self:GetVerticalScrollRange()
	end

	self:SetVerticalScroll(newValue)
end

local function State_OnClick(self)
    PlaySound(856)
    moetQOLDB[self.key].state = self:GetChecked()
    ns.Config:UpdatePendingChanges()

    --Update bg color based on checked
    local parent = self:GetParent()
    if parent then
        local bg = parent.Bg or nil
        if bg then
            if self:GetChecked() then
                bg:SetColorTexture(0,1,0,TAB_LINE_ALPHA)
            else
                bg:SetColorTexture(1,0,0,TAB_LINE_ALPHA)
            end
        end
    end

    --Disable custom options if any exists
    local dropdown = parent.dropdown or nil
    if dropdown then
        if self:GetChecked() then
            UIDropDownMenu_EnableDropDown(dropdown)
        else
            UIDropDownMenu_DisableDropDown(dropdown)
        end
    end

    local editbox = parent.editbox or nil
    if editbox then
        if self:GetChecked() then
            editbox:Enable()
        else
            editbox:Disable()
        end
    end
end

local function InitializeDropDownMenu(self, level)
    if not self.items then return end
    local info = UIDropDownMenu_CreateInfo()
    for k, v in pairs(self.items) do
        info = UIDropDownMenu_CreateInfo()
        info.text = v
        info.func = DropDown_OnClick
        info.arg1 = self
        UIDropDownMenu_AddButton(info, level)
    end
end

local function EditBox_OnEnterPressed(self)
    self:ClearFocus() 
end

local function EditBox_OnFocusLost(self)
    GameTooltip:Hide()
    --Update DB Key
    self:HighlightText(0,0)
    local entered = tonumber(self:GetText())
    if entered and entered >= self.min and entered <= self.max then
        ns.Config:UpdatePendingChanges()
        moetQOLDB[self.key].custom = entered
    else
        self:SetText("")
        self:Insert(moetQOLDB[self.key].custom)
    end
end

local function EditBox_OnEnable(self)
    self:SetText(moetQOLDB[self.key].custom)
end

local function EditBox_OnDisable(self)
    self:SetText(" ")
end

local function EditBox_OnFocusGained(self)
    GameTooltip:Hide()
    GameTooltip:SetOwner(self, "TOP")
    GameTooltip:AddLine("Number")
    GameTooltip:AddLine("Min: "..self.min)
    GameTooltip:AddLine("Max: "..self.max)
    GameTooltip:Show()
end

---------------------------------------------------
-- FRAME CREATION
---------------------------------------------------
function Config:UpdatePendingChanges()
    if not CHANGES_MADE then
        CHANGES_MADE = true
        cframe.changes:SetText("Pending changes! To optimize memory a /rl is required.")
    end
end

local function SortDatabaseByCategory()
    local sorted = {}
    
    for k,v in pairs(ns.Core.MQdefault) do
        if v.category then
            if not sorted[v.category] then
                sorted[v.category] = {}
            end

            if not sorted[v.category][k] then
                sorted[v.category][k] = v
            end
        else
            ns.Core:PrintMessage(string.format("%s is missing a category in DB!", k))
        end
    end

    return sorted
end


local function AddCustomOption(f, options, key)
    if options.min and options.max then
        f.editbox = CreateFrame("EditBox", f:GetName().."Edit", f, "InputBoxTemplate")
        f.editbox:SetWidth(CUSTOM_OPTION_WIDTH)
        f.editbox:SetHeight(HEIGHT_PER_FUNCTION_ENTRY)
        f.editbox:SetPoint("TOPRIGHT", f.state, "TOPLEFT")
        f.editbox:SetAutoFocus(false)
        f.editbox:SetNumeric(true)
        f.editbox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
        f.editbox:SetScript("OnEditFocusGained", EditBox_OnFocusGained)
        f.editbox:SetScript("OnEditFocusLost", EditBox_OnFocusLost)
        f.editbox:SetScript("OnEnable", EditBox_OnEnable)
        f.editbox:SetScript("OnDisable", EditBox_OnDisable)
        f.editbox.min = options.min
        f.editbox.max = options.max
        f.editbox.key = key
    else
        f.dropdown = CreateFrame("Frame", f:GetName().."Menu", f, "UIDropDownMenuTemplate")
        f.dropdown:SetPoint("TOPRIGHT", f.state, "TOPLEFT")
        f.dropdown:SetWidth(CUSTOM_OPTION_WIDTH)
        f.dropdown.items = options
        f.dropdown.key = key
        UIDropDownMenu_Initialize(f.dropdown, InitializeDropDownMenu)
        UIDropDownMenu_SetWidth(f.dropdown, f.dropdown:GetWidth(), 35)
        UIDropDownMenu_SetButtonWidth(f.dropdown, f.dropdown:GetWidth()-25)
        UIDropDownMenu_JustifyText(f.dropdown, "LEFT")
        UIDropDownMenu_SetText(f.dropdown, moetQOLDB[key].custom)
        UIDropDownMenu_SetSelectedValue(f.dropdown, moetQOLDB[key].custom)
    end
end


local function AddFunctions(parent, sorted_db_functions)
    local i = 0
    for k,v in pairs(sorted_db_functions) do
        i = i + 1
        local fname = k
        local fdesc = v.desc
        local fcustom = v.custom and moetQOLDB[k].custom or nil
        local fstate = moetQOLDB[k].state
        
        local f = CreateFrame("Frame", parent:GetName().."Line"..i, parent)
        if i == 1 then
            f:SetPoint("TOPLEFT", parent, "TOPLEFT")
        else
            f:SetPoint("TOPLEFT", parent:GetName().."Line"..(i-1), "BOTTOMLEFT")
        end

        f:SetWidth(parent:GetWidth())
        f:SetHeight(HEIGHT_PER_FUNCTION_ENTRY)
        f:SetScript("OnEnter", Line_OnEnter)
        f:SetScript("OnLeave", Line_OnLeave)

        f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal_NoShadow")
        f.title:SetPoint("LEFT", f, "LEFT")
        f.title:SetText(fname)
        f.desc = fdesc

        f.state = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
        f.state:SetPoint("RIGHT", f, "RIGHT")
        f.state:SetScript("OnClick", State_OnClick)
        f.state.key = k
        f.state:SetChecked(fstate)

        f.Bg = f:CreateTexture(nil, "BACKGROUND")
        f.Bg:SetAllPoints(true)

        if fcustom then
            AddCustomOption(f, v.custom, k)
        end

        if f.state:GetChecked() then
            f.Bg:SetColorTexture(0,1,0, TAB_LINE_ALPHA)
            if f.dropdown then UIDropDownMenu_EnableDropDown(f.dropdown) end
            if f.editbox then f.editbox:Enable() end
        else
            f.Bg:SetColorTexture(1,0,0, TAB_LINE_ALPHA)
            if f.dropdown then UIDropDownMenu_DisableDropDown(f.dropdown) end
            if f.editbox then f.editbox:Disable() end
        end
    end

    return i
end

local function AddTabs(parent)
    PanelTemplates_SetNumTabs(parent, #ns.Core.FunctionCategory)
    parent.Tabs = {}
    local db_sorted = SortDatabaseByCategory()

    for i=1, parent.numTabs do
        local name = ns.Core:GetKeyName(ns.Core.FunctionCategory, i)
        local tabName = parent:GetName()..name.."Tab"
        local tab = CreateFrame("Button", tabName, parent, "CharacterFrameTabButtonTemplate")
        tab:SetID(i)
        tab:SetText(name)
        tab:SetScript("OnClick", Tab_OnClick)

        if i == 1 then
            tab:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 3, 7);
        else
            tab:SetPoint("TOPLEFT", parent.Tabs[i-1], "TOPRIGHT", DISTANCE_BETWEEN_TABS, 0);
        end

        -- Add Content
        tab.content = CreateFrame("Frame", tabName..i.."Body", parent)
        tab.content:SetWidth(parent:GetWidth()*0.85)
        tab.content:Hide()

        local entries = AddFunctions(tab.content, db_sorted[i])
        tab.content:SetHeight(entries * HEIGHT_PER_FUNCTION_ENTRY)

        parent.Tabs[i] = tab
    end

    Tab_OnClick(parent.Tabs[1])
end

function Config:SetupConfig()
    cframe = CreateFrame("Frame", "mq_Config", UIParent, "TranslucentFrameTemplate")
    --cframe.Bg:SetTexture("Interface\\FrameGeneral\\UIFrameNecrolordBackground")
    ns.Config.Frame = cframe
    cframe:SetSize(400, 500)
    cframe:SetPoint("CENTER", 0, 50)
    cframe:SetFrameStrata("HIGH")
    cframe.title = cframe:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    cframe.title:SetPoint("CENTER", cframe:GetName().."TopBorder", "CENTER")
    cframe.title:SetText("moetQOL v"..ns.ADDON_VERSION)
    cframe:SetMovable(true)
    cframe:EnableMouse(true)
    cframe:RegisterForDrag("LeftButton")
    cframe:SetScript("OnDragStart", cframe.StartMoving)
    cframe:SetScript("OnDragStop", cframe.StopMovingOrSizing)
    tinsert(UISpecialFrames, ns.Config.Frame:GetName())

    cframe.close = CreateFrame("Button", cframe:GetName().."CloseButton", cframe, "UIPanelCloseButton")
    cframe.close:SetPoint("CENTER", cframe:GetName().."TopRightCorner", "CENTER", -5, -5)
    cframe.close:SetScript("OnClick", Config.ToggleFrame)

    cframe.changes = cframe:CreateFontString(nil, "OVERLAY", "GameFontRed")
    cframe.changes:SetPoint("CENTER", cframe:GetName().."TopBorder", "CENTER", 0, -25)

    --Scrolling
    cframe.ScrollFrame = CreateFrame("ScrollFrame", nil, cframe, "UIPanelScrollFrameTemplate")
    cframe.ScrollFrame:SetPoint("TOPLEFT", cframe:GetName().."TopLeftCorner", "BOTTOMLEFT", 20, -30)
	cframe.ScrollFrame:SetPoint("BOTTOMRIGHT", cframe:GetName(), "BOTTOMRIGHT", -35, 12)
    cframe.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)

    --Tabs and Functions
    AddTabs(cframe)

    --Interface Options
    local panel = CreateFrame("FRAME", "moetQOL_BlizzOptions")
    panel.name = "moetQOL"
    panel.configbtn = CreateFrame("Button", "ScrapButton_Panel", panel, "OptionsButtonTemplate")
    panel.configbtn:SetText("Config")
    panel.configbtn:SetPoint("CENTER", panel, "TOP", 0, -100)
    panel.configbtn:SetScript("OnClick", function()
        while CloseWindows() do end
        return Config:ToggleFrame()
    end)
    InterfaceOptions_AddCategory(panel)

    cframe:Hide()
end

function Config:ToggleFrame()
    if not cframe then Config:SetupConfig() end
    cframe:SetShown(not cframe:IsShown())
end