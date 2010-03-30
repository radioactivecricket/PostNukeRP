local ITEM = {}


ITEM.ID = "tool_deeppot"

ITEM.Name = "Deep Pot"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 60
ITEM.Small_Parts = 0
ITEM.Chemicals = 40
ITEM.Chance = 100
ITEM.Info = "A deep pot.  Can't make anything with it alone."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_deeppot"
ITEM.Model = "models/props_c17/metalpot001a.mdl"
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

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)