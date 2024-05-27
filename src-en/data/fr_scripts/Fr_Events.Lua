
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

-- Crew number check

script.on_game_event("FR_OPERATOR_QUEST",false,
function()
  playerShip = Hyperspace.ships.player
  crewCount = playerShip:CountCrew(false)
  variable = 0
  if (crewCount > 5) or (crewcount > 4 and playerShip.bAutomated == true ) then
    variable = 1
  end
  Hyperspace.playerVariables.forgorEnoughCrew = variable
end)

-- Discharge Surge
local vter = mods.inferno.vter
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
script.on_game_event("FR_HAUNT_APPARITION_VIN", false, function()
    local shipManager = Hyperspace.ships(1)
    local pShipManager = Hyperspace.ships(0)
    local sysDamage = Hyperspace.Damage()
    sysDamage.iIonDamage = 3 --15 seconds
    shipManager:DamageSystem(9, sysDamage) --9 is teleporter system id
    for crewmem in vter(shipManager.vCrewList) do
        crewmem.extend:InitiateTeleport(pShipManager.iShipId,0,0)
    end
end)