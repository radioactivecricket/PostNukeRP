local ITEM = {}


ITEM.ID = "intm_elecboard"

ITEM.Name = "Electronic Board"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 5
ITEM.Small_Parts = 5
ITEM.Chemicals = 15
ITEM.Chance = 100
ITEM.Info = "Pretty modular electrical boards.  Mostly for robotics."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_elecboard"
ITEM.Model = "models/props_lab/reciever01d.mdl"
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