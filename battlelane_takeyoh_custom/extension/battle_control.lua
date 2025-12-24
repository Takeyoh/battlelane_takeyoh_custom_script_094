print("battle_control")

--動作条件確認
if ac.getSim().isOnlineRace then return nil end

local totalCars = ac.getSim().carsCount
if totalCars == 1 then
    return nil
end

--パラメータ設定
local carsStatus = {}
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
    carsStatus[i].battle = 0
    carsStatus[i].countdown = 0

end

local respawn = {
    position = ac.StructItem.vec3(),
    direction = ac.StructItem.vec3(),
}
local sharedRespawn = ac.connect(respawn,true,nil)

local progressPerMeter = 1/(ac.getSim().trackLengthM)

local forApp = {
    target = nil,
    countdown = 0,
    lifeSelf = 100,
    lifeRival = 100,
    pursuitLevel = 1,
    status = "",
    message = "",
    distance = 0,
}

local msgTimer = 0
function setMessage(msg, time)
  if forApp.message ~= msg  then
    forApp.message = msg
    msgTimer = time
  end
end

function calcMessage(dt)
  if msgTimer > 0 then
  msgTimer = msgTimer - dt
  else
    forApp.message = ""
  end
end

function initialize(targetCar)
    carsStatus[0].battle = 0
    carsStatus[0].countdown = 0
    carsStatus[targetCar].battle = 3
    carsStatus[targetCar].countdown = 0
    forApp.target = nil
    prePosition = nil
    forApp.status = ""
end

local damageVolume = nil
if ac.getPatchVersionCode() >= 3465 then
    ac.onCarCollision(-1, function(carIndex)
        if forApp.status == "battle" then
            damageVolume = ac.getCar(carIndex).collisionDepth
            if carIndex == 0 then
                forApp.lifeSelf = forApp.lifeSelf - damageVolume*50             
            end

            if ac.areShapesColliding(0,nil,forApp.target) then
                if ac.getCar(0).collisionPosition.z > 0 then
                    forApp.lifeSelf = forApp.lifeSelf - damageVolume*500
                else
                    forApp.lifeRival = forApp.lifeRival - damageVolume*500
                end
            end
        end        
    end)
end

