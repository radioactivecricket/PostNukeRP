local ITEM = {}


ITEM.ID = "exp_oil_drum"

ITEM.Name = "Explosive Oil Drum"
ITEM.ClassSpawn = "Science"
ITEM.Scrap = 5
ITEM.Small_Parts = 0
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = "Big Bada Boom!"
ITEM.Type = "junk"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "prop_physics"
ITEM.Model = "models/props_c17/oildrum001_explosive.mdl"
ITEM.Script = ""
ITEM.Weight = 20

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
	ent:Spawn()
end

PNRP.AddItem(ITEM)


