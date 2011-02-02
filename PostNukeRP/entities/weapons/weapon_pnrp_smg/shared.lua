
SWEP.Author		= "LostInTheWired"
SWEP.Contact		= "LostInTheWired@gmail.com"
SWEP.Purpose		= "No one really knows who came up\n  with the name.  It's just what they\n call it.  God knows..."
SWEP.Instructions	= "Right click for iron sights.\nWALK-Right click to hold passive."

SWEP.ViewModel		= "models/weapons/v_smg1.mdl"
SWEP.WorldModel		= "models/weapons/w_smg1.mdl"

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 	= true
SWEP.DrawCrosshair 		= false

SWEP.Base 				= "weapon_base"

SWEP.Primary.Sound 			= Sound("Weapon_SMG1.Single")
SWEP.Primary.Recoil 		= 0.8
SWEP.Primary.Damage 		= 12
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.017
SWEP.Primary.ClipSize 		= 25
SWEP.Primary.Delay 			= 0.095
SWEP.Primary.DefaultClip 	= 25
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "smg1"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.HoldType				= "smg"

SWEP.IronSightsPos = Vector (-6.443, -3, 2.5552)
SWEP.IronSightsAng = Vector (0, 0, 0)

function SWEP:Initialize()
	util.PrecacheModel( self.ViewModel )
	util.PrecacheModel( self.WorldModel )
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound("Weapon_SMG1.Reload")
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:Equip()
	self.Weapon:SetNWBool("IronSights", false)
	self.Weapon:SetNWBool("IsPassive", false)
end

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
	if self.Weapon:GetNWBool("IsPassive", false) or self.Owner:KeyDown( IN_SPEED ) then return end
	
	self.Weapon:EmitSound(self.Primary.Sound)
	self:TakePrimaryAmmo(self.Primary.NumShots)
	
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	local handlingSkill = self.Owner:GetSkill("Weapon Handling")
	
	if self.Weapon:GetNWBool("IronSights", false) then
		self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil - (0.06 * handlingSkill)), math.Rand(-1,1) * ((self.Primary.Recoil - (0.06 * handlingSkill)) / 2), 0))
		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, (self.Primary.Cone - (0.001 * handlingSkill)) / 2, (self.Primary.Recoil - (0.06 * handlingSkill)) / 2 )
	else
		self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil - (0.06 * handlingSkill)), math.Rand(-1,1) * (self.Primary.Recoil - (0.06 * handlingSkill)), 0))
		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, (self.Primary.Cone - (0.001 * handlingSkill)), (self.Primary.Recoil - (0.06 * handlingSkill)) )
	end
	
	self.LastShoot = CurTime()
end

function SWEP:SecondaryAttack()
	if self.Owner:KeyDown( IN_WALK ) then
		local savedBool = (not self.Weapon:GetNWBool("IsPassive", false))
		self.Weapon:SetNWBool("IsPassive", (not self.Weapon:GetNWBool("IsPassive", false)))
		self.Owner:EmitSound("npc/combine_soldier/gear4.wav")
		
		if savedBool then
			self:SetWeaponHoldType("passive")
			self.Owner:SetFOV( 0, 0.15 )
			self.Weapon:SetNWBool("IronSights", false)
		else
			self:SetWeaponHoldType("smg")
		end
	else
		if self.Weapon:GetNWBool("IsPassive", false) then return end
		local savedBool = (not self.Weapon:GetNWBool("IronSights", false))
		self.Weapon:SetNWBool("IronSights", (not self.Weapon:GetNWBool("IronSights", false))) 
		
		if savedBool then
			self.Owner:SetFOV( 65, 0.15 )
		else
			self.Owner:SetFOV( 0, 0.15 )
		end
	end
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:Reload()
	if self.Weapon:Clip1() < self.Primary.ClipSize then
		self.Weapon:SetNWBool("IronSights", false)
		self.Owner:SetFOV( 0, 0.15 )
		
		-- self.Weapon:SetNextPrimaryFire(CurTime() + 1.5)
		-- self.Weapon:SetNextSecondaryFire(CurTime() + 1.5)
	
		self.Weapon:DefaultReload(ACT_VM_RELOAD) 
		self.Weapon:EmitSound("Weapon_SMG1.Reload")
		
	end
