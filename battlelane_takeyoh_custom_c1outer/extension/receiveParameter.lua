print ("track parameter receive from lua app.")

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


function script.update(dt)
    local data = JSON.parse(ac.load('tky_srp_trackParam'))
    if data ~= nil then
        sharedTrackParam.largeCarMass = data.largeCarMass
        sharedTrackParam.rightLaneRate = data.rightLaneRate
        sharedTrackParam.leftLaneRate = data.leftLaneRate
        sharedTrackParam.rightLaneSpeed = data.rightLaneSpeed
        sharedTrackParam.centerLaneSpeed = data.centerLaneSpeed
        sharedTrackParam.leftLaneSpeed = data.leftLaneSpeed
        sharedTrackParam.beastSpeed = data.beastSpeed
        sharedTrackParam.trafficCarDistance = data.trafficCarDistance
        sharedTrackParam.rivalCarSlowdown = data.rivalCarSlowdown
    end
    
    ac.debug("largeCarMass: ", sharedTrackParam.largeCarMass)
    ac.debug("rightLaneRate: " , sharedTrackParam.rightLaneRate)
    ac.debug("leftLaneRate: " , sharedTrackParam.leftLaneRate)
    ac.debug("trafficDistance: " , sharedTrackParam.trafficCarDistance)
    ac.debug("rivalSlowdown: " , sharedTrackParam.rivalCarSlowdown)
    ac.debug("rightLaneSpeed: " , sharedTrackParam.rightLaneSpeed)
    ac.debug("centerLaneSpeed: " , sharedTrackParam.centerLaneSpeed)
    ac.debug("leftLaneSpeed: " , sharedTrackParam.leftLaneSpeed)
    ac.debug("beastSpeed: " , sharedTrackParam.beastSpeed)
end

