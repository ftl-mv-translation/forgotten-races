local vter = mods.fusion.vter

--auto repair augment

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP,
function(shipManager)
  local power = shipManager:GetSystemPower(4)--this number ist the id of the system, medbay is 5, drones 4
    if power ~= 0 and shipManager:GetAugmentationValue("FR_GHOSTLY_REPAIR_BOTS") ~= 0 then --this line makes it so half-repaired systems can reset, because running this every tick apparently prevents that
    for sys in vter(shipManager.vSystemList) do
      local roomNumber = sys:GetRoomId()
      local augValue = shipManager:GetAugmentationValue("FR_GHOSTLY_REPAIR_BOTS")
      local RepairSpeed = augValue / 2
        sys:PartialRepair(RepairSpeed * power, false)
    end
  end
end)

--auto extinguish and breach part of auto repair

script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE,
function(ShipManager, AugName, AugValue)
  
  if (AugName == "SLUG_GEL" or AugName == "FIRE_EXTINGUISHERS" )and ShipManager:HasAugmentation("FR_GHOSTLY_REPAIR_BOTS") > 0 then
    local powerBars = ShipManager:GetSystemPower(4)
    local RepairSpeed = (powerBars * ShipManager:GetAugmentationValue("FR_GHOSTLY_REPAIR_BOTS"))
    AugValue = AugValue + RepairSpeed
  end

  return Defines.Chain.CONTINUE, AugValue
end)

-- Double ion

local function fr_weapon_ionize(ship, _, projectile)
  local ion_damage_modifier = 1 + ship:GetAugmentationValue("FR_COMMONWEALTH_IONIZER")
  if projectile:GetType() ~= 5 and (projectile.damage.iIonDamage > 0 ) then
    projectile.damage.iIonDamage = math.min(9,projectile.damage.iIonDamage * ion_damage_modifier)
  end
end

script.on_fire_event(Defines.FireEvents.WEAPON_FIRE, fr_weapon_ionize)
script.on_fire_event(Defines.FireEvents.ARTILLERY_FIRE, fr_weapon_ionize)

-- Double ion

local function fr_weapon_ionize(ship, _, projectile)
  local ion_damage_modifier = 1 + ship:GetAugmentationValue("FR_COMMONWEALTH_IONIZER_UNLOCKED")
  if projectile:GetType() ~= 5 and (projectile.damage.iIonDamage > 0 ) then
    projectile.damage.iIonDamage = math.min(9,projectile.damage.iIonDamage * ion_damage_modifier)
  end
end

script.on_fire_event(Defines.FireEvents.WEAPON_FIRE, fr_weapon_ionize)
script.on_fire_event(Defines.FireEvents.ARTILLERY_FIRE, fr_weapon_ionize)

-- Super shield battery PLAYER

local baseChargeTime = 10 --How many seconds it takes to pulse with one shield layer's worth of power.
local barsPerPulse = 1 --How many super shield bars are added per pulse.

local timer = 0
local function RandomInt(min, max)
  return (Hyperspace.random32() % (max - min + 1)) + min
end

local function OnTick()
  local playerShip = Hyperspace.ships.player
  if playerShip and playerShip.shieldSystem and not Hyperspace.Global.GetInstance():GetCApp().world.space.gamePaused then --Note: Use better pause check once other pause booleans are exposed. Console being opened will not register as a pause.
    if playerShip:HasAugmentation("FR_ENERGY_SHIELD_BATTERY") > 0 then
--	playerShip.shieldSystem.shields.power.first=0
--	playerShip.shieldSystem.shields.charger = 0
	  local shieldBoost = playerShip:GetAugmentationValue("SHIELD_RECHARGE") + 1 -- the shield recharge boost + base value
      local manningBonus = (playerShip.shieldSystem.iActiveManned)*0.1 + 1 -- recharge speed based on manning
      local powerInShields = playerShip:GetSystemPower(0) --Power in shield system.
      local layerEquivalent = powerInShields // 2 -- How many layers this equates to.
      local chargeSpeed = 0 --Speed at which overcharger charges.
      if layerEquivalent > 0 then
        chargeSpeed = layerEquivalent
      else
        chargeSpeed = -1 --Drain timer if shields are lacking power.
      end
	  timer = math.max(timer + layerEquivalent * (Hyperspace.FPS.SpeedFactor / 16) * shieldBoost * manningBonus, 0)
      local superPower = playerShip:GetShieldPower().super
	  if superPower.second > 5 then
		if superPower.first == superPower.second then --If super shield is full, drain timer.
		  timer = 0 
		end
	    else
			if superPower.first >= layerEquivalent then --If super shield is "full", drain timer.
			  timer = 0 
			end
		end
      if timer > baseChargeTime then --Add super shields
        timer = 0 
        for i = 1, barsPerPulse do
          local x = RandomInt(-1000, 1000)
          local y = RandomInt(-1000, 1000)
          playerShip.shieldSystem:AddSuperShield(Hyperspace.Point(x, y))
        end
      end

    end
  end
end 

local outlineColor = Graphics.GL_Color(0.8, 0.7, 0.5, 1.0) --Color for the outline of the charge bar (White).
local fillColor = Graphics.GL_Color(221 / 255, 195 / 255, 141 / 255, 255 / 255) --Color that fills the charge bar (Green).

local flashTimer = 0
local flashRate = 1 / 2 --Modifier for the speed at which the bar flashes at full
local function OnRender()
    local playerShip = Hyperspace.ships.player
    if playerShip:HasAugmentation("FR_ENERGY_SHIELD_BATTERY") > 0 then
      local progress = timer / baseChargeTime
      fillColor.a = 1

      local superPower = playerShip:GetShieldPower().super
      if superPower.first == superPower.second then
        fillColor.a = math.abs(math.sin(flashTimer * math.pi * flashRate))
        flashTimer = flashTimer + Hyperspace.FPS.SpeedFactor / 16
        if flashTimer > 1 then flashTimer = 0 end
        progress = 1
      end
      Graphics.CSurface.GL_DrawRectOutline(30, 89, 98, 6, outlineColor, 1)
      Graphics.CSurface.GL_DrawRect(32, 91, 94 * progress, 2, fillColor)
    end
end
script.on_internal_event(Defines.InternalEvents.ON_TICK, OnTick)
script.on_render_event(Defines.RenderEvents.LAYER_PLAYER, OnRender, function() end)


-- Super shield battery ENEMY

local baseChargeTime = 10 --How many seconds it takes to pulse with one shield layer's worth of power.
local barsPerPulse = 1 --How many super shield bars are added per pulse.

local timer = 0
local function RandomInt(min, max)
  return (Hyperspace.random32() % (max - min + 1)) + min
end

local function OnTickEnemy()
  local enemyShip = Hyperspace.ships.enemy
  if enemyShip and enemyShip.shieldSystem and not Hyperspace.Global.GetInstance():GetCApp().world.space.gamePaused then --Note: Use better pause check once other pause booleans are exposed. Console being opened will not register as a pause.
    if enemyShip:HasAugmentation("FR_ENERGY_SHIELD_BATTERY_ENEMY") > 0 then
