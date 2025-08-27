GladiatorBoard = GladiatorBoard or {}
GladiatorBoard.FilterKeywords = {
    "要的", "顶级", "带你飞", "嘉年华", "陪玩", "代练", "老板", "教学", "优惠",
    "低价", "价格",
    "coaching", "gold", "wts", "wtb", "boost",
}

function GladiatorBoard.FilterGroups()
    local filtered = {}
    if not GladiatorBoard.groups or type(GladiatorBoard.groups) ~= "table" then
        return
    end
    for i, g in ipairs(GladiatorBoard.groups) do
        local isFiltered = false
        if GladiatorBoardDb.FilteredLeaders then
            if GladiatorBoardDb.FilteredLeaders[g.leader] then
                isFiltered = true
            end
        end
        if not isFiltered and g.title and type(g.title) == "string" then
            for _, keyword in ipairs(GladiatorBoard.FilterKeywords) do
                if strfind(g.title, keyword, 1, true) or strfind(g.title, keyword, 1, false) then
                    isFiltered = true
                    break
                end
                if string.find(string.lower(g.title), string.lower(keyword)) then
                    isFiltered = true
                    break
                end
            end
        end
        if not isFiltered and g.description and type(g.description) == "string" then
            for _, keyword in ipairs(GladiatorBoard.FilterKeywords) do
                if string.find(g.description, keyword, 1, true) or string.find(g.description, keyword, 1, false) then
                    isFiltered = true
                    break
                end
                if string.find(string.lower(g.description), string.lower(keyword)) then
                    isFiltered = true
                    break
                end
            end
        end

        if not isFiltered then
            table.insert(filtered, g)
        end
    end

    GladiatorBoard.groups = filtered
end
