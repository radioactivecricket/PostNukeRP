local ITEM = {}


ITEM.ID = "tool_pottedplant"

ITEM.Name = "Potted Plant"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 100
ITEM.Small_Parts = 75
ITEM.Chemicals = 300
ITEM.Chance = 100
ITEM.Info = "A slowly raised, but now useful plant.  Grows fruits if taken care of."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_pottedplant"
ITEM.Model = "models/props/cs_office/plant01.mdl"
ITEM.Script = ""
ITEM.Weight = 10

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:Activate()
	--ent:SetNetworkedString("Owner", ply:Nick())
	PNRP.SetOwner(ply, ent)
	
	PNRP.AddWorldCache( ply,ITEM.ID )
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)