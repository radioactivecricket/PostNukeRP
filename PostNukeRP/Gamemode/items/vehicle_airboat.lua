local ITEM = {}


ITEM.ID = "vehicle_airboat"

ITEM.Name = "Airboat"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 300
ITEM.Small_Parts = 150
ITEM.Chemicals = 50
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "vehicle"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "prop_vehicle_airboat"
ITEM.Model = "models/airboat.mdl"
ITEM.Script = "scripts/vehicles/airboat.txt"
ITEM.Weight = 100

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)


