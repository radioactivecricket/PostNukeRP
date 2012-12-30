local ITEM = {}


ITEM.ID = "tool_batteryconductor"

ITEM.Name = "Battery Conductor"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 50
ITEM.Small_Parts = 40
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = "A charger for high-capacity batteries."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_batteryconductor"
ITEM.Model = "models/props_lab/incubatorplug.mdl"
ITEM.Script = ""
ITEM.Weight = 1

function ITEM.ToolCheck( p )
	-- This one returns required items.
	--return {["intm_hudint"]=1, ["intm_elecboard"]=2, ["intm_servo"]=1}
	return true
end

function ITEM.Create( ply, class, pos )	
	local ent = ents.Create(class)
	ent:SetAngles(ply:GetAngles())
	ent:SetPos(pos + Vector(0,0,20))
	ent:Spawn()
	ent:Activate()
	
	PNRP.SetOwner(ply, ent)
	
	PNRP.AddWorldCache( ply,ITEM.ID )
end


function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)