print("lane_control")

--動作条件確認
if ac.getSim().isOnlineRace then return nil end

local totalCars = ac.getSim().carsCount
if totalCars == 1 then
    return nil
end


--パラメータ設定
local carsStatus = {}
local carsDistance = {}
for i = 0 , totalCars - 1 do
    local sharedData ={
        ac.StructItem.key('tky_srp_carstatus' .. i),
        id = ac.StructItem.string(),
        name = ac.StructItem.string(),
        mass = ac.StructItem.float(),
        position = ac.StructItem.vec3(),
        speed = ac.StructItem.float(),
        setSpeed = ac.StructItem.float(),
        compass = ac.StructItem.float(),
        width = ac.StructItem.float(),
        length = ac.StructItem.float(),
        lengthFront = ac.StructItem.float(),
        lengthRear = ac.StructItem.float(),
        progress = ac.StructItem.float(),
        fromLine = ac.StructItem.float(),
        lane = ac.StructItem.string(),
        dot = ac.StructItem.float(),
        battle = ac.StructItem.uint8(),
        countdown = ac.StructItem.float(),
        layout = ac.StructItem.string(),
        isParking = ac.StructItem.boolean(),
        isRoadRage = ac.StructItem.boolean(),
        angerSwitch = ac.StructItem.boolean(),
        isPolice = ac.StructItem.boolean()
    }
    carsStatus[i] = ac.connect(sharedData,true,nil)

    local distanceData = {ac.StructItem.key('tky_srp_cardistance' .. i),}
    for i = 0, ac.getSim().carsCount - 1 do
        distanceData['car'..i] = ac.StructItem.float()
    end
    carsDistance[i] = ac.connect(distanceData,true,nil)
end

local respawn = {
    position = ac.StructItem.vec3(),
    direction = ac.StructItem.vec3(),
}
local sharedRespawn = ac.connect(respawn,true,nil)
sharedRespawn.position = vec3(889.708, 6.64998, -198.848)
sharedRespawn.direction = vec3(0,0,1)

local accident ={
    ac.StructItem.key('tky_srp_battlelayout_accident'),
    burnedout = ac.StructItem.boolean(),
    accident1 = ac.StructItem.boolean(),
    accident2 = ac.StructItem.boolean(),
    addAccident = ac.StructItem.boolean(),
}
local sharedAccident = ac.connect(accident,true,nil)

local trackparameter ={
    ac.StructItem.key('tky_srp_battlelayout_trackParam'),
    largeCarMass = ac.StructItem.uint16(),
    rightLaneRate = ac.StructItem.float(),
    leftLaneRate = ac.StructItem.float(),
    rightLaneSpeed = ac.StructItem.uint8(),
    centerLaneSpeed = ac.StructItem.uint8(),
    beastSpeed = ac.StructItem.uint8(),
    leftLaneSpeed = ac.StructItem.uint8(),
    trafficCarDistance = ac.StructItem.uint8(),
    rivalCarSlowdown = ac.StructItem.float()
}
local sharedTrackParam = ac.connect(trackparameter,true,nil)

sharedTrackParam.largeCarMass = tonumber(ac.configValues({ LARGE_CAR_MASS = '' }).LARGE_CAR_MASS) or 3000
sharedTrackParam.rightLaneRate = tonumber(ac.configValues({ RIGHT_LANE_RATE = '' }).RIGHT_LANE_RATE) or 0.2
sharedTrackParam.leftLaneRate = tonumber(ac.configValues({ LEFT_LANE_RATE = '' }).LEFT_LANE_RATE) or 0.4
sharedTrackParam.rivalCarSlowdown = tonumber(ac.configValues({ RIVAL_SLOWDOWN = '' }).RIVAL_SLOWDOWN) or 1
sharedTrackParam.trafficCarDistance = 45

sharedTrackParam.rightLaneSpeed = 120
sharedTrackParam.centerLaneSpeed = 100
sharedTrackParam.leftLaneSpeed = 95
sharedTrackParam.beastSpeed = 180

local trafficAccident = tonumber(ac.configValues({ ACCIDENT = '' }).ACCIDENT) or 1
if trafficAccident == 1 then
    sharedAccident.addAccident = true
else
    sharedAccident.addAccident = false
