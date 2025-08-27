GladiatorBoard = GladiatorBoard or {}
GladiatorBoard.specIcon = nil
GladiatorBoardDb = GladiatorBoardDb or {}

function GladiatorBoard.GetLeaderRating(result)
    if result.leaderPvpRatingInfo then
        for _,info in pairs(result.leaderPvpRatingInfo) do
            if info and info.rating then
                return info.rating
            end
        end
    end
    return -1
end

function GladiatorBoard.GetMembersInfo(result)
    local members = {}
    for i = 1, result.numMembers do
        local mRole,mClassEn,mClass,mSpec,mLeader = C_LFGList.GetSearchResultMemberInfo(result.searchResultID, i)
        table.insert(members, {
            index = i,
            role = mRole,
            classEn = mClassEn,
            class = mClass,
            spec = mSpec,
            leader = mLeader,
        })
    end
    table.sort(members, function(a, b)
        if a == nil and b == nil then
            return false
        elseif a ~= nil and b == nil then
            return true
        elseif a == nil and b ~= nil then
            return false
        end
        if a.leader and not b.leader then
            return true
        elseif not a.leader and b.leader then
            return false
        else
            return false
        end
    end)
    return members
end

function GladiatorBoard.TruncateTitle(text)
    return text
end

function GladiatorBoard.TruncateRealm(text)
    if not text then return "" end
    local nameOnly = text:match("^(.+)-[^-]+$") or text
    return nameOnly
end

function GladiatorBoard.SortGroups()
    table.sort(GladiatorBoard.groups, function(a, b)
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
            return (a.originRating or 0) > (b.originRating or 0)
        end

        if a.type == b.type then
            return false
        elseif a.type == GladiatorBoard.mode then
            return true
        elseif b.type == GladiatorBoard.mode then
            return false
        else
            return false
        end
    end)
end

function GladiatorBoard.GetSpecIdFromLocalizedName(member)
    local str = strlower(member.class)..strlower(member.spec)
    if GladiatorBoard.specIds ~= nil then
        return GladiatorBoard.specIds[str]
    end
    GladiatorBoard.specIds = {}
    for classId = 1, MAX_CLASSES do
        local className, classTag, classId = GetClassInfo(classId)
        local numSpecs = GetNumSpecializationsForClassID(classId)
        for specIndex = 1, numSpecs do
            local specId, specName = GetSpecializationInfoForClassID(classId, specIndex)
            GladiatorBoard.specIds[strlower(className)..strlower(specName)] = specId
        end
    end
    return GladiatorBoard.specIds[str]
end

function GladiatorBoard.SetRoleIcon(f, member, icon)
    local roleIcon = f:CreateTexture(nil, "ARTWORK", nil, 1)
    roleIcon:SetSize(22, 22)
    roleIcon:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 6, -6)

    if member.role == "HEALER" then
        roleIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
        roleIcon:SetTexCoord(0.3046875, 0.6015625, 0.015625, 0.3125)
        return
    end

    -- local specId = GladiatorBoard.GetSpecIdFromLocalizedName(member)
    -- if specId then
    --     local iconPath = "Interface\\AddOns\\GladiatorBoard\\media\\Spec_"..specId..".tga"
    --     roleIcon:SetTexture(iconPath)
    --     return
    -- end
end

function GladiatorBoard.CanGroupApply(group)
    if group.delist then
        return false
    elseif group.status == "cancelled" then
        return false
    elseif group.status == "invitedeclined" then
        return false
    else
        return true
    end
end

