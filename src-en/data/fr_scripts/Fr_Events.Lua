local vter = mods.fusion.vter
-- Remove bypass

script.on_game_event("COMBAT_CHECK_REMOVEBYPASS",false,
function()
  Hyperspace.ships.enemy:RemoveItem("UPG_TECH_BYPASS")
  Hyperspace.ships.enemy:RemoveItem("HIDDEN UPG_TECH_BYPASS")
  if Hyperspace.ships.enemy:HasAugmentation("SYLVAN_GEL") == "true" then
    Hyperspace.ships.enemy:RemoveItem("SYLVAN_GEL")
    Hyperspace.ships.enemy:AddAugmentation("LOCKED_SLUG_GEL")
  end
end
)

-- Bypass check
script.on_game_event("COMBAT_CHECK",false,
function()
  if Hyperspace.ships.enemy:GetAugmentationValue("ZOLTAN_BYPASS") > 0 then
    Hyperspace.playerVariables.enemyHasBypass = 1
  else
    Hyperspace.playerVariables.enemyHasBypass = 0
  end
end
)

-- enemy check (by julk and me)

mods.fr.enemyChecker = {}
local flagshipSurgeChecker = mods.fr.enemyChecker 
flagshipSurgeChecker["FR_OBELISK_FLAGSHIP_NOBLE_SURGE"] = true
flagshipSurgeChecker["FR_OBELISK_FLAGSHIP_COMMONWEALTH_SURGE"] = true
flagshipSurgeChecker["FR_OBELISK_FLAGSHIP_WITHER_SURGE"] = true
flagshipSurgeChecker["FR_OBELISK_FLAGSHIP_ROYAL_SURGE"] = true
flagshipSurgeChecker["FR_OBELISK_FLAGSHIP_G_SURGE"] = true
flagshipSurgeChecker["FR_OBELISK_FLAGSHIP_Y_SURGE"] = true

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId)
  for k,v in pairs(flagshipSurgeChecker) do
    if Hyperspace.ships.player and Hyperspace.ships.player:GetAugmentationValue(k) > 0 and ShipManager.iShipId == 0 then
      if OtherShipManager and OtherShipManager._targetable.hostile then
        Hyperspace.playerVariables.fr_enemy_present = 1
      else
        Hyperspace.playerVariables.fr_enemy_present = 0
      end
    end
  end
end)

-- asb check (by me)

mods.fr.asbChecker = {}
local flagshipASBChecker = mods.fr.asbChecker 
flagshipASBChecker["FR_OBELISK_FLAGSHIP_Y_SURGE"] = true

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  for k,v in pairs(flagshipASBChecker) do
    if Hyperspace.ships.player and Hyperspace.ships.player:GetAugmentationValue(k) > 0 and ShipManager.iShipId == 0 then
      local SpaceManager = Hyperspace.Global.GetInstance():GetCApp().world.space
      if SpaceManager.bPDS then
        Hyperspace.playerVariables.fr_asb_check = 1
      else
        Hyperspace.playerVariables.fr_asb_check = 0
      end
    end
  end
end)

-- ion resist check
script.on_game_event("FR_NEUTRAL_COMMONWEALTH_PULSAR_AUTO",false,
function()
  if Hyperspace.ships.player:GetAugmentationValue("ION_ARMOR") >= 1 then
    Hyperspace.playerVariables.fr_full_ion_immunity = 1
  else
    Hyperspace.playerVariables.fr_full_ion_immunity = 0
  end
end
)


-- Discharge Surge
script.on_game_event("FR_DISCHARGE", false, 
function()
    local shipManager = Hyperspace.ships.enemy
    local engines = Hyperspace.ships.player:GetSystem(1)
    local enginePower = engines:GetMaxPower()
    for sys in vter(shipManager.vSystemList) do
		local downgrade = math.floor(sys:GetMaxPower()*(0.1+enginePower*0.05))
		local check = math.floor(1-(1/(1+math.abs(sys:GetMaxPower()-downgrade-1))))
		local check = math.min(sys:GetMaxPower()-downgrade-1,1)
		sys:UpgradeSystem(-(downgrade+check))
    end
    engines:SetPowerCap(1)
end)

-- Vin apparition teleport code (by Arc)
script.on_game_event("FR_REVENANT_APPARITION_VIN", false, function()
    local shipManager = Hyperspace.ships.enemy
    local pShipManager = Hyperspace.ships.player
    local sysDamage = Hyperspace.Damage()
    sysDamage.iIonDamage = 3 --15 seconds
    shipManager:DamageSystem(9, sysDamage) --9 is teleporter system id
    for crewmem in vter(shipManager.vCrewList) do
        crewmem.extend:InitiateTeleport(pShipManager.iShipId,0,0)
    end
end)

-- MFK Spawner for warzone (by MV)

script.on_game_event("FR_START_WARZONE_COALITION_VANCE", false, function()
    local bp = Hyperspace.Blueprints:GetCrewBlueprint("human_mfk")
    local rm = Hyperspace.ships.enemy:GetSystemRoom(0)
    Hyperspace.ships.enemy:AddCrewMemberFromBlueprint(bp, 0, true, rm, true)
    Hyperspace.ships.enemy:AddCrewMemberFromBlueprint(bp, 0, true, rm, true)
    Hyperspace.ships.enemy:AddCrewMemberFromBlueprint(bp, 0, true, rm, true)
end)


