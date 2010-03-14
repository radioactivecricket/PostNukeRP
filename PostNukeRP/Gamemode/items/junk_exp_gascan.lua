local ITEM = {}


ITEM.ID = "exp_gascan"

ITEM.Name = "Explosive Gas Can"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 2
ITEM.Small_Parts = 0
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = "Big Bada Boom!"
ITEM.Type = "junk"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "prop_physics"
ITEM.Model = "models/props_junk/gascan001a.mdl"
ITEM.Script = ""
ITEM.Weight = 4

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