function script.update(dt)
    -- self car attack
    local selfCar = ac.getCar(0)
    if selfCar.flashingLightsActive and carsStatus[0].battle == 0 then
        local frontCar = detectFrontCar(0,20,true)
        if frontCar ~= 0 then
            local frontCheck = detectFrontCar(frontCar,20,true)
            if frontCheck== frontCar then
                --- battle start
                forApp.target = frontCar
                carsStatus[forApp.target].battle = 1
                carsStatus[forApp.target].countdown = 5
                carsStatus[0].battle = 1
                forApp.lifeSelf = 100
                forApp.lifeRival = 100
                forApp.status = "countdown"
            end
        end
    end

     -- countdown
    if forApp.status == "countdown" then        
        if carsStatus[forApp.target].countdown > 0 then
            carsStatus[forApp.target].countdown = carsStatus[forApp.target].countdown - dt
            forApp.countdown = carsStatus[forApp.target].countdown
            physics.addForce(0,vec3(0,0,0),true,vec3(0,0,10000*( carsStatus[forApp.target].speed - carsStatus[0].speed)),true)
            local rivalFrontCheck = detectFrontCar(forApp.target,30,true)
            if rivalFrontCheck ~= forApp.target and rivalFrontCheck ~= 0 then
                despawn(rivalFrontCheck)
            end
        else
            forApp.status = "battle"
            carsStatus[forApp.target].countdown = 0
        end

    -- battle control
    elseif forApp.status == "battle" then
            -- finished
        if forApp.lifeRival <= 0 or forApp.lifeSelf <= 0 then
            if forApp.lifeRival <= 0 then
                setMessage("You win!",5)
                if forApp.pursuitLevel < 10 then
                    forApp.pursuitLevel = forApp.pursuitLevel + 1
                end
            elseif forApp.lifeSelf <= 0 then
                setMessage("You lose.",5)
                if forApp.pursuitLevel > 1 then
                    forApp.pursuitLevel = forApp.pursuitLevel - 1
                end
            end
            initialize(forApp.target)


        -- calc life point
        else
            local distance = calcDistance(forApp.target)
            forApp.distance = distance
            ac.debug("distance",distance)
            ac.debug("targetspeed",carsStatus[forApp.target].speed)

            local speedGap = carsStatus[forApp.target].speed - carsStatus[0].speed
            if distance > 200 then
                forApp.lifeSelf = forApp.lifeSelf - math.abs(distance-200) * 0.001
                forApp.lifeSelf = forApp.lifeSelf - math.max(0,speedGap) * 0.001
            elseif distance > 30 then
                forApp.lifeSelf = forApp.lifeSelf - math.max(0,speedGap) * 0.001
            elseif distance > 0 and math.abs(speedGap) < 10 then
                forApp.lifeRival = forApp.lifeRival - (30-math.abs(distance))/5 * 0.001
            elseif distance < -200 then
                forApp.lifeRival = forApp.lifeRival - math.abs(distance + 200) * 0.001
                forApp.lifeRival = forApp.lifeRival - math.max(0,-speedGap) * 0.001
            elseif distance < -30 then
                forApp.lifeRival = forApp.lifeRival - math.max(0,-speedGap) * 0.001
            elseif distance < 0 and math.abs(speedGap) < 10 then
                forApp.lifeSelf = forApp.lifeSelf - (30 - math.abs(distance))/5 * 0.001
            end


            -- rival car boost
            local rivalFrontCheck = detectFrontCar(forApp.target,carsStatus[forApp.target].speed/5,true)
            if distance < -30 then
                rivalFrontCheck  = detectFrontCar(forApp.target,math.min(50,math.abs(distance)-20),true)
                if rivalFrontCheck ~= forApp.target and rivalFrontCheck ~= 0 then
                    despawn(rivalFrontCheck)
                end
            end

            if not carsStatus[forApp.target].isPolice then
                if rivalFrontCheck == forApp.target then
                    local trainPower = math.max(0,ac.getCar(forApp.target).drivetrainPower)
                    if distance >= 0 then
                        if carsStatus[forApp.target].dot > 0.9 then
                            physics.addForce(forApp.target,vec3(0,0,0),true,vec3(0,0,trainPower*forApp.pursuitLevel*10),true)
                        else
                            physics.addForce(forApp.target,vec3(0,0,0),true,vec3(0,0,trainPower*forApp.pursuitLevel*4),true)
                        end
                    else
                        if carsStatus[forApp.target].dot > 0.9 then
                            physics.addForce(forApp.target,vec3(0,0,0),true,vec3(0,0,trainPower*forApp.pursuitLevel*math.max(30,-distance)),true)
                        else
                            physics.addForce(forApp.target,vec3(0,0,0),true,vec3(0,0,trainPower*forApp.pursuitLevel*5),true)
                        end
                    end
                end
            end
        end
    end

    ac.debug("battlemode",carsStatus[0].battle)
    ac.debug("pursuitLevel",forApp.pursuitLevel)
    ac.debug("targetCar",forApp.target)
    if forApp.target ~= nil then
        ac.debug("countdown",carsStatus[forApp.target].countdown)
    end
    ac.debug("message",forApp.message)
    ac.debug("timer",msgTimer)

    -- アプリケーションへの情報受け渡し用
    ac.store('tky_srp_forApp',JSON.stringify(forApp))

    calcMessage(dt)

end


function calcDistance(target)
    local distance = carsStatus[0].position:distance(carsStatus[target].position)
    local carLook = ac.trackProgressToWorldCoordinate(carsStatus[0].progress + progressPerMeter) - ac.trackProgressToWorldCoordinate(carsStatus[0].progress)
    local targetDirection = carsStatus[target].position - carsStatus[0].position
    local dot = carLook:dot(targetDirection)
    if dot < 0 then
        distance = -distance
    end
    return distance
end

function detectFrontCar(i,minDistance,collisionCheck)
     -- 前方にいる車両の判別
    local frontCar = i
    local selfCar = carsStatus[i]
    for j = 0, totalCars - 1 do
        if j ~= i and carsStatus[j].isParking == false then
            local targetCar = carsStatus[j]
            local distance = (targetCar.progress - selfCar.progress)/progressPerMeter
                            - (targetCar.lengthRear + selfCar.lengthFront)
            if distance > 0 and distance < minDistance then
                if collisionCheck then
                    local needWidth = (targetCar.width/2 + selfCar.width/2)
                    if math.abs(targetCar.fromLine - selfCar.fromLine) < needWidth then
                        minDistance = distance
                        frontCar = j
                    end
                else
                    minDistance = distance
                    frontCar = j
                end
            end
        end
    end
    return frontCar
end

function despawn(carIndex)
    if not ac.getCar(0).isInPitlane and ac.getCar(carIndex).position:distance(sharedRespawn.position)>10 then
        physics.setCarPosition(carIndex,sharedRespawn.position, sharedRespawn.direction)
        carsStatus[carIndex].progress = ac.worldCoordinateToTrackProgress(ac.getCar(carIndex).position)
    end
end


ac.onCarJumped(-1, function(carIndex)
    if forApp.status == "battle" then
        if carIndex == forApp.target then
            forApp.lifeRival = 0
        elseif carIndex == 0 then
            forApp.lifeSelf = 0
        end
    end
end)

ac.onSessionStart(function(sessionIndex,restarted)
    if restarted then
        if forApp.target ~= nil then
            setMessage("",0)
            initialize(forApp.target)
        end
    end
end)



