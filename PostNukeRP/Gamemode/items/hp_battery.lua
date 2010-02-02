local ITEM = {}


ITEM.ID = "battery"

ITEM.Name = "Armor Battery"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 20
ITEM.Small_Parts = 0
ITEM.Chemicals = 50
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "medical"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "hp_battery"
ITEM.Model = "models/items/battery.mdl"
ITEM.Script = ""
ITEM.Weight = 2

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


