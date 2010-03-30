local ITEM = {}


ITEM.ID = "food_stew"

ITEM.Name = "Antlion Roast"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 6
ITEM.Small_Parts = 0
ITEM.Chemicals = 6
ITEM.Chance = 100
ITEM.Info = "A roast of antlion.  High in protien.  Needs both a saucepan and a deep pot."
ITEM.Type = "food"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "food_stew"
ITEM.Model = "models/gibs/antlion_gib_large_2.mdl"
ITEM.Script = ""
ITEM.Weight = 1


function ITEM.ToolCheck( p )
	if p:HasInInventory("tool_saucepan") and p:HasInInventory("tool_deeppot") then
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
		
		ply:GiveHunger( 40 )
		if not ( health == ply:GetMaxHealth() ) then
			ply:SetHealth( health + 10 )
			if ( ply:GetMaxHealth() < health + 10  ) then
				ply:SetHealth( ply:GetMaxHealth() )
			end
		end
		return true	
	else
		return false
	end
end


PNRP.AddItem(ITEM)


