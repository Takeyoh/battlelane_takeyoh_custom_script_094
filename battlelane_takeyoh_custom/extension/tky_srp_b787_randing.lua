local progress = 200
local progress2 = 0
local looptime = 240
local routeFile = "tky_srp_b787_route.ksanim"
local animFile = "tky_srp_b787_randing001.ksanim"
local b787_001 = ac.findNodes("b787a.001")
local smoke = ac.Particles.Smoke({color = rgbm(1, 1, 1, 0.3), colorConsistency = 0.5, thickness = 1, life = 10, size = 2, spreadK = 1, growK = 1, targetYVelocity = 0})


function script.update(dt)
  if ac.getSim().isPaused == false then
    if progress < looptime then
        progress = progress + dt
        b787_001:setAnimation(routeFile,progress/looptime,false)

        if progress/looptime < 0.041 then
            progress2 = 0
        elseif progress/looptime > 0.691 then
            if progress2 > 0 then
                progress2 = progress2 - dt / 8                
            end
        else
            if progress2 < 1 then
                progress2 = progress2 + dt / 8
            end

            if b787_001:getPosition().y > 100 then
                smoke:emit(b787_001:getPosition(),-b787_001:getLook(),4)
            end

        end
        b787_001:setAnimation(animFile,progress2,false)

    else
        progress = 0
    end

-- print(progress/180 .. " : " .. progress2)
  end
end