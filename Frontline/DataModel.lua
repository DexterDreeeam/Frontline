Frontline = Frontline or {}
Frontline.refreshing = false
Frontline.mode = "3v3"
Frontline.resultIds = {}
Frontline.groups = {}

function Frontline.Init()
    FrontlineFrameRefreshButton:SetText("Refresh")
    FrontlineFrameModeButton:SetText(Frontline.mode)
end

function Frontline.SwitchMode()
    if Frontline.mode == "3v3" then
        Frontline.mode = "2v2"
    elseif Frontline.mode == "2v2" then
        Frontline.mode = "3v3"
    end
    FrontlineFrameModeButton:SetText(Frontline.mode)
end

function Frontline.UpdateGroup(result)
    local index = -1
    for _,g in ipairs(Frontline.groups) do
        if g.id == result.searchResultID then
            index = g.index
        end
    end
    if index == -1 then
        
    end
end

function Frontline.UpdateResult(cleanup)
    if cleanup == true then
        Frontline.resultIds = {}
    end
    Frontline.Clear()
    Frontline.ProcessResult()
end

function Frontline.ProcessResult()
    local _, results = C_LFGList.GetSearchResults()
    local list = {}
    local merged = {}
    for resultId,_ in pairs(Frontline.groups) do
        merged[resultId] = true
    end
    for _,resultId in pairs(results) do
        merged[resultId] = true
    end
    Frontline.resultIds = merged
    for resultId,_ in pairs(Frontline.resultIds) do
        local result = C_LFGList.GetSearchResultInfo(resultId)
        local group = {
            id = result.searchResultID,
            title = result.name,
            comment = result.comment,
            leader = result.leaderName,
            rating = Frontline.GetLeaderRating(result),
            members = Frontline.GetMembersInfo(result),
            friends = result.numBNetFriends,
            hasSelf = result.hasSelf,
            delist = result.isDelisted
        }
        for _,actId in pairs(result.activityIDs) do
            if actId == Frontline.ActivityId_2v2 then
                group.type = "2v2"
                group.max_mem = 2
            elseif actId == Frontline.ActivityId_3v3 then
                group.type = "3v3"
                group.max_mem = 3
            end
        end
        if group.type then
            table.insert(Frontline.groups, group)
        end
    end
    Frontline.SortGroups()
    local row_num = 1
    for i,g in ipairs(Frontline.groups) do
        if g.type == Frontline.mode then
            g.frame = Frontline.CreateGroupFrame(row_num, g)
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

function Frontline.SortGroups()
    table.sort(Frontline.groups, function(a, b)
        if a == nil and b == nil then
            return false
        elseif a == nil then
            return false
        elseif b == nil then
            return true
        end

        if a.hasSelf then
            return true
        elseif b.hasSelf then
            return false
        end

        if a.friends > b.friends then
            return true
        elseif b.friends > a.friends then
            return false
        end

        if a.type == b.type then
            return (a.rating or 0) >= (b.rating or 0)
        end

        if a.type == Frontline.mode then
            return true
        elseif b.type == Frontline.mode then
            return false
        else
            return true
        end
    end)
end

function Frontline.Clear()
    Frontline.groups = {}
    if Frontline.failedText ~= nil then
        Frontline.failedText:Hide()
    end
    local scrollChild = FrontlineFrameScrollFrameScrollChild
    local children = {scrollChild:GetChildren()}
    for _, child in ipairs(children) do
        child:ClearAllPoints()
        child:SetParent(nil)
        child:Hide()
    end
    FrontlineFrameScrollFrame:SetVerticalScroll(0)
    scrollChild:SetHeight(1)
    Frontline.refreshing = false
    FrontlineFrameRefreshButton:SetText("Refresh")
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
