-- API compatibility helpers shared by the Retail and WoW: Forever clients.
local _, ns = ...

local function GetAddOnMetadata(addon, key)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(addon, key)
    end
    if _G.GetAddOnMetadata then
        return _G.GetAddOnMetadata(addon, key)
    end
end

local function GetNumAddOns()
    if C_AddOns and C_AddOns.GetNumAddOns then
        return C_AddOns.GetNumAddOns()
    end
    if _G.GetNumAddOns then
        return _G.GetNumAddOns()
    end
    return 0
end

local function GetAddOnInfo(index)
    if C_AddOns and C_AddOns.GetAddOnInfo then
        return C_AddOns.GetAddOnInfo(index)
    end
    if _G.GetAddOnInfo then
        return _G.GetAddOnInfo(index)
    end
end

function ns.GetAddOnMetadata(addon, key)
    return GetAddOnMetadata(addon, key)
end

function ns.GetNumAddOns()
    return GetNumAddOns()
end

function ns.GetAddOnInfo(index)
    return GetAddOnInfo(index)
end

function ns.GetMouseFocusRegions()
    if _G.GetMouseFoci then
        return _G.GetMouseFoci()
    end

    local focus = _G.GetMouseFocus and _G.GetMouseFocus()
    if focus then
        return { [0] = focus }
    end
end

function ns.GetCoinText(amount, separator)
    if C_CurrencyInfo and C_CurrencyInfo.GetCoinText then
        return C_CurrencyInfo.GetCoinText(amount, separator)
    end
    if _G.GetCoinTextureString then
        return _G.GetCoinTextureString(amount)
    end
    return tostring(amount)
end

function ns.IsSecretValue(value)
    return _G.issecretvalue and _G.issecretvalue(value) or false
end