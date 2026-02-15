# CameraShaker-optimized
A CameraShaker inspired by the ideas of @Sleitnick's RbxCameraShaker, but uses more advanced physics and more stability factors.

# How to use? 
**A very easy module, that includes a variety of options to choose from.** 
We know that 
springshaker.new()'s parameters are 

| Parameter | Type | Description
| --- | --- | --- |
| `Magnitude` | number | Scale factor of the entire shake. Measured as Ampltiude. |
| `Roughness` | number | Speed of the perlin noise and spring |
| `FadeInTime` | number | Defines how many seconds it takes for the spring shake to transition from a CurrentTime (ranging 0.0 -> 1.0) |
| `FadeOutTime` | number | Defines how many seconds it would take for the spring to 'calm down' (Connected to E(t)) |
| `Tension` | number | A restoring force, of how much the camera needs to return to its position. **(XYZ): (0,0,0)** |
| `Velocity` | Vector3 | The speed of the camera in which it's moving in miliseconds | 
| `Damping` | number | The resistor of stopping the camera to shake forever. |
| `RotationInfluence` | Vector3 | It is a pin-point translator (1D) to (3D), which by per-axis, allows you to constrain the spring mathematics to edit at what direction you would like it to shake. | 
| `__RenderPriority` | Enum.RenderPriority | Determines when and at what frame should the shake be allowed. By default, the code will set it to 201. |

