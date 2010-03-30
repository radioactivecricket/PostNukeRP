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
		
		ply:GiveHunger( 25 )
		
		if not ( health == ply:GetMaxHealth() ) then
			ply:SetHealth( health + 5 )
			if ( ply:GetMaxHealth() < health + 5  ) then
				ply:SetHealth( ply:GetMaxHealth() )
			end
		end
		return true	
	else
		return false
	end
end


PNRP.AddItem(ITEM)


