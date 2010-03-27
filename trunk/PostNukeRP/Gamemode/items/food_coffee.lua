local ITEM = {}


ITEM.ID = "food_coffee"

ITEM.Name = "Cup of Coffee"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 1
ITEM.Small_Parts = 0
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = "A good cup of coffee to keep ya goin'.  Needs a Coffee Pot."
ITEM.Type = "food"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "food_coffee"
ITEM.Model = "models/props_junk/garbage_coffeemug001a.mdl"
ITEM.Script = ""
ITEM.Weight = 1

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.ToolCheck( p )
	if p:HasInInventory("tool_coffeepot") then
		return true
	else
		return false
	end
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


