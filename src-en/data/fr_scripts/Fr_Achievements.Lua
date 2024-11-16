local vter = mods.fusion.vter

local function string_starts(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

local function should_track_achievement(achievement, ship, shipClassName)
    return ship and
           Hyperspace.Global.GetInstance():GetCApp().world.bStartedGame and
           Hyperspace.CustomAchievementTracker.instance:GetAchievementStatus(achievement) < Hyperspace.Settings.difficulty and
           string_starts(ship.myBlueprint.blueprintName, shipClassName)
end

local function current_sector()
    return Hyperspace.Global.GetInstance():GetCApp().world.starMap.worldLevel + 1
end


--achiivo 1 (by me, arc and julk)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  if ShipManager:HasAugmentation("FR_SHIP_COMMONWEALTH") > 0 and ShipManager:GetWeaponList():size() >= 3  then 
    local hasFullIon = true
    for weapon in vter(ShipManager:GetWeaponList()) do
      if  weapon.blueprint.damage.iIonDamage < 1 then
        hasFullIon = false
      end
    end
    if hasFullIon then
      Hyperspace.CustomAchievementTracker.instance:SetAchievement("ACH_SHIP_FR_COMMONWEALTH_1", false)
    end
  end
end)


--achiivo 2 (by me, arc and julk)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  if ShipManager:HasAugmentation("FR_SHIP_COMMONWEALTH") > 0 then 
    local hasrightweaponlevels = true
    if ShipManager:GetSystem(3).powerState.second > ShipManager.myBlueprint.systemInfo[3].powerLevel then
      hasrightweaponlevels = false
    end
    if hasrightweaponlevels and ShipManager:GetSystem(11).powerState.second == 5 then
      Hyperspace.CustomAchievementTracker.instance:SetAchievement("ACH_SHIP_FR_COMMONWEALTH_2", false)
    end
  end
end)

--achiivo 3 (by me, arc and julk)

script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(ShipManager)
  if ShipManager:HasAugmentation("FR_SHIP_COMMONWEALTH") > 0 then 
    local hashighIon = false
    for weapon in vter(ShipManager:GetWeaponList()) do
      if weapon.blueprint.damage.iIonDamage  >= 5 then
        hashighIon = true
      end
    end
    if hashighIon then
      Hyperspace.CustomAchievementTracker.instance:SetAchievement("ACH_SHIP_FR_COMMONWEALTH_3", false)
    end
  end
end)