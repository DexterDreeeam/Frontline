Frontline = Frontline or {}

function Frontline.ActivityId()
    if Frontline.mode == "3v3" then
        return Frontline.ActivityId_3v3
    elseif Frontline.mode == "2v2" then
        return Frontline.ActivityId_2v2
    end
    return ""
end

function Frontline.SwitchMode()
    if Frontline.mode == "3v3" then
        Frontline.mode = "2v2"
    elseif Frontline.mode == "2v2" then
        Frontline.mode = "3v3"
    end
    FrontlineFrameModeButton:SetText(Frontline.mode)
end

function Frontline.IsInActiveGroup()
    return C_LFGList.GetActiveEntryInfo() ~= nil
end

function Frontline.IsLeaderInActiveGroup()
    return Frontline.IsInActiveGroup() and UnitIsGroupLeader("player")
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
