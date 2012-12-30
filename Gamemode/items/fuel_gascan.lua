local ITEM = {}


ITEM.ID = "fuel_gas"

ITEM.Name = "Gas Can"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 2
ITEM.Small_Parts = 0
ITEM.Chemicals = 20
ITEM.Chance = 100
ITEM.Info = "Big Bada Boom!"
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "prop_physics"
ITEM.Model = "models/props_junk/gascan001a.mdl"
ITEM.Script = ""
ITEM.Weight = 1

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Use( ply )
	return true	
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetModel(ITEM.Model)
	ent:SetPos(pos)
	ent.CanF2 = true
	ent.ID = "fuel_gas"
	ent:Spawn()
end

PNRP.AddItem(ITEM)


