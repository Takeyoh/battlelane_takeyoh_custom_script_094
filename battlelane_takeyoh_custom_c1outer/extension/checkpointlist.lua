function checkPointList(sharedAccident)
    local laneCtrl = {
        {start = 0.846617, finish = 0.875749, center = 0, right = 0, left = 0}, -- edobashi JCT
        {start = 0.927665, finish = 0.948625, center = 0, right = 7, left = 0}, -- ginza south 1
        {start = 0.973569, finish = 0.985856, center = -0.5, right = 7.5, left = -0.5}, -- ginza south 2
    }

    if sharedAccident.accident1 then
        table.insert(laneCtrl,
        {start = 0.489852, finish = 0.512425, center = 4, right = 4, left = 4} -- accident1
        )
    end

    return laneCtrl
end
