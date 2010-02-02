local ITEM = {}


ITEM.ID = "box_buckshot"

ITEM.Name = "Shotgun Ammo"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 10
ITEM.Small_Parts = 0
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "ammo"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "ammo_shotgun"
ITEM.Model = "models/items/boxbuckshot.mdl"
ITEM.Script = ""
ITEM.Weight = 2

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


