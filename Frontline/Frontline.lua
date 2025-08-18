-- Simple slash command to toggle visibility
SLASH_FRONTLINE1 = "/fl"
SlashCmdList["FRONTLINE"] = function()
    FrontlineFrame:SetShown(not FrontlineFrame:IsShown())
end