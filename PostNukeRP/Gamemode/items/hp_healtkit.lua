local ITEM = {}


ITEM.ID = "healthkit"

ITEM.Name = "Health Kit"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 10
ITEM.Small_Parts = 0
ITEM.Chemicals = 20
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "medical"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "hp_healthkit"
ITEM.Model = "models/items/healthkit.mdl"
ITEM.Script = ""
ITEM.Weight = 4

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


