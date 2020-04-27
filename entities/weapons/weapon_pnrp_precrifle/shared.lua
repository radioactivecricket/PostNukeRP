
SWEP.Author		= "LostInTheWired"
SWEP.Contact		= "LostInTheWired@gmail.com"
SWEP.Purpose		= "Very well made.  Also, very expensive.\n  Could have shared that wealth..."
SWEP.Instructions	= "Right click to use scope.\nWALK-Right click to hold passive."

SWEP.ViewModel		= "models/weapons/v_snip_sg550.mdl"
SWEP.WorldModel		= "models/weapons/w_snip_sg550.mdl"

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 	= true
SWEP.DrawCrosshair 		= false

SWEP.Base 				= "weapon_base"

SWEP.MuzzleAttachment		= "1" -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment	= "2" -- Should be "2" for CSS models or "1" for hl2 models

SWEP.Primary.Sound 			= Sound("Weapon_SG550.Single")
SWEP.Primary.Recoil 		= 2
SWEP.Primary.Damage 		= 70
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0
SWEP.Primary.ClipSize 		= 5
SWEP.Primary.Delay 			= 0.5
SWEP.Primary.DefaultClip 	= 5
SWEP.Primary.Automatic 		= false
SWEP.Primary.Ammo 			= "357"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"
SWEP.MouseSensitivity		= 1

SWEP.HoldType				= "ar2"
SWEP.ViewModelFlip			= true

SWEP.IronSightsPos = Vector (5.6212, 0, 1.8808)
SWEP.IronSightsAng = Vector (0, 0, 0)

SWEP.IronSightZoom			= 1.3 -- How much the player's FOV should zoom in ironsight mode. 
SWEP.UseScope				= true -- Use a scope instead of iron sights.
SWEP.ScopeScale 				= 0.4 -- The scale of the scope's reticle in relation to the player's screen size.
SWEP.ScopeZooms				= {6} -- The possible magnification levels of the weapon's scope.   If the scope is already activated, secondary fire will cycle through each zoom level in the table.

local sndZoomIn = Sound("Weapon_AR2.Special1")
local sndZoomOut = Sound("Weapon_AR2.Special2")

