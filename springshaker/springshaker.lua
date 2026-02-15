--[[
SpringShaker by kasym77777 
Source: https://github.com/nilleniumrust/CameraShaker-optimized
Please read API documentation in the GitHub linked up ^

A CameraShaker that works similarly like Sleitnick's CamShaker, but more modified and upgraded version.
This CameraShaker, works on a trailed spring system which achieves what a Spring would do using Semi-Implicit Euler Integrators.
]]

--// CLASSES \\--
local SpringShaker = {}
local SpringShakerPresets = {}

--// MODULES  \\--
local BuiltIn = require(script.BuiltIn)
local Janitor = require(script.Janitor)
local ShakerInstances = require(script.ShakerInstances)
local Presets = require(script.Presets)

--// CONFIGURATION \\--
local PresetData = BuiltIn.BuildInPresets
local PresetConfig = PresetData.__presetConfig

--// SERVICES || IMPORTS \\--
local CurrentCamera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

--// DECLARATIONS & PRIVATE FUNCTIONS \\--
local __classInstances = {}
export type __SpringShakerClassDef = typeof(SpringShakerPresets) & BuiltIn.__camShakePreset

SpringShaker._PresetsMap = Presets
SpringShaker._PartnerLoop = false

SpringShakerPresets.__index = function(self, __indexmap): () -> ()
	local internal_rawdata = rawget(self, __indexmap)
	if internal_rawdata ~= nil then 
		return internal_rawdata 
	end

	local PRESET_CONNECTOR = {
		[PresetConfig.MAGNITUDE] = function() return self.Magnitude end,
		[PresetConfig.ROUGHNESS] = function() return self.Roughness end,
		[PresetConfig.FADEINTIME] = function() return self.FadeInTime end,
		[PresetConfig.FADEOUTTIME] = function() return self.FadeOutTime end,
		[PresetConfig.DAMPING] = function() return self.Damping end,
		[PresetConfig.TENSION] = function() return self.Tension end, 
		[PresetConfig.VELOCITY] = function() return self.Velocity end
	}

	local __connector = PRESET_CONNECTOR[__indexmap]
	if __connector then 
		return __connector()
	end

	return SpringShaker[__indexmap]
end

--// FUNCTIONS \\--

--- Creates a brand new Springy camera shaker instance.
--- @param __SpringShakeDefClass table -- The configuration table for the shaker.
--- @return __SpringShakerClassDef -- Returns the shaker class object.
function SpringShaker.new(__SpringShakeDefClass: BuiltIn.__camShakePreset): __SpringShakerClassDef
	assert(RunService:IsClient(), "SpringShaker must be run on the client.")
	assert(__SpringShakeDefClass, "SpringShaker must have a valid table.")
	assert(typeof(__SpringShakeDefClass) == "table", "SpringShaker.new expects a table configuration.")

	local __Magnitude = math.clamp(__SpringShakeDefClass.Magnitude or 0.4, 0, 10^5)
	assert(__Magnitude < 10^5, "Magnitude is too high!")

	local self = setmetatable({
		Active = true,
		Magnitude = __Magnitude,
		Roughness = math.clamp(__SpringShakeDefClass.Roughness or 0.2, 0, 500),
		FadeInTime = __SpringShakeDefClass.FadeInTime or 0.1,
		FadeOutTime = __SpringShakeDefClass.FadeOutTime or 0.5,
		Tension = math.clamp(__SpringShakeDefClass.Tension or 150, 0, 1500),
		Damping = __SpringShakeDefClass.Damping or __SpringShakeDefClass.Damper or 10, 
		Damper = __SpringShakeDefClass.Damping or __SpringShakeDefClass.Damper or 10,
		__JanitorClass = Janitor.new(), 
		Velocity = __SpringShakeDefClass.Velocity or Vector3.zero,
		__RenderName = __SpringShakeDefClass.__RenderName or ("SpringShaker_" .. game:GetService("HttpService"):GenerateGUID(false)),
		__RenderPriority = __SpringShakeDefClass.__RenderPriority or (Enum.RenderPriority.Camera.Value + 1),
		__Callback = nil,
		RotationInfluence = __SpringShakeDefClass.RotationInfluence or __SpringShakeDefClass.RotInflux or Vector3.new(1, 1, 1),
		PositionInfluence = __SpringShakeDefClass.PositionInfluence or __SpringShakeDefClass.PosInflux or Vector3.new(0, 0, 0),
	}, SpringShakerPresets)
	
	self.__JanitorClass:Add(function()
		RunService:UnbindFromRenderStep(self.__RenderName)
		self.Active = false
	end)
	
	return self
end

--- Retrieves a preset by name and returns a new Shaker instance using that preset's config.
--- @param PresetName string -- The key name of the preset in the Presets module.
--- @return __SpringShakerClassDef? -- Returns the instance, or nil if not found.
function SpringShaker:GetPreset(PresetName: string): __SpringShakerClassDef
	local __presetAnnotator = SpringShaker._PresetsMap[PresetName]
	if not __presetAnnotator then 
		warn("Preset is null or invalid.")
		return
	end
	return self.new(__presetAnnotator)
end

--- Internal method to bind the shaker update loop to RenderStep.
--- @param SpringDef __SpringShakerClassDef -- The instance to start rendering.
function SpringShaker:Start(SpringDef: __SpringShakerClassDef)
	if SpringShaker._PartnerLoop then return end 
	SpringShaker._PartnerLoop = true
	RunService:BindToRenderStep("PartnerLoop", Enum.RenderPriority.Camera.Value + 1, function(DeltaTime)
		debug.profilebegin("SpringShakerClass") 
		if #__classInstances == 0 then
			RunService:UnbindFromRenderStep("PartnerLoop")
			SpringShaker._PartnerLoop = false
			return
		end

		local _Offset = self:UpdateAll(DeltaTime)
		CurrentCamera.CFrame *= _Offset
		debug.profileend()
	end)
