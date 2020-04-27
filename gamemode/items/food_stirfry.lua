local ITEM = {}


ITEM.ID = "food_stirfry"

ITEM.Name = "Guard Stirfry"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 0
ITEM.Small_Parts = 0
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = "An antlion guard stirfry.  The royal gelly inside is very healthy.  Needs a skillet though."
ITEM.Type = "food"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "food_stirfry"
ITEM.Model = "models/props_junk/garbage_takeoutcarton001a.mdl"
ITEM.Script = ""
ITEM.Weight = 1


function ITEM.ToolCheck( p )
	return {["tool_skillet"]=0, ["food_rawguard"]=1}
end

function ITEM.Use( ply )
	local hunger = ply:GetTable().Hunger
	if not ( hunger == 100 ) then
		local sound = Sound("npc/ichthyosaur/snap.wav")
		ply:EmitSound( sound )
		
		ply:GiveHunger( 50 )
		
		local health = ply:Health()
		
		if not ( health == ply:GetMaxHealth() ) then
			ply:SetHealth( health + 10 )
			if ( ply:GetMaxHealth() < health + 10 ) then
				ply:SetHealth( ply:GetMaxHealth() )
			end
		end
		
		return true	
	else
		return false
	end
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
end

PNRP.AddItem(ITEM)


