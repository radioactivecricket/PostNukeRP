--Chat Commands
PNRP.ChatCommands = { }
PNRP.ChatConCommands = { }
PNRP.PendingInvites = { }

function PNRP.ChatCmd( cmdtext, callback )

	PNRP.ChatCommands[cmdtext] = callback

end

function PNRP.ChatConCmd( cmdtext, callback )

	PNRP.ChatConCommands[cmdtext] = callback

end

function PNRP.chtTest( ply, cmd, text )
	
	ply:ChatPrint("Test")

end
PNRP.ChatCmd( "/test", PNRP.chtTest )

PNRP.ChatConCmd( "/classmenu", "pnrp_classmenu" )
PNRP.ChatConCmd( "/shop", "pnrp_buy_shop" )
PNRP.ChatConCmd( "/inv", "pnrp_inv" )
PNRP.ChatConCmd( "/salvage", "pnrp_salvage" )

/*---------------------------------------------------------
  Save/Load
---------------------------------------------------------*/
function GM.SaveCharacter(ply,cmd,args)
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/Saves") then file.CreateDir("PostNukeRP/Saves") end
	
--	local curEndurance = ply:GetNetworkedInt("Endurance")
	
	local tbl = {}
	tbl["class"] = ply:Team()
	tbl["health"] = ply:Health()
	tbl["armor"] = ply:Armor()
	tbl["endurance"] = ply:GetTable().Endurance
	tbl["hunger"] = ply:GetTable().Hunger
	tbl["resources"] = {}
	tbl["date"] = os.date("%A %m/%d/%y")
	tbl["name"] = ply:Nick()
	tbl["weapons"] = {}
	tbl["ammo"] = {}
	tbl["community"] = ply:GetTable().Community
	
	if tbl["community"] then
		AmendCommunityInfo( tbl["community"], ply:Nick(), ply:GetTable().CommunityRank, os.date(), ply:GetModel(), ply:UniqueID() )
	end
	
	--Sets Resources
	for k,v in pairs(ply.Resources) do
		if v <= 0 then
			v = 0
		end
		tbl["resources"][k] = v
	end
	--Sets Weapons
	for k, v in pairs(ply:GetWeapons()) do
		local wepCheck = PNRP.CheckDefWeps(v)
		if !wepCheck then
--			local ammotbl = {}
			local ammo = ply:GetAmmoCount( v:GetPrimaryAmmoType() ) 
			local ammoType = PNRP.ConvertAmmoType(v:GetPrimaryAmmoType())
			--tbl["weapons"][tostring(v:GetClass())] = tostring(ammo)
--			tbl["weapons"][tostring(v:GetClass())] = 1
			if v:GetClass() == "weapon_radio" then
				tbl["weapons"][tostring(v:GetClass())] = 1
				tbl["ammo"]["none"] = 0
			end
			if ammoType then
--				ammotbl[ammoType] = ammo
				tbl["weapons"][tostring(v:GetClass())] = 1
				--grenade fix
				if tostring(v:GetClass()) == "weapon_frag" then
					ammoType = "grenade"
					tbl["ammo"][ammoType] = ammo - 1  --Removes one since it gives you one as a weapon
				else
					tbl["ammo"][ammoType] = ammo
				end
			end
		end
	end 
	Msg("Player Data Saved.\n")
	ply:ChatPrint("Player Saved.")
	file.Write("PostNukeRP/Saves/"..ply:UniqueID()..".txt",util.TableToKeyValues(tbl))
end

function GM.LoadCharacter( ply )
	if file.Exists("PostNukeRP/Saves/"..ply:UniqueID()..".txt") then
		local tbl = util.KeyValuesToTable(file.Read("PostNukeRP/Saves/"..ply:UniqueID()..".txt"))
		
		ply:SetTeam( tonumber(tbl.class) )
		
		PNRP:LoadRecources(ply, tbl)
		
--		PNRP:LoadWeaps(ply, tbl)
		
	else
		ply:SetResource("Scrap",0)
		ply:SetResource("Small_Parts",0)
		ply:SetResource("Chemicals",0)
	end
end

function PNRP:LoadRecources(ply, tbl)
	if tbl["resources"] then
		for k,v in pairs(tbl["resources"]) do
			ply:SetResource(string.Capitalize(k),v)
		end
	end
end

function GM.LoadStatus( ply )
	if file.Exists("PostNukeRP/Saves/"..ply:UniqueID()..".txt") then
		local tbl = util.KeyValuesToTable(file.Read("PostNukeRP/Saves/"..ply:UniqueID()..".txt"))
		--Fix for the odd negative HP issue that happens some times.
		if tbl["health"] then 
			if tbl["health"] <= 0 then
				setHP = 100
			else
				setHP = tbl["health"]
			end
			ply:SetHealth( setHP ) 
		end
		if tbl["armor"] then ply:SetArmor( tbl["armor"] ) end
		--if tbl["endurance"] then ply:SetNetworkedInt("Endurance", tbl["endurance"] ) end
		if tbl["endurance"] then ply:GetTable().Endurance = tbl["endurance"] end
		if tbl["hunger"] then ply:GetTable().Hunger = tbl["hunger"] end
		if tbl["community"] then 
			--ply:GetTable().Community = tbl["community"]
			LoadCommunityInfo( ply, tbl["community"] )
		else 
			ply:GetTable().Community = nil
		end
		
		SendEndurance( ply )
		
	end
end

function GM.LoadWeaps( ply )
	if file.Exists("PostNukeRP/Saves/"..ply:UniqueID()..".txt") then
		local tbl = util.KeyValuesToTable(file.Read("PostNukeRP/Saves/"..ply:UniqueID()..".txt"))
--		ply:RemoveAllAmmo()
		
		if tbl["weapons"] then
			for k,v in pairs(tbl["weapons"]) do
				ply:Give(string.lower(k))
--				if v then
--					for ammoType,ammoNum in pairs(v) do
--						ply:GiveAmmo(ammoNum, ammoType)
--					end
--				end
			end
			for ammoType,ammoNum in pairs(tbl["ammo"]) do
				ply:GiveAmmo(ammoNum, ammoType)
			end
		end
	end
end

