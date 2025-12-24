if ac.getSim().isOnlineRace then return nil end

print("transport")

local point = {   
   { position = vec3(5875.83, 22.98, -4634.43), direction = vec3(1,0,-0.4)}, -- tatsumi PA
   { position = vec3(1098.98, 24.86, -4647.23), direction = vec3(-1,0,0)}, -- shibaura PA
   { position = vec3(963.18, 6.44, -175), direction = vec3(1,0,-0.7)},  -- oiw PA
   { position = vec3(-144.62, 6.07, 1455.05), direction = vec3(0.5,0,-1)},  -- heiwajima south PA
   { position = vec3(-308.23, 15.05, 6150.91), direction = vec3(1,0,0)},  -- daishi PA
   { position = vec3(-246.68, 11.88, 1355.33), direction = vec3(-1,0,0.8)},  -- heiwajima north PA
   { position = vec3(-4341.4, 36.28, -8877.34), direction = vec3(-0.3,0,-1)},  -- yoyogi PA
--   { position = vec3(-5934.4, 2.6, 14098.79), direction = vec3(1,0,-0.5)},  -- daikoku PA
}
local point2 = {
   { position = vec3(3407.15, 30.4, -3393.47), direction = vec3(1,0,1)},  -- ariake JCT
   { position = vec3(1105.25, 32.37, -4711.56), direction = vec3(0,0,1)},  -- shibaura PA
   { position = vec3(1330.93, 9.66, -5731.27), direction = vec3(0,0,1)},  -- shiodome
   { position = vec3(-730.95, 17.29, -6588.61), direction = vec3(-1,0,1)},  -- tanimachi JCT
   { position = vec3(327.66, 11.87, -8294.17), direction = vec3(-0.4,0,1)},  -- miyake JCT
   { position = vec3(1920.43, 12.75, -9737.16), direction = vec3(-1,0,-0.2)},  -- kandabashi JCT
   { position = vec3(2985.08, 18.65, -9124.49), direction = vec3(0.6,0,-1)},  -- edobashi JCT
   { position = vec3(2763.77, -0.762, -8715.49), direction = vec3(-0.6,0,1)},  -- edobashi JCT
   { position = vec3(1339.26, 14.84, -5861.52), direction = vec3(0,0,-1)},  -- hamasakibashi JCT
   { position = vec3(-179.7, 6.06, 1465.16), direction = vec3(0.5,0,1)},  -- heiwajima gate
   { position = vec3(-326.69, 15.19, 6081.69), direction = vec3(0,0,-1)},  -- daishi gate
   { position = vec3(-348.78, 16.09, 6004.29), direction = vec3(-0.3,0,1)},  -- daishi gate (north)
   { position = vec3(-6485.46, 10.93, 10935.31), direction = vec3(1,0,-0.5)},  -- namamugi JCT
   { position = vec3(-6158.66, 19.48, 13680.83), direction = vec3(-0.2,0,-1)},  -- daikoku PA JCT
   { position = vec3(4110.59, -8.44, 8480.85), direction = vec3(-0.7,0,1)},  -- ukishima Gate (north)
   { position = vec3(4037.63, -6.67, 8653.18), direction = vec3(0.8,0,-1)},  -- ukishima Gate
   { position = vec3(905.144, 6.48401, -105.988), direction = vec3(0,0,1)},  -- oi Gate
   { position = vec3(3119.37, -2.67, 4147.48), direction = vec3(-1,0,-0.8)},  -- haneda (west)
}

local srp094PTB = {
   { position = vec3(936.04, -2.33, -1139.78), direction = vec3(1,0,0.3)},  -- oie PA
   { position = vec3(3975.76, 9.36, -8989.54), direction = vec3(0.9,0,1)},  -- hakozaki PA
}

-- SRP0.9.4 PTB1の場合、PAデータを2つ追加。
if string.find(ac.getTrackID(),"shutoko_revival_project") ~= nil then
    for i,v in pairs(srp094PTB) do
        table.insert(point,v)
    end
end

--point2をマージ
for i,v in pairs(point2) do
    table.insert(point,v)
end


local i = 1
local timer = 0
function script.update(dt)
    if timer > 0 then 
        timer = timer - dt
    elseif timer < 0 then
        i = i - 1
        if i < 1 then i = #point end
        timer = 0
    end
    if ac.isKeyReleased(ui.KeyIndex.M) then
print("point..." .. i)
        physics.setCarPosition(0,point[i].position, point[i].direction)
        i = i + 1
        if i > #point then
            i = 1
        end
        timer = 5
    end

end
