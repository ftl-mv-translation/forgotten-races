local vter = mods.fusion.vter

-- Artillery surges

local artillerySurges = {}
artillerySurges["FR_ARTILLERY_COMMONWEALTH_B"] = "FR_ARTY_DRONE_SURGE"
artillerySurges["FR_ARTILLERY_COMMONWEALTH_DAISY"] = "FR_ARTY_DAISY_DRONE_SURGE"
artillerySurges["FR_ARTILLERY_ALT_WITHER_C"] = "FR_ARTY_BARRAGE_SURGE"
artillerySurges["FR_ARTILLERY_TESTER_B"] = "FR_ARTY_TESTER_DRONE_SURGE"

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
    local capp = Hyperspace.Global.GetInstance():GetCApp()
    local surgeEvent = artillerySurges[weapon.blueprint.name]
    if surgeEvent then
        projectile:Kill()
        if not capp.gui.event_pause then
            Hyperspace.CustomEventsParser.GetInstance():LoadEvent(capp.world, surgeEvent, false, -1)
        end
    end
end)


-- Returns a table of all crew belonging to the given ship on the room tile at the given point
local function get_ship_crew_point(shipManager, x, y, maxCount)
    res = {}
    x = x//35
    y = y//35
    for crewmem in vter(shipManager.vCrewList) do
        if crewmem.iShipId == shipManager.iShipId and x == crewmem.x//35 and y == crewmem.y//35 then
            table.insert(res, crewmem)
            if maxCount and #res >= maxCount then
                return res
            end
        end
    end
    return res
end

-- Tririac's absduction code (made by chooseche and arc)
mods.fr.yoinkWeapons = {}
local yoinkWeapons = mods.fr.yoinkWeapons 
yoinkWeapons["FR_TRIRIAC_ABDUCTOR"] = true

mods.fr.enemyCrewToPlayerCrew = {}
local enemyCrewToPlayerCrew = mods.fr.enemyCrewToPlayerCrew
enemyCrewToPlayerCrew["human_rebel"] = "human"
enemyCrewToPlayerCrew["human_rebel_medic"] = "human_medic"
--enemyCrewToPlayerCrew["rock_paladin_enemy"] = "rock_paladin"
enemyCrewToPlayerCrew["zoltan_osmian_enemy"] = "zoltan_osmian"
enemyCrewToPlayerCrew["fr_bonus_augustus_enemy"] = "fr_bonus_augustus"
enemyCrewToPlayerCrew["fr_bonus_prince_enemy"] = "fr_bonus_prince"

-- Addon fellas
enemyCrewToPlayerCrew["deeponecultist_enemy"] = "deeponecultist"
enemyCrewToPlayerCrew["unique_thehunger_enemy"] = "unique_thehunger"
enemyCrewToPlayerCrew["ddseraph_engi_enemy"] = "ddseraph_engi"
enemyCrewToPlayerCrew["disparity_engihazard_enemy"] = "disparity_engihazard"
enemyCrewToPlayerCrew["enlightened_horror_enemy"] = "enlightened_horror"
enemyCrewToPlayerCrew["ddnightmare_rift_enemy"] = "ddnightmare_rift"
enemyCrewToPlayerCrew["ddPOWEROFULTIMA_enemy"] = "ddPOWEROFULTIMA"
enemyCrewToPlayerCrew["ddtempest_stormborn_spawn_enemy"] = "ddtempest_stormborn_spawn"
enemyCrewToPlayerCrew["ddsoulplague_husk_human_enemy"] = "ddsoulplague_husk_human"
enemyCrewToPlayerCrew["ddsoulplague_husk_crystal_enemy"] = "ddsoulplague_husk_crystal"
enemyCrewToPlayerCrew["ddsoulplague_husk_engi_enemy"] = "ddsoulplague_husk_engi"
enemyCrewToPlayerCrew["ddsoulplague_husk_zoltan_enemy"] = "ddsoulplague_husk_zoltan"
enemyCrewToPlayerCrew["ddsoulplague_husk_orchid_enemy"] = "ddsoulplague_husk_orchid"
enemyCrewToPlayerCrew["ddsoulplague_husk_mantis_enemy"] = "ddsoulplague_husk_mantis"
enemyCrewToPlayerCrew["ddsoulplague_husk_rockman_enemy"] = "ddsoulplague_husk_rockman"
enemyCrewToPlayerCrew["ddsoulplague_husk_slug_enemy"] = "ddsoulplague_husk_slug"
enemyCrewToPlayerCrew["ddsoulplague_husk_shell_enemy"] = "ddsoulplague_husk_shell"
enemyCrewToPlayerCrew["ddsoulplague_husk_lanius_enemy"] = "ddsoulplague_husk_lanius"
enemyCrewToPlayerCrew["ddsoulplague_husk_deepone_enemy"] = "ddsoulplague_husk_deepone"
enemyCrewToPlayerCrew["ddsoulplague_husk_ghost_enemy"] = "ddsoulplague_husk_ghost"
enemyCrewToPlayerCrew["ddsoulplague_husk_leech_enemy"] = "ddsoulplague_husk_leech"
enemyCrewToPlayerCrew["ddsoulplague_husk_obelisk_enemy"] = "ddsoulplague_husk_obelisk"
enemyCrewToPlayerCrew["ddsoulplague_shellcultist_enemy"] = "ddsoulplague_shellcultist"
enemyCrewToPlayerCrew["ddsoulplague_huskweaver_enemy"] = "ddsoulplague_huskweaver"
enemyCrewToPlayerCrew["ddunique_theaberration_enemy"] = "ddunique_theaberration"
enemyCrewToPlayerCrew["ddunique_theheroine_enemy"] = "ddunique_theheroine"
enemyCrewToPlayerCrew["ddmanifestationofintegrity_enemy"] = "ddmanifestationofintegrity"
enemyCrewToPlayerCrew["ddseraph_shell_enemy"] = "ddseraph_shell"


