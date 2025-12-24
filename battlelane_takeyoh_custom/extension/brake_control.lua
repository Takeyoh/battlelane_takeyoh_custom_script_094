print("brake control")

local totalCars = ac.getSim().carsCount

if totalCars == 1 then
    return nil
end

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

function script.update(dt)
    local start = 1
    if ac.getCar(0).isAIControlled and not ac.getCar(0).isInPitlane then start = 0 end
    brakeControl(carsStatus,start,dt)
end

local debugCar = nil
function brakeControl(carsStatus,start,dt)
    for i = start, totalCars - 1 do

        if carsStatus[i].lane == "wrongway" and carsStatus[i].isParking then
            goto continue
        end

        -- エンジンブロー対策
        if ac.getCar(i).engineLifeLeft < 500 then
            physics.setCarEngineLife(i, 1000)
        end

        if not carsStatus[i].isParking and not ac.getCar(i).isInPitlane then
            --自車に近い車両のみ制御対象にする
--            if carsDistance[0]['car'..i] > -100 and carsDistance[0]['car'..i] < 250 then
            if ac.getCar(i).position:distance(ac.getCar(0).position) < 300 then
                local selfCar = carsStatus[i]
                local brake = false

                -- 前方にいる車両の判別
                local frontCar = i
                local checkDistance = selfCar.speed/4
                local minDistance = checkDistance
                for j = 0, totalCars - 1 do
                    if j ~= i and carsStatus[j].isParking == false then
                        local targetCar = carsStatus[j]
                        local distance = carsDistance[i]['car'..j]
                                        - (targetCar.lengthRear + selfCar.lengthFront)
                        if carsDistance[i]['car'..j] > 0 and distance < minDistance then
                            local needWidth = (targetCar.width/2 + selfCar.width/2)*0.95
                            if math.abs(targetCar.fromLine - selfCar.fromLine) < needWidth then
                                minDistance = distance
                                frontCar = j
                            end
                        end
                    end
                end

                -- 前方車両の距離に応じてブレーキ処理（走行方向と逆向きに力を加える）
                if frontCar ~= i then
                    if minDistance < 2 then
                        physics.addForce(i,vec3(0,0,0),true,vec3(0,0,-300000*math.max(0,2-minDistance)),true)                
                    elseif carsStatus[frontCar].speed - selfCar.speed < 0 then
                        local brakeThreshold
                        if carsStatus[i].isPolice and frontCar == 0 then
                            brakeThreshold = 0
                        else
                            brakeThreshold = -carsStatus[i].speed/5
                        end
                        physics.addForce(i,vec3(0,0,0),true,vec3(0,0,150*(checkDistance-minDistance)*math.min(brakeThreshold,(carsStatus[frontCar].speed - selfCar.speed))),true)
                    end
                    brake = true
                end

                if carsStatus[i].lane == "challenger" or carsStatus[i].angerSwitch then
                    
                    -- 先のコーナーの曲がり度合いを検知して、減速
                    local dot = calcDots()
                    carsStatus[i].dot = dot
                    if selfCar.speed > 120 then
                        -- 急なコーナーが迫ってきたら減速処理
                        if dot < 0.9 then
                            local brakePower = -1000 * (1-math.abs(dot))*selfCar.speed
                            physics.addForce(i,vec3(0,0,0),true,vec3(0,0,brakePower),true)
                            brake = true
                        end

                        -- ゆるい高速コーナーで飛び出さないように常時力を加える
                        local xVelocity = ac.getCar(car.index).localVelocity.x
                        if math.abs(xVelocity) > 0.1 and math.abs(xVelocity) < 4 then
                            local sidePower = 130 * xVelocity * selfCar.speed
                            if math.abs(sidePower) < 100000 then
                                physics.addForce(i,vec3(0,0,0),true,vec3(-sidePower,-math.abs(sidePower*1.0),-selfCar.speed*1.7*(math.abs(xVelocity))),true)    
                            end
                        end
                    end

                    if carsStatus[i].lane == "challenger" then
                        -- アクセル全開
                        physics.setAIThrottleLimit(i,1)
                    elseif carsStatus[i].angerSwitch and carsStatus[i].speed < 250 then
                        -- beast mode
                        if not brake then
                            physics.addForce(i,vec3(0,0,0),true,vec3(0,0,10000*carsDistance[i]['car0']),true)
                        end
                    end

                    -- 前方に車が無く、かつスピードが遅いときはプッシュ（AI車両に近づいた時に加速しないため強制加速させる）
                    if brake == false and not carsStatus[i].isPolice then
                        if (selfCar.speed > 80 and selfCar.speed < 150) then
                            physics.addForce(i,vec3(0,0,0),true,vec3(0,0,200000*dot),true)
                        end
                    end
                    
                    if debugCar ~= nil and i == debugCar then
                        ac.debug("1_frontCar",frontCar)
                        ac.debug("2_distance",minDistance)
                        ac.debug("3_dot",dot)
                        ac.debug("4_xVelocity", ac.getCar(car.index).localVelocity.x)
                        ac.debug("5_brake",brake)
                    end

                else
                    --アクセルを制限
                    physics.setAIThrottleLimit(i,0.01)
                    --トラフィック用車両の最高速度を強制的に制限
                    if brake == false and selfCar.speed > 50 then
                        physics.addForce(i,vec3(0,0,0),true,vec3(0,0,8000*( selfCar.setSpeed - selfCar.speed)),true)
                    end

                    -- 前方に車が割り込んだら減速して車間を保つ
                    if frontCar ~= i and minDistance < 50 then
                        physics.addForce(i,vec3(0,0,0),true,vec3(0,0,-50 * selfCar.speed),true)
                    end
                end
            end
        end

        ::continue::
    end
end

-- 内積を使って、先のコーナーの曲がり度合いを計算
function calcDots()
    local selfCarPorgress = ac.worldCoordinateToTrackProgress(car.position)
    local progressPerSec = 1/(ac.getSim().trackLengthM)*10
    local minDot = 2
    for i = 4, 13 do
        local vector = ac.trackProgressToWorldCoordinate(selfCarPorgress + progressPerSec * (i+1))
                        -ac.trackProgressToWorldCoordinate(selfCarPorgress + progressPerSec * i)
        vector = vector / math.sqrt(vector.x^2 + vector.y^2 + vector.z^2)
        local dot = math.abs(vector:dot(car.look))
        if dot < minDot then minDot = dot end
    end
    return minDot
end