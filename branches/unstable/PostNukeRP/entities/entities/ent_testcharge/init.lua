AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

/*---------------------------------------------------------
   Name: ENT:Initialize()
---------------------------------------------------------*/
function ENT:Initialize()

	self.Owner = self.Entity.Owner

	if not self.Owner:IsValid() then
		self:Remove()
		return
	end

	self.Entity:SetModel("models/weapons/w_slam.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(false)

	self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
	
	local phys = self.Entity:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
	end

	self.Entity:EmitSound("C4.Plant")
end

/*---------------------------------------------------------
   Name: ENT:Think()
---------------------------------------------------------*/
function ENT:Think()
end

/*---------------------------------------------------------
   Name: ENT:Explosion()
---------------------------------------------------------*/
function ENT:Explosion()

	local doorent = self.Entity:GetNWEntity("door", nil)
	if doorent:IsValid() and (doorent:GetClass() == "prop_door_rotating" or doorent:GetClass() == "func_door_rotating" or doorent:GetClass() == "func_door") then
		doorent:Fire("unlock", "", 0.1)
		doorent:Fire("open", "", 0.1)

		local pos = doorent:GetPos()
		local ang = doorent:GetAngles()
		local model = doorent:GetModel()
		local skin = doorent:GetSkin()

		doorent:SetNotSolid(true)
		if doorent:GetClass() == "prop_door_rotating" then
			doorent:SetNoDraw(true)
		end

		local function ResetDoor(door, fakedoor)
			door:SetNotSolid(false)
			door:SetNoDraw(false)
			if door:GetClass() == "prop_door_rotating" then
				fakedoor:Remove()
			end
		end

		local norm = pos - (self.Entity:GetPos() + self.Entity:GetRight() * 100 + self.Entity:GetUp() * 400)
		if norm.z < 0 then norm.z = 0 end
		norm:Normalize()

		local push = 40000 * norm
		if doorent:GetClass() == "prop_door_rotating" then
			local ent = ents.Create("prop_physics")

			ent:SetPos(pos)
			ent:SetAngles(ang)
			ent:SetModel(model)

			if(skin) then
				ent:SetSkin(skin)
			end

			ent:Spawn()

			timer.Simple(0.01, function()
					ent:SetVelocity(push)
					ent:GetPhysicsObject():ApplyForceCenter(push)
				end)
			timer.Simple(25, function()
					ResetDoor( doorent, ent)
				end)
		else
			timer.Simple(25, function()
					ResetDoor( doorent, nil)
				end)
		end
	elseif doorent:IsValid() and doorent:GetClass() == "pnrp_antmound" then
		doorent:SetHealth(doorent:Health() - 500)
		doorent:Ignite(10, 0)
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
	util.Effect("HelicopterMegaBomb", effectdata)
	
	local owner = self.Entity:GetNWEntity("ownerent", nil)
	
	if owner:IsValid() then
		local rf = RecipientFilter()
		rf:AddPlayer( owner )
		
		local effectdata = EffectData()
			effectdata:SetOrigin(self.Entity:GetPos())
		util.Effect("HelicopterMegaBomb", effectdata, false, rf )
	end
	
	-- local shake = ents.Create("env_shake")
		-- shake:SetOwner(self.Owner)
		-- shake:SetPos(self.Entity:GetPos())
		-- shake:SetKeyValue("amplitude", "500")	// Power of the shake
		-- shake:SetKeyValue("radius", "500")		// Radius of the shake
		-- shake:SetKeyValue("duration", "2.5")	// Time of shake
		-- shake:SetKeyValue("frequency", "255")	// How har should the screenshake be
		-- shake:SetKeyValue("spawnflags", "4")	// Spawnflags(In Air)
		-- shake:Spawn()
		-- shake:Activate()
		-- shake:Fire("StartShake", "", 0)

	self.Entity:EmitSound("doors/vent_open1.wav")

	self.Entity:Remove()
end

/*---------------------------------------------------------
   Name: ENT:Use()
---------------------------------------------------------*/
function ENT:Use(activator, caller)
	if CLIENT then return end
	if not activator:IsValid() then return end
	
	if activator:HasWeapon("weapon_testcharge") then
		activator:GiveAmmo(1, "slam")
	else
		activator:Give("weapon_testcharge")
	end
	local chargeOwner = self.Entity:GetNWEntity("ownerent", nil)
	
	if chargeOwner:IsValid() then
		local trgWeapon = chargeOwner:GetWeapon("weapon_testcharge")
		
		if trgWeapon then
			if trgWeapon:IsValid() then
				for k, v in pairs(trgWeapon.SetCharges) do
					if v == self.Entity then
						table.remove(trgWeapon.SetCharges, k)
					end
				end
			end
		end
	end
	self.Entity:Remove()
end
