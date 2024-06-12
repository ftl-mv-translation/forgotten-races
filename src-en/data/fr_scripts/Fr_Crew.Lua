local vter = mods.inferno.vter

--Augustus crew's scrap thingy (kokoro, chooseche and chrono)

local healthDef = Hyperspace.StatBoostDefinition()
healthDef.stat = Hyperspace.CrewStat.MAX_HEALTH
healthDef.amount = 0
healthDef.duration = -1
healthDef.maxStacks = 1
healthDef.cloneClear = false
healthDef.boostType = Hyperspace.StatBoostDefinition.BoostType.FLAT
healthDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
healthDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
healthDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
healthDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(healthDef)
local healthStatBoost = Hyperspace.StatBoost(healthDef)

local damageDef = Hyperspace.StatBoostDefinition()
damageDef.stat = Hyperspace.CrewStat.DAMAGE_MULTIPLIER
damageDef.amount = 0
damageDef.duration = -1
damageDef.maxStacks = 1
damageDef.cloneClear = false
damageDef.boostType = Hyperspace.StatBoostDefinition.BoostType.FLAT
damageDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
damageDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
damageDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
damageDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(damageDef)
local damageStatBoost = Hyperspace.StatBoost(damageDef)

local sabotageDef = Hyperspace.StatBoostDefinition()
sabotageDef.stat = Hyperspace.CrewStat.SABOTAGE_SPEED_MULTIPLIER
sabotageDef.amount = 0
sabotageDef.duration = -1
sabotageDef.maxStacks = 1
sabotageDef.cloneClear = false
sabotageDef.boostType = Hyperspace.StatBoostDefinition.BoostType.FLAT
sabotageDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
sabotageDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
sabotageDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
sabotageDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(sabotageDef)
local sabotageStatBoost = Hyperspace.StatBoost(sabotageDef)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipMgr)
    if shipMgr.iShipId ~= 0 then
        return
    end
    healthDef.amount = math.max(shipMgr.currentScrap // 2, 0)
    damageDef.amount = math.max(shipMgr.currentScrap / 100, 0)
    sabotageDef.amount = math.max(shipMgr.currentScrap / 100, 0)
end)

script.on_internal_event(Defines.InternalEvents.CREW_LOOP, function(crew)
    if crew.iShipId ~= 0 or crew:GetSpecies() ~= 'fr_bonus_augustus' then
        return
    end
    local userdata = mods.multiverse.userdata_table(crew, 'mods.fr.augustus')
    if not userdata.createdStatBoost then
        Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(healthStatBoost, crew)
        Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(damageStatBoost, crew)
        Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(sabotageStatBoost, crew)
        userdata.createdStatBoost = true
    end
end)


--[[script.on_internal_event(Defines.InternalEvents.CREW_LOOP, function(crew)
    if crew:GetSpecies() == "fr_bonus_augustus" and Hyperspace.ships(0) and Hyperspace.ships(0).currentScrap then
       local scraptotal = Hyperspace.ships(0).currentScrap
       local currenthealth = crew.health.first
       crew:SetHealthBoost(scraptotal / 2)
       crew.health.first = currenthealth
    end
end)
]]

--Funny name compatibility

