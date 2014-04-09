
SWEP.Author		= "LostInTheWired"
SWEP.Contact		= "LostInTheWired@gmail.com"
SWEP.Purpose		= "A shaped charge for blowing down doors and\n  blasting antlion mounds!"
SWEP.Instructions	= "Left click to place a charge.\nRight click to detonate charges.\nWALK-Right click to hold passive."

SWEP.ViewModel		= "models/weapons/v_slam.mdl"
SWEP.WorldModel		= "models/weapons/w_slam.mdl"

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 	= true
SWEP.DrawCrosshair 		= false

SWEP.Base 				= "weapon_base"

SWEP.Primary.Recoil 		= 0
SWEP.Primary.Damage 		= 0
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.Delay 			= 1
SWEP.Primary.DefaultClip 	= 1
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "slam"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.HoldType				= "slam"

SWEP.IronSightsPos = Vector (-6.443, -3, 2.5552)
SWEP.IronSightsAng = Vector (0, 0, 0)

if SERVER then SWEP.SetCharges = {} end

local LastAmmo

function SWEP:Initialize()
	util.PrecacheModel( self.ViewModel )
	util.PrecacheModel( self.WorldModel )
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Equip()
	self.Weapon:SetNWBool("IronSights", false)
	self.Weapon:SetNWBool("IsPassive", false)
end

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
	if self.Weapon:GetNWBool("IsPassive", false) or self.Owner:KeyDown( IN_SPEED ) then return end
	
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + 100 * self.Owner:GetAimVector()
	tr.filter = {self.Owner}
	local trace = util.TraceLine(tr)

	self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)

	if not trace.Hit or (trace.Entity:GetClass() ~= "prop_door_rotating" and trace.Entity:GetClass() ~= "func_door_rotating" and trace.Entity:GetClass() ~= "pnrp_antmound" and trace.Entity:GetClass() ~= "func_door") or trace.HitWorld then
		if (SERVER) then
			self.Owner:PrintMessage(HUD_PRINTTALK, "The shaped charge can only be installed on doors or mounds!")
		end 

		return 
	end
	
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Weapon:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
	
	self.Owner:SetAnimation(PLAYER_ATTACK1)

	if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
		self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_IDLE)
	else
		self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_DRAW)
	end
	
	self.LastShoot = CurTime()
	
	if (CLIENT) then return end
	
	if trace.Entity:GetClass() ~= "pnrp_antmound" then
		local ConstrainedEntities = constraint.GetAllConstrainedEntities( trace.Entity )
		for _, ent in pairs( ConstrainedEntities ) do
			if ent:GetClass() == "ent_testcharge" then 
				self.Owner:PrintMessage(HUD_PRINTTALK, "You can't put more then one on the same door!")
				return 
			end
		end
	end
	
	self:TakePrimaryAmmo(self.Primary.NumShots)
	
	Charge = ents.Create("ent_testcharge")
	Charge:SetPos(trace.HitPos + trace.HitNormal)

	trace.HitNormal.z = -trace.HitNormal.z

	Charge:SetAngles(trace.HitNormal:Angle() - Angle(270, 180, 180))

	Charge.Owner = self.Owner
	Charge:Spawn()
	
	Charge:SetNWString("Owner", "Unownable")
	Charge:SetNWEntity("ownerent", self.Owner)
	Charge:SetNWEntity("door", trace.Entity)
	table.insert(self.SetCharges, Charge)
	
	if trace.Entity and trace.Entity:IsValid() and (trace.Entity:GetClass() == "prop_door_rotating" or trace.Entity:GetClass() == "func_door_rotating" or trace.Entity:GetClass() == "func_door") then
		if not trace.Entity:IsNPC() and not trace.Entity:IsPlayer() and trace.Entity:GetPhysicsObject():IsValid() then
			constraint.Weld(Charge, trace.Entity, 0, trace.PhysicsBone, 0, collision == 0, true )
		end
	else
		Charge:SetMoveType(MOVETYPE_NONE)
	end