concommand.Add( "pnrp_save", GM.SaveCharacter )
PNRP.ChatConCmd( "/save", "pnrp_save" )

-- Community Functions

-- Loads a player's community information.
function LoadCommunityInfo( ply, community )
	if file.Exists("PostNukeRP/Communities/"..tostring(community)..".txt") then
		local communityTbl = glon.decode(file.Read("PostNukeRP/Communities/"..community..".txt"))
		
		local found = false
		--Find player in the community's file.  If they aren't there, they were removed while offline.
		for k, v in pairs(communityTbl["users"]) do
			if k == ply:UniqueID() then
				ply:GetTable().Community = community
				ply:GetTable().CommunityRank = v["rank"]
				ply:SetNWString("community", community)
				if ply:Nick() ~= v["name"] then
					AmendCommunityInfo( community, ply:Nick(), nil, nil, nil, ply:UniqueID() )
				end
				found = true
			end
		end
		if not found then
			ply:GetTable().Community = nil
			ply:GetTable().CommunityRank = nil
			ply:SetNWString("community", "N/A")
		end
	else
		ply:GetTable().Community = nil
		ply:GetTable().CommunityRank = nil
		ply:SetNWString("community", "N/A")
	end
end

-- Edits players in the list.
function AmendCommunityInfo( community, name, rank, lastlog, model, uniqueid )
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/Communities") then file.CreateDir("PostNukeRP/Communities") end
	local communityTbl = {}
	
	if file.Exists("PostNukeRP/Communities/"..tostring(community)..".txt") then
		communityTbl = glon.decode(file.Read("PostNukeRP/Communities/"..community..".txt"))
		
		--UniqueID is optional.  Makes it a quicker, more optimized search.
		local found = false
		if uniqueid then
			if name then
				communityTbl["users"][uniqueid].name = name
			end
			if rank then
				communityTbl["users"][uniqueid].rank = rank
				
				local target = player.GetByUniqueID(uniqueid)
				if target then
					target:GetTable().CommunityRank = rank
				end
			end
			if lastLog then
				communityTbl["users"][uniqueid].lastlog = lastlog
			end
			if model then
				communityTbl["users"][uniqueid].model = model
			end
			found = true
		else
			
			for k, v in pairs(communityTbl["users"]) do
				if v.name == name then
					if rank then
						communityTbl["users"][k].rank = rank
					end
					if lastLog then
						communityTbl["users"][k].lastlog = lastlog
					end
					if model then
						communityTbl["users"][k].model = model
					end
					found = true
					break
				end
			end
			
		end
		if not found then
			ErrorNoHalt("Player not found in community file!\n")
		end
		if found then file.Write("PostNukeRP/Communities/"..community..".txt",glon.encode(communityTbl)) end
	else
		--Throws a lua error without halting the script.
		ErrorNoHalt("Cannot amend a community file that doesn't exist!\n")
	end
end

-- Actually makes new communities, or adds a player to a community.  Can only be done in game, for good reason.
function NewCommunityInfo( ply, community )
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/Communities") then file.CreateDir("PostNukeRP/Communities") end
	local communityTbl = {}
	
	if file.Exists("PostNukeRP/Communities/"..tostring(community)..".txt") then
		communityTbl = glon.decode(file.Read("PostNukeRP/Communities/"..community..".txt"))
		
		communityTbl["users"][ply:UniqueID()] = {}
		communityTbl["users"][ply:UniqueID()].name = ply:Nick()
		communityTbl["users"][ply:UniqueID()].rank = 1
		communityTbl["users"][ply:UniqueID()].lastlog = os.date()
		communityTbl["users"][ply:UniqueID()].model = ply:GetModel()
		
		ply:GetTable().Community = community
		ply:SetNWString("community", community)
		ply:GetTable().CommunityRank = 1
		ply:ConCommand("pnrp_save")
	else
		ply:GetTable().Community = community
		ply:SetNWString("community", community)
		ply:GetTable().CommunityRank = 3
		
		communityTbl["users"] = {}
		communityTbl["users"][ply:UniqueID()] = {}
		communityTbl["users"][ply:UniqueID()].name = ply:Nick()
		communityTbl["users"][ply:UniqueID()].rank = 3
		communityTbl["users"][ply:UniqueID()].lastlog = os.date()
		communityTbl["users"][ply:UniqueID()].model = ply:GetModel()
		
		communityTbl["res"] = {}
		communityTbl["res"]["Scrap"] = 0
		communityTbl["res"]["Small_Parts"] = 0
		communityTbl["res"]["Chemicals"] = 0
		
		communityTbl["inv"] = {}
		ply:ConCommand("pnrp_save")
	end
	file.Write("PostNukeRP/Communities/"..community..".txt",glon.encode(communityTbl))
end

