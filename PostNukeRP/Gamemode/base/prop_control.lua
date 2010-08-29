
--CreateConVar("pnrp_propBanning", "1", FCVAR_ARCHIVE)
--CreateConVar("pnrp_propAllowing", "0", FCVAR_ARCHIVE)

--CreateConVar("pnrp_propPay", "1", FCVAR_ARCHIVE)
--CreateConVar("pnrp_propCost", "10", FCVAR_ARCHIVE)

--CreateConVar("pnrp_adminCreateAll", "1", FCVAR_ARCHIVE)
--CreateConVar("pnrp_adminTouchAll", "1", FCVAR_ARCHIVE)

--CreateConVar("pnrp_exp2Level", "1", FCVAR_ARCHIVE)

local EntityMeta = FindMetaTable("Entity")

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
		Create = itemtable.Create,
		ToolCheck = itemtable.ToolCheck,
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

function PNRP.GetBannedPropsList( )
	local tbl = { }
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if file.Exists("PostNukeRP/banned_props.txt") then
		tbl = glon.decode(file.Read("PostNukeRP/banned_props.txt"))
		if tbl ~= nil then
			for k, v in pairs(tbl) do
				AddBannedProp(v)
			end
		end
	else
		file.Write("PostNukeRP/banned_props.txt",util.TableToKeyValues(tbl))
	end
end
PNRP.GetBannedPropsList( )

function PNRP.GetAllowedPropsList( )
	local tbl = { }
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if file.Exists("PostNukeRP/allowed_props.txt") then
		tbl = glon.decode(file.Read("PostNukeRP/allowed_props.txt"))
		if tbl ~= nil then
			for k, v in pairs(tbl) do
				AddAllowedProp(v)
			end
		end
	else
		file.Write("PostNukeRP/allowed_props.txt",util.TableToKeyValues(tbl))
	end
end
PNRP.GetAllowedPropsList( )

function PNRP.Start_open_PropPprotection(ply)
	local bannedtbl = { }
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if file.Exists("PostNukeRP/banned_props.txt") then
		bannedtbl = glon.decode(file.Read("PostNukeRP/banned_props.txt"))
	else
		file.Write("PostNukeRP/banned_props.txt",glon.encode(bannedtbl))
	end
	local allowedtbl = { }
	if file.Exists("PostNukeRP/allowed_props.txt") then
		allowedtbl = glon.decode(file.Read("PostNukeRP/allowed_props.txt"))
	else
		file.Write("PostNukeRP/allowed_props.txt",glon.encode(allowedtbl))
	end
	datastream.StreamToClients(ply, "pnrp_OpenPropProtectWindow", { bannedtbl, allowedtbl } )
end
datastream.Hook( "Start_open_PropProtection", PNRP.Start_open_PropPprotection )

function PNRP.PropProtect_AddItem(ply, handler, id, encoded, decoded )
	local model = decoded[1]
	local switch = decoded[2] --1 is add Prop Block, 2 is add Prop Allowed
	local tbl = {}
	if switch == 1 then
		--Prop Blocking 
		if file.Exists("PostNukeRP/banned_props.txt") then
			tbl = glon.decode(file.Read("PostNukeRP/banned_props.txt"))
			if tbl ~= nil then
				for k, v in pairs( tbl ) do	
					if model == v then return end
				end	
			else
				tbl = {}
			end
			table.insert(tbl, model)
			AddBannedProp(model)
			file.Write("PostNukeRP/banned_props.txt",glon.encode(tbl))
		else
			AddBannedProp(model)
			table.insert(tbl, model)
			file.Write("PostNukeRP/banned_props.txt",glon.encode(tbl))
		end
	else
		--Prop Allowing
		if file.Exists("PostNukeRP/allowed_props.txt") then
			tbl = glon.decode(file.Read("PostNukeRP/allowed_props.txt"))
			if tbl ~= nil then
				for k, v in pairs( tbl ) do	
					if model == v then return end
				end	
			else
				tbl = {}
			end
			table.insert(tbl, model)
			AddAllowedProp(model)
			file.Write("PostNukeRP/allowed_props.txt",glon.encode(tbl))
		else
			table.insert(tbl, model)
			AddAllowedProp(model)
			file.Write("PostNukeRP/allowed_props.txt",glon.encode(tbl))
		end
	end
end
datastream.Hook(  "PropProtect_AddItem", PNRP.PropProtect_AddItem )

