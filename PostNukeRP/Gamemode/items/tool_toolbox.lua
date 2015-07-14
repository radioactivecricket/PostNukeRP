local ITEM = {}


ITEM.ID = "tool_toolbox"

ITEM.Name = "Toolbox"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 50
ITEM.Small_Parts = 25
ITEM.Chemicals = 40
ITEM.Chance = 100
ITEM.Info = "Needed to fix stuff"
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_toolbox"
ITEM.Model = "models/weapons/w_models/w_toolbox.mdl"
ITEM.Script = ""
ITEM.Weight = 5

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	
	PNRP.SetOwner(ply, ent)
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)