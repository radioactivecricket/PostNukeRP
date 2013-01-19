local ITEM = {}


ITEM.ID = "fuel_h2"

ITEM.Name = "Deuterium Fuel"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 0
ITEM.Small_Parts = 0
ITEM.Chemicals = 0
ITEM.Chance = 100
ITEM.Info = "An H-2 isotope, ready to be loaded into a reactor."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "fuel_h2"
ITEM.Model = "models/items/combine_rifle_ammo01.mdl"
ITEM.Script = ""
ITEM.Weight = 0.1
ITEM.ShopHide = true

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Use( ply )
	return false
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
end

PNRP.AddItem(ITEM)