mods.hackslow = mods.hackslow or {}
mods.hackslow.customRaceNames = mods.hackslow.customRaceNames or {}
mods.hackslow.customRaceNames.addonNames = mods.hackslow.customRaceNames.addonNames or {}
mods.hackslow.customRaceNames.addonNames.forgottenraces = {
    fr_unique_mantis_queen = {"Leikonpliiinakra"},
    fr_unique_leah_legion = {"Leah"},
    fr_reborn_g = {"G"},
    fr_reborn_aleenor = {"Aleenor"},
    fr_gozer = {"Goziodeon"},
    fr_reborn_zulu = {"Zulu"},
    fr_reborn_vin = {"Vin"},
    fr_reborn_cleo = {"Cleo"},
    fr_reborn_slimer = {"Slimer"},
    fr_reborn_phys = {"Phys"},
    fr_reformed_charror = {"Charror"},
    fr_reformed_chills = {"Chills"},
    fr_reformed_searak = {"Searak"},
    fr_reformed_leo = {"Leo"},
    fr_watcher = {"Watcher"},
    fr_reformed_pok = {"Pok"},
    fr_ghost_wither = {"Pok"},
    fr_ghost_ooj = {"Pok"},
    fr_ghost_obyn = {"Pok"},
    fr_ghost_queen = {"Pok"},
    fr_ghost_metyunt = {"Pok"},
    fr_ghost_guntput = {"Pok"},
    fr_ghost_anointed = {"Pok"},
    fr_ghost_eater = {"Pok"},
    fr_ghost_alkram = {"Pok"},
    fr_ghost_tonysr = {"Pok"},
    fr_ghost_dessius = {"Pok"},
    fr_ghost_tyrdeo = {"Pok"},
    fr_ghost_billy = {"Pok"},
    fr_ghost_billy_box = {"Pok"},
    fr_ghost_irwin = {"Pok"},
    fr_ghost_slocknog = {"Pok"},
    fr_ghost_nights = {"Pok"},
    fr_ghost_dianesh = {"Pok"},
    fr_ghost_ruwen = {"Pok"},
    fr_ghost_sylvan = {"Pok"},
    fr_ghost_alkali = {"Pok"},
    fr_ghost_vortigon = {"Pok"},
    fr_ghost_ariadne = {"Pok"},
    fr_ghost_tuco = {"Pok"},
    fr_ghost_symbiote = {"Pok"},
    fr_ghost_freddy = {"Pok"},
    fr_ghost_kaz = {"Pok"},
    fr_ghost_devorak = {"Pok"},
    fr_ghost_anurak = {"Pok"},
    fr_ghost_turzil = {"Pok"},
    fr_ghost_stephan = {"Pok"},
    fr_ghost_ellie = {"Pok"},
    fr_ghost_jerry = {"Pok"},
    fr_ghost_haynes = {"Pok"},
    fr_ghost_tully = {"Pok"},
    fr_reformed_smoke = {"Smoke"},
    fr_unique_sammy = {"Sammy"},
    human_humanoid = {"Stephan"},
    fr_bonus_augustus = {"Augustus"}, 
    fr_bonus_sally_hatchling = {"Sally"},
    fr_bonus_sally_adult = {"Sally"},
    fr_bonus_sally_weaver = {"Sally"},
    fr_bonus_prince = {"Prince of Darkness"}, 
    fr_bonus_prince_jerry = {"Jerry"}, 
    fr_bonus_tririac = {"Tririac"}, 
    human = {
        male = {
            "Gabriel Cooper",
            "HereticChurch"
        },
        female = {
            "HereticChurch"
        }
    }
}

-- Tririac's Mind control ability (originally by pepson but heavily edited by chrono and me)

local userdata_table = mods.multiverse.userdata_table

script.on_internal_event(Defines.InternalEvents.ACTIVATE_POWER, function(power, ship)
    if power.crew.blueprint.name ~= "fr_bonus_tririac" then
        return
    end
    for crew in vter(ship.vCrewList) do
        if power.powerRoom == crew.iRoomId and power.crew ~= crew and power.crew.iShipId ~= crew.iShipId and crew.bMindControlled == false then
            local mctable = userdata_table(crew, "mods.fr.mccrew")
            crew:SetMindControl(true)
            mctable.mcTime = 10
            power:CancelPower(true)
            break
        end
    end
end)

script.on_internal_event(Defines.InternalEvents.CREW_LOOP, function(crew)
    local mctable = userdata_table(crew, "mods.fr.mccrew")
    if mctable.mcTime then
        mctable.mcTime = math.max(mctable.mcTime - Hyperspace.FPS.SpeedFactor/16, 0)
        if mctable.mcTime <= 0 then
            crew:SetMindControl(false)
            mctable.mcTime = nil
        end
    end
end)

-- Spherax Temporal ability (made by pepson)

local userdata_table = mods.multiverse.userdata_table

script.on_internal_event(Defines.InternalEvents.ACTIVATE_POWER, function(power, ship)
    if power.crew.blueprint.name ~= "fr_spherax" then return end
    local crew = power.crew
    local roomToSpeed = nil
    for room in vter(ship.ship.vRoomList) do
        if room.iRoomId == crew.iRoomId then roomToSpeed = room break end
    end
    if roomToSpeed then
        local speedtable = userdata_table(roomToSpeed, "mods.fr.speedroom")
        if power.def.name == "Fr_Fast" then
            roomToSpeed.extend.timeDilation = 2
        else
            roomToSpeed.extend.timeDilation = -2
        end
        speedtable.speedTime = 5
        power:CancelPower(true)
    end
end)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ship)
    for room in vter(ship.ship.vRoomList) do
        local speedtable = userdata_table(room, "mods.fr.speedroom")
        if speedtable.speedTime then
            speedtable.speedTime = math.max(speedtable.speedTime - Hyperspace.FPS.SpeedFactor/16, 0)
            if speedtable.speedTime <= 0 then
                room.extend.timeDilation = 0
                speedtable.speedTime = nil
            end
        end
    end
end)