--	enemyShip.shieldSystem.shields.power.first=0
--	enemyShip.shieldSystem.shields.charger=0
	  local shieldBoost = enemyShip:GetAugmentationValue("SHIELD_RECHARGE")+1 -- the shield recharge boost + base value
      local manningBonus = (enemyShip.shieldSystem.iActiveManned)*0.1 + 1 -- recharge speed based on manning
      local powerInShields = enemyShip:GetSystemPower(0) --Power in shield system.
      local layerEquivalent = powerInShields // 2 -- How many layers this equates to.
      local chargeSpeed = 0 --Speed at which overcharger charges.
      if layerEquivalent > 0 then
        chargeSpeed = layerEquivalent
      else
        chargeSpeed = -1 --Drain timer if shields are lacking power.
      end
	  timer = math.max(timer + layerEquivalent * (Hyperspace.FPS.SpeedFactor / 16) * shieldBoost * manningBonus, 0)
      local superPower = enemyShip:GetShieldPower().super
	  if superPower.second > 5 then
		if superPower.first == superPower.second then --If super shield is full, drain timer.
		  timer = 0 
		end
	    else
			if superPower.first >= layerEquivalent then --If super shield is "full", drain timer.
			  timer = 0 
			end
		end
      if timer > baseChargeTime then --Add super shields
        timer = 0 
        for i = 1, barsPerPulse do
          local x = RandomInt(-1000, 1000)
          local y = RandomInt(-1000, 1000)
          enemyShip.shieldSystem:AddSuperShield(Hyperspace.Point(x, y))
        end
      end

    end
  end
end 

script.on_internal_event(Defines.InternalEvents.ON_TICK, OnTickEnemy)

-- Enemy Anti-reloader

script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE,
function(ShipManager, AugName, AugValue)
  if ShipManager then
    local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId) -- funny math so it can check other ship stuff
    if OtherShipManager then
      if AugName == "AUTO_COOLDOWN" and OtherShipManager:HasAugmentation("FR_FRIEND_MAKER_SHIELD") ~= 0 then -- when the other ship has the augment
        local cooldownModifier = OtherShipManager:GetAugmentationValue("FR_FRIEND_MAKER_SHIELD")
        AugValue = AugValue - cooldownModifier -- changing AUTO_COOLDOWN by the opposing ship's ANTI_AUTO_COOLDOWN
      end
    end
  end
  return Defines.Chain.CONTINUE, AugValue
end)


-- Enemy anti-augment

--[[
script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE,
function(ShipManager, AugName, AugValue)
  local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId) -- funny math so it can check other ship stuff
  if OtherShipManager and not AugName:find("ANTIAUG_") then -- when the other ship has the augment
    local cooldownModifier = OtherShipManager:GetAugmentationValue("ANTIAUG_"..AugName)
    AugValue = AugValue - cooldownModifier -- changing augment by the opposing ship's ANTIAUG_ of the augment
  end

  return Defines.Chain.CONTINUE, AugValue
end)
]]

-- Watcher shield resist

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION_PRE, function(ShipManager, Projectile, Damage, CollisionResponse)
  local shieldPower = ShipManager:GetShieldPower()
  if ShipManager:HasAugmentation("FR_WATCHER_SHIELD") > 0 and shieldPower.super.first > 0 and Damage.iDamage > 0 and math.random(2)==2 then
    Damage.iDamage = 0 
    CollisionResponse.superDamage = 0 
    CollisionResponse.damage = 2147483647
    if Projectile:GetType() ~= 5 then
      Projectile:Kill()
    end
  end
  return Defines.Chain.CONTINUE
end)

-- Energy Hull Code

local function hullHit(shipManager, Damage)  
  if Damage.iDamage<0 then
    for i = 1, math.abs(Damage.iDamage) do -- this is the zs regen code from recharging zs, does the thing based on what heals is set to
      local x = RandomInt(-1000, 1000)
      local y = RandomInt(-1000, 1000)
      shipManager.shieldSystem:AddSuperShield(Hyperspace.Point(x, y))
    end
  else
    shipManager.ship.hullIntegrity.first=shipManager:GetShieldPower().super.first -- hull hp is set to zs hp
  end
end
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT,
function(ShipManager, Projectile, Location, Damage, shipFriendlyFire)
  if ShipManager:HasAugmentation("FR_ENERGY_HULL") > 0 then
    hullHit(ShipManager, Damage)
  end
  return Defines.CHAIN_CONTINUE
end)

script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM,
function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
  if ShipManager:HasAugmentation("FR_ENERGY_HULL") > 0 then
    hullHit(ShipManager, Damage)
  end
  return Defines.CHAIN_CONTINUE, beamHitType
end)

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION, function(ShipManager, Projectile, Damage, CollisionResponse)
  if ShipManager:HasAugmentation("FR_ENERGY_HULL") > 0 then 
    ShipManager.ship.hullIntegrity.first=ShipManager:GetShieldPower().super.first -- hull hp is set to zs hp
  end
  return Defines.Chain.CONTINUE
end)

-- Molten Armor (by Choosechee)
script.on_internal_event(Defines.InternalEvents.CREW_LOOP, function(crew)
  local currentShip = Hyperspace.Global.GetInstance():GetShipManager(crew.currentShipId)
  if not currentShip then return end
  local augmentValue = currentShip:GetAugmentationValue("FR_MOLTEN_ARMOR")
  local _, canBurn = crew.extend:CalculateStat(Hyperspace.CrewStat.CAN_BURN)

  if (augmentValue > 0 and canBurn) then
      local fireDamageMultiplier, _ = crew.extend:CalculateStat(Hyperspace.CrewStat.FIRE_DAMAGE_MULTIPLIER)
      local temporalEffect = 2^currentShip.ship.vRoomList[crew.iRoomId].extend.timeDilation
      crew:DirectModifyHealth(-5 * augmentValue * fireDamageMultiplier * (Hyperspace.FPS.SpeedFactor / 16) * temporalEffect)
      crew.iOnFire = math.max(4, crew.iOnFire) --new
  end
end)

-- Missile Arm (by Pepson with the help of Chrono Vortex)

local userdata_table = mods.multiverse.userdata_table

script.on_internal_event(Defines.InternalEvents.PROJECTILE_UPDATE_POST, function(projectile)
  if projectile.ownerId > -1 then
    local owner = Hyperspace.ships(projectile.ownerId)
    local projTable = userdata_table(projectile, "mods.fr.armmissile")
    local missiles = Hyperspace.Blueprints:GetWeaponBlueprint(projectile.extend.name).missiles
    if owner:HasAugmentation("FR_NEXUS_ARM_MISSILE") > 0 then
        if missiles > 0 and not projTable.refundedMiss and projectile.passedTarget then
            owner:ModifyMissileCount(missiles)
            projTable.refundedMiss = true
        end
    end
  end
  return Defines.Chain.CONTINUE
end)

-- Electromagnetic Arm (by Pepson)

script.on_internal_event(Defines.InternalEvents.GET_DODGE_FACTOR, function(ship, value)
  if ship:HasAugmentation("FR_NEXUS_ARM_ELECTROMAGNETIC_DEBUFF") > 0 then
    value = value + 10
  end
  return Defines.Chain.Continue, value
end)

--[[ Electromagnetic Arm Removal (by Choosechee)

script.on_internal_event(Defines.InternalEvents.JUMP_LEAVE, function(ship)
    if ship:HasAugmentation("HIDDEN FR_NEXUS_ARM_ELECTROMAGNETIC_DEBUFF") > 0 then
        ship:RemoveItem("HIDDEN FR_NEXUS_ARM_ELECTROMAGNETIC_DEBUFF")
    end
end)
]]

-- Weapon Remover Arm (by Pepson)

