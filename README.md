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
| `Tension` | number | A restoring force, of how much the camera needs to return to its position. **(XYZ): (0,0,0)** |
| `Velocity` | number | The speed of the camera in which it's moving in miliseconds | 
| `Damping` | number | The resistor of stopping the camera to shake forever. |
| `RotationInfluence` | Vector3 | It is a pin-point translator (1D) to (3D), which by per-axis, allows you to constrain the spring mathematics to edit at what direction you would like it to shake. | 
| `__RenderPriority` | Enum.RenderPriority | Determines when and at what frame should the shake be allowed. By default, the code will set it to 201. |

**<code>⚠ NOTE</code>**: Magnitude cannot overpass more than (10^5), a natural resemblance in Physics happens, called [Resonance](https://en.wikipedia.org/wiki/Resonance). It is due to F(t), frequency of the
force, matches the S(t) natural frequency of the spring, thus turning into mathematics an impossible to detect, unregistered number, in which the engine cannot properly render.

**<code>⚠ NOTE</code>**: **This module cannot be used on SERVER. Therefore, you either run this by using [Remotes](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent), _if you want to connect it to CLIENTS._**

# Example
```lua 
local springshaker = require(...)
local springshaker_test = springshakernew({
	Magnitude = 7,
	Roughness =25,
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

## Desmos testing
[Desmos Link](https://www.desmos.com/calculator/r8iharhx3y)

## Small notes (FOR BEGINNERS!)
**This module cannot be used on SERVER. Therefore, you either run this by using [Remotes](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent), if you want to connect it to CLIENTS.**
