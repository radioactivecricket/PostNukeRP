AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/items/crossbowrounds.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/items/crossbowrounds.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:PhysWake()
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		local actWeight = PNRP.InventoryWeight( activator )
		local actCapacity
		if team.GetName(activator:Team()) == "Scavenger" then
			actCapacity = GetConVarNumber("pnrp_packCapScav") + (activator:GetSkill("Backpacking")*10)
		else
			actCapacity = GetConVarNumber("pnrp_packCap") + (activator:GetSkill("Backpacking")*10)
		end
		
		if actCapacity >= actWeight + 6 then
			local sound = Sound("items/ammo_pickup.wav")
			self.Entity:EmitSound( sound )
			
			activator:AddToInventory("fuel_uran", 60)
			
			self:Remove()
		else
			activator:ChatPrint("You cannot carry the contents of the fuel pod!")
		end
	end
 
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