end

local laneCtrl = {}
local changeCheck = {
    burnedout = false,
    accident1 = false,
    accident2 = false,
}

if io.fileExists(__dirname .. "\\checkpointlist.lua") then
  dofile(__dirname .. "\\checkpointlist.lua")
  laneCtrl = checkPointList(sharedAccident)
else
  return nil
end


local cars = {}
local countHuge = 0
local countRival = 0
local shuffle = {}
local blinker = {}

local leftLane = -3.9
local rightLane = 3.9
local centerLane = 0
local leftWidth = -1.5
local rightWidth = 1.5

local rivalMaxSpeed = 500

local progressPerMeter = 1/(ac.getSim().trackLengthM)

---- 起動時処理
-- ライバル車と重量車のチェックと残りトラフィック台数の確認
for i = 0, totalCars - 1 do
    local carTag = ac.getCarTags(i)
    local checkTraffic = false
    if carTag ~= nil and #carTag > 0 then
        for j = 1, #carTag do
            if string.lower(carTag[j]) == "traffic" then
                checkTraffic = true
            end
        end
    end

    cars[i] = {
        laneMem = "center",
        isTraffic = checkTraffic,
        offset = 0,
        speed = sharedTrackParam.centerLaneSpeed,
        preOffset = 0,
        caution = 1,
        lanechange = false,
        fixedOffset = nil,
        aggression = 0,
        steerRatio = 2.5,
        ailevel = 1,
    }

    if carsStatus[i].mass > sharedTrackParam.largeCarMass or ac.getCar(i).aabbSize.x > 2.5 then
        carsStatus[i].lane = "left"
        countHuge = countHuge + 1
    elseif i == 0 or carsStatus[i].isPolice or (sharedTrackParam.rivalCarSlowdown == 0 and cars[i].isTraffic == false) then
        carsStatus[i].lane = "challenger"
        countRival = countRival + 1
    else
        table.insert(shuffle,i)
    end
end

--ライバル車と重量車両以外のトラフィックの順番をランダム化
math.randomseed(os.time()) 
for i = #shuffle, 2, -1 do
    local j = math.random(i)
    shuffle[i], shuffle[j] = shuffle[j], shuffle[i]
end

-- ライバル車と重量車以外のトラフィックのレーンを割り当て
local maxLeft = math.floor((totalCars - countRival)* sharedTrackParam.leftLaneRate) - countHuge
local maxRight = math.floor((totalCars - countRival) * sharedTrackParam.rightLaneRate)
for i = 1, #shuffle do
    if maxLeft > 0 then
        carsStatus[shuffle[i]].lane = "left"
        maxLeft = maxLeft - 1
    elseif maxRight > 0 then
        carsStatus[shuffle[i]].lane = "right"
        maxRight = maxRight - 1
    else
        carsStatus[shuffle[i]].lane = "center"
    end
end

local function setParameter(i,full)
    if carsStatus[i].lane == "left" then
        cars[i].offset = leftLane
        cars[i].preOffset = leftLane
        cars[i].fixedOffset = leftLane
        cars[i].speed = sharedTrackParam.leftLaneSpeed
        cars[i].caution = 0.01
        cars[i].ailevel = 1
    elseif carsStatus[i].lane == "right" then
        cars[i].offset = rightLane
        cars[i].preOffset = rightLane
        cars[i].fixedOffset = rightLane
        cars[i].speed = sharedTrackParam.rightLaneSpeed
        cars[i].caution = 0.01
        cars[i].ailevel = 1
    elseif carsStatus[i].lane == "center" then
        cars[i].offset = centerLane
        cars[i].preOffset = centerLane
        cars[i].fixedOffset = centerLane
        cars[i].speed = sharedTrackParam.centerLaneSpeed
        cars[i].caution = 0.01
        cars[i].ailevel = 1
    else
        if full then
            cars[i].offset = centerLane
            cars[i].preOffset = centerLane
        end
        cars[i].speed = sharedTrackParam.centerLaneSpeed
        cars[i].caution = 0.1
        cars[i].ailevel = 2
    end
    carsStatus[i].setSpeed = cars[i].speed
    physics.setAIAggression(i,cars[i].aggression)
    physics.setAILevel(i,cars[i].ailevel)

    blinker[i+1] = 0