local function remove_enemy_weapon()
    local ship = Hyperspace.ships.enemy
    local weaponList = ship:GetWeaponList()
    local index = math.random(0, weaponList:size()-1)
    local refundChance = 10

    if weaponList[index] and weaponList[index].blueprint then
        if math.random(1, 100) <= refundChance then
            Hyperspace.ships.player:ModifyScrapCount(10 + weaponList[index].requiredPower * 10, true);
        end
        ship:RemoveItem(weaponList[index].blueprint.name)
    end
end

script.on_game_event("COMBAT_CHECK_FR_REMOVE_WEAPON", false, remove_enemy_weapon)

-- Nexus Engine Dodge Upgrade (by me!...with pepson, julk and Choosechee's help)

script.on_internal_event(Defines.InternalEvents.GET_DODGE_FACTOR, function(ship, dodgeChance)
    if ship:HasAugmentation("FR_NEXUS_ENGINES_DODGE") > 0 then
		if dodgeChance > 0 then
			dodgeChance = dodgeChance + ship:GetAugmentationValue("FR_NEXUS_ENGINES_DODGE")
		end
	end
    return Defines.Chain.Continue, dodgeChance
end)

-- Nexus Engine fuel Upgrade (by me and julk)

script.on_internal_event(Defines.InternalEvents.JUMP_LEAVE, function(ship)
  if ship:HasAugmentation("FR_NEXUS_ENGINES_FUEL") > 0 then
    local fuelRefundChance = ship:GetAugmentationValue("FR_NEXUS_ENGINES_FUEL")
      if math.random()<fuelRefundChance or fuelRefundChance>=1 then
        ship.fuel_count = ship.fuel_count + 1
    end
  end
end)

-- Nexus Shields Resist Upgrade (by me :o (with help from julk))

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION_PRE, function(ShipManager, Projectile, Damage, CollisionResponse)
  if ShipManager:HasAugmentation("FR_NEXUS_SHIELD_RESIST") > 0 then
    local ShieldResistChance = ShipManager:GetAugmentationValue("FR_NEXUS_SHIELD_RESIST")
    local shieldPower = ShipManager.shieldSystem.shields.power
    if Damage.iDamage > 0 and math.random()<ShieldResistChance and (Projectile:GetType() == 0 or Projectile:GetType() == 1 or Projectile:GetType() == 3) and shieldPower.super.first == 0 then
      return Defines.Chain.PREEMPT
    end
  end
  return Defines.Chain.CONTINUE
end)

-- Nexus Weapons Status Upgrade (code shamelessly stole from julk and slightly altered to work :troll)

local function EffectResist(ShipManager, Damage, Projectile)
local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId)
  if OtherShipManager and ShipManager and OtherShipManager:HasAugmentation("FR_NEXUS_WEAPONS_STATUS") > 0 then
  local augValue = OtherShipManager:GetAugmentationValue("FR_NEXUS_WEAPONS_STATUS")
    if Projectile and Projectile:GetType() == 2 then return
    end
    if Damage.breachChance > 0 then --In cases of negative augValue, do not add breach chance to weapons without breach (Intentional)
        Damage.breachChance = math.max(0, Damage.breachChance + augValue)
    end
    if Damage.fireChance > 0 then --In cases of negative augValue, do not add fire chance to weapons without fire (Intentional)
        Damage.fireChance = math.max(0, Damage.fireChance + augValue)
    end
  end
end
script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA, 
function(ShipManager, Projectile, Location, Damage, forceHit, shipFriendlyFire)
  EffectResist(ShipManager, Damage, Projectile)
  return Defines.Chain.CONTINUE, forceHit, shipFriendlyFire
end)
script.on_internal_event(Defines.InternalEvents.DAMAGE_BEAM, 
function(ShipManager, Projectile, Location, Damage, realNewTile, beamHitType)
  EffectResist(ShipManager, Damage)
  return Defines.Chain.CONTINUE, beamHitType
end)

-- Nexus Weapons Power Upgrade (Kokoro, arc and julk)

local weaponPower = {}
local weaponPowerFixed = true

script.on_init(function()
    weaponPowerFixed = false
end)
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  if ShipManager:HasAugmentation("FR_NEXUS_WEAPONS_POWER") > 0 then
    if not weaponPowerFixed then
        local sys = ShipManager.weaponSystem
        if sys then
            sys:ForceDecreasePower(99)
        end
        weaponPowerFixed = true
    end
    for weapon in vter(ShipManager:GetWeaponList()) do
      if weapon.blueprint.power > 1 and weapon.requiredPower > weapon.blueprint.power - 1 then
        weapon.requiredPower = math.max(1, weapon.blueprint.power - 1)
      end
    end
  end
end)

--[[Nexus Weapons Boost Upgrade (old)

local function fr_extra_projectile(ShipManager, Weapon, Projectile)
  local extra_projectile = ShipManager:GetAugmentationValue("FR_NEXUS_WEAPONS_BOOST")
  if ShipManager:HasAugmentation("FR_NEXUS_WEAPONS_BOOST") > 0 then 
    if Projectile and Projectile:GetType() == 1 or Projectile:GetType() == 3 or Projectile:GetType() == 4 then
      Weapon.numShots = Weapon.numShots + extra_projectile
    end
    if Projectile and Projectile:GetType() == 0 then
      Weapon.shotsFiredAtTarget = Weapon.shotsFiredAtTarget + extra_projectile
    end
  end
end

script.on_fire_event(Defines.FireEvents.WEAPON_FIRE, fr_extra_projectile)
script.on_fire_event(Defines.FireEvents.ARTILLERY_FIRE, fr_extra_projectile)

]]

-- Nexus Weapons Boost Upgrade (arc and chrono)

--[[--bombs

local get_room_at_location = mods.trc.get_room_at_location
local get_adjacent_rooms = mods.trc.get_adjacent_rooms

script.on_internal_event(Defines.InternalEvents.DAMAGE_AREA_HIT, function(ShipManager, Projectile, location, damage, shipFriendlyFire)
  if ShipManager:HasAugmentation("FR_NEXUS_WEAPONS_BOOST_BOMB") > 0 then 
    local weaponName = Projectile.extend.name
    if Projectile and Projectile:GetType() == 4 then
      local newDamage = Hyperspace.Damage()
      newDamage.iDamage = math.floor(damage.iDamage/2)
      newDamage.fireChance = math.floor(damage.fireChance/2)
      newDamage.breachChance = math.floor(damage.breachChance/2)
      newDamage.stunChance = math.floor(damage.stunChance/2)
      newDamage.iIonDamage = math.floor(damage.iIonDamage/2)
      newDamage.iSystemDamage = math.floor(damage.iSystemDamage/2)
      newDamage.iPersDamage = math.floor(damage.iPersDamage/2)
      newDamage.iStun = math.floor(damage.iStun/2)
      newDamage.ownerId = damage.ownerId
      newDamage.selfId = damage.selfId
      newDamage.iShieldPiercing = damage.iShieldPiercing
      newDamage.bHullBuster = damage.bHullBuster
      newDamage.bLockdown = damage.bLockdown
      newDamage.crystalShard = damage.crystalShard
      newDamage.bFriendlyFire = damage.bFriendlyFire
      Projectile.extend.name = ""
      for roomId, roomPos in pairs(get_adjacent_rooms(ShipManager.iShipId, get_room_at_location(ShipManager, location, false), false)) do
        ShipManager:DamageArea(roomPos, newDamage, true)
      end
      Hyperspace.Get_Projectile_Extend(Projectile).name = weaponName
    end
  end
end)


--Radius (by julk)

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION_PRE, function(ShipManager, Projectile, Damage, CollisionResponse)
  if ShipManager:HasAugmentation("FR_NEXUS_WEAPONS_BOOST_FLAK") > 0 then
    if Projectile and Projectile:GetType() == 0 then
      local shieldPower = ShipManager.shieldSystem.shields.power
      local popData = ShipManager:GetAugmentationValue("FR_NEXUS_WEAPONS_BOOST_FLAK")
        if shieldPower.super.first <= 0 and CollisionResponse.damage > Damage.iShieldPiercing then
            ShipManager.shieldSystem:CollisionReal(Projectile.position.x, Projectile.position.y, Hyperspace.Damage(), true)
            shieldPower.first = math.max(0, shieldPower.first - popData)
        end
    end      
  end
  return Defines.Chain.CONTINUE
end)

--Solids/Missiles (by me and arc)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  if ShipManager:HasAugmentation("FR_NEXUS_WEAPONS_BOOST_MISSILE") > 0 then 
    for weapon in vter(ShipManager:GetWeaponList()) do
      if weapon.blueprint.typeName == "MISSILE" then
        weapon.blueprint.drone_targetable = 0
      end
    end
  end
end)

]]