-- event atmosphere (by mv)

local atmoBackgrounds = mods.multiverse.atmoBackgrounds

mods.multiverse.atmoBackgrounds.FR_BACK_EVENT_FEDERATION_HQ = true
mods.multiverse.atmoBackgrounds.FR_BACK_EVENT_REBEL_HANGER = true

-- Oracle Check

script.on_game_event("FR_COMBAT_CHECK_THE_ORACLE",false,
function()
  local enemy = Hyperspace.ships.enemy
  local weapon = enemy.weaponSystem
  if weapon then
    Hyperspace.playerVariables.fr_enemyHasWeapons = 1
  else
    Hyperspace.playerVariables.fr_enemyHasWeapons = 0
  end
end
)

script.on_game_event("FR_COMBAT_CHECK_THE_ORACLE",false,
function()
  local enemy = Hyperspace.ships.enemy
  local drone = enemy.droneSystem
  if drone then
    Hyperspace.playerVariables.fr_enemyHasDrones = 1
  else
    Hyperspace.playerVariables.fr_enemyHasDrones = 0
  end
end
)

--[[script.on_game_event("FR_COMBAT_CHECK_THE_ORACLE",false,
function()
  local enemy = Hyperspace.ships.enemy
  if enemy:GetAugmentationCount() ~= 0 or enemy:GetAugmentationCount() ~= 1 then
    Hyperspace.playerVariables.fr_enemyHasAugment = 1
  else
    Hyperspace.playerVariables.fr_enemyHasAugment = 0
  end
end
)]]

script.on_game_event("FR_COMBAT_CHECK_THE_ORACLE",false,
function()
  local enemy = Hyperspace.ships.enemy
  if enemy:CountCrew(false) ~= 0 then
    Hyperspace.playerVariables.fr_enemyHasCrew = 1
  else
    Hyperspace.playerVariables.fr_enemyHasCrew = 0
  end
end
)

-- Oracle Steal (me and Duodecimus)

script.on_game_event("FR_COMBAT_CHECK_THE_ORACLE_WEAPON",false,
function()
    local ship = Hyperspace.ships.enemy
    local weaponList = ship:GetWeaponList()
    local index = math.random(0, weaponList:size()-1)

    if weaponList[index] and weaponList[index].blueprint then
      Hyperspace.App.gui.equipScreen:AddToCargo(weaponList[index].blueprint.name)
      ship:RemoveItem(weaponList[index].blueprint.name)
    end
end
)

script.on_game_event("FR_COMBAT_CHECK_THE_ORACLE_DRONE",false,
function()
    local ship = Hyperspace.ships.enemy
    local droneList = ship:GetDroneList()
    local index = math.random(0, droneList:size()-1)

    if droneList[index] and droneList[index].blueprint then
      Hyperspace.App.gui.equipScreen:AddToCargo(droneList[index].blueprint.name)
      ship:RemoveItem(droneList[index].blueprint.name)
    end
end
)

--[[script.on_game_event("FR_COMBAT_CHECK_THE_ORACLE_AUGMENT",false,
function()
    local augList = {}
    local augManager = Hyperspace.CustomAugmentManager.GetInstance()
    for aug in vter(augManager:GetShipAugments(1):keys()) do
      print(aug)
      if aug ~= "MIND_ORDER" then
        table.insert(augList, aug)
      end
    end
    local randIndex = math.random(1, augList:size())
    local othership = Hyperspace.ships.player
    local ship = Hyperspace.ships.enemy
    for index, augName in ipairs(augList) do
      if randIndex == index then
        othership:AddAugmentation(augName)
        ship:RemoveAugmentation(augName)
        break
      end
    end
  end
)]]

script.on_game_event("FR_COMBAT_CHECK_THE_ORACLE_CREW",false,
function()
  local ship = Hyperspace.ships.enemy
  for crew in vter(ship.vCrewList) do
    local othership = Hyperspace.ships.player
      if not crew:IsDrone() then
        local crewmemRace = nil
        crewmemRace = crew:GetSpecies()
        othership:AddCrewMemberFromString(crew:GetLongName(), crewmemRace, false, 0, false, crew.crewAnim.bMale)
        crew:Kill(true)
        break
      end
    end
  end
)

-- Tririac TOWR (by MV)

script.on_game_event("FR_THE_ONE_WHO_RHYMES_CHAOS_TRIRIAC", false, function()
    local bp = Hyperspace.Blueprints:GetCrewBlueprint("eldritch_thing")
    local rm = Hyperspace.ships.enemy:GetSystemRoom(6)
    Hyperspace.ships.enemy:AddCrewMemberFromBlueprint(bp, 0, true, rm, true)
end)

script.on_game_event("FR_THE_ONE_WHO_RHYMES_TRIRIAC", false, function()
    local bp = Hyperspace.Blueprints:GetCrewBlueprint("eldritch_thing")
    local rm = Hyperspace.ships.enemy:GetSystemRoom(6)
    Hyperspace.ships.enemy:AddCrewMemberFromBlueprint(bp, 0, true, rm, true)
end)