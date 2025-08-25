Frontline = Frontline or {}

function Frontline.ActivityId()
    if Frontline.mode == "3v3" then
        return Frontline.ActivityId_3v3
    elseif Frontline.mode == "2v2" then
        return Frontline.ActivityId_2v2
    end
    return ""
end

function Frontline.IsInActiveGroup()
    return C_LFGList.GetActiveEntryInfo() ~= nil
end

function Frontline.IsLeaderInActiveGroup()
    return Frontline.IsInActiveGroup() and UnitIsGroupLeader("player")
end

function Frontline.GetColorByClassEn(classEn)
    if classEn == nil or type(classEn) ~= "string" then
        return { r = 1, g = 1, b = 1, a = 1 }
    else
        return RAID_CLASS_COLORS[string.upper(classEn)]
    end
end

function Frontline.SavePosition()
    local left = FrontlineFrame:GetLeft()
    local top = FrontlineFrame:GetTop()
    FrontlineDb = FrontlineDb or {}
    FrontlineDb.left = left
    FrontlineDb.top = top
    FrontlineDb.collapse = Frontline.collapse
end

function Frontline.RestorePosition()
    FrontlineFrame:ClearAllPoints()
    FrontlineFrame:SetPoint(
        "TOPLEFT",
        UIParent,
        "BOTTOMLEFT",
        FrontlineDb.left or 400,
        FrontlineDb.top or 1000)
end

function Frontline.RestoreFrame()
    Frontline.collapse = FrontlineDb.collapse
    Frontline.SwitchCollapse(false)
end

function Frontline.FillFrameWithColorByRole(f, role)
    local border = f:CreateTexture(nil, "BACKGROUND")
    border:SetAllPoints()
    border:SetTexture("Interface\\Buttons\\WHITE8X8")
    alpha = 1.0
    if role == nil then
        border:SetColorTexture(0, 0, 0, 0.8)
    elseif role == "DAMAGER" then
        border:SetColorTexture(0.5, 0, 0, 1)
    elseif role == "HEALER" then
        border:SetColorTexture(0, 0.5, 0, 1)
    else
        border:SetColorTexture(0, 0, 0.5, 1)
    end
end

function Frontline.ButtonClickCountdown(button, dur, text, cb)
    button:SetText(tostring(dur))
    button:Disable()
    local countdown = dur
    local ticker
    ticker = C_Timer.NewTicker(1, function()
        countdown = countdown - 1
        if countdown > 0 then
            button:SetText(tostring(countdown))
        else
            ticker:Cancel()
            button:SetText(text)
            if cb then
                cb()
            end
            button:Enable()
        end
    end, dur)
end