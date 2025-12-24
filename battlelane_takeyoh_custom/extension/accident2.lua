print('accident2')

local accident ={
    ac.StructItem.key('tky_srp_battlelayout_accident'),
    burnedout = ac.StructItem.boolean(),
    accident1 = ac.StructItem.boolean(),
    accident2 = ac.StructItem.boolean(),
    addAccident = ac.StructItem.boolean(),
}
local sharedAccident = ac.connect(accident,true,nil)

local rand = math.seededRandom(math.randomKey())

function setup()
    -- main
    local collider = physics.RigidBody("accident2_collider.kn5", 100000,vec3(0,0,0),true,true) 
    if sharedAccident.addAccident then
        rand = math.seededRandom(math.randomKey())
    else
        rand = 0
    end
    print(rand)
    if rand > 0.5 then
        sharedAccident.accident2 = true
    -- Show obstacles
        local meshObj = ac.findNodes("accident2")
        meshObj:setVisible(true)
        meshObj:setShadows(true)
        meshObj:setTransparent(false)

    else
        sharedAccident.accident2 = false
    -- Hide obstacles
        collider:dispose()
        local meshObj = ac.findNodes("accident2")
        meshObj:setVisible(false)
        meshObj:setShadows(false)
        meshObj:setTransparent(true)
    end
end

setup()

ac.onSessionStart(function(sessionIndex,restart)
    setup()
end)
