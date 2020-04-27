
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
--Moved this here
--Was causing errors client side.
util.AddNetworkString( "manageDoor" )

function StartKeysMenu(len, ply)
	local ent = net.ReadEntity()
	
	local doorowner = ent:GetNetVar( "ownerent", nil )
	if doorowner == nil then return end
	if !doorowner:IsValid() then
		ply:ConCommand("pnrp_setOwner")
	elseif doorowner == ply then
		--Open Door Management
		net.Start("manageDoor")
			net.WriteEntity(ent)
			net.WriteTable(ent.Coowners or {})
		net.Send(ply)
	else
		ply:ChatPrint("You don't have this key.")
	end
end
net.Receive("pnrp_StartKeysMenu", StartKeysMenu)
util.AddNetworkString( "pnrp_StartKeysMenu" )
