print("getCarStatus")
if ac.getSim().carsCount == 1 then return nil end
if not ac.hasTrackSpline() then return nil end
if ac.getSim().isOnlineRace then return nil end

local carsStatus = {}
local carsDistance = {}
for i = 0 , ac.getSim().carsCount - 1 do
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

    carsStatus[i].id = ac.getCarID(i)
    carsStatus[i].name = ac.getCarName(i)
    carsStatus[i].mass = ac.getCar(i).mass
    carsStatus[i].dot = 1
    carsStatus[i].isParking = false

    local carTag = ac.getCarTags(i)
    carsStatus[i].isRoadRage = false
    if carTag ~= nil and #carTag > 0 then
        for j = 1, #carTag do
            if string.lower(carTag[j]) == "beast" then
                carsStatus[i].isRoadRage = true
            end
        end
    end
    carsStatus[i].angerSwitch = false

    local distanceData = {ac.StructItem.key('tky_srp_cardistance' .. i),}
    for i = 0, ac.getSim().carsCount - 1 do
        distanceData['car'..i] = ac.StructItem.float()
    end
    carsDistance[i] = ac.connect(distanceData,true,nil)

    local checkPolice = false
    if string.find(string.lower(ac.getCarName(i)),"police") ~= nil
      or string.find(string.lower(ac.getCarID(i)),"police") ~= nil
      or string.find(string.lower(ac.getCarSkinID(i)),"police") ~= nil then
        checkPolice = true
    end
    carsStatus[i].isPolice = checkPolice

end

function getStatus(carNumber)
    local currentCar = ac.getCar(carNumber)
    local currentCarTrackCoordinate = ac.worldCoordinateToTrack(currentCar.position)
    local trackSide = ac.getTrackAISplineSides(currentCarTrackCoordinate.z)
    local distantfromAILine = 0
    if currentCarTrackCoordinate.x < 0 then
        distantfromAILine = currentCarTrackCoordinate.x * trackSide.x
    else
        distantfromAILine = currentCarTrackCoordinate.x * trackSide.y
    end
    carsStatus[carNumber].position = currentCar.position
    carsStatus[carNumber].speed = currentCar.speedKmh
    carsStatus[carNumber].compass = currentCar.compass
    carsStatus[carNumber].width = currentCar.aabbSize.x
    carsStatus[carNumber].length = currentCar.aabbSize.z
    carsStatus[carNumber].lengthFront = currentCar.aabbSize.z/2 + currentCar.aabbCenter.z
    carsStatus[carNumber].lengthRear = currentCar.aabbSize.z/2 - currentCar.aabbCenter.z
    carsStatus[carNumber].progress = currentCarTrackCoordinate.z
    carsStatus[carNumber].fromLine = distantfromAILine
end

local progressPerMeter = 1/(ac.getSim().trackLengthM)
function calcDistance(from,to)
    local distance = to - from
    if distance > 0.95 then distance = distance - 1 end
    if distance < -0.95 then distance = distance + 1 end
    return distance / progressPerMeter
end

local totalCar = ac.getSim().carsCount
local count = 0

function script.update(dt)
    for i = 0, totalCar - 1 do
        if not carsStatus[i].isParking then
            if count > (count + dt) % 0.05 then
                getStatus(i)
                for j = 0, totalCar - 1 do
                    carsDistance[i]['car'..j] = calcDistance(carsStatus[i].progress,carsStatus[j].progress)
                end
            end

            -- angerSwitch
            if carsStatus[i].isRoadRage then
                if carsStatus[i].angerSwitch == false then
                    if (carsStatus[i].isParking == false and carsDistance[i]['car0'] > 0 and carsDistance[i]['car0'] < 20 and ac.getCar(0).brake > 0.8)
                    or (carsStatus[i].isParking == false and carsDistance[i]['car0'] < 0 and carsDistance[i]['car0'] > -20 and ac.getCar(0).hornActive) then
                        carsStatus[i].angerSwitch = true
                    end
                else
                    if carsDistance[i]['car0'] > 50 then
                        carsStatus[i].angerSwitch = false
                    end
                end
            end
        end
    end
    ac.store('tky_srp_angerswitch',JSON.stringify(angerSwitch))
    ac.debug("car0 name", carsStatus[0].name)
    count = (count + dt) % 0.1
end

ac.onCarJumped(-1, function(carIndex)
    getStatus(carIndex)
    for j = 0, totalCar - 1 do
        carsDistance[carIndex]['car'..j] = calcDistance(carsStatus[carIndex].progress,carsStatus[j].progress)
    end
end)