-- Will delete a community automatically when users becomes 0.
function RemCommunityInfo( community, name, rank, uniqueid )
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/Communities") then file.CreateDir("PostNukeRP/Communities") end
	local communityTbl = {}
	local wasOwner = false
	
	if file.Exists("PostNukeRP/Communities/"..tostring(community)..".txt") then
		communityTbl = glon.decode(file.Read("PostNukeRP/Communities/"..community..".txt"))
		
		--UniqueID is optional.  Makes it a quicker, more optimized search.
		local found = false
		if uniqueid then
			communityTbl["users"][uniqueid] = nil
			local myUser = player.GetByUniqueID(uniqueid)
			if myUser:GetTable().CommunityRank > 2 then wasOwner = true end
			wasOwner = (myUser:GetTable().CommunityRank > 2)
			myUser:GetTable().Community = nil
			myUser:GetTable().CommunityRank = nil
			myUser:SetNWString("community", "N/A")
			myUser:ChatPrint("You've been removed from the community named "..community..".")
			found = true
		else
			
			for k, v in pairs(communityTbl["users"]) do
				if v.name == name then
					if v.rank > 2 then wasOwner = true end
					communityTbl["users"][k] = nil
					for _, myUser in pairs(player.GetAll()) do
						if myUser:Nick() == name then
							myUser:GetTable().Community = nil
							myUser:GetTable().CommunityRank = nil
							myUser:SetNWString("community", "N/A")
							myUser:ChatPrint("You've been removed from the community named "..community..".")
							break
						end
					end
					found = true
					break
				end
			end
			
		end
		if not found then
			ErrorNoHalt("Player not found in community file!\n")
		end
		if found then file.Write("PostNukeRP/Communities/"..community..".txt",glon.encode(communityTbl)) end
		if table.Count(communityTbl["users"]) < 1 then
			file.Delete("PostNukeRP/Communities/"..string.lower(community)..".txt")
		else
			if not wasOwner then return end
			local hasOwner = false
			for k, v in pairs(communityTbl["users"]) do
				if v["rank"] == 3 then
					hasOwner = true
					break
				end
			end
			if not hasOwner then
				local hasOfficer = false
				for k, v in pairs(communityTbl["users"]) do
					if v["rank"] == 2 then
						hasOfficer = true
						AmendCommunityInfo( community, v["name"], 3, nil, nil, nil )
						for _, myUser in pairs(player.GetAll()) do
							if myUser:Nick() == v["name"] then
								myUser:GetTable().CommunityRank = 3
								myUser:ChatPrint("You've been made leader of "..community..".")
								break
							end
						end
						break
					end
				end
				if not hasOfficer then
					for k, v in pairs(communityTbl["users"]) do
						AmendCommunityInfo( community, nil, 3, nil, nil, k )
						for _, myUser in pairs(player.GetAll()) do
							if myUser:Nick() == v["name"] then
								myUser:GetTable().CommunityRank = 3
								myUser:ChatPrint("You've been made leader of "..community..".")
								break
							end
						end
						break
					end
				end
			end
		end
	else
		--Throws a lua error without halting the script.
		ErrorNoHalt("Cannot remove a user from a community file that doesn't exist!\n")
	end
end

-- Removes a community entirely.  The community res and inventory will fly into the void of nothingness.
function DelCommunity( community )
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/Communities") then file.CreateDir("PostNukeRP/Communities") end
	
	if file.Exists("PostNukeRP/Communities/"..tostring(community)..".txt") then
		file.Delete("PostNukeRP/Communities/"..string.lower(community)..".txt")
	end
end

-- Sets community resources
function SetCommunityRes( community, scrap, small, chems )
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/Communities") then file.CreateDir("PostNukeRP/Communities") end
	local communityTbl = {}
	
	if file.Exists("PostNukeRP/Communities/"..tostring(community)..".txt") then
		communityTbl = glon.decode(file.Read("PostNukeRP/Communities/"..community..".txt"))
		
		communityTbl["res"]["Scrap"] = scrap
		communityTbl["res"]["Small_Parts"] = small
		communityTbl["res"]["Chemicals"] = chems
		
		file.Write("PostNukeRP/Communities/"..community..".txt",glon.encode(communityTbl))
	else
		ErrorNoHalt("player_functions.lua:  Line 409  Community table not found!\n")
	end
end

function AddCommunityRes( community, mytype, amount )
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/Communities") then file.CreateDir("PostNukeRP/Communities") end
	local communityTbl = {}
	
	if file.Exists("PostNukeRP/Communities/"..tostring(community)..".txt") then
		communityTbl = glon.decode(file.Read("PostNukeRP/Communities/"..community..".txt"))
		
		communityTbl["res"][mytype] = communityTbl["res"][mytype] + amount
		
		file.Write("PostNukeRP/Communities/"..community..".txt",glon.encode(communityTbl))
	else
		ErrorNoHalt("player_functions.lua:  Line 425  Community table not found!\n")
	end
end

function SubCommunityRes( community, mytype, amount )
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/Communities") then file.CreateDir("PostNukeRP/Communities") end
	local communityTbl = {}
	
	if file.Exists("PostNukeRP/Communities/"..tostring(community)..".txt") then
		communityTbl = glon.decode(file.Read("PostNukeRP/Communities/"..community..".txt"))
		
		communityTbl["res"][mytype] = communityTbl["res"][mytype] - amount
		if communityTbl["res"][mytype] < 0 then communityTbl["res"][mytype] = 0 end
		
		file.Write("PostNukeRP/Communities/"..community..".txt",glon.encode(communityTbl))
	else
		ErrorNoHalt("player_functions.lua:  Line 442  Community table not found!\n")
	end
end

function AddCommunityItem( community, mytype, amount )
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/Communities") then file.CreateDir("PostNukeRP/Communities") end
	local communityTbl = {}
	
	if file.Exists("PostNukeRP/Communities/"..tostring(community)..".txt") then
		communityTbl = glon.decode(file.Read("PostNukeRP/Communities/"..community..".txt"))
		
		if communityTbl["inv"][mytype] then
			communityTbl["inv"][mytype] = communityTbl["inv"][mytype] + amount
		else
			communityTbl["inv"][mytype] = amount
		end
		
		file.Write("PostNukeRP/Communities/"..community..".txt",glon.encode(communityTbl))
	else
		ErrorNoHalt("player_functions.lua:  Line 466  Community table not found!\n")
	end
end

function SubCommunityItem( community, mytype, amount )
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/Communities") then file.CreateDir("PostNukeRP/Communities") end
	local communityTbl = {}
	
	if file.Exists("PostNukeRP/Communities/"..tostring(community)..".txt") then
		communityTbl = glon.decode(file.Read("PostNukeRP/Communities/"..community..".txt"))
		
		communityTbl["inv"][mytype] = communityTbl["inv"][mytype] - amount
		if communityTbl["inv"][mytype] <= 0 then communityTbl["inv"][mytype] = nil end
		
		file.Write("PostNukeRP/Communities/"..community..".txt",glon.encode(communityTbl))
	else
		ErrorNoHalt("player_functions.lua:  Line 482  Community table not found!\n")
	end
end

function GetCommunityTbl( community )
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/Communities") then file.CreateDir("PostNukeRP/Communities") end
	local communityTbl = {}
	
	if file.Exists("PostNukeRP/Communities/"..tostring(community)..".txt") then
		communityTbl = glon.decode(file.Read("PostNukeRP/Communities/"..community..".txt"))
		return communityTbl
	else
		ErrorNoHalt("player_functions.lua:  Line 455  Community table not found!\n")
		return nil
	end
