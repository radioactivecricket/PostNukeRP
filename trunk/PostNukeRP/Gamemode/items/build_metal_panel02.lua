local ITEM = {}


ITEM.ID = "metal_panel02"

ITEM.Name = "Tin Panel Small"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 4
ITEM.Small_Parts = 0
ITEM.Chemicals = 0
ITEM.Chance = 100
ITEM.Info = "Small Tin Panel"
ITEM.Type = "build"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "prop_physics"
ITEM.Model = "models/props_debris/metal_panel02a.mdl"
ITEM.Script = ""
ITEM.Weight = 3

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


