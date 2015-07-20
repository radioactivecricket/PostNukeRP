
local EntityMeta = FindMetaTable("Entity")

BannedProps = { }
ToolBlockedProps = { }
function AddBannedProp(mdl) table.insert(BannedProps, mdl) end
function AddToolBlockedProp(mdl) table.insert(ToolBlockedProps, mdl) end

AllowedProps = { }
function AddAllowedProp(mdl) table.insert(AllowedProps, mdl) end

for k, v in pairs(PNRP.JunkModels) do
	AddBannedProp(v)
end
for k, v in pairs(PNRP.ChemicalModels) do
	AddBannedProp(v)
end
for k, v in pairs(PNRP.SmallPartsModels) do
	AddBannedProp(v)
end
for k, item in pairs( PNRP.Items ) do
	if not item.UnBlock then
		AddBannedProp(item.Model)
	end
end

function PNRP.GetBannedPropsList( )
	local tbl = { }
	if !file.IsDir("PostNukeRP", "DATA" ) then file.CreateDir("PostNukeRP") end
	if file.Exists("PostNukeRP/banned_props.txt", "DATA") then
		tbl = util.JSONToTable(file.Read("PostNukeRP/banned_props.txt"))
		if tbl ~= nil then
			for k, v in pairs(tbl) do
				print("k ["..k.."] v ["..v.."]")
				AddToolBlockedProp(v)
				AddBannedProp(v)
			end
		end
	else
		file.Write("PostNukeRP/banned_props.txt",util.TableToJSON(bannedtbl))
	end
end
PNRP.GetBannedPropsList( )

function PNRP.GetAllowedPropsList( )
	local tbl = { }
	if !file.IsDir("PostNukeRP", "DATA") then file.CreateDir("PostNukeRP") end
	if file.Exists("PostNukeRP/allowed_props.txt", "DATA") then
		tbl = util.JSONToTable(file.Read("PostNukeRP/allowed_props.txt"))
		if tbl ~= nil then
			for k, v in pairs(tbl) do
				AddAllowedProp(v)
			end
		end
	else
		file.Write("PostNukeRP/allowed_props.txt",util.TableToJSON(bannedtbl))
	end
end
PNRP.GetAllowedPropsList( )

function PNRP.Start_open_PropPprotection()
	local ply = net.ReadEntity()
	local bannedtbl = { }
	if !file.IsDir("PostNukeRP", "DATA") then file.CreateDir("PostNukeRP") end
	if file.Exists("PostNukeRP/banned_props.txt", "DATA") then
		bannedtbl = util.JSONToTable(file.Read("PostNukeRP/banned_props.txt"))
	else
		file.Write("PostNukeRP/banned_props.txt",util.TableToJSON(bannedtbl))
	end
	local allowedtbl = { }
	if file.Exists("PostNukeRP/allowed_props.txt", "DATA") then
		allowedtbl = util.JSONToTable(file.Read("PostNukeRP/allowed_props.txt"))
	else
		file.Write("PostNukeRP/allowed_props.txt",util.TableToJSON(allowedtbl))
	end
	--datastream.StreamToClients(ply, "pnrp_OpenPropProtectWindow", { bannedtbl, allowedtbl } )
	
	if bannedtbl == nil then bannedtbl = { } end
	if allowedtbl == nil then allowedtbl= { } end
	
	net.Start("pnrp_OpenPropProtectWindow")
		net.WriteTable(bannedtbl)
		net.WriteTable(allowedtbl)
	net.Send(ply)
end
--datastream.Hook( "Start_open_PropProtection", PNRP.Start_open_PropPprotection )
net.Receive( "Start_open_PropProtection", PNRP.Start_open_PropPprotection )
util.AddNetworkString( "pnrp_OpenPropProtectWindow" )

