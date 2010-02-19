local ITEM = {}


ITEM.ID = "ammo_pistol"

ITEM.Name = "Pistol Ammo"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 5
ITEM.Small_Parts = 0
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "ammo"
ITEM.Remove = true
ITEM.Energy = 20
ITEM.Ent = "ammo_pistol"
ITEM.Model = "models/items/boxsrounds.mdl"
ITEM.Script = ""
ITEM.Weight = 2

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