--Lasers/Ions/ weapon boster full (by me and julk)

local function fr_weapon_booster(ShipManager, _, projectile)
  if ShipManager:HasAugmentation("FR_NEXUS_WEAPONS_BOOST") > 0 then 
    local booster_damage_modifier = ShipManager:GetAugmentationValue("FR_NEXUS_WEAPONS_BOOST")
    if projectile:GetType() == 1 or projectile:GetType() == 0 or projectile:GetType() == 3 or projectile:GetType() == 4 then
      if (projectile.damage.iIonDamage > 0 ) then
      projectile.damage.iIonDamage = projectile.damage.iIonDamage + booster_damage_modifier
      end
      if (projectile.damage.iDamage > 0) then
        projectile.damage.iDamage = projectile.damage.iDamage + booster_damage_modifier
      end
      if (projectile.damage.iSystemDamage > 0 and projectile.damage.iDamage <= 0) then
        projectile.damage.iSystemDamage = projectile.damage.iSystemDamage + booster_damage_modifier
      end
      if (projectile.damage.iSystemDamage > 0 and projectile.damage.iIonDamage > 0 and projectile.damage.iDamage > 0) then
        projectile.damage.iSystemDamage = projectile.damage.iSystemDamage + booster_damage_modifier
      end
      if (projectile.damage.iPersDamage > 0 and projectile.damage.iDamage <= 0) then
        projectile.damage.iPersDamage = projectile.damage.iPersDamage + booster_damage_modifier
      end
    end
  end
end

script.on_fire_event(Defines.FireEvents.WEAPON_FIRE, fr_weapon_booster)
script.on_fire_event(Defines.FireEvents.ARTILLERY_FIRE, fr_weapon_booster)

-- Nexus oxygen breach Upgrade (me, julk, choosechee, chrono and LoudMute)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  if ShipManager:HasAugmentation("FR_NEXUS_OXYGEN_BREACH") > 0 and ShipManager:GetSystem(2):GetEffectivePower() > 0 then 
    for system in vter(ShipManager.vSystemList) do
      if system.bBreached then
        ShipManager.oxygenSystem:ModifyRoomOxygen(system.roomId, 10.525)
      end
    end
  end
end)

-- Nexus drone boost Upgrade (kokoro's base code and pepson and choosechee's help)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  local combatdrones = ShipManager.spaceDrones
  local speed = ShipManager:GetAugmentationValue("FR_NEXUS_DRONES_BOOST")
  if ShipManager:HasAugmentation("FR_NEXUS_DRONES_BOOST") > 0 then 
      for combatdrone in vter(combatdrones) do
        if combatdrone.powered then
          if combatdrone.currentSpeed and combatdrone.weaponCooldown >= 0 then
            combatdrone.weaponCooldown = (combatdrone.weaponCooldown) - Hyperspace.FPS.SpeedFactor / 16 * (speed - 1)
            if combatdrone.weaponCooldown <= 0 then
              combatdrone.weaponCooldown = -1
            end
          end
        end
        for _ = 1, speed - 1 do
          combatdrone:OnLoop()
        end
      end
  end
end)

-- Nexus cloak charge Upgrade (me, julk, LoudMute and pepson)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  local weaponchargespeed = ShipManager:GetAugmentationValue("FR_NEXUS_CLOAK_CHARGE")
  local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId)
  if ShipManager:HasAugmentation("FR_NEXUS_CLOAK_CHARGE") > 0 then
    local cloak = ShipManager.cloakSystem
    if OtherShipManager and cloak and cloak.bTurnedOn then
      for weapon in vter(OtherShipManager:GetWeaponList()) do
        if weapon.powered and weapon.cooldown.first > 0 then
          weapon.cooldown.first = math.max(0, weapon.cooldown.first - Hyperspace.FPS.SpeedFactor / 16 * weaponchargespeed) 
        end
      end
    end
  end
end)


-- Nexus cloak emp Upgrade (me,julk , LoudMute and pepson)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId)
  if ShipManager:HasAugmentation("FR_NEXUS_CLOAK_EMP") > 0 then
    local cloak = ShipManager.cloakSystem
    if cloak and cloak.bTurnedOn then
      if OtherShipManager and OtherShipManager.hackingSystem and OtherShipManager.hackingSystem.drone then
        OtherShipManager.hackingSystem:BlowHackingDrone()
      end
      for drone in vter(OtherShipManager.spaceDrones) do
        drone.ionStun = drone.ionStun + Hyperspace.FPS.SpeedFactor / 16
      end
    end
  end
end)

--[[-- Nexus teleport recall Upgrade (me and pepson)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  if ShipManager:HasAugmentation("FR_NEXUS_TELEPORTER_RECALL") > 0 then 
      local OtherShip = Hyperspace.ships(1 - ShipManager.iShipId)
      if OtherShip and ShipManager.iShipId ~= OtherShip.iShipId and ShipManager.jump_timer.first > ShipManager.jump_timer.second - 1 then
          print("Teleporting to ship " .. tostring(OtherShip.iShipId) .. " timer " .. tostring(ShipManager.jump_timer.first).."/"..tostring(ShipManager.jump_timer.second))
          for crew in vter(ShipManager.vCrewList) do
              if crew.iShipId == OtherShip.iShipId then
                  crew.extend:InitiateTeleport(OtherShip.iShipId,0,0)
              end
          end
      end
  end
end)
]]

-- Nexus teleport power Upgrade (me and choosechee)
local crewwasinteleporter = {}
local crewteleportedlastframe = {}

local function rechargeTeleportedCrewAbilities(shipWithAugment, crewList)
  local teleporterroom = shipWithAugment.teleportSystem:GetRoomId()
  
  for crew in vter(crewList) do
    if crew.iShipId == shipWithAugment.iShipId and crew.currentShipId ~= crew.iShipId and crew.table[crewwasinteleporter] and (crew.table[crewteleportedlastframe] and not crew.extend.customTele.teleporting) then
      for power in vter(crew.extend.crewPowers) do
        power.powerCooldown.first = power.powerCooldown.second
      end
    end
    if not crew.extend.customTele.teleporting then
      crew.table[crewwasinteleporter] = crew:InsideRoom(teleporterroom)
    end
    crew.table[crewteleportedlastframe] = crew.extend.customTele.teleporting
  end
