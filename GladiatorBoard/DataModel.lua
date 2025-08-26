GladiatorBoard = GladiatorBoard or {}
GladiatorBoard.collapse = false
GladiatorBoard.refreshing = false
GladiatorBoard.mode = "3v3"
GladiatorBoard.resultIds = {}
GladiatorBoard.groups = {}
GladiatorBoard.status = {}
GladiatorBoard.inGroup = false
GladiatorBoard.isGroupLeader = false
GladiatorBoard.applicants = {}

function GladiatorBoard.Init()
    GladiatorBoardFrameRefreshButton:SetText("Refresh")
    GladiatorBoard.mode = GladiatorBoardDb.mode or "3v3"
    GladiatorBoardFrameModeButton:SetText(GladiatorBoard.mode)
end

function GladiatorBoard.SwitchMode()
    if GladiatorBoard.mode == "3v3" then
        GladiatorBoard.mode = "2v2"
    elseif GladiatorBoard.mode == "2v2" then
        GladiatorBoard.mode = "3v3"
    end
    GladiatorBoardFrameModeButton:SetText(GladiatorBoard.mode)
    GladiatorBoardDb.mode = GladiatorBoard.mode
    GladiatorBoard.Request()
end

function GladiatorBoard.HideAllFrames()
    for i = 1, GladiatorBoardFrame:GetNumRegions() do
        local region = select(i, GladiatorBoardFrame:GetRegions())
        if region then
            region:Hide()
        end
    end
    for _, child in ipairs({GladiatorBoardFrame:GetChildren()}) do
        child:Hide()
    end
    GladiatorBoardFrame.Background:Show()
    GladiatorBoardFrameCollapseButton:Show()
    GladiatorBoardDb.collapse = GladiatorBoard.collapse
end

function GladiatorBoard.ShowAllFrames()
    for i = 1, GladiatorBoardFrame:GetNumRegions() do
        local region = select(i, GladiatorBoardFrame:GetRegions())
        if region then
            region:Show()
        end
    end
    for _, child in ipairs({GladiatorBoardFrame:GetChildren()}) do
        child:Show()
    end
    GladiatorBoardDb.collapse = GladiatorBoard.collapsea 
end

function GladiatorBoard.SwitchCollapse(switch)
    if switch == true then
        GladiatorBoard.collapse = not GladiatorBoard.collapse
    end
    if GladiatorBoard.collapse then
        GladiatorBoard.HideAllFrames()
        GladiatorBoardFrame:SetSize(160, 50)
        GladiatorBoardFrameCollapseButton:SetText("Board")
    else
        GladiatorBoardFrame:SetSize(800, 650)
        GladiatorBoard.ShowAllFrames()
        GladiatorBoardFrameCollapseButton:SetText("Collapse")
    end
    GladiatorBoard.RestorePosition()
    if switch == true and not GladiatorBoard.collapse then
        GladiatorBoard.Request()
    else
        GladiatorBoard.CheckApplicantActivity()
    end
end

function GladiatorBoard.UpdateResult(cleanup)
    if GladiatorBoard.updateResultRunning then
        return
    end
    GladiatorBoard.updateResultRunning = true
    C_Timer.After(0.5, function()
        if cleanup == true then
            GladiatorBoard.resultIds = {}
            GladiatorBoard.status = {}
            GladiatorBoard.groups = {}
        end
        GladiatorBoard.Clear()
        GladiatorBoard.ProcessResult()
        GladiatorBoard.updateResultRunning = false
    end)
end

function GladiatorBoard.UpdateStatus(id, status)
    GladiatorBoard.status = GladiatorBoard.status or {}
    GladiatorBoard.status[id] = status
    for _,g in pairs(GladiatorBoard.groups) do
        if g.id == id then
            g.status = status
            -- GladiatorBoard.UpdateStateIcon(g)
        end
    end
end

function GladiatorBoard.ProcessResult()
    local _, results = C_LFGList.GetSearchResults()
    local merged = {}
    for resultId,g in pairs(GladiatorBoard.groups) do
        if g.rating >= 0 then
            merged[resultId] = g.rating
        else
            merged[resultId] = true
        end
    end
    for _,resultId in pairs(results) do
        merged[resultId] = true
    end
    GladiatorBoard.resultIds = merged
    for resultId,val in pairs(GladiatorBoard.resultIds) do
        if resultId and type(resultId) == "number" and resultId > 0 then
            local _,status = C_LFGList.GetApplicationInfo(resultId)
            if status then
                local result = C_LFGList.GetSearchResultInfo(resultId)
                local group = {
                    id = result.searchResultID,
                    title = result.name,
                    comment = result.comment,
                    leader = result.leaderName,
                    rating = GladiatorBoard.GetLeaderRating(result),
                    members = GladiatorBoard.GetMembersInfo(result),
                    friends = result.numBNetFriends or 0,
                    hasSelf = result.hasSelf or false,
                    delist = result.isDelisted or false,
                }
                if type(val) == "number" then
                    group.originRating = val
                else
                    group.originRating = group.rating
                end
                for _,actId in pairs(result.activityIDs) do
                    if actId == GladiatorBoard.ActivityId_2v2 then
                        group.type = "2v2"
                        group.max_mem = 2
                    elseif actId == GladiatorBoard.ActivityId_3v3 then
                        group.type = "3v3"
                        group.max_mem = 3
                    end
                end
                -- local _,status = C_LFGList.GetApplicationInfo(resultId)
                group.status = status
                if group.type then
                    table.insert(GladiatorBoard.groups, group)
                end
            end
        end
    end
    GladiatorBoard.SortGroups()
    local row_num = 1
    GladiatorBoard.inGroup = false
    GladiatorBoard.isGroupLeader = false
    for i,g in ipairs(GladiatorBoard.groups) do
        if g.hasSelf then
            GladiatorBoard.inGroup = true
            GladiatorBoard.isGroupLeader = UnitIsGroupLeader("player") or false
        end
        if g.type == GladiatorBoard.mode then
            GladiatorBoard.CreateGroupFrame(row_num, g)
            row_num = row_num + 1
        end
    end