function SWEP:Initialize()
	util.PrecacheModel( self.ViewModel )
	util.PrecacheModel( self.WorldModel )
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound("Weapon_Weapon_SG550.Reload")
	
	util.PrecacheSound(sndZoomIn)
	util.PrecacheSound(sndZoomOut)
	
	if CLIENT then
	
		-- We need to get these so we can scale everything to the player's current resolution.
		local iScreenWidth = surface.ScreenWidth()
		local iScreenHeight = surface.ScreenHeight()
		
		-- The following code is only slightly riped off from Night Eagle
		-- These tables are used to draw things like scopes and crosshairs to the HUD.
		self.ScopeTable = {}
		self.ScopeTable.l = iScreenHeight*self.ScopeScale
		self.ScopeTable.x1 = 0.5*(iScreenWidth + self.ScopeTable.l)
		self.ScopeTable.y1 = 0.5*(iScreenHeight - self.ScopeTable.l)
		self.ScopeTable.x2 = self.ScopeTable.x1
		self.ScopeTable.y2 = 0.5*(iScreenHeight + self.ScopeTable.l)
		self.ScopeTable.x3 = 0.5*(iScreenWidth - self.ScopeTable.l)
		self.ScopeTable.y3 = self.ScopeTable.y2
		self.ScopeTable.x4 = self.ScopeTable.x3
		self.ScopeTable.y4 = self.ScopeTable.y1
				
		self.ParaScopeTable = {}
		self.ParaScopeTable.x = 0.5*iScreenWidth - self.ScopeTable.l
		self.ParaScopeTable.y = 0.5*iScreenHeight - self.ScopeTable.l
		self.ParaScopeTable.w = 2*self.ScopeTable.l
		self.ParaScopeTable.h = 2*self.ScopeTable.l
		
		self.ScopeTable.l = (iScreenHeight + 1)*self.ScopeScale -- I don't know why this works, but it does.

		self.QuadTable = {}
		self.QuadTable.x1 = 0
		self.QuadTable.y1 = 0
		self.QuadTable.w1 = iScreenWidth
		self.QuadTable.h1 = 0.5*iScreenHeight - self.ScopeTable.l
		self.QuadTable.x2 = 0
		self.QuadTable.y2 = 0.5*iScreenHeight + self.ScopeTable.l
		self.QuadTable.w2 = self.QuadTable.w1
		self.QuadTable.h2 = self.QuadTable.h1
		self.QuadTable.x3 = 0
		self.QuadTable.y3 = 0
		self.QuadTable.w3 = 0.5*iScreenWidth - self.ScopeTable.l
		self.QuadTable.h3 = iScreenHeight
		self.QuadTable.x4 = 0.5*iScreenWidth + self.ScopeTable.l
		self.QuadTable.y4 = 0
		self.QuadTable.w4 = self.QuadTable.w3
		self.QuadTable.h4 = self.QuadTable.h3

		self.LensTable = {}
		self.LensTable.x = self.QuadTable.w3
		self.LensTable.y = self.QuadTable.h1
		self.LensTable.w = 2*self.ScopeTable.l
		self.LensTable.h = 2*self.ScopeTable.l

		self.CrossHairTable = {}
		self.CrossHairTable.x11 = 0
		self.CrossHairTable.y11 = 0.5*iScreenHeight
		self.CrossHairTable.x12 = iScreenWidth
		self.CrossHairTable.y12 = self.CrossHairTable.y11
		self.CrossHairTable.x21 = 0.5*iScreenWidth
		self.CrossHairTable.y21 = 0
		self.CrossHairTable.x22 = 0.5*iScreenWidth
		self.CrossHairTable.y22 = iScreenHeight
		
	end
	
    self:SetWeaponHoldType(self.HoldType)
end

function SWEP:SetupDataTables()
	self:DTVar("Bool", 0, "Holsted")
	self:DTVar("Bool", 1, "Ironsights")
end 

function SWEP:Equip()
	self.Weapon:SetDTBool(0, false)
	self.Weapon:SetDTBool(1, false)
end

function SWEP:PrimaryAttack()

	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
	if self.Weapon:GetDTBool(0) or self.Owner:KeyDown( IN_SPEED ) then return end
	
	self.Weapon:EmitSound(self.Primary.Sound)
	self:TakePrimaryAmmo(self.Primary.NumShots)
	
	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	local handlingSkill = self.Owner:GetSkill("Weapon Handling")
	
	if self.Weapon:GetDTBool(1) then
		self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil - (0.1 * handlingSkill)), math.Rand(-1,1) * ((self.Primary.Recoil - (0.1 * handlingSkill)) / 2), 0))
		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone / 2, (self.Primary.Recoil - (0.1 * handlingSkill)) / 2 )
	else
		self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil - (0.1 * handlingSkill)), math.Rand(-1,1) * (self.Primary.Recoil - (0.1 * handlingSkill)), 0))
		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, self.Primary.Cone, (self.Primary.Recoil - (0.1 * handlingSkill)) )
	end
	
	self.LastShoot = CurTime()
end

