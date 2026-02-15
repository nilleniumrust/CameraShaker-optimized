--!strict
--!native

local BuiltIn = {}

export type  __camShakePreset = {
	Magnitude: number, 
	Roughness: number, 
	FadeInTime: number, 
	Tension: number, 
	Damping: number, 
	Velocity: number,
	FadeOutTime: number, 
	RotationInfluence: Vector3,
	__RenderPriority: Enum.RenderPriority,
}


export type Constants = {
	Magnitude: (number) -> number;
	Roughness: (number) -> number;
	Tension: (number) -> number;
	Damping: (number) -> number;
	Velocity: (number) -> number
}

local __camShakeStates = {
	Reserved = -1, 
	Inactive = 0,
	Active = 1,
	FadeInProgress = 2, 
	FadeOutProgress = 3
}

export type CamShakeStates = typeof(__camShakeStates)

local __camShakePresetConfiguration = {
	MAGNITUDE = "Magnitude",
	ROUGHNESS = "Roughness",
	FADEOUTTIME = "FadeOutTime",
	FADEINTIME = "FadeInTime",
	VELOCITY = "Velocity",
	DAMPING = "Damping",
	TENSION = "Tension"
}


BuiltIn.BuildInPresets = {
	__presetConfig = __camShakePresetConfiguration,
	__camShakeStates = __camShakeStates
}

return BuiltIn