end

-- 各車にレーンごとの設定を追加
for i = 0, totalCars - 1 do

    setParameter(i,true)
    cars[i].laneMem = carsStatus[i].lane
    physics.setAILookaheadGasBrake(i, 30)
    physics.setAILookaheadBase(i,10)
    physics.setAISteerMultiplier(i, 1) 

    print(i .. " " .. ac.getCarID(i) .. " : " .. carsStatus[i].lane .. ":" .. tostring(carsStatus[i].isPolice))

end

---- メインルーティン
local debugCar = nil
local debugMsg = ""
local updateCounter = 0
function script.update(dt)
    -- 制御レーンリスト更新チェック
    local updateCheck = false
    for  event,status in pairs(changeCheck) do
       if changeCheck[event] ~= sharedAccident[event] then
            updateCheck = true
            changeCheck[event] = sharedAccident[event]
       end
    end
    if updateCheck then
        laneCtrl = checkPointList(sharedAccident)
    end

    -- レーン制御処理
    if updateCounter > (updateCounter + dt) % 0.01 then
        local start = 1
        if ac.getCar(0).isAIControlled and not ac.getCar(0).isInPitlane then start = 0 end
        laneControl(carsStatus,start,dt)
    end
    updateCounter = (updateCounter + dt) % 0.01

    -- for debug
    if debugCar~= nil then
        ac.debug("car name",carsStatus[debugCar].name)
        ac.debug("mass",carsStatus[debugCar].mass)
        ac.debug("fixedOffset",cars[debugCar].fixedOffset)
        ac.debug("lane",carsStatus[debugCar].lane)
        ac.debug("laneChange",cars[debugCar].lanechange)
        ac.debug("offset", cars[debugCar].offset)
        ac.debug("preOffset", cars[debugCar].preOffset)
        ac.debug("fromLine", carsStatus[debugCar].fromLine)
        ac.debug("porgress",carsStatus[debugCar].progress)
        ac.debug("lane distance", debugMsg)
        ac.debug("speed", math.floor(carsStatus[debugCar].speed))
    end
    ac.debug("accident1",sharedAccident.accident1)
    ac.debug("accident2",sharedAccident.accident2)
    ac.debug("burnedout",sharedAccident.burnedout)
end

-- スポーンされた車両に対する処理
ac.onCarJumped(-1, function(carIndex)
    if not carsStatus[0].isParking or carsStatus[carIndex].lane ~= 'wrongway' then

        -- 自車の前後近くにいるAI車両を強制的にデスポーン
        local distance = carsDistance[0]['car'..carIndex]
        if carIndex ~= 0 and not ac.getCar(carIndex).isInPitlane then
            if distance < 300 and distance > 0 then
                if existArroundCar(carIndex,sharedTrackParam.trafficCarDistance) then
                    despawn(carIndex)
                end
            end
        end

        -- ステアリングのリセットと、ダメージ回復、場所情報の最新化
        physics.overrideSteering(carIndex, 0)
        physics.overrideSteering(carIndex, math.nan)
        physics.resetCarState(carIndex, 0.5)
        carsStatus[carIndex].progress = ac.worldCoordinateToTrackProgress(cars[carIndex].position)

        -- バトル中にジャンプしてしまった場合の終了処理
        if carsStatus[carIndex].battle > 0 then
            carsStatus[carIndex].battle = 0
            carsStatus[carIndex].countdown = 0
            carsStatus[carIndex].lane = cars[carIndex].laneMem
        end

        -- バトル車両を一定の率で、トラフィックに切り替え（ゆっくり走るバトル車を作る）
        if carIndex ~= 0 and not carsStatus[carIndex].isPolice
        and cars[carIndex].isTraffic == false then
            local rand = math.seededRandom(os.time())
            if rand < sharedTrackParam.rivalCarSlowdown then
                carsStatus[carIndex].lane = cars[carIndex].laneMem
            else
                carsStatus[carIndex].lane = "challenger"
            end
        end

        -- 設定されたlaneパラメータに合わせて、車両パラメータを再設定
        setParameter(carIndex,true)

    end
end)