end

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId)
  if ShipManager:HasAugmentation("FR_NEXUS_TELEPORTER_POWER") > 0 and OtherShipManager then 
    local teleporter = ShipManager.teleportSystem
    if teleporter then
      rechargeTeleportedCrewAbilities(ShipManager, ShipManager.vCrewList)
      rechargeTeleportedCrewAbilities(ShipManager, OtherShipManager.vCrewList)
    end
  end
end)

--[[Nexus clonebay multiple Upgrade (julk)

local fTimeToCloneBefore = 0
local cloneBefore = {0}
script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  if ShipManager:HasAugmentation("FR_NEXUS_CLONE_MULTIPLE") > 0 then 
    local cloneBay = ShipManager.cloneSystem
    if cloneBay then
      if cloneBay.fTimeToClone < (fTimeToCloneBefore or 0) and cloneBay.clone ~= cloneBefore[0] and cloneBay.clone then
        cloneBefore[1]=math.min(0,cloneBefore[1]-1)
        if cloneBefore[1]==0 then
          cloneBay.fTimeToClone = cloneBay.fTimeGoal
          cloneBefore[1]=2
        end
      end
      fTimeToCloneBefore = fTimeToClone
      cloneBefore[0]=clone
    end
  end
end)
]]

-- Nexus temporal global Upgrade

script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE,
function(ShipManager, AugName, AugValue)
  if ShipManager then
    local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId) -- funny math so it can check other ship stuff
    if OtherShipManager then
      if AugName == "AUTO_COOLDOWN" and OtherShipManager:HasAugmentation("FR_NEXUS_TEMPORAL_GLOBAL") ~= 0 then -- when the other ship has the augment
        local cooldownModifier = OtherShipManager:GetAugmentationValue("FR_NEXUS_TEMPORAL_GLOBAL")
        AugValue = AugValue - cooldownModifier -- changing AUTO_COOLDOWN by the opposing ship's ANTI_AUTO_COOLDOWN
      end
      if AugName == "SHIELD_RECHARGE" and OtherShipManager:HasAugmentation("FR_NEXUS_TEMPORAL_GLOBAL") ~= 0 then -- when the other ship has the augment
        local cooldownModifier = OtherShipManager:GetAugmentationValue("FR_NEXUS_TEMPORAL_GLOBAL")
        AugValue = AugValue - cooldownModifier -- changing AUTO_COOLDOWN by the opposing ship's ANTI_AUTO_COOLDOWN
      end
    end
  end
  return Defines.Chain.CONTINUE, AugValue
end)

-- Nexus sensors charge Upgrade (me, LoudMute and julk)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  local weaponchargespeed = ShipManager:GetAugmentationValue("FR_NEXUS_SENSORS_CHARGE")
  local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId)
  if ShipManager:HasAugmentation("FR_NEXUS_SENSORS_CHARGE") > 0 then 
    if OtherShipManager then
      local cloak = OtherShipManager.cloakSystem
      if cloak and cloak.bTurnedOn then
        for weapon in vter(ShipManager:GetWeaponList()) do
          if weapon.powered and weapon.cooldown.first < weapon.cooldown.second then
            weapon.cooldown.first = math.min(math.max(weapon.cooldown.second-0.0001,weapon.cooldown.first), (weapon.cooldown.first) + Hyperspace.FPS.SpeedFactor / 16 * weaponchargespeed) 
          end
        end
      end
    end
  end
end)

-- Nexus sensors accuracy Upgrade

script.on_internal_event(Defines.InternalEvents.GET_DODGE_FACTOR, function(ShipManager, value)
  local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId)
  if ShipManager and OtherShipManager then
    if OtherShipManager:HasAugmentation("FR_NEXUS_SENSORS_ACCURACY") > 0 then
      value = value - 10
    end
  end
  return Defines.Chain.Continue, value
end)

-- Augustus Golden System (arc)

script.on_internal_event(Defines.InternalEvents.GET_AUGMENTATION_VALUE, function(shipManager, augName, augValue)
  if shipManager and shipManager:HasAugmentation("FR_GOLDEN_SYSTEMS") > 0 then 
  local currentscrap = shipManager.currentScrap
    if augName == "AUTO_COOLDOWN" then
      augValue = augValue + (currentscrap / 1000)
    end
    if augName == "SHIELD_RECHARGE" then
      augValue = augValue + (currentscrap / 500)
    end
    if augName == "FTL_BOOSTER" then
      augValue = augValue + (currentscrap / 200)
    end
  end
  return Defines.Chain.CONTINUE, augValue
end, -100)

--Leah augment (by me and julk)

local function fr_weapon_booster(ShipManager, _, projectile)
  if ShipManager:HasAugmentation("FR_BEAM_OVERCLOCKER") > 0 then 
    local booster_damage_modifier = ShipManager:GetAugmentationValue("FR_BEAM_OVERCLOCKER")
    if projectile:GetType() == 5 then
      if (projectile.damage.iIonDamage > 0 ) then
      projectile.damage.iIonDamage = projectile.damage.iIonDamage + booster_damage_modifier
      end
      if (projectile.damage.iDamage > 0) then
        projectile.damage.iDamage = projectile.damage.iDamage + booster_damage_modifier
      end
      if (projectile.damage.iSystemDamage > 0 and projectile.damage.iDamage <= 0) then
        projectile.damage.iSystemDamage = projectile.damage.iSystemDamage + booster_damage_modifier
      end
      if (projectile.damage.iSystemDamage > 0 and projectile.damage.iIonDamage > 0 and projectile.damage.iDamage > 0) then
        projectile.damage.iSystemDamage = projectile.damage.iSystemDamage + booster_damage_modifier
      end
      if (projectile.damage.iPersDamage > 0 and projectile.damage.iDamage <= 0) then
        projectile.damage.iPersDamage = projectile.damage.iPersDamage + booster_damage_modifier
      end
    end
  end
end

script.on_fire_event(Defines.FireEvents.WEAPON_FIRE, fr_weapon_booster)
script.on_fire_event(Defines.FireEvents.ARTILLERY_FIRE, fr_weapon_booster)

--[[Shadow mist augment (by me and Lizzard)

script.on_internal_event(Defines.InternalEvents.PROJECTILE_FIRE, function(projectile, weapon)
  local shipManager = Hyperspace.ships(projectile.ownerId)
  local otherShipManager = Hyperspace.ships(1 - shipManager.iShipId)
  if shipManager and otherShipManager then
      if otherShipManager:HasAugmentation("FR_SHADOW_MIST") > 0 then 
          local booster_accuracy_modifier = otherShipManager:GetAugmentationValue("FR_SHADOW_MIST")
          if projectile:GetType() ~= 2 and projectile:GetType() ~= 5 then
              projectile.extend.customDamage.accuracyMod = projectile.extend.customDamage.accuracyMod - booster_accuracy_modifier
          end
      end
  end
end)

]]

script.on_internal_event(Defines.InternalEvents.PROJECTILE_PRE, function(projectile)
  if Hyperspace.ships.enemy and projectile.ownerId > -1 then
    local shipManager = Hyperspace.ships(projectile.ownerId)
    local otherShipManager = Hyperspace.ships(1 - shipManager.iShipId)
    if shipManager and otherShipManager then
        if otherShipManager:HasAugmentation("FR_SHADOW_MIST") > 0 and projectile:GetSpaceId() ~= projectile:GetOwnerId() and not projectile.table.rolledShadowMiss then 
            local booster_accuracy_modifier = otherShipManager:GetAugmentationValue("FR_SHADOW_MIST")
            if projectile:GetType() ~= 2 and projectile:GetType() ~= 5 and projectile:GetType() ~= 6 then
                local random_number = math.random()
                projectile.table.rolledShadowMiss = true
                if random_number < booster_accuracy_modifier then
                    projectile.missed = true
                end
            end
        end
    end
  end
  return Defines.Chain.CONTINUE
end)