function PNRP.PropProtect_RemoveItem(ply, handler, id, encoded, decoded )
	local model = decoded[1]
	local switch = decoded[2] --1 is add Prop Block, 2 is add Prop Allowed
	local tbl = { }
	if switch == 1 then
		--Prop Banning
		if file.Exists("PostNukeRP/banned_props.txt") then
			tbl = glon.decode(file.Read("PostNukeRP/banned_props.txt"))
			if tbl ~= nil then
				for k, v in pairs( tbl ) do	
					if model == v then
						table.remove(tbl, k)
					end
				end
				file.Write("PostNukeRP/banned_props.txt",glon.encode(tbl))
			end
			for k, v in pairs( BannedProps ) do	
				if model == v then
					table.remove(BannedProps, k)
				end
			end
		else
			for k, v in pairs( BannedProps ) do	
				if model == v then
					table.remove(BannedProps, k)
				end
			end
			file.Write("PostNukeRP/banned_props.txt",glon.encode(tbl))
		end
	else
		--Prop Allowing
		if file.Exists("PostNukeRP/allowed_props.txt") then
			tbl = glon.decode(file.Read("PostNukeRP/allowed_props.txt"))
			if tbl ~= nil then
				for k, v in pairs( tbl ) do	
					if model == v then
						table.remove(tbl, k)
					end
				end
				file.Write("PostNukeRP/allowed_props.txt",glon.encode(tbl))
			end
			for k, v in pairs( AllowedProps ) do	
				if model == v then
					table.remove(AllowedProps, k)
				end
			end
		else
			for k, v in pairs( AllowedProps ) do	
				if model == v then
					table.remove(AllowedProps, k)
				end
			end
			file.Write("PostNukeRP/allowed_props.txt",glon.encode(tbl))
		end
	end
end
datastream.Hook( "PropProtect_RemoveItem", PNRP.PropProtect_RemoveItem )

function GM:PlayerSpawnProp(ply, model)
	if not self.BaseClass:PlayerSpawnProp(ply, model) then return false end
	
	local allowed = false
	
	--Admin Create All Overide
	if ply:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1 then 
		
		allowed = true 
	
	else
	--Normal Allowed system
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
	end
	
	if allowed then
		if GetConVarNumber("pnrp_propPay") == 1 then
			local ent = ents.Create("prop_physics")
			ent:SetModel(model)
			ent:Spawn()			
			
			local price = math.Round(((ent:BoundingRadius() + ent:GetPhysicsObject():GetMass()) / 2) * (GetConVarNumber("pnrp_propCost") / 100))
			ent:Remove()
			
			if price < 1 then price = 1 end
			--ply:ChatPrint("Price:  "..tostring(price))
			
			--Admin No Cost Overide
			local adminCostOveride = false
			if ply:IsAdmin() and GetConVarNumber("pnrp_adminNoCost") == 1 then 
				adminCostOveride = true 
			else
				adminCostOveride = false
			end
			
			if ply:GetResource("Scrap") >= price or adminCostOveride == true then
				ply:ChatPrint(tostring(price).." scrap used to create this prop.")
				ply:DecResource("Scrap", price)
				return true
			else
				ply:ChatPrint(tostring(price).." scrap needed to create this prop.")
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

function GM:PlayerSpawnSENT( p, classname )
	p:ChatPrint("Classname:  "..classname)
	if not (p:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1) then
		for k, v in pairs(PNRP.Items) do
			if v.ClassSpawn == classname then
				return false
			end
		end
		
		if string.find(classname, "eapon") == 2 then
			return false
		end
	end
	
	return true
end

function GM:PlayerSpawnSWEP( ply, class, wep )

	ply:ChatPrint( "Spawning the F-ing Weapon" )

	if not (ply:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1) then
	
		ply:ChatPrint( "SWEP spawning is disabled." )
	
		return false
		
	end	

	return true
		
	
end

