Frontline = Frontline or {}
Frontline.CategoryID_Arena = 4
Frontline.ActivityId_2v2 = 2
Frontline.ActivityId_3v3 = 3
Frontline.EventFrame = CreateFrame("Frame")
Frontline.EventFrame:RegisterEvent("ADDON_LOADED")
Frontline.EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
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
        Frontline.GetActivities()
        Frontline.Init()
        Frontline.RestoreFrame()
        if FrontlineFrame:IsShown() then
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
    elseif event == "GROUP_ROSTER_UPDATE" then
        Frontline.CheckApplicantActivity()
    end
end)

SLASH_FRONTLINE1 = "/fl"
SlashCmdList["FRONTLINE"] = function()
    if FrontlineFrame:IsShown() then
        FrontlineFrame:Hide()
    else
        FrontlineFrame:Show()
        Frontline.Request()
    end
end

SLASH_GLADIATORBOARD1 = "/gb"
SlashCmdList["GLADIATORBOARD"] = function()
    if FrontlineFrame:IsShown() then
        FrontlineFrame:Hide()
    else
        FrontlineFrame:Show()
        Frontline.Request()
    end
end
