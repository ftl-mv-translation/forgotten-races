local eye = mods.eyesystem

-- Check for the right ship

local function isPrecursorShip(ship)
    return ship.myBlueprint.blueprintName == "PLAYER_SHIP_FR_SPHERAX" or ship.myBlueprint.blueprintName == "PLAYER_SHIP_FR_SPHERAX_2" or ship.myBlueprint.blueprintName == "PLAYER_SHIP_FR_SPHERAX_3" and Hyperspace.ships.player == ship
end

-- ALL EYE Functions
local saveDrone = nil
local droneTimer = 5
local saveProj = nil
local projTimer = 0
local saveSpeed = 0
local function resetEyeLook(ship, projectile, drone)
    if drone and saveDrone ~= drone then saveDrone = drone droneTimer = 3 end

    if saveProj and saveProj == projectile then return false
    elseif saveProj and saveProj ~= projectile then saveProj.speed_magnitude = saveSpeed end

    return true
end

local function eyeIdle(ship)
    local function internal(nothing)
        return
    end
    return {Hyperspace.Mouse.position.x, Hyperspace.Mouse.position.y, internal, false, 1}
end

local function eyeBoarder(ship)
    local function internal(crew)
        crew.health.first = math.min(crew.health.first - 0.05, crew.health.second)
    end
    local crews = ship.vCrewList
    for i = 0, crews:size()-1 do
        if crews[i].iShipId == 1 then
            return {crews[i].x, crews[i].y, internal, crews[i], 2}
        end
    end
    return false
end

local function eyeFriendlyHurt(ship)
    local function internal(crew)
        crew.health.first = math.min(crew.health.first + 0.05, crew.health.second)
    end
    local crews = ship.vCrewList
    local index = -1
    local saveHp = 999999
    for i = 0, crews:size()-1 do
        local health = crews[i].health.first
        if crews[i] and health and crews[i].iShipId == 0 and health ~= crews[i].health.second and health < saveHp then
            index = i
            saveHp = health
        end
    end

    if index == -1 then return false end
    return {crews[index]:GetPosition().x, crews[index]:GetPosition().y, internal, crews[index], 2}
end

local function eyeDrone(ship)
    local function internal(drone)
        resetEyeLook(ship, nil, drone)

        droneTimer = math.max(droneTimer - Hyperspace.FPS.SpeedFactor/16, 0)
        if droneTimer == 0 then
            drone:BlowUp(false)
            droneTimer = 4
        end
    end
    if not Hyperspace.ships.enemy then return false end
    local drones = Hyperspace.ships.enemy.spaceDrones
    for i = 0, drones:size()-1 do
        if drones[i] and drones[i]:GetOwnerId() == 1 and drones[i].powered and drones[i].currentSpace == 0 then
            return {drones[i].currentLocation.x, drones[i].currentLocation.y, internal, drones[i], 3}
        end
    end
    return false
end

local function eyeProjectile(ship)
    local function internal(projectile)
        local ret = resetEyeLook(ship, projectile, nil)
        if not ret then return end
        saveProj = projectile
        saveSpeed = projectile.speed_magnitude
        projectile.speed_magnitude = projectile.speed_magnitude / 4
        projectile.damage.iShieldPiercing = 0
    end
    local space = Hyperspace.App.world.space
    local projectiles = space.projectiles
    local saveDist = 999999
    local index = -1
    for i = 0, projectiles:size()-1 do
        local projectileType = Hyperspace.Blueprints:GetWeaponBlueprint(projectiles[i].extend.name).typeName
        if projectiles[i].ownerId == 1 and
            eye.distance(eye.iris.baseX,eye.iris.baseY,projectiles[i].position.x, projectiles[i].position.y) < saveDist and
            (projectileType == "LASER" or projectileType == "MISSILES") and
            projectiles[i].currentSpace == 0 and
            not projectiles[i].missed
            then

            index = i
            saveDist = eye.distance(eye.iris.baseX,eye.iris.baseY,projectiles[i].position.x, projectiles[i].position.y)
        end
    end

    if index == -1 then return false end
    return {projectiles[index].position.x, projectiles[index].position.y, internal, projectiles[index], 4}
end

local priorityList = {
    [1] = eyeProjectile, [2] = eyeDrone, [3] = eyeBoarder, [4] = eyeFriendlyHurt, [5] = eyeIdle
}

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
    if not isPrecursorShip(ship) then return end
    local data
    for _, func in ipairs(priorityList) do
        data = func(ship)
        if data then break end
    end

    if not data then return end
    eye.target.x = data[1]
    eye.target.y = data[2]
    data[3](data[4])
    eye.iris.textureIndex = data[5]
end)


local fancyRotation = 0
script.on_render_event(Defines.RenderEvents.SHIP_ENGINES, function(ship, _, alpha)

    if not isPrecursorShip(Hyperspace.Global.GetInstance():GetShipManager(ship.iShipId)) then return end

    local position = eye.getPupilPosition()
    local positionIris = eye.getIrisPosition()

	if not Hyperspace.App.gui.bPaused then fancyRotation = (fancyRotation + 1) % 360 end
    local angle = ((position.x + positionIris.y)*5 + fancyRotation) % 360
    local angle2 = ((position.y + positionIris.x)*5 - fancyRotation) % 360
    

    eye.pupil.alpha = alpha
    eye.iris.alpha = alpha

    eye.renderIris(angle, positionIris.x, positionIris.y)
    eye.renderPupil(angle2, position.x, position.y)

end, function() end)