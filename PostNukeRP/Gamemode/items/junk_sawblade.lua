local ITEM = {}


ITEM.ID = "sawblade"

ITEM.Name = "Sawblade"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 10
ITEM.Small_Parts = 0
ITEM.Chemicals = 0
ITEM.Chance = 100
ITEM.Info = "Fire off with a Grav Gun and see the carnage."
ITEM.Type = "junk"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "prop_physics"
ITEM.Model = "models/props_junk/sawblade001a.mdl"
ITEM.Script = ""
ITEM.Weight = 7

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Use( ply )
	return true	
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetModel(ITEM.Model)
	ent:SetPos(pos)
	ent:Spawn()
end

PNRP.AddItem(ITEM)


