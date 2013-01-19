local ITEM = {}


ITEM.ID = "ammo_ar2"

ITEM.Name = "Fusion Battery"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 10
ITEM.Small_Parts = 0
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "ammo"
ITEM.Remove = true
ITEM.Energy = 50  --is also ammo amount for ammo
ITEM.Ent = "ammo_ar2"
ITEM.Model = "models/Items/combine_rifle_cartridge01.mdl"
ITEM.Script = ""
ITEM.Weight = 1

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Use( ply )
	local ammoType = ITEM.ID
	ammoType = string.gsub(ammoType, "ammo_", "")
	ply:GiveAmmo(ITEM.Energy, ammoType)
	return true
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:SetNetworkedString("Ammo", tostring(ITEM.Energy))
end

PNRP.AddItem(ITEM)


