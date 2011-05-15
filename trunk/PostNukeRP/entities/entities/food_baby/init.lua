AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/props_c17/doll01.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/doll01.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:PhysWake()
end

function ENT:Use( activator, caller )
	
 
	if ( activator:IsPlayer() ) then
		
		local hunger = activator:GetTable().Hunger
		
		if not ( hunger == 100 ) then
			local sound = Sound("ambient/creatures/town_child_scream1.wav")
			self.Entity:EmitSound( sound )
			activator:ChatPrint("April Fools :)")
			
			for i=1, 5 do
				local zomb = ents.Create("npc_zombie")
				local x = math.random(-64, 64 )
				local y = math.random(-64, 64 )
				zomb:SetPos( activator:GetPos() + Vector( x, y, 8 ) )
				zomb:DropToFloor()
				zomb:Spawn()
			end
			
			activator:GiveHunger( 20 )
			self.Entity:Remove()
		end
 
	end
 
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
