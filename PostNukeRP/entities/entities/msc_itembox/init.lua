AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/items/item_item_crate.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/items/item_item_crate.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	self.Item = self.Entity:GetNWString("itemtype")
	self.Amount = self.Entity:GetNWInt("amount")
	self.myItem = {}
	 
	for _, item in pairs(PNRP.Items) do
		if self.Item == item.ID then
			self.Entity:SetNWString("itemname", item.Name)
			self.Entity:SetNWInt("ammoamount", item.Energy)
			self.myItem = item
			break
		end
	end
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		if activator:KeyPressed( IN_USE ) then
			if self.Amount > 0 then
				local ent 
				if self.myItem.Type == "weapon" then
					ent = ents.Create("ent_weapon")
					ent:SetNetworkedString("WepClass", self.myItem.Ent)
					--ent:SetNetworkedInt("Ammo", self:GetNWInt("ammoamount", 0))
					ent:SetNetworkedInt("Ammo", 0)
				else
					ent = ents.Create(self.myItem.Ent)
					ent:SetNetworkedString("Ammo", tostring(self:GetNWInt("ammoamount", 0)))
				end
				
				--ent:SetModel(self.myItem.Model)
				--ent:SetAngles(Angle(0,0,0))
				--ent:SetPos(self:GetPos()+Vector(0,0,30))
				--ent:Spawn()
				local pos = self:GetPos()+Vector(0,0,30) 
				
				self.myItem.Create(activator, self.myItem.Ent, pos)
				
				
				self.Amount = self.Amount - 1
				self.Entity:SetNWInt("amount", self.Amount )
				if self.Amount <= 0 then
					self:Remove()
				end
			else
				self:Remove()
			end
		end
	end
end

function ENT:KeyValue (key, value)
	self[key] = tonumber(value) or value
	self.Entity:SetNWString (key, value)
	print ("["..key.." = "..value.."] ")
end

function ENT:F2Use(ply)
	
	local Item = self.Item
	local Amount = self.Amount
	local weight = PNRP.Items[Item].Weight
	local sumWeight = weight*Amount
	
	local weightCap
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	local weightCalc = PNRP.InventoryWeight( ply ) + sumWeight
	if weightCalc <= weightCap then
		ply:AddToInventory( Item, Amount )
		ply:EmitSound(Sound("items/ammo_pickup.wav"))
		ply:ChatPrint("You have taken all of this.")
		self:Remove()
	else
		local weightDiff = weightCalc - weightCap
		local extra = math.ceil(weightDiff/weight)
		
		if extra >= Amount then
			ply:ChatPrint("You can't carry any of these!")
		else
			local taken = Amount - extra
			
			ply:AddToInventory( Item, taken )
			self.Entity:SetNWInt("amount", Amount - taken )
			self.Amount = Amount - taken
			ply:EmitSound(Sound("items/ammo_pickup.wav"))
			ply:ChatPrint("You were only able to carry "..tostring(taken).." of these!")
		end
	end
end