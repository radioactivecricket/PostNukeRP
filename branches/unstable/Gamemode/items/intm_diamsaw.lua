local ITEM = {}


ITEM.ID = "intm_diamsaw"

ITEM.Name = "Diamond-edge Saw"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 5
ITEM.Small_Parts = 20
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = "A diamond-edged saw, able to cut through most metals."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_diamsaw"
ITEM.Model = "models/props_forest/circularsaw01.mdl"
ITEM.Script = ""
ITEM.Weight = 1
ITEM.ShopHide = true

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)