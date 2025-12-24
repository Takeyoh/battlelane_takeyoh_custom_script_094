function checkPointList(sharedAccident)
    local laneCtrl = {
        {start = 0.09631071239709854, finish = 0.09870032221078873, center = 0, right = 6.5, left = -6.5}, -- ukishima
        {start = 0.31696775555610657, finish = 0.31827119662761688, center = -0.5, right = 6, left = -0.5}, -- heiwajima
        {start = 0.38255035877227783, finish = 0.3849787712097168, center = 0, right = 0, left = 0}, -- edobashi JCT
        {start = 0.47638884863853455, finish = 0.47952935099601746, center = 0, right = 0, left = 0}, -- tatsumiJCT 1
        {start = 0.4806135892868042, finish = 0.48175153136253357, center = 0, right = 0, left = 0}, -- tatsumiJCT 2
        {start = 0.8581331968307495, finish = 0.8602667616844177, center = 0, right = 6, left = -6}, -- oi
        {start = 0.6117718815803528, finish = 0.613453, center = -0.3, right = 5.6, left = -0.3}, -- daishi
        {start = 0.37580984830856323, finish = 0.37704036316871643, center = 0, right = 6, left = 0}, -- ginza north 1
        {start = 0.37744036316871643, finish = 0.37863469800949097, center = -0.8, right = 6, left = -0.8}, -- ginza north 2
        {start = 0.5206953287124634, finish = 0.5224556990623474, center = 0, right = 7, left = 0}, -- ginza south 1
        {start = 0.5242373943328857, finish = 0.5252897641181946, center = -0.5, right = 7.5, left = -0.5}, -- ginza south 2
    }

    if sharedAccident.burnedout then
        table.insert(laneCtrl,
        {start = 0.362392, finish = 0.364477, center = 0.8, right = 5, left = 0.8} -- burnedout
        )
    end
    if sharedAccident.accident1 then
        table.insert(laneCtrl,
        {start = 0.934795, finish = 0.9363, center = 4, right = 4, left = 4} -- accident1
        )
    end
    if sharedAccident.accident2 then
        table.insert(laneCtrl,
        {start = 0.288067, finish = 0.289514, center = 4, right = 4, left = 4} -- accident2
        )
    end

    return laneCtrl
end
