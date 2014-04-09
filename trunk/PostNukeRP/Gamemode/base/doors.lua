-- Everything below is a shameless copy and paste.  God knows how well it'll work after integration.


--require("datastream")

SK_Srv = {}

--AddCSLuaFile("autorun/client/simplekeys_cl.lua")

util.AddNetworkString("SKRemAllCoowner")
util.AddNetworkString("SKAddCoowner")
util.AddNetworkString("SKRemCoowner")

local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")
------------------------------------------------
--	Spawns and Disconnects
------------------------------------------------
-- function SK_Srv.Init( ply )
	-- ply:Give("weapon_simplekeys")
-- end
-- hook.Add( "PlayerSpawn", "keysInit", SK_Srv.Init )

function SK_Srv.OnDisc_Doors( ply )
	for k, v in pairs(ents.GetAll()) do
		if v:IsDoor() and v:GetNWEntity( "ownerent" ) == ply then
			v:SKRemoveOwner()
			if v.Coowners and v.Coowners[1] then
				local topCoowner = v.Coowners[1]
				v:SKRemoveCoowner( topCoowner )
				v:SKSetOwner( topCoowner )
				
				topCoowner:ChatPrint( ply:GetName().." has released an item and you have been made the owner." )
			end
		end
	end
end
-- hook.Add( "PlayerDisconnected", "SKPlyDisc", SK_Srv.OnDisc_Doors )

------------------------------------------------
--	Door Protections
------------------------------------------------
-- function SK_Srv.PickupCheck( ply, ent )
	-- if ent:IsDoor() then return false end
-- end
-- hook.Add( "PhysgunPickup", "SKpickupCheck", SK_Srv.PickupCheck )

--Entity Functions (Mostly ownership functions)
function EntityMeta:SKSetOwner( ply )		
	local plUID = PNRP:GetUID( ply )
	self:SetNWEntity( "ownerent", ply )
	self:SetNWString("Owner", ply:Nick())
	self:SetNetworkedString("Owner_UID", plUID)
end

function EntityMeta:SKRemoveOwner( ply )
	self:SetNWEntity( "ownerent", nil )
end

function EntityMeta:SKSetCoowner( ply )
	if self.Coowners then
		for _, v in pairs(player.GetAll()) do
			if v == ply then
				table.insert(self.Coowners, ply)
				return true
			end
		end
		return false
	else
		self.Coowners = {}
		
		for _, v in pairs(player.GetAll()) do
			if v == ply then
				table.insert(self.Coowners, ply)
				return true
			end
		end
		return false
	end
end

function EntityMeta:SKRemoveCoowner( ply )
	if self.Coowners then
		for k, v in pairs(self.Coowners) do
			if v == ply then
				table.remove(self.Coowners, k)
				return true
			end
		end
	else
		return false
	end
end

function EntityMeta:SKRemoveCoowners()
	self.Coowners = {}
end

function EntityMeta:SKRemoveOwners()
	self:SetNWEntity( "ownerent", nil )
	self.Coowners = {}
end

function EntityMeta:SKHasOwner()
	local myowner = self:GetNWEntity( "ownerent", nil )
	
	if IsValid(myowner) then
		return true
	else
		return false
	end
end

function PlayerMeta:SKIsOwner( ent )
	local doorowner = ent:GetNWEntity( "ownerent", nil )
	
	if self == doorowner then
		return true
	else
		return false
	end
	return false --To make sure, just in case.
end

function PlayerMeta:SKIsCoowner( ent )
	if ent.Coowners then
		for _, v in pairs( ent.Coowners ) do
			if v == self then
				return true
			end
		end
		return false
	else
		return false
	end
	return false --To make sure, just in case.
end

----------------------------------------------------
--	Net Hooks [Used to be Datastreams]
----------------------------------------------------

--	SKReleaseOwner
function SK_Srv.ReleaseOwner( ply, doorEnt )	
	if ply:SKIsOwner( doorEnt ) then
		doorEnt:SKRemoveOwner()
		ply:ChatPrint("You have released ownership of this.")
		if doorEnt.Coowners and doorEnt.Coowners[1] then
			local topCoowner = doorEnt.Coowners[1]
			doorEnt:SKRemoveCoowner( topCoowner )
			doorEnt:SKSetOwner( topCoowner )
			
			
			topCoowner:ChatPrint("The previous owner has released an item and you have been made owner.")
			topCoowner:ChatPrint( ply:GetName().." has released an item and you have been made the owner." )
		end
	end
end

function SK_Srv.RelOwnerNet()
	local ply = net.ReadEntity()
	local doorEnt = net.ReadEntity()
	
	SK_Srv.ReleaseOwner( ply, doorEnt )
end
--datastream.Hook( "SKReleaseOwner", SK_Srv.ReleaseOwner )
net.Receive( "SKReleaseOwner", SK_Srv.ReleaseOwner )

--SKAddCoowner
function SK_Srv.AddCoowner( )
	local ply = net.ReadEntity()
	local doorEnt = net.ReadEntity()
	local newCoowner = net.ReadEntity()
	--local doorEnt = decoded.doorEnt
	--local newCoowner = decoded.newCoowner
	
	if ply:SKIsOwner( doorEnt ) then
		if doorEnt:SKSetCoowner( newCoowner ) then
			ply:ChatPrint( newCoowner:GetName().." is now a co-owner of this item." )
			newCoowner:ChatPrint( ply:GetName().." has set you as a co-owner to one of their items." )
		else
			ply:ChatPrint( "ERROR: Can't find player. (Are they still on the server?)" )
		end
	end
end
--datastream.Hook( "SKAddCoowner", SK_Srv.AddCoowner )
net.Receive( "SKAddCoowner", SK_Srv.AddCoowner )

--SKRemCoowner
function SK_Srv.RemCoowner( )
	local ply = net.ReadEntity()
	local doorEnt = net.ReadEntity()
	local coowner = net.ReadEntity()
--	local doorEnt = decoded.doorEnt
--	local coowner = decoded.coowner
	
	if ply:SKIsOwner( doorEnt ) then
		if doorEnt:SKRemoveCoowner( coowner ) then
			ply:ChatPrint( coowner:GetName().." is no longer a co-owner of this item." )
			coowner:ChatPrint( ply:GetName().." has removed you as a co-owner of one of their items." )
		else
			ply:ChatPrint( "ERROR: Can't find player. (Are they still on the server?)" )
		end
	end
end
--datastream.Hook( "SKRemCoowner", SK_Srv.RemCoowner )
net.Receive( "SKRemCoowner", SK_Srv.RemCoowner )

--SKRemAllCoowner
function SK_Srv.RemAllCoowner( )
	local ply = net.ReadEntity()
	local doorEnt = net.ReadEntity()
	--local doorEnt = decoded.doorEnt
	
	if ply:SKIsOwner( doorEnt ) then
		for k, v in pairs(doorEnt.Coowners) do
			if IsValid(v) and v:IsPlayer() then
				v:ChatPrint( ply:GetName().." has removed you as a co-owner of one of their items." )
			end
		end
		doorEnt:SKRemoveCoowners()
	end
end
--datastream.Hook( "SKRemAllCoowner", SK_Srv.RemAllCoowner )
net.Receive( "SKRemAllCoowner", SK_Srv.RemAllCoowner )

-- Already part of the meta tables.
--Utilities
-- function EntityMeta:IsDoor()
	-- local class = self:GetClass()

	-- if class == "func_door" or
		-- class == "func_door_rotating" or
		-- class == "prop_door_rotating" or
		-- class == "prop_dynamic" then
		-- return true
	-- end
	-- return false
-- end
