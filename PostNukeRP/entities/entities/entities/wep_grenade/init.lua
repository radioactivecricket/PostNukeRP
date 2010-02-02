AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/weapons/w_grenade.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_grenade.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:PhysWake()
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		local sound = Sound("items/ammo_pickup.wav")
		self.Entity:EmitSound( sound )
		
		self.Entity:Remove()
		
		local ent = ents.Create("weapon_frag")
		local pos = activator:GetPos() 
		ent:SetModel("models/weapons/w_grenade.mdl")
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(pos)
		ent:Spawn()
		ent:SetNetworkedString("Owner", "World")
 
	end
 
end
