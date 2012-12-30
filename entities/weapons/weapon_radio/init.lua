
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
	
	umsg.Start("radiofreq_recieve", ply)
		umsg.String(frequency)
	umsg.End()
end
--datastream.Hook( "setfreq_stream", SetPlyFreqSWEP )
net.Receive( "setfreq_stream", SetPlyFreqSWEP )