end

-- Actual commands
--Opens the Community Menu
function PNRP.OpenMainCommunity(ply)
	
	local PlayerCommunityName
	local tbl = { }
	
	PlayerCommunityName = ply:GetTable().Community
	if PlayerCommunityName == nil then
		PlayerCommunityName = "none"
	else
		tbl = GetCommunityTbl( PlayerCommunityName )
	end
	
	datastream.StreamToClients(ply, "pnrp_OpenCommunityWindow", { PlayerCommunityName, tbl })
		

end
concommand.Add("pnrp_OpenCommunity", PNRP.OpenMainCommunity)

function PlyDelComm(ply, cmd, args)
	if ply:GetTable().Community and ply:GetTable().CommunityRank > 2 then
		DelCommunity( ply:GetTable().Community )
		
		for _, v in pairs(player.GetAll()) do
			if v:GetTable().Community == ply:GetTable().Community and v ~= ply then
				v:GetTable().Community = nil
				v:GetTable().CommunityRank = nil
				v:SetNWString("community", "N/A")
				
				v:ChatPrint( "Your community, "..ply:GetTable().Community..", has been deleted by an owner!" )
			end
		end
		ply:GetTable().Community = nil
		ply:GetTable().CommunityRank = nil
		ply:SetNWString("community", "N/A")
		ply:ChatPrint( "The community has been successfully deleted." )
	else
		ply:ChatPrint( "Unable to delete.  Either you do not have the rank to do this, or you are not part of a community." )
	end
end
concommand.Add( "pnrp_delcomm", PlyDelComm )
PNRP.ChatConCmd( "/delcomm", "pnrp_delcomm" )

function PlyInvComm(ply, cmd, args)
	if ply:GetTable().Community and ply:GetTable().CommunityRank > 1 then
		local trgName = args[1]
		local trgEnt = NullEntity()
		for _, v in pairs(player.GetAll()) do
			if v:Nick() == trgName then
				trgEnt = v
			end
		end
		
		if trgEnt:IsValid() then
			-- NewCommunityInfo( trgEnt, ply:GetTable().Community )
			if PNRP.PendingInvites[trgEnt:Nick()] then
				ply:ChatPrint( trgEnt:Nick().." already has another invite pending." )
				return
			end
			ply:ChatPrint( trgEnt:Nick().." has been invited to the community!" )
			
			PNRP.PendingInvites[trgEnt:Nick()] = ply:GetTable().Community
			umsg.Start( "sendinvite", trgEnt )
				umsg.String( ply:Nick() )
				umsg.String( ply:GetTable().Community )
			umsg.End()

		else
			ply:ChatPrint( "Player not found!" )
		end
	else
		ply:ChatPrint( "You do not have the community permissions to do this!" )
	end
end
concommand.Add( "pnrp_invcomm", PlyInvComm )
PNRP.ChatConCmd( "/invite", "pnrp_invcomm" )

function PlyRankComm(ply, cmd, args)
	local newRank = math.Clamp(tonumber(args[2]), 1, 3)
	if ply:GetTable().Community and ply:GetTable().CommunityRank > 2 then
		local communityTbl = GetCommunityTbl(ply:GetTable().Community)
		local trgName = args[1]
		
		local trgID
		for k, v in pairs(communityTbl["users"]) do
			if v.name == trgName then
				trgID = k
				break
			end
		end
		
		if trgID then
			AmendCommunityInfo( ply:GetTable().Community, nil, tonumber(newRank), nil, nil, trgID )
			ply:ChatPrint( args[1].."'s rank has been set to "..tostring(newRank.."." ) )
		else
			ply:ChatPrint( "Player not part of the community!" )
		end
	else
		ply:ChatPrint( "You do not have the community permissions to do this!" )
	end
end
concommand.Add( "pnrp_rankcomm", PlyRankComm )
PNRP.ChatConCmd( "/setrank", "pnrp_rankcomm" )

function PlyNewComm(ply, cmd, args)
	if ply:GetTable().Community then
		ply:ChatPrint("Cannot create a community when in a community.")
		return
	end
	-- Cant see why it doesn't work right now.  I'll figure out some way to fix it...
	-- if string.find(args[1], " ") or string.find(args[1], ".") or string.find(args[1], ",") or string.find(args[1], "@") 
	  -- or string.find(args[1], "#") or string.find(args[1], "$") or string.find(args[1], "%") or string.find(args[1], "^")
	  -- or string.find(args[1], "&") or string.find(args[1], "*") or string.find(args[1], "(") or string.find(args[1], ")")
	  -- or string.find(args[1], "{") or string.find(args[1], "}") or string.find(args[1], ";") or string.find(args[1], ":")
	  -- or string.find(args[1], "/") or string.find(args[1], "\\") or string.find(args[1], "'") or string.find(args[1], "\"")
	  -- or string.find(args[1], "?") or string.find(args[1], "[") or string.find(args[1], "]") or string.find(args[1], "!")
	  -- or string.find(args[1], "`") or string.find(args[1], "~") or string.find(args[1], "|") then
		-- ply:ChatPrint("A community name cannot contain special characters!")
		-- return
	-- end
	
	if not file.Exists("PostNukeRP/Communities/"..tostring(args[1])..".txt") then
		NewCommunityInfo( ply, args[1] )
		ply:ChatPrint("You have created a community called "..tostring(args[1]).."!")
	else
		ply:ChatPrint("This community name is already taken!")
	end
end
concommand.Add( "pnrp_newcomm", PlyNewComm )
PNRP.ChatConCmd( "/newcomm", "pnrp_newcomm" )

function PlyLeaveComm(ply, cmd, args)
	if file.Exists("PostNukeRP/Communities/"..tostring(ply:GetTable().Community)..".txt") then
		ply:ChatPrint("You have left the community called "..tostring(ply:GetTable().Community).."!")
		RemCommunityInfo( ply:GetTable().Community, ply:Nick(), nil, ply:UniqueID() )
	else
		ply:ChatPrint("This community doesn't exist!")
	end
end
concommand.Add( "pnrp_leavecomm", PlyLeaveComm )
PNRP.ChatConCmd( "/leave", "pnrp_leavecomm" )

