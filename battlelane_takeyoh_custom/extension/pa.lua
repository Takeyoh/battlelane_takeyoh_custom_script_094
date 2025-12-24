print("set car for PA")

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

local respawn = {
    position = ac.StructItem.vec3(),
    direction = ac.StructItem.vec3(),
}
local sharedRespawn = ac.connect(respawn,true,nil)

local pa = {
    name = ac.StructItem.string(),
}
local sharePA = ac.connect(pa,true,nil)


local area = {
    ['tatsumi']={
        start = {
            vec3(6117.05,22.7311,-4860.64),
            vec3(5677.35,15.9183,-4591.53),
            vec3(5875.83, 22.98, -4634.43),
            vec3(5891.61,23.7557,-4651.73), --pit position
        },
        position = vec3(5938.15,23.81,-4677.2),
        distance = 300,
        park = {
            {pos=vec3(5891.28, 23.81, -4652.5),dir=vec3(-0.45,0,-1),length = 5,flag=0},
            {pos=vec3(5895.98, 23.97, -4654.34),dir=vec3(-0.45,0,-1),length = 5,flag=0},
            {pos=vec3(5903.29, 24.2, -4656.96),dir=vec3(-0.45,0,-1),length = 5,flag=0},
            {pos=vec3(5915.09, 24.57, -4661.74),dir=vec3(-0.45,0,-1),length = 5,flag=0},
            {pos=vec3(5945.92, 25.32, -4669.72),dir=vec3(1,0,-0.40),length = 20,flag=0},
            {pos=vec3(5941.48, 25.37, -4678.71),dir=vec3(1,0,-0.40),length = 20,flag=0},
        }
    },
    ['shibaura']={
        start = {
            vec3(1093.15,31.8712,-4744.96),
            vec3(1098.98, 24.86, -4647.23),
        },
        position = vec3(1105.14,24.86,-4711.37),
        distance = 120,
        park = {
            {pos=vec3(1098.35, 24.86, -4745.98),dir=vec3(-1,0,0),length = 5,flag=0},
            {pos=vec3(1098.61, 24.86, -4735.82),dir=vec3(-1,0,0),length = 5,flag=0},
            {pos=vec3(1098.1, 24.87, -4718.4),dir=vec3(-1,0,0),length = 5,flag=0},
            {pos=vec3(1098.8, 24.86, -4700.35),dir=vec3(-1,0,0),length = 5,flag=0},
            {pos=vec3(1098.91, 24.86, -4687.85),dir=vec3(-1,0,0),length = 5,flag=0},
            {pos=vec3(1098.82, 24.86, -4670.04),dir=vec3(-1,0,0),length = 5,flag=0},
        }
    },
    ['oiw']={
        start = {
            vec3(940.642,4.25011,-410.903),
            vec3(964.54, 6.44, -175.32),
        },
        position = vec3(969.832,6.41,-87.2028),
        distance = 350,
        park = {
            {pos=vec3(963.06, 6.41, -163.86),dir=vec3(1,0,-0.7),length = 5,flag=0},
            {pos=vec3(963.5, 6.37, -149.01),dir=vec3(1,0,-0.7),length = 5,flag=0},
            {pos=vec3(963.51, 6.31, -135.34),dir=vec3(1,0,-0.7),length = 5,flag=0},
            {pos=vec3(964.6, 6.05, -70.61),dir=vec3(0,0,-1),length = 20,flag=0},
        }
    },
    ['heiwajiman']={
        start = {
            vec3(-249.212,5.89392,1373.47),
            vec3(-246.68, 11.88, 1355.33),
        },
        position = vec3(-137.07,6.09,1469.99),
        distance = 300,
        park = {
            {pos=vec3(-234.7, 11.88, 1354.26),dir=vec3(1,0,-0.8),length = 5,flag=0},
            {pos=vec3(-242.56, 11.88, 1343.99),dir=vec3(1,0,-0.8),length = 5,flag=0},
            {pos=vec3(-252.84, 11.88, 1331.03),dir=vec3(1,0,-0.8),length = 5,flag=0},
            {pos=vec3(-262.69, 11.88, 1318.86),dir=vec3(1,0,-0.8),length = 5,flag=0},
            {pos=vec3(-254.18, 11.88, 1345.37),dir=vec3(-1,0,0.8),length = 5,flag=0},
            {pos=vec3(-266.95, 11.88, 1329.06),dir=vec3(-1,0,0.8),length = 5,flag=0},
            {pos=vec3(-252.85, 11.91, 1321.05),dir=vec3(-1,0,-1),length = 20,flag=0},
            {pos=vec3(-233.7, 11.91, 1326.72),dir=vec3(-1,0,-1),length = 20,flag=0},            
        }
    },
    ['heiwajimas']={
        start = {
            vec3(-301.771,5.86848,1267.28),
            vec3(-144.62, 6.07, 1455.05),
        },
        position = vec3(-137.07,6.09,1469.99),
        distance = 300,
        park = {
            {pos=vec3(-137.07, 6.09, 1469.99),dir=vec3(0.45,0,-1),length = 5,flag=0},
            {pos=vec3(-140.8, 6.08, 1462.54),dir=vec3(0.45,0,-1),length = 5,flag=0},
            {pos=vec3(-148.02, 5.96, 1447.05),dir=vec3(0.45,0,-1),length = 5,flag=0},
            {pos=vec3(-152.11, 5.92, 1439.89),dir=vec3(0.4,0,-1),length = 5,flag=0},
            {pos=vec3(-160.55, 5.92, 1424.46),dir=vec3(0.35,0,-1),length = 5,flag=0},
            {pos=vec3(-97.68, 6.25, 1566.47),dir=vec3(-0.5,0,-1),length = 20,flag=0},
        }
    },
    ['daishi']={
        start = {
            vec3(-301.488,15.0566,5925.31),
            vec3(-308.23, 15.05, 6150.91),
        },
        position = vec3(-308.36,15.01,6145.63),
        distance = 250,
        park = {
            {pos=vec3(-308.36, 15.01, 6162.54),dir=vec3(1,0,0),length = 5,flag=0},
            {pos=vec3(-307.96, 15.02, 6157.87),dir=vec3(1,0,0),length = 5,flag=0},
            {pos=vec3(-307.96, 15.03, 6155.49),dir=vec3(1,0,0),length = 5,flag=0},
            {pos=vec3(-308.23, 15.06, 6148.53),dir=vec3(1,0,0),length = 5,flag=0},
            {pos=vec3(-308.2, 15.07, 6143.9),dir=vec3(1,0,0),length = 5,flag=0},
        }
    },
    ['yoyogi']={
        start = {
            vec3(-4579.81,41.4185,-8733.54),
            vec3(-4341.4, 36.28, -8877.34),
        },
        position = vec3(-4376.71,36.28,-8820.51),
        distance = 250,
        park = {
            {pos=vec3(-4345.9, 36.28, -8876.06),dir=vec3(-0.3,0,-1),length = 5,flag=0},
            {pos=vec3(-4336.96, 36.29, -8879),dir=vec3(-0.3,0,-1),length = 5,flag=0},
            {pos=vec3(-4332.49, 36.29, -8880.3),dir=vec3(-0.3,0,-1),length = 5,flag=0},
            {pos=vec3(-4318.44, 36.31, -8882.85),dir=vec3(-0.3,0,-1),length = 5,flag=0},
            {pos=vec3(-4310.36, 36.31, -8882.8),dir=vec3(-0.3,0,-1),length = 5,flag=0},
            {pos=vec3(-4292.72, 36.33, -8884.01),dir=vec3(-0.75,0,-1),length = 20,flag=0},
            {pos=vec3(-4296.36, 36.33, -8884.29),dir=vec3(-0.75,0,-1),length = 20,flag=0},
        }
    },
    ['daikoku']={
        start = {
            vec3(-6042.2,29.6794,14049.7),
            vec3(-6139.02,19.2337,13759.3),
            vec3(-5934.4, 2.6, 14098.79),
        },
        position = vec3(-5907.65,1.19473,13902.3),
        distance = 350,
        park = {
            {pos=vec3(-5894.44, 2.34, 14133.76),dir=vec3(1,0,-0.5),length = 5,flag=0},
            {pos=vec3(-5917.36, 2.34, 14133.1),dir=vec3(1,0,-0.5),length = 5,flag=0},
            {pos=vec3(-5908.71, 2.43, 14120.56),dir=vec3(1,0,-0.5),length = 5,flag=0},
            {pos=vec3(-5900.44, 2.53, 14107.85),dir=vec3(1,0,-0.5),length = 5,flag=0},
            {pos=vec3(-5918.44, 2.67, 14089.71),dir=vec3(1,0,-0.5),length = 5,flag=0},
            {pos=vec3(-5874.94, 2.52, 14110.67),dir=vec3(1,0,-0.5),length = 5,flag=0},
            {pos=vec3(-5914.39, 2.79, 14074.22),dir=vec3(1,0,-0.5),length = 5,flag=0},
            {pos=vec3(-5851.61, 2.94, 14056.07),dir=vec3(-1,0,0.3),length = 20,flag=0},
            {pos=vec3(-5858.53, 3, 14048.57),dir=vec3(-1,0,0.3),length = 20,flag=0},
            {pos=vec3(-5870.58, 3.08, 14038.11),dir=vec3(-1,0,0.3),length = 20,flag=0},
        }
    },
    ['oie']={
        start = {
            vec3(923.5,-1.33759,-823.79),
            vec3(936.04, -2.33, -1139.78),
        },
        position = vec3(940.19, -2.23, -1138.32),
        distance = 350,
        park = {
            {pos=vec3(937.53, -2.34, -1144.9),dir=vec3(1,0,0.3),length = 5,flag=0},
            {pos=vec3(939.36, -2.36, -1152.17),dir=vec3(1,0,0.3),length = 5,flag=0},
            {pos=vec3(941.41, -2.37, -1159.51),dir=vec3(1,0,0.3),length = 5,flag=0},
            {pos=vec3(924.03, -2.31, -1134.7),dir=vec3(-0.3,0,1),length = 20,flag=0},
        }
    },
    ['hakozaki']={
        start = {
            vec3(3691,19.39,-8907.17),
            vec3(3836.46,11.3327,-8725.32),
            vec3(3975.76, 9.36, -8989.54),
        },
        position = vec3(3975.76, 9.36, -8989.54),
        distance = 350,
        park = {
            {pos=vec3(3983.85, 9.94, -8997.12),dir=vec3(0.9,0,1),length = 5,flag=0},
            {pos=vec3(3988.27, 9.87, -9001.27),dir=vec3(0.9,0,1),length = 5,flag=0},
            {pos=vec3(3975.94, 9.91, -9006.65),dir=vec3(-0.9,0,-1),length = 5,flag=0},
            {pos=vec3(3971.39, 9.98, -9002.12),dir=vec3(-0.9,0,-1),length = 5,flag=0},
            {pos=vec3(3966.48, 9.97, -9010.28),dir=vec3(0.9,0,-1),length = 20,flag=0},
            {pos=vec3(3961.36, 9.99, -9010.49),dir=vec3(0.9,0,-1),length = 20,flag=0},
        }
    },
}