function PNRP.PropProtect_AddItem( )
	local ply = net.ReadEntity()
	local model = net.ReadString()
	local switch = net.ReadDouble() --1 is add Prop Block, 2 is add Prop Allowed
	local tbl = {}
	if switch == 1 then
		--Prop Blocking 
		if file.Exists("PostNukeRP/banned_props.txt", "DATA") then
			tbl = util.JSONToTable(file.Read("PostNukeRP/banned_props.txt"))
			if tbl ~= nil then
				for k, v in pairs( tbl ) do	
					if model == v then return end
				end	
			else
				tbl = {}
			end
			table.insert(tbl, model)
			AddBannedProp(model)
			AddToolBlockedProp(model)
			file.Write("PostNukeRP/banned_props.txt",util.TableToJSON(tbl))
		else
			AddBannedProp(model)
			AddToolBlockedProp(model)
			table.insert(tbl, model)
			file.Write("PostNukeRP/banned_props.txt",util.TableToJSON(tbl))
		end
	else
		--Prop Allowing
		if file.Exists("PostNukeRP/allowed_props.txt", "DATA") then
			tbl = util.JSONToTable(file.Read("PostNukeRP/allowed_props.txt"))
			if tbl ~= nil then
				for k, v in pairs( tbl ) do	
					if model == v then return end
				end	
			else
				tbl = {}
			end
			table.insert(tbl, model)
			AddAllowedProp(model)
			file.Write("PostNukeRP/allowed_props.txt",util.TableToJSON(tbl))
		else
			table.insert(tbl, model)
			AddAllowedProp(model)
			file.Write("PostNukeRP/allowed_props.txt",util.TableToJSON(tbl))
		end
	end
end
--datastream.Hook(  "PropProtect_AddItem", PNRP.PropProtect_AddItem )
net.Receive(  "PropProtect_AddItem", PNRP.PropProtect_AddItem )

function PNRP.PropProtect_RemoveItem( )
	local ply = net.ReadEntity()
	local model = net.ReadString()
	local switch = net.ReadDouble() --1 is add Prop Block, 2 is add Prop Allowed
	local tbl = { }
	if switch == 1 then
		--Prop Banning
		if file.Exists("PostNukeRP/banned_props.txt", "DATA") then
			tbl = util.JSONToTable(file.Read("PostNukeRP/banned_props.txt"))
			if tbl ~= nil then
				for k, v in pairs( tbl ) do	
					if model == v then
						table.remove(tbl, k)
					end
				end
				file.Write("PostNukeRP/banned_props.txt",util.TableToJSON(tbl))
			end
			for k, v in pairs( BannedProps ) do	
				if model == v then
					table.remove(BannedProps, k)
					table.remove(ToolBlockedProps, k)
				end
			end
		else
			for k, v in pairs( BannedProps ) do	
				if model == v then
					table.remove(BannedProps, k)
					table.remove(ToolBlockedProps, k)
				end
			end
			file.Write("PostNukeRP/banned_props.txt",util.TableToJSON(tbl))
		end
	else
		--Prop Allowing
		if file.Exists("PostNukeRP/allowed_props.txt", "DATA") then
			tbl = util.JSONToTable(file.Read("PostNukeRP/allowed_props.txt"))
			if tbl ~= nil then
				for k, v in pairs( tbl ) do	
					if model == v then
						table.remove(tbl, k)
					end
				end
				file.Write("PostNukeRP/allowed_props.txt",util.TableToJSON(tbl))
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
			file.Write("PostNukeRP/allowed_props.txt",util.TableToJSON(tbl))
		end
	end
end
--datastream.Hook( "PropProtect_RemoveItem", PNRP.PropProtect_RemoveItem )
net.Receive( "PropProtect_RemoveItem", PNRP.PropProtect_RemoveItem )

