Frontline = Frontline or {}
Frontline.CategoryID_Arena = 4
Frontline.ActivityId_2v2 = 2
Frontline.ActivityId_3v3 = 3
Frontline.EventFrame = CreateFrame("Frame")
Frontline.EventFrame:RegisterEvent("ADDON_LOADED")
Frontline.EventFrame:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
Frontline.EventFrame:RegisterEvent("LFG_LIST_SEARCH_FAILED")
Frontline.EventFrame:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
Frontline.EventFrame:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")
Frontline.EventFrame:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")
Frontline.EventFrame:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
Frontline.EventFrame:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
Frontline.EventFrame:SetScript("OnEvent", function(self, event, ...)
    -- print("Frontline - " .. event)
    if event == "ADDON_LOADED" then
        FrontlineDb = FrontlineDb or {}
        for _,catId in pairs(C_LFGList.GetAvailableCategories()) do
            if catId then
                local cat = C_LFGList.GetLfgCategoryInfo(catId)
                if cat and cat.name == "竞技场" then
                    Frontline.CategoryID_Arena = catId
                end
            end
        end
        for _,actId in pairs(C_LFGList.GetAvailableActivities(Frontline.CategoryID_Arena)) do
            if actId then
                local act = C_LFGList.GetActivityInfoTable(actId)
                if act and act.fullName == "竞技场（2v2）" then
                    Frontline.ActivityId_2v2 = actId
                end
                if act and act.fullName == "竞技场（3v3）" then
                    Frontline.ActivityId_3v3 = actId
                end
            end
        end
        Frontline.Init()
        Frontline.RestorePosition()
        if FrontlineFrame:IsShown() then
            Frontline.UpdatePlayer()
            Frontline.Request()
        end
    elseif event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" then
        Frontline.UpdateResult(true)
    elseif event == "LFG_LIST_SEARCH_FAILED" then
        Frontline.RefreshFailed()
    elseif event == "LFG_LIST_SEARCH_RESULT_UPDATED" then
        Frontline.UpdateResult(false)
    elseif event == "LFG_LIST_APPLICATION_STATUS_UPDATED" then
        -- Frontline.UpdateStatus(...)
        Frontline.UpdateResult(false)
    elseif event == "LFG_LIST_APPLICANT_UPDATED" then
        Frontline.UpdateApplicant(...)
    elseif event == "LFG_LIST_APPLICANT_LIST_UPDATED" then
        -- Frontline.UpdateApplicant(...)
    elseif event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" then
        Frontline.CheckApplicantActivity()
    end
end)

SLASH_FRONTLINE1 = "/fl"
SlashCmdList["FRONTLINE"] = function()
    if FrontlineFrame:IsShown() then
        FrontlineFrame:Hide()
    else
        FrontlineFrame:Show()
        Frontline.UpdatePlayer()
        Frontline.Request()
    end
end
