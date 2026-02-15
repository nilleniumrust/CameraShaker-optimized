local ShakerInstances = {}
ShakerInstances.__index = ShakerInstances

local SpringShaker = script.Parent
local BuiltIn = require(SpringShaker.BuiltIn)

local Random = Random.new()

type CamShakeInstance = BuiltIn.CamShakeStates

function ShakerInstances.new(__SpringShakeDefClass)
	assert(__SpringShakeDefClass, "__SpringShakeDefClass must be of a new constructor class")

	local INITIATOR_COMPOUND = setmetatable({
		Magnitude = __SpringShakeDefClass.Magnitude or 0.4, 
		Roughness = __SpringShakeDefClass.Roughness or 0.2, 
		FadeInTime = __SpringShakeDefClass.FadeInTime or 0,
		FadeOutTime = __SpringShakeDefClass.FadeOutTime or 0,
		Velocity = __SpringShakeDefClass.Velocity or Vector3.zero,
		Tension = __SpringShakeDefClass.Tension or 150,
		Damper = __SpringShakeDefClass.Damper or 10,
		PositionInfluence = __SpringShakeDefClass.PosInflux or __SpringShakeDefClass.PositionInfluence or Vector3.zero,
		RotationInfluence = __SpringShakeDefClass.RotInflux or __SpringShakeDefClass.RotationInfluence or Vector3.one,
		Elapsed = 0,
		SustainComplex = __SpringShakeDefClass.FadeInTime > 0,
		Position = Vector3.zero,
		CurrentTime = (__SpringShakeDefClass.FadeInTime > 0 and 0 or 1),
		Active = true, 
		Tick = Random:NextInteger(-100,100),
		State = BuiltIn.BuildInPresets.__camShakeStates.Active
	}, ShakerInstances)

	return INITIATOR_COMPOUND
end

--# Advanced semi-notorious perlin noise implemented through Hooke's Law
--# We are not using linear-complex duty mathematics, you can imagine this as a Pendulum that swings, but looses energy due to air resistance. 
--# Like this, it looses energy dissipated on time. 
--[[
	    Graph: https://www.desmos.com/calculator/r8iharhx3y
	    Force (ext) = (Pn(k) + 0.3 * Pn(c)) * (A * Ep)
	    
	    Pn(k) <- Perlin noise, rumbling
	    Pn(c) <- Perlin noise, jitter
	    A   <- Magnitude or, as designated Amplitude
	    Ep  <- Current energy
	    
	    k   <- Tension
	    c   <- Damper
	    ================================
	    Using hooke's law (F=-kx)
	    Restoring force would be Fs=-kx, and damping force Fd=-cv, so, total external force would be
	    F = -kx + -cv=Fs+Fd
	    ma=-k(x-Fext)-cv
	    
	    Here, mass is assumed as privelege of 1.0
	    ================================
	    v1=v0+(a*dt)
	    x1=x0+(v1*dt)
]]--

--@class ShakerInstances
--@param dx number -- A number given in physics, determines the difference of time.
function ShakerInstances:Update(dx)
	if not self.Active or not self.Position then return Vector3.zero end
	--# Even though we're fine at 0.016s at rapid 60FPS we can still benefit from capping the delta time at 0.033s (30FPS), from not having excessive physics teardown
	dx = math.min(dx, 0.033) 

	if self.SustainComplex then
		local rate = (self.FadeInTime > 0) and (dx / self.FadeInTime) or 1
		self.CurrentTime = math.min(1, self.CurrentTime + rate)
	else
		local rate = (self.FadeOutTime > 0) and (dx / self.FadeOutTime) or 1
		self.CurrentTime = math.max(0, self.CurrentTime - rate)
	end


	local energy = math.pow(self.CurrentTime, 3)
	self.Elapsed = self.Elapsed + (dx * self.Roughness)
	local _t = self.Elapsed + self.Tick
	
	
	local rumble = Vector3.new(
		math.noise(_t, 0), 
		math.noise(0, _t), 
		math.noise(_t, _t)
	)
	local jitter = Vector3.new(
		math.noise(_t * 5, 0), 
		math.noise(0, _t * 5), 
		math.noise(_t * 5, _t * 5)
	) * 0.3

	local combinedForce = (rumble + jitter) * (self.Magnitude * energy)

	local displacement = (self.Position - combinedForce)
	local springForce = -self.Tension * displacement
	local dampingForce = -self.Damper * self.Velocity 

	self.Velocity += (springForce + dampingForce) * dx
	self.Position += self.Velocity * dx
	
	--# Check for NaN or explosive values that can 'destroy' the spring at any moment. 
	--# https://en.wikipedia.org/wiki/Resonance
	if self.Position.X ~= self.Position.X or self.Position.Magnitude > 10^5 then
		warn("SpringShake: Massive resonance detected, aborting...")
		self.Position = Vector3.zero
		self.Velocity = Vector3.zero
		return Vector3.zero
	end
	
	return self.Position
end

function ShakerInstances:FadeOut(Time: number)
	assert(Time, "given time was not found and failed to set fadeout")
	if Time == 0 then 
		self.CurrentTime = 0 
	end

	self.FadeOutTime = Time
	self.FadeInTime = 0
	self.SustainComplex = false
end

function ShakerInstances:GetFadeMagnitude()
	return math.pow(self.CurrentTime, 3)
end

function ShakerInstances:FadeIn(Time: number)
	assert(Time, "given time was not found and failed to set fadeout")
	if Time == 0 then 
		self.CurrentTime = 0 
	end

	self.FadeOutTime = 0
	self.FadeInTime = Time
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
	if not self.Position then return true end

	local curTime = self.CurrentTime or 0
	local isSettled = self.Position.Magnitude < 0.001 
		and self.Velocity.Magnitude < 0.001

	return (not self.SustainComplex) and (curTime <= 0) and isSettled
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
