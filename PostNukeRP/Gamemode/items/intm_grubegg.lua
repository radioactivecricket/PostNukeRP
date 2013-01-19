local ITEM = {}


ITEM.ID = "intm_grubegg"

ITEM.Name = "Grub Egg"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 0
ITEM.Small_Parts = 0
ITEM.Chemicals = 30
ITEM.Chance = 100
ITEM.Info = "An egg carefully picked from a hive."
ITEM.Type = "part"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_grubegg"
ITEM.Model = "models/props_hive/egg_phy.mdl"
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