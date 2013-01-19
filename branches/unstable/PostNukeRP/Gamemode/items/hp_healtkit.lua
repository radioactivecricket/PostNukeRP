local ITEM = {}


ITEM.ID = "healthkit"

ITEM.Name = "Health Kit"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 5
ITEM.Small_Parts = 0
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "medical"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "hp_healthkit"
ITEM.Model = "models/items/healthkit.mdl"
ITEM.Script = ""
ITEM.Weight = 4

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( ply )
	local health = ply:Health()
		
	if not ( health == ply:GetMaxHealth() ) then
		local sound = Sound("items/medshot4.wav")
		ply:EmitSound( sound )
		
		ply:SetHealth( health + 30 )
		if ( ply:GetMaxHealth() < health + 30  ) then
			ply:SetHealth( ply:GetMaxHealth() )
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


