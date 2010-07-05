ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
 
ENT.PrintName		= "Wasteland Radar Model SCXU 8034"
ENT.Author			= "Eldar Storm"
ENT.Contact			= ""  --fill in these if you want it to be in the spawn menu
ENT.Purpose			= "Radar for use by Wastelanders."
ENT.Instructions	= "Ping!"
 
ENT.Spawnable			= false
ENT.AdminSpawnable		= false

---------------------------------------------------------
--   Name: OnRemove
--   Desc: Called just before entity is deleted
---------------------------------------------------------
function ENT:OnRemove()
	if (SERVER) then
		umsg.Start("radar_state", rp)
		umsg.String("none")
		umsg.Short(self.Entity:EntIndex())
		umsg.End()
		self.Ready = 0
	end
end

function ENT:IsOutside()

	local trace = {}
	trace.start = self:GetLocalPos()
	trace.endpos = trace.start + ( self:GetUp() * 300 )
	trace.filter = self
	local tr = util.TraceLine( trace )

	if !tr.HitWorld && !tr.HitNonWorld then
	
		return true
		
	end
	
	return false

end	

function ENT:StopRunningSound()
	self:StopSound("plats/tram_move.wav")
end