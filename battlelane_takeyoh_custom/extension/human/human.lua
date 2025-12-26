print("human")

if ac.getPatchVersionCode() < 3116 then
    return nil
end

local humans = {}
humans["man1"] = {kn5file = "man1.kn5"}
humans["man2"] = {kn5file = "man2.kn5"}
humans["man3"] = {kn5file = "man3.kn5"}
humans["man4"] = {kn5file = "man4.kn5"}
humans["man5"] = {kn5file = "man5.kn5"}
humans["man6"] = {kn5file = "man6.kn5"}
humans["man7"] = {kn5file = "man7.kn5"}
humans["man8"] = {kn5file = "man8.kn5"}
humans["man9"] = {kn5file = "man9.kn5"}
humans["man10"] = {kn5file = "man10.kn5"}
humans["girl1"] = {kn5file = "girl1.kn5"}
humans["girl2"] = {kn5file = "girl2.kn5"}
humans["girl3"] = {kn5file = "girl3.kn5"}
humans["girl4"] = {kn5file = "girl4.kn5"}

for name,value in pairs(humans) do
    humans[name].shader = ac.findNodes("dynamicRoot:yes"):createNode(name,true)
    humans[name].shader:loadKN5(humans[name].kn5file)
end

local paAction = {}
local filename = __dirname .. "\\paAction.json"
if io.fileExists(filename) then
    io.loadAsync(filename, function(err, data)
        paAction = stringify.parse(data)
    end)
end

if paAction == {} then 
    return nil
end

local pa = {
    name = ac.StructItem.string(),
}
local sharePA = ac.connect(pa,true,nil)


function humanAnim(human,dt)
    if human.counter == 0 then
        human.start = human.action[human.status].start
        human.finish = human.action[human.status].finish
        human.direction = human.action[human.status].direction
        human.duration = human.action[human.status].duration
        human.loopTime = human.action[human.status].loopTime
        human.animFile = human.action[human.status].action

        human.status = human.status + 1
        if human.status > #human.action then human.status = 1 end
    end
    human.shader:setPosition(human.start + (human.finish-human.start)*human.counter)
    human.shader:setOrientation(human.direction,nil)
    human.shader:setAnimation(human.animFile,human.loop,false)
    human.loop = (human.loop + dt/human.loopTime) % 1
    human.counter = human.counter + dt/human.duration
    if human.counter >= 0.995 then
        human.counter = 0
        human.loop = 0
    end
end



function humanSetup(pa)
    local human = nil
    local actions = nil
    for i = 1, #pa do
        for key, value in pairs(pa[i]) do
            if key == "target" then
                human = humans[value]
            elseif key == "actions" then
                actions = value
            end
        end
        if human ~= nil then
            human.start = vec3(0,-100,0)
            human.finish = vec3(0,-100,0)
            human.direction = vec3(0,0,0)
            human.counter = 0
            human.duration = 0
            human.loop = 0
            human.loopTime = 0
            human.animFile = nil
            human.status = 1
            human.action = nil

            if actions ~= nil then
                human.action = actions
            end
        end
    end
end

function humanExec(dt)
    for key, value in pairs(humans) do
        if value.action ~= nil then
            humanAnim(humans[key],dt)
        end
    end
end

function humanReset()
    for key, value in pairs(humans) do
        value.start = vec3(0,-100,0)
        value.finish = vec3(0,-100,0)
        value.direction = vec3(0,0,0)
        value.counter = 0
        value.duration = 0
        value.loop = 0
        value.loopTime = 0
        value.animFile = nil
        value.status = 1
        value.action = nil
    end
end

local status = ""
function script.update(dt)
    if sharePA.name ~= "" and status ~= sharePA.name then
        if paAction[sharePA.name] ~= nil then
            humanSetup(paAction[sharePA.name])
            status = sharePA.name
        end
    elseif status ~= "" and sharePA.name == "" then
        humanReset()
        status = ""
    elseif status == sharePA.name and not ac.getSim().isPaused then
        humanExec(dt)
    end

    ac.debug("pa",sharePA.name)
    ac.debug("status", status)
end