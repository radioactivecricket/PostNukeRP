
--CreateConVar("pnrp_propBanning", "1", FCVAR_ARCHIVE)
--CreateConVar("pnrp_propAllowing", "0", FCVAR_ARCHIVE)

--CreateConVar("pnrp_propPay", "1", FCVAR_ARCHIVE)
--CreateConVar("pnrp_propCost", "10", FCVAR_ARCHIVE)

--CreateConVar("pnrp_adminCreateAll", "1", FCVAR_ARCHIVE)
--CreateConVar("pnrp_adminTouchAll", "1", FCVAR_ARCHIVE)

--CreateConVar("pnrp_exp2Level", "1", FCVAR_ARCHIVE)

BannedProps = { }
function AddBannedProp(mdl) table.insert(BannedProps, mdl) end

AllowedProps = { }
function AddAllowedProp(mdl) table.insert(AllowedProps, mdl) end

PNRP.Items = {}

function PNRP.AddItem( itemtable )

	PNRP.Items[itemtable.ID] =
	{
		ID = itemtable.ID,
		Name = itemtable.Name,
		ClassSpawn = itemtable.ClassSpawn,		
		Scrap = itemtable.Scrap,
		SmallParts = itemtable.Small_Parts,
		Chemicals = itemtable.Chemicals,
		Chance = itemtable.Chance,
		Info = itemtable.Info,	
		Type = itemtable.Type,
		Energy = itemtable.Energy,
		Ent = itemtable.Ent,
		Model = itemtable.Model,
		Spawn = itemtable.Spawn,
		Use = itemtable.Use,
		Remove = itemtable.Remove,
		Script = itemtable.Script,
		Weight = itemtable.Weight,
	}
	
	AddBannedProp(itemtable.Model)
	
end	

-- PNRP.JunkModels = { "models/props_junk/TrashCluster01a.mdl",
	-- "models/Gibs/helicopter_brokenpiece_03.mdl"}
-- PNRP.ChemicalModels = { "models/props_junk/garbage128_composite001c.mdl",
	-- "models/Gibs/gunship_gibs_sensorarray.mdl",
	-- "models/Gibs/gunship_gibs_eye.mdl"}
-- PNRP.SmallPartsModels = { "models/props_combine/combine_binocular01.mdl",
	-- "models/Gibs/Scanner_gib01.mdl", 
	-- "models/Gibs/Scanner_gib05.mdl" }

for k, v in pairs(PNRP.JunkModels) do
	AddBannedProp(v)
end
for k, v in pairs(PNRP.ChemicalModels) do
	AddBannedProp(v)
end
for k, v in pairs(PNRP.SmallPartsModels) do
	AddBannedProp(v)
end

function GM:PlayerSpawnProp(ply, model)
	if not self.BaseClass:PlayerSpawnProp(ply, model) then return false end
	
	local allowed = false
	
	if ply:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1 then allowed = true end

	model = string.gsub(model, "\\", "/")
	if string.find(model,  "//") then return false end
	-- Banned props take precedence over allowed props
	if GetConVarNumber("pnrp_propBanning") == 1 then
		for k, v in pairs(BannedProps) do
			if string.lower(v) == string.lower(model) then 
				ply:ChatPrint("This prop is not allowed.")
				return false 
			end
		end
	end

	if GetConVarNumber("pnrp_propAllowing") == 1 then
	-- If we are specifically allowing certain props, if it's not in the list, allowed will remain false
		for k, v in pairs(AllowedProps) do
			if v == model then allowed = true end
		end
	else
		-- allowedprops is not enabled, so assume that if it wasn't banned above, it's allowed
		allowed = true
	end

	if allowed then
		if GetConVarNumber("pnrp_propPay") == 1 then
			if ply:GetResource("Scrap") >= GetConVarNumber("pnrp_propCost") then
				ply:ChatPrint(tostring(GetConVarNumber("pnrp_propCost")).." scrap used to create this prop.")
				ply:DecResource("Scrap", GetConVarNumber("pnrp_propCost"))
				return true
			else
				ply:ChatPrint(tostring(GetConVarNumber("pnrp_propCost")).." scrap needed to create this prop.")
				return false
			end
		else
			return true
		end
	end
	return false
end

