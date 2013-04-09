AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()

	self.Entity:SetModel("models/items/ar2_grenade.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(false)
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.Entity:EmitSound("Weapon_FlareGun.Burn")
	
	self.Timer = CurTime() + 1
	self.RepeatTimer = CurTime() + 0.5
	self.EndTimer = CurTime() + 4

	self.Entity:SetNWBool("Smoke", true)
	self.Entity:SetNWBool("Lit", false)
	self.Entity.Explode = false
end

/*---------------------------------------------------------
   Name: ENT:Think()
---------------------------------------------------------*/
function ENT:Think()

	if self.RepeatTimer < CurTime() then
		local effectdata = EffectData()
			effectdata:SetOrigin(self.Entity:GetPos())
		util.Effect("effect_flare", effectdata)
	end

	if self.Timer < CurTime() then
		self:Explosion()
		local effectdata = EffectData()
			effectdata:SetOrigin(self.Entity:GetPos())
		util.Effect("effect_flare_explode", effectdata)
		self.Entity:SetNWBool("Smoke", false)
		self.Entity:SetNWBool("Lit", true)
		self.Timer = CurTime() + 5
	end
	
	if self.EndTimer < CurTime() then
		local effectdata = EffectData()
			effectdata:SetOrigin(self.Entity:GetPos())
		util.Effect("effect_flare_final", effectdata)
		self:GetPhysicsObject():EnableMotion(false)
		self.moveActive = false
		self.EndTimer = CurTime() + 20
		timer.Simple( 10, function ()
				self:Remove()
			end )
	end

	if self.Entity:WaterLevel() > 2 then
		self.Entity:Remove()
	end
end

/*---------------------------------------------------------
   Name: ENT:Explosion()
---------------------------------------------------------*/
function ENT:Explosion()
	local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
	util.Effect("effect_flare_explode", effectdata)
	
	self.Entity.Explode = true
end

/*---------------------------------------------------------
   Name: ENT:OnRemove()
---------------------------------------------------------*/
function ENT:OnRemove()

	self.Entity:StopSound("Weapon_FlareGun.Burn")
end