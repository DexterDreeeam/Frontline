Frontline = Frontline or {}
Frontline.collapse = false
Frontline.refreshing = false
Frontline.mode = "3v3"
Frontline.resultIds = {}
Frontline.groups = {}
Frontline.status = {}
Frontline.inGroup = false
Frontline.isGroupLeader = false
Frontline.applicants = {}

function Frontline.Init()
    FrontlineFrameRefreshButton:SetText("Refresh")
    FrontlineFrameModeButton:SetText(Frontline.mode)
end

function Frontline.SavePosition()
    local point, relativeTo, relativePoint, x, y = FrontlineFrame:GetPoint()
    FrontlineDb.pos = FrontlineDb.pos or {}
    FrontlineDb.pos.point = point
    FrontlineDb.pos.relativeTo = relativeTo
    FrontlineDb.pos.relativePoint = relativePoint
    FrontlineDb.pos.x = x
    FrontlineDb.pos.y = y
    FrontlineDb.collapse = Frontline.collapse
end

function Frontline.RestorePosition()
    FrontlineFrame:ClearAllPoints()
    Frontline.collapse = FrontlineDb.collapse
    Frontline.SwitchCollapse(false)
    if FrontlineDb.pos == nil then
        FrontlineDb.pos = {}
        FrontlineDb.pos.point = "TOPLEFT"
        -- FrontlineDb.pos.relativeTo = "UIParent"
        FrontlineDb.pos.relativePoint = "TOPLEFT"
        FrontlineDb.pos.x = 400
        FrontlineDb.pos.y = -200
    end
    FrontlineFrame:SetPoint(
        FrontlineDb.pos.point,
        FrontlineDb.pos.relativeTo,
        FrontlineDb.pos.relativePoint,
        FrontlineDb.pos.x,
        FrontlineDb.pos.y)
end

function Frontline.HideAllFrames()
    for i = 1, FrontlineFrame:GetNumRegions() do
        local region = select(i, FrontlineFrame:GetRegions())
        if region then
            region:Hide()
        end
    end
    for _, child in ipairs({FrontlineFrame:GetChildren()}) do
        child:Hide()
    end
    FrontlineFrame.Background:Show()
    FrontlineFrameCollapseButton:Show()
    FrontlineDb.collapse = Frontline.collapse
end

function Frontline.ShowAllFrames()
    for i = 1, FrontlineFrame:GetNumRegions() do
        local region = select(i, FrontlineFrame:GetRegions())
        if region then
            region:Show()
        end
    end
    for _, child in ipairs({FrontlineFrame:GetChildren()}) do
        child:Show()
    end
    FrontlineDb.collapse = Frontline.collapsea 
end

function Frontline.SwitchCollapse(switch)
    if switch == true then
        Frontline.collapse = not Frontline.collapse
    end
    if Frontline.collapse then
        Frontline.HideAllFrames()
        FrontlineFrame:SetSize(200, 50)
        FrontlineFrameCollapseButton:SetText("Expand")
    else
        FrontlineFrame:SetSize(800, 650)
        Frontline.ShowAllFrames()
        FrontlineFrameCollapseButton:SetText("Collapse")
    end
end

function Frontline.UpdateResult(cleanup)
    if cleanup == true then
        Frontline.resultIds = {}
        Frontline.status = {}
    end
    Frontline.Clear()
    Frontline.ProcessResult()
end

function Frontline.UpdateStatus(id, status)
    Frontline.status = Frontline.status or {}
    Frontline.status[id] = status
    for _,g in pairs(Frontline.groups) do
        if g.id == id then
            g.status = status
            -- Frontline.UpdateStateIcon(g)
        end
    end
end

