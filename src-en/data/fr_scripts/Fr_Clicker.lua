local userdata_table = mods.multiverse.userdata_table

-- Find ID of a room at the given location
local function get_room_at_location(shipManager, location, includeWalls)
    return Hyperspace.ShipGraph.GetShipInfo(shipManager.iShipId):GetSelectedRoom(location.x, location.y, includeWalls)
end

-- written by kokoro
local function convertMousePositionToEnemyShipPosition(mousePosition)
    local cApp = Hyperspace.Global.GetInstance():GetCApp()
    local combatControl = cApp.gui.combatControl
    local position = combatControl.position
    local targetPosition = combatControl.targetPosition
    local enemyShipOriginX = position.x + targetPosition.x
    local enemyShipOriginY = position.y + targetPosition.y
    return Hyperspace.Point(mousePosition.x - enemyShipOriginX, mousePosition.y - enemyShipOriginY)
end

local function convertMousePositionToPlayerShipPosition(mousePosition)
    local cApp = Hyperspace.Global.GetInstance():GetCApp()
    local combatControl = cApp.gui.combatControl
    local playerPosition = combatControl.playerShipPosition
    return Hyperspace.Point(mousePosition.x - playerPosition.x, mousePosition.y - playerPosition.y)
end

local function global_pos_to_player_pos(mousePosition)
    local cApp = Hyperspace.Global.GetInstance():GetCApp()
    local combatControl = cApp.gui.combatControl
    local playerPosition = combatControl.playerShipPosition
    return Hyperspace.Point(mousePosition.x - playerPosition.x, mousePosition.y - playerPosition.y)
end

-- Returns a table where the indices are the IDs of all rooms adjacent to the given room
-- and the values are the rooms' coordinates
local function get_adjacent_rooms(shipId, roomId, diagonals)
    local shipGraph = Hyperspace.ShipGraph.GetShipInfo(shipId)
    local roomShape = shipGraph:GetRoomShape(roomId)
    local adjacentRooms = {}
    local currentRoom = nil
    local function check_for_room(x, y)
        currentRoom = shipGraph:GetSelectedRoom(x, y, false)
        if currentRoom > -1 and not adjacentRooms[currentRoom] then
            adjacentRooms[currentRoom] = Hyperspace.Pointf(x, y)
        end
    end
    for offset = 0, roomShape.w - 35, 35 do
        check_for_room(roomShape.x + offset + 17, roomShape.y - 17)
        check_for_room(roomShape.x + offset + 17, roomShape.y + roomShape.h + 17)
    end
    for offset = 0, roomShape.h - 35, 35 do
        check_for_room(roomShape.x - 17, roomShape.y + offset + 17)
        check_for_room(roomShape.x + roomShape.w + 17, roomShape.y + offset + 17)
    end
    if diagonals then
        check_for_room(roomShape.x - 17, roomShape.y - 17)
        check_for_room(roomShape.x + roomShape.w + 17, roomShape.y - 17)
        check_for_room(roomShape.x + roomShape.w + 17, roomShape.y + roomShape.h + 17)
        check_for_room(roomShape.x - 17, roomShape.y + roomShape.h + 17)
    end
    return adjacentRooms
end


--[[
local function vter(cvec)
    local i = -1
    local n = cvec:size()
    return function()
        i = i + 1
        if i < n then return cvec[i] end
    end
end
--]]



local vter = mods.multiverse.vter

local herCursorSpawnPath = "hc_spawn_"
local herCursorSpawnNumber = 7

local sfxPlayed = false
local loadComplete = {}
loadComplete[0] = false
loadComplete[1] = false

--Handles tooltips and mousever descriptions per level
local function get_level_description_fr_clicker(systemId, level, tooltip)
    if systemId == Hyperspace.ShipSystem.NameToSystemId("fr_clicker") then
                if tooltip then
            if level == 0 then
                return Hyperspace.Text:GetText("tooltip_fr_clicker_disabled")
            end
            return string.format(Hyperspace.Text:GetText("tooltip_fr_clicker_level"), tostring(level < 3 and level or level - 1), tostring(math.min(level + 2, 5)))
        end
        return string.format(Hyperspace.Text:GetText("tooltip_fr_clicker_level"), tostring(level < 3 and level or level - 1), tostring(math.min(level + 2, 5)))
    end
end

script.on_internal_event(Defines.InternalEvents.GET_LEVEL_DESCRIPTION, get_level_description_fr_clicker)

--Utility function to check if the SystemBox instance is for our customs system
local function is_fr_clicker(systemBox)
    local systemName = Hyperspace.ShipSystem.SystemIdToName(systemBox.pSystem.iSystemType)
    return systemName == "fr_clicker" and systemBox.bPlayerUI
