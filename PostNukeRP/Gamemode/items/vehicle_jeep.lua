local ITEM = {}


ITEM.ID = "vehicle_jeep"

ITEM.Name = "Jeep"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 300
ITEM.Small_Parts = 150
ITEM.Chemicals = 50
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "vehicle"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "prop_vehicle_jeep_old"
ITEM.Model = "models/buggy.mdl"
ITEM.Script = "scripts/vehicles/jeep_test.txt"
ITEM.Weight = 100

function ITEM.Spawn( p )
	PNRP.BaseVehicle( p, "models/buggy.mdl", "prop_vehicle_jeep_old", "scripts/vehicles/jeep_test.txt", ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