* **<code>⚠ NOTE</code>**: Magnitude cannot overpass more than (10^5), a natural resemblance in Physics happens, called [Resonance](https://en.wikipedia.org/wiki/Resonance). It is due to F(t), frequency of the
force, matches the S(t) natural frequency of the spring, thus turning into mathematics an impossible to detect, unregistered number, in which the engine cannot properly render.
* **<code>⚠ NOTE</code>**: **This module cannot be used on SERVER. Therefore, you either run this by using [Remotes](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent), _if you want to connect it to CLIENTS._**

# Example
```lua 
local springshaker = require(...)
local springshaker_test = springshakernew({
	Magnitude = 7,
	Roughness = 25,
	FadeInTime = 0.1,
	Tension = 150,
	Damping = 11,
	Velocity = nil,
	FadeOutTime = 0.75,
	RotationInfluence = Vector3.new(4,2,1),
})

springshaker:ShakeOnce(springshaker_test, 2)
```
This code will pull out a small explosion / vibration feeling on your camera for around two seconds. 

# Modules & Libraries used 
[Janitor v1.17.0](https://github.com/howmanysmall/Janitor/tree/main) by @howmanysmall

# Benchmarking & Testing
For intuitive research, here's the graph, accumulated by me: [Desmos Demonstration](https://www.desmos.com/calculator/r8iharhx3y)

# API 
## springshaker.lua
### CONSTRUCTOR (SpringShaker)
| Enums | Returns | Description |
| --- | --- | --- |
| `__PresetMap` | {...} | Returns the array of Presets, which can be used on the function of :GetPreset() |

| Types | Inhibits | Description | 
| --- | --- | --- |
| __SpringShakerClassDef | `SpringShakerPresets & BuiltIn.__camShakePreset` | A data map array that contains valid information points which inhibits private links and data structure. |

**__SpringShakerClassDef**
| Value | Type | Pointers | Returns | Content |
| --- | --- | --- | --- |
| __index | Metadata (function) | `self, __indexmap: string` | () -> () | A linked data map that shows overall infastructural data of the class | 
| Active | Variable (boolean) | `null` | `null` | A boolean that verifies whether if the class is currently active. (:GetState() effects) |
| Magnitude | Constant (number) | `null` | `null` | Scale factor of the entire shake. Measured as Ampltiude | 
| Roughness | Constant (number) | `null` | `null` | Speed of the perlin noise and spring |
| FadeInTime | number | `null` | `null` | Defines how many seconds it takes for the spring shake to transition from a CurrentTime (ranging 0.0 -> 1.0) | 
| FadeOutTime | number | `null` | `null` | Defines how many seconds it would take for the spring to 'calm down' (Connected to E(t)) |
| Tension | number | `null` | `null`| A restoring force, of how much the camera needs to return to its position. **(XYZ): (0,0,0)** |
| Damping or Damper | number | `null` | `null` | The resistor of stopping the camera to shake forever. |
| Velocity | Vector3 | `null` | `null` | The speed of the camera in which it's moving in miliseconds |
| __RenderName | string | `null` | `null` | For BindToRenderStep(), this is unique coding. If you want a custom RenderName, you can input it here. On default, it uses GUID. | 
| __RenderPriority | Enum.RenderPriority | `null` | `null` | Determines when and at what frame should the shake be allowed. By default, the code will set it to 201. |
| RotationalInfluence | Vector3 | `null` | `null` | It is a pin-point translator (1D) to (3D), which by per-axis, allows you to constrain the spring mathematics to edit at what direction you would like it to shake. | 


| Functions | Parameters | Returns | Description | Recommended to run? |
| --- | --- | --- | --- | --- |
| .new() | `BuiltIn._camShakePreset` | `__SpringShakerClassDef` | Builds a new constructor class and returns a valid mathematical table, that can be used by general functions ahead.| **Yes (if not using :GetPreset()** |
| :GetPreset() | `PresetName: string` | `__SpringShakerClassDef` | Returns a preset found from the preset table. You can use this preset for general functions, without building the new constructor class.| **Yes (if not using .new())** |
| :Start() | `__SpringShakerClassDef` | `null` | A function that starts the method to update the camera rendering, and management of renovating it. | **No** |
| :Halt() | `__SpringShakerClassDef` | `null` | Forces a specific shaker class to stop functioning, but does not delete it. | **Optional** |
| :HaltAll() | FadeOutTime: number | `null` | Forces every single shaker class to stop functioning, but does not delete it. | **Optional** |
| :RecycleAll() | No parameters. | `null` | Garbage cleans every single shaker class and empties memory | **Optional** |
| :HaltDurationWise() | Time: number | `null` | Optional fadeout duration for overriding. | **Optional. Recommended for :Shake()** |
| :UpdateAll() | dx: number | `CFrame` | Internal core loop that calculates every single combined CFrame of active springs. | **No** | 
| :Recycle() | `__SpringShakerClass` | `null` | Garbage cleans a specific shaker class and empties memory hash of it | **Optional** |
| :Append() |`__SpringShakerClass` | `null`| Adds a specific shaker class for the overall memory. | **No** | 
| :ShakeSustained() | `__SpringShakerClassDef` | () -> CFrame | Starts a shake that lasts until manually stopped | **Yes, after you run .new() or :GetPreset()** |
| :ShakeOnce() | `__SpringShakeClassDef, Duration: number` | `null` | Plays a shake once, for unhandled situations. | **Yes, after you run .new() or :GetPreset()** |

## shakerinstances.lua 
### COSNTRUCTOR (ShakerInstances) 
### Not recommended or required to run. This module is the **backbone** of springshaker.lua.

| Functions | Parameters | Description |
| --- | --- | --- |
| `.new()` | __SpringShakerDefClass | Inherits the same __SpringShakerClassDef as its table, but more modified and a stable mathematics version. It is then to be given to the main module, for purpose and security. |
| `:Update()` | dx: number | The main handler of the connected springs in general physics and mathematics. | 
| `:FadeOut()` | Time: number | The time to it takes to calm down and return to zero in overall. Direct connection to E(t) frequency. |
| `:FadeIn()` | Time: number | The amount of time it takes to reach the full magnitude (amplitude) of the spring. | 
| `:GetFadeMagnitude()` | `null` | Returns the current multiplier of the shake (0-1). Used to determine the remaining intensity based on FadeIn/FadeOut progress. |
| `:IsShaking()` | `null` | Logic gate that contains if the Spring is in 'Shaking' state |
| `:IsFading()` | `null` | Logic gate that tells if the spring is currently 'fading in'| 
| `:IsFadingOut()` | `null` | Logic gate that tells if the spring is currently 'fading out'. Reverse of :IsFading() | 
| `:IsDead()` | `null` | Logic gate that returns whether if the selected spring shaker class is dead in instance |
| `:GetState()` | `null` | Returns integer values that are designated to 'Inactive', 'Active' and etc. |



