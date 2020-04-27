AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/props_rooftop/satellitedish02.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props_rooftop/satellitedish02.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:PhysWake()
	
	-- Important power vars!
	self.PowerItem = true
	self.PowerLevel = 0
	self.NetworkContainer = nil
	self.LinkedItems = {}
	self.DirectLinks = {}
end

function ENT:Use( activator, caller )
 
end

function ENT:Think()
--	local constr = constraint.FindConstraint( self, "Weld" )
	
--	if not constr then
--		self.Entity:NextThink(CurTime() + 10)
--		return true
--	end
	
--	if constr.Entity[2].Entity:GetClass() == "tool_radar" then
--		if self:GetNWString( "Owner", "None" ) == constr.Entity[2].Entity:GetNWString( "Owner", "None" ) then
--			if self:GetPos():Distance( constr.Entity[2].Entity:GetPos() ) > 100 then
--				self:EmitSound("ambient/energy/spark4.wav", 100, 100)
--				constraint.RemoveConstraints( self, "Weld" )
--			end
--		else
--			self:EmitSound("ambient/energy/spark4.wav", 100, 100)
--			constraint.RemoveConstraints( self, "Weld" )
--		end
--	else
--		self:EmitSound("ambient/energy/spark4.wav", 100, 100)
--		constraint.RemoveConstraints( self, "Weld" )
--	end
--	
--	self.Entity:NextThink(CurTime() + 10)
--	return true
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