end

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Owner:SetNWBool("IronSights", false)
	self.Weapon:SetNWBool("IsPassive", false)

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	return true
end

function SWEP:Think()
	-- if self.Weapon:GetNWBool("IsPassive", false) or self.Owner:KeyDown( IN_SPEED ) then
		-- self:SetWeaponHoldType("passive")
	-- else
		-- self:SetWeaponHoldType("smg")
	-- end
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
	
	if (not self.IronSightsPos) then return pos, ang end

	local bIron = self.Weapon:GetNWBool("IronSights", false)

	if (bIron != self.bLastIron) then
		self.bLastIron = bIron
		self.fIronTime = CurTime()
		
		if (bIron) then
			self.SwayScale 	= 0.3
			self.BobScale 	= 0.1
		else
			self.SwayScale 	= 1.0
			self.BobScale 	= 1.0
		end
	end

	local fIronTime = self.fIronTime or 0

	if (not bIron and fIronTime < CurTime() - IRONSIGHT_TIME) then
		return pos, ang
	end

	local Mul = 1.0

	if (fIronTime > CurTime() - IRONSIGHT_TIME) then
		Mul = math.Clamp((CurTime() - fIronTime) / IRONSIGHT_TIME, 0, 1)

		if not bIron then Mul = 1 - Mul end
	end
	
	local Offset	= self.IronSightsPos
	
	if (self.IronSightsAng) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), 		self.IronSightsAng.x * Mul)
		ang:RotateAroundAxis(ang:Up(), 		self.IronSightsAng.y * Mul)
		ang:RotateAroundAxis(ang:Forward(), 	self.IronSightsAng.z * Mul)
	end

	local Right 	= ang:Right()
	local Up 		= ang:Up()
	local Forward 	= ang:Forward()

	pos = pos + Offset.x * Right * Mul
	pos = pos + Offset.y * Forward * Mul
	pos = pos + Offset.z * Up * Mul

	return pos, ang
end

function SWEP:ShootBullet( damage, num_bullets, aimcone, recoil )
	
	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()	-- Source
	bullet.Dir 		= self.Owner:GetAimVector()	-- Dir of bullet
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )		-- Aim Cone
	bullet.Tracer	= 4	-- Show a tracer on every x bullets 
        bullet.TracerName = "Tracer" -- what Tracer Effect should be used
	bullet.Force	= 1	-- Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = "smg1"
 
	self.Owner:FireBullets( bullet )
	
	self:ShootEffects()
	
	if ((SinglePlayer() and SERVER) or (not SinglePlayer() and CLIENT)) then
		local eyeang = self.Owner:EyeAngles()
		eyeang.pitch = eyeang.pitch - recoil
		self.Owner:SetEyeAngles(eyeang)
	end
	
end

function SWEP:ShootEffects()
 
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )	-- View model animation
	self.Owner:MuzzleFlash()				-- Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )		-- 3rd Person Animation
 
end

-- --Holdtype fix?
-- local function HoldTypeFix()
	-- for k, v in pairs(player.GetAll()) do
		-- local myWep = v:GetActiveWeapon()
		-- if myWep:IsValid() then
			-- if myWep:GetClass() == "weapon_testsmg" then
				-- if myWep:GetNWBool("IsPassive", false) or v:KeyDown( IN_SPEED ) then
					-- myWep:SetWeaponHoldType("passive")
					-- -- -- if (SERVER) then
						-- -- -- -- self.Weapon:SetWeaponHoldType("passive")
						-- -- -- self.Owner:SetAnimation( ACT_HL2MP_IDLE_PASSIVE )
					-- -- -- end
				-- else
					-- myWep:SetWeaponHoldType(myWep.HoldType)
					-- -- -- if (SERVER) then
						-- -- -- -- self.Weapon:SetWeaponHoldType("smg")
						-- -- -- self.Owner:SetAnimation( ACT_HL2MP_IDLE_SMG1 )
					-- -- -- end
				-- end
				-- -- -- self:SetWeaponHoldType( self.HoldType )
			-- end
		-- end
	-- end
-- end
-- hook.Add( "Think", "holdtypefix_test", HoldTypeFix )
