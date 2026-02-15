# CameraShaker-optimized
Sleitnick's camerashaker but more optimized and secure. (work in progress for now)

# How to use? 
**For test purposes, it is still in work in progress. It works similarly like RbxCameraShaker, from sleitnick.** 
We know that 
springshaker.new()'s parameters are 
	* Magnitude: number, 
	* Roughness: number, 
	* FadeInTime: number, 
	* FadeOutTime: number, 
    * PosInflux: Vector3,
	* RotInflux: Vector3,
	* __RenderPriority: Enum.RenderPriority,

## TLDR, wise... 
* Magnitude: Master volume for the shake (0 = off, 10 = crazy).
* Roughness: Frequency of the jitters (Low = smooth lukewater, High = earthquake).
* FadeInTime: Seconds to ramp up from 0 to full power.
* PosInflux: How many studs the camera moves on X, Y, Z.
* RotInflux: How many degrees the camera rotates on X, Y, Z.
* FadeOutTime: Seconds to ramp down to 0 after the shake ends.
* RenderPriority: Where in the frame-cycle the code runs (keep it at Camera).


(F.E) 
```lua 
local springshaker = require(...)
local springshaker_test = springshaker.new(4, Vector3.new(4,1,1), Vector3.new(0.25,0.25,0.25),10,0.1,0.75)

springshaker:ShakeOnce(springshaker_test, 2)
```
This code will pull out a small explosion / vibration feeling on your camera.

## For nerds
1. Magnitude (number) (scalable to amplitude)
The scale factor for the entire shake. It acts as a global multiplier for both PosInflux and RotInflux. If you want to make a "Small Explosion" into a "Big Explosion" without changing the axis math, you just double this number.
2. Roughness (number)
Controls the "speed" of the Perlin noise.
3. FadeInTime (number)
The "Attack" of the shake. It defines how many seconds it takes for the shake to transition from a CurrentTime of 0.0 to 1.0.

4. PosInflux (Vector3)
Defines the maximum positional offset (in Studs) the camera can move on the X, Y, and Z axes.

5. RotInflux (Vector3)
Defines the maximum rotational offset (in Degrees) the camera can tilt.
    X: Pitch (looking up/down)
    Y: Yaw (looking left/right)
    Z: Roll (tilting side to side)
   
7. FadeOutTime (number)
The "Release" of the shake. When the shake is told to stop (or its duration ends), it will take this many seconds to smoothly return the camera to its original position. This prevents the camera from "snapping" back instantly, which causes motion sickness.
8. __RenderPriority (Enum.RenderPriority)
Determines when the CFrame is applied during the RunService cycle. By default, this is set to Camera, ensuring the shake is applied after the game's default camera scripts but before the frame is rendered to the screen.

## Small notes (FOR BEGINNERS!)
**This module cannot be used on SERVER. Therefore, you either run this by using [Remotes](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent), if you want to connect it to CLIENTS.**
