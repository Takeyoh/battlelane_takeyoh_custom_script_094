print('burnedout car')

local accident ={
    ac.StructItem.key('tky_srp_battlelayout_accident'),
    burnedout = ac.StructItem.boolean(),
    accident1 = ac.StructItem.boolean(),
    accident2 = ac.StructItem.boolean(),
    addAccident = ac.StructItem.boolean(),
}
local sharedAccident = ac.connect(accident,true,nil)

local smoke = ac.Particles.Smoke({color = rgbm(0.5, 0.5, 0.5, 0.5), colorConsistency = 0.5, thickness = 1, life = 10, size = 0.2, spreadK = 1, growK = 1, targetYVelocity = 0})
local smoke2 = smoke
local spark = ac.Particles.Sparks({color = rgbm(0.5, 0, 0, 0.5), life = 4, size = 0.2, directionSpread = 1, positionSpread = 0.2})
local flame = ac.Particles.Flame({color = rgbm(1, 0.1, 0.0, 1), size = 0.5, temperatureMultiplier = 1, flameIntensity = 1})
local flame2 = flame
local rand = math.seededRandom(math.randomKey())

function setup()
    -- main
    local collider = physics.RigidBody("burnedout_cars_collider.kn5", 100000,vec3(0,0,0),true,true) 
    if sharedAccident.addAccident then
        rand = math.seededRandom(math.randomKey())
    else
        rand = 0
    end
    print(rand)
    if rand > 0.5 then
        sharedAccident.burnedout = true
    -- Show obstacles
        local meshObj = ac.findNodes("burnedout_base")
        meshObj:setVisible(true)
        meshObj:setShadows(true)
        meshObj:setTransparent(false)

        local meshBoard = ac.findMeshes("denko_keijiban_burnedout1")
        meshBoard:setVisible(true)
        meshBoard:setShadows(true)
        meshBoard:setTransparent(false)

        meshBoard = ac.findMeshes("denko_keijiban_burnedout2")
        meshBoard:setVisible(true)
        meshBoard:setShadows(true)
        meshBoard:setTransparent(false)
        
        meshBoard = ac.findMeshes("denko_keijiban_chunk_1")
        meshBoard:setVisible(false)
        meshBoard:setShadows(false)
        meshBoard:setTransparent(true)

        meshBoard = ac.findMeshes("denko_keijiban_chunk_c1in_14")
        meshBoard:setVisible(false)
        meshBoard:setShadows(false)
        meshBoard:setTransparent(true)

    else
        sharedAccident.burnedout = false
    -- Hide obstacles
        collider:dispose()
        local meshObj = ac.findNodes("burnedout_base")
        meshObj:setVisible(false)
        meshObj:setShadows(false)
        meshObj:setTransparent(true)

        local meshBoard = ac.findMeshes("denko_keijiban_burnedout1")
        meshBoard:setVisible(false)
        meshBoard:setShadows(false)
        meshBoard:setTransparent(true)

        meshBoard = ac.findMeshes("denko_keijiban_burnedout2")
        meshBoard:setVisible(false)
        meshBoard:setShadows(false)
        meshBoard:setTransparent(true)

        meshBoard = ac.findMeshes("denko_keijiban_chunk_1")
        meshBoard:setVisible(true)
        meshBoard:setShadows(true)
        meshBoard:setTransparent(false)

        meshBoard = ac.findMeshes("denko_keijiban_chunk_c1in_14")
        meshBoard:setVisible(true)
        meshBoard:setShadows(true)
        meshBoard:setTransparent(false)

    end
end

setup()

ac.onSessionStart(function(sessionIndex,restart)
    setup()
end)

function script.update(dt)
    if rand > 0.5 then
        smoke:emit(vec3(1328.36, 9.91, -6080.23),vec3(0,1,0),10)
        smoke2:emit(vec3(1326.63, 9.91, -6083.37),vec3(0,1,0),10)
        spark:emit(vec3(23.25, -1, 211.96),vec3(0,1,0),10)
        flame:emit(vec3(1327.88 , 9.93823, -6068.1),vec3(0,1,0),1)        
        flame2:emit(vec3(1327.08 , 9.93823 , -6065.71),vec3(0,1,0),1)        
    end
end
