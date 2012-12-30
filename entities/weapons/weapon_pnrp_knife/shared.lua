
SWEP.Author		= "LostInTheWired"
SWEP.Contact		= "LostInTheWired@gmail.com"
SWEP.Purpose		= "Your lifeblood in the wastes.  What\n  would you do without your knife?\nPlus, very few can survive a good backstab."
SWEP.Instructions	= "WALK-Right click to hold passive."

SWEP.ViewModel		= "models/weapons/v_knife_t.mdl"
SWEP.WorldModel 	= "models/weapons/w_knife_t.mdl" 

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 	= true
SWEP.DrawCrosshair 		= true

SWEP.Base 				= "weapon_base"

SWEP.MuzzleAttachment		= "1" -- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment	= "2" -- Should be "2" for CSS models or "1" for hl2 models

SWEP.MissSound 				= Sound("weapons/knife/knife_slash1.wav")
SWEP.WallSound 				= Sound("weapons/knife/knife_hitwall1.wav")
SWEP.DeploySound				= Sound("weapons/knife/knife_deploy1.wav")

SWEP.Primary.Damage 		= 25
SWEP.Primary.ClipSize 		= -1
SWEP.Primary.Delay 			= 0.5
SWEP.Primary.DefaultClip 	= -1
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "none"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.HoldType				= "knife"

SWEP.IronSightsPos = Vector (0, 0, 0)
SWEP.IronSightsAng = Vector (0, 0, 0)

function SWEP:Initialize()
	util.PrecacheModel( self.ViewModel )
	util.PrecacheModel( self.WorldModel )
	util.PrecacheSound(self.MissSound)
	util.PrecacheSound(self.WallSound)
	util.PrecacheSound(self.DeploySound)
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

	if self.Weapon:GetDTBool(0) or self.Owner:KeyDown( IN_SPEED ) then return end
	
	local tr = {}
	tr.start = self.Owner:GetShootPos()
	tr.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 50 )
	tr.filter = self.Owner
	tr.mask = MASK_SHOT
	local trace = util.TraceLine( tr )

	self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if ( trace.Hit ) then
		if trace.Entity:IsPlayer() or string.find(trace.Entity:GetClass(),"npc") or string.find(trace.Entity:GetClass(),"prop_ragdoll") then
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 1
			if SERVER then
				if trace.Entity:GetAimVector():DotProduct(self.Owner:GetAimVector()) > 0 then
					bullet.Damage = self.Primary.Damage * 4
				else
					bullet.Damage = self.Primary.Damage
				end
			end
			self.Owner:FireBullets(bullet) 
			self.Weapon:EmitSound( "weapons/knife/knife_hit" .. math.random(1, 4) .. ".wav" )
		else
			self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 1
			bullet.Damage = self.Primary.Damage
			self.Owner:FireBullets(bullet) 
			self.Weapon:EmitSound( self.WallSound )		
			util.Decal("ManhackCut", trace.HitPos + trace.HitNormal, trace.HitPos - trace.HitNormal)
		end
	else
		self.Weapon:EmitSound(self.MissSound,100,math.random(90,120))
		self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
	end
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
		return
	end
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:Reload()
	
end

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:SetDTBool(0, false)
	self.Weapon:SetDTBool(1, false)

	self.Weapon:SetNextPrimaryFire(CurTime() + 1)
	return true
end

function SWEP:Think()
end

-- Ironsights code, based on CSS Realistic
local IRONSIGHT_TIME = 0.15

function SWEP:GetViewModelPosition(pos, ang)
	
	if self.Weapon:GetDTBool(0) or self.Owner:KeyDown( IN_SPEED ) then
		ang = ang * 1
		ang:RotateAroundAxis(ang:Right(), 		-50.2258)
		ang:RotateAroundAxis(ang:Up(), 		1.7237)
		ang:RotateAroundAxis(ang:Forward(), 	0)
		
		local Offset = Vector(1.6428, 0, -3.2286)
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