sharePA.name = ""
local setting = 0
local shuffle = {}
carsStatus[0].isParking = false
for i = 1, totalCars - 1 do
    table.insert(shuffle,i)
    carsStatus[i].isParking = false
end

-- for debug
--physics.setCarPosition(0,vec3(-4579.81,41.4185,-8733.54))
--sharePA.name = "daikoku"

function script.update(dt)
    if sharePA.name == "" then
        for i , areaData in pairs(area) do
            for j = 1, #area[i].start do
                local distance = ac.getCar(0).position:distance(area[i].start[j])
                if distance < 6 then
                        sharePA.name = i
                    break
                end
            end
        end
    else
        for i = 1, totalCars - 1 do
            if carsStatus[i].isParking then
                physics.overrideSteering(i, 0)
            end
        end
        
        local distance = ac.getCar(0).position:distance(area[sharePA.name].position)
        if distance > area[sharePA.name].distance then
                sharePA.name = ""
        end
    end

    if sharePA.name ~= "" then
        carSetting()

        if setting == 1 then
            for i = 1 , #area[sharePA.name].park do
                if area[sharePA.name].park[i].flag > 0 then
                    physics.setGentleStop(area[sharePA.name].park[i].flag, true)
                    local calcDistance = ac.getCar(area[sharePA.name].park[i].flag).position:distance(area[sharePA.name].park[i].pos)
                    if calcDistance > 10 then
                        physics.setCarPosition(area[sharePA.name].park[i].flag,area[sharePA.name].park[i].pos + vec3(0,0.01,0),area[sharePA.name].park[i].dir)
                    end
                end
            end
        end
    else
        carRelease()
    end
    ac.debug("pa",sharePA.name)
    ac.debug("setting",setting)
