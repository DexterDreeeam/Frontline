Frontline = Frontline or {}
Frontline.refreshing = false
Frontline.mode = "Rated Arena"

function Frontline.SwitchMode()
    if Frontline.mode == "Rated Arena" then
        Frontline.mode = "3v3 Arena"
    elseif Frontline.mode == "3v3 Arena" then
        Frontline.mode = "2v2 Arena"
    elseif Frontline.mode == "2v2 Arena" then
        Frontline.mode = "Rated Arena"
    end
    FrontlineFrameModeButton:SetText(Frontline.mode)
end

function Frontline.UpdateList(list)
    Frontline.refreshing = false
    FrontlineFrameRefreshButton:SetText("Refresh")
end

function Frontline.ProcessResult(_, results)
    local list = {}
    for _,resultId in pairs(results) do
        local result = C_LFGList.GetSearchResultInfo(resultId)
        print(result.name)
    end
    Frontline.refreshing = false
    FrontlineFrameRefreshButton:SetText("Refresh")
end

function Frontline.Clear()
    Frontline.UpdateList({})
    Frontline.refreshing = false
    FrontlineFrameRefreshButton:SetText("Refresh")
end

function Frontline.Request()
    if Frontline.refreshing then
        return
    end
    Frontline.refreshing = true
    FrontlineFrameRefreshButton:SetText("Loading...")

    C_LFGList.Search(Frontline.CategoryID_Arena)
end
