
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

local function SetPlyFreqSWEP( )
	local ply = net.ReadEntity()
	local frequency = net.ReadString()
	if string.len(frequency) > 6 then frequency = string.sub(frequency, 1, 6) end
	if string.len(frequency) < 4 then frequency = frequency + ".00" end
	if string.len(frequency) < 6 then frequency = frequency + "0" end
	
	ply.Channel = frequency
	
	ply:ChatPrint("Radio frequency now set to "..frequency..".")
	
	net.Start("radiofreq_recieve")
		net.WriteString(frequency)
	net.Send(ply)
end
util.AddNetworkString("radiofreq_recieve")
util.AddNetworkString("radiofreq_select")
util.AddNetworkString("radiopower_select")
util.AddNetworkString("setfreq_stream")
net.Receive( "setfreq_stream", SetPlyFreqSWEP )

