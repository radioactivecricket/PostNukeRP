AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/props_citizen_tech/transponder.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props_citizen_tech/transponder.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:PhysWake()
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		if not activator:HasWeapon("weapon_radio") then
			local sound = Sound("items/ammo_pickup.wav")
			self.Entity:EmitSound( sound )
			
			self.Entity:Remove()
			
			-- local ammo
			-- if self.Entity:GetNWString("Ammo") then
				-- ammo = tonumber(self.Entity:GetNWString("Ammo"))
			-- else
				-- ammo = 7
			-- end
			
			local ent = ents.Create("weapon_radio")
			local pos = activator:GetPos() 
			ent:SetModel("models/props_citizen_tech/transponder.mdl")
			ent:SetAngles(Angle(0,0,0))
			ent:SetPos(pos)
			ent:Spawn()
			ent:SetNetworkedString("Owner", "World")
			ent:SetClip1(ammo)
		end
 
	end
 
end
