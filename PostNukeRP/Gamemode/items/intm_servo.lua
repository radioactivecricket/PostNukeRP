local ITEM = {}


ITEM.ID = "intm_servo"

ITEM.Name = "Servo"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 5
ITEM.Small_Parts = 20
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = "Small electrical motor."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_servo"
ITEM.Model = "models/gibs/scanner_gib04.mdl"
ITEM.Script = ""
ITEM.Weight = 1

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)