local ITEM = {}


ITEM.ID = "intm_seeds"

ITEM.Name = "Genetically Modified Seed"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 2
ITEM.Small_Parts = 0
ITEM.Chemicals = 20
ITEM.Chance = 100
ITEM.Info = "Seeds designed to survive the post apocalypse.  They do!  If only you could make more..."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_seeds"
ITEM.Model = "models/props_lab/box01a.mdl"
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