local centerPosition = vec3(-5550.3, 0, 13911.9)
local daikokuAreaRadius = 1000
local status = 0

local deleteMeshTable = {
"0ROAD.001",
"geo_sitamiti00_sh001.002",
"geo_parts_sh001.001",
"geo_tree04_sh001f",
"1GRASS_geo_jimen_01",
"geo_wall_siro2_sh001",
"geo_window_kuro_sh001",
"geo_window2_ao2_sh001_DFlamp",
"geo_wall_cha_sh001",
"geo_wall_siro_sh001",
"geo_window_gray2_sh001",
"geo_wall_gray_sh001",
"geo_wall_gray6_sh001",
"geo_wall_gray9_sh001",
"geo_window2_ao_sh001",
"geo_window_cha_sh001",
"geo_wall_aka_sh001.002",
"geo_window_aka_sh001.001",
"geo_window2_wcb31p_sh",
"geo_wcb29_sh001",
"geo_window3_Wab00p_sh001",
"geo_window_siro_sh001",
"geo_window_gray_sh001",
"geo_tree04_sh001b",
"geo_window2_wcb21p_sh001",
"geo_window2_aka8_zsh001",
"geo_window2_wcb25p_sh001",
"geo_window2_wcb27p_sh",
"geo_c1_mono_sh.002",
"geo_window2_wcb02p_sh001",
"geo_wall_block_sh001",
"geo_window2_wcb28p_sh001",
"geo_wall_siro3_sh",
"geo_wcb22_sh",
"geo_wall_gray4_sh.002",
"bayshore_chunk2_geo_sitamiti00_sh.003",
"bayshore_chunk2_geo_sitamiti00_sh",
"bayshore_chunk2_geo_parts_sh.003",
"bayshore_chunk2_geo_parts_sh",
"bayshore_chunk2_geo_Ground_Level_lamp101_head.001",
"bayshore_chunk2_geo_asfa00_sh.001",
"bayshore_chunk2_geo_wallw_kuro.003",
"bayshore_chunk2_geo_wallw_kuro",
"bayshore_chunk2_geo_wall_cha",
"bayshore_chunk2_geo_jimen_01.001",
"bayshore_chunk2_geo_jimen_01",
"bayshore_chunk2_geo_parts_ripu00_sh.001",
"bayshore_chunk2_geo_wcb29_sh",
"bayshore_chunk2_geo_wall_siro_sh",
"bayshore_chunk2_geo_wall_gray",
"bayshore_chunk2_geo_wall_gray6_sh",
"bayshore_chunk2_geo_wall_kuro.003",
"bayshore_chunk2_geo_wall_kuro",
"bayshore_chunk2_geo_wbb01_sh",
"bayshore_chunk2_geo_wall_siro3",
"bayshore_chunk2_geo_c1_mono_sh",
"bayshore_chunk2_geo_wallw_gray2.003",
"bayshore_chunk2_geo_wallw_gray2",
"bayshore_chunk2_geo_wallw_gray",
"bayshore_chunk2_geo_wall_gray9.003",
"bayshore_chunk2_geo_wallw_siro.003",
"bayshore_chunk2_geo_window2_wcb25p_sh",
"bayshore_chunk2_geo_wall_gray4",
"bayshore_chunk2_geo_wallw_ao.002",
"bayshore_chunk2_geo_wcb22_sh",
"bayshore_chunk2_geo_window2_wcb23p_sh",
"bayshore_chunk2_geo_window2_wcb16p_sh",
"bayshore_chunk2_geo_wall_block_sh",
"bayshore_chunk2_geo_go_ro_parts00_sh.001",
"bayshore_chunk2_geo_window2_kuro4_sh",
"bayshore_chunk2_geo_wcb20_sh",
"bayshore_chunk2_geo_wallw_aka8",
"bayshore_chunk2_geo_parts14_sh",
"bayshore_chunk2_geo_parts_hiru00_sh",
"bayshore_chunk2_geo_wallw_siro3.003",
"bayshore_chunk2_geo_wallw_siro3",
"bayshore_chunk2_geo_wall_siro2.002",
"bayshore_chunk2_geo_wall_gray9_sh",
"bayshore_chunk2_geo_parts32_sh",
"bayshore_chunk2_geo_parts9_sh.002",
"bayshore_chunk2_geo_wallw_cha10",
"bayshore_chunk2_geo_wallw_cha",
"bayshore_chunk2_geo_wall_siro2_sh",
"bayshore_chunk2_geo_parts19_sh",
"bayshore_chunk2_geo_parts34_sh.003",
"bayshore_chunk2_geo_wallw_aka.003",
"bayshore_chunk2_geo_wall_aka.003",
"bayshore_chunk2_geo_wall_aka",
"bayshore_chunk2_geo_wall_ao2.001",
"bayshore_chunk2_geo_window2_wab00p_sh",
"bayshore_chunk2_geo_wall_siro.003",
"bayshore_chunk2_geo_wall_siro",
"bayshore_chunk2_geo_window2_wcb28p_sh",
"bayshore_chunk2_geo_blue_variation",
"bayshore_chunk2_geo_wallw_ao5.003",
"bayshore_chunk2_geo_parts_hiru00_sh_still",
"bayshore_chunk2_geo_wallw_aka12",
"bayshore_chunk2_geo_girder",
"bayshore_chunk2_geo_wab02p_sh",
"bayshore_chunk2_geo_wcb00p_sh",
"bayshore_chunk2_geo_wcb02p_sh",
"bayshore_chunk2_geo_wcb16p_sh",
"bayshore_chunk2_geo_wab00p_sh"
}

