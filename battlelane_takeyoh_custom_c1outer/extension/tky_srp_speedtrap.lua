print("tky_srp_speedtrap")

if ac.getSim().isOnlineRace then
    return nil
end

local sp,distance
local speed
local counter = 0
local flashFlag = false

local flash = ac.LightSource(1)
flash.position = vec3(0,0,0)
--flash.spot = 0
flash.range = 20

trapPosition = {}
trapPosition[1] = vec3(1917.63, -2.80149, -7171.04)
trapPosition[2] = vec3(2532.29, -2.69177, -8246.17)
trapPosition[3] = vec3(713.32, 11.7385, -5752.64)
trapPosition[4] = vec3(2551.67, -2.51895, -8246.81)
trapPosition[5] = vec3(2480.11, 0.433426, -8029.44)
trapPosition[6] = vec3(873.712, 16.2447, -9971.5)
trapPosition[7] = vec3(5453.55, 13.6671, -7131.24)
trapPosition[8] = vec3(-8185.56, 2.06903, 11641.9)
trapPosition[9] = vec3(-118.636, 11.2132, 5245.19)
trapPosition[10] = vec3(111.832, 5.68735, 2074.13)
trapPosition[11] = vec3(-4297.89, 36.0525, -8853.23)
trapPosition[12] = vec3(-3586.07, 37.27, 12747.35)
trapPosition[13] = vec3(-713.05, 17.37, -6606.48)

cameraPosition = {}
cameraPosition[1] = vec3(1933.86, 0.0414, -7193.95)
cameraPosition[2] = vec3(2554.15, 1.34, -8276.18)
cameraPosition[3] = vec3(683.74, 15.13, -5753.92)
cameraPosition[4] = vec3(2526.56, 0.514, -8219.57)
cameraPosition[5] = vec3(2483.55, 1.21, -8007)
cameraPosition[6] = vec3(860.78, 20.25, -9957.74)
cameraPosition[7] = vec3(5462.47, 15.98, -7102.14)
cameraPosition[8] = vec3(-8165.45, 4.99, 11629.34)
cameraPosition[9] = vec3(-102.84, 14.17, 5218.71)
cameraPosition[10] = vec3(108.19, 8.74, 2054.81)
cameraPosition[11] = vec3(-4319.42, 38.67, -8857.59)
cameraPosition[12] = vec3(-3601.96, 39.55, 12747.75)
cameraPosition[13] = vec3(-709.64, 18.84, -6624.17)

function update(dt)
    sp = ac.getCar().position
    flashFlag = false
    for i = 1 , #trapPosition do
        cp = trapPosition[i]
        distance = math.sqrt((sp.x - cp.x)^2 + (sp.y - cp.y)^2 + (sp.z - cp.z)^2)
        if distance < 7 then
            flash.position = cameraPosition[i]
            flashFlag = true
        end
    end

    if flashFlag then
        speed = ac.getCarSpeedKmh()
        if speed > 105 then
            counter = counter + dt
            if counter > 0.1 then
                flash.color = rgb(0,0,0)
            elseif counter > 0 then                
                flash.color = rgb(255,0,0)
            end
        end
    else
        flash.color = rgb(0,0,0)
        counter = 0
    end
end