local ITEM = {}


ITEM.ID = "food_rawhead"

ITEM.Name = "Raw Headcrab Meat"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 5
ITEM.Small_Parts = 0
ITEM.Chemicals = 2
ITEM.Chance = 100
ITEM.Info = "A bit of raw headcrab meat."
ITEM.Type = "food"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "food_rawhead"
ITEM.Model = "models/weapons/w_bugbait.mdl"
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
		local shouldpoison = math.random(1, 100)
		if shouldpoison < 20 then
			local timerstring = tostring(ply:UniqueID())..tostring(math.random(1,999))
			
			timer.Create("poison"..timerstring, 1, 10, function() 
					if ply and IsValid(ply) then
						if not ply:Alive() then
							timer.Destroy("poison"..timerstring)
							return
						end
						ply:TakeDamage( 1, ply, ply)
					end
				end)
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