-- Hektar Shield Accuracy

script.on_internal_event(Defines.InternalEvents.GET_DODGE_FACTOR, function(ShipManager, value)
  local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId)
  if ShipManager and OtherShipManager then
    if OtherShipManager:HasAugmentation("FR_HEKTAR_SUPERSHIELD_ACCURACY") > 0 then
      value = value - 30
    end
  end
  return Defines.Chain.Continue, value
end)


--osmian black hole augment (by me and lizzard)

local radhealthDef = Hyperspace.StatBoostDefinition()
radhealthDef.stat = Hyperspace.CrewStat.MAX_HEALTH
radhealthDef.amount = 1
radhealthDef.duration = 1
radhealthDef.maxStacks = 1
radhealthDef.cloneClear = false
radhealthDef.boostType = Hyperspace.StatBoostDefinition.BoostType.MULT
radhealthDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
radhealthDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
radhealthDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ENEMIES
radhealthDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(radhealthDef)
local radhealthStatBoost = Hyperspace.StatBoost(radhealthDef)

local radrepairDef = Hyperspace.StatBoostDefinition()
radrepairDef.stat = Hyperspace.CrewStat.REPAIR_SPEED_MULTIPLIER
radrepairDef.amount = 1
radrepairDef.duration = 1
radrepairDef.maxStacks = 1
radrepairDef.cloneClear = false
radrepairDef.boostType = Hyperspace.StatBoostDefinition.BoostType.MULT
radrepairDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
radrepairDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
radrepairDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ENEMIES
radrepairDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(radrepairDef)
local radrepairStatBoost = Hyperspace.StatBoost(radrepairDef)

local radhealSpeedDef = Hyperspace.StatBoostDefinition()
radhealSpeedDef.stat = Hyperspace.CrewStat.HEAL_SPEED_MULTIPLIER
radhealSpeedDef.amount = 1
radhealSpeedDef.duration = 1
radhealSpeedDef.maxStacks = 1
radhealSpeedDef.cloneClear = false
radhealSpeedDef.boostType = Hyperspace.StatBoostDefinition.BoostType.MULT
radhealSpeedDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
radhealSpeedDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
radhealSpeedDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ENEMIES
radhealSpeedDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(radhealSpeedDef)
local radhealSpeedStatBoost = Hyperspace.StatBoost(radhealSpeedDef)

local oldReactor = 0
mods.fr.blackholeradboost = {}
local istheradboostup = mods.fr.blackholeradboost 

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  if ShipManager:HasAugmentation("FR_OSMIAN_VORTEX") > 0 then
    istheradboostup = 1
    local ReactorLevel = ShipManager:GetAvailablePower().first
      if ReactorLevel ~= oldReactor then
        radhealthDef.amount = math.max(0.3810477 + (1 - 0.3810477) / (1 + ( ReactorLevel / 68.84276) ^ 3.846), 0.1)
        Hyperspace.StatBoostDefinition.statBoostDefs:push_back(radhealthDef)
        radrepairDef.amount = math.max(0.3810477 + (1 - 0.3810477) / (1 + ( ReactorLevel / 68.84276) ^ 3.846), 0.1)
        Hyperspace.StatBoostDefinition.statBoostDefs:push_back(radrepairDef)
        radhealSpeedDef.amount = math.max(0.3810477 + (1 - 0.3810477) / (1 + ( ReactorLevel / 68.84276) ^ 3.846), 0.1)
        Hyperspace.StatBoostDefinition.statBoostDefs:push_back(radhealSpeedDef)
      end
      oldReactor = ReactorLevel
  end
end)

script.on_internal_event(Defines.InternalEvents.CREW_LOOP, function(crew)
  local userdata = mods.multiverse.userdata_table(crew, 'mods.fr.blackholerad')
  local radstatboostTable = userdata_table(crew, "mods.fr.blackholeradtime")
  if not userdata.createdStatBoost and istheradboostup == 1 then
    Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(radhealthStatBoost, crew)
    Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(radrepairStatBoost, crew)
    Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(radhealSpeedStatBoost, crew)
    userdata.createdStatBoost = true
    radstatboostTable.tableTime = 1
  end
  if userdata.createdStatBoost and radstatboostTable.tableTime then
    radstatboostTable.tableTime = math.max(radstatboostTable.tableTime - Hyperspace.FPS.SpeedFactor/16, 0)
      if radstatboostTable.tableTime <= 0 then
        userdata.createdStatBoost = false
        radstatboostTable.tableTime = nil
        istheradboostup = nil
      end
  end
  return Defines.Chain.Continue, value
end)

--osmian white hole augment (by me and lizzard)

local holohealthDef = Hyperspace.StatBoostDefinition()
holohealthDef.stat = Hyperspace.CrewStat.MAX_HEALTH
holohealthDef.amount = 1
holohealthDef.duration = 1
holohealthDef.maxStacks = 1
holohealthDef.cloneClear = false
holohealthDef.boostType = Hyperspace.StatBoostDefinition.BoostType.MULT
holohealthDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
holohealthDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
holohealthDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
holohealthDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(holohealthDef)
local holohealthStatBoost = Hyperspace.StatBoost(holohealthDef)

local holorepairDef = Hyperspace.StatBoostDefinition()
holorepairDef.stat = Hyperspace.CrewStat.REPAIR_SPEED_MULTIPLIER
holorepairDef.amount = 1
holorepairDef.duration = 1
holorepairDef.maxStacks = 1
holorepairDef.cloneClear = false
holorepairDef.boostType = Hyperspace.StatBoostDefinition.BoostType.MULT
holorepairDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
holorepairDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
holorepairDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
holorepairDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(holorepairDef)
local holorepairStatBoost = Hyperspace.StatBoost(holorepairDef)

local holosabotageDef = Hyperspace.StatBoostDefinition()
holosabotageDef.stat = Hyperspace.CrewStat.SABOTAGE_SPEED_MULTIPLIER
holosabotageDef.amount = 1
holosabotageDef.duration = 1
holosabotageDef.maxStacks = 1
holosabotageDef.cloneClear = false
holosabotageDef.boostType = Hyperspace.StatBoostDefinition.BoostType.MULT
holosabotageDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
holosabotageDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
holosabotageDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
holosabotageDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(holosabotageDef)
local holosabotageStatBoost = Hyperspace.StatBoost(holosabotageDef)

local holodamageDef = Hyperspace.StatBoostDefinition()
holodamageDef.stat = Hyperspace.CrewStat.DAMAGE_MULTIPLIER
holodamageDef.amount = 1
holodamageDef.duration = 1
holodamageDef.maxStacks = 1
holodamageDef.cloneClear = false
holodamageDef.boostType = Hyperspace.StatBoostDefinition.BoostType.MULT
holodamageDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
holodamageDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
holodamageDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
holodamageDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(holodamageDef)
local holodamageStatBoost = Hyperspace.StatBoost(holodamageDef)