--Checks spawn for props and removes them
function PNRP.spawnPropProtect()
	timer.Create( "spawnCheckTimer", 20, 0, function ()
		if getServerSetting("propSpawnpointProtection") == 1 then
			local fountEnts = ents.FindByClass("info_player_start")
			table.Add(fountEnts,ents.FindByClass("info_player_terrorist"))
			table.Add(fountEnts,ents.FindByClass("info_player_counterterrorist"))
			for k, v in pairs( fountEnts ) do
				local found_ents = ents.FindInSphere( v:GetPos(), 135)
				for i, ent in ipairs(found_ents) do
					local myClass = ent:GetClass()
					if myClass == "prop_physics"  and not ent.ID and not ent.crafted then
						ent:Remove()
					end
					if ent:IsDoor() then
						ent:SetNetVar("Owner", "Unownable")
					end
				end
			end
		end
	end)
end
PNRP.spawnPropProtect()

function GM:PlayerSpawnProp(ply, model)
	if not self.BaseClass:PlayerSpawnProp(ply, model) then return false end
	
	local allowed = false
	
	--Admin Create All Overide
	if ply:IsAdmin() and getServerSetting("adminCreateAll") == 1 then 
		
		allowed = true 
	
	else
	
	--Normal Allowed system
		model = string.gsub(model, "\\", "/")
		if string.find(model,  "%../") then return false end
		if string.find(model,  "//") then return false end
		-- Banned props take precedence over allowed props
		if getServerSetting("propBanning") == 1 then
			local blockProp = false
			for k, v in pairs(BannedProps) do
				if string.lower(v) == string.lower(model) then 
					blockProp = true
					for k, v in pairs(AllowedProps) do
						if v == model then blockProp = false end
					end
					if blockProp then
						ply:ChatPrint("This prop is not allowed.")
						return false 
					end
				end
			end
		end
	
		if getServerSetting("propAllowing") == 1 then
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
		return true
	end
	return false
end

function GM:PlayerSpawnedProp( ply, model, ent )
	local plUID = PNRP:GetUID( ply )
	if getServerSetting("propPay") == 1 then
		
		local price = math.Round(((ent:BoundingRadius() + ent:GetPhysicsObject():GetMass()) / 2) * (getServerSetting("propCost") / 100))
		
		if price < 1 then price = 1 end
		--ply:ChatPrint("Price:  "..tostring(price))
		
		--Admin No Cost Overide
		local adminCostOveride = false
		if ply:IsAdmin() and getServerSetting("adminNoCost") == 1 then 
			adminCostOveride = true 
		else
			adminCostOveride = false
		end
		
		if ply:GetResource("Scrap") >= price or adminCostOveride == true then
			ply:ChatPrint(tostring(price).." scrap used to create this prop.")
			ply:DecResource("Scrap", price)
			ent:SetNetVar( "Owner_UID", plUID )
			ent:SetNetVar( "Owner", ply:Nick())
			ent:SetNetVar( "ownerent", ply )
		else
			ply:ChatPrint(tostring(price).." scrap needed to create this prop.")
			ent:Remove()
		end
	else
		ent:SetNetVar( "Owner_UID", plUID )
		ent:SetNetVar( "Owner", ply:Nick())
		ent:SetNetVar( "ownerent", ply )
	end
end

function GM:PlayerSpawnVehicle( p, class, vehtbl )
	if not (p:IsAdmin() and getServerSetting("adminCreateAll") == 1) then
		for _, v in pairs(AllowedProps) do
			if class == v then return true end
		end
		p:ChatPrint( "Vehicle spawning is disabled." )
		return false	
	end	
	return true
end	

function GM:PlayerSpawnedVehicle(ply, ent)
	local plUID = PNRP:GetUID( ply )
	ent:SetNetVar( "Owner_UID", plUID )
	ent:SetNetVar( "Owner", ply:Nick())
	ent:SetNetVar( "ownerent", ply )
end

function GM:PlayerSpawnRagdoll( p, model )
	if not (p:IsAdmin() and getServerSetting("adminCreateAll") == 1) then
		p:ChatPrint( "Ragdoll spawning is disabled." )
		return false
	end	
	return true
