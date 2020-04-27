ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
 
ENT.PrintName		= "Automated Miner"
ENT.Author			= "LostInTheWired"
ENT.Contact			= ""  --fill in these if you want it to be in the spawn menu
ENT.Purpose			= "Scavenger's mining tool."
ENT.Instructions	= "Is this Dune or what?"

ENT.AutomaticFrameAdvance = true 
 
ENT.Spawnable			= false
ENT.AdminSpawnable		= false

---------------------------------------------------------
--   Name: OnRemove
--   Desc: Called just before entity is deleted
---------------------------------------------------------
function ENT:OnRemove()
	if (SERVER) then
		util.AddNetworkString("radar_state")
		net.Start("radar_state")
			net.WriteString("none")
			net.WriteDouble(self.Entity:EntIndex())
		net.Send(rp)
		self.Ready = 0
	end
end

function ENT:IsOutside()

	local trace = {}
	trace.start = self:GetLocalPos()
	trace.endpos = trace.start + ( self:GetUp() * 500 )
	trace.filter = self
	local tr = util.TraceLine( trace )

	if !tr.HitWorld && !tr.HitNonWorld then
	
		return true
		
	end
	
	return false

end

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
 
	self.AutomaticFrameAdvance = bUsingAnim
 
end
