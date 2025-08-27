GladiatorBoard = GladiatorBoard or {}
GladiatorBoardDb = GladiatorBoardDb or {}

function GladiatorBoard.ClearPlayer()
    for _,child in pairs({GladiatorBoardFramePlayerFrame:GetChildren()}) do
        if child then
            child:Hide()
            child:SetParent(nil)
            child = nil
        end
    end
end

function GladiatorBoard.CreatePlayerFrame()
    local playerFrame = CreateFrame("Frame", nil, GladiatorBoardFramePlayerFrame)
    playerFrame:SetAllPoints(GladiatorBoardFramePlayerFrame)
    playerFrame:CreateTexture(nil, "OVERLAY")

    local spec_idx = GetSpecialization()
    if spec_idx == nil then
        return
    end
    local spec_id, spec_name = GetSpecializationInfo(spec_idx)
    if spec_id == nil or spec_name == nil then
        return
    end

    local icon = playerFrame:CreateTexture(nil, "ARTWORK")
    local path = "Interface\\AddOns\\GladiatorBoard\\media\\Spec_"..spec_id..".tga"
    icon:SetSize(60, 60)
    icon:SetPoint("TOPRIGHT", playerFrame, "TOP", -4, -5)
    icon:SetTexture(path)

    local modeString = playerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    modeString:SetPoint("TOPLEFT", playerFrame, "TOP", 4, -10)
    modeString:SetText(GladiatorBoard.mode or "")
    modeString:SetJustifyH("LEFT")
    modeString:SetShadowColor(0, 0, 0, 1.0)
    modeString:SetShadowOffset(2, -2)

    local rating = 0
    local highest = 0
    local weekCnt = 0
    local weekWon = 0
    local weekRate = "0.0"
    local seasonCnt = 0
    local seasonWon = 0
    local seasonRate = "0.0"
    if GladiatorBoard.mode == "2v2" then
        rating, hightest, _, seasonCnt, seasonWon, weekCnt, weekWon = GetPersonalRatedInfo(1)
    elseif GladiatorBoard.mode == "3v3" then
        rating, hightest, _, seasonCnt, seasonWon, weekCnt, weekWon = GetPersonalRatedInfo(2)
    end
    if seasonWon and seasonCnt and seasonCnt >= 1 then
        seasonRate = string.format("%.1f", 100.0 * seasonWon / seasonCnt)
    end
    if weekWon and weekCnt and weekCnt >= 1 then
        weekRate = string.format("%.1f", 100.0 * weekWon / weekCnt)
    end
    local ratingString = playerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    ratingString:SetPoint("TOPLEFT", playerFrame, "TOP", 4, -40)
    ratingString:SetText(rating)
    ratingString:SetJustifyH("LEFT")
    ratingString:SetShadowColor(0, 0, 0, 1.0)
    ratingString:SetShadowOffset(2, -2)

    local hightestString = playerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hightestString:SetPoint("TOPRIGHT", playerFrame, "TOP", -4, -80)
    hightestString:SetText("Highest: ")
    hightestString:SetJustifyH("RIGHT")
    hightestString:SetShadowColor(0, 0, 0, 1.0)
    hightestString:SetShadowOffset(2, -2)

    local hightestScoreString = playerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hightestScoreString:SetPoint("TOPLEFT", playerFrame, "TOP", 4, -80)
    hightestScoreString:SetText(hightest)
    hightestScoreString:SetJustifyH("LEFT")
    hightestScoreString:SetShadowColor(0, 0, 0, 1.0)
    hightestScoreString:SetShadowOffset(2, -2)

    local seasonString = playerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    seasonString:SetPoint("TOPRIGHT", playerFrame, "TOP", -4, -110)
    seasonString:SetText("Season: ")
    seasonString:SetJustifyH("RIGHT")
    seasonString:SetShadowColor(0, 0, 0, 1.0)
    seasonString:SetShadowOffset(2, -2)

    local seasonScoreString = playerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    seasonScoreString:SetPoint("TOPLEFT", playerFrame, "TOP", 4, -110)
    seasonScoreString:SetText(seasonWon .. " - " .. (seasonCnt - seasonWon))
    seasonScoreString:SetJustifyH("LEFT")
    seasonScoreString:SetShadowColor(0, 0, 0, 1.0)
    seasonScoreString:SetShadowOffset(2, -2)

    local weekString = playerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    weekString:SetPoint("TOPRIGHT", playerFrame, "TOP", -4, -140)
    weekString:SetText("Weekly: ")
    weekString:SetJustifyH("RIGHT")
    weekString:SetShadowColor(0, 0, 0, 1.0)
    weekString:SetShadowOffset(2, -2)

    local weekScoreString = playerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    weekScoreString:SetPoint("TOPLEFT", playerFrame, "TOP", 4, -140)
    weekScoreString:SetText(weekWon .. " - " .. (weekCnt - weekWon))
    weekScoreString:SetJustifyH("LEFT")
    weekScoreString:SetShadowColor(0, 0, 0, 1.0)
    weekScoreString:SetShadowOffset(2, -2)

end
