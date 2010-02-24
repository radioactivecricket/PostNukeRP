local ITEM = {}


ITEM.ID = "Seat_Jeep"

ITEM.Name = "Jeep Seat"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 5
ITEM.Small_Parts = 2
ITEM.Chemicals = 2
ITEM.Chance = 100
ITEM.Info = "Press Alt+E to exit seat."
ITEM.Type = "vehicle"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "weapon_seat"
ITEM.Model = "models/nova/jeep_seat.mdl"
ITEM.Script = "scripts/vehicles/prisoner_pod.txt"
ITEM.Weight = 10

function ITEM.Spawn( p )
	PNRP.BaseVehicle( p, "models/jeep_seat.mdl", "prop_vehicle_prisoner_pod", "scripts/vehicles/prisoner_pod.txt", ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)


