local ITEM = {}


ITEM.ID = "food_orange"

ITEM.Name = "Orange"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 0
ITEM.Small_Parts = 0
ITEM.Chemicals = 0
ITEM.Chance = 100
ITEM.Info = "It's an orange.  Must be grown, as you can't find them anywhere."
ITEM.Type = "food"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "food_orange"
ITEM.Model = "models/props/cs_italy/orange.mdl"
ITEM.Script = ""
ITEM.Weight = 0.2


function ITEM.ToolCheck( p )
	if p:HasInInventory("tool_saucepan") then
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
		
		ply:GiveHunger( 15 )

		return true	
	else
		return false
	end
end


PNRP.AddItem(ITEM)