local meshTable={
"bayshore_chunk2_geo_lamp701",
"bayshore_chunk2_geo_lamp701.001",
"bayshore_chunk2_geo_lamp702_head.001",
"bayshore_chunk2_geo_Ground_Level_lamp101_head",
"bayshore_chunk2_geo_fence_kanaami.001",
"bayshore_chunk2_geo_fence_kanaami",
"bayshore_chunk2_geo_fence_03",
"bayshore_chunk2_geo_fence_03.001",
"bayshore_chunk2_geo_botom_s_01.001",
"bayshore_chunk2_geo_botom_s_01",
"bayshore_chunk2_geo_botom_u_13",
"bayshore_chunk2_geo_botom_u_13.001",
"bayshore_chunk2_geo_wal_01",
"bayshore_chunk2_geo_wal_04",
"bayshore_chunk2_geo_wal_dan_04",
"bayshore_chunk2_geo_road_01",
"bayshore_chunk2_geo_road_01_seamless",
"bayshore_chunk2_geo_botom_u_01",
"geo_botom_s_002"
}
local meshTableOrig = {
"0WALL003.001_SUB0",
"0WALL004_SUB1",
"0ROAD_tky_01",
"tky_botom_s_002",
"tky_botom_u_014",
"tky_botom_u_015"
}
local i, meshName

for i,meshName in ipairs(deleteMeshTable) do
    ac.findMeshes(meshName):setTransparent(true)
    ac.findMeshes(meshName):setVisible(false)
    ac.findMeshes(meshName):setShadows(false)
end

for i,meshName in ipairs(meshTableOrig) do
    ac.findMeshes(meshName):setTransparent(true)
    ac.findMeshes(meshName):setVisible(false)
    ac.findMeshes(meshName):setShadows(false)
end

local checkPointRadius = 5
local checkPoints = {}
checkPoints[1] = vec3(-6070.66,27.2558,13998.6)
checkPoints[2] = vec3(-6076.6,18.3622,13995.7)
checkPoints[3] = vec3(-6132.17,28.8429,13767.9)
checkPoints[4] = vec3(-6135.25,18.9242,13780)
checkPoints[5] = vec3(-5934.4, 2.6, 14098.79)

print ("daikoku.lua")
local daikokuAreaFlag = false
local counter = 0

function script.update(dt)
    if counter < (counter + dt) % 0.1 then
        ac.debug("mode", daikokuAreaFlag)
        local sp = ac.getCar(0).position
        local largeDistance = sp:distance(centerPosition)
        ac.debug("largeDistance",largeDistance)
        if daikokuAreaFlag == true and largeDistance > daikokuAreaRadius then
            daikokuAreaFlag = false
            status = 0
        elseif daikokuAreaFlag == false and status ==  0 then
            for i,checkpoint in ipairs(checkPoints) do
                local distance = sp:distance(checkpoint)
                if distance < checkPointRadius then
                    daikokuAreaFlag = true
                    status = 1
                end
            end
        end

        if daikokuAreaFlag and ac.findMeshes("bayshore_chunk2_geo_road_01"):isTransparent() == false then
            for i,meshName in ipairs(meshTable) do
                ac.findMeshes(meshName):setTransparent(true)
                ac.findMeshes(meshName):setVisible(false)
                ac.findMeshes(meshName):setShadows(false)
            end
            for i,meshName in ipairs(meshTableOrig) do
                ac.findMeshes(meshName):setTransparent(false)
                ac.findMeshes(meshName):setVisible(true)
                ac.findMeshes(meshName):setShadows(true)
            end        
        elseif not(daikokuAreaFlag) and ac.findMeshes("bayshore_chunk2_geo_road_01"):isTransparent() == true then
            for i,meshName in ipairs(meshTable) do
                ac.findMeshes(meshName):setTransparent(false)
                ac.findMeshes(meshName):setVisible(true)
                ac.findMeshes(meshName):setShadows(true)
            end
            for i,meshName in ipairs(meshTableOrig) do
                ac.findMeshes(meshName):setTransparent(true)
                ac.findMeshes(meshName):setVisible(false)
                ac.findMeshes(meshName):setShadows(false)
            end       
        end
    end
    counter = (counter + dt) % 0.1
end
