local ITEM = {}


ITEM.ID = "intm_oil"

ITEM.Name = "Oil"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 2
ITEM.Small_Parts = 0
ITEM.Chemicals = 50
ITEM.Chance = 100
ITEM.Info = "Oil."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_oil"
ITEM.Model = "models/props_junk/plasticbucket001a.mdl"
ITEM.Script = ""
ITEM.Weight = 1
ITEM.ShopHide = false

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	
	PNRP.SetOwner(ply, ent)
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)