end

--Utility function to check if the SystemBox instance is for our customs system
local function is_fr_clicker_enemy(systemBox)
    local systemName = Hyperspace.ShipSystem.SystemIdToName(systemBox.pSystem.iSystemType)
    return systemName == "fr_clicker" and not systemBox.bPlayerUI
end


local fr_clickerButtonOffset_x = 37--35
local fr_clickerButtonOffset_y = -50---40
--Handles initialization of custom system box
local function fr_clicker_construct_system_box(systemBox)
    if is_fr_clicker(systemBox) then
        systemBox.extend.xOffset = 54
        local activateButton = Hyperspace.Button()
        activateButton:OnInit("systemUI/button_cloaking1",
            Hyperspace.Point(fr_clickerButtonOffset_x, fr_clickerButtonOffset_y))
        activateButton.hitbox.x = 10--11
        activateButton.hitbox.y = 47--36
        activateButton.hitbox.w = 20--20
        activateButton.hitbox.h = 19--30
        systemBox.table.activateButton = activateButton
    end
end

script.on_internal_event(Defines.InternalEvents.CONSTRUCT_SYSTEM_BOX, fr_clicker_construct_system_box)

--Handles mouse movement
local function fr_clicker_mouse_move(systemBox, x, y)
    if is_fr_clicker(systemBox) then
        local activateButton = systemBox.table.activateButton
        activateButton:MouseMove(x - fr_clickerButtonOffset_x, y - fr_clickerButtonOffset_y, false)
    end
    return Defines.Chain.CONTINUE
end
script.on_internal_event(Defines.InternalEvents.SYSTEM_BOX_MOUSE_MOVE, fr_clicker_mouse_move)

local function fr_clicker_click(systemBox, shift)
    if is_fr_clicker(systemBox) then
        local activateButton = systemBox.table.activateButton
        if activateButton.bHover and activateButton.bActive then
            local shipManager = Hyperspace.ships.player
            local fr_clicker_system = shipManager:GetSystem(Hyperspace.ShipSystem.NameToSystemId(
            "fr_clicker"))
            userdata_table(shipManager, "mods.fr.clicker").clickmode = true
            local sys = Hyperspace.ships.player:GetSystem(Hyperspace.ShipSystem.NameToSystemId("fr_clicker"))
            local level = sys and sys:GetEffectivePower() or 0
            userdata_table(shipManager, "mods.fr.clicker").clickcount = math.min(level + 2, 5)
            Hyperspace.Sounds:PlaySoundMix(herCursorSpawnPath .. tostring(math.random(1, herCursorSpawnNumber)), -1, false)
        end
    end
    return Defines.Chain.CONTINUE
end
script.on_internal_event(Defines.InternalEvents.SYSTEM_BOX_MOUSE_CLICK, fr_clicker_click)


local lastKeyDown = nil


script.on_internal_event(Defines.InternalEvents.SYSTEM_BOX_KEY_DOWN, function(systemBox, key, shift)
    if Hyperspace.metaVariables.fr_clicker_hotkey_enabled == 0 and ((not lastKeyDown) or lastKeyDown ~= key) and is_fr_clicker(systemBox) then
        lastKeyDown = key
        --print("press key:"..key.." shift:"..tostring(shift))
        local shipManager = Hyperspace.ships.player
        if not Hyperspace.ships.player:HasSystem(Hyperspace.ShipSystem.NameToSystemId("fr_clicker")) then return end
    end
end)

script.on_internal_event(Defines.InternalEvents.ON_KEY_UP, function(key)
    lastKeyDown = nil
end)


---Utility function to see if the system is ready for use
---@param shipSystem Hyperspace.ShipSystem
---@return boolean
local function fr_clicker_ready(shipSystem)
    if not shipSystem then return false end
    local shipManager = Hyperspace.ships.player
    if not shipManager or userdata_table(shipManager, "mods.fr.clicker").clickmode then return false end
    return not shipSystem:GetLocked() and shipSystem:Functioning() and shipSystem.iHackEffect <= 1
end