function GM:PlayerSpawnNPC( p, npc_type, npc_weapon )

	if not (p:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1) then
	
		p:ChatPrint( "NPC spawning is disabled." )
	
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
	
	if string.find(ent:GetClass(), "dynam") == 6 then
		return false
	end
	
	local searchPos
	
	searchPos = string.find(ent:GetClass(), "door_")
	
	if not searchPos then
		searchPos = 0
	end
	if searchPos > 1 then
		return false
	end
	
	searchPos = string.find(ent:GetClass(), "dynam")
	
	if not searchPos then
		searchPos = 0
	end
	if searchPos > 1 then
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
	local ent = tr.Entity
	if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then
		return true
	end
	--ply:ChatPrint(tostring(toolmode))
	local searchPos
	
	if string.find(ent:GetClass(), "ep_") == 2 then
		return false
	end
	
	if string.find(ent:GetClass(), "unc_") == 2 then
		return false
	end
	
	if string.find(ent:GetClass(), "pc_") == 2 then
		if string.find(tostring(ent:GetClass()),"turret") then
			if toolmode == "weld" or toolmode == "weld_ez" 
			  or toolmode == "easy_precision" or toolmode == "nocollide" then
				
			else
				return false
			end
		else
			return false
		end
	end
	
	searchPos = string.find(ent:GetClass(), "door_")
	
	if not searchPos then
		searchPos = 0
	end
	if searchPos > 1 then
		return false
	end
	
	searchPos = string.find(ent:GetClass(), "dynam")
	
	if not searchPos then
		searchPos = 0
	end
	if searchPos > 1 then
		return false
	end
	
	local owner = ent:GetNWString( "Owner", "None" )
	if owner == "Unownable" then return false end
	if owner != ply:Nick() then 
		if owner != "None" then
			ply:ChatPrint("You do not own this.")
			return false 
		end
	end
	
	if toolmode == "colour" then
		if ent:IsWorld() then return false end
		if ent:IsPlayer() then return false end
		if owner != ply:Nick() then
			ply:ChatPrint("You do not own this.")
			return false
		end
	end	
	
	if toolmode == "wire_expression" or toolmode == "wire_expression2" or toolmode == "wire_gate_expression" or toolmode == "wire_debugger" or toolmode == "wire_adv" then
		if GetConVarNumber("pnrp_exp2Level") == 0 then 
			return false 
		elseif GetConVarNumber("pnrp_exp2Level") == 1 and ply:IsAdmin() then
			return true
		elseif GetConVarNumber("pnrp_exp2Level") == 2 and (ply:IsAdmin() or ply:Team() == TEAM_ENGINEER) then
			return true
		elseif GetConVarNumber("pnrp_exp2Level") == 3 and (ply:IsAdmin() or ply:Team() == TEAM_ENGINEER or ply:Team() == TEAM_SCIENCE) then
			return true
		elseif GetConVarNumber("pnrp_exp2Level") == 4 then
			return true
		else
			return false
		end
	end
	
	--check for globally allowed tools (Admins can use all tools)
	local DoClassToolCheck = false
	if GetConVarNumber("pnrp_toolLevel") == 1 and not ply:IsAdmin() then
		DoClassToolCheck = true
	elseif GetConVarNumber("pnrp_toolLevel") == 2 and ply:Team() ~= TEAM_ENGINEER then
		DoClassToolCheck = true
	elseif GetConVarNumber("pnrp_toolLevel") == 3 and not (ply:Team() == TEAM_ENGINEER or ply:Team() == TEAM_SCIENCE) then
		DoClassToolCheck = true
	end
	
	if DoClassToolCheck then
		if not (toolmode == "remover" or toolmode == "weld" or toolmode == "weld_ez" 
		  or toolmode == "easy_precision" or toolmode == "duplicator" 
		  or toolmode == "adv_duplicator" or toolmode == "weld_ez2"
		  or toolmode == "nocollide")
		   then 
			return false
		end
	end
	
	--Restricts most tools on items in the item base
	local DoToolCheck = false
	local myClass = ent:GetClass()
	--Checks for weapon seats
	if ent:GetClass() == "prop_vehicle_prisoner_pod" then
		myClass = "weapon_seat"
	end
	--If prop_physics then check by model
	if myClass == "prop_physics" then
		local myModel = ent:GetModel()
		for itemname, item in pairs( PNRP.Items ) do
			if myModel == item.Model then DoToolCheck = true end
		end		
	else
		--Checks the itembase for the item
		local ItemID = PNRP.FindItemID( myClass )
		if ItemID != nil then DoToolCheck = true end
	end
	--If Item is found in item base, do a tool check
	if DoToolCheck then
		if not (toolmode == "weld" or toolmode == "weld_ez" 
		  or toolmode == "easy_precision" or toolmode == "weld_ez2"
		  or toolmode == "nocollide")
		   then 
			return false
		end
	end
end
hook.Add( "CanTool", "ToolCheck", ToolCheck )

--EOF