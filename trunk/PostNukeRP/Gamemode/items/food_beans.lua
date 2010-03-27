local ITEM = {}


ITEM.ID = "food_beans"

ITEM.Name = "Can O' Beans"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 5
ITEM.Small_Parts = 0
ITEM.Chemicals = 2
ITEM.Chance = 100
ITEM.Info = "Beans are a staple of wasteland life."
ITEM.Type = "food"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "food_beans"
ITEM.Model = "models/props_junk/garbage_metalcan001a.mdl"
ITEM.Script = ""
ITEM.Weight = 1

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


