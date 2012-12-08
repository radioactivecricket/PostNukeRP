local ITEM = {}


ITEM.ID = "intm_sensorpod"

ITEM.Name = "Sensorpod"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 20
ITEM.Small_Parts = 20
ITEM.Chemicals = 10
ITEM.Chance = 100
ITEM.Info = "An aging sensor pod from times past."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_sensorpod"
ITEM.Model = "models/gibs/shield_scanner_gib5.mdl"
ITEM.Script = ""
ITEM.Weight = 1
ITEM.ShopHide = true

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