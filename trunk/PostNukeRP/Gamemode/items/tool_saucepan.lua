local ITEM = {}


ITEM.ID = "tool_saucepan"

ITEM.Name = "Tin Saucepan"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 40
ITEM.Small_Parts = 0
ITEM.Chemicals = 35
ITEM.Chance = 100
ITEM.Info = "A sauce pan.  Useful for the growing cook."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_saucepan"
ITEM.Model = "models/props_interiors/pot02a.mdl"
ITEM.Script = ""
ITEM.Weight = 3

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	ent:SetNetworkedString("Owner", ply:Nick())
	
	--PNRP.AddWorldCache( ply,ITEM.ID )
end

function ITEM.Spawn( p )
	PNRP.BaseItemSpawn( p, ITEM )
end

function ITEM.Use( p, ent )
	PNRP.BaseUse( p, ITEM )
end


PNRP.AddItem(ITEM)