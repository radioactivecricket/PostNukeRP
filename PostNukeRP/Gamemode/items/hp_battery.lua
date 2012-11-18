local ITEM = {}


ITEM.ID = "battery"

ITEM.Name = "Armor Battery"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 10
ITEM.Small_Parts = 0
ITEM.Chemicals = 25
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "medical"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "hp_battery"
ITEM.Model = "models/items/battery.mdl"
ITEM.Script = ""
ITEM.Weight = 2

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( ply )
	local armor = ply:Armor()
		
	if not ( armor == 100 ) then
		local sound = Sound("items/battery_pickup.wav")
		ply:EmitSound( sound )
		
		ply:SetArmor( armor + 20 )
		if ( 100 < armor + 20 ) then
			ply:SetArmor( 100 )
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


