local ITEM = {}


ITEM.ID = "intm_car_axle"

ITEM.Name = "Old Car Axle"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 15
ITEM.Small_Parts = 5
ITEM.Chemicals = 2
ITEM.Chance = 100
ITEM.Info = "Beat up old axle"
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_car_axle"
ITEM.Model = "models/props_vehicles/carparts_axel01a.mdl"
ITEM.Script = ""
ITEM.Weight = 1
ITEM.ShopHide = true

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	
	PNRP.SetOwner(ply, ent)
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)