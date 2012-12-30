local ITEM = {}


ITEM.ID = "food_rawguard"

ITEM.Name = "Raw Antlion Guard Meat"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 5
ITEM.Small_Parts = 0
ITEM.Chemicals = 2
ITEM.Chance = 100
ITEM.Info = "A large hunk of guard meat.  The royal gelly inside seems to heal."
ITEM.Type = "food"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "food_rawguard"
ITEM.Model = "models/gibs/antlion_gib_large_3.mdl"
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
		
		ply:GiveHunger( 20 )
		
		local health = ply:Health()
	
		if not ( health == ply:GetMaxHealth() ) then
			ply:SetHealth( health + 5 )
			if ( ply:GetMaxHealth() < health + 5  ) then
				ply:SetHealth( ply:GetMaxHealth() )
			end
		end
		
		local shouldpoison = math.random(1, 100)
		if shouldpoison < 20 then
			local timerstring = tostring(ply:UniqueID())..tostring(math.random(1,999))
			
			timer.Create("poison"..timerstring, 1, 20, function() 
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


