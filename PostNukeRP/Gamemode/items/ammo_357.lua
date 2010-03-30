local ITEM = {}


ITEM.ID = "ammo_357"

ITEM.Name = ".357 Ammo"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 10
ITEM.Small_Parts = 0
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "ammo"
ITEM.Remove = true
ITEM.Energy = 10
ITEM.Ent = "ammo_357"
ITEM.Model = "models/items/357ammo.mdl"
ITEM.Script = ""
ITEM.Weight = 1


function ITEM.Use( ply )
	local ammoType = ITEM.ID
	ammoType = string.gsub(ammoType, "ammo_", "")
	ply:GiveAmmo(ITEM.Energy, ammoType)
	return true
end


PNRP.AddItem(ITEM)