end	

function GM:PlayerSpawnedRagdoll(ply, model, ent)
	local plUID = PNRP:GetUID( ply )
	ent:SetNetVar( "Owner_UID", plUID )
	ent:SetNetVar( "Owner", ply:Nick())
	ent:SetNetVar( "ownerent", ply )
end

function GM:PlayerSpawnEffect( p, model )
	if not (p:IsAdmin() and getServerSetting("adminCreateAll") == 1) then
		p:ChatPrint( "Effect spawning is disabled." )
		return false
	end	
	return true
end	

function GM:PlayerGiveSWEP( ply, class, info )
	if not (ply:IsAdmin() and getServerSetting("adminCreateAll") == 1) then
		ply:ChatPrint( "Weapon spawning is disabled." )
		return false
	end	
	return true
end	

function GM:PlayerSpawnedEffect(ply, model, ent)
	local plUID = PNRP:GetUID( ply )
	ent:SetNetVar( "Owner_UID", plUID )
	ent:SetNetVar( "Owner", ply:Nick())
	ent:SetNetVar( "ownerent", ply )
end


function GM:PlayerSpawnSENT( p, classname )
	if not (p:IsAdmin() and getServerSetting("adminCreateAll") == 1) then
		p:ChatPrint( "SEnt spawning is disabled." )
		return false
	end
	
	p:ChatPrint("Classname:  "..classname)
--	if not (p:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1) then
--		for k, v in pairs(PNRP.Items) do
--			if v.ClassSpawn == classname then
--				return false
--			end
--		end
		
--		if string.find(classname, "eapon") == 2 then
--			return false
--		end
--	end
	
	return true
end

function GM:PlayerSpawnedSENT(ply, ent)
	local plUID = PNRP:GetUID( ply )
	ent:SetNetVar( "Owner_UID", plUID )
	ent:SetNetVar( "Owner", ply:Nick())
	ent:SetNetVar( "ownerent", ply )
end

function GM:PlayerSpawnSWEP( ply, class, wep )
	ply:ChatPrint( "Spawning the F-ing Weapon" )
	if not (ply:IsAdmin() and getServerSetting("adminCreateAll") == 1) then
		ply:ChatPrint( "SWEP spawning is disabled." )
		return false	
	end	
	return true
end

function GM:PlayerSpawnNPC( p, npc_type, npc_weapon )
	if not (p:IsAdmin() and getServerSetting("adminCreateAll") == 1) then
		p:ChatPrint( "NPC spawning is disabled." )
		return false	
	end	
	return true
end	

function PlayerUse(ply, ent)
	if ( !IsValid( ent ) or !ent:IsVehicle() ) then return end
	
	if ( ply:GetEyeTrace().HitBox == 3 ) then
		
		if tostring(ent:GetNetVar( "Owner_UID" , "None" )) == PNRP:GetUID(ply) then
			local item = PNRP.SearchItembase( ent )
			if item then
				ply:SendLua( "CurCarMaxWeight = "..tostring(item.Capacity) )
			--	ply:ConCommand("pnrp_carinv")
				PNRP.OpenItemInventory( ent.iid, ply, item.ID )
			end
		end
	
		return false
	end
	return true
end
hook.Add("PlayerUse", "PlayerUse", PlayerUse)

function PuntCheck(ply, ent)
	if not (ply:IsAdmin() and getServerSetting("adminTouchAll") == 1) then
		if getServerSetting("AllowPunt") == 1 then
			return true
		else
			local Item = PNRP.SearchItembase( ent )
			if Item != nil then
				if Item.AllowPunt == true then
					return true
				end
			end
			return false
		end
	end
	return true
end
hook.Add("GravGunPunt", "PuntCheck", PuntCheck)

function isPlayerAndAdmin( ent )
	if ent:IsPlayer() then
		if ent:IsSuperAdmin() or ent:IsAdmin() then
			return true
		else
			return false
		end
	else
		return false
	end