function GM:PlayerSpawnVehicle( p )

	if not (p:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1) then
	
		p:ChatPrint( "Vehicle spawning is disabled." )
	
		return false
		
	end	

	return true
	
end	


function GM:PlayerSpawnRagdoll( p, model )

	if not (p:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1) then

		p:ChatPrint( "Ragdoll spawning is disabled." )
	
		return false
		
	end	

	return true
	
end	


function GM:PlayerSpawnEffect( p, model )

	if not (p:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1) then

		p:ChatPrint( "Effect spawning is disabled." )
	
		return false
		
	end	

	return true
	
end	


function GM:PlayerSpawnSWEP( p, classname )

	if not (p:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1) then

		p:ChatPrint( "SWEP spawning is disabled." )
	
		return false
		
	end	

	return true
	
end


function PickupCheck( ply, ent)
	--admin can do whatever they want
	if ply:IsSuperAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then return true end
	
	if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 and not (ent:IsSuperAdmin() or ent:IsAdmin()) then return true end
	
	if ent:IsPlayer() then return false end
	
	--local searchString = " "..ent:GetClass()
	if string.find(ent:GetClass(), "unc_") == 2 then
		return false
	end
	
	local owner = ent:GetNWString( "Owner", "None" )
	
	local playerPos = ply:GetShootPos()
	local entPos = ent:GetPos()
	local myDistance = playerPos:Distance( entPos )
	
	--Check distance first.  Don't want people picking stuff from across the map.
	if myDistance > 300 then return false end
	
	--Unownable should be un-pickupable, so we check that next
	if owner == "Unownable" then return false end
	
	--if owner == "None" or owner == "World" then return true end
	if ply:Nick() == owner then return true end
	if owner ~= ply:Nick() then 
		if owner ~= "None" and owner ~= "World" then
			return false
		end
	end
	
	--If nothing is triggered, just return false.
	--return false
end
hook.Add( "PhysgunPickup", "pickupCheck", PickupCheck )

function PhysUnfreezeCheck ( ply, ent, physobj )
	--admin can do whatever they want
	if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then return true end

	--get the entity we're looking at, do the same checks as when doing pickup
	--local ent = ply:GetEyeTrace().Entity
	
	local owner = ent:GetNWString( "Owner", "None" )
	
	local playerPos = ply:GetShootPos()
	local entPos = ent:GetPos()
	local myDistance = playerPos:Distance( entPos )
	
	if myDistance > 300 then return false end
	if owner == "Unownable" then return false end
	--if owner == "None" or owner == "World" then return true end
	if ply:Nick() == owner then return true end
	
	--If nothing is triggered, just return false.
	--return false
end
hook.Add("CanPlayerUnfreeze", "PhyUnfreezeCheck", PhysUnfreezeCheck)

function ToolCheck( ply, tr, toolmode )
	--check for globally allowed tools (Admins can use all tools)
	if toolmode == "remover" or toolmode == "weld" or toolmode == "weld_ez" 
	  or toolmode == "easy_precision" or toolmode == "duplicator" 
	  or toolmode == "adv_duplicator" or toolmode == "weld_ez2" 
	  or(ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 ) then 
		return true
	end
	
	
	if toolmode == "wire_expression" or toolmode == "wire_expression2" or toolmode == "wire_gate_expression" or toolmode == "wire_debugger" or toolmode == "wire_adv" then
		if GetConVarNumber("pnrp_exp2Level") == 0 then 
			return false 
		elseif GetConVarNumber("pnrp_exp2Level") == 1 and ply:IsAdmin() then
			return true
		elseif GetConVarNumber("pnrp_exp2Level") == 2 and (ply:IsAdmin() or team.GetName(ply:Team()) == "Engineer") then
			return true
		elseif GetConVarNumber("pnrp_exp2Level") == 3 and (ply:IsAdmin() or team.GetName(ply:Team()) == "Engineer" or team.GetName(ply:Team()) == "Science") then
			return true
		elseif GetConVarNumber("pnrp_exp2Level") == 4 then
			return true
		else
			return false
		end
	end
	
	--check for class (Engineers can use all tools right now)
	if team.GetName(ply:Team()) == "Engineer" then
		return true
	end
	
	--if you don't meet any of these, you can go to hell.
	return false
end
hook.Add( "CanTool", "ToolCheck", ToolCheck )