-- 自車の周り（一定距離内）に車が存在するかどうかのチェックルーチン
function existArroundCar(carID, distance)
    local result = false
    for i = 0, #carsStatus - 1 do
        if i ~= carID and carsStatus[i].lane ~= "challenger" then
            if math.abs(carsDistance[carID]['car'..i]) < distance then
                result = true
                break
            end
        end
    end
    return result
end

-- 強制的に車をデスポーンさせる処理
function despawn(carIndex)
    if not ac.getCar(0).isInPitlane and ac.getCar(carIndex).position:distance(sharedRespawn.position)>10 then
        physics.setCarPosition(carIndex,sharedRespawn.position, sharedRespawn.direction)
        cars[carIndex].offset = centerLane
        cars[carIndex].preOffset = centerLane
        carsStatus[carIndex].progress = ac.worldCoordinateToTrackProgress(cars[carIndex].position)
    end
end

-- 各車のレーンを制御するルーティン
function laneControl(carsStatus,start,dt)

    local offset = centerLane
    for i = start, totalCars - 1 do
        local selfCar = carsStatus[i]
        blinker[i+1] = 0

        if selfCar.lane == "wrongway" or selfCar.isParking then
            goto continue
        end

        if selfCar.battle == 1 and selfCar.countdown <= 0 then
            -- バトル開始時に対象車両のlaneパラメータをchallengerに変更。
            selfCar.lane = "challenger"
            setParameter(i,false)
            selfCar.battle = 2
        elseif selfCar.battle == 3 then
            -- バトル終了時は元に戻す。
            selfCar.lane = cars[i].laneMem
            setParameter(i,false)
            selfCar.battle = 0
        end

        -- AI車両に対して、設定し続ける必要があるパラメータを繰り返し設定する処理
        selfCar.setSpeed = cars[i].speed
        physics.setAITopSpeed(i,cars[i].speed)
        physics.setAICaution(i,cars[i].caution)

        -- 走行中のAI車両で特定の条件にあるものを強制デスポーン。
        local distance = carsDistance[0]['car'..i]
        if not carsStatus[0].isParking then
            if (i ~= 0 and not ac.getCar(i).isInPitlane) then
                if distance > 500 and distance < 1000 then
                    if existArroundCar(i,sharedTrackParam.trafficCarDistance) then
                        despawn(i)
                    end
                end
                if distance > 0 and distance < 300 and carsStatus[i].speed < 5 then
                    despawn(i)
                end
            end
        end

        -- ゲートや柱などの特定区間を検知・制御
        local activeZoneIndex = 0 
        local side = ac.getTrackAISplineSides(selfCar.progress)
        -- 特定の区間に入っているかを判定
        for j = 1, #laneCtrl do
            if selfCar.progress > laneCtrl[j].start and selfCar.progress < laneCtrl[j].finish then
                activeZoneIndex = j
                break
            end
        end
        
        if activeZoneIndex ~= 0 then
            -- 特定の区間は、走行レーンを固定する処理
            local currentZone = laneCtrl[activeZoneIndex] 

            if selfCar.fromLine > rightWidth then
                offset = currentZone.right
                if side.y > rightLane then
                    cars[i].offset = rightLane
                    cars[i].preOffset = rightLane
                else
                    cars[i].offset = centerLane
                    cars[i].preOffset = centerLane
                end
            elseif selfCar.fromLine < leftWidth then
                offset = currentZone.left
                if -side.x < leftLane then
                    cars[i].offset = leftLane
                    cars[i].preOffset = leftLane
                else
                    cars[i].offset = centerLane
                    cars[i].preOffset = centerLane
                end
            else
                offset = currentZone.center
                cars[i].offset = centerLane
                cars[i].preOffset = centerLane
            end
            physics.setAISplineAbsoluteOffset(i, offset, true)
            --ハザード
            if not carsStatus[i].isParking then
                blinker[i+1] = 3
            end
        
        -- 特定区間以外の制御
        -- angerモード
        elseif carsStatus[i].angerSwitch then
            blinker[i+1] = 3
            --車にオフセットを設定            
            physics.setAISplineAbsoluteOffset(i, carsStatus[0].fromLine, true)

        -- AI車両の制御（負荷軽減のため一定距離以内の車両のみを制御）
        elseif ac.getCar(i).position:distance(ac.getCar(0).position) < 5000 
          or carsStatus[i].mass > sharedTrackParam.largeCarMass then 
            -- ハザードが点いている車は消す。
            if blinker[i+1] == 3 then
                blinker[i+1] = 0
            end
            
            -- 各車の最高速度制御
            if carsStatus[i].lane == "challenger" then                
                if carsDistance[0]['car'..i] > 100 then
                    -- 自車から遠い場合はトラフィックと同じ速度
                    cars[i].speed = sharedTrackParam.centerLaneSpeed
                else
                    -- 近づいたら制限解除
                    cars[i].speed = rivalMaxSpeed
                end
            else
                -- beast mode（夜はスピードが速くなる）
                if carsStatus[i].isRoadRage and ac.getSunAngle() > 90 then
                    cars[i].speed = sharedTrackParam.beastSpeed

                -- 各レーンを走る車の制限速度を設定
                elseif carsStatus[i].fromLine < leftWidth then
                    cars[i].speed = sharedTrackParam.leftLaneSpeed
                elseif carsStatus[i].fromLine > rightWidth then
                    cars[i].speed = sharedTrackParam.rightLaneSpeed
                else
                    cars[i].speed = sharedTrackParam.centerLaneSpeed
                end
            end

            --各車のレーン選択
            if cars[i].lanechange == false then
                if carsStatus[i].lane == "challenger" then
                    -- ライバル車のレーン制御
                    offset = selectLane(i,side,math.max(200,carsStatus[i].speed))
                else
                    -- トラフィック車のレーン制御
                    offset = selectLane(i,side,20)
                end
            else
                offset = cars[i].fixedOffset
            end

            -- レーン変更前の左右車両の確認
            if cars[i].preOffset ~= offset then
                if existCarCheck(i, offset) then
                    cars[i].lanechange = true
                    cars[i].fixedOffset = offset
                elseif cars[i].lanechange == true then
                    cars[i].fixedOffset = cars[i].preOffset
                end
            end

            -- レーン移動処理
            if carsStatus[i].speed > 50 and cars[i].lanechange == true then

                blinker[i+1] = 0
                if offset == nil then offset = cars[i].offset end

                --右移動
                if offset > cars[i].offset then
                    cars[i].offset = cars[i].offset + dt*cars[i].steerRatio
                end
                --左移動
                if offset < cars[i].offset then
                    cars[i].offset = cars[i].offset - dt*cars[i].steerRatio
                end

                --レーン移動終了時処理
                if math.abs(offset - cars[i].offset) < 0.05 then
                    cars[i].preOffset = offset
                    blinker[i+1] = 0
                    cars[i].lanechange = false
                    if carsStatus[i].lane ~= "challenger" then
                        if offset > rightWidth then
                            cars[i].speed = sharedTrackParam.rightLaneSpeed
                        elseif offset < leftWidth then
                            cars[i].speed = sharedTrackParam.leftLaneSpeed
                        else
                            cars[i].speed = sharedTrackParam.centerLaneSpeed
                        end
                    end
                end

                -- ウィンカー判別
                if cars[i].fixedOffset < cars[i].preOffset then
                    --左ウィンカー
                    blinker[i+1] = 1 
                elseif cars[i].fixedOffset > cars[i].preOffset then
                    --右ウィンカー
                    blinker[i+1] = 2
                end
            end

            -- バトルまでのカウントダウン中にハザードを点灯
            if selfCar.battle == 1 and selfCar.countdown > 0 then
                blinker[i+1] = 3
            end

            --車にオフセットを設定
            physics.setAISplineAbsoluteOffset(i, cars[i].offset, true)

        end

        ::continue::
    end

    -- carmodのscript_tky_srp_blinker.luaに値を渡すための処理
    -- track modからcar modへのデータ連携はac.connectが使えないため
    ac.store('tky_srp_blinker',JSON.stringify(blinker))

