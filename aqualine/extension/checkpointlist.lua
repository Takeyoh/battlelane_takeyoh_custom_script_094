function checkPointList(sharedAccident)
    local laneCtrl = {
        {start = 0.0824832, finish = 0.0835969, center = 0, right = 6.5, left = -6.5}, -- ukishima
        {start = 0.26899, finish = 0.269428, center = -0.5, right = 6, left = -0.5}, -- heiwajima
        {start = 0.324602, finish = 0.326388, center = 0, right = 0, left = 0}, -- edobashi JCT
        {start = 0.4032, finish = 0.406091, center = 0, right = 0, left = 0}, -- tatsumiJCT 1
        {start = 0.40695, finish = 0.4081, center = 0, right = 0, left = 0}, -- tatsumiJCT 2
        {start = 0.880829, finish = 0.881426, center = 0, right = 6, left = -6}, -- oi
        {start = 0.518846, finish = 0.519411, center = -0.3, right = 5.6, left = -0.3}, -- daishi
        {start = 0.318715, finish = 0.319286, center = 0, right = 6, left = 0}, -- ginza north 1
        {start = 0.319963, finish = 0.320857, center = -0.8, right = 6, left = -0.8}, -- ginza north 2
        {start = 0.441197, finish = 0.442201, center = 0, right = 7, left = 0}, -- ginza south 1
        {start = 0.444187, finish = 0.444938, center = -0.5, right = 7.5, left = -0.5}, -- ginza south 2
        {start = 0.677105, finish = 0.677912, center = 0, right = 3.9, left = -3.9}, -- ukishima JCT in
        {start = 0.677912, finish = 0.682963, center = 0, right = 0, left = 0}, -- ukishima JCT in2
        {start = 0.694519, finish = 0.695947, center = 0, right = 0, left = 0}, -- K6
        {start = 0.828666, finish = 0.833356, center = 0, right = 0, left = 0}, -- ukishima JCT out
    }

    if sharedAccident.burnedout then
        table.insert(laneCtrl,
        {start = 0.30787, finish = 0.308498, center = 0.8, right = 5, left = 0.8} -- burnedout
        )
    end
    if sharedAccident.accident1 then
        table.insert(laneCtrl,
        {start = 0.944959, finish = 0.945989, center = 4, right = 4, left = 4} -- accident1
        )
    end
    if sharedAccident.accident2 then
        table.insert(laneCtrl,
        {start = 0.244108, finish = 0.245114, center = 4, right = 4, left = 4} -- accident2
        )
    end

    return laneCtrl
end
