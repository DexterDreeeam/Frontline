GladiatorBoard = GladiatorBoard or {}
GladiatorBoardDb = GladiatorBoardDb or {}

function GladiatorBoard.GetActivities()
    for _,catId in pairs(C_LFGList.GetAvailableCategories()) do
        if catId then
            local cat = C_LFGList.GetLfgCategoryInfo(catId)
            if cat and cat.name == "竞技场" then
                GladiatorBoard.CategoryID_Arena = catId
            end
        end
    end
    for _,actId in pairs(C_LFGList.GetAvailableActivities(GladiatorBoard.CategoryID_Arena)) do
        if actId then
            local act = C_LFGList.GetActivityInfoTable(actId)
            if act and act.fullName == "竞技场（2v2）" then
                GladiatorBoard.ActivityId_2v2 = actId
            end
            if act and act.fullName == "竞技场（3v3）" then
                GladiatorBoard.ActivityId_3v3 = actId
            end
        end
    end
end

function GladiatorBoard.ActivityId()
    if GladiatorBoard.ActivityId_3v3 == nil or GladiatorBoard.ActivityId_2v2 == nil then
        GladiatorBoard.GetActivities()
    end
    if GladiatorBoard.mode == "3v3" then
        return GladiatorBoard.ActivityId_3v3
    elseif GladiatorBoard.mode == "2v2" then
        return GladiatorBoard.ActivityId_2v2
    end
    return 3
end

function GladiatorBoard.IsInActiveGroup()
    return C_LFGList.GetActiveEntryInfo() ~= nil
end

function GladiatorBoard.IsLeaderInActiveGroup()
    return GladiatorBoard.IsInActiveGroup() and UnitIsGroupLeader("player")
end

function GladiatorBoard.GetColorByClassEn(classEn)
    if classEn == nil or type(classEn) ~= "string" then
        return { r = 1, g = 1, b = 1, a = 1 }
    else
        return RAID_CLASS_COLORS[string.upper(classEn)]
    end
end

function GladiatorBoard.TestPrint()
    local left = GladiatorBoardFrame:GetLeft()
    local top = GladiatorBoardFrame:GetTop()
    print("Left:"..left..",Top:"..top)
    print("Db.Left:"..GladiatorBoardDb.left..",Db.Top:"..GladiatorBoardDb.top)
    print(GladiatorBoard.CategoryID_Arena, GladiatorBoard.ActivityId_2v2, GladiatorBoard.ActivityId_3v3)
end

function GladiatorBoard.SavePosition()
    local left = GladiatorBoardFrame:GetLeft()
    local top = GladiatorBoardFrame:GetTop()
    GladiatorBoardDb = GladiatorBoardDb or {}
    GladiatorBoardDb.left = left
    GladiatorBoardDb.top = top
    GladiatorBoardDb.collapse = GladiatorBoard.collapse
end

function GladiatorBoard.RestorePosition()
    GladiatorBoardFrame:ClearAllPoints()
    GladiatorBoardFrame:SetPoint(
        "TOPLEFT",
        UIParent,
        "BOTTOMLEFT",
        GladiatorBoardDb.left or 400,
        GladiatorBoardDb.top or 1000)
    GladiatorBoard.SavePosition()
end

function GladiatorBoard.RestoreFrame()
    GladiatorBoard.collapse = GladiatorBoardDb.collapse
    GladiatorBoard.SwitchCollapse(false)
end

function GladiatorBoard.FillFrameWithColorByRole(f, role)
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

function GladiatorBoard.ButtonClickCountdown(button, dur, text, cb)
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