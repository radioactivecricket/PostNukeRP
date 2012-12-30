AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:PhysWake()
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		local myWep = self.Entity:GetNWString("WepClass", nil)
		
		if not myWep then return end
		
		if not activator:HasWeapon(myWep) then
			local sound = Sound("items/ammo_pickup.wav")
			self.Entity:EmitSound( sound )
			
			self.Entity:Remove()
			
			local weaponEntity = activator:Give(myWep)
			local ammo = self.Entity:GetNWInt("Ammo", nil)
			
			if ammo then
				weaponEntity:SetClip1(ammo)
			end
		elseif myWep == "weapon_frag" then
			activator:GiveAmmo(1, "grenade")
			self.Entity:Remove()
		elseif myWep == "weapon_pnrp_charge" then
			activator:GiveAmmo(1, "slam")
			self.Entity:Remove()
		end
 
	end
 
end
