local ITEM = {}


ITEM.ID = "tool_hopper"

ITEM.Name = "Item Hopper"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 150
ITEM.Small_Parts = 100
ITEM.Chemicals = 20
ITEM.Chance = 100
ITEM.Info = "Grabs and stores, hell if we know where the items go..."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_hopper"
ITEM.Model = "models/props_wasteland/laundry_cart002.mdl"
ITEM.Script = ""
ITEM.Weight = 10

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Create( ply, class, pos )	
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()

	PNRP.SetOwner(ply, ent)
	
	PNRP.AddWorldCache( ply,ITEM.ID,ent )
end


function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)