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
	 
	for _, item in pairs(PNRP.Items) do
		if self.Item == item.Ent then
			self.Entity:SetNWString("itemname", item.Name)
			self.Entity:SetNWInt("ammoamount", item.Energy)
			break
		end
	end
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		if activator:KeyPressed( IN_USE ) then
			if self.Amount > 0 then
				local ent = ents.Create(self.Item)
				ent:SetAngles(Angle(0,0,0))
				ent:SetPos(self:GetPos()+Vector(0,0,30))
				ent:SetNetworkedString("Ammo", tostring(self:GetNWInt("ammoamount", 0)))
				ent:Spawn()
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
