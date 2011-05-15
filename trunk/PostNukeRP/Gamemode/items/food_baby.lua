local ITEM = {}


ITEM.ID = "food_baby"

ITEM.Name = "Small child"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 5
ITEM.Small_Parts = 5
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = "A small child, tastes great, needs a skillet too."
ITEM.Type = "food"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "food_baby"
ITEM.Model = "models/props_c17/doll01.mdl"
ITEM.Script = ""
ITEM.Weight = 1


function ITEM.ToolCheck( p )
	if p:HasInInventory("tool_skillet") then
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
		
		ply:GiveHunger( 30 )
	
		return true	
	else
		return false
	end
end


PNRP.AddItem(ITEM)


