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


function ITEM.ToolCheck( p )
	if p:HasInInventory("tool_coffeepot") then
		return true
	else
		return false
	end
end

function ITEM.Use( ply )
	local hunger = ply:GetTable().Hunger
	if not ( hunger == 100 ) then
		local sound = Sound("npc/ichthyosaur/snap.wav")
		ply:EmitSound( sound )
		
		ply:GiveHunger( 5 )
		ply:GiveEndurance( 8 )
		return true	
	else
		return false
	end
end


PNRP.AddItem(ITEM)


