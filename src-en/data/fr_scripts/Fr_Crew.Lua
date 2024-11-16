local vter = mods.fusion.vter

--Augustus crew's scrap thingy (kokoro, chooseche and chrono)

local augustushealthDef = Hyperspace.StatBoostDefinition()
augustushealthDef.stat = Hyperspace.CrewStat.MAX_HEALTH
augustushealthDef.amount = 0
augustushealthDef.duration = -1
augustushealthDef.maxStacks = 1
augustushealthDef.cloneClear = false
augustushealthDef.boostType = Hyperspace.StatBoostDefinition.BoostType.FLAT
augustushealthDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
augustushealthDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
augustushealthDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
augustushealthDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(augustushealthDef)
local augustushealthStatBoost = Hyperspace.StatBoost(augustushealthDef)

local augustusdamageDef = Hyperspace.StatBoostDefinition()
augustusdamageDef.stat = Hyperspace.CrewStat.DAMAGE_MULTIPLIER
augustusdamageDef.amount = 0
augustusdamageDef.duration = -1
augustusdamageDef.maxStacks = 1
augustusdamageDef.cloneClear = false
augustusdamageDef.boostType = Hyperspace.StatBoostDefinition.BoostType.FLAT
augustusdamageDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
augustusdamageDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
augustusdamageDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
augustusdamageDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(augustusdamageDef)
local augustusdamageStatBoost = Hyperspace.StatBoost(augustusdamageDef)

local augustussabotageDef = Hyperspace.StatBoostDefinition()
augustussabotageDef.stat = Hyperspace.CrewStat.SABOTAGE_SPEED_MULTIPLIER
augustussabotageDef.amount = 0
augustussabotageDef.duration = -1
augustussabotageDef.maxStacks = 1
augustussabotageDef.cloneClear = false
augustussabotageDef.boostType = Hyperspace.StatBoostDefinition.BoostType.FLAT
augustussabotageDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
augustussabotageDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
augustussabotageDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
augustussabotageDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(augustussabotageDef)
local augustussabotageStatBoost = Hyperspace.StatBoost(augustussabotageDef)

local oldScrap = 0

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipMgr)
    if shipMgr.iShipId ~= 0 then
        return
    end
    local ScrapLevel = shipMgr.currentScrap
    if ScrapLevel ~= oldScrap then
        augustushealthDef.amount = math.max(ScrapLevel // 2, 0)
        Hyperspace.StatBoostDefinition.statBoostDefs:push_back(augustushealthDef)
        augustusdamageDef.amount = math.max(ScrapLevel / 100, 0)
        Hyperspace.StatBoostDefinition.statBoostDefs:push_back(augustusdamageDef)
        augustussabotageDef.amount = math.max(ScrapLevel / 100, 0)
        Hyperspace.StatBoostDefinition.statBoostDefs:push_back(augustussabotageDef)
    end
    oldScrap = ScrapLevel
end)

script.on_internal_event(Defines.InternalEvents.CREW_LOOP, function(crew)
    if crew.iShipId ~= 0 or crew:GetSpecies() ~= 'fr_bonus_augustus' then
        return
    end
    local userdata = mods.multiverse.userdata_table(crew, 'mods.fr.augustus')
    if not userdata.createdStatBoost then
        Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(augustushealthStatBoost, crew)
        Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(augustusdamageStatBoost, crew)
        Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(augustussabotageStatBoost, crew)
        userdata.createdStatBoost = true
    end
end)

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
    fr_unique_y = {"Y"}, 
    fr_unique_collector = {"Collector"}, 
    fr_unique_cylvan = {"Cylvan"}, 
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

-- Tririac's Mind control ability (by arc)


local userdata_table = mods.multiverse.userdata_table
local resists_mind_control = mods.multiverse.resists_mind_control
local can_be_mind_controlled = mods.multiverse.can_be_mind_controlled

script.on_internal_event(Defines.InternalEvents.ACTIVATE_POWER, function(power, ship)
    if power.crew.blueprint.name ~= "fr_bonus_tririac" then
        return
    end
    local roomId = power.crew.iRoomId
    local mindControlledCrew = 0
    for crewmem in vter(ship.vCrewList) do
        local doControl = crewmem.iRoomId == roomId and
                          crewmem.currentShipId == ship.iShipId and
                          crewmem.iShipId ~= power.crew.iShipId and
                          crewmem ~= power.crew
        if doControl then
            if can_be_mind_controlled(crewmem) then
                crewmem:SetMindControl(true)
                local mcTable = userdata_table(crewmem, "mods.mv.crewStuff")
                mcTable.mcTime = math.max(10, mcTable.mcTime or 0)
                mindControlledCrew = mindControlledCrew + 1
                if mindControlledCrew >= 1 then break end
            elseif resists_mind_control(crewmem) then
                crewmem.bResisted = true
            end
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