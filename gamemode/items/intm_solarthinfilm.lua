local ITEM = {}


ITEM.ID = "intm_solarthinfilm"

ITEM.Name = "Solar Thin Film Roll"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 20
ITEM.Small_Parts = 5
ITEM.Chemicals = 40
ITEM.Chance = 100
ITEM.Info = "A roll of copper indium gallium selenide film, fragile outside of it's protective case."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_solarthinfilm"
ITEM.Model = "models/props/de_nuke/wall_light.mdl"
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