function PlyRemComm(ply, cmd, args)
	if file.Exists("PostNukeRP/Communities/"..tostring(ply:GetTable().Community)..".txt") then
		if ply:GetTable().CommunityRank > 2 then
			RemCommunityInfo( ply:GetTable().Community, args[1], nil, nil )
			ply:ChatPrint("You have removed the user "..tostring(args[1]).." from the community!")
		end
	else
		ply:ChatPrint("This community doesn't exist!")
	end
end
concommand.Add( "pnrp_remcomm", PlyRemComm )
PNRP.ChatConCmd( "/remove", "pnrp_remcomm" )

function PlyDemSelfComm(ply, cmd, args)
	if ply:GetTable().Community then
		if ply:GetTable().CommunityRank < 2 then
			ply:ChatPrint( "You cannot demote yourself further." )
			return
		end
		AmendCommunityInfo( ply:GetTable().Community, nil, ply:GetTable().CommunityRank - 1, nil, nil, ply:UniqueID() )
		ply:ChatPrint( "Your rank has been set to "..ply:GetTable().CommunityRank.."." )
	else
		ply:ChatPrint( "You are not in a community!" )
	end
end
concommand.Add( "pnrp_demselfcomm", PlyDemSelfComm )
PNRP.ChatConCmd( "/demoteself", "pnrp_demselfcomm" )

function PlyAcceptInvite(ply, cmd, args )	
	if PNRP.PendingInvites[ply:Nick()] then
		NewCommunityInfo( ply, PNRP.PendingInvites[ply:Nick()] )
		ply:ChatPrint("You have been added to the community!")
		PNRP.PendingInvites[ply:Nick()] = nil
	else
		ply:ChatPrint("You have no invite pending.")
	end
	
end
concommand.Add( "pnrp_accinvite", PlyAcceptInvite )
PNRP.ChatConCmd( "/accept", "pnrp_accinvite" )

function PlyDenyInvite(ply, cmd, args )	
	if PNRP.PendingInvites[ply:Nick()] then
		PNRP.PendingInvites[ply:Nick()] = nil
		ply:ChatPrint("You have ignored this invite.")
	else
		ply:ChatPrint("You have no invite pending.")
	end
	
end
concommand.Add( "pnrp_denyinvite", PlyDenyInvite )
PNRP.ChatConCmd( "/deny", "pnrp_denyinvite" )

function PlyPlaceStockpile(ply, cmd, args)
	if ply:GetTable().Community then
		if ply:GetTable().CommunityRank > 1 then
			for _, v in pairs(ents.FindByClass("msc_stockpile")) do
				if v:GetNWString("community_owner", "nonvalid community") == ply:GetTable().Community then
					ply:ChatPrint( "You can only have one stockpile out at a time!" )
					return
				end
			end
			local communityTbl = GetCommunityTbl( ply:GetTable().Community )
			
			if table.Count(communityTbl["users"]) < 3 then
				ply:ChatPrint( "You can only use this when you have at least 3 members!" )
				return
			end
			
			local tracedata = {}
			tracedata.start = ply:GetShootPos()
			tracedata.endpos = tracedata.start + (ply:GetAimVector() * 200)
			tracedata.filter = ply
			local trace = util.TraceLine(tracedata)
			
			if trace.Hit then
				local ent = ents.Create ("msc_stockpile")
				ent:SetNWString("community_owner", ply:GetTable().Community)
				ent:SetNWString("Owner", "Unownable")
				ent:SetPos( trace.HitPos + Vector(0,0,80) )
				ent:Spawn()
				ent:GetPhysicsObject():EnableMotion(false)
				ent:SetMoveType(MOVETYPE_NONE)
				ply:ChatPrint( "You have placed a community stockpile.  It will take 10 seconds to become active." )
			else
				ply:ChatPrint( "Did not touch ground.  Move closer to your position and try again." )
			end
		else
			ply:ChatPrint( "You do not have the community permissions to do this!" )
		end
	else
		ply:ChatPrint( "You are not in a community!" )
	end
end
concommand.Add( "pnrp_placestock", PlyPlaceStockpile )
PNRP.ChatConCmd( "/placestock", "pnrp_placestock" )

function PlyPlaceLocker(ply, cmd, args)
	if ply:GetTable().Community then
		if ply:GetTable().CommunityRank > 1 then
			for _, v in pairs(ents.FindByClass("msc_equiplocker")) do
				if v:GetNWString("community_owner", "nonvalid community") == ply:GetTable().Community then
					ply:ChatPrint( "You can only have one locker out at a time!" )
					return
				end
			end
			local communityTbl = GetCommunityTbl( ply:GetTable().Community )
			
			if table.Count(communityTbl["users"]) < 3 then
				ply:ChatPrint( "You can only use this when you have at least 3 members!" )
				return
			end
			
			local tracedata = {}
			tracedata.start = ply:GetShootPos()
			tracedata.endpos = tracedata.start + (ply:GetAimVector() * 200)
			tracedata.filter = ply
			local trace = util.TraceLine(tracedata)
			
			if trace.Hit then
				local ent = ents.Create ("msc_equiplocker")
				ent:SetNWString("community_owner", ply:GetTable().Community)
				ent:SetNWString("Owner", "Unownable")
				ent:SetPos( trace.HitPos + Vector(0,0,12) )
				ent:Spawn()
				ent:GetPhysicsObject():EnableMotion(false)
				ent:SetMoveType(MOVETYPE_NONE)
				ply:ChatPrint( "You have placed a community locker.  It will take 10 seconds to become active." )
			else
				ply:ChatPrint( "Did not touch ground.  Move closer to your position and try again." )
			end
		else
			ply:ChatPrint( "You do not have the community permissions to do this!" )
		end
	else
		ply:ChatPrint( "You are not in a community!" )
	end
end
concommand.Add( "pnrp_placelocker", PlyPlaceLocker )
PNRP.ChatConCmd( "/placelocker", "pnrp_placelocker" )