local holomovementDef = Hyperspace.StatBoostDefinition()
holomovementDef.stat = Hyperspace.CrewStat.MOVE_SPEED_MULTIPLIER
holomovementDef.amount = 1
holomovementDef.duration = 1
holomovementDef.maxStacks = 1
holomovementDef.cloneClear = false
holomovementDef.boostType = Hyperspace.StatBoostDefinition.BoostType.MULT
holomovementDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
holomovementDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
holomovementDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
holomovementDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(holomovementDef)
local holomovementStatBoost = Hyperspace.StatBoost(holomovementDef)

local oldReactor = 0
mods.fr.whiteholeradboost = {}
local istheholoboostup = mods.fr.whiteholeradboost 

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  if ShipManager:HasAugmentation("FR_OSMIAN_VORTEX_HOLOGRAM") > 0 then
    istheholoboostup = 1
    local ReactorLevel = ShipManager:GetAvailablePower().first
    if ReactorLevel ~= oldReactor then
      holohealthDef.amount = math.max(3.092097 + (1 - 3.092097)/(1 + (ReactorLevel/49.50974)^4.378459), 1)
      Hyperspace.StatBoostDefinition.statBoostDefs:push_back(holohealthDef)
      holorepairDef.amount = math.max(3.092097 + (1 - 3.092097)/(1 + (ReactorLevel/49.50974)^4.378459), 1)
      Hyperspace.StatBoostDefinition.statBoostDefs:push_back(holorepairDef)
      holosabotageDef.amount = math.max(3.092097 + (1 - 3.092097)/(1 + (ReactorLevel/49.50974)^4.378459), 1)
      Hyperspace.StatBoostDefinition.statBoostDefs:push_back(holosabotageDef)
      holomovementDef.amount = math.max(3.092097 + (1 - 3.092097)/(1 + (ReactorLevel/49.50974)^4.378459), 1)
      Hyperspace.StatBoostDefinition.statBoostDefs:push_back(holomovementDef)
      holodamageDef.amount = math.max(3.092097 + (1 - 3.092097)/(1 + (ReactorLevel/49.50974)^4.378459), 1)
      Hyperspace.StatBoostDefinition.statBoostDefs:push_back(holodamageDef)
    end
  oldReactor = ReactorLevel
  end
end)

script.on_internal_event(Defines.InternalEvents.CREW_LOOP, function(crew)
  local userdata = mods.multiverse.userdata_table(crew, 'mods.fr.whiteholehologram')
  local holostatboostTable = userdata_table(crew, "mods.fr.whiteholetime")
  if not userdata.createdStatBoost and istheholoboostup == 1 and crew.iShipId == 0 and crew:GetSpecies() == 'zoltan_osmian_hologram' or crew:GetSpecies() == 'fr_zoltan_osmian_hologram_weak' then 
    Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(holohealthStatBoost, crew)
    Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(holorepairStatBoost, crew)
    Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(holosabotageStatBoost, crew)
    Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(holodamageStatBoost, crew)
    Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(holomovementStatBoost, crew)
    userdata.createdStatBoost = true
    holostatboostTable.tableTime = 1
  end
  if userdata.createdStatBoost and holostatboostTable.tableTime then
    holostatboostTable.tableTime = math.max(holostatboostTable.tableTime - Hyperspace.FPS.SpeedFactor/16, 0)
      if holostatboostTable.tableTime <= 0 then
        userdata.createdStatBoost = false
        holostatboostTable.tableTime = nil
        istheholoboostup = nil
      end
  end
  return Defines.Chain.Continue, value
end)


--osmian green  hole augment (by me and lizzard)


local healhealthDef = Hyperspace.StatBoostDefinition()
healhealthDef.stat = Hyperspace.CrewStat.MAX_HEALTH
healhealthDef.amount = 1
healhealthDef.duration = 1
healhealthDef.maxStacks = 1
healhealthDef.cloneClear = false
healhealthDef.boostType = Hyperspace.StatBoostDefinition.BoostType.MULT
healhealthDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
healhealthDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
healhealthDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
healhealthDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(healhealthDef)
local healhealthStatBoost = Hyperspace.StatBoost(healhealthDef)

local healhealDef = Hyperspace.StatBoostDefinition()
healhealDef.stat = Hyperspace.CrewStat.TRUE_HEAL_AMOUNT
healhealDef.amount = 0
healhealDef.duration = 1
healhealDef.maxStacks = 1
healhealDef.cloneClear = false
healhealDef.boostType = Hyperspace.StatBoostDefinition.BoostType.FLAT
healhealDef.boostSource = Hyperspace.StatBoostDefinition.BoostSource.AUGMENT
healhealDef.shipTarget = Hyperspace.StatBoostDefinition.ShipTarget.ALL
healhealDef.crewTarget = Hyperspace.StatBoostDefinition.CrewTarget.ALL
healhealDef.realBoostId = Hyperspace.StatBoostDefinition.statBoostDefs:size()
Hyperspace.StatBoostDefinition.statBoostDefs:push_back(healhealDef)
local healhealStatBoost = Hyperspace.StatBoost(healhealDef)

local oldReactor = 0
mods.fr.greenholeradboost = {}
local isthehealboostup = mods.fr.greenholeradboost 

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  if ShipManager.iShipId ~= 0 then
    return
  end
  if ShipManager:HasAugmentation("FR_OSMIAN_VORTEX_HEAL") > 0 then
    isthehealboostup = 1
    local ReactorLevel = ShipManager:GetAvailablePower().first
    if ReactorLevel ~= oldReactor then
      healhealthDef.amount = math.max(6.753534 + (1 - 6.753534)/(1 + (ReactorLevel/213.4063)^2.056506), 1)
      Hyperspace.StatBoostDefinition.statBoostDefs:push_back(healhealthDef)
      healhealDef.amount = math.max(20.45685 + (1 - 20.45685)/(1 + (ReactorLevel/41.3302)^4.219021), 1)
      Hyperspace.StatBoostDefinition.statBoostDefs:push_back(healhealDef)
    end
  oldReactor = ReactorLevel
  end
end)

script.on_internal_event(Defines.InternalEvents.CREW_LOOP, function(crew)
  local userdata = mods.multiverse.userdata_table(crew, 'mods.fr.healholelife')
  local healstatboostTable = userdata_table(crew, "mods.fr.greenholetime")
  if not userdata.createdStatBoost and isthehealboostup == 1 and crew.iShipId == 0 then 
    Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(healhealthStatBoost, crew)
    Hyperspace.StatBoostManager.GetInstance():CreateTimedAugmentBoost(healhealStatBoost, crew)
    userdata.createdStatBoost = true
    healstatboostTable.tableTime = 1
  end
  if userdata.createdStatBoost and healstatboostTable.tableTime then
    healstatboostTable.tableTime = math.max(healstatboostTable.tableTime - Hyperspace.FPS.SpeedFactor/16, 0)
      if healstatboostTable.tableTime <= 0 then
        userdata.createdStatBoost = false
        healstatboostTable.tableTime = nil
        isthehealboostup = nil
      end
  end
  return Defines.Chain.Continue, value
end)

--Probe hunter augment (by me and julk)

