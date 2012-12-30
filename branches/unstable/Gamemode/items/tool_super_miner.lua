local ITEM = {}


ITEM.ID = "tool_super_miner"

ITEM.Name = "Automated Super Sonic Miner"
ITEM.ClassSpawn = "Scavenger"
ITEM.Scrap = 500
ITEM.Small_Parts = 400
ITEM.Chemicals = 250
ITEM.Chance = 100
ITEM.Info = "Forget teh antlion headache, bring on the migrane.."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_super_miner"
ITEM.Model = "models/props_combine/combinethumper001a.mdl"
ITEM.Script = ""
ITEM.Weight = 40

function ITEM.ToolCheck( p )
	-- This one returns required items.
	return {["intm_sensorpod"]=1, ["intm_elecboard"]=3, ["intm_servo"]=4}
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	--ent:SetNetworkedString("Owner", ply:Nick())
	PNRP.SetOwner(ply, ent)
	
	PNRP.AddWorldCache( ply,ITEM.ID )
end


function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)