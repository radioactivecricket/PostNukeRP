local ITEM = {}


ITEM.ID = "food_cookedbeans"

ITEM.Name = "Well-cooked Beans"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 0
ITEM.Small_Parts = 0
ITEM.Chemicals = 0
ITEM.Chance = 100
ITEM.Info = "Beans are a staple of wasteland life, made even better by someone who knows how to cook."
ITEM.Type = "food"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "food_cookedbeans"
ITEM.Model = "models/props_junk/garbage_metalcan001a.mdl"
ITEM.Script = ""
ITEM.Weight = 1


function ITEM.ToolCheck( p )
	return {["food_beans"]=1}
end

function ITEM.Use( ply )
	local hunger = ply:GetTable().Hunger
	if not ( hunger == 100 ) then
		local sound = Sound("npc/ichthyosaur/snap.wav")
		ply:EmitSound( sound )
		
		ply:GiveHunger( 20 )
		
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


