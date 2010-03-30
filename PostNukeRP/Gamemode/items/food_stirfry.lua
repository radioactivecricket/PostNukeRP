local ITEM = {}


ITEM.ID = "food_stirfry"

ITEM.Name = "Carton of Stirfry"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 5
ITEM.Small_Parts = 0
ITEM.Chemicals = 3
ITEM.Chance = 100
ITEM.Info = "A bit of stirfry, much more filling then beans.  Needs a skillet though."
ITEM.Type = "food"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "food_stirfry"
ITEM.Model = "models/props_junk/garbage_takeoutcarton001a.mdl"
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


