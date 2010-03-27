local ITEM = {}


ITEM.ID = "food_soup"

ITEM.Name = "Carton of Soup"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 3
ITEM.Small_Parts = 0
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = "A big carton of soup.  Keeps you healthy!  Needs a saucepan."
ITEM.Type = "food"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "food_soup"
ITEM.Model = "models/props_junk/garbage_milkcarton002a.mdl"
ITEM.Script = ""
ITEM.Weight = 1

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.ToolCheck( p )
	if p:HasInInventory("tool_saucepan") then
		return true
	else
		return false
	end
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


