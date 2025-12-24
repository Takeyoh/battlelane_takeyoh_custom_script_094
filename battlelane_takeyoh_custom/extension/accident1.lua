print('accident1')

local accident ={
    ac.StructItem.key('tky_srp_battlelayout_accident'),
    burnedout = ac.StructItem.boolean(),
    accident1 = ac.StructItem.boolean(),
    accident2 = ac.StructItem.boolean(),
    addAccident = ac.StructItem.boolean(),
}
local sharedAccident = ac.connect(accident,true,nil)

local smoke = ac.Particles.Smoke({color = rgbm(0.5, 0.5, 0.5, 0.5), colorConsistency = 0.5, thickness = 1, life = 2, size = 0.2, spreadK = 1, growK = 1, targetYVelocity = 0})

local rand = math.seededRandom(math.randomKey())

function setup()
    -- main
    local collider = physics.RigidBody("accident1_collider.kn5", 100000,vec3(0,0,0),true,true) 
    if sharedAccident.addAccident then
        rand = math.seededRandom(math.randomKey())
    else
        rand = 0
    end
    print(rand)
    if rand > 0.5 then
        sharedAccident.accident1 = true
    -- Show obstmacles
        local meshObj = ac.findNodes("accident1")
        meshObj:setVisible(true)
        meshObj:setShadows(true)
        meshObj:setTransparent(false)

        local meshBoard = ac.findMeshes("denko_keijiban_chunk_c1out_2")
        meshBoard:setVisible(false)
        meshBoard:setShadows(false)
        meshBoard:setTransparent(true)

        meshBoard = ac.findMeshes("denko_keijiban_accident")
        meshBoard:setVisible(true)
        meshBoard:setShadows(true)
        meshBoard:setTransparent(false)

        local meshSig = ac.findMeshes("signal_accident1")
        meshSig:setVisible(true)
        meshSig:setShadows(true)
        meshSig:setTransparent(false)
        
    else
        sharedAccident.accident1 = false
    -- Hide obstacles
        collider:dispose()
        local meshObj = ac.findNodes("accident1")
        meshObj:setVisible(false)
        meshObj:setShadows(false)
        meshObj:setTransparent(true)

        local meshBoard = ac.findMeshes("denko_keijiban_chunk_c1out_2")
        meshBoard:setVisible(true)
        meshBoard:setShadows(true)
        meshBoard:setTransparent(false)

        meshBoard = ac.findMeshes("denko_keijiban_accident")
        meshBoard:setVisible(false)
        meshBoard:setShadows(false)
        meshBoard:setTransparent(true)

        local meshSig = ac.findMeshes("signal_accident1")
        meshSig:setVisible(false)
        meshSig:setShadows(false)
        meshSig:setTransparent(true)

    end
end

setup()

ac.onSessionStart(function(sessionIndex,restart)
    setup()
end)

function script.update(dt)
    if rand > 0.5 then
        smoke:emit(vec3(278.954, 7.84987, -8468.52),vec3(0,1,0),1)
    end
end
