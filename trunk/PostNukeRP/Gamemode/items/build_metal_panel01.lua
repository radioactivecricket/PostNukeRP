local ITEM = {}


ITEM.ID = "metal_panel01"

ITEM.Name = "Tin Panel"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 5
ITEM.Small_Parts = 0
ITEM.Chemicals = 0
ITEM.Chance = 100
ITEM.Info = "Larg Tin Panel"
ITEM.Type = "build"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "prop_physics"
ITEM.Model = "models/props_debris/metal_panel01a.mdl"
ITEM.Script = ""
ITEM.Weight = 5

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


