local ITEM = {}


ITEM.ID = "ammo_pistol"

ITEM.Name = "Pistol Ammo"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 5
ITEM.Small_Parts = 0
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "ammo"
ITEM.Remove = true
ITEM.Energy = 20
ITEM.Ent = "ammo_pistol"
ITEM.Model = "models/items/boxsrounds.mdl"
ITEM.Script = ""
ITEM.Weight = 2


function ITEM.Use( ply )
	local ammoType = ITEM.ID
	ammoType = string.gsub(ammoType, "ammo_", "")
	ply:GiveAmmo(ITEM.Energy, ammoType)
	return true
end


PNRP.AddItem(ITEM)


