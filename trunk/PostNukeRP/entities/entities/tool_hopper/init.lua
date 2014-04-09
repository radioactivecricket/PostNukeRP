AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')


util.PrecacheModel ("models/props_wasteland/laundry_cart002.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props_wasteland/laundry_cart002.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox

	self.pid = self.Entity:GetNWString("Owner_UID")
	self.entOwner = "none"
	
	self.inv = { }
	self.catch = {  "food_orange",
					"msc_scrapnug",
					"msc_smallnug",
					"msc_chemnug",}
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		if activator:KeyPressed( IN_USE ) then
		--Does not check for owner, adds some risk
		--	for itm, val in pairs(self.inv) do
		--		activator:ChatPrint(itm..": "..val)
		--	end
			
			net.Start("hopper_menu")
				net.WriteEntity(self)
				net.WriteTable(self.inv)
			net.Send(activator)
		end
	end
end
util.AddNetworkString("hopper_menu")

function ENT:Touch( hitEnt )

	if ( hitEnt:IsValid() && hitEnt.checkedEnt != true ) then
		hitEnt.checkedEnt = true;  --Stops it from spamming the check
		for _, class in pairs(self.catch) do
			if tostring(hitEnt:GetClass()) == class then
				if !self.inv[class] then self.inv[class] = 0 end
				self.inv[class] = self.inv[class] + 1
				hitEnt:Remove()
			end
		end
	end
	
 end
 
function ENT:TakeAllHopper()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	for itm, val in pairs(ent.inv) do
		if itm == "msc_scrapnug" then
			if ply then
				ply:IncResource( "Scrap", val )
				ent.inv[itm] = ent.inv[itm] - val
			end
		elseif itm == "msc_smallnug" then
			if ply then
				ply:IncResource( "Small_Parts", val )
				ent.inv[itm] = ent.inv[itm] - val
			end
		elseif itm == "msc_chemnug" then
			if ply then
				ply:IncResource( "Chemicals", val )
				ent.inv[itm] = ent.inv[itm] - val
			end
		end
	end
end
 net.Receive( "takeall_hopper", ENT.TakeAllHopper )
 util.AddNetworkString("takeall_hopper")
 
 function ENT:DropAllHopper()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	local pos = ent:GetPos()
	
	for itemID, val in pairs(ent.inv) do
		local Item = PNRP.Items[itemID]local Item = PNRP.Items[itemID]
		if Item then
			if val > 0 then
				PNRP.DropCrate( itemID, val, pos )
				ent:EmitSound(Sound("items/ammo_pickup.wav"))
				ent.inv[itemID] = ent.inv[itemID] - val
			end
		end
	end
	
end
 net.Receive( "dropall_hopper", ENT.DropAllHopper )
 util.AddNetworkString("dropall_hopper")
 
function ENT:TakeResHopper()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	local itm = net.ReadString()
	local count = net.ReadDouble()
	
	if count < 1 then count = 1 end
	if count > ent.inv[itm] then count = ent.inv[itm] end

	if count > 0 then
		if itm == "msc_scrapnug" then
			if ply then
				ply:IncResource( "Scrap", count )
				ent.inv[itm] = ent.inv[itm] - count
			end
		elseif itm == "msc_smallnug" then
			if ply then
				ply:IncResource( "Small_Parts", count )
				ent.inv[itm] = ent.inv[itm] - count
			end
		elseif itm == "msc_chemnug" then
			if ply then
				ply:IncResource( "Chemicals", count )
				ent.inv[itm] = ent.inv[itm] - count
			end
		end
	end
	
end
 net.Receive( "takeres_hopper", ENT.TakeResHopper )
 util.AddNetworkString("takeres_hopper")
 
 function ENT:DropItemHopper()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	local itemID = net.ReadString()
	local count = net.ReadDouble()
	
	if count < 1 then count = 1 end
	if count > ent.inv[itemID] then count = ent.inv[itemID] end
	
	if count > 0 then
		local Item = PNRP.Items[itemID]local Item = PNRP.Items[itemID]
		if Item then
			local pos = ent:GetPos()
			PNRP.DropCrate( itemID, count, pos )
			ent.inv[itemID] = ent.inv[itemID] - count
		end
	end
end
 net.Receive( "dropitem_hopper", ENT.DropItemHopper )
 util.AddNetworkString("dropitem_hopper")
 
function ENT:OnRemove()
	local pos = self:GetPos() - Vector(0,0,15)
	local plyList = player.GetAll()
	local ply = nil
	local pid = self:GetNWString("Owner_UID")
	
	for _, pent in pairs(plyList) do
		if pent and IsValid(pent) then
			if tostring(pid) == tostring(PNRP:GetUID( pent )) then
				ply = pent
			end
		end
	end
	if IsValid(ply) then
		for itm, val in pairs(self.inv) do
			if itm == "msc_scrapnug" then
				if ply then
					ply:IncResource( "Scrap", val )
				end
			elseif itm == "msc_smallnug" then
				if ply then
					ply:IncResource( "Small_Parts", val )
				end
			elseif itm == "msc_chemnug" then
				if ply then
					ply:IncResource( "Chemicals", val )
				end
			else 
				PNRP.DropCrate( itm, val, pos )
				pos = pos + Vector(0,0,10)
			end
		end
	end
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end