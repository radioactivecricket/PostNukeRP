AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/props_junk/cardboard_box003b.mdl")

function ENT:Initialize()
	self.item = self:GetNetVar("itemID")
	self.vendorid = self:GetNetVar("vendorid")
	self.cost = self:GetNetVar("cost")
	self.open = self:GetNetVar("open", "false")
		
	self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		if activator:KeyPressed( IN_USE ) then
			local itemID = self:GetNetVar("itemID")
			local item = PNRP.Items[itemID]
			local vendorID = self.vendorid
			local iid = self:GetNetVar("iid", "")
			if self.open == "true" then
				
				local itemString = getItemInfo(itemID, vendorID)
				net.Start("dispBuyVerify")
					net.WriteEntity(activator)
					net.WriteEntity(self)
					net.WriteString(itemID)
					net.WriteString(itemString)
					net.WriteString(iid)
				net.Send(activator)
				
			else
				if tostring(self:GetNetVar( "Owner_UID" , "None" )) == PNRP:GetUID( activator ) then
					local itemString = getItemInfo(itemID, vendorID, iid)
					
					if itemString == "0,0,0,0" then
						activator:ChatPrint("Unable to find item in vendor.")
						self:Remove()
						return
					end
					
					local model = item.Model
					local skin = 0
					if iid ~= "" then
						local status = PNRP.ReturnState(iid)
						if status ~= "" then
							local newModel = PNRP.GetFromStat(status, "Model")
							local newSkin = PNRP.GetFromStat(status, "Skin")
							if newModel then model = newModel end
							if newSkin then skin = tonumber(newSkin) end
						end
					end
					
					self:boxRespawn( activator, model, skin)
					
					self.open = "true"
					self:SetNetVar("open", "true")
					
					local render = {}
					render["mode"] = 1
					render["color"] = Color( 200, 200, 255, 100 )
					render["fx"] = 16			
					
					self.cost = itemString
					self:SetNetVar("cost", itemString)
				else
					activator:ChatPrint("You do not own this.")
				end
			end
			
			
		end
	end
end
util.AddNetworkString("dispBuyVerify")

function BuyFromVendorDisp( )
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	local item = PNRP.Items[net.ReadString()]
	local amount = tonumber(net.ReadString())
	
	local vendorID = ent.vendorid
	local iid = ent:GetNetVar("iid", "")
	local itemString = getItemInfo(item.ID, vendorID, iid)
	
	if itemString == "0,0,0,0" then
		ply:ChatPrint("Unable to find item in vendor.")
		ent:Remove()
		return
	end
	
	local itemInfo = string.Explode( ",", itemString )
	itemInfo["count"] = itemInfo[1]
	itemInfo["scrap"] = itemInfo[2]
	itemInfo["sp"] = itemInfo[3]
	itemInfo["chems"] = itemInfo[4]
	
	local Cost = {itemInfo["scrap"], itemInfo["sp"], itemInfo["chems"]}
	
	local itemSold = BuyFromVendor(ply, vendorID, item.ID, Cost, amount, "dispItem", iid )
	if itemSold then
		itemInfo["count"] = itemInfo["count"] - 1
	else
		--If no item sold then dont continue
		return
	end
	
	local foundDispItems = ents.FindByClass(ent:GetClass())
	local idCount = 0
	for _, v in pairs(foundDispItems) do
		if v.vendorid == vendorID and v.item == item.ID and v.iid == iid then
			if itemInfo["count"] == 0 then
				v:Remove()
			else
				idCount = idCount + 1
			end
		end
	end
	
	local itmCount = 0
	local itemString = string.Explode( ",", getItemInfo(item.ID, vendorID))
	itmCount = itemString[1]
	
	if idCount > (itemInfo["count"] - 1) then
		ent:Remove()
		if (idCount - itmCount) > 1 then
			checkRMDispItems(ply, item.ID, vendorID)
		end
	end
end
net.Receive( "BuyFromVendorDisp", BuyFromVendorDisp )
util.AddNetworkString("BuyFromVendorDisp")

function ENT:boxRespawn( ply, model, skin )
	local iid = self:GetNetVar("iid", "")
	local status = self:GetNetVar("status", "")
	local oldRad = self:GetCollisionBounds()
	if not skin then skin = 0 end
	self:SetModel(model)
	self:SetSkin(skin)
	local newRad = self:GetCollisionBounds()
	local setRad = oldRad - newRad
	local pos = self:GetPos()
	self:SetPos(pos + setRad + Vector(0,0,15))
	self:SetAngles( ply:GetAngles()-Angle(0,180,0) )
	self:Spawn()
	self:Activate()
	self:GetPhysicsObject():Wake()

	if self.open != true then
		local render = {}
		render["mode"] = 0
		render["color"] = Color( 255, 255, 255, 255 )
		render["fx"] = 0			
		
	--	self:SetColor( render["color"] )
	--	self:SetRenderMode( render["mode"] ) 
	--	self:SetRenderFX( render["fx"] )
	end
end

function ENT:F2Use(ply)
	if tostring(self:GetNetVar( "Owner_UID" , "None" )) == PNRP:GetUID( ply ) then
		local model = "models/props_junk/cardboard_box003b.mdl"

		self:boxRespawn( ply, model )
					
		self.open = "false"
		self:SetNetVar("open", "false")
	else
		ply:ChatPrint("You do not own this.")
	end
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end