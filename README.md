# Forts - Energy Shield Door

A small **Forts** material mod that combines the vanilla **Energy Shield** with the automatic opening behaviour of the vanilla **Door**.

## What it does

The mod adds a new material with the internal name `energydoor`.

- Reflects laser beams like an Energy Shield.
- Keeps the Energy Shield's projectile interaction, HP, costs and energy drain.
- Opens automatically when a weapon behind it needs to fire.
- Closes again using the normal Forts door logic.
- Uses only vanilla Forts sprites/effects; no game assets are redistributed.
- Tracks later changes to the vanilla shield through `RegisterApplyMod`.

The implementation intentionally reuses Forts' native door system instead of scripting projectile detection manually. This should make it much safer for multiplayer/replays than a custom open/close state machine.

## Installation for local testing

1. Open the Forts installation directory from Steam.
2. Go to:

   `Forts/data/mods/`

3. Clone/copy this repository into a folder there, for example:

   `Forts/data/mods/energy-shield-door/`

4. Launch Forts.
5. Start Sandbox/Skirmish and enable the mod under the **Materials** category.
6. Build normal bracing, then use the material conversion menu to convert it to `energydoor`.

## Expected behaviour

Place a weapon behind the Energy Door and aim through it.

- While closed, laser/beam attacks should be reflected using the same material properties as the vanilla shield.
- When the weapon behind it is aimed/fired through the link, Forts should treat the material as a door and open it automatically.
- After firing, Forts' normal door logic should close it again.

## Current visual approach

The material uses the normal door rail/cap sprites and the Energy Shield sprite as the moving foreground leaf. This is intentional for version 0.1: it lets us validate gameplay before adding custom textures.

## Balance

Version 0.1 inherits the **current vanilla Energy Shield** values at load time, including:

- hit points;
- metal/energy build and repair costs;
- continuous energy consumption;
- projectile deflection properties;
- beam reflection;
- shield disable/warm-up effects.

Door opening/closing speed is inherited from the current vanilla Door.

## Technical notes

Forts loads `materials/building_materials.lua` from active mods on top of the base material database. This mod clones the vanilla shield into a new entry, adds `IsDoor = true`, then copies the native door-specific properties.

A final `RegisterApplyMod` pass refreshes the material after other mods/commanders have applied their changes.

## Compatibility

No Moonshot-only keyword is required by the implementation. The mod is designed around base-game `shield` and `door` materials.

The first version still needs an in-game validation pass because Forts itself is not available in the GitHub execution environment. If the moving shield sprite needs different offsets/caps, those are isolated to the visual fields in `ApplyDoorBehaviour`.

## References

- EarthWork Games official Forts modding guide: materials are configured in `materials/building_materials.lua`, mods layer changes over the base data, and `RegisterApplyMod` runs after active mods have been applied.
- Forts material configuration exposes `IsDoor`, `DoorSpeed`, `DoorSpeedClose`, `SpriteDoor`, collision flags and `ReflectsBeams`.