end

function PickupCheck( ply, ent)
	--admin can do whatever they want
	if ply:IsSuperAdmin() and getServerSetting("adminTouchAll") == 1 then return true end
	
	if ply:IsAdmin() and getServerSetting("adminTouchAll") == 1 and not isPlayerAndAdmin( ent ) then return true end
	
	if ent:IsPlayer() then return false end
	
	if ent.moveActive == false then return false end
	
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
	
	local plUID = PNRP:GetUID( ply )
	local owner = ent:GetNetVar( "Owner", "None" )
	local ownerUID = ent:GetNetVar( "Owner_UID", "None" )
	
	local playerPos = ply:GetShootPos()
	local entPos = ent:GetPos()
	local myDistance = playerPos:Distance( entPos )
	
	--Check distance first.  Don't want people picking stuff from across the map.
	if myDistance > 300 then return false end
	
	--Unownable should be un-pickupable, so we check that next
	if owner == "Unownable" then return false end
	
	--If player owns the prop
	if ownerUID == plUID then return true end
	if ent.GetPlayer and type(ent.GetPlayer) == "function" then
		if ply == ent:GetPlayer() then return true end
	end
--	if ownerUID ~= plUID then 
--		if owner ~= "None" and owner ~= "World" then
--			return false
--		end
--	end
	--if owner == "None" or owner == "World" then return true end
	
	--Checks buddy system
	local ownerEnt = ent:GetNetVar( "ownerent", nil )
	if ent.GetPlayer and type(ent.GetPlayer) == "function" and not ownerEnt then
		ownerEnt = ent:GetPlayer() or nil
	end
	if ownerEnt then
		if ownerEnt.PropBuddyList then
			if ownerEnt.PropBuddyList[PNRP:GetUID( ply )] then
				return true
			elseif tostring(ownerEnt.CommunityBuddy) == "true" then
				local entCID = tonumber(ownerEnt:GetNetVar("cid", -1))
				local plyCID = tonumber(ply:GetNetVar("cid", -1))
				
				if plyCID >= 0 and entCID == plyCID then
					return true
				elseif tostring(ownerEnt.AllyBuddy) == "true" and (ply.ComDiplomacy[tonumber(entCID)] or "none") == "ally" then
					return true
				else
					return false
				end
			else
				return false
			end
		end
	end
	
	if owner == "None" or owner == "World" then
		return true
	end
	return false
end
hook.Add( "PhysgunPickup", "pickupCheck", PickupCheck )

function PhysUnfreezeCheck ( ply, ent, physobj )
	--admin can do whatever they want
	if ply:IsAdmin() and getServerSetting("adminTouchAll") == 1 then return true end
	
	if ent.moveActive == false then return false end

	--get the entity we're looking at, do the same checks as when doing pickup
	--local ent = ply:GetEyeTrace().Entity
	
	local plUID = PNRP:GetUID( ply )
	local owner = ent:GetNetVar( "Owner", "None" )
	local ownerUID = ent:GetNetVar( "Owner_UID", "None" )
	
	local playerPos = ply:GetShootPos()
	local entPos = ent:GetPos()
	local myDistance = playerPos:Distance( entPos )
	
	if myDistance > 300 then return false end
	if owner == "Unownable" then return false end
	--if owner == "None" or owner == "World" then return true end
	if plUID == ownerUID then return true end
	if ent.GetPlayer and type(ent.GetPlayer) == "function" then
		if ply == ent:GetPlayer() then return true end
	end
	
	--if owner == "None" or owner == "World" then return true end
	
	--Checks buddy system
	local ownerEnt = ent:GetNetVar( "ownerent", nil )
	if ent.GetPlayer and type(ent.GetPlayer) == "function" and not ownerEnt then
		ownerEnt = ent:GetPlayer() or nil
	end
	if ownerEnt then
		if ownerEnt.PropBuddyList then
			if ownerEnt.PropBuddyList[PNRP:GetUID( ply )] then
				return true
			else 
				return false
			end
		end
	end
	
	if owner == "None" or owner == "World" then
		return true
	end
	return false
