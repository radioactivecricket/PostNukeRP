local ITEM = {}


ITEM.ID = "intm_fusioncore"

ITEM.Name = "Fusion Core"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 40
ITEM.Small_Parts = 20
ITEM.Chemicals = 5
ITEM.Chance = 100
ITEM.Info = "An extremely rare reactor core for a fusion reactor."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_fusioncore"
ITEM.Model = "models/props_combine/combine_light002a.mdl"
ITEM.Script = ""
ITEM.Weight = 2
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