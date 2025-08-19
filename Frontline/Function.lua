Frontline = Frontline or {}
Frontline.specIcon = nil

function Frontline.GetLeaderRating(result)
    if result.leaderPvpRatingInfo then
        for _,info in pairs(result.leaderPvpRatingInfo) do
            if info and info.rating then
                return info.rating
            end
        end
    end
    return -1
end

function Frontline.GetMembersInfo(result)
    local members = {}
    for i = 1, result.numMembers do
        local mRole,mClassEn,mClass,mSpec,mLeader = C_LFGList.GetSearchResultMemberInfo(result.searchResultID, i)
        table.insert(members, {
            role = mRole,
            classEn = mClassEn,
            class = mClass,
            spec = mSpec,
            leader = mLeader,
        })
    end
    return members
end

function Frontline.TruncateTitle(text)
    return text
end

function Frontline.TruncateRealm(text)
    if not text then return "" end
    local nameOnly = text:match("^(.+)-[^-]+$") or text
    return nameOnly
end

function Frontline.GetSpecIdFromLocalizedName(member)
    local str = strlower(member.class)..strlower(member.spec)
    if Frontline.specIds ~= nil then
        return Frontline.specIds[str]
    end
    Frontline.specIds = {}
    for classId = 1, MAX_CLASSES do
        local className, classTag, classId = GetClassInfo(classId)
        local numSpecs = GetNumSpecializationsForClassID(classId)
        for specIndex = 1, numSpecs do
            local specId, specName = GetSpecializationInfoForClassID(classId, specIndex)
            Frontline.specIds[strlower(className)..strlower(specName)] = specId
        end
    end
    return Frontline.specIds[str]
end

function Frontline.SetRoleIcon(f, member, icon)
    local roleIcon = f:CreateTexture(nil, "ARTWORK", nil, 1)
    roleIcon:SetSize(22, 22)
    roleIcon:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 6, -6)

    if member.role == "HEALER" then
        roleIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
        roleIcon:SetTexCoord(0.3046875, 0.6015625, 0.015625, 0.3125)
        return
    end

    -- local specId = Frontline.GetSpecIdFromLocalizedName(member)
    -- if specId then
    --     local iconPath = "Interface\\AddOns\\Frontline\\media\\Spec_"..specId..".tga"
    --     roleIcon:SetTexture(iconPath)
    --     return
    -- end
end

function Frontline.CreateGroupFrame(index, group)
    local row = CreateFrame("Frame", nil, FrontlineFrameScrollFrameScrollChild)
    row:SetSize(560, 36)
    row:SetPoint("TOPLEFT", 0, -42 * (index-1))

    if group.delist then
        local darkOverlay = row:CreateTexture(nil, "OVERLAY", nil, 5)
        darkOverlay:SetAllPoints()
        darkOverlay:SetColorTexture(0, 0, 0, 0.65)
    else
        row:EnableMouse(true)
        row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
        row.highlight:SetAllPoints()
        row.highlight:SetColorTexture(1, 1, 1, 0.2)
        row:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" then
                print(group.leader)
                -- C_LFGList.ApplyToGroup(group.id)
            end
        end)
        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        if group.hasSelf then
            bg:SetColorTexture(0.05, 0.35, 0.05, 0.7)
        elseif group.friends > 0 then
            bg:SetColorTexture(0.25, 0.35, 0.05, 0.7)
        else
            bg:SetColorTexture(0.15, 0.15, 0.15, 0.7)
        end
    end

    -- Column 1: Current Rating
    local ofst_x = 10
    local ratingText = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    ratingText:SetPoint("LEFT", ofst_x, 0)
    ratingText:SetText(group.rating)
    ratingText:SetJustifyH("RIGHT")
    ratingText:SetWidth(36)
    ofst_x = ofst_x + 36
    
    -- Column 2: Leader Name
    ofst_x = ofst_x + 20
    local leaderText = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    leaderText:SetPoint("LEFT", ofst_x, 0)
    leaderText:SetText(Frontline.TruncateRealm(group.leader))
    leaderText:SetJustifyH("RIGHT")
    leaderText:SetWidth(100)
    local color = RAID_CLASS_COLORS[string.upper(group.members[1].classEn)]
    if color then
        leaderText:SetTextColor(color.r, color.g, color.b)
    end
    ofst_x = ofst_x + 100

    -- Column 3: Member Class Icons
    ofst_x = ofst_x + 20
    local icon_ofst = 0
    local border_fn = function(f, m)
        local border = f:CreateTexture(nil, "BACKGROUND")
        border:SetAllPoints()
        border:SetTexture("Interface\\Buttons\\WHITE8X8")
        alpha = 1.0
        if m == nil then
            border:SetColorTexture(0, 0, 0, 0.8)
        elseif m.role == "DAMAGER" then
            border:SetColorTexture(0.5, 0, 0, 1)
        elseif m.role == "HEALER" then
            border:SetColorTexture(0, 0.5, 0, 1)
        else
            border:SetColorTexture(0, 0, 0.5, 1)
        end
    end
    local exists_num = 0
    for i, member in ipairs(group.members) do
        local iconFrame = CreateFrame("Frame", nil, row)
        iconFrame:SetSize(32, 32)
        iconFrame:SetPoint("LEFT", ofst_x + icon_ofst, 0)
        iconFrame:SetFrameLevel(row:GetFrameLevel() + 2)
        if group.delist then
            iconFrame:SetAlpha(0.7)
        end
        border_fn(iconFrame, member)

        local specId = Frontline.GetSpecIdFromLocalizedName(member)
        local icon = iconFrame:CreateTexture(nil, "ARTWORK")
        local path = "Interface\\AddOns\\Frontline\\media\\ClassIcon_"..member.classEn..".tga"
        if member.role ~= "HEALER" and specId then
            path = "Interface\\AddOns\\Frontline\\media\\Spec_"..specId..".tga"
        end
        icon:SetSize(28, 28)
        icon:SetPoint("CENTER", 0, 0)
        icon:SetTexture(path)

        Frontline.SetRoleIcon(iconFrame, member, icon)
        exists_num = exists_num + 1
        icon_ofst = icon_ofst + 40
    end

    while exists_num < group.max_mem do
        local iconFrame = CreateFrame("Frame", nil, row)
        iconFrame:SetSize(28, 28)
        iconFrame:SetPoint("LEFT", ofst_x + icon_ofst, 0)
        border_fn(iconFrame, nil)
        exists_num = exists_num + 1
        icon_ofst = icon_ofst + 40
    end
    ofst_x = ofst_x + 100

    -- Column 4: Group Name
    ofst_x = ofst_x + 20
    local groupText = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    groupText:SetPoint("LEFT", ofst_x, 0)
    groupText:SetText(Frontline.TruncateTitle(group.title))
    groupText:SetJustifyH("LEFT")
    groupText:SetWidth(240)
    ofst_x = ofst_x + 240
    
    -- local bg = row:CreateTexture(nil, "BACKGROUND")
    -- bg:SetColorTexture(0.1, 0.1, 0.1, 0.5)  -- Dark gray with 50% opacity
    -- bg:SetPoint("LEFT", groupText, -5, 0)    -- Extend slightly left
    -- bg:SetPoint("RIGHT", groupText, 5, 0)    -- Extend slightly right
    -- bg:SetPoint("TOP", groupText, 0, 5)      -- Extend slightly up
    -- bg:SetPoint("BOTTOM", groupText, 0, -5)  -- Extend slightly down

    return row
end
