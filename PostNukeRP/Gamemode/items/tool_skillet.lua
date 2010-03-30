local ITEM = {}


ITEM.ID = "tool_skillet"

ITEM.Name = "Iron Skillet"
ITEM.ClassSpawn = "Cultivator"
ITEM.Scrap = 50
ITEM.Small_Parts = 0
ITEM.Chemicals = 20
ITEM.Chance = 100
ITEM.Info = "A skillet!  Always useful!"
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_skillet"
ITEM.Model = "models/props_c17/metalpot002a.mdl"
ITEM.Script = ""
ITEM.Weight = 4

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