local ITEM = {}


ITEM.ID = "tool_vendor"

ITEM.Name = "Vending Machine"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 500
ITEM.Small_Parts = 150
ITEM.Chemicals = 75
ITEM.Chance = 100
ITEM.Info = "A vending machine to sell items."
ITEM.Type = "tool"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "tool_vendor"
ITEM.Model = "models/props/cs_office/vending_machine.mdl"
ITEM.Script = ""
ITEM.Weight = 1
ITEM.Capacity = 500
ITEM.ProfileCost = "500 150 100"
ITEM.Persistent = true

function ITEM.ToolCheck( p )
	return {["intm_hudint"]=1,["intm_sensorpod"]=1, ["intm_elecboard"]=2, ["intm_servo"]=8}
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(class)
	ent:SetModel("models/props_interiors/vendingmachinesoda01a.mdl")
	ent:SetAngles( ply:GetAngles()-Angle(0,180,0) )
	ent:SetPos(pos + Vector(0,0,30))
	ent:Spawn()
	ent:Activate()
	
	PNRP.SetOwner(ply, ent)
	ent:SetNetVar("pid", ply.pid)
	ent:SetNetVar("name", ply:Nick().."'s Vending Machine")
	ent:SetNetVar("vendorid", nil)
	
	ent:GetPhysicsObject():Wake()
	
	PNRP.AddWorldCache( ply,ITEM.ID )
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)