-- Handle teleportation beams
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(shipManager, projectile, location, damage, realNewTile, beamHitType)
    local teleControl = yoinkWeapons[projectile.extend.name]
    local otherShip = Hyperspace.Global.GetInstance():GetShipManager((shipManager.iShipId + 1)%2)
    if teleControl then
        for i, crewmem in ipairs(get_ship_crew_point(shipManager, location.x, location.y)) do
            if not crewmem:IsDrone() then
                local crewmemRace = nil
                if enemyCrewToPlayerCrew[crewmem:GetSpecies()] then
                    crewmemRace = enemyCrewToPlayerCrew[crewmem:GetSpecies()]
                else
                    crewmemRace = crewmem:GetSpecies()
                end
                
                otherShip:AddCrewMemberFromString(crewmem:GetLongName(), crewmemRace, false, 0, false, crewmem.crewAnim.bMale)
                crewmem:Kill(true)
            end
        end
    end
    return Defines.Chain.CONTINUE, beamHitType
end)

-- Tririac B artillery (By Arc)

local function get_room_at_location(shipManager, location, includeWalls)
    return Hyperspace.ShipGraph.GetShipInfo(shipManager.iShipId):GetSelectedRoom(location.x, location.y, includeWalls)
end

mods.fr.temporalWeapons = {}
local temporalWeapons = mods.fr.temporalWeapons 
temporalWeapons["FR_ARTILLERY_TRIRIAC_B"] = true
temporalWeapons["FR_CEL_MISSILE"] = true
temporalWeapons["FR_DRONE_CEL_LASER"] = true
temporalWeapons["FR_DRONE_CEL_BEAM"] = true
temporalWeapons["FR_CEL_LASER"] = true
temporalWeapons["FR_CEL_ION"] = true
temporalWeapons["FR_CEL_BOMB"] = true
temporalWeapons["FR_CEL_BEAM"] = true

local userdata_table = mods.multiverse.userdata_table

local function fr_slow_rooms(shipManager, projectile, location, damage, shipFriendlyFire)
    local weaponName = nil
    pcall(function() weaponName = projectile.extend.name end)
    if temporalWeapons[weaponName] then
        local roomId = get_room_at_location(shipManager, location, true)
        local roomToSpeed = nil
        for room in vter(shipManager.ship.vRoomList) do
            if room.iRoomId == roomId then roomToSpeed = room end
        end
        if roomToSpeed then
            local speedtable = userdata_table(roomToSpeed, "mods.fr.slowedroom")
            roomToSpeed.extend.timeDilation = -2
            speedtable.speedTime = 5
        end
    end
end

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, fr_slow_rooms)
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, fr_slow_rooms)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
    for room in vter(ship.ship.vRoomList) do
        local speedtable = userdata_table(room, "mods.fr.slowedroom")
        if speedtable.speedTime then
            speedtable.speedTime = math.max(speedtable.speedTime - Hyperspace.FPS.SpeedFactor/16, 0)
            if speedtable.speedTime <= 0 then
                room.extend.timeDilation = 0
                speedtable.speedTime = nil
            end
        end
    end
end)


--Pro Hull code, stolen from mv for now

local beamDamageMods = mods.multiverse.beamDamageMods
beamDamageMods["FR_ARTILLERY_VORTEX_HEAL"] = {iDamage = -2}
beamDamageMods["FR_COMMONWEALTH_FOCUS"] = {iDamage = -5}
beamDamageMods["FR_WITHER_PROTOTYPE_HAVOC"] = {iDamage = -4}

--Y's artilleries downgrading

