local ITEM = {}


ITEM.ID = "healthvial"

ITEM.Name = "Small Healthkit"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 5
ITEM.Small_Parts = 0
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "medical"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "hp_smallhealthkit"
ITEM.Model = "models/healthvial.mdl"
ITEM.Script = ""
ITEM.Weight = 2

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( ply )
	local health = ply:Health()
		
	if not ( health == ply:GetMaxHealth() ) then
		local sound = Sound("items/smallmedkit1.wav")
		ply:EmitSound( sound )
		
		ply:SetHealth( health + 10 )
		if ( ply:GetMaxHealth() < health + 10  ) then
			ply:SetHealth( ply:GetMaxHealth() )
		end
		return true	
	else
		return false
	end
end


PNRP.AddItem(ITEM)