local buttonBase
local buttonCharging
local numberPrimitives = {}
script.on_init(function()
    buttonBase = Hyperspace.Resources:CreateImagePrimitiveString("systemUI/button_cloaking1_base.png",
    fr_clickerButtonOffset_x, fr_clickerButtonOffset_y, 0, Graphics.GL_Color(1, 1, 1, 1), 1, false)
    buttonCharging = Hyperspace.Resources:CreateImagePrimitiveString("systemUI/button_cloaking1_charging_on.png",
        fr_clickerButtonOffset_x, fr_clickerButtonOffset_y, 0, Graphics.GL_Color(1, 1, 1, 1), 1,
        false)

    local i = 0
    while i <= 9 do
        numberPrimitives[i] = Hyperspace.Resources:CreateImagePrimitiveString(
        "systemUI/fr_clicker_button_number" .. i .. ".png", fr_clickerButtonOffset_x, fr_clickerButtonOffset_y, 0, Graphics.GL_Color(1, 1, 1, 1), 1, false)
        i = i + 1
    end

    for i = 0, 1, 1 do
        loadComplete[i] = false
        --print("L:", i, Hyperspace.metaVariables["mods_fr_clicker_" .. i])
        --print("mods_fr_clicker_" .. i)
    end
    --print("Loaded:", loadValues[0])

end)

--Handles custom rendering
local function fr_clicker_render(systemBox, ignoreStatus)
    if is_fr_clicker(systemBox) then
        local activateButton = systemBox.table.activateButton
        local shipManager = Hyperspace.ships.player
        local fr_clicker_system = shipManager:GetSystem(Hyperspace.ShipSystem.NameToSystemId("fr_clicker"))
        activateButton.bActive = fr_clicker_ready(fr_clicker_system)

        if activateButton.bHover then
            if not activateButton.bActive and not userdata_table(shipManager, "mods.fr.clicker").clickmode then
                Hyperspace.Mouse.tooltip = Hyperspace.Text:GetText("tooltip_fr_clicker_level_notready")
                Hyperspace.Mouse.bForceTooltip = true
            end
        end
        Graphics.CSurface.GL_RenderPrimitive(buttonBase)
        if userdata_table(shipManager, "mods.fr.clicker").clickmode then
            --local height = math.ceil(activationTimer[0] * 31)
            --[[Graphics.CSurface.GL_BlitImagePartial(buttonChargingTex, fr_clickerButtonOffset_x,
                fr_clickerButtonOffset_y, 20, 31, fr_clickerButtonOffset_x,
                fr_clickerButtonOffset_x + 20, fr_clickerButtonOffset_y + height,
                fr_clickerButtonOffset_y + 31, 1, Graphics.GL_Color(1, 1, 1, 1), false)--]]
            ---@diagnostic disable-next-line: param-type-mismatch
            --Graphics.CSurface.GL_SetStencilMode(Graphics.STENCIL_SET, 1, 1)
            --Graphics.CSurface.GL_DrawRect(fr_clickerButtonOffset_x + 10, --+10
            --    fr_clickerButtonOffset_y - height + 67, --+67
            --    20,
            --    height,
            --    Graphics.GL_Color(1, 1, 1, 1))
            ---@diagnostic disable-next-line: param-type-mismatch
            --Graphics.CSurface.GL_SetStencilMode(Graphics.STENCIL_USE, 1, 1)
            --Graphics.CSurface.GL_RenderPrimitive(buttonCharging)
            ---@diagnostic disable-next-line: param-type-mismatch
            --Graphics.CSurface.GL_SetStencilMode(Graphics.STENCIL_IGNORE, 1, 1)

            local num = userdata_table(shipManager, "mods.fr.clicker").clickcount or 0
            num = num % 10
            Graphics.CSurface.GL_RenderPrimitive(numberPrimitives[num])

        else
            systemBox.table.activateButton:OnRender()
        end
    end
end
script.on_render_event(Defines.RenderEvents.SYSTEM_BOX,
    function(systemBox, ignoreStatus)
        return Defines.Chain.CONTINUE
    end, fr_clicker_render)


script.on_internal_event(Defines.InternalEvents.JUMP_ARRIVE, function(shipManager)
    userdata_table(shipManager, "mods.fr.clicker").clickmode = false
    userdata_table(shipManager, "mods.fr.clicker").clickcount = 0
end)

local playerCursorRestore
local playerCursorRestoreInvalid

script.on_internal_event(Defines.InternalEvents.ON_TICK, function()
    local commandGui = Hyperspace.App.gui
    local shipManager = Hyperspace.ships.player


    if shipManager and userdata_table(shipManager, "mods.fr.clicker").clickmode then

        if not playerCursorRestore then
            playerCursorRestore = Hyperspace.Mouse.validPointer
            playerCursorRestoreInvalid = Hyperspace.Mouse.invalidPointer
        end
        Hyperspace.Mouse.validPointer = Hyperspace.Resources:GetImageId("mouse/pointer_her_1.png")
        Hyperspace.Mouse.invalidPointer = Hyperspace.Resources:GetImageId("mouse/pointer_her_1.png")
    elseif playerCursorRestore then
        Hyperspace.Mouse.validPointer = playerCursorRestore
        Hyperspace.Mouse.invalidPointer = playerCursorRestoreInvalid
        playerCursorRestore = nil
        playerCursorRestoreInvalid = nil
    end
end)