end

--レーン移動方向に車が存在するかをチェックする処理
-- 移動する方向に車両が入なければtrue、衝突する可能性がある場合はfalseをreturnする。
function existCarCheck(carID,offset)
    if carsStatus == nil then return false end

    local result = true
    local selfCar = carsStatus[carID]

    for i = 0 , totalCars - 1 do
        if i~= carID and carsStatus[i].isParking == false then
            -- 車線変更方向に車かいるかどうかを判別
            local targetCar  = carsStatus[i]
            if cars[i].fixedOffset == offset then
                local distance = carsDistance[carID]['car'..i]
                if distance >= 0 then
                    if distance < carsStatus[i].lengthRear + carsStatus[carID].lengthFront + 1 then
                        result = false
                    end
                else
                    if math.abs(distance) < carsStatus[carID].lengthRear + carsStatus[i].lengthFront + 1 then
                        result = false
                    end
                end
            end
        end
    end
    return result
end

-- レーン選択処理
-- 車両ごとに前方の空き距離をレーンごとに検出し、どのレーンに移動するかをreturnする。
function selectLane(carID,side,distance)

    local selfCar = carsStatus[carID]
    local left = distance
    local leftCar = carID
    local center = left
    local centerCar = carID
    local right =  left
    local rightCar = carID

    -- carIDの車両からみた、左・中央・右の各レーンの前方空き距離を検出
    for i=0 , totalCars - 1 do
        if i ~= carID and carsStatus[i].isParking == false then
            local targetCar = carsStatus[i]
            local targetCarDistance = carsDistance[carID]['car'..i]
            if not (carsStatus[i].lane == "challenger" and carsStatus[i].speed > 200 ) 
              or carsStatus[carID].battle > 0
              or carsStatus[i].isPolice then
                if targetCarDistance > -1*(selfCar.lengthRear + targetCar.lengthFront) 
                  and targetCarDistance <  distance then
                    if targetCar.fromLine < leftWidth then
                        if targetCarDistance < left then
                            left = targetCarDistance
                            leftCar = i
                        end
                    elseif targetCar.fromLine > rightWidth then
                        if targetCarDistance < right then
                            right = targetCarDistance
                            rightCar = i
                        end
                    elseif targetCarDistance < center then
                        center = targetCarDistance
                        centerCar = i
                    end
                end
            end
        end
    end

    if side.y < rightLane then
        right = 0
    end
    if -side.x > leftLane then
        left = 0
    end

    if debugCar ~= nil and carID == debugCar then
        debugMsg = math.floor(left) .. " : "  .. math.floor(center) .. " : " .. math.floor(right)
    end

    local offset = cars[carID].preOffset
    if carsStatus[carID].lane == "challenger" then
        -- ライバル車のレーン選択処理
        if cars[carID].preOffset == centerLane then
            if center >= left and center >= right then
                offset = centerLane
            elseif right >= left then
                if side.y > rightLane and right > center then
                    offset = rightLane
                end
            else
                if -side.x < leftLane and left > center then
                    offset = leftLane
                end
            end
        elseif cars[carID].preOffset == leftLane then
            if left >= center and left >= right then
                offset = leftLane
            elseif -side.x > leftLane then
                offset = centerLane
            elseif center > left then
                offset = centerLane
            end
        elseif cars[carID].preOffset == rightLane then
            if right >= left and right >= center then
                offset = rightLane
            elseif side.y < rightLane then
                offset = centerLane                
            elseif center > right + 40 then
                offset=centerLane
            end
        end

    else
        --トラフィック車のレーン選択処理
        if carsStatus[carID].lane == "left" then
            if -side.x < leftLane then
                if leftCar ~= carID 
                  and (carsStatus[leftCar].speed - selfCar.speed < -10) 
                  then
                    offset = centerLane
                else
                    offset = leftLane                        
                end
            else
                if centerCar ~= carID 
                  and (carsStatus[centerCar].speed - selfCar.speed < -10) 
                  then
                    offset = rightLane
                else
                    offset = centerLane
                end
            end
        elseif carsStatus[carID].lane == "right" then
            if side.y > rightLane then
                if rightCar ~= carID 
                  and (carsStatus[rightCar].speed - selfCar.speed < -10) 
                then
                    offset = centerLane
                else
                    offset = rightLane
                end
            else
                offset = centerLane
            end
        else
            if centerCar ~= carID 
              and (carsStatus[centerCar].speed - selfCar.speed < -10) 
              then
                offset = rightLane
            else
                offset = centerLane
            end
        end
    end

    return offset
end
