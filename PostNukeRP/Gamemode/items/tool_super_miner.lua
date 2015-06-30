local ITEM = {}


ITEM.ID = "tool_super_miner"

ITEM.Name = "Automated Super Sonic Miner"
ITEM.ClassSpawn = "Scavenger"
ITEM.Scrap = 500
ITEM.Small_Parts = 400
ITEM.Chemicals = 250
ITEM.Chance = 100
ITEM.Info = "Forget the antlion headache, bring on the migrane.."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_super_miner"
ITEM.Model = "models/props_combine/combinethumper001a.mdl"
ITEM.Script = ""
ITEM.Weight = 40
ITEM.SaveState = true

function ITEM.BuildState( ent )
	local toolHP = 300
	if( IsValid(ent) ) then toolHP = ent:Health() end
	
	return "HP="..toolHP
end

function ITEM.ToolCheck( p )
	-- This one returns required items.
	return {["intm_sensorpod"]=1, ["intm_elecboard"]=3, ["intm_servo"]=4}
end

function ITEM.Create( ply, class, pos, iid )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	
	if ITEM.SaveState then
		PNRP.BuildPersistantItem(ply, ent, iid)
	end
	
	PNRP.SetOwner(ply, ent)
	
	PNRP.AddWorldCache( ply,ITEM.ID )
end


function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)