local function fr_probe_booster(ShipManager, _, projectile)
  local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId)
  local EnemyIsAuto = OtherShipManager.bAutomated
  if ShipManager:HasAugmentation("FR_AUTO_HUNTER_GEAR") > 0 and EnemyIsAuto then 
    local probe_damage_modifier = ShipManager:GetAugmentationValue("FR_AUTO_HUNTER_GEAR")
    if projectile:GetType() == 1 or projectile:GetType() == 0 or projectile:GetType() == 3 or projectile:GetType() == 4 or projectile:GetType() == 5 then
      if (projectile.damage.iIonDamage > 0 ) then
      projectile.damage.iIonDamage = projectile.damage.iIonDamage * probe_damage_modifier
      end
      if (projectile.damage.iDamage > 0) then
        projectile.damage.iDamage = projectile.damage.iDamage * probe_damage_modifier
      end
      if (projectile.damage.iSystemDamage > 0 and projectile.damage.iDamage <= 0) then
        projectile.damage.iSystemDamage = projectile.damage.iSystemDamage * probe_damage_modifier
      end
      if (projectile.damage.iSystemDamage > 0 and projectile.damage.iIonDamage > 0 and projectile.damage.iDamage > 0) then
        projectile.damage.iSystemDamage = projectile.damage.iSystemDamage * probe_damage_modifier
      end
      if (projectile.damage.iPersDamage > 0 and projectile.damage.iDamage <= 0) then
        projectile.damage.iPersDamage = projectile.damage.iPersDamage * probe_damage_modifier
      end
    end
  end
end

script.on_fire_event(Defines.FireEvents.WEAPON_FIRE, fr_probe_booster)
script.on_fire_event(Defines.FireEvents.ARTILLERY_FIRE, fr_probe_booster)

-- Narrative Shield - (by me, pepson, arc, lizzard and ranhai)

script.on_internal_event(Defines.InternalEvents.PRE_CREATE_CHOICEBOX, function(event)
  local ShipManager = Hyperspace.ships.player
  if ShipManager and ShipManager:HasAugmentation("FR_NARRATIVE_SHIELD") > 0 then
    if event.eventName == "LIGHTSPEED_DROPPOINT" then
      return
    end
    Choices = event:GetChoices()
    for choice in vter(Choices) do
      local req_lvl = ShipManager:HasEquipment(choice.requirement.object)
      if (req_lvl < choice.requirement.min_level or req_lvl > choice.requirement.max_level) and choice.requirement.blue then
        choice.requirement.min_level = 1
        choice.requirement.max_level = 1
        choice.requirement.object = "FR_NARRATIVE_SHIELD"
      end
    end
  end
end)


--[[boarder event blocker G augment (by me and julk) - not working + bad idea (breaks sylvan)

script.on_internal_event(Defines.InternalEvents.PRE_CREATE_CHOICEBOX, function(event)
  local ShipManager = Hyperspace.ships.player
  if ShipManager and ShipManager:HasAugmentation("FR_NECROMANCER_SHIELD") > 0 then
    local Boarders = event.boarders
    if Boarders.min > 0 or Boarders.max > 0 then
      Boarders.min = 0
      Boarders.max = 0
    end
  end
end)
]]

-- Refuge's Shield Advanced - (by me and julk)

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION, function(ShipManager, Projectile, Damage, CollisionResponse)
  if Projectile.ownerId > -1 then
      local shieldPower = ShipManager:GetShieldPower()
      local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId)
      if ShipManager and OtherShipManager and ShipManager:HasEquipment("FR_REFUGE_SHIELDS") > 0 and shieldPower.super.first > 0 and Damage.iIonDamage > 0 then
          local BP = Hyperspace.Blueprints:GetWeaponBlueprint(Projectile.extend.name)
          local ionReflect;
          if Projectile:GetType() == 1 then --laser/flak
              ionReflect = Hyperspace.App.world.space:CreateLaserBlast(BP, Hyperspace.Pointf(CollisionResponse.point.x-5*Projectile.speed.x, CollisionResponse.point.y-5*Projectile.speed.y), Projectile.currentSpace, ShipManager.iShipId, OtherShipManager:GetRandomRoomCenter(), 1-Projectile.currentSpace, Projectile.entryAngle)
              ionReflect.flight_animation = Projectile.flight_animation
          end
          if Projectile:GetType() == 3 then--missile
              ionReflect = Hyperspace.App.world.space:CreateMissile(BP, Hyperspace.Pointf(CollisionResponse.point.x-5*Projectile.speed.x, CollisionResponse.point.y-5*Projectile.speed.y), Projectile.currentSpace, ShipManager.iShipId, OtherShipManager:GetRandomRoomCenter(), 1-Projectile.currentSpace, Projectile.entryAngle)
          end
          if Projectile:GetType() == 5 then--beam
            local rooms = Hyperspace.ShipGraph.GetShipInfo(OtherShipManager.iShipId).rooms
            local roomId1 = math.random(0,rooms:size()-1)
            local roomId2 = math.random(0,rooms:size()-2)
            if(roomId2>=roomId1) then roomId2 = roomId2 +1 end
            ionReflect = Hyperspace.App.world.space:CreateBeam(BP, CollisionResponse.point, 0, ShipManager.iShipId, OtherShipManager:GetRoomCenter(roomId1), OtherShipManager:GetRoomCenter(roomId2), 1-ShipManager.iShipId, math.min(20,BP.length), Projectile.entryAngle)
          end
          ionReflect.death_animation = Projectile.death_animation
          ionReflect.damage = Damage
      end
  end
  return Defines.Chain.CONTINUE
end)


--[[ Refuge's Shield basic - (by me and julk)

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION_PRE, function(ShipManager, Projectile, Damage, CollisionResponse)
  if Projectile.ownerId > -1 then
    local shieldPower = ShipManager.shieldSystem.shields.power
    local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId)
    if ShipManager and OtherShipManager and ShipManager:HasAugmentation("FR_REFUGE_SHIELDS") > 0 and shieldPower.super.first > 0 and Damage.iIonDamage > 0 then
      ionShot = Hyperspace.App.world.space:CreateLaserBlast(Hyperspace.Blueprints:GetWeaponBlueprint("ION_1"), Hyperspace.Pointf(Projectile.position.x, Projectile.position.y), Projectile.currentSpace, ShipManager.iShipId, OtherShipManager:GetRandomRoomCenter(), 1-Projectile.currentSpace, 0)
      ionShot:ComputeHeading()
    end
  end
  return Defines.Chain.CONTINUE
end)]]

-- prototype shield (me)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  local OtherShipManager = Hyperspace.ships(1 - ShipManager.iShipId)
  if ShipManager and OtherShipManager and ShipManager:HasAugmentation("FR_PROTOTYPE_SHIELDS") > 0 then
    local shieldPower = ShipManager:GetShieldPower()
    if shieldPower.super.first > 0 then
      for drone in vter(OtherShipManager.spaceDrones) do
        drone.ionStun = drone.ionStun + Hyperspace.FPS.SpeedFactor / 16
      end
    end
  end
end)

-- lich's shield resist (me)

script.on_internal_event(Defines.InternalEvents.SHIELD_COLLISION_PRE, function(ShipManager, Projectile, Damage, CollisionResponse)
  local shieldPower = ShipManager:GetShieldPower()
  if ShipManager:HasEquipment("FR_LICHS_SHIELDS") > 0 and shieldPower.super.first > 0 and Damage.iDamage > 0 and math.random(1, 100) <= 85 then
    Damage.iDamage = 0 
    CollisionResponse.superDamage = 0 
    CollisionResponse.damage = 2147483647
    if Projectile:GetType() ~= 5 then
      Projectile:Kill()
    end
  end
  return Defines.Chain.CONTINUE
end)

-- queen's shield (me)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  local shieldPower = ShipManager:GetShieldPower()
  if ShipManager:HasEquipment("FR_QUEENS_AEGIS") > 0 and shieldPower.super.first > 0 then
    ShipManager:ClearStatusAll()
  end
  return Defines.Chain.CONTINUE
end)


