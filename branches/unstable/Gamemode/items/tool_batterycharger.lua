local ITEM = {}


ITEM.ID = "tool_batterycharger"

ITEM.Name = "Battery Charger"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 100
ITEM.Small_Parts = 50
ITEM.Chemicals = 200
ITEM.Chance = 100
ITEM.Info = "A charger for high-capacity batteries."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_batterycharger"
ITEM.Model = "models/props_lab/tpplugholder_single.mdl"
ITEM.Script = ""
ITEM.Weight = 3

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