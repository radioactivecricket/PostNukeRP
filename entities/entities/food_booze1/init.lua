AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/props_junk/glassjug01.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props_junk/glassjug01.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:PhysWake()
end

function ENT:Use( activator, caller )
	
 
	if ( activator:IsPlayer() ) then
		
		local drunkness = activator:GetTable().Drunkness
		
		if not drunkness then
			activator.Drunkness = 0
		end
		
		local sound = Sound("npc/ichthyosaur/snap.wav")
		self.Entity:EmitSound( sound )
		
		activator:GiveHunger( 30 )
		activator:GiveDrunkness(20)
		
		if activator.Drunkness >= 100 then
			activator:ChatPrint("You've passed out completely!")
			
			activator.Endurance = 0
			SendEndurance( activator )
			
			EnterSleep(activator)
		end
		
		self.Entity:Remove()
 
	end
 
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
