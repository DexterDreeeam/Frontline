Frontline = Frontline or {}
Frontline.TitleEditText = ""
Frontline.CommentEditText = ""
Frontline.GroupButton = "Create"

function Frontline.SetTitle(text)
    Frontline.TitleEditText = text
end

function Frontline.SetComment(text)
    Frontline.CommentEditText = text
end

function Frontline.ClearGroupButton()
    Frontline.SetGroupButton("Create")
end

function Frontline.SetGroupButton(text)
    -- print(text)
    if Frontline.GroupButton ~= text then
        Frontline.GroupButton = text
        FrontlineFrameGroupFrameGroupButton:SetText(text)
        -- Frontline.ButtonClickCountdown(
        --     FrontlineFrameGroupFrameGroupButton,
        --     2,
        --     text,
        --     function()
        --         Frontline.GroupButton = text
        --     end)
    end
end

function Frontline.OnGroupButton()
    if Frontline.GroupButton == "Create" then
        Frontline.Create()
        Frontline.SetGroupButton("List")
    elseif Frontline.GroupButton == "List" then
        Frontline.List()
        Frontline.ClearGroupButton()
    elseif Frontline.GroupButton == "Delist" then
        Frontline.Delist()
        Frontline.ClearGroupButton()
    elseif Frontline.GroupButton == "Exit" then
        Frontline.Exit()
        Frontline.ClearGroupButton()
    end
end

function Frontline.Create()
    C_LFGList.RemoveListing()

    local blizTitle = LFGListFrame.EntryCreation.Name
    Frontline.BlizTitleParent = blizTitle:GetParent()
    Frontline.blizTitleAnchor = Frontline.blizTitleAnchor or {}
    Frontline.blizTitleAnchor.point, Frontline.blizTitleAnchor.relativeTo, Frontline.blizTitleAnchor.relativePoint, 
    Frontline.blizTitleAnchor.x, Frontline.blizTitleAnchor.y = blizTitle:GetPoint()
    Frontline.blizTitleAnchor.width = blizTitle:GetWidth()
    Frontline.blizTitleAnchor.height = blizTitle:GetHeight()
    Frontline.blizTitleAnchor.isShown = blizTitle:IsShown()

    FrontlineFrameGroupFrameGroupButton.selectedCategory = Frontline.CategoryID_Arena
    FrontlineFrameGroupFrameGroupButton.selectedActivity = Frontline.ActivityId()
    blizTitle:SetParent(FrontlineFrameGroupFrameGroupButton)
    blizTitle:ClearAllPoints()
    blizTitle:SetPoint("TOP", 0, -30)
    blizTitle:SetSize(FrontlineFrameGroupFrameGroupButton:GetWidth(), FrontlineFrameGroupFrameGroupButton:GetHeight())
    blizTitle:SetScript("OnTextChanged", function(name)
        InputBoxInstructions_OnTextChanged(name)
    end)
end

function Frontline.List()
    Frontline.applicants = {}
    C_LFGList.RemoveListing()
    local blizTitle = LFGListFrame.EntryCreation.Name
    blizTitle:SetParent(Frontline.BlizTitleParent)
    blizTitle:ClearAllPoints()
    blizTitle:SetPoint(
        Frontline.blizTitleAnchor.point,
        Frontline.blizTitleAnchor.relativeTo,
        Frontline.blizTitleAnchor.relativePoint,
        Frontline.blizTitleAnchor.x,
        Frontline.blizTitleAnchor.y
    )
    blizTitle:SetSize(Frontline.blizTitleAnchor.width, Frontline.blizTitleAnchor.height)

    local createData = {
        activityIDs = { Frontline.ActivityId() },
        isCrossFactionListing = false,
        isPrivateGroup = false,
        playstyle = 1,
        requiredDungeonScore = 0,
        requiredItemLevel = 0,
        requiredPvpRating = 0,
    }
    local ok = C_LFGList.CreateListing(createData)
    C_Timer.After(0.5, function()
    Frontline.Request()
    end)
end

function Frontline.Delist()
    C_LFGList.RemoveListing()
end

function Frontline.Exit()
    LeaveParty()
end

function Frontline.ClearApplicantFrame()
    local children = {FrontlineFrameGroupFrameScrollFrameScrollChild:GetChildren()}
    for _, child in ipairs(children) do
        if child then
            child:ClearAllPoints()
            child:SetParent(nil)
            child:Hide()
        end
    end
end

function Frontline.InteractiveStatus(status)
    if status == "applied" then
        return true
    elseif status == "invited" then
        return true
    else
        return false
    end
end

function Frontline.CreateApplicantFrames()
    if Frontline.applicants == nil then
        return
    end

    Frontline.ClearApplicantFrame()

    table.sort(Frontline.applicants, function(a, b)
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

    for i,appl in ipairs(Frontline.applicants) do
        local row = CreateFrame("Frame", nil, FrontlineFrameGroupFrameScrollFrameScrollChild)
        row:SetSize(150, 36)
        row:SetPoint("TOPLEFT", 0, -40 * (i-1))
        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        if Frontline.InteractiveStatus(appl.status) then
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
                    local activityStr = Frontline.mode .. " - " .. m.rating
                    local itemLevelStr = "PVP装备：" .. m.level
                    local color = RAID_CLASS_COLORS[string.upper(m.classEn)]
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
        Frontline.FillFrameWithColorByRole(iconFrame, mem.role)
        local icon = iconFrame:CreateTexture(nil, "ARTWORK")
        local path = "Interface\\AddOns\\Frontline\\media\\Spec_"..mem.specId..".tga"
        icon:SetSize(28, 28)
        icon:SetPoint("CENTER", 0, 0)
        icon:SetTexture(path)

        local nameText = row:CreateFontString(nil, "ARTWORK", "NumberFontNormal")
        nameText:SetPoint("BOTTOMLEFT", row, "LEFT", 40, 1)
        nameText:SetText(Frontline.TruncateRealm(mem.name))
        local color = RAID_CLASS_COLORS[string.upper(mem.classEn)]
        nameText:SetTextColor(color.r, color.g, color.b)
        nameText:SetJustifyH("LEFT")
        nameText:SetWidth(150)
        nameText:SetShadowColor(0, 0, 0, 1.0)
        nameText:SetShadowOffset(2, -2)

        local ratingText = row:CreateFontString(nil, "ARTWORK", "NumberFontNormal")
        ratingText:SetPoint("TOPLEFT", row, "LEFT", 40, -1)
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
            stateIcon:SetTexture("Interface\\AddOns\\Frontline\\media\\Applicant_"..appl.status..".tga")
            stateIcon:SetAlpha(0.5)
        end
    end
end
