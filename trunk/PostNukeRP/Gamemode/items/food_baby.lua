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
ITEM.ShopHide = true
ITEM.AllHide = true


function ITEM.ToolCheck( p )
	if (CLIENT) then
		return false
	end
	if p:HasInInventory("tool_skillet") then
		return true
	else
		return false
	end
end

function ITEM.Use( ply )
	local hunger = ply:GetTable().Hunger
	if not ( hunger == 100 ) then
		local sound = Sound("ambient/creatures/town_child_scream1.wav")
		ply:EmitSound( sound )
		ply:ChatPrint("April Fools :)")
		
		for i=1, 5 do
			local zomb = ents.Create("npc_zombie")
			local x = math.random(-64, 64 )
			local y = math.random(-64, 64 )
			zomb:SetPos( ply:GetPos() + Vector( x, y, 8 ) )
			zomb:DropToFloor()
			zomb:Spawn()
		end
		
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