function PlyRemStockpile(ply, cmd, args)
	if ply:GetTable().Community then
		if ply:GetTable().CommunityRank > 1 then
			for _, v in pairs(ents.FindByClass("msc_stockpile")) do
				if v:GetNWString("community_owner", "nonvalid community") == ply:GetTable().Community then
					local stockpile = v
					ply:ChatPrint( "Your stockpile will take 1 minute to break down.  It can be interacted with in that time." )
					timer.Simple(60, function ()
						stockpile:Remove()
					end)
					return
				end
			end
			ply:ChatPrint( "No stockpile found!" )
		else
			ply:ChatPrint( "You do not have the community permissions to do this!" )
		end
	else
		ply:ChatPrint( "You are not in a community!" )
	end
end
concommand.Add( "pnrp_remstock", PlyRemStockpile )
PNRP.ChatConCmd( "/remstock", "pnrp_remstock" )

function PlyRemLocker(ply, cmd, args)
	if ply:GetTable().Community then
		if ply:GetTable().CommunityRank > 1 then
			for _, v in pairs(ents.FindByClass("msc_equiplocker")) do
				if v:GetNWString("community_owner", "nonvalid community") == ply:GetTable().Community then
					local stockpile = v
					ply:ChatPrint( "Your locker will take 1 minute to break down.  It can be interacted with in that time." )
					timer.Simple(60, function ()
						stockpile:Remove()
					end)
					return
				end
			end
			ply:ChatPrint( "No stockpile found!" )
		else
			ply:ChatPrint( "You do not have the community permissions to do this!" )
		end
	else
		ply:ChatPrint( "You are not in a community!" )
	end
end
concommand.Add( "pnrp_remlocker", PlyRemLocker )
PNRP.ChatConCmd( "/remlocker", "pnrp_remlocker" )

/*-------------------------------------------------------*/

function GM:DoPlayerDeath( ply, attacker, dmginfo )
	
	if ply:GetNetworkedBool("IsAsleep") then
		ply:ConCommand("pnrp_wake")
	end
	
	ply:CreateRagdoll()
 
	ply:AddDeaths( 1 )
 	
	PNRP.DeathPay(ply, "Scrap")
	PNRP.DeathPay(ply, "Small_Parts")
	PNRP.DeathPay(ply, "Chemicals")
	
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
 
		if ( attacker == ply ) then
			attacker:AddFrags( -1 )
		else
			attacker:AddFrags( 1 )
		end
 
	end
	PNRP.PlyDeathZombie(ply)
	local pos = ply:GetPos() + Vector(0,0,20)	
	--Drop Weapons
	for k, v in pairs(ply:GetWeapons()) do
		ply:ChatPrint(v:GetClass())
		local wepCheck = PNRP.CheckDefWeps(v) and v != "weapon_real_cs_admin_weapon"
		if !wepCheck then
			if PNRP.FindWepItem(v:GetModel()) then
				local myItem = PNRP.FindWepItem(v:GetModel())
				Msg(tostring(v:GetModel()).." "..tostring(myItem.ID).."\n")
				local ent = ents.Create(myItem.Ent)
				--ply:PrintMessage( HUD_PRINTTALK, v:GetPrintName( ) )
				--ply:ChatPrint( "Dropped "..myItem.Name)
				ent:SetModel(myItem.Model)
				ent:SetAngles(Angle(0,0,0))
				ent:SetPos(pos)
				ent:Spawn()
				ent:SetNetworkedString("Ammo", v:Clip1())
				ent:SetNetworkedString("Owner", "World")
				
				local ammoDrop = ply:GetAmmoCount(v:GetPrimaryAmmoType())
				if ammoDrop > 0 then
					local myAmmoType = PNRP.ConvertAmmoType(v:GetPrimaryAmmoType())
					local entClass
					local entModel
				--	ply:ChatPrint(myAmmoType)
				--	ply:SendHint( "Dropped "..myItem.Name,5)
					local ammoFType
					--grenade fix
					if myItem.ID == "wep_grenade" then
						ammoFType = "wep_grenade"
						local ItemID = PNRP.FindItemID( ammoFType )
						if ItemID then
							entClass = ammoFType
							entModel = PNRP.Items[ItemID].Model
						end
						local entAmmo
						--Starts at 2 since it allready drops one as a weapon
						for i=2,ammoDrop do
							entAmmo = ents.Create(entClass)
							entAmmo:SetModel(entModel)
							entAmmo:SetAngles(Angle(0,0,0))
							entAmmo:SetPos(pos)
							entAmmo:Spawn()
						end
						
					else
						ammoFType = "ammo_"..myAmmoType
						local ItemID = PNRP.FindItemID( ammoFType )
						if ItemID then
							entClass = ammoFType
							entModel = PNRP.Items[ItemID].Model
						end
						local entAmmo = ents.Create(entClass)
						entAmmo:SetModel(entModel)
						entAmmo:SetAngles(Angle(0,0,0))
						entAmmo:SetPos(pos)
						entAmmo:Spawn()
						
						entAmmo:SetNetworkedString("Ammo", tostring(ammoDrop))
					end
				end
			end
		end
	end 		
end

function PNRP.DeathPay(ply, Recource)
	if GetConVarNumber("pnrp_deathPay") == 1 then
	    local getRec
	    local int
	    local cost = GetConVarNumber("pnrp_deathCost") / 100
  
	    getRec = ply:GetResource(Recource)
	    int = getRec * cost
	    int = math.Round(int)
	    if getRec - int >= 0 then
	    	ply:ChatPrint("Death has taken "..int.." "..Recource.." from you.")
	    	Msg("Death cost applied to "..Recource.." \n")
	    	ply:DecResource(Recource,int)
	    end
	end
end

function PNRP.CheckDefWeps(wep)
	local defWeps = table.Add(PNRP.DefWeps)
	for k,v in pairs(defWeps) do
		if string.lower(v) == wep:GetClass() then
			return true
		end
	end
end

function GM.set_Zombies(ply, command, arg) 
	RunConsoleCommand( "pnrp_MaxZombies", arg[1] )
	
	return GetConVarNumber("pnrp_MaxZombies")
end
concommand.Add( "pnrp_SetZombies", GM.set_Zombies )


