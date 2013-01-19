
SWEP.Author		= "LostInTheWired"
SWEP.Contact		= "LostInTheWired@gmail.com"
SWEP.Purpose		= "An extremely rare weapon,\n seen only before the great war..."
SWEP.Instructions	= "Right click for iron sights.\nWALK-Right click to hold passive."

SWEP.ViewModel		= "models/weapons/v_IRifle.mdl"
SWEP.WorldModel		= "models/weapons/w_IRifle.mdl"

SWEP.Spawnable 			= true
SWEP.AdminSpawnable 	= true
SWEP.DrawCrosshair 		= false

SWEP.Base 				= "weapon_base"

SWEP.Primary.Sound 			= Sound("Weapon_AR2.Single")
SWEP.Primary.Recoil 		= 0.8
SWEP.Primary.Damage 		= 30
SWEP.Primary.NumShots 		= 1
SWEP.Primary.Cone 			= 0.017
SWEP.Primary.ClipSize 		= 50
SWEP.Primary.Delay 			= 0.095
SWEP.Primary.DefaultClip 	= 50
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= "ar2"

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= false
SWEP.Secondary.Ammo 		= "none"

SWEP.HoldType				= "ar2"

SWEP.VElements = {
	["sight"] = { type = "Model", model = "models/wystan/attachments/aimpoint.mdl", bone = "Base", pos = Vector(-1.125, 2.75, 10.455), angle = Angle(-180, -17.386, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false },
	["sight_effect"] = { type = "Sprite", sprite = "sprites/redglow3", bone = "Base", pos = Vector(0.625, -3.8, 5.909), size = { x = 1, y = 1 }, color = Color(255, 255, 255, 80), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false}
	-- ["scopezoom"] = { type = "Quad", bone = "Base", rel = "", pos = Vector(0.63, -3.800, 1.5), angle = Angle(0, 0, 0), size = 0.030, draw_func = nil}
}

SWEP.WElements = {
	["sight"] = { type = "Model", model = "models/wystan/attachments/aimpoint.mdl", bone = "ValveBiped.Bip01_R_Hand", pos = Vector(13.182, -1.864, -3.6), angle = Angle(-148.295, -83.8, 11.250), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false }
}

SWEP.IronSightsPos = Vector (-5.24, -3, 1.40)
SWEP.IronSightsAng = Vector (0, 0, 0)

function SWEP:Initialize()
	util.PrecacheModel( self.ViewModel )
	util.PrecacheModel( self.WorldModel )
	util.PrecacheSound(self.Primary.Sound)
	util.PrecacheSound("Weapon_AR2.Reload")
    self:SetWeaponHoldType(self.HoldType)
	
	if SERVER then
		
		self:SetNPCMinBurst(1)			
		self:SetNPCMaxBurst(1)
		self:SetNPCFireRate(1)	
		--self.Owner:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_VERY_GOOD )
	end
	
	if CLIENT and !self.Owner:IsNPC() then
	
		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) and !(self.Owner:IsNPC()) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
			end
			
			// Init viewmodel visibility
			if (self.ShowViewModel == nil or self.ShowViewModel) then
				if IsValid(vm) then
					vm:SetColor(Color(255,255,255,255))
				end
			else
				if IsValid(vm) then
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")
				end
			end
		end
		
	end
end

function SWEP:SetupDataTables()
	self:DTVar("Bool", 0, "Holsted")
	self:DTVar("Bool", 1, "Ironsights")
end 

function SWEP:Equip()
	if self.Owner:IsNPC() then
		ErrorNoHalt("Setting weapon proficiency.")
		self.Owner:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
	end
	self.Weapon:SetDTBool(0, false)
	self.Weapon:SetDTBool(1, false)
end

