local ITEM = {}


ITEM.ID = "food_beans"

ITEM.Name = "Can O' Beans"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 5
ITEM.Small_Parts = 0
ITEM.Chemicals = 2
ITEM.Chance = 100
ITEM.Info = "Beans are a staple of wasteland life."
ITEM.Type = "food"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "food_beans"
ITEM.Model = "models/props_junk/garbage_metalcan001a.mdl"
ITEM.Script = ""
ITEM.Weight = 1
ITEM.ShopHide = true

function ITEM.ToolCheck( p )
	return true
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

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
end

PNRP.AddItem(ITEM)


