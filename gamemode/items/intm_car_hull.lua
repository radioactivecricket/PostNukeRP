local ITEM = {}


ITEM.ID = "intm_car_hull"

ITEM.Name = "Old Car Body"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 75
ITEM.Small_Parts = 50
ITEM.Chemicals = 0
ITEM.Chance = 100
ITEM.Info = "Rusty piece of junk"
ITEM.Type = "vehicle"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "intm_car_hull"
ITEM.Model = "models/props_vehicles/car001a_hatchback.mdl"
ITEM.Script = ""
ITEM.Weight = 1
ITEM.ShopHide = true
ITEM.SaveState = true

function ITEM.BuildState( ent )
	local model = "models/props_vehicles/car001a_hatchback.mdl"
	local skin = 0
	if( IsValid(ent) ) then 
		model = ent:GetModel()
		skin = ent:GetSkin()
	end
	
	if model == "" or model == nil then model = "models/props_vehicles/car001a_hatchback.mdl" end
	if skin == "" or skin == nil then skin = 0 end

	return "Model="..model..",Skin="..tostring(skin)
end

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Create( ply, class, pos, iid, angles, model, skin )
	local ent = ents.Create(class)
	if not model then model = "models/props_vehicles/car001a_hatchback.mdl" end
	if not angles then angles = Angle(0,0,0) end
	if not skin then skin = 0 end
	
	ent:SetAngles(toangle(angles))
	if iid then
		local stateStr = PNRP.ReturnState(iid)
		model = PNRP.GetFromStat(stateStr, "Model")
		local newSkin = tonumber(PNRP.GetFromStat(stateStr, "Skin"))
		if newSkin then
			skin = newSkin
		end
	end
	
	ent:SetModel(model)
	ent:SetSkin(skin)
	local mb = ent:GetModelBounds()
	mb = string.Explode(" ", tostring(mb))
	mb[3] = mb[3] / 2
	ent:SetPos(pos-Vector(0,0,mb[3]))
	ent:Spawn()
	
	ent.resource = false
	
	ent:SetMoveType( MOVETYPE_VPHYSICS )
	ent:PhysWake()
	
	if ITEM.SaveState then
		
		PNRP.BuildPersistantItem(ply, ent, iid)
	end
	
	PNRP.SetOwner(ply, ent)
	
	PNRP.AddWorldCache( ply,ITEM.ID,ent )
end

function ITEM.Use( ply )
	return true	
end


PNRP.AddItem(ITEM)