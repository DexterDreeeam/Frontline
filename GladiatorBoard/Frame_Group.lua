GladiatorBoard = GladiatorBoard or {}
GladiatorBoard.TitleEditText = ""
GladiatorBoard.CommentEditText = ""
GladiatorBoard.GroupButton = "Create"

GladiatorBoard.FilterKeywords = {
    "要的", "顶级",
}

function GladiatorBoard.SetTitle(text)
    GladiatorBoard.TitleEditText = text
end

function GladiatorBoard.SetComment(text)
    GladiatorBoard.CommentEditText = text
end

function GladiatorBoard.ClearGroupButton()
    GladiatorBoard.SetGroupButton("Create")
end

function GladiatorBoard.SetGroupButton(text)
    if GladiatorBoard.GroupButton ~= text then
        GladiatorBoard.GroupButton = text
        GladiatorBoardFrameGroupFrameGroupButton:SetText(text)
        -- GladiatorBoard.ButtonClickCountdown(
        --     GladiatorBoardFrameGroupFrameGroupButton,
        --     2,
        --     text,
        --     function()
        --         GladiatorBoard.GroupButton = text
        --     end)
    end
end

function GladiatorBoard.OnGroupButton()
    if GladiatorBoard.GroupButton == "Create" then
        GladiatorBoard.Create()
        GladiatorBoard.SetGroupButton("List")
    elseif GladiatorBoard.GroupButton == "List" then
        GladiatorBoard.List()
        GladiatorBoard.ClearGroupButton()
    elseif GladiatorBoard.GroupButton == "Delist" then
        GladiatorBoard.Delist()
        GladiatorBoard.ClearGroupButton()
    elseif GladiatorBoard.GroupButton == "Exit" then
        GladiatorBoard.Exit()
        GladiatorBoard.ClearGroupButton()
    elseif GladiatorBoard.GroupButton == "Queue" then
        if C_PvP.IsArena() or not UnitIsGroupLeader("player") then
            return
        elseif GladiatorBoard.mode == "2v2" then
            pcall(JoinSkirmish, 4)
        elseif GladiatorBoard.mode == "3v3" then
            pcall(JoinSkirmish, 5)
        end
    end
end

function GladiatorBoard.Create()
    C_LFGList.RemoveListing()

    local blizTitle = LFGListFrame.EntryCreation.Name
    GladiatorBoard.BlizTitleParent = blizTitle:GetParent()
    GladiatorBoard.blizTitleAnchor = GladiatorBoard.blizTitleAnchor or {}
    GladiatorBoard.blizTitleAnchor.point, GladiatorBoard.blizTitleAnchor.relativeTo, GladiatorBoard.blizTitleAnchor.relativePoint, 
    GladiatorBoard.blizTitleAnchor.x, GladiatorBoard.blizTitleAnchor.y = blizTitle:GetPoint()
    GladiatorBoard.blizTitleAnchor.width = blizTitle:GetWidth()
    GladiatorBoard.blizTitleAnchor.height = blizTitle:GetHeight()
    GladiatorBoard.blizTitleAnchor.isShown = blizTitle:IsShown()

    GladiatorBoardFrameGroupFrameGroupButton.selectedCategory = GladiatorBoard.CategoryID_Arena
    GladiatorBoardFrameGroupFrameGroupButton.selectedActivity = GladiatorBoard.ActivityId()
    blizTitle:SetParent(GladiatorBoardFrameGroupFrameGroupButton)
    blizTitle:ClearAllPoints()
    blizTitle:SetPoint("TOP", 0, -30)
    blizTitle:SetSize(GladiatorBoardFrameGroupFrameGroupButton:GetWidth(), GladiatorBoardFrameGroupFrameGroupButton:GetHeight())
    blizTitle:SetScript("OnTextChanged", function(name)
        InputBoxInstructions_OnTextChanged(name)
    end)
end

function GladiatorBoard.List()
    GladiatorBoard.applicants = {}
    C_LFGList.RemoveListing()
    local blizTitle = LFGListFrame.EntryCreation.Name
    blizTitle:SetParent(GladiatorBoard.BlizTitleParent)
    blizTitle:ClearAllPoints()
    blizTitle:SetPoint(
        GladiatorBoard.blizTitleAnchor.point,
        GladiatorBoard.blizTitleAnchor.relativeTo,
        GladiatorBoard.blizTitleAnchor.relativePoint,
        GladiatorBoard.blizTitleAnchor.x,
        GladiatorBoard.blizTitleAnchor.y
    )
    blizTitle:SetSize(GladiatorBoard.blizTitleAnchor.width, GladiatorBoard.blizTitleAnchor.height)

    local createData = {
        activityIDs = { GladiatorBoard.ActivityId() },
        isCrossFactionListing = false,
        isPrivateGroup = false,
        playstyle = 1,
        requiredDungeonScore = 0,
        requiredItemLevel = 0,
        requiredPvpRating = 0,
    }
    local ok = C_LFGList.CreateListing(createData)
    C_Timer.After(0.5, function()
        GladiatorBoard.Request()
    end)
end

function GladiatorBoard.Delist()
    C_LFGList.RemoveListing()
end

function GladiatorBoard.Exit()
    LeaveParty()
end

