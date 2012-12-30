
include('shared.lua')

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

/*---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------*/
function SWEP:ShouldDropOnDie()
	return false
end

util.AddNetworkString("Turret_Whitelist")
util.AddNetworkString("Turret_AddTrg")
util.AddNetworkString("Turret_RemTrg")
util.AddNetworkString("Turret_ClearTrg")
util.AddNetworkString("turretprog_menu")

function SWEP.ToggleWhitelist(len, ply)
	local turretEnt = net.ReadEntity()
	
	local plUID = PNRP:GetUID( ply )
	local ownerUID = turretEnt:GetNWString( "Owner_UID", "None" )
	local canProg = false
	
	
	if ownerUID == plUID then canProg = true end
	if turretEnt.GetPlayer and type(turretEnt.GetPlayer) == "function" then
		if ply == turretEnt:GetPlayer() then canProg = true end
	end
	
	if not canProg then
		local ownerEnt = turretEnt:GetNWEntity( "ownerent", nil )
		if turretEnt.GetPlayer and type(turretEnt.GetPlayer) == "function" and not ownerEnt then
			ownerEnt = turretEnt:GetPlayer() or nil
		end
		if ownerEnt then
			if ownerEnt.PropBuddyList then
				if ownerEnt.PropBuddyList[PNRP:GetUID( ply )] then
					canProg = true
				end
			end
		end
	end
	
	if canProg then
		turretEnt.Whitelist = !turretEnt.Whitelist
		
		if turretEnt.NetworkContainer and IsValid(turretEnt.NetworkContainer) then
			turretEnt.NetworkContainer:UpdatePower()
		end
	end
end
net.Receive( "Turret_Whitelist", SWEP.ToggleWhitelist )

function SWEP.TurretAddTarget(len, ply)
	local turretEnt = net.ReadEntity()
	local trgEnt = net.ReadEntity()
	
	local plUID = PNRP:GetUID( ply )
	local ownerUID = turretEnt:GetNWString( "Owner_UID", "None" )
	local canProg = false
	
	
	if ownerUID == plUID then canProg = true end
	if turretEnt.GetPlayer and type(turretEnt.GetPlayer) == "function" then
		if ply == turretEnt:GetPlayer() then canProg = true end
	end
	
	if not canProg then
		local ownerEnt = turretEnt:GetNWEntity( "ownerent", nil )
		if turretEnt.GetPlayer and type(turretEnt.GetPlayer) == "function" and not ownerEnt then
			ownerEnt = turretEnt:GetPlayer() or nil
		end
		if ownerEnt then
			if ownerEnt.PropBuddyList then
				if ownerEnt.PropBuddyList[PNRP:GetUID( ply )] then
					canProg = true
				end
			end
		end
	end
	
	if canProg then
		table.insert(turretEnt.ProgTable, trgEnt)
		
		if turretEnt.NetworkContainer and IsValid(turretEnt.NetworkContainer) then
			turretEnt.NetworkContainer:UpdatePower()
		end
	end
end
net.Receive( "Turret_AddTrg", SWEP.TurretAddTarget )

function SWEP.TurretRemTarget(len, ply)
	local turretEnt = net.ReadEntity()
	local trgEnt = net.ReadEntity()
	
	local plUID = PNRP:GetUID( ply )
	local ownerUID = turretEnt:GetNWString( "Owner_UID", "None" )
	local canProg = false
	
	
	if ownerUID == plUID then canProg = true end
	if turretEnt.GetPlayer and type(turretEnt.GetPlayer) == "function" then
		if ply == turretEnt:GetPlayer() then canProg = true end
	end
	
	if not canProg then
		local ownerEnt = turretEnt:GetNWEntity( "ownerent", nil )
		if turretEnt.GetPlayer and type(turretEnt.GetPlayer) == "function" and not ownerEnt then
			ownerEnt = turretEnt:GetPlayer() or nil
		end
		if ownerEnt then
			if ownerEnt.PropBuddyList then
				if ownerEnt.PropBuddyList[PNRP:GetUID( ply )] then
					canProg = true
				end
			end
		end
	end
	
	if canProg then
		for k, v in pairs(turretEnt.ProgTable) do
			if v == trgEnt then
				table.remove(turretEnt.ProgTable, k)
			end
		end
		
		if turretEnt.NetworkContainer and IsValid(turretEnt.NetworkContainer) then
			turretEnt.NetworkContainer:UpdatePower()
		end
	end
end
net.Receive( "Turret_RemTrg", SWEP.TurretRemTarget )

function SWEP.TurretClearTarget(len, ply)
	local turretEnt = net.ReadEntity()
	
	local plUID = PNRP:GetUID( ply )
	local ownerUID = turretEnt:GetNWString( "Owner_UID", "None" )
	local canProg = false
	
	
	if ownerUID == plUID then canProg = true end
	if turretEnt.GetPlayer and type(turretEnt.GetPlayer) == "function" then
		if ply == turretEnt:GetPlayer() then canProg = true end
	end
	
	if not canProg then
		local ownerEnt = turretEnt:GetNWEntity( "ownerent", nil )
		if turretEnt.GetPlayer and type(turretEnt.GetPlayer) == "function" and not ownerEnt then
			ownerEnt = turretEnt:GetPlayer() or nil
		end
		if ownerEnt then
			if ownerEnt.PropBuddyList then
				if ownerEnt.PropBuddyList[PNRP:GetUID( ply )] then
					canProg = true
				end
			end
		end
	end
	
	if canProg then
		turretEnt.ProgTable = {}
		
		if turretEnt.NetworkContainer and IsValid(turretEnt.NetworkContainer) then
			turretEnt.NetworkContainer:UpdatePower()
		end
	end
end
net.Receive( "Turret_ClearTrg", SWEP.TurretClearTarget )
