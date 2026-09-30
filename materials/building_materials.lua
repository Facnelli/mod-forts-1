-- Energy Shield Door
-- Creates a new material by combining the defensive behaviour of the
-- vanilla Energy Shield with the automatic opening behaviour of a Door.

local ENERGY_DOOR_SAVE_NAME = "energydoor"

local function FindMaterialBySaveName(saveName)
    for _, material in ipairs(Materials) do
        if material.SaveName == saveName then
            return material
        end
    end

    return nil
end

local function ShallowCopy(source)
    local copy = {}

    for key, value in pairs(source) do
        copy[key] = value
    end

    return copy
end

local function CopyList(source)
    local copy = {}

    if source then
        for index, value in ipairs(source) do
            copy[index] = value
        end
    end

    return copy
end

local function ListContains(list, value)
    if not list then
        return false
    end

    for _, item in ipairs(list) do
        if item == value then
            return true
        end
    end

    return false
end

local function AddEnergyDoorToDefaultConversions()
    if DefaultConversions and not ListContains(DefaultConversions, ENERGY_DOOR_SAVE_NAME) then
        table.insert(DefaultConversions, ENERGY_DOOR_SAVE_NAME)
    end
end

local function ApplyDoorBehaviour(material, door, shield)
    -- Door state/animation. IsDoor is what makes weapons open the link
    -- automatically when their firing arc is blocked by it.
    material.IsDoor = true
    material.DoorSpeed = door.DoorSpeed
    material.DoorSpeedClose = door.DoorSpeedClose
    material.DoorOnClearanceOverlap = door.DoorOnClearanceOverlap
    material.WeaponRecession = door.WeaponRecession

    material.OpenEffect = door.OpenEffect
    material.OpenedEffect = door.OpenedEffect
    material.CloseEffect = door.CloseEffect
    material.ClosedEffect = door.ClosedEffect

    -- Keep the normal door rails/caps, but draw the shield itself as the
    -- moving foreground leaf. This gives an "electric door" appearance
    -- without shipping copied game textures in the mod.
    material.Sprite = door.Sprite
    material.Sprite1 = door.Sprite1
    material.Sprite2 = door.Sprite2
    material.SpriteDoor = shield.Sprite
    material.DoorCap = door.DoorCap
    material.EndCap = door.EndCap
    material.EndLinkOffset = door.EndLinkOffset
    material.EndCapOffset = door.EndCapOffset
    material.RenderOrder = door.RenderOrder

    -- Preserve door-compatible construction behaviour.
    material.RecessionTargetSaveName = door.RecessionTargetSaveName
    material.ForegroundTargetSaveName = door.ForegroundTargetSaveName
    material.ArmorRemovalTargetSaveName = door.ArmorRemovalTargetSaveName
    material.DoorTargetSaveName = ENERGY_DOOR_SAVE_NAME

    material.AttachesCladding = door.AttachesCladding
    material.BackgroundCladding = door.BackgroundCladding

    -- Shield behaviour remains inherited from the vanilla shield.
    -- Explicitly set the important collision flags for clarity and to make
    -- the intended behaviour resilient to unrelated material mods.
    material.ReflectsBeams = true
    material.CollidesWithEnemyProjectiles = shield.CollidesWithEnemyProjectiles
    material.CollidesWithFriendlyProjectiles = shield.CollidesWithFriendlyProjectiles
    material.CollidesWithEnemyBeams = shield.CollidesWithEnemyBeams
    material.CollidesWithFriendlyBeams = shield.CollidesWithFriendlyBeams
    material.CollidesWithWind = shield.CollidesWithWind

    -- Reuse the shield's HUD assets.
    material.Icon = shield.Icon
    material.Detail = shield.Detail
    material.Context = shield.Context
    material.SelectEffect = shield.SelectEffect

    material.Enabled = true
    material.ShowOnHUD = true
    material.ShowInEditor = true
end

local function CreateEnergyDoor()
    local existing = FindMaterialBySaveName(ENERGY_DOOR_SAVE_NAME)
    if existing then
        return existing
    end

    local shield = FindMaterialBySaveName("shield")
    local door = FindMaterialBySaveName("door")

    if not shield or not door then
        return nil
    end

    local energyDoor = ShallowCopy(shield)
    energyDoor.SaveName = ENERGY_DOOR_SAVE_NAME

    -- Do not offer conversion from the new material to itself.
    energyDoor.Conversions = CopyList(DefaultConversions)

    ApplyDoorBehaviour(energyDoor, door, shield)
    table.insert(Materials, energyDoor)
    AddEnergyDoorToDefaultConversions()

    return energyDoor
end

-- Base materials already exist when this file is loaded.
CreateEnergyDoor()

-- Re-apply after every active mod/commander has modified the vanilla
-- materials. This keeps the Energy Door synced with the current shield
-- balance while retaining the normal door mechanics.
RegisterApplyMod(function()
    local energyDoor = FindMaterialBySaveName(ENERGY_DOOR_SAVE_NAME)
    local shield = FindMaterialBySaveName("shield")
    local door = FindMaterialBySaveName("door")

    if not shield or not door then
        return
    end

    if not energyDoor then
        energyDoor = CreateEnergyDoor()
    end

    if not energyDoor then
        return
    end

    -- Refresh all shield stats (HP, costs, energy drain, deflection values,
    -- disable effects, etc.) in case another mod changed the vanilla shield.
    for key, value in pairs(shield) do
        energyDoor[key] = value
    end

    energyDoor.SaveName = ENERGY_DOOR_SAVE_NAME
    energyDoor.Conversions = CopyList(DefaultConversions)

    -- Remove a possible self-conversion introduced by a previous apply pass.
    for index = #energyDoor.Conversions, 1, -1 do
        if energyDoor.Conversions[index] == ENERGY_DOOR_SAVE_NAME then
            table.remove(energyDoor.Conversions, index)
        end
    end

    ApplyDoorBehaviour(energyDoor, door, shield)
    AddEnergyDoorToDefaultConversions()
end)
