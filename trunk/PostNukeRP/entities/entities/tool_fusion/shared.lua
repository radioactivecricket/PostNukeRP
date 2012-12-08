ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
 
ENT.PrintName		= "Fusion Generator"
ENT.Author			= "LostInTheWired"
ENT.Contact			= ""  --fill in these if you want it to be in the spawn menu
ENT.Purpose			= "Power Generator for the PNRP Gamemode."
ENT.Instructions	= "Start it and hope for the best!"

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
