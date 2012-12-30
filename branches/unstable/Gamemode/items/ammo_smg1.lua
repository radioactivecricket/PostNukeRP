local ITEM = {}


ITEM.ID = "ammo_smg1"

ITEM.Name = "SMG Ammo"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 15
ITEM.Small_Parts = 0
ITEM.Chemicals = 15
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "ammo"
ITEM.Remove = true
ITEM.Energy = 75
ITEM.Ent = "ammo_smg1"
ITEM.Model = "models/items/boxmrounds.mdl"
ITEM.Script = ""
ITEM.Weight = 3

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