end

--- Forces a specific shaker instance to stop rendering immediately.
--- @param SpringDef __SpringShakerClassDef -- The instance to halt.
function SpringShaker:Halt(SpringDef: __SpringShakerClassDef)
	assert(SpringDef, "SpringDef must be of type table")
	if SpringDef.__Callback or SpringDef.__RenderName then 
		RunService:UnbindFromRenderStep(SpringDef.__RenderName)
	end
end

--- Iterates through all active shakers and triggers their FadeOut.
--- @param FadeOutTime number? -- Optional time to override the preset's FadeOutTime.
function SpringShaker:HaltAll(FadeOutTime: number)
	for _, shaker in ipairs(__classInstances) do
		if shaker.__SpringShakeInstance then
			shaker.__SpringShakeInstance:FadeOut(FadeOutTime or 0.5)
		end
	end
end

--- Immediately stops all rendering, cleans up all memory, and clears the instance list.
function SpringShaker:RecycleAll()
	if #__classInstances > 0 then
		RunService:UnbindFromRenderStep(__classInstances[1].__RenderName)
	end
	for i = #__classInstances, 1, -1 do
		self:Recycle(__classInstances[i])
		table.remove(__classInstances, i)
	end
	table.clear(__classInstances)
	self.__running = false
end

--- Fades out all active shakers based on their current state.
--- @param Time number? -- Optional override for the FadeOut duration.
function SpringShaker:HaltDurationWise(Time: number)
	for _, shakerPreset in ipairs(__classInstances) do 
		local mathInstance = shakerPreset.__SpringShakeInstance 
		if mathInstance and not mathInstance:IsFadingOut() then 
			mathInstance:FadeOut(Time or shakerPreset.FadeOutTime)
		end
	end
end

--- Internal core loop that calculates the combined CFrame of all active springs.
--- @param dx number -- The DeltaTime from RenderStep.
--- @return CFrame -- The combined offset to be applied to the Camera.
function SpringShaker:UpdateAll(dx: number): CFrame
	if #__classInstances == 0 then return CFrame.identity end
	if not dx then return end
	
	local __rotdef = Vector3.zero
	local MAX_OFFSET = 15 -- To not scare amplitude off

	for i = #__classInstances, 1, -1 do 
		local __SpringShakerClass = __classInstances[i]
		local __SpringShakeInstance = __SpringShakerClass.__SpringShakeInstance 
		
		if not __SpringShakeInstance then continue end
		local __component = __SpringShakeInstance:Update(dx)

		if __SpringShakeInstance:IsDead() then 
			self:Recycle(__SpringShakerClass)
			table.remove(__classInstances, i) 
			continue
		end
		__rotdef += (__component * __SpringShakeInstance.RotationInfluence)
	end
	
	if __rotdef.Magnitude > MAX_OFFSET then
		__rotdef = __rotdef.Unit * MAX_OFFSET
	end

	return CFrame.fromEulerAnglesXYZ(math.rad(__rotdef.X), math.rad(__rotdef.Y), math.rad(__rotdef.Z))
end

--- Cleans up an individual shaker instance and its Janitor class.
--- @param __SpringShakerClass any -- The specific instance to recycle.
function SpringShaker:Recycle(__SpringShakerClass)
	if not __SpringShakerClass then return end
	if __SpringShakerClass.__JanitorClass then
		__SpringShakerClass.__JanitorClass:Cleanup()
	end
	__SpringShakerClass.__SpringShakeInstance = nil
	table.clear(__SpringShakerClass)
end

--- Adds a shaker instance to the active stack.
--- @param __SpringShakeInstance __SpringShakerClassDef -- The instance to append.
function SpringShaker:Append(__SpringShakeInstance: __SpringShakerClassDef)
	assert(__SpringShakeInstance, "__SpringShakeInstance not found")
	table.insert(__classInstances, __SpringShakeInstance)
end

--- Starts a shaker that lasts until manually stopped.
--- @param __SpringShakeInstance __SpringShakerClassDef -- The instance to use.
--- @return function -- Returns a callback function (for legacy compatibility).
function SpringShaker:ShakeSustained(__SpringShakeInstance: __SpringShakerClassDef): () -> CFrame
	assert(__SpringShakeInstance, "spring shaker class missing!")
	
	__SpringShakeInstance.__SpringShakeInstance = ShakerInstances.new(__SpringShakeInstance)
	__SpringShakeInstance.__SpringShakeInstance:FadeIn(__SpringShakeInstance.FadeInTime)
	
	self:Append(__SpringShakeInstance)
	
	self:Start(__SpringShakeInstance)
	return function() return __SpringShakeInstance.__CFCallback or CFrame.identity end
end

--- Plays a shaker once for a specific duration.
--- @param SpringDef __SpringShakerClassDef -- The instance configuration.
--- @param Duration number? -- How long the shake should stay active before fading out.
function SpringShaker:ShakeOnce(SpringDef: __SpringShakerClassDef, Duration: number)
	assert(SpringDef, "spring shaker class missing!")
	SpringDef.__SpringShakeInstance = ShakerInstances.new(SpringDef)
	
	self:Append(SpringDef)
	self:Start(SpringDef)
	
	task.delay(Duration or 1, function()
		if SpringDef and SpringDef.__SpringShakeInstance then
			SpringDef.__SpringShakeInstance:FadeOut(SpringDef.FadeOutTime or 0.5)
		end
	end)
end

return SpringShaker