end


function carSetting()
    if setting == 0 then
        math.randomseed(os.time()) 
        for i = #shuffle, 2, -1 do
            local j = math.random(i)
            shuffle[i], shuffle[j] = shuffle[j], shuffle[i]
        end

        for j = 1, totalCars - 1 do
            local carIndex = shuffle[j]
            if carsStatus[carIndex].battle == 0 
            and (carsDistance[0]['car'..carIndex] > 200 
            or carsDistance[0]['car'..carIndex] < -100) then
                for i = 1, #area[sharePA.name].park do
                    if area[sharePA.name].park[i].flag == 0 
                      and carsStatus[carIndex].length < area[sharePA.name].park[i].length 
                      and carsStatus[carIndex].length > area[sharePA.name].park[i].length - 15 then
                        physics.setCarPosition(carIndex,area[sharePA.name].park[i].pos+ vec3(0,0.01,0),area[sharePA.name].park[i].dir)
                        local calcDistance = ac.getCar(area[sharePA.name].park[i].flag).position:distance(area[sharePA.name].park[i].pos)
                        if calcDistance > 0.5 then
                            physics.setCarPosition(carIndex,area[sharePA.name].park[i].pos + vec3(0,0.01,0),area[sharePA.name].park[i].dir)
                        end
                        physics.overrideSteering(carIndex, 0)
                        area[sharePA.name].park[i].flag = carIndex
                        carsStatus[carIndex].isParking = true
                        print("park" .. i .. ":" .. carIndex)
                        break
                    end
                end
                setting = 1
            end
        end
    end
end

function carRelease()
    if setting == 1 then
        for i,paData in pairs(area) do
            for j = 1, #paData.park do
                if area[i].park[j].flag > 0 then
                    physics.overrideSteering(area[i].park[j].flag, math.nan)
                    physics.setGentleStop(area[i].park[j].flag, false)
                    physics.setCarPosition(area[i].park[j].flag,sharedRespawn.position, sharedRespawn.direction)
                    carsStatus[area[i].park[j].flag].isParking = false
                    print(area[i].park[j].flag .. " is released.")
                    area[i].park[j].flag = 0
                end
            end
        end
        setting = 0
    end
end

ac.onCarJumped(0,function(carIndex)
    sharePA.name = ""
    setting = 1
    carRelease()
end)