end

function GladiatorBoard.RefreshFailed()
    GladiatorBoard.Clear()
    if GladiatorBoard.failedText ~= nil then
        GladiatorBoard.failedText:Show()
    else
        GladiatorBoard.failedText = GladiatorBoardFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
        GladiatorBoard.failedText:SetPoint("CENTER", -80, 0)
        GladiatorBoard.failedText:SetText("Search Failed")
        GladiatorBoard.failedText:SetJustifyH("CENTER")
        GladiatorBoard.failedText:SetWidth(400)
        GladiatorBoard.failedText:SetShadowColor(0, 0, 0, 1.0)
        GladiatorBoard.failedText:SetShadowOffset(2, -2)
    end
end

function GladiatorBoard.Clear()
    GladiatorBoard.groups = {}
    if GladiatorBoard.failedText ~= nil then
        GladiatorBoard.failedText:Hide()
    end
    local children = {GladiatorBoardFrameScrollFrameScrollChild:GetChildren()}
    for _, child in ipairs(children) do
        if child then
            child:ClearAllPoints()
            child:SetParent(nil)
            child:Hide()
        end
    end
    GladiatorBoardFrameScrollFrame:SetVerticalScroll(0)
    GladiatorBoardFrameRefreshButton:SetText("Refresh")
end

function GladiatorBoard.UpdatePlayer()
    GladiatorBoard.ClearPlayer()
    GladiatorBoard.CreatePlayerFrame()
end

function GladiatorBoard.Request()
    -- print("----Request")
    GladiatorBoard.UpdatePlayer()
    GladiatorBoard.CheckApplicantActivity()
    if GladiatorBoard.refreshing then
        return
    end
    GladiatorBoard.refreshing = true
    GladiatorBoard.GetActivities()
    GladiatorBoardFrameModeButton:Disable()
    GladiatorBoardFrameGroupFrameGroupButton:Disable()
    GladiatorBoard.ButtonClickCountdown(GladiatorBoardFrameRefreshButton, 2, "Refresh", function()
        GladiatorBoard.refreshing = false
        GladiatorBoardFrameModeButton:Enable()
        GladiatorBoardFrameGroupFrameGroupButton:Enable()
    end)
    GladiatorBoard.Clear()
    C_LFGList.Search(GladiatorBoard.CategoryID_Arena)
end

function GladiatorBoard.CheckApplicantActivity()
    if GladiatorBoard.mode == "3v3" and GetNumGroupMembers() == 3 then
        GladiatorBoard.SetGroupButton("Queue")
    elseif GladiatorBoard.mode == "2v2" and GetNumGroupMembers() == 2 then
        GladiatorBoard.SetGroupButton("Queue")
    elseif GladiatorBoard.IsInActiveGroup() then
        if GladiatorBoard.IsLeaderInActiveGroup() then
            GladiatorBoard.SetGroupButton("Delist")
        else
            GladiatorBoard.SetGroupButton("Exit")
        end
    else
        GladiatorBoard.ClearApplicantFrame()
        GladiatorBoard.ClearGroupButton()
    end
end

function GladiatorBoard.UpdateApplicant(applicantId)
    local applicantData = C_LFGList.GetApplicantInfo(applicantId)
    local cur_appl = {
        id = applicantId,
        status = applicantData.applicationStatus,
        comment = applicantData.comment,
    }
    for i = 1, applicantData.numMembers do
        local name,classEn,class,_,_,_,_,_,_,role,_,_,level,_,_,specId,_ = C_LFGList.GetApplicantMemberInfo(applicantId, i)
        local _,specLoc = GetSpecializationInfoByID(specId)
        local pvp = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantId, i, GladiatorBoard.ActivityId())
        local rating = 0
        if pvp then
            rating = pvp.rating or 0
        end
        local mem = {
            ["applicantId"] = applicantId,
            ["index"] = i,
            ["name"] = name,
            ["role"] = role,
            ["level"] = string.format("%.1f", level),
            ["class"] = class,
            ["classEn"] = classEn,
            ["specLoc"] = specLoc,
            ["specId"] = specId,
            ["rating"] = rating,
        }
        cur_appl[i] = mem
    end
    for i, appl in ipairs(GladiatorBoard.applicants) do
        if appl.id == applicantId then
            GladiatorBoard.applicants[i] = cur_appl
            GladiatorBoard.CreateApplicantFrames()
            return
        end
    end
    table.insert(GladiatorBoard.applicants, cur_appl)
    GladiatorBoard.CreateApplicantFrames()
end
