local ITEM = {}


ITEM.ID = "food_roast"

ITEM.Name = "Headcrab Roast"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 6
ITEM.Small_Parts = 0
ITEM.Chemicals = 6
ITEM.Chance = 100
ITEM.Info = "A roast of headcrab.  Very filling.  Needs both a skillet and a deep pot."
ITEM.Type = "food"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "food_roast"
ITEM.Model = "models/headcrabclassic.mdl"
ITEM.Script = ""
ITEM.Weight = 1


function ITEM.ToolCheck( p )
	if p:HasInInventory("tool_skillet") and p:HasInInventory("tool_deeppot") then
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
		
		ply:GiveHunger( 50 )

		return true	
	else
		return false
	end
end


PNRP.AddItem(ITEM)


