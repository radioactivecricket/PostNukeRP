local ITEM = {}


ITEM.ID = "tool_relay"

ITEM.Name = "Power Relay"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 50
ITEM.Small_Parts = 20
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "A power relay to extend cable distance."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_relay"
ITEM.Model = "models/props_c17/substation_transformer01d.mdl"
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