function PNRP.ConvertAmmoType(ammoType)

	local sendType = nil
	
	if ammoType == 1 then sendType = "ar2" end -- Ammunition of the AR2/Pulse Rifle
	if ammoType == 2 then sendType = "alyxgun" end -- (name in-game "5.7mm Ammo")
	if ammoType == 3 then sendType = "pistol" end -- Ammunition of the 9MM Pistol 
	if ammoType == 4 then sendType = "smg1" end -- Ammunition of the SMG/MP7
	if ammoType == 5 then sendType = "357" end -- Ammunition of the .357 Magnum
	if ammoType == 6 then sendType = "xbowbolt" end -- Ammunition of the Crossbow
	if ammoType == 7 then sendType = "buckshot" end -- Ammunition of the Shotgun
	if ammoType == 8 then sendType = "rpg_round" end -- Ammunition of the RPG/Rocket Launcher
	if ammoType == 9 then sendType = "smg1_grenade" end -- Ammunition for the SMG/MP7 grenade launcher (secondary fire)
	if ammoType == 10 then sendType = "sniperround" end 
	if ammoType == 11 then sendType = "sniperpenetratedround" end -- (name in-game ".45 Ammo")
	if ammoType == 12 then sendType = "grenade" end -- Note you must be given the grenade weapon (e.g. pl:Give ("weapon_grenade")) before you can throw any grenades
	if ammoType == 13 then sendType = "thumper" end -- Ammunition cannot exceed 2 (name in-game "Explosive C4 Ammo")
	if ammoType == 14 then sendType = "gravity" end -- (name in-game "4.6MM Ammo")
	if ammoType == 15 then sendType = "battery" end -- (name in-game "9MM Ammo")
	if ammoType == 16 then sendType = "gaussEnergy" end 
	if ammoType == 17 then sendType = "combineCannon" end -- (name in-game ".50 Ammo")
	if ammoType == 18 then sendType = "airboatGun" end -- (name in-game "5.56MM Ammo")
	if ammoType == 19 then sendType = "striderMinigun" end -- (name in-game "7.62MM Ammo")
	if ammoType == 20 then sendType = "helicopterGun" end 
	if ammoType == 21 then sendType = "ar2altfire" end -- Ammunition of the AR2/Pulse Rifle 'combine ball' (secondary fire)
	if ammoType == 22 then sendType = "slam" end -- See Grenade

	return sendType
end

function ConvertWepEnt( weaponModel )
	for itemname, item in pairs( PNRP.Items ) do
		if weaponModel == item.Model then
			return item.Ent
		end
	end
	return nil
end

function PNRP.DropWeapon (ply, command, args)
	local myWep = ply:GetActiveWeapon()
	
	if ( myWep ) and myWep:GetClass() !=  "weapon_frag" then
		local curAmmo = myWep:Clip1()
		
		if PNRP.CheckDefWeps(myWep) then return end
		
		local wepModel = myWep:GetModel()
		if string.find(myWep:GetModel(), "v_") ~= 1 then
			wepModel = "models/weapons/w_"..string.sub(myWep:GetModel(),string.find(myWep:GetModel(), "v_")+2)
		end
		
		local wepEnt = ConvertWepEnt( wepModel )
		
		local tr = ply:TraceFromEyes(200)
		local trPos = tr.HitPos
		
		local ent = ents.Create(wepEnt)
		local pos = trPos + Vector(0,0,20)
		ent:SetModel(wepModel)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(pos)
		ent:Spawn()
		ent:SetNetworkedString("Owner", "World")
		ent:SetNetworkedString("Ammo", myWep:Clip1())
		
		ply:StripWeapon(myWep:GetClass())
	end
	
	if myWep:GetClass() ==  "weapon_frag" then
		ply:ChatPrint("Use /dropammo to drop grenades.")
	end
end
concommand.Add( "pnrp_dropWep", PNRP.DropWeapon )
PNRP.ChatConCmd( "/dropwep", "pnrp_dropWep" )
PNRP.ChatConCmd( "/dropgun", "pnrp_dropWep" )

function PNRP.OpenEquipment(ply)
	ply:ConCommand("pnrp_eqipment")
end
PNRP.ChatCmd( "/eq", PNRP.OpenEquipment )
PNRP.ChatCmd( "/equipment", PNRP.OpenEquipment )

--Will evntually build this to replace the above function
function PNRP.DropWep(ply, handler, id, encoded, decoded )
	
	local myWep = PNRP.Items[decoded[1]]
	local curWepAmmo = decoded[2]
		
	local tr = ply:TraceFromEyes(200)
	local trPos = tr.HitPos
	
	local ent = ents.Create(myWep.Ent)
	local pos = trPos + Vector(0,0,20)
	ent:SetModel(myWep.Model)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:SetNetworkedString("Owner", "World")
	ent:SetNetworkedString("Ammo", curWepAmmo)
		
end
datastream.Hook( "pnrp_dropWepFromEQ", PNRP.DropWep )

function PNRP.StripWep (ply, command, args)
	local wep = args[1]
	if wep == "weapon_frag" then 
		ply:RemoveAmmo( 1, "grenade" )
	else
		ply:StripWeapon(wep)
	end
end
concommand.Add( "pnrp_stripWep", PNRP.StripWep )

function PNRP.StowWeapon (ply, command, args)
	local myWep = ply:GetActiveWeapon()
	if ( myWep ) then
		local curAmmo = myWep:Clip1()
		
		if PNRP.CheckDefWeps(myWep) then return end
		
		local ItemID = PNRP.FindWepItem(tostring(myWep:GetModel()))
				
		if ItemID != nil then
		
			local weight = PNRP.InventoryWeight( ply ) + ItemID.Weight
			local weightCap
			
			if team.GetName(ply:Team()) == "Scavenger" then
				weightCap = GetConVarNumber("pnrp_packCapScav")
			else
				weightCap = GetConVarNumber("pnrp_packCap")
			end
			
			if weight <= weightCap then
				if ItemID.ID == "wep_grenade" then
					PNRP.AddToInentory( ply, ItemID.ID )
					ply:RemoveAmmo( 1, "grenade" )
				else
					PNRP.AddToInentory( ply, ItemID.ID )
					ply:GiveAmmo(myWep:Clip1(), myWep:GetPrimaryAmmoType())
					ply:StripWeapon(myWep:GetClass())
				end
			else
				ply:ChatPrint("You're pack is too full and cannot carry this.")
			end
		
		end		
		
	end