function SWEP:SecondaryAttack()
	if self.Owner:KeyDown( IN_WALK ) then
		-- local savedBool = (not self.Weapon:GetNWBool("IsPassive", false))
		local savedBool = (not self.Weapon:GetDTBool(0))
		
		if (SERVER) then
			self.Weapon:SetDTBool(0, (not self.Weapon:GetDTBool(0)))
			self.Owner:EmitSound("npc/combine_soldier/gear4.wav")
		end
		
		if savedBool then
			self:SetWeaponHoldType("normal")
			self.Owner:SetFOV( 0, 0.15 )
			self.Weapon:SetDTBool(1, false)
		else
			self:SetWeaponHoldType(self.HoldType)
		end
	else
		--if self.Weapon:GetNWBool("IsPassive", false) then return end
		if self.Weapon:GetDTBool(0) then return end
		-- local savedBool = (not self.Weapon:GetNWBool("IronSights", false))
		local savedBool = (not self.Weapon:GetDTBool(1))
		-- self.Weapon:SetNWBool("IronSights", (not self.Weapon:GetNWBool("IronSights", false))) 
		self.Weapon:SetDTBool(1, (not self.Weapon:GetDTBool(1)))
		
		if savedBool then
			self.Owner:SetFOV( 10, 0.15 )
			self.Weapon:SetNetVar("MouseSensitivity", 0.5)
			if (SERVER) then self.Owner:DrawViewModel(false) end
			self.Owner:EmitSound(sndZoomIn)
		else
			self.Owner:SetFOV( 0, 0.15 )
			self.Weapon:SetNetVar("MouseSensitivity", 1)
			if (SERVER) then self.Owner:DrawViewModel(true) end
			self.Owner:EmitSound(sndZoomOut)
		end
	end
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:Reload()
	if self.Weapon:Clip1() < self.Primary.ClipSize then
		self.Weapon:SetDTBool(1, false)
		self.Owner:SetFOV( 0, 0.15 )
		
		if (SERVER) then self.Owner:DrawViewModel(true) end
		-- self.Weapon:SetNextPrimaryFire(CurTime() + 1.5)
		-- self.Weapon:SetNextSecondaryFire(CurTime() + 1.5)
	
		self:SetWeaponHoldType("ar2")
		self.Weapon:DefaultReload(ACT_VM_RELOAD) 
		self.Weapon:EmitSound("Weapon_Weapon_SG550.Reload")
		
	end
end

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:SetDTBool(0, false)
	self.Weapon:SetDTBool(1, false)
	self.Weapon:SetNetVar("MouseSensitivity", 1)

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	return true
end

function SWEP:Think()
	-- if self.Weapon:GetNWBool("IsPassive", false) or self.Owner:KeyDown( IN_SPEED ) then
		-- self:SetWeaponHoldType("passive")
	-- else
		-- self:SetWeaponHoldType(self.HoldType)
	-- end
end

-- Ironsights code, based on CSS Realistic
local IRONSIGHT_TIME = 0.15

function SWEP:GetViewModelPosition(pos, ang)
	
	if self.Weapon:GetDTBool(0) or self.Owner:KeyDown( IN_SPEED ) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), 		-37.2258)
		ang:RotateAroundAxis(ang:Up(), 		1.7237)
		ang:RotateAroundAxis(ang:Forward(), 	0)
		
		local Offset = Vector(1.6428, 0, 6.2286)
		local Right 	= ang:Right()
		local Up 		= ang:Up()
		local Forward 	= ang:Forward()
		
		pos = pos + Offset.x * Right
		pos = pos + Offset.y * Forward
		pos = pos + Offset.z * Up
		return pos, ang
	end
	
	if (not self.IronSightsPos) then return pos, ang end

	local bIron = self.Weapon:GetDTBool(1)

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
 
	if SERVER then self.Owner:LagCompensation( true ) end
		self.Owner:FireBullets( bullet )
	if SERVER then self.Owner:LagCompensation( false ) end
	
	self:ShootEffects()
	
	if ((game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT)) then
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

if CLIENT then
	local function AdjustSensitivity()
		if LocalPlayer():GetActiveWeapon() and LocalPlayer():GetActiveWeapon():IsValid() then
			if LocalPlayer():GetActiveWeapon():GetClass() == "weapon_pnrp_precrifle" then
				local ironSights = LocalPlayer():GetActiveWeapon():GetDTBool(1)
				if ironSights then
					return 0.35
				else
					return 1
				end
			end
		end
	end
	hook.Add("AdjustMouseSensitivity", "PrecRflSense", AdjustSensitivity)

end
