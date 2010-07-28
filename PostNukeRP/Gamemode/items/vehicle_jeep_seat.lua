local ITEM = {}


ITEM.ID = "seat_jeep"

ITEM.Name = "Jeep Seat"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 5
ITEM.Small_Parts = 2
ITEM.Chemicals = 2
ITEM.Chance = 100
ITEM.Info = "Press E to exit seat or Alt+E to use Buttons."
ITEM.Type = "vehicle"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "weapon_seat"
ITEM.Model = "models/nova/jeep_seat.mdl"
ITEM.Script = "scripts/vehicles/prisoner_pod.txt"
ITEM.Weight = 10

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)