function GladiatorBoard.CreateGroupFrame(index, group)
    local row = CreateFrame("Frame", nil, GladiatorBoardFrameScrollFrameScrollChild)
    row:SetSize(560, 38)
    row:SetPoint("TOPLEFT", 0, -44 * (index-1))

    local bg = row:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    if group.hasSelf or group.status == "inviteaccepted" then
        bg:SetColorTexture(0.05, 0.35, 0.05, 0.7)
    elseif group.friends > 0 then
        bg:SetColorTexture(0.05, 0.15, 0.35, 0.7)
    elseif group.status == "applied" then
        bg:SetColorTexture(0.35, 0.3, 0.0, 0.7)
    else
        bg:SetColorTexture(0.15, 0.15, 0.15, 0.7)
    end
    if group.delist then
        local darkOverlay = row:CreateTexture(nil, "OVERLAY", nil, 5)
        darkOverlay:SetAllPoints()
        darkOverlay:SetColorTexture(0, 0, 0, 0.6)
    else
        row:EnableMouse(true)
        if GladiatorBoard.CanGroupApply(group) then
            row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
            row.highlight:SetAllPoints()
            row.highlight:SetColorTexture(1, 1, 1, 0.2)
            row:SetScript("OnMouseUp", function(self, button)
                if button == "LeftButton" then
                    if group.status == nil or group.status == "none" then
                        local role = UnitGroupRolesAssigned("player")
                        if role == "TANK" then
                            C_LFGList.ApplyToGroup(group.id, true, false, false)
                        elseif role == "HEALER" then
                            C_LFGList.ApplyToGroup(group.id, false, true, false)
                        else
                            C_LFGList.ApplyToGroup(group.id, false, false, true)
                        end
                    elseif group.status == "applied" then
                        C_LFGList.CancelApplication(group.id)
                    end
                elseif button == "RightButton" then
                    GladiatorBoardDb.FilteredLeaders = GladiatorBoardDb.FilteredLeaders or {}
                    GladiatorBoardDb.FilteredLeaders[group.leader] = true
                    print("|cFFFF0000[Gladiator Board] Filtered Leader: " .. group.leader)
                end
            end)
        end
        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
            GameTooltip:SetText(group.title)
            GameTooltip:AddLine(group.leader, 1, 1, 1, true)
            GameTooltip:AddLine(group.comment, 0.6, 0.6, 0.6, true)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end

    -- Column 1: Current Rating
    local ofst_x = 10
    local ratingText = row:CreateFontString(nil, "ARTWORK", "NumberFontNormalLarge")
    ratingText:SetPoint("LEFT", ofst_x - 20, 0)
    ratingText:SetText(group.rating)
    ratingText:SetJustifyH("RIGHT")
    ratingText:SetWidth(60)
    ratingText:SetShadowColor(0, 0, 0, 1.0)
    ratingText:SetShadowOffset(4, -4)
    ofst_x = ofst_x + 40
    
    -- Column 2: Leader Name
    ofst_x = ofst_x + 20
    local leaderText = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    leaderText:SetPoint("LEFT", ofst_x - 20, 0)
    leaderText:SetText(GladiatorBoard.TruncateRealm(group.leader))
    leaderText:SetJustifyH("RIGHT")
    leaderText:SetWidth(126)
    ratingText:SetShadowColor(0, 0, 0, 1.0)
    ratingText:SetShadowOffset(2, -2)
    local color = GladiatorBoard.GetColorByClassEn(group.members[1].classEn)
    if color then
        leaderText:SetTextColor(color.r, color.g, color.b)
    end
    ofst_x = ofst_x + 106

    -- Column 3: Member Class Icons
    ofst_x = ofst_x + 20
    local icon_ofst = 0
    local exists_num = 0
    for i, member in ipairs(group.members) do
        local iconFrame = CreateFrame("Frame", nil, row)
        iconFrame:SetSize(32, 32)
        iconFrame:SetPoint("LEFT", ofst_x + icon_ofst, 0)
        iconFrame:SetFrameLevel(row:GetFrameLevel() + 2)
        if group.delist then
            iconFrame:SetAlpha(0.7)
        end
        GladiatorBoard.FillFrameWithColorByRole(iconFrame, member.role)

        local specId = GladiatorBoard.GetSpecIdFromLocalizedName(member)
        local icon = iconFrame:CreateTexture(nil, "ARTWORK")
        local path = "Interface\\AddOns\\GladiatorBoard\\media\\ClassIcon_"..member.classEn..".tga"
        if member.role ~= "HEALER" and specId then
            path = "Interface\\AddOns\\GladiatorBoard\\media\\Spec_"..specId..".tga"
        end
        icon:SetSize(28, 28)
        icon:SetPoint("CENTER", 0, 0)
        icon:SetTexture(path)

        GladiatorBoard.SetRoleIcon(iconFrame, member, icon)
        exists_num = exists_num + 1
        icon_ofst = icon_ofst + 40
    end

    while exists_num < group.max_mem do
        local iconFrame = CreateFrame("Frame", nil, row)
        iconFrame:SetSize(28, 28)
        iconFrame:SetPoint("LEFT", ofst_x + icon_ofst, 0)
        GladiatorBoard.FillFrameWithColorByRole(iconFrame, nil)
        exists_num = exists_num + 1
        icon_ofst = icon_ofst + 40
    end
    ofst_x = ofst_x + 110

    -- Column 4: Group Name
    ofst_x = ofst_x + 20
    local groupText = row:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    groupText:SetPoint("LEFT", ofst_x, 0)
    groupText:SetText(GladiatorBoard.TruncateTitle(group.title))
    groupText:SetJustifyH("LEFT")
    groupText:SetTextColor(0.7, 0.7, 0.6)
    groupText:SetWidth(200)
    groupText:SetMaxLines(1)
    groupText:SetShadowColor(0, 0, 0, 1.0)
    groupText:SetShadowOffset(2, -2)
    ofst_x = ofst_x + 200

    -- Column 5: Group Status
    local stateFrame = CreateFrame("Frame", nil, row)
    stateFrame:SetSize(32, 32)
    stateFrame:SetPoint("LEFT", ofst_x, 0)
    stateFrame:SetFrameLevel(row:GetFrameLevel() + 2)
    local stateIcon = stateFrame:CreateTexture(nil, "ARTWORK")
    stateIcon:SetSize(24, 24)
    stateIcon:SetPoint("CENTER", 0, 0)
    stateIcon:SetAlpha(0)
    if group.status == "applied" or
        group.status == "invited" or
        group.status == "invitedeclined" or
        group.status == "cancelled" then
        stateIcon:SetTexture("Interface\\AddOns\\GladiatorBoard\\media\\Status_"..group.status..".tga")
        stateIcon:SetAlpha(0.7)
    end

    group.frame = row
end
