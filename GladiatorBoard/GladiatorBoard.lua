GladiatorBoard = GladiatorBoard or {}
GladiatorBoard.CategoryID_Arena = 4
GladiatorBoard.ActivityId_2v2 = 6
GladiatorBoard.ActivityId_3v3 = 7
GladiatorBoard.EventFrame = CreateFrame("Frame")
GladiatorBoard.EventFrame:RegisterEvent("ADDON_LOADED")
GladiatorBoard.EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
GladiatorBoard.EventFrame:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED")
GladiatorBoard.EventFrame:RegisterEvent("LFG_LIST_SEARCH_FAILED")
GladiatorBoard.EventFrame:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED")
GladiatorBoard.EventFrame:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE")
GladiatorBoard.EventFrame:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")
GladiatorBoard.EventFrame:RegisterEvent("LFG_LIST_APPLICANT_UPDATED")
GladiatorBoard.EventFrame:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
GladiatorBoard.EventFrame:SetScript("OnEvent", function(self, event, ...)
    -- print("GladiatorBoard - " .. event)
    if event == "ADDON_LOADED" then
        GladiatorBoardDb = GladiatorBoardDb or {}
        GladiatorBoard.GetActivities()
        GladiatorBoard.Init()
        GladiatorBoard.RestoreFrame()
        if GladiatorBoardFrame:IsShown() then
            GladiatorBoard.Request()
        end
    elseif event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" then
        GladiatorBoard.UpdateResult(true)
    elseif event == "LFG_LIST_SEARCH_FAILED" then
        GladiatorBoard.RefreshFailed()
    elseif event == "LFG_LIST_SEARCH_RESULT_UPDATED" then
        GladiatorBoard.UpdateResult(false)
    elseif event == "LFG_LIST_APPLICATION_STATUS_UPDATED" then
        -- GladiatorBoard.UpdateStatus(...)
        GladiatorBoard.UpdateResult(false)
    elseif event == "LFG_LIST_APPLICANT_UPDATED" then
        GladiatorBoard.UpdateApplicant(...)
    elseif event == "LFG_LIST_APPLICANT_LIST_UPDATED" then
        -- GladiatorBoard.UpdateApplicant(...)
    elseif event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" then
        GladiatorBoard.CheckApplicantActivity()
    elseif event == "GROUP_ROSTER_UPDATE" then
        GladiatorBoard.CheckApplicantActivity()
    end
end)

SLASH_GladiatorBoard1 = "/fl"
SlashCmdList["GladiatorBoard"] = function()
    if GladiatorBoardFrame:IsShown() then
        GladiatorBoardFrame:Hide()
    else
        GladiatorBoardFrame:Show()
        GladiatorBoard.Request()
    end
end

SLASH_GLADIATORBOARD1 = "/gb"
SlashCmdList["GLADIATORBOARD"] = function()
    if GladiatorBoardFrame:IsShown() then
        GladiatorBoardFrame:Hide()
    else
        GladiatorBoardFrame:Show()
        GladiatorBoard.Request()
    end
end
