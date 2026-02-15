--[[
You can add any types of Presets here as long as it follows the format below:
PresetName = {
	Magnitude: number, 
	Roughness: number, 
	FadeInTime: number, 
	FadeOutTime: number, 
	Tension: number, 
	Damping: number, 
	RotationInfluence: Vector3, 
}

To run it, you just have to use the function of :GetPreset() and enter a valid Preset (string).
]]

local Presets = {
	Explosion = {
		Magnitude = 8,
		Roughness = 25,
		FadeInTime = 0,
		FadeOutTime = 1.2,
		Tension = 400,
		Damping = 45, 
		RotationInfluence = Vector3.new(4, 1, 2),
	},
	Landmine = {
		Magnitude = 3,
		Roughness = 30,
		FadeInTime = 0,
		FadeOutTime = 0.4,
		Tension = 600, 
		Damping = 60,
		RotationInfluence = Vector3.new(3, 0.5, 0.5),
	},
	Earthquake = {
		Magnitude = 4,
		Roughness = 4,
		FadeInTime = 2, 
		FadeOutTime = 10, 
		Tension = 150, 
		Damping = 25,
		RotationInfluence = Vector3.new(1, 4, 4), 
	},
	ExplosiveBullet = {
		Magnitude = 1.5,    
		Roughness = 45,      
		FadeInTime = 0,       
		FadeOutTime = 0.2,    
		Tension = 800,        
		Damping = 70,      
		RotationInfluence = Vector3.new(1.2, 0.4, 0.4),
	},
	Vibration = {
		Magnitude = 0.2,
		Roughness = 50,     
		FadeInTime = 1.0,   
		FadeOutTime = 1.0,
		Tension = 1000,      
		Damping = 80,         
		RotationInfluence = Vector3.new(0.2, 0.2, 0.2),
	},
	Bounce = {
		Magnitude = 2.0,
		Roughness = 5,      
		FadeInTime = 0,
		FadeOutTime = 0.8,
		Tension = 150,       
		Damping = 12,         
		RotationInfluence = Vector3.new(2, 0, 0.5),
	},
	Resonance = {
		Magnitude = 5.0,
		Roughness = 12,
		FadeInTime = 4.0, 
		FadeOutTime = 2.0,
		Tension = 200,
		Damping = 15, 
		RotationInfluence = Vector3.new(2, 2, 2),
	}
}

return Presets
