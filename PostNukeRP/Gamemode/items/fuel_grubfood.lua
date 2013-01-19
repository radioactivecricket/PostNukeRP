local ITEM = {}


ITEM.ID = "fuel_grubfood"

ITEM.Name = "Grub Food"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 10
ITEM.Small_Parts = 10
ITEM.Chemicals = 35
ITEM.Chance = 100
ITEM.Info = "A strange concoction of organic material that the antlions use to feed their young."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "fuel_grubfood"
ITEM.Model = "models/spitball_medium.mdl"
ITEM.Script = ""
ITEM.Weight = 0.1

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Use( ply )
	return false
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
end

PNRP.AddItem(ITEM)