function GladiatorBoard.ClearApplicantFrame()
    local children = {GladiatorBoardFrameGroupFrameScrollFrameScrollChild:GetChildren()}
    for _, child in ipairs(children) do
        if child then
            child:ClearAllPoints()
            child:SetParent(nil)
            child:Hide()
        end
    end
end

function GladiatorBoard.InteractiveStatus(status)
    if status == "applied" then
        return true
    elseif status == "invited" then
        return true
    else
        return false
    end
end

function GladiatorBoard.CreateApplicantFrames()
    if GladiatorBoard.applicants == nil then
        return
    end

    GladiatorBoard.ClearApplicantFrame()

    table.sort(GladiatorBoard.applicants, function(a, b)
        if a.applicantId == nil and b.applicantId then
            return false
        elseif a.applicantId == nil then
            return false
        elseif b.applicantId == nil then
            return true
        end

        if a.applicantId > b.applicantId then
            return true
        else
            return false
        end
    end)

    for i,appl in ipairs(GladiatorBoard.applicants) do
        local row = CreateFrame("Frame", nil, GladiatorBoardFrameGroupFrameScrollFrameScrollChild)
        row:SetSize(150, 36)
        row:SetPoint("TOPLEFT", 0, -40 * (i-1))
        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        if GladiatorBoard.InteractiveStatus(appl.status) then
            row:EnableMouse(true)
            row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
            row.highlight:SetAllPoints()
            row.highlight:SetColorTexture(1, 1, 1, 0.2)
            row:SetScript("OnMouseUp", function(self, button)
                if button == "LeftButton" and appl.status == "applied" then
                    C_LFGList.InviteApplicant(appl.id)
                end
            end)
            row:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                for _,m in ipairs(appl) do
                    local classSpecStr = m.class .. " - " .. m.specLoc
                    local activityStr = GladiatorBoard.mode .. " - " .. m.rating
                    local itemLevelStr = "PVP Item: " .. m.level
                    local color = GladiatorBoard.GetColorByClassEn(m.classEn)
                    GameTooltip:SetText(m.name, color.r, color.g, color.b, true)
                    GameTooltip:AddLine(classSpecStr, 0.6, 0.6, 0.6, true)
                    GameTooltip:AddLine(activityStr, 0.6, 0.6, 0.6, true)
                    GameTooltip:AddLine(itemLevelStr, 0.6, 0.6, 0.6, true)
                end
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)
            bg:SetColorTexture(0.15, 0.15, 0.15, 0.7)
        else
            local darkOverlay = row:CreateTexture(nil, "OVERLAY", nil, 5)
            darkOverlay:SetAllPoints()
            darkOverlay:SetColorTexture(0, 0, 0, 0.6)
            bg:SetColorTexture(0, 0, 0, 0.7)
        end

        local mem = appl[1]
        local iconFrame = CreateFrame("Frame", nil, row)
        iconFrame:SetSize(32, 32)
        iconFrame:SetPoint("LEFT", 4, 0)
        iconFrame:SetFrameLevel(row:GetFrameLevel() + 2)
        GladiatorBoard.FillFrameWithColorByRole(iconFrame, mem.role)
        local icon = iconFrame:CreateTexture(nil, "ARTWORK")
        local path = "Interface\\AddOns\\GladiatorBoard\\media\\Spec_"..mem.specId..".tga"
        icon:SetSize(28, 28)
        icon:SetPoint("CENTER", 0, 0)
        icon:SetTexture(path)

        local nameText = row:CreateFontString(nil, "ARTWORK", "NumberFontNormal")
        nameText:SetPoint("BOTTOMLEFT", row, "LEFT", 42, 1)
        nameText:SetText(GladiatorBoard.TruncateRealm(mem.name))
        local color = GladiatorBoard.GetColorByClassEn(mem.classEn)
        nameText:SetTextColor(color.r, color.g, color.b)
        nameText:SetJustifyH("LEFT")
        nameText:SetWidth(150)
        nameText:SetShadowColor(0, 0, 0, 1.0)
        nameText:SetShadowOffset(2, -2)

        local ratingText = row:CreateFontString(nil, "ARTWORK", "NumberFontNormal")
        ratingText:SetPoint("TOPLEFT", row, "LEFT", 44, -1)
        ratingText:SetText(mem.rating .. " - " .. mem.level)
        ratingText:SetJustifyH("LEFT")
        ratingText:SetWidth(150)
        ratingText:SetShadowColor(0, 0, 0, 1.0)
        ratingText:SetShadowOffset(2, -2)

        local stateFrame = CreateFrame("Frame", nil, row)
        stateFrame:SetSize(28, 28)
        stateFrame:SetPoint("RIGHT", -4, 0)
        stateFrame:SetFrameLevel(row:GetFrameLevel() + 2)
        local stateIcon = stateFrame:CreateTexture(nil, "ARTWORK")
        stateIcon:SetSize(20, 20)
        stateIcon:SetPoint("CENTER", 0, 0)
        stateIcon:SetAlpha(0)
        if appl.status == "invited" or
            appl.status == "declined" or
            appl.status == "declined_full" or
            appl.status == "inviteaccepted" then
            stateIcon:SetTexture("Interface\\AddOns\\GladiatorBoard\\media\\Applicant_"..appl.status..".tga")
            stateIcon:SetAlpha(0.5)
        end
    end
end