end
concommand.Add( "pnrp_stowWep", PNRP.StowWeapon )
PNRP.ChatConCmd( "/stowwep", "pnrp_stowWep" )
PNRP.ChatConCmd( "/stowgun", "pnrp_stowWep" )
PNRP.ChatConCmd( "/putawaygun", "pnrp_stowWep" )


function PNRP.DropAmmo (ply, command, args)
	local ammoType = args[1]
	if ammoType then ply:ChatPrint("Ammo Type:  "..ammoType) end
	local ammoAmt = tonumber(args[2])
	local entClass
	local entModel
	local ammoFTyp
	
	if ammoType and ammoAmt then
		ammoFType = "ammo_"..ammoType
		if ammoFType == "ammo_grenade" then ammoFType = "wep_grenade" end
		local ItemID = PNRP.FindItemID( ammoFType )
		if ItemID then
			entClass = ammoFType
			entModel = PNRP.Items[ItemID].Model
		else
			ply:ChatPrint("Invalid ammo type.")
			return
		end
	elseif ammoType then
		ammoFType = "ammo_"..ammoType
		if ammoFType == "ammo_grenade" then ammoFType = "wep_grenade" end
		local ItemID = PNRP.FindItemID( ammoFType )
		if ItemID then
			entClass = ammoFType
			entModel = PNRP.Items[ItemID].Model
			ammoAmt = PNRP.Items[ItemID].Energy
		else
			ply:ChatPrint("Invalid ammo type.")
			return
		end
	else
		--Grenade Check
		if ply:GetActiveWeapon():GetClass() == "weapon_frag" then 
			ammoFType = "wep_grenade"
			ammoType = "grenade" 
		else
			ammoType = PNRP.ConvertAmmoType(ply:GetActiveWeapon():GetPrimaryAmmoType())
			ammoFType = "ammo_"..ammoType
		end
		
		local ItemID = PNRP.FindItemID( ammoFType )
		if ItemID then
			entClass = ammoFType
			entModel = PNRP.Items[ItemID].Model
			ammoAmt = PNRP.Items[ItemID].Energy
		else
			ply:ChatPrint("Invalid ammo type.")
			return
		end
	end
	
	
	if ply:GetAmmoCount(ammoType) < ammoAmt then
		ply:ChatPrint("You cannot drop that much.  All ammo dropped instead.")
		
		ammoAmt = ply:GetAmmoCount(ammoType)
	end
	
	if ply:GetAmmoCount(ammoType) <= 0 then
		ply:ChatPrint("You don't have any of this type!")
		return
	end
	
	
	local tr = ply:TraceFromEyes(200)
	local trPos = tr.HitPos
	
	local ent = ents.Create(entClass)
	local pos = trPos + Vector(0,0,20)
	ent:SetModel(entModel)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:SetNetworkedString("Owner", "World")
	ent:SetNetworkedString("Ammo", tostring(ammoAmt))
	
	local prevAmmo = ply:GetAmmoCount(ammoType)
	
	if ammoType == "grenade" then ammoAmt = 1 end
	ply:RemoveAmmo( ammoAmt, ammoType )
--	ply:ChatPrint(tostring(prevAmmo).."  -  "..tostring(ammoAmt).." = "..tostring(prevAmmo - ammoAmt))
end
concommand.Add( "pnrp_dropAmmo", PNRP.DropAmmo )
PNRP.ChatConCmd( "/dropammo", "pnrp_dropAmmo" )

function PNRP.GetSpawnflags ( ply )
	local tr = ply:TraceFromEyes(400)
	local ent = tr.Entity
	
	for k,v in pairs(ent:GetKeyValues()) do
--		if string.lower(v) == wep:GetClass() then
--		Msg( tostring(k).." "..tostring(v).."\n")
		ply:ChatPrint(tostring(k)..": ["..tostring(v).."] \n")
--			return true
--		end
	end

--	ply:ChatPrint("Class: "..tostring(ent:GetClass()))
	EntityKeyValueInfo( ent )
--	Msg(EntityKeyValueInfo( ent, 0 ).."\n")
	ply:ChatPrint("Handle Animation: "..tostring(ent:GetTable().HandleAnimation) )
	ply:ChatPrint("Model: "..tostring(ent:GetModel()) )
end
concommand.Add( "pnrp_getinfo", PNRP.GetSpawnflags )

function PNRP.GetRepelSpawnflags ( ply )
	
	local repelpoints = ents.FindByClass("point_antlion_repellant")
	for k, v in pairs(repelpoints) do
		for k2,v2 in pairs(v:GetKeyValues()) do
	--		if string.lower(v) == wep:GetClass() then
	--		Msg( tostring(k).." "..tostring(v).."\n")
			ply:ChatPrint(tostring(k2)..": ["..tostring(v2).."] \n")
	--			return true
	--		end
		end
		ply:ChatPrint("Pos:  "..tostring(v:GetPos()))
		ply:ChatPrint("------------------------------------------------------")
	end
--	ply:ChatPrint("Class: "..tostring(ent:GetClass()))
--	Msg(EntityKeyValueInfo( ent, 0 ).."\n")
end
concommand.Add( "pnrp_getrepels", PNRP.GetRepelSpawnflags )

function EntityKeyValueInfo( ent, key, value )

--return tostring(key).." "..tostring(value)
	Msg(tostring(ent).." "..tostring(key).." "..tostring(value).."\n")

--	for k,v in pairs(ent:GetKeyValues()) do
--		if string.lower(v) == wep:GetClass() then
--		Msg( tostring(k).." "..tostring(v).."\n")
--		ply:ChatPrint(tostring(k)..": ["..tostring(v).."] \n")
--			return true
--		end
--	end

end

hook.Add( 'EntityKeyValue' , "EntityKeyValueInfo", getMoreInfo )

function PNRP.Unfreeze(ply)
	ply:Freeze(false)
end
concommand.Add( "pnrp_unfreeze", PNRP.Unfreeze )
PNRP.ChatCmd( "/unfreeze", PNRP.Unfreeze )

--EOF