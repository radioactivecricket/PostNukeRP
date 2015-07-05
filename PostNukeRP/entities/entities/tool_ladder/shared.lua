ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
 
ENT.PrintName		= "Ladder"
ENT.Author			= "LiddulBOFH"
ENT.Contact			= ""  --fill in these if you want it to be in the spawn menu
ENT.Purpose			= "A general purpose ladder."
ENT.Instructions	= "Put it somewhere, you doofus."
 
ENT.AutomaticFrameAdvance = true 
 
ENT.Spawnable			= false
ENT.AdminSpawnable		= false

---------------------------------------------------------
--   Name: OnRemove
--   Desc: Called just before entity is deleted
---------------------------------------------------------

function ENT:OnRemove()
	if (SERVER) then
		util.AddNetworkString("ladder_state")
		net.Start("ladder_state")
			net.WriteString("none")
			net.WriteDouble(self.Entity:EntIndex())
		net.Send(rp)
		self.Ready = 0
	end
end

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
 
	self.AutomaticFrameAdvance = bUsingAnim
 
end