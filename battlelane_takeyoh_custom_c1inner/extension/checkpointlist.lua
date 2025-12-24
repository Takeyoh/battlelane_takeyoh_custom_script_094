function checkPointList(sharedAccident)
    local laneCtrl = {
        {start = 0.218754, finish = 0.229026, center = 0, right = 6, left = 0}, -- ginza north 1
        {start = 0.235502, finish = 0.252444, center = -0.8, right = 6, left = -0.8}, -- ginza north 2
        {start = 0.313887, finish = 0.334852, center = 0, right = 0, left = 0}, -- edobashi JCT
    }

    if sharedAccident.burnedout then
        table.insert(laneCtrl,
        {start = 0.0451684, finish = 0.0705562, center = 0.8, right = 5, left = 0.8} -- burnedout
        )
    end
    
    return laneCtrl
end