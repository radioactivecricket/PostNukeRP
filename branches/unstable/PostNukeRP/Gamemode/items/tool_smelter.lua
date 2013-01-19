local ITEM = {}


ITEM.ID = "tool_smelter"

ITEM.Name = "Smelting Furnace"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 200
ITEM.Small_Parts = 75
ITEM.Chemicals = 300
ITEM.Chance = 100
ITEM.Info = "A metal smelting furnace.  Can convert small parts into scrap."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_smelter"
ITEM.Model = "models/props_forest/furnace01.mdl"
ITEM.Script = ""
ITEM.Weight = 20

function ITEM.ToolCheck( p )
	return true
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