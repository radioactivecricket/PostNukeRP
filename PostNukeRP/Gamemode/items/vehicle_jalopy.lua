local ITEM = {}


ITEM.ID = "vehicle_jalopy"

ITEM.Name = "Jalopy"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 300
ITEM.Small_Parts = 150
ITEM.Chemicals = 50
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "vehicle"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "prop_vehicle_jeep"
ITEM.Model = "models/vehicle.mdl"
ITEM.Script = "scripts/vehicles/jalopy.txt"
ITEM.Weight = 500

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)


