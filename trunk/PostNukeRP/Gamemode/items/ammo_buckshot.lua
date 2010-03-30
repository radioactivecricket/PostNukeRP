local ITEM = {}


ITEM.ID = "ammo_buckshot"

ITEM.Name = "Buckshot Ammo"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 10
ITEM.Small_Parts = 0
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "ammo"
ITEM.Remove = true
ITEM.Energy = 20
ITEM.Ent = "ammo_buckshot"
ITEM.Model = "models/items/boxbuckshot.mdl"
ITEM.Script = ""
ITEM.Weight = 2


function ITEM.Use( ply )
	local ammoType = ITEM.ID
	ammoType = string.gsub(ammoType, "ammo_", "")
	ply:GiveAmmo(ITEM.Energy, ammoType)
	return true
end


PNRP.AddItem(ITEM)