mods.fr.downgradeWeapons = {} 
local downgradeWeapon = mods.fr.downgradeWeapons
downgradeWeapon["FR_ARTILLERY_OBELISK_FLAGSHIP_MISSILE_Y"] =  {3, 0.5}
downgradeWeapon["FR_ARTILLERY_OBELISK_FLAGSHIP_ION_Y"] =  {1, 1}
downgradeWeapon["FR_ARTILLERY_OBELISK_FLAGSHIP_BEAM_Y"] =  {1, 0.25}
downgradeWeapon["FR_ARTILLERY_OBELISK_FLAGSHIP_LASER_Y"] =  {1, 0.5}
downgradeWeapon["FR_ARTILLERY_OBELISK_FLAGSHIP_BOMB_Y"] =  {2, 1}

script.on_internal_event(Defines.InternalEvents.DAMAGE_SYSTEM,
function(ship, projectile, roomId, damage)
    if projectile then
        local sys = ship:GetSystemInRoom(roomId)
        local downgradeWeapon = mods.fr.downgradeWeapons[projectile.extend.name]
        if sys and downgradeWeapon and math.random()<downgradeWeapon[2] then
            sys:UpgradeSystem(math.max(1,sys.powerState.second-downgradeWeapon[1])-sys.powerState.second)
        end
    end
    return Defines.Chain.CONTINUE
end)

-- Vin's Dot (made by sillysandvich and arc)
mods.fr.flamedotweapons = {}
local flamedotweapons = mods.fr.flamedotweapons 
flamedotweapons["FR_VIN_MISSILE"] = true

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(shipManager, projectile, location, damage, shipFriendlyFire)
    if flamedotweapons[projectile and projectile.extend.name] then
        local roomId = get_room_at_location(shipManager, location, true)
        for crew in vter(shipManager.vCrewList) do
            local _, canBurn = crew.extend:CalculateStat(Hyperspace.CrewStat.CAN_BURN)
            if roomId == crew.iRoomId then 
                if canBurn then
                    local fireDamageMultiplier, _ = crew.extend:CalculateStat(Hyperspace.CrewStat.FIRE_DAMAGE_MULTIPLIER)
                    local vinfiredot = Hyperspace.StatBoostDefinition()
                    vinfiredot.stat = Hyperspace.CrewStat.TRUE_HEAL_AMOUNT
                    vinfiredot.amount = -10 * fireDamageMultiplier
                    vinfiredot.duration = 10
                    vinfiredot.maxStacks = 1
                    vinfiredot.cloneClear = true
                    vinfiredot.boostType = Hyperspace.StatBoostDefinition.BoostType.FLAT
                    vinfiredot.boostSource = Hyperspace.StatBoostDefinition.BoostSource.CREW
                    vinfiredot.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
                    vinfiredot.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
                    vinfiredot.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
                    Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(Hyperspace.StatBoost(vinfiredot), crew)
                end
            end
        end
    end
    return Defines.Chain.CONTINUE
end)

-- Phys Drone stun (By silly, lizzard and me)

mods.fr.dronestungun = {}
local dronestungun = mods.fr.dronestungun 
dronestungun["FR_PHYS_BEAM"] = true

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, function(shipManager, projectile, location, damage, realNewTile, beamHitType)
    if dronestungun[projectile and projectile.extend.name] then
        local roomId = get_room_at_location(shipManager, location, true)
        local dronecontrol = shipManager:GetSystemRoom(4)
        if roomId == dronecontrol and roomId ~= -1 then 
            for crew in vter(shipManager.vCrewList) do
                if crew:IsDrone() and crew.iShipId ~= projectile.ownerId then
                    crew.fStunTime = math.max(crew.fStunTime, 5)
                end
            end
            local OtherShipManager = Hyperspace.ships(1 - shipManager.iShipId)
            for crew in vter(OtherShipManager.vCrewList) do
                if crew:IsDrone() and crew.iShipId ~= projectile.ownerId then
                    crew.fStunTime = math.max(crew.fStunTime, 5)
                end
            end
            for drone in vter(shipManager.spaceDrones) do
                drone.ionStun = math.max(drone.ionStun, 5)
            end
        end
    end
    return Defines.Chain.CONTINUE, beamHitType
end)

-- Augustus Gun fixes (By MV)

mods.trc.burstMultiBarrel.FR_ARTILLERY_MATH_ADDER = {barrelOffset = 10, barrelCount = 2}
mods.trc.burstMultiBarrel.FR_ARTILLERY_COALITION_FLAGSHIP_B_HULL_LASER = {barrelOffset = 8, barrelCount = 3}
mods.trc.burstMultiBarrel.FR_AUGUSTUS_MISSILE = {barrelOffset = 5, barrelCount = 3}
mods.trc.burstSpriteFixes.FR_AUGUSTUS_MISSILE = true
