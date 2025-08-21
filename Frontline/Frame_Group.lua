Frontline = Frontline or {}
Frontline.TitleEditText = ""
Frontline.CommentEditText = ""

function Frontline.SetTitle(text)
    Frontline.TitleEditText = text
end

function Frontline.SetComment(text)
    Frontline.CommentEditText = text
end

function Frontline.ActivityId()
    if Frontline.mode == "3v3" then
        return Frontline.ActivityId_3v3
    elseif Frontline.mode == "2v2" then
        return Frontline.ActivityId_2v2
    end
    return 0
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

    FrontlineFrameGroupFrameListButton.selectedCategory = Frontline.CategoryID_Arena
    FrontlineFrameGroupFrameListButton.selectedActivity = Frontline.ActivityId()
    blizTitle:SetParent(FrontlineFrameGroupFrameListButton)
    blizTitle:ClearAllPoints()
    blizTitle:SetPoint("TOP", 0, -30)
    blizTitle:SetSize(FrontlineFrameGroupFrameListButton:GetWidth(), FrontlineFrameGroupFrameListButton:GetHeight())
    blizTitle:SetScript("OnTextChanged", function(name)
        InputBoxInstructions_OnTextChanged(name)
    end)
    FrontlineFrameGroupFrameCreateButton:Hide()
    FrontlineFrameGroupFrameListButton:Show()
end

function Frontline.List()
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
    FrontlineFrameGroupFrameListButton:Hide()
    FrontlineFrameGroupFrameCreateButton:Show()
end

function Frontline.Delist()
    C_LFGList.RemoveListing()
end