end

function SWEP:SecondaryAttack()
	if self.Owner:KeyDown( IN_WALK ) then
		local savedBool = (not self.Weapon:GetNWBool("IsPassive", false))
		self.Weapon:SetNWBool("IsPassive", (not self.Weapon:GetNWBool("IsPassive", false)))
		self.Owner:EmitSound("npc/combine_soldier/gear4.wav")
		
		if savedBool then
			self:SetWeaponHoldType("passive")
			self.Owner:SetFOV( 0, 0.15 )
			-- self.Weapon:SetNWBool("IronSights", false)
		else
			self:SetWeaponHoldType("slam")
		end
	else
		if self.Weapon:GetNWBool("IsPassive", false) then return end
		
		if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
			self.Weapon:SendWeaponAnim( ACT_SLAM_DETONATOR_DETONATE )
		else
			self.Weapon:SendWeaponAnim( ACT_SLAM_THROW_DETONATE )
			timer.Simple( 0.1, function ()
				self.Weapon:SendWeaponAnim( ACT_SLAM_THROW_IDLE )
			end)
		end
		
		if SERVER then
			for _, charge in pairs(self.SetCharges) do 
				if charge then
					if charge:IsValid() then
						charge:Explosion()
						if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
							self.Owner:StripWeapon(self:GetClass())
						end
					end
				end
			end
			self.SetCharges = {}
		end
		-- self.Weapon:SetNWBool("IronSights", (not self.Weapon:GetNWBool("IronSights", false))) 
		
		-- if self.Weapon:GetNWBool("IronSights", false) then
			-- self.Owner:SetFOV( 65, 0.15 )
		-- else
			-- self.Owner:SetFOV( 0, 0.15 )
		-- end
	end
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:Reload()
	-- if self.Weapon:Clip1() < self.Primary.ClipSize then
		-- self.Weapon:SetNWBool("IronSights", false)
		-- self.Owner:SetFOV( 0, 0.15 )
		
		-- -- self.Weapon:SetNextPrimaryFire(CurTime() + 1.5)
		-- -- self.Weapon:SetNextSecondaryFire(CurTime() + 1.5)
	
		-- self.Weapon:DefaultReload(ACT_VM_RELOAD) 
		-- self.Weapon:EmitSound("Weapon_SMG1.Reload")
		
	-- end
end

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:SetNWBool("IsPassive", false)

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	return true
end

function SWEP:Think()
	if not self.Owner:IsValid() then return end

	if (not LastAmmo) then LastAmmo = self.Owner:GetAmmoCount(self.Primary.Ammo) end
	
	if LastAmmo <= 0 and self.Owner:GetAmmoCount(self.Primary.Ammo) > 0 then
		self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_DRAW)
	end
	LastAmmo = self.Owner:GetAmmoCount(self.Primary.Ammo)
end

-- Ironsights code, based on CSS Realistic
local IRONSIGHT_TIME = 0.15

function SWEP:GetViewModelPosition(pos, ang)
	
	if self.Weapon:GetNWBool("IsPassive", false) or self.Owner:KeyDown( IN_SPEED ) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), 		-37.2258)
		ang:RotateAroundAxis(ang:Up(), 		1.7237)
		ang:RotateAroundAxis(ang:Forward(), 	0)
		
		local Offset = Vector(1.6428, 0, 8.2286)
		local Right 	= ang:Right()
		local Up 		= ang:Up()
		local Forward 	= ang:Forward()
		
		pos = pos + Offset.x * Right
		pos = pos + Offset.y * Forward
		pos = pos + Offset.z * Up
		return pos, ang
	end

	return pos, ang
end

function SWEP:CanPrimaryAttack()

	if (self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0) or (self.Owner:WaterLevel() > 2) then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		return false
	end

	if (not self.Owner:IsNPC()) and (self.Owner:KeyDown(IN_SPEED)) then
		self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
		return false
	end

	return true
end