end
hook.Add("CanPlayerUnfreeze", "PhyUnfreezeCheck", PhysUnfreezeCheck)

function ToolCheck( ply, tr, toolmode )
	local ent = tr.Entity
	
	if (not ent) and (not ent:IsWorld()) then return false end

	--If player is admin (Admin Touch All overide)
	if ply:IsAdmin() and getServerSetting("adminTouchAll") == 1 then
		return true
	end
	
	--Add tool checks for ASSMod and SAT
	if ASS_VERSION then
		local ASS_Plugin = ASS_FindPlugin("Sandbox Tool/Swep/Sent Protection")
		if ASS_Plugin then
			ASS_Check = ASS_Plugin.CanTool( ply, tr, toolmode )
			if ASS_Check == false then return false end
		end
	end
	if SAT then
		SAT_CHECK = SAT_ToolCheck( ply, tr, toolmode )
		if !SAT_CHECK then return false end
	end
	
	if toolmode == "pnrp_powerlinker" then return true end
	
	if ent.moveActive == false then return false end
	
	--Blocks tool usage to these items
	for k, v in pairs(ToolBlockedProps) do
		if string.lower(v) == string.lower(ent:GetModel()) then 
			ply:ChatPrint("This is not allowed.")
			return false 
		end
	end
	
	local searchPos
	--Blocks weapons
	if string.find(ent:GetClass(), "ep_") == 2 then
		return false
	end
	--Blocks Func Ents
	if string.find(ent:GetClass(), "unc_") == 2 then
		return false
	end
	--Blocks NPCs and restricts use on turrets
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
	
	--Restrics certin tools on vehicles
	local plyTool = ply:GetActiveWeapon( )
	if ent:IsVehicle() then
		if toolmode == "nocollide_world" or toolmode == "AdvBallsocket" 
			or toolmode == "ballsocket_adv" or toolmode == "ballsocket_ez" then
			ply:ChatPrint("Tool not allowed on this.")
			return false
		end
		if toolmode == "nocollide" then
			if( ply:KeyDown( IN_ATTACK2 ) ) then
				ply:ChatPrint("No-collide all not allowed on this.")
				return false
			end
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
	
	--Checks ownership
	local plUID = PNRP:GetUID( ply )
	local owner = ent:GetNetVar( "Owner", "None" )
	local ownerUID = ent:GetNetVar( "Owner_UID", "None" )
	if owner == "Unownable" then return false end
	
	
	local IsBuddy = false
	
	--Checks buddy system
	local ownerEnt = ent:GetNetVar( "ownerent", nil )
	if not ent:IsWorld() then
		if ent.GetPlayer and type(ent.GetPlayer) == "function" and not ownerEnt then
			ownerEnt = ent:GetPlayer() or nil
		end
		if ownerEnt then
			if ownerEnt.PropBuddyList and ownerEnt != ply then
				if ownerEnt.PropBuddyList[PNRP:GetUID( ply )] then
					IsBuddy = true
				elseif tostring(ownerEnt.CommunityBuddy) == "true" then
					local entCID = tonumber(ownerEnt:GetNetVar("cid", -1))
					local plyCID = tonumber(ply:GetNetVar("cid", -1))
					
					if plyCID >= 0 and entCID == plyCID then
						IsBuddy = true
					elseif tostring(ownerEnt.AllyBuddy) == "true" and (ply.ComDiplomacy[tonumber(entCID)] or "none") == "ally" then
						IsBuddy = true
					else
						IsBuddy = false
					end
				else 
					IsBuddy = false
				end
			end
		end
	end
	
	if not IsBuddy then
		if ownerUID != plUID then 
			if owner != "World" then
				if owner != "None" then
					ply:ChatPrint("You do not own this.")
					return false 
				elseif ent.GetPlayer and type(ent.GetPlayer) == "function" then
					if ent:GetPlayer() then
						if ent:GetPlayer() ~= ply then
							ply:ChatPrint("You do not own this.")
							return false 
						end
					end
				end
			elseif ent.GetPlayer and type(ent.GetPlayer) == "function" then
				if ent:GetPlayer() then
					if ent:GetPlayer() ~= ply then
						ply:ChatPrint("You do not own this.")
						return false 
					end
				end
			end
		end
	end
	
	if toolmode == "colour" or toolmode == "material" or toolmode == "unbreakable" then
		if ent:IsWorld() then return false end
		if ent:IsPlayer() then return false end
		if ent:IsNPC() then return false end
		if not IsBuddy then
			if ownerUID != plUID then
				ply:ChatPrint("You do not own this.")
				return false
			end
		end
	end	
	
	if toolmode == "wire_expression" or toolmode == "wire_expression2" or toolmode == "wire_gate_expression" or toolmode == "wire_debugger" or toolmode == "wire_adv" then
		if getServerSetting("exp2Level") == 0 then 
			return false 
		elseif getServerSetting("exp2Level") == 1 and ply:IsAdmin() then
			return true
		elseif getServerSetting("exp2Level") == 2 and (ply:IsAdmin() or ply:Team() == TEAM_ENGINEER) then
			return true
		elseif getServerSetting("exp2Level") == 3 and (ply:IsAdmin() or ply:Team() == TEAM_ENGINEER or ply:Team() == TEAM_SCIENCE) then
			return true
		elseif getServerSetting("exp2Level") == 4 then
			return true
		else
			return false
		end
	end
	
	--check for globally allowed tools (Admins can use all tools)
	local DoClassToolCheck = false
	if getServerSetting("toolLevel") == 1 and not ply:IsAdmin() then
		DoClassToolCheck = true
	elseif getServerSetting("toolLevel") == 2 and ply:Team() ~= TEAM_ENGINEER then
		DoClassToolCheck = true
	elseif getServerSetting("toolLevel") == 3 and not (ply:Team() == TEAM_ENGINEER or ply:Team() == TEAM_SCIENCE) then
		DoClassToolCheck = true
	end
	
	if string.find(toolmode, "turret") then
		ply:ChatPrint("Turrets blocked.")
		return false
	end
	
	if string.find(toolmode, "igniter") then
		ply:ChatPrint("Igniter blocked.")
		return false
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
	
	if string.find(toolmode, "dup") then
		if PNRP.FindItemID( myClass ) and myClass != "prop_physics" then
			print(tostring(PNRP.FindItemID( myClass )))
			ply:ChatPrint("Duplication blocked.")
			return false
		end
	end

	--If prop_physics then check by model
	if myClass == "prop_physics" then
		local myModel = ent:GetModel()
		for itemname, item in pairs( PNRP.Items ) do
			if myModel == item.Model and not item.UnBlock then DoToolCheck = true end
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
	
	--if owner == "None" or owner == "World" then return true end
	if owner == "None" or owner == "World" then
		return true
	end
end
hook.Add( "CanTool", "ToolCheck", ToolCheck )

function PNRP.PlayerExitVehicle( ply, vehicle )
	if vehicle.ExitAng then
		local origin = vehicle:GetPos()
		
	end
end
hook.Add("PlayerLeaveVehicle", "PlayerExitVehicle", PNRP.PlayerExitVehicle )

function PNRP.removeCarSeats( ent )
	local seats = constraint.FindConstraints( ent, "Weld" )
	for _, seat in pairs(seats) do
		if seat.Entity[2].Entity.seat == 1 then
			seat.Entity[2].Entity:Remove()
		end
	end
end
hook.Add( "EntityRemoved", "removeCarSeats", PNRP.removeCarSeats )
--EOF