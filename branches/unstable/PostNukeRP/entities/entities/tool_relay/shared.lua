ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
 
ENT.PrintName		= "Power Relay"
ENT.Author			= "LostInTheWired"
ENT.Contact			= ""  --fill in these if you want it to be in the spawn menu
ENT.Purpose			= "Relay for extending cables in PNRP."
ENT.Instructions	= ""

ENT.AutomaticFrameAdvance = true 
 
ENT.Spawnable			= false
ENT.AdminSpawnable		= false

---------------------------------------------------------
--   Name: OnRemove
--   Desc: Called just before entity is deleted
---------------------------------------------------------

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
 
	self.AutomaticFrameAdvance = bUsingAnim
 
end
