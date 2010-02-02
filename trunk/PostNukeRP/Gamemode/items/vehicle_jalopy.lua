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
ITEM.Weight = 200

function ITEM.Spawn( p )
	PNRP.BaseVehicle( p, "models/vehicle.mdl", "prop_vehicle_jeep", "scripts/vehicles/jalopy.txt", ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