function Frontline.ProcessResult()
    local _, results = C_LFGList.GetSearchResults()
    local list = {}
    local merged = {}
    for resultId,g in pairs(Frontline.groups) do
        if g.rating >= 0 then
            merged[resultId] = g.rating
        else
            merged[resultId] = true
        end
    end
    for _,resultId in pairs(results) do
        merged[resultId] = true
    end
    Frontline.resultIds = merged
    for resultId,val in pairs(Frontline.resultIds) do
        local result = C_LFGList.GetSearchResultInfo(resultId)
        local group = {
            id = result.searchResultID,
            title = result.name,
            comment = result.comment,
            leader = result.leaderName,
            rating = Frontline.GetLeaderRating(result),
            members = Frontline.GetMembersInfo(result),
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
            if actId == Frontline.ActivityId_2v2 then
                group.type = "2v2"
                group.max_mem = 2
            elseif actId == Frontline.ActivityId_3v3 then
                group.type = "3v3"
                group.max_mem = 3
            end
        end
        local _,status = C_LFGList.GetApplicationInfo(resultId)
        group.status = status
        if group.type then
            table.insert(Frontline.groups, group)
        end
    end
    Frontline.SortGroups()
    local row_num = 1
    Frontline.inGroup = false
    Frontline.isGroupLeader = false
    for i,g in ipairs(Frontline.groups) do
        if g.hasSelf then
            Frontline.inGroup = true
            Frontline.isGroupLeader = UnitIsGroupLeader("player") or false
        end
        if g.type == Frontline.mode then
            Frontline.CreateGroupFrame(row_num, g)
            row_num = row_num + 1
        end
    end
    Frontline.refreshing = false
    FrontlineFrameRefreshButton:SetText("Refresh")
end

function Frontline.RefreshFailed()
    Frontline.Clear()
    if Frontline.failedText ~= nil then
        Frontline.failedText:Show()
    else
        Frontline.failedText = FrontlineFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
        Frontline.failedText:SetPoint("CENTER", -80, 0)
        Frontline.failedText:SetText("Search Failed")
        Frontline.failedText:SetJustifyH("CENTER")
        Frontline.failedText:SetWidth(400)
        Frontline.failedText:SetShadowColor(0, 0, 0, 1.0)
        Frontline.failedText:SetShadowOffset(2, -2)
    end
end

function Frontline.Clear()
    Frontline.groups = {}
    if Frontline.failedText ~= nil then
        Frontline.failedText:Hide()
    end
    local children = {FrontlineFrameScrollFrameScrollChild:GetChildren()}
    for _, child in ipairs(children) do
        if child then
            child:ClearAllPoints()
            child:SetParent(nil)
            child:Hide()
        end
    end
    FrontlineFrameScrollFrame:SetVerticalScroll(0)
    FrontlineFrameRefreshButton:SetText("Refresh")
    Frontline.refreshing = false
end

function Frontline.UpdatePlayer()
    Frontline.ClearPlayer()
    Frontline.CreatePlayerFrame()
end

function Frontline.Request()
    if Frontline.refreshing then
        return
    end
    Frontline.Clear()
    Frontline.refreshing = true
    FrontlineFrameRefreshButton:SetText("Loading...")
    C_LFGList.Search(Frontline.CategoryID_Arena)
end

function Frontline.CheckApplicantActivity()
    if not Frontline.IsInActiveGroup() then
        Frontline.ClearApplicantFrame()
        return
    end
end

function Frontline.UpdateApplicant(applicantId)
    local applicantData = C_LFGList.GetApplicantInfo(applicantId)
    local cur_appl = {
        id = applicantId,
        status = applicantData.applicationStatus,
        comment = applicantData.comment,
    }
    for i = 1, applicantData.numMembers do
        local name,classEn,class,_,_,_,_,_,_,role,_,_,level,_,_,specId,_ = C_LFGList.GetApplicantMemberInfo(applicantId, i)
        local _,specLoc = GetSpecializationInfoByID(specId)
        local pvp = C_LFGList.GetApplicantPvpRatingInfoForListing(applicantId, i, Frontline.ActivityId())
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
    for i, appl in ipairs(Frontline.applicants) do
        if appl.id == applicantId then
            Frontline.applicants[i] = cur_appl
            Frontline.CreateApplicantFrames()
            return
        end
    end
    table.insert(Frontline.applicants, cur_appl)
    Frontline.CreateApplicantFrames()
end
