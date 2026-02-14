local ShakerInstances = {}
ShakerInstances.__index = ShakerInstances

local SpringShaker = script.Parent
local BuiltIn = require(SpringShaker.BuiltIn)

type CamShakeInstance = BuiltIn.CamShakeStates

function ShakerInstances.new(__SpringShakeDefClass)
	assert(__SpringShakeDefClass, "__SpringShakeDefClass must be of a new constructor class")
	local INITIATOR_COMPOUND = setmetatable({
		Magnitude = __SpringShakeDefClass.Magnitude or 0.4, 
		Roughness = __SpringShakeDefClass.Roughness or 0.2, 
		FadeInTime = __SpringShakeDefClass.FadeInTime or 0,
		FadeOutTime = __SpringShakeDefClass.FadeOutTime or 0,
		PositionInfluence = __SpringShakeDefClass.PosInflux or Vector3.zero,
		RotationInfluence = __SpringShakeDefClass.RotInflux or Vector3.zero,
		Elapsed = 0,
		SustainComplex = __SpringShakeDefClass.FadeInTime > 0,
		CurrentTime = (__SpringShakeDefClass.FadeInTime > 0 and 0 or 1),
		Active = true, 
		State = BuiltIn.BuildInPresets.__camShakeStates.Active
	}, ShakerInstances)
	
	return INITIATOR_COMPOUND
end

function ShakerInstances:Update(dx)
	if not self.Magnitude then return Vector3.zero end

	self.Elapsed = (self.Elapsed or 0) + (dx * (self.Roughness or 0.1))

	local Offset = Vector3.new(
		math.noise(self.Elapsed, 0, 1.1), 
		math.noise(self.Elapsed, 0, 2.2),
		math.noise(self.Elapsed, 0, 3.3)
	)

	self.CurrentTime = self.CurrentTime or 0

	if self.SustainComplex then
		if (self.FadeInTime or 0) > 0 then
			self.CurrentTime = math.min(1, self.CurrentTime + (dx / self.FadeInTime))
		else
			self.CurrentTime = 1
		end
	else
		if (self.FadeOutTime or 0) > 0 then
			self.CurrentTime = math.max(0, self.CurrentTime - (dx / self.FadeOutTime))
		else
			self.CurrentTime = 0
		end
	end

	return Offset * self.Magnitude * self.CurrentTime
end

function ShakerInstances:FadeOut(Time: number)
	assert(Time, "given time was not found and failed to set fadeout")
	if Time == 0 then 
		self.CurrentTime = 0 
	end
	
	self.FadeInTime = Time
	self.FadeOutTime = 0
	self.SustainComplex = false
end

function ShakerInstances:FadeIn(Time: number)
	assert(Time, "given time was not found and failed to set fadeout")
	if Time == 0 then 
		self.CurrentTime = 0 
	end

	self.FadeOutTime = Time 
	self.FadeInTime = 0
	self.SustainComplex = true
end

function ShakerInstances:IsShaking(): boolean
	local curTime = self.CurrentTime or 0
	return (curTime > 0 or self.SustainComplex == true)
end

function ShakerInstances:IsFadingOut(): boolean
	local curTime = self.CurrentTime or 0
	return (not self.SustainComplex) and (curTime > 0)
end

function ShakerInstances:IsFading(): boolean
	local curTime = self.CurrentTime or 0
	local fadeIn = self.FadeInTime or 0
	return (curTime < 1) and (self.SustainComplex == true) and (fadeIn > 0)
end

function ShakerInstances:IsDead(): boolean
	local curTime = self.CurrentTime or 0
	return (not self.SustainComplex) and (curTime <= 0)
end

function ShakerInstances:GetState(): CamShakeInstance
	if self:IsShaking() then 
		return BuiltIn.BuildInPresets.__camShakeStates.Active
	end
	
	if self:IsFadingOut() then
		return BuiltIn.BuildInPresets.__camShakeStates.FadeOutProgress
	end
	
	if self:IsFading() then 
		return BuiltIn.BuildInPresets.__camShakeStates.FadeInProgress
	end
	
	
	return BuiltIn.BuildInPresets.__camShakeStates.Inactive
end


return ShakerInstances