function SWEP:PrimaryAttack()
	
	if not self:CanPrimaryAttack() or self.Owner:WaterLevel() > 2 then return end
	if not self.Owner:IsNPC() then
		if self.Weapon:GetDTBool(0) or self.Owner:KeyDown( IN_SPEED ) then return end
	end
	
	self.Weapon:EmitSound(self.Primary.Sound)
	if not self.Owner:IsNPC() then
		self:TakePrimaryAmmo(self.Primary.NumShots)
	end
	
	if not self.Owner:IsNPC() then
		self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	else
		self.Weapon:SetNextPrimaryFire(CurTime())
	end
	
	local handlingSkill
	if self.Owner:IsNPC() then
		handlingSkill = 5
	else
		handlingSkill = self.Owner:GetSkill("Weapon Handling")
	end
	
	if self.Weapon:GetDTBool(1) or self.Owner:IsNPC() then
		if !self.Owner:IsNPC() then
			self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil - (0.06 * handlingSkill)), math.Rand(-1,1) * ((self.Primary.Recoil - (0.06 * handlingSkill)) / 2), 0))
		end
		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, (self.Primary.Cone - (0.001 * handlingSkill)) / 2, (self.Primary.Recoil - (0.06 * handlingSkill)) / 2 )
	else
		self.Owner:ViewPunch(Angle(math.Rand(-0.5,-2.5) * (self.Primary.Recoil - (0.06 * handlingSkill)), math.Rand(-1,1) * (self.Primary.Recoil - (0.06 * handlingSkill)), 0))
		self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, (self.Primary.Cone - (0.001 * handlingSkill)), (self.Primary.Recoil - (0.06 * handlingSkill)) )
	end
end

function SWEP:SecondaryAttack()
	if self.Owner:IsNPC() then return end
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
			self.Owner:SetFOV( 65, 0.15 )
		else
			self.Owner:SetFOV( 0, 0.15 )
		end
	end
	self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:Reload()
	if self.Owner:IsNPC() then return end
	if self.Weapon:Clip1() < self.Primary.ClipSize and self.Owner:GetAmmoCount(self.Weapon:GetPrimaryAmmoType()) > 0 then
		self.Weapon:SetDTBool(1, false)
		self.Owner:SetFOV( 0, 0.15 )
		
		-- self.Weapon:SetNextPrimaryFire(CurTime() + 1.5)
		-- self.Weapon:SetNextSecondaryFire(CurTime() + 1.5)
	
		self.Weapon:DefaultReload(ACT_VM_RELOAD) 
		self.Weapon:EmitSound("Weapon_AR2.Reload")
		
	end
end

function SWEP:Deploy()

	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:SetDTBool(0, false)
	self.Weapon:SetDTBool(1, false)

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

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		if not self.Owner:IsNPC() then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
			end
		end
	end
	
	return true
end

-- Ironsights code, based on CSS Realistic
local IRONSIGHT_TIME = 0.15

function SWEP:GetViewModelPosition(pos, ang)
	
	if self.Weapon:GetDTBool(0) or self.Owner:KeyDown( IN_SPEED ) then
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
	bullet.Tracer	= 1	-- Show a tracer on every x bullets 
        bullet.TracerName = "AR2Tracer" -- what Tracer Effect should be used
	bullet.Force	= 1	-- Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = "ar2"
	
	if self.Owner:IsNPC() then
		self.Owner:FireBullets( bullet )
	else
		if SERVER and not self.Owner:IsNPC() then self.Owner:LagCompensation( true ) end
			self.Owner:FireBullets( bullet )
		if SERVER and not self.Owner:IsNPC() then self.Owner:LagCompensation( false ) end
	end
	
	self:ShootEffects()
	
	if ((game.SinglePlayer() and SERVER) or (not game.SinglePlayer() and CLIENT)) then
		if not self.Owner:IsNPC() then
			local eyeang = self.Owner:EyeAngles()
			eyeang.pitch = eyeang.pitch - recoil
			self.Owner:SetEyeAngles(eyeang)
		end
	end
	
end

function SWEP:ShootEffects()
 
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )	-- View model animation
	self.Owner:MuzzleFlash()				-- Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )		-- 3rd Person Animation
 
end

if CLIENT then
	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()
		if self.Owner:IsNPC() then return end
		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end
		
		if (!self.VElements) then return end
		
		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then
			
			// we build a render order because sprites need to be drawn after models
			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.vRenderOrder, k)
				end
			end
			
		end

		for k, name in ipairs( self.vRenderOrder ) do
		
			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (!v.bone) then continue end
			
			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )
			
			if (!pos) then continue end
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
		
		end
		
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" and v.draw_func) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, v.size)
					v.draw_func( self )
				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end