script.on_render_event(Defines.RenderEvents.MOUSE_CONTROL, function()
    local commandGui = Hyperspace.App.gui
    local shipManager = Hyperspace.ships.player

    if shipManager and userdata_table(shipManager, "mods.fr.clicker").clickmode and (Hyperspace.metaVariables.fr_clicker_pause_enabled or not commandGui.bPaused) and not (commandGui.event_pause or commandGui.menu_pause) then
        local mousePos = Hyperspace.Mouse.position
        local mousePosLocal = convertMousePositionToEnemyShipPosition(mousePos)
        local shipAtMouse = 1
        local roomAtMouse = -1
        --print("MOUSE POS X:"..mousePos.x.." Y:"..mousePos.y.." LOCAL X:"..mousePosLocal.x.." Y:"..mousePosLocal.y)
        roomAtMouse = get_room_at_location(Hyperspace.ships.enemy, mousePosLocal, true)

        Hyperspace.Mouse.valid = shipAtMouse == 0 and roomAtMouse > -1
        --print(shipAtMouse .. " " .. roomAtMouse)
        --print(Hyperspace.playerVariables.lily_beam_active == 1 .. " " .. Hyperspace.playerVariables.lily_ion_active == 1)
        --print("Count: " .. count)
        --print(roomAtMouse)
        if shipAtMouse == 1 and roomAtMouse > -1 then

            local cApp = Hyperspace.Global.GetInstance():GetCApp()
            local combatControl = cApp.gui.combatControl
            local playerPosition = combatControl.playerShipPosition
            Hyperspace.ships.enemy.ship:SetSelectedRoom(roomAtMouse)
            --[[local roomc = shipManager:GetRoomCenter(roomAtMouse)
            Graphics.CSurface.GL_PushMatrix()
            Graphics.CSurface.GL_Translate(playerPosition.x, playerPosition.y, 0)
            Graphics.CSurface.GL_Translate(roomc.x, roomc.y, 0)
            Graphics.CSurface.GL_RenderPrimitive(crosshair)
            Graphics.CSurface.GL_PopMatrix()--]]

        end
    end
end, function() end)

---Click on a room to select it
---@param shipManager Hyperspace.ShipManager
---@param roomId integer
---@param ionAmount integer
local function selectRoom(shipManager, roomId, ionAmount)
    --print("called", roomId, shipManager.ship.vRoomList:size())
    if roomId == -1 or roomId >= shipManager.ship.vRoomList:size() then
        --userdata_table(shipManager, "mods.fr.clicker").targetroom = nil
        --userdata_table(shipManager, "mods.fr.clicker").clickmode = false
    else
        --print("roomok")
        local clickcount = userdata_table(Hyperspace.ships.player, "mods.fr.clicker").clickcount or 0
        if clickcount > 0 then
            --print("countok")
            local sys = shipManager:GetSystemInRoom(roomId)
            if sys then
                sys:IonDamage(ionAmount)
            end
            userdata_table(Hyperspace.ships.player, "mods.fr.clicker").clickcount = clickcount - 1
        end
    end
end


script.on_internal_event(Defines.InternalEvents.ON_MOUSE_L_BUTTON_DOWN, function(x, y)
    local commandGui = Hyperspace.App.gui
    local shipManager = Hyperspace.ships.player

    if shipManager and userdata_table(shipManager, "mods.fr.clicker").clickmode and (Hyperspace.metaVariables.fr_clicker_pause_enabled or not commandGui.bPaused) and not (commandGui.event_pause or commandGui.menu_pause) then
        local mousePos = Hyperspace.Mouse.position
        local mousePosLocal = convertMousePositionToEnemyShipPosition(mousePos)
        local shipAtMouse = 1
        local roomAtMouse = -1
        --print("MOUSE POS X:"..mousePos.x.." Y:"..mousePos.y.." LOCAL X:"..mousePosLocal.x.." Y:"..mousePosLocal.y)

        roomAtMouse = get_room_at_location(Hyperspace.ships.enemy, mousePosLocal, true)

        local sys = shipManager:GetSystem(Hyperspace.ShipSystem.NameToSystemId("fr_clicker"))
        local level = sys and sys:GetEffectivePower() or 0

        --print(shipAtMouse .. " " .. roomAtMouse)
        --print(Hyperspace.playerVariables.lily_beam_active == 1 .. " " .. Hyperspace.playerVariables.lily_ion_active == 1)
        --print("Count: " .. count)
        if shipAtMouse == 1 and roomAtMouse > -1 then
            --print("Clicked: ", roomAtMouse)
            selectRoom(Hyperspace.ships.enemy, roomAtMouse, level < 3 and level or level - 1)
            Hyperspace.Sounds:PlaySoundMix("ionHit" .. math.random(3), -1, false)
            if (userdata_table(shipManager, "mods.fr.clicker").clickcount or 0) <= 0 and userdata_table(shipManager, "mods.fr.clicker").clickmode then
                userdata_table(shipManager, "mods.fr.clicker").clickmode = false
                userdata_table(shipManager, "mods.fr.clicker").clickcount = 0
                if sys then
                    if sys:GetLocked() then
                        sys:AddLock(5)
                    else
                        sys:LockSystem(5)
                    end
                end
            end
        end
    end
    return Defines.Chain.CONTINUE
end)


script.on_internal_event(Defines.InternalEvents.SHIP_LOOP, function(shipManager)
    if shipManager:HasSystem(Hyperspace.ShipSystem.NameToSystemId("fr_clicker")) then
        local fr_clicker_system = shipManager:GetSystem(Hyperspace.ShipSystem.NameToSystemId(
        "fr_clicker"))

        if ((userdata_table(shipManager, "mods.fr.clicker").clickcount or 0) <= 0 or not fr_clicker_system:Functioning()) and userdata_table(shipManager, "mods.fr.clicker").clickmode then
            userdata_table(shipManager, "mods.fr.clicker").clickmode = false
            userdata_table(shipManager, "mods.fr.clicker").clickcount = 0
            if fr_clicker_system:GetLocked() then
                fr_clicker_system:AddLock(5)
            else
                fr_clicker_system:LockSystem(5)
            end
        end

        fr_clicker_system.bBoostable = false
        local level = fr_clicker_system.healthState.second
        local efflevel = fr_clicker_system:GetEffectivePower()

        if shipManager.iShipId == 0 then
            Hyperspace.playerVariables.fr_clicker = level
        end


        if Hyperspace.playerVariables["stability"] > 0 and not loadComplete[shipManager.iShipId] then
            local v = Hyperspace.playerVariables
            ["mods_fr_clicker_" .. (shipManager.iShipId > 0.5 and "1" or "0")]
            if v > 0 then
                userdata_table(shipManager, "mods.fr.clicker").clickmode = true
                userdata_table(shipManager, "mods.fr.clicker").clickcount = v - 1
            else
                userdata_table(shipManager, "mods.fr.clicker").clickmode = false
                userdata_table(shipManager, "mods.fr.clicker").clickcount = 0
            end
            loadComplete[shipManager.iShipId] = true
        end


        if Hyperspace.playerVariables["stability"] > 0 and loadComplete[shipManager.iShipId] then
            if not userdata_table(shipManager, "mods.fr.clicker").clickmode then
                Hyperspace.playerVariables["mods_fr_clicker_" .. (shipManager.iShipId > 0.5 and "1" or "0")] = 0
            else
                local count = userdata_table(shipManager, "mods.fr.clicker").clickcount or 0
                Hyperspace.playerVariables["mods_fr_clicker_" .. (shipManager.iShipId > 0.5 and "1" or "0")] = count + 1
            end
        end


        --print(targetroom, Hyperspace.metaVariables["mods_fr_clicker_" .. shipManager.iShipId])
        --print("mods_fr_clicker_" .. shipManager.iShipId)
    elseif shipManager.iShipId == 0 then
        Hyperspace.playerVariables.fr_clicker = 0
    end
end)





mods.multiverse.systemIcons[Hyperspace.ShipSystem.NameToSystemId("fr_clicker")] = mods.multiverse
    .register_system_icon("fr_clicker")



script.on_internal_event(Defines.InternalEvents.CONSTRUCT_SHIP_SYSTEM, function(system)
    if system and system:GetId() == Hyperspace.ShipSystem.NameToSystemId("fr_clicker") then
        system.bBoostable = false
    end
end)

script.on_internal_event(Defines.InternalEvents.JUMP_LEAVE, function(shipManager)
    if shipManager.iShipId == 0 and shipManager:HasSystem(Hyperspace.ShipSystem.NameToSystemId("fr_clicker")) then
        local system = shipManager:GetSystem(Hyperspace.ShipSystem.NameToSystemId("fr_clicker"))
        local gui = Hyperspace.App.gui
        if system:GetLocked() and (gui.upgradeButton.bActive and not gui.event_pause) then
            system:LockSystem(0)
        end
    end
end)