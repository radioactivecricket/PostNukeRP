PNRP.PendingInvites = { }
--Chat Commands
PNRP.ChatCommands = { }
PNRP.ChatConCommands = { }
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
PNRP.ChatConCmd( "/hud", "pnrp_HUD" )
PNRP.ChatConCmd( "/devmode", "pnrp_plydevmode" )

function SetItmName(ply, cmd, args)
	local tr = ply:TraceFromEyes(200)
	local ent = tr.Entity
	
	if IsValid(ent) then
		if !ent:IsPlayer() then
			if tostring(ent:GetNetworkedString( "Owner_UID" , "None" )) == PNRP:GetUID( ply ) then
				if args[1] then
					ent:SetNWString("name", args[1])
				end
			end
		end
	end
end
concommand.Add( "pnrp_setname", SetItmName )
PNRP.ChatConCmd( "/name", "pnrp_setname" )

-- Pretty much taken from DarkRP code.  If it works, it works.
local meta = FindMetaTable("Player")
meta.SteamName = meta.Name
meta.Name = function(self)
	if IsValid(self) then
		return self.rpname or self:SteamName()
	else
		return "Unknown"
	end
end
meta.Nick = meta.Name
meta.GetName = meta.Name

function SetRPName(ply, cmd, args, fullstr)
	if (not args[1]) or args[1] == "" or args[1] == nil or (not fullstr) or fullstr == "" or fullstr == nil then
		ply.rpname = ply:SteamName()
	else
		if string.len(fullstr) > 40 then
			ply:ChatPrint("RP name is too long.  Must be under 40 characters.")
			return
		end

		ply.rpname = fullstr
	end
	
	net.Start("RPNameChange")
		net.WriteEntity(ply)
		net.WriteString(ply.rpname)
		net.WriteBit(false)
	net.Broadcast()
end
concommand.Add( "pnrp_setrpname", SetRPName )
PNRP.ChatConCmd( "/rpname", "pnrp_setrpname" )
util.AddNetworkString("RPNameChange")

function GetAllRPNames(ply)
	local plyList = player.GetAll()

	for _, pent in pairs(plyList) do
		if pent and IsValid(pent) then
			if pent ~= ply then
				net.Start("RPNameChange")
					net.WriteEntity(pent)
					net.WriteString(pent:Name())
					net.WriteBit(true)
				net.Send(ply)
			end
		end
	end
end
concommand.Add( "pnrp_newcomm", PlyNewComm )
PNRP.ChatConCmd( "/newcomm", "pnrp_newcomm" )

function SetModel(ply, cmd, args)
	local GM = GAMEMODE
	local cl_playermodel = ply:GetInfo( "cl_playermodel" )
	local modelname = player_manager.TranslatePlayerModel( cl_playermodel )

	ply.rpmodel = modelname
	GM:PlayerSetModel( ply )
end
concommand.Add( "pnrp_setmodel", SetModel )
PNRP.ChatConCmd( "/setmodel", "pnrp_setmodel" )

/*---------------------------------------------------------
  Save/Load
---------------------------------------------------------*/
function GM.SaveCharacter(ply,cmd,args)
	local query
	local result

	if not ply.HasLoaded then return end

	local skillList = ""
	local weaponList = ""
	local ammoTbl = {}
	local ammoList = ""

	for skill, level in pairs(ply.Skills) do
		--Noticed skills with spaces in it screwed the system, so we're fixing that.
		local skillEscaped = string.gsub(skill, " ", "_")
		skillList = skillList..skillEscaped..","..tostring(level).." "
	end
	string.TrimRight(skillList)


	for k, v in pairs(ply:GetWeapons()) do
		local ammo = ply:GetAmmoCount( v:GetPrimaryAmmoType() )
		local ammoType = PNRP.ConvertAmmoType(v:GetPrimaryAmmoType()) or "none"
		
		--Fix for the frag and charg bug
		if v:GetClass() == "weapon_frag" and ammo < 1 then
			ply:StripWeapon( v:GetClass() )
		elseif v:GetClass() == "weapon_pnrp_charge" and ammo == 0 then
			--Do nothing
			--skips saving this but does not remove so player can still use the trigger
			--ply:StripWeapon( v:GetClass() )
		else
			weaponList = weaponList..v:GetClass()..","
			if v:GetClass() == "weapon_frag" or v:GetClass() == "weapon_pnrp_charge" then
				ammoTbl[ammoType] = ammo - 1
			else
				ammoTbl[ammoType] = ammo
			end
		end
	end
	string.TrimRight(weaponList, ",")

	for ammo, amount in pairs(ammoTbl) do
		ammoList = ammoList..ammo..","..tostring(amount).." "
	end
	string.TrimRight(ammoList)

	query = "UPDATE profiles SET model='"..ply:GetModel().."', nick ="..SQLStr(ply:Nick())..", lastlog="..SQLStr(os.date())..", class="..tostring(ply:Team())..", xp="..tostring(ply:GetXP())..", skills='"..skillList.."', health="..tostring(ply:Health())..", armor="..tostring(ply:Armor())..", endurance="..tostring(ply.Endurance)..", hunger="..tostring(ply.Hunger)
	query = query..", res='"..ply.Resources["Scrap"]..","..ply.Resources["Small_Parts"]..","..ply.Resources["Chemicals"].."', weapons='"..weaponList.."', ammo='"..ammoList.."' WHERE pid="..tostring(ply.pid)
	result = querySQL(query)
	print("Player data saved: "..ply:Nick())
	ply:ChatPrint("Player Saved.")
end

function GM.CreateCharacter( ply, plyModel, plyClass )
	local query
	local result

	query = "SELECT steamid FROM player_table WHERE steamid='"..ply:SteamID().."'"
	result = querySQL(query)

	if not result then
		query = "INSERT INTO player_table VALUES ( '"..ply:SteamID().."', '"..tostring(ply:UniqueID()).."', '"..ply:IPAddress().."', "..SQLStr(ply:SteamName())..", '"..tostring(os.date()).."', '"..tostring(os.date()).."' )"
		result = querySQL(query)
	end

	query = "INSERT INTO profiles VALUES ( NULL, '"..ply:SteamID().."', "..SQLStr(plyModel)..", "..SQLStr(ply:Name())..", "..SQLStr(os.date())..", "..tonumber(plyClass)..", 0, ' ', 150, 0, 100, 100, '0,0,0', ' ', ' ' )"
	result = querySQL(query)

	print("Created new character for "..ply:SteamName())
	ply:ChatPrint("New character created!")
end

function GM.DeleteProfile( )
	local GM = GAMEMODE
	local ply = net.ReadEntity()
	local pid = net.ReadString()
	querySQL("DELETE FROM profiles WHERE pid='"..tonumber(pid).."'")
	querySQL("DELETE FROM player_inv WHERE pid='"..tonumber(pid).."'")
	querySQL("DELETE FROM world_cache WHERE pid='"..tonumber(pid).."'")
	querySQL("DELETE FROM community_members WHERE pid='"..tonumber(pid).."'")

	--This calls the profile selection window
	local result = GM.GetCharacterList( ply )
	local tbl = {}
	if result then
		tbl = result
	end

	net.Start("pnrp_runProfilePicker")
	--	net.WriteEntity(ply)
		net.WriteTable(tbl)
	net.Send(ply)
end
net.Receive("delProfile", GM.DeleteProfile );

function GM.initProfileMenu( )
	local GM = GAMEMODE
	local ply = net.ReadEntity()
	--This calls the profile selection window
	local result = GM.GetCharacterList( ply )
	local tbl = {}
	if result then
		tbl = result
	end

	net.Start("pnrp_runProfilePicker")
	--	net.WriteEntity(ply)
		net.WriteTable(tbl)
	net.Send(ply)
end
net.Receive("initProfileStuff", GM.initProfileMenu );
util.AddNetworkString( "pnrp_runProfilePicker" )

function GM.GetCharacterList( ply )
	local query
	local result

	query = "SELECT * FROM profiles WHERE steamid='"..ply:SteamID().."'"
	result = querySQL(query)

	if not result then return nil end

	return result
end

function GM.LoadCharacter( ply, pid )
	local query
	local result

	ply.pid = pid

	query = "SELECT * FROM profiles WHERE pid="..tostring(pid)
	result = querySQL(query)

	if not result then return end

	ply.rpmodel = result[1]["model"]
	ply.rpname = result[1]["nick"]
	ply:SetTeam( tonumber(result[1]["class"]) )
	ply:SetXP( tonumber(result[1]["xp"]) )

	local skillLongStr = string.Explode( " ", result[1]["skills"] )

	for _, skillStr in pairs(skillLongStr) do
		local skillSplit = string.Explode(",", skillStr)
		local skillEscaped = string.gsub(skillSplit[1], "_", " ")
		ply:SetSkill(skillEscaped, tonumber(skillSplit[2]))
	end

	ply:SetHealth( tonumber(result[1]["health"]) or maxHealth )
	ply.LoadHealth = tonumber(result[1]["health"])
--	ErrorNoHalt( "Stored HP:  "..result[1]["health"].."  After Set:  "..tostring(ply:Health()).."\n")

	ply:SetArmor( tonumber(result[1]["armor"]) or 0 )
	ply.Endurance = tonumber(result[1]["endurance"])
	ply.Hunger = tonumber(result[1]["hunger"])
	ply.LoadArmor = tonumber(result[1]["armor"]) or 0 

	local resStr = string.Explode( ",", result[1]["res"] )
	ply:SetResource( "Scrap", tonumber(resStr[1]) )
	ply:SetResource( "Small_Parts", tonumber(resStr[2]) )
	ply:SetResource( "Chemicals", tonumber(resStr[3]) )

	local weapStr = string.Explode( ",", result[1]["weapons"] )
	for _, wepid in pairs(weapStr) do
		ply:Give(wepid)
	end

	local ammoTbl = {}
	local ammoLongStr = string.Explode( " ", result[1]["ammo"] )
	for _, ammoStr in pairs( ammoLongStr ) do
		local ammoSplit = string.Explode( ",", ammoStr )
		ammoTbl[ammoSplit[1]] = tonumber(ammoSplit[2])
	end

	for k, v in pairs(ammoTbl) do
		ply:ChatPrint("Type:  "..k.."  Amount:  "..tostring(v))
		if k then ply:GiveAmmo( v, k ) end
	end

	LoadCommunityInfo( ply, ply.pid )
	GetAllRPNames( ply )
end
concommand.Add( "pnrp_save", GM.SaveCharacter )
PNRP.ChatConCmd( "/save", "pnrp_save" )

-- Community Functions

-- Loads a player's community information.
function LoadCommunityInfo( ply, pid )
	local query
	local result

	query = "SELECT * FROM community_members WHERE pid="..tostring(pid)
	result = querySQL(query)

	if result then
		local query2
		local result2

		ply.Community = tonumber(result[1]["cid"])
		ply.CommunityRank = tonumber(result[1]["rank"])
		ply:SetNWString("ctitle", result[1]["title"])

		query2 = "SELECT cname FROM community_table WHERE cid="..tostring(result[1]["cid"])
		result2 = querySQL(query2)
		ply:SetNWString("community", result2[1]["cname"])
	else
		ply.Community = nil
		ply.CommunityRank = nil
		ply:SetNWString("ctitle", "")
		ply:SetNWString("community", "N/A")
	end
end

-- Edits players in the list. ADDED TITLE!  ALL REFERENCES NEED TO ADD NEW VARIABLE BETWEEN NAME AND RANK!
function AmendCommunityInfo( cid, name, title, rank, lastlog, model, pid )
	local query
	local result

	local values = "SET"
	local values2 = "SET"
	local whereClause
	local ident
	--"CREATE TABLE community_table ( cid INTEGER PRIMARY KEY AUTOINCREMENT, cname varchar(255), res varchar(255), inv varchar(255), founded varchar(255) )"
	--"CREATE TABLE community_members ( pid int, cid int, rank int, title varchar(255) )"

	--Needs to take any number of entries.  pid will be required.
	if pid then
		whereClause = "WHERE pid="..tostring(pid)
		ident = 1
	-- elseif cid and name then
		-- query = "SELECT pid FROM profiles WHERE nick='"...."'"
		-- whereClause = "WHERE cid="..tostring(cid).." AND name='"..SQLStr(tostring(name)).."'"
		-- ident = 2
	else
		ErrorNoHalt("SQL ERROR:  Amend error; no identifying data.")
		return
	end
	--"CREATE TABLE profiles ( pid INTEGER PRIMARY KEY AUTOINCREMENT, steamid varchar(255), model varchar(255), nick varchar(255), lastlog varchar(255), xp int, skills varchar(255), health int, armor int, endurance int, hunger int, res varchar(255), weapons varchar(255), ammo varchar(255) )"
	if name then
		values2 = values2.." nick="..SQLStr(name)
	end

	if rank then
		values = values.." rank='"..tostring(rank).."'"
	end

	if title then
		if values ~= "SET" then values = values.."," end
		values = values.." title="..SQLStr(tostring(title))
	end

	if lastlog then
		if values2 ~= "SET" then values2 = values2.."," end
		values2 = values2.." lastlog="..SQLStr(lastlog)
	end

	if model then
		if values2 ~= "SET" then values2 = values2.."," end
		values2 = values2.." model="..SQLStr(model)
	end

	if values ~= "SET" then
		query = "UPDATE community_members "..values.." "..whereClause
		result = querySQL(query)
	end

	if values2 ~= "SET" then
		query = "UPDATE profiles "..values2.." "..whereClause
		result = querySQL(query)
	end
end

-- Actually makes new communities, or adds a player to a community.  Can only be done in game, for good reason.
function NewCommunityInfo( ply, community )
	local query
	local result

	-- Check to see if profile is already in a community.
	query = "SELECT pid FROM community_members WHERE pid='"..tostring(ply.pid).."'"
	result = querySQL(query)
	if result then
		ply:ChatPrint("You are already in a community and cannot create another.")
		return
	end

	-- Escape special characters from community names.
	if string.find(community, "[%/%\\%!%@%#%$%%%^%&%*%(%)%+%=%.%'%\"]") then
		ply:ChatPrint("A community name cannot have special characters in it!")
		return
	end

	-- Check to see if the community already exists.  If it does, then add this player, else create new and add player.
	--query = "SELECT cid FROM community_table WHERE cname='"..SQLStr(tostring(community)).."'"
	query = "SELECT cid FROM community_table WHERE cname="..SQLStr(tostring(community))
	result = querySQL(query)

	if result then
		local mycid = result[1]["cid"]
		if mycid == nil then
			ErrorNoHalt("SQL ERROR:  cid was nil.")
			return
		end
		query = "INSERT INTO community_members VALUES ( "..tostring(ply.pid)..", "..mycid..", 1, 'Recruit' )"
		result = querySQL(query)

		ply:GetTable().Community = mycid
		ply:SetNWString("community", community)
		ply:GetTable().CommunityRank = 1
		ply:SetNWString("ctitle", "Recruit")
		ply:ConCommand("pnrp_save")
	else
		query = "INSERT INTO community_table VALUES ( NULL, "..SQLStr(tostring(community))..", '0,0,0', ' ', "..SQLStr(tostring(os.date())).." )"
		result = querySQL(query)

		query = "SELECT cid FROM community_table WHERE cname="..SQLStr(tostring(community))
		result = querySQL(query)

		local newcid = nil

		if result then
			newcid = result[1]['cid']
		else
			ply:ChatPrint("An error has occured creating this community.")
			return
		end

		if newcid == nil then
			ErrorNoHalt("SQL ERROR: New cid is nil.")
			return
		end

		query = "INSERT INTO community_members VALUES ( "..tostring(ply.pid)..", "..newcid..", 3, 'Founder' )"
		result = querySQL(query)

		ply:GetTable().Community = newcid
		ply:SetNWString("community", community)
		ply:GetTable().CommunityRank = 3
		ply:SetNWString("ctitle", "Founder")
		ply:ConCommand("pnrp_save")
	end

end

-- Will delete a community automatically when users becomes 0.
function RemCommunityInfo( cid, pid )
	local query
	local result

	local rank

	query = "SELECT rank FROM community_members WHERE pid="..tostring(pid)
	result = querySQL(query)

	if result then
		rank = result[1]["rank"]
	end

	query = "DELETE FROM community_members WHERE pid="..tostring(pid)
	result = querySQL(query)

	for _, myUser in pairs(player.GetAll()) do
		if myUser.pid == pid then
			myUser:GetTable().Community = nil
			myUser:SetNWString("community", nil)
			myUser:GetTable().CommunityRank = nil
			myUser:SetNWString("ctitle", nil)
			myUser:ConCommand("pnrp_save")
			myUser:ChatPrint("You've been removed from your community.")
		end
	end

	if rank == 3 then
		query = "SELECT pid FROM community_members WHERE rank=3 AND cid="..tostring(cid)
		result = querySQL(query)
		if not result then
			query = "SELECT pid FROM community_members WHERE rank=2 AND cid="..tostring(cid)
			result = querySQL(query)

			if result then
				local newowner = result[1]["pid"]
				query = "UPDATE community_members SET rank=3 WHERE pid="..tostring(newowner)
				result = querySQL(query)

				for _, myUser in pairs(player.GetAll()) do
					if myUser.pid == newowner then
						myUser:GetTable().CommunityRank = 3
						myUser:ConCommand("pnrp_save")
						myUser:ChatPrint("You've been promoted to owner of your community.")
						break
					end
				end
			else
				query = "SELECT pid FROM cummunity_members WHERE rank=1 AND cid="..tostring(cid)
				result = querySQL(query)

				if result then
					local newowner = result[1]["pid"]
					query = "UPDATE community_members SET rank=3 WHERE pid="..tostring(newowner)
					result = querySQL(query)

					for _, myUser in pairs(player.GetAll()) do
						if myUser.pid == newowner then
							myUser:GetTable().CommunityRank = 3
							myUser:ConCommand("pnrp_save")
							myUser:ChatPrint("You've been promoted to owner of your community.")
							break
						end
					end
				else
					DelCommunity(cid)
				end
			end
		end
	end
end

-- Removes a community entirely.  The community res and inventory will fly into the void of nothingness.
function DelCommunity( cid )
	local query
	local result

	query = "DELETE FROM community_members WHERE cid="..tostring(cid)
	result = querySQL(query)

	query = "DELETE FROM community_table WHERE cid="..tostring(cid)
	result = querySQL(query)

	for _, myUser in pairs(player.GetAll()) do
		if myUser.Community == cid then
			myUser:GetTable().Community = nil
			myUser:SetNWString("community", nil)
			myUser:GetTable().CommunityRank = nil
			myUser:SetNWString("ctitle", nil)
			myUser:ConCommand("pnrp_save")
			myUser:ChatPrint("You've been removed from your community, because it's been deleted.")
		end
	end
end

-- Sets community resources
function SetCommunityRes( cid, scrap, small, chems )
	local query
	local result

	query = "SELECT cid FROM community_table WHERE cid="..tostring(cid)
	result = querySQL(query)

	if result then
		query = "UPDATE community_table SET res='"..tostring(scrap)..","..tostring(small)..","..tostring(chems).."' WHERE cid="..tostring(cid)
		result = querySQL(query)
	else
		ErrorNoHalt(tostring(os.date()).." SQL ERROR:  No cid match in SetCommunityRes!" )
		return
	end
end

function AddCommunityRes( cid, mytype, amount )
	local query
	local result
	--"CREATE TABLE community_table ( cid INTEGER PRIMARY KEY AUTOINCREMENT, cname varchar(255), res varchar(255), inv varchar(255), founded varchar(255) )"
	--"CREATE TABLE community_members ( pid int, cid int, rank int, title varchar(255) )"
	Msg("trying to do with with cid: "..tostring(cid).."\n")
	query = "SELECT res FROM community_table WHERE cid='"..tostring(cid).."'"
	result = querySQL(query)

	if result then
		local myRes = string.Explode(",", result[1]["res"])
		local newRes
		local newResStr
		if mytype == "Scrap" then
			newRes = tonumber(myRes[1]) + amount
			newResStr = tostring(newRes)..","..myRes[2]..","..myRes[3]
		elseif mytype == "Small_Parts" then
			newRes = tonumber(myRes[2]) + amount
			newResStr = myRes[1]..","..tostring(newRes)..","..myRes[3]
		elseif mytype == "Chemicals" then
			newRes = tonumber(myRes[3]) + amount
			newResStr = myRes[1]..","..myRes[2]..","..tostring(newRes)
		else
			ErrorNoHalt(tostring(os.date()).." INPUT ERROR:  mytype non-valid for AddCommunityRes!")
			return
		end

		query = "UPDATE community_table SET res='"..newResStr.."' WHERE cid="..tostring(cid)
		result = querySQL(query)
	else
		ErrorNoHalt(tostring(os.date()).." SQL ERROR:  No cid match in AddCommunityRes!" )
	end
end

function SubCommunityRes( cid, mytype, amount )
	local query
	local result

	query = "SELECT res FROM community_table WHERE cid="..tostring(cid)
	result = querySQL(query)

	if result then
		local myRes = string.Explode(",", result[1]["res"])
		local newRes
		local newResStr
		if mytype == "Scrap" then
			newRes = tonumber(myRes[1]) - amount
			if newRes < 0 then newRes = 0 end
			newResStr = tostring(newRes)..","..myRes[2]..","..myRes[3]
		elseif mytype == "Small_Parts" then
			newRes = tonumber(myRes[2]) - amount
			if newRes < 0 then newRes = 0 end
			newResStr = myRes[1]..","..tostring(newRes)..","..myRes[3]
		elseif mytype == "Chemicals" then
			newRes = tonumber(myRes[3]) - amount
			if newRes < 0 then newRes = 0 end
			newResStr = myRes[1]..","..myRes[2]..","..tostring(newRes)
		else
			ErrorNoHalt(tostring(os.date()).." INPUT ERROR:  mytype non-valid for AddCommunityRes!")
			return
		end

		query = "UPDATE community_table SET res='"..newResStr.."' WHERE cid="..tostring(cid)
		result = querySQL(query)
	else
		ErrorNoHalt(tostring(os.date()).." SQL ERROR:  No cid match in SubCommunityRes! ["..tostring(cid).."] \n" )
	end
end

function AddCommunityItem( cid, mytype, amount )
	local query
	local result

	query = "SELECT inv FROM community_table WHERE cid="..tostring(cid)
	result = querySQL(query)

	-- Inventory string design:  'item_code,amount item_code2,amount item_code3,amount'
	if result then
		local invSplit = string.Explode(" ", result[1]["inv"])
		local invTable = {}

		for _, itemData in pairs(invSplit) do
			local splitData = string.Explode(",", itemData)

			invTable[splitData[1]] = tonumber(splitData[2])
		end

		if invTable[mytype] then
			invTable[mytype] = invTable[mytype] + amount
		else
			invTable[mytype] = amount
		end

		local newInvString = ""

		for k, v in pairs(invTable) do
			newInvString = newInvString..k..","..tostring(v).." "
		end
		newInvString = string.TrimRight(newInvString)

		query = "UPDATE community_table SET inv='"..newInvString.."' WHERE cid='"..tostring(cid).."'"
		result = querySQL(query)
	else
		ErrorNoHalt(tostring(os.date()).." SQL ERROR:  No cid match in AddCommunityItem! ["..tostring(cid).."] \n")
	end
end

function SubCommunityItem( cid, mytype, amount )
	local query
	local result

	query = "SELECT inv FROM community_table WHERE cid="..tostring(cid)
	result = querySQL(query)

	if result then
		local invSplit = string.Explode(" ", result[1]["inv"])
		local invTable = {}

		for _, itemData in pairs(invSplit) do
			local splitData = string.Explode(",", itemData)

			invTable[splitData[1]] = tonumber(splitData[2])
		end

		if invTable[mytype] then
			invTable[mytype] = invTable[mytype] - amount
			if invTable[mytype] <= 0 then invTable[mytype] = nil end
		else
			ErrorNoHalt(tostring(os.date()).." SubCommunityItem ERROR: Item does not exist in inventory!")
			return
		end

		local newInvString = ""

		for k, v in pairs(invTable) do
			newInvString = newInvString..k..","..tostring(v).." "
		end
		newInvString = string.TrimRight(newInvString)

		query = "UPDATE community_table SET inv='"..newInvString.."' WHERE cid="..tostring(cid)
		result = querySQL(query)
	else
		ErrorNoHalt(tostring(os.date()).." SQL ERROR:  No cid match in SubCommunityItem!" )
	end
end

function GetCommunityTbl( cid )
	local query
	local result

	local communityTbl = {}
	local ctblInfo
	local cMemInfo
	--"CREATE TABLE community_table ( cid INTEGER PRIMARY KEY AUTOINCREMENT, cname varchar(255), res varchar(255), inv varchar(255), founded varchar(255) )"
	--"CREATE TABLE community_members ( pid int, cid int, rank int, title varchar(255) )"

	query = "SELECT * FROM community_table WHERE cid="..tostring(cid)
	result = querySQL(query)

	if not result then
		return nil
	end
	ctblInfo = result[1]

	query = "SELECT * FROM community_members WHERE cid="..tostring(cid)
	result = querySQL(query)

	if not result then
		return nil
	end
	cMemInfo = result

	communityTbl["cid"] = ctblInfo["cid"]
	communityTbl["name"] = ctblInfo["cname"]

	local resStr = string.Explode(",", ctblInfo["res"])
	communityTbl["res"] = {}
	communityTbl["res"]["Scrap"] = tonumber(resStr[1])
	communityTbl["res"]["Small_Parts"] = tonumber(resStr[2])
	communityTbl["res"]["Chemicals"] = tonumber(resStr[3])

	local invSplit = string.Explode(" ", ctblInfo["inv"])
	local invTable = {}

	for _, itemData in pairs(invSplit) do
		local splitData = string.Explode(",", itemData)

		invTable[splitData[1]] = tonumber(splitData[2])
	end
	communityTbl["inv"] = invTable
	communityTbl["founded"] = ctblInfo["founded"]

	--"CREATE TABLE profiles ( pid INTEGER PRIMARY KEY AUTOINCREMENT, steamid varchar(255), model varchar(255), nick varchar(255), lastlog varchar(255), xp int, skills varchar(255), health int, armor int, endurance int, hunger int, res varchar(255), weapons varchar(255), ammo varchar(255) )"
	communityTbl["users"] = {}
	for _, user in pairs(cMemInfo) do

		query = "SELECT * FROM profiles WHERE pid="..tostring(user["pid"])
		result = querySQL(query)

		if result then
			communityTbl["users"][user["pid"]] = {}
			communityTbl["users"][user["pid"]]["steamid"] = result[1]["steamid"]
			communityTbl["users"][user["pid"]]["model"] = result[1]["model"]
			communityTbl["users"][user["pid"]]["name"] = result[1]["nick"]
			communityTbl["users"][user["pid"]]["lastlog"] = result[1]["lastlog"]
		else
			ErrorNoHalt(tostring(os.date()).." SQL ERROR: Shit fucked up.  Profile in community, but not in profiles.")
		end
		communityTbl["users"][user["pid"]]["pid"] = user["pid"]
		communityTbl["users"][user["pid"]]["rank"] = tonumber(user["rank"])
		communityTbl["users"][user["pid"]]["title"] = user["title"]
	end

	return communityTbl

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
--		query = "SELECT * FROM community_members WHERE pid="..tostring(ply.pid)
--		result = sql.Query(query)
--		local cid = result[1]["cid"]
		tbl = GetCommunityTbl( PlayerCommunityName )
		PlayerCommunityName = ply:GetNWString("community")
	end

	net.Start("pnrp_OpenCommunityWindow")
		net.WriteString(PlayerCommunityName)
		net.WriteTable(tbl)
		net.WriteString(tostring(ply.pid))
	net.Send(ply)
end
concommand.Add("pnrp_OpenCommunity", PNRP.OpenMainCommunity)
util.AddNetworkString( "pnrp_OpenCommunityWindow" )

function PNRP.OpenCommunityAdmin(ply, cmd, args)
	if ply:IsAdmin() then
		local cid = args[1]
		if cid then
			query = "SELECT * FROM community_table WHERE cid="..tostring(ply.Community)
			result = querySQL(query)
		else
			query = "SELECT * FROM community_table"
			result = sql.Query(query)
			net.Start("pnrp_OpenCommAdminWindow")
				net.WriteTable(result)
			net.Send(ply)
		end
	end
end
concommand.Add("pnrp_communityAdmin", PNRP.OpenCommunityAdmin)
util.AddNetworkString( "pnrp_OpenCommAdminWindow" )

function AdmDelCom(ply, cmd, args)
	if ply:IsAdmin() then
		local cid = args[1]
		DelCommunity( cid )

		for _, v in pairs(player.GetAll()) do
			if tostring(v:GetTable().Community) == tostring(cid) then
				v:ChatPrint( "Your community, "..ply:GetNWString("community")..", has been deleted by an Admin!" )

				v:GetTable().Community = nil
				v:GetTable().CommunityRank = nil
				v:SetNWString("community", "N/A")
			end
		end
	end
end
concommand.Add("pnrp_AdminDelCom", AdmDelCom)

function AdmEditCom(ply, cmd, args)
	if ply:IsAdmin() then
		local cid = args[1]
		local tbl = { }
		GetComtbl = GetCommunityTbl( cid )
		if GetComtbl then
			tbl = GetComtbl
		end
		net.Start("pnrp_OpenEditCommunityWindow")
			net.WriteTable(tbl)
			net.WriteString(cid)
		net.Send(ply)
	end
end
concommand.Add("pnrp_AdmEditCom", AdmEditCom)
util.AddNetworkString( "pnrp_OpenEditCommunityWindow" )

function PlyDelComm(ply, cmd, args)
	if ply:GetTable().Community and ply:GetTable().CommunityRank > 2 then
		DelCommunity( ply:GetTable().Community )

		for _, v in pairs(player.GetAll()) do
			if v:GetTable().Community == ply:GetTable().Community and v ~= ply then
				v:GetTable().Community = nil
				v:GetTable().CommunityRank = nil
				v:SetNWString("community", "N/A")

				v:ChatPrint( "Your community, "..ply:GetNWString("community")..", has been deleted by an owner!" )
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
		local trgEnt = nil
		for _, v in pairs(player.GetAll()) do
			if v:Nick() == trgName then
				trgEnt = v
			end
		end

		if IsValid(trgEnt) then
			-- NewCommunityInfo( trgEnt, ply:GetTable().Community )
			if trgEnt:GetTable().Community then
				ply:ChatPrint( trgEnt:Nick().." is already in a community." )
				return
			end
			if PNRP.PendingInvites[trgEnt:Nick()] then
				ply:ChatPrint( trgEnt:Nick().." already has another invite pending." )
				return
			end
			ply:ChatPrint( trgEnt:Nick().." has been invited to the community!" )
			
			local CommunityID = ply:GetTable().Community
			local CommunityName = ply:GetNWString("community")

			PNRP.PendingInvites[trgEnt:Nick()] = ply:GetNWString("community")
			net.Start( "sendinvite" )
				net.WriteString( ply:Nick() )
				net.WriteString( CommunityID )
				net.WriteString( CommunityName )
			net.Send(trgEnt)

		else
			ply:ChatPrint( "Player not found!" )
		end
	else
		ply:ChatPrint( "You do not have the community permissions to do this!" )
	end
end
concommand.Add( "pnrp_invcomm", PlyInvComm )
PNRP.ChatConCmd( "/invite", "pnrp_invcomm" )
util.AddNetworkString("sendinvite")

function PlyRankComm(ply, cmd, args)
	--function AmendCommunityInfo( cid, name, title, rank, lastlog, model, pid* )
	local newRank = math.Clamp(tonumber(args[2]), 1, 3)
	if ply:GetTable().Community and ply:GetTable().CommunityRank > 2 then
		local communityTbl = GetCommunityTbl(ply:GetTable().Community)
		local trgName = args[1]

		local trgID
		for k, v in pairs(communityTbl["users"]) do
			if v.name == trgName then
				trgID = v.pid
				break
			end
		end

		if trgID then
			AmendCommunityInfo( ply:GetTable().Community, nil, nil, tonumber(newRank), nil, nil, trgID )
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
	local query
	local result

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

	query = "SELECT cid FROM community_table WHERE cname='"..tostring(args[1]).."'"
	result = sql.Query(query)
	ErrorNoHalt(tostring(os.date()).." SQL QUERY: (Find matching community name) Error:  "..tostring(sql.LastError()))

	if not result then
		NewCommunityInfo( ply, args[1] )
		ply:ChatPrint("You have created a community called "..tostring(args[1]).."!")
	else
		ply:ChatPrint("This community name is already taken!")
	end
end
concommand.Add( "pnrp_newcomm", PlyNewComm )
PNRP.ChatConCmd( "/newcomm", "pnrp_newcomm" )

function PlySetTitle(ply, cmd, args)
	local pid = tostring(args[1])
	local newTitle = tostring(args[2])
	local result
	local query

	query = "UPDATE community_members SET title='"..newTitle.."' WHERE pid='"..pid.."'"
	result = sql.Query(query)

	for _, v in pairs(player.GetAll()) do
		if tostring(v.pid) == pid then
			v:SetNWString("ctitle", newTitle)
		end
	end
end
concommand.Add( "pnrp_setTitle", PlySetTitle )

function PlyLeaveComm(ply, cmd, args)
	local query
	local result

	query = "SELECT cname FROM community_table WHERE cid="..tostring(ply.Community)
	result = sql.Query(query)
	ErrorNoHalt(tostring(os.date()).." SQL QUERY: (Find matching community) Error:  "..tostring(sql.LastError()))

	if result then
		ply:ChatPrint("You have left the community called "..tostring(ply:GetNWString("community")).."!")
		RemCommunityInfo( ply:GetTable().Community, ply.pid )
	else
		ply:ChatPrint("This community doesn't exist!")
	end
end
concommand.Add( "pnrp_leavecomm", PlyLeaveComm )
PNRP.ChatConCmd( "/leave", "pnrp_leavecomm" )

--NOW REQUIRES pid INSTEAD OF NAME!
function PlyRemComm(ply, cmd, args)
	if ply:GetTable().CommunityRank > 2 then
		RemCommunityInfo( ply:GetTable().Community, args[1])
		ply:ChatPrint("You have removed the user "..tostring(args[1]).." from the community!")
	else
		ply:ChatPrint("This community doesn't exist!")
	end
end
concommand.Add( "pnrp_remcomm", PlyRemComm )
PNRP.ChatConCmd( "/remove", "pnrp_remcomm" )

function PlyDemSelfComm(ply, cmd, args)
	--function AmendCommunityInfo( cid, name, title, rank, lastlog, model, pid* )

	if ply:GetTable().Community then
		if ply:GetTable().CommunityRank < 2 then
			ply:ChatPrint( "You cannot demote yourself further." )
			return
		end
		AmendCommunityInfo(ply:GetTable().Community, nil, nil, ply:GetTable().CommunityRank - 1, nil, nil, ply.pid)
		ply:GetTable().CommunityRank = ply:GetTable().CommunityRank - 1
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
			local foundStockpiles = ents.FindByClass("msc_stockpile")
			for k, v in pairs(foundStockpiles) do
				if tostring(v:GetNWString("community_owner")) == tostring(ply:GetTable().Community) then
					ply:ChatPrint( "You can only have one stockpile out at a time!" )
					return
				end
			end
			local communityTbl = GetCommunityTbl( ply:GetTable().Community )

			if table.Count(communityTbl["users"]) < 1 then
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
				ent:SetNWString("communityName", ply:GetNWString("community"))
				ent:SetNWString("community_owner", ply:GetTable().Community)
				ent:SetNWString("Owner", "Unownable")
				ent:SetPos( trace.HitPos + Vector(0,0,80) )
				ent:Spawn()
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
			local foundComLockers = ents.FindByClass("msc_equiplocker")
			for _, v in pairs(foundComLockers) do
				if tostring(v:GetNWString("community_owner")) == tostring(ply:GetTable().Community) then
					ply:ChatPrint( "You can only have one locker out at a time!" )
					return
				end
			end
			local communityTbl = GetCommunityTbl( ply:GetTable().Community )

			if table.Count(communityTbl["users"]) < 1 then
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
				ent:SetNWString("communityName", ply:GetNWString("community"))
				ent:SetNWString("community_owner", ply:GetTable().Community)
				ent:SetNWString("Owner", "Unownable")
				ent:SetPos( trace.HitPos + Vector(0,0,12) )
				ent:Spawn()

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
			local foundStockpiles = ents.FindByClass("msc_stockpile")
			for k, v in pairs(foundStockpiles) do
				if tostring(v:GetNWString("community_owner")) == tostring(ply:GetTable().Community) then
					local stockpile = v
					ply:ChatPrint( "Your stockpile will take 1 minute to break down.  It can be interacted with in that time." )
					timer.Simple(60, function ()
						if IsValid(stockpile) then
							stockpile:Remove()
						end
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
			local foundComLockers = ents.FindByClass("msc_equiplocker")
			for _, v in pairs(foundComLockers) do
				if tostring(v:GetNWString("community_owner")) == tostring(ply:GetTable().Community) then
					local locker = v
					ply:ChatPrint( "Your locker will take 1 minute to break down.  It can be interacted with in that time." )
					timer.Simple(60, function ()
						if IsValid(locker) then
							locker:Remove()
						end
					end)
					return
				end
			end
			ply:ChatPrint( "No locker found!" )
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
	
	local contents = {}
	contents.res = {}
	
	local getRec
	local int
	local cost = GetConVarNumber("pnrp_deathCost") / 100

	contents.name = ply:Nick()
	
	getRec = ply:GetResource("Scrap")
	int = getRec * cost
	int = math.Round(int / 2)
	if getRec - int >= 0 then
		contents.res.scrap = int
	else
		contents.res.scrap = 0
	end
	
	getRec = ply:GetResource("Small_Parts")
	int = getRec * cost
	int = math.Round(int / 2)
	if getRec - int >= 0 then
		contents.res.small = int
	else
		contents.res.small = 0
	end
	
	getRec = ply:GetResource("Chemicals")
	int = getRec * cost
	int = math.Round(int / 2)
	if getRec - int >= 0 then
		contents.res.chems = int
	else
		contents.res.chems = 0
	end
	
	contents.inv = {}
	contents.ammo = {}
	
	local pos = ply:GetPos() + Vector(0,0,20)
	--Drop Weapons
	for k, v in pairs(ply:GetWeapons()) do
		local wepModel
		if string.lower(v:GetClass()) == "weapon_radio" then
			wepModel = "models/Weapons/V_hands.mdl"
		else
			wepModel = v:GetModel()
		end
		
		local wepCheck = PNRP.CheckDefWeps(v) and v != "weapon_real_cs_admin_weapon"
		if !wepCheck then
			if PNRP.FindWepItem(wepModel) then
				local myItem
				if string.lower(v:GetClass()) == "weapon_radio" then
				--	myItem = PNRP.FindItemID( v:GetClass() )
					myItem = PNRP.Items["wep_radio"]
				else
					myItem = PNRP.FindWepItem( v:GetModel() )
				end
			--	Msg(tostring(v:GetModel()).." "..tostring(myItem.ID).."\n")
				-- local ent = ents.Create("ent_weapon")
				-- --ply:PrintMessage( HUD_PRINTTALK, v:GetPrintName( ) )
				-- --ply:ChatPrint( "Dropped "..myItem.Name)
				-- ent:SetModel(myItem.Model)
				-- ent:SetAngles(Angle(0,0,0))
				-- ent:SetPos(pos)
				-- ent:Spawn()
				-- ent:SetNWString("WepClass", myItem.Ent)
				-- ent:SetNetworkedInt("Ammo", v:Clip1())
				-- ent:SetNetworkedString("Owner", "World")
				local ammoDrop = ply:GetAmmoCount(v:GetPrimaryAmmoType())
				if myItem.ID == "wep_grenade" or myItem.ID == "wep_shapedcharge" then
					--skip
				else
					contents.inv[myItem.ID] = 1
				end
								
				if ammoDrop > 0 then
					local myAmmoType = PNRP.ConvertAmmoType(v:GetPrimaryAmmoType())
					-- local entClass
					-- local entModel
				-- --	ply:ChatPrint(myAmmoType)
				-- --	ply:SendHint( "Dropped "..myItem.Name,5)
					local ammoFType
					-- --grenade fix
					if myItem.ID == "wep_grenade" then
					--	contents.inv[myItem.ID] = contents.inv[myItem.ID] + ammoDrop - 1
						print(ammoDrop)
						contents.inv[myItem.ID] = ammoDrop - 1
					elseif myItem.ID == "wep_shapedcharge" then
						ammoFType = "slam"
						contents.ammo[myAmmoType] = ammoDrop + v:Clip1() - 1
					else
						ammoFType = "ammo_"..myAmmoType
						contents.ammo[myAmmoType] = ammoDrop + v:Clip1()
					end
				end
			end
		end
	end
	
	PNRP.PlyDeathZombie(ply, contents)
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
	--Changed some ammo type numbers to crrectly reflect what they are in game.
	if ammoType == 1 then sendType = "ar2" end -- Ammunition of the AR2/Pulse Rifle
	if ammoType == 2 then sendType = "alyxgun" end -- (name in-game "5.7mm Ammo")
	if ammoType == 3 then sendType = "pistol" end -- Ammunition of the 9MM Pistol
	if ammoType == 4 then sendType = "smg1" end -- Ammunition of the SMG/MP7
	if ammoType == 5 then sendType = "357" end -- Ammunition of the .357 Magnum
	if ammoType == 6 then sendType = "xbowbolt" end -- Ammunition of the Crossbow
	if ammoType == 7 then sendType = "buckshot" end -- Ammunition of the Shotgun
	if ammoType == 8 then sendType = "rpg_round" end -- Ammunition of the RPG/Rocket Launcher
	if ammoType == 9 then sendType = "smg1_grenade" end -- Ammunition for the SMG/MP7 grenade launcher (secondary fire)
	if ammoType == 12 then sendType = "sniperround" end
	if ammoType == 22 then sendType = "sniperpenetratedround" end -- (name in-game ".45 Ammo")
	if ammoType == 10 then sendType = "grenade" end -- Note you must be given the grenade weapon (e.g. pl:Give ("weapon_grenade")) before you can throw any grenades
	if ammoType == 13 then sendType = "thumper" end -- Ammunition cannot exceed 2 (name in-game "Explosive C4 Ammo")
	if ammoType == 14 then sendType = "gravity" end -- (name in-game "4.6MM Ammo")
	if ammoType == 15 then sendType = "battery" end -- (name in-game "9MM Ammo")
	if ammoType == 16 then sendType = "gaussEnergy" end
	if ammoType == 17 then sendType = "combineCannon" end -- (name in-game ".50 Ammo")
	if ammoType == 18 then sendType = "airboatGun" end -- (name in-game "5.56MM Ammo")
	if ammoType == 19 then sendType = "striderMinigun" end -- (name in-game "7.62MM Ammo")
	if ammoType == 20 then sendType = "helicopterGun" end
	if ammoType == 21 then sendType = "ar2altfire" end -- Ammunition of the AR2/Pulse Rifle 'combine ball' (secondary fire)
	if ammoType == 11 then sendType = "slam" end -- See Grenade

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
		if myWep:GetClass() == "weapon_radio" then
			wepModel = "models/props_citizen_tech/transponder.mdl"
		end
		local wepEnt = "ent_weapon"--ConvertWepEnt( wepModel )

		local tr = ply:TraceFromEyes(200)
		local trPos = tr.HitPos

		local ent = ents.Create(wepEnt)
		local pos = trPos + Vector(0,0,20)
		ent:SetModel(wepModel)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(pos)
		ent:Spawn()
		ent:SetNetworkedString("Owner", "World")
		ent:SetNWString("WepClass", myWep:GetClass())
		ent:SetNetworkedInt("Ammo", myWep:Clip1())

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
function PNRP.DropWep()

	local ply = net.ReadEntity()
	local myWep = PNRP.Items[net.ReadString()]
	local curWepAmmo = net.ReadString()
	--local myWep = PNRP.Items[decoded[1]]
	--local curWepAmmo = decoded[2]

	local tr = ply:TraceFromEyes(200)
	local trPos = tr.HitPos

	local ent = ents.Create("ent_weapon")
	local pos = trPos + Vector(0,0,20)
	ent:SetModel(myWep.Model)
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	ent:Spawn()
	ent:SetNetworkedString("Owner", "World")
	ent:SetNWString("WepClass", myWep.Ent)
	ent:SetNetworkedInt("Ammo", curWepAmmo)

end
--datastream.Hook( "pnrp_dropWepFromEQ", PNRP.DropWep )
net.Receive( "pnrp_dropWepFromEQ", PNRP.DropWep )

function PNRP.StripWep (ply, command, args)
	local wep = args[1]
	if wep == "weapon_frag" then
		ply:RemoveAmmo( 1, "grenade" )
	elseif wep == "weapon_pnrp_charge" then
		ply:RemoveAmmo( 1, "slam" )
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


function PNRP.DropAmmo(ply, command, args)
	local ammoType = args[1]
	local ammoAmt = tonumber(args[2])
	local ammoFType

	--Converts into the correct ItemID
	if ammoType == "slam" then ammoFType = "weapon_pnrp_charge"
	elseif ammoType == "grenade" then ammoFType = "weapon_frag"
	else ammoFType = "ammo_"..string.lower(ammoType) end
	local ItemID = PNRP.FindItemID( ammoFType )

	if ItemID then
		local EntSetting
		local tr = ply:TraceFromEyes(200)
		local trPos = tr.HitPos

		ply:ChatPrint("Dropping "..ammoAmt.." "..PNRP.Items[ItemID].Name)

		if ammoType == "slam" or ammoType == "grenade" then EntSetting = "ent_weapon"
		else EntSetting = PNRP.Items[ItemID].Ent end

		local ent = ents.Create(EntSetting)
		local pos = trPos + Vector(0,0,20)
		ent:SetModel(PNRP.Items[ItemID].Model)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(pos)
		ent:Spawn()
		ent:SetNetworkedString("WepClass", PNRP.Items[ItemID].Ent)
		ent:SetNetworkedString("Owner", "World")
		ent:SetNetworkedString("Ammo", tostring(ammoAmt))
	else
		ply:ChatPrint("Invalid ammo type. "..ammoFType)
		return
	end

	if ammoType == "grenade" or ammoType == "slam" then ammoAmt = 1 end
	ply:RemoveAmmo( ammoAmt, ammoType )
end
concommand.Add( "pnrp_dropAmmo", PNRP.DropAmmo )
PNRP.ChatConCmd( "/dropammo", "pnrp_eqipment" )

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
	ply:ChatPrint("Pos:  "..tostring(ent:GetPos()) )
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

function seatSetup(ply, cmd, args)
	for _, car in pairs(ents.FindInSphere( ply:GetPos(), 200 )) do
		local ItemID = PNRP.FindItemID( car:GetClass() )
		if ItemID != nil then
			if ItemID == "vehicle_jalopy" and car:GetModel() == "models/buggy.mdl" then
				ItemID = "vehicle_jeep"
			end
			local myType = PNRP.Items[ItemID].Type
			if tostring(car:GetNetworkedString( "Owner_UID" , "None" )) == PNRP:GetUID(ply) && myType == "vehicle" then
				
				local seatModel
				local seatPos
				if ItemID == "vehicle_jalopy" then
					seatPos = util.LocalToWorld( car, Vector(20, -26, 20))
					seatModel = "models/nova/jalopy_seat.mdl"
				elseif ItemID == "vehicle_airboat" then
					seatPos = util.LocalToWorld( car, Vector(0, -45, 65))
					seatModel = "models/nova/airboat_seat.mdl"
				else
					seatPos = util.LocalToWorld( car, Vector(20, -35, 20))
					seatModel = "models/nova/jeep_seat.mdl"
				end
				
				local seats = constraint.FindConstraints( car, "Weld" )
				for _, seat in pairs(seats) do
					if seat.Entity[2].Entity.seat == 1 then
						seat.Entity[2].Entity:Remove()
					end
				end
				
				local ent = ents.Create("prop_vehicle_prisoner_pod")
				
				ent:SetPos(seatPos)
				ent:SetAngles(car:GetAngles()+Angle(0,0,0))
				ent:SetModel(seatModel)
				ent:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
				ent:SetKeyValue( "model", seatModel )
				ent:Spawn()
				ent:Activate()
				ent.seat = 1
				PNRP.SetOwner(ply, ent)
				
				constraint.Weld(car, ent, 0, 0, 0, true)
				ent:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
			end
		end
	end
	
end
concommand.Add( "pnrp_seatSetup", seatSetup )
PNRP.ChatConCmd( "/carseat", "pnrp_seatSetup" )

function plyAFK(ply, cmd, args)
	if ply:GetTable().IsAsleep then
		ply:ChatPrint("You can not go afk while asleep.")
		return
	end
	if ply.AFK then
		ply.AFK = false
		ply:Freeze(false)
		ply:SetRenderMode(0)
		ply:SetColor( Color(255,255,255,255) )
		net.Start("sleepeffects")
			net.WriteBit(false)
		net.Send(ply)
		ply:ChatPrint("You are no longer AFK")
		
		timer.Create( "AFK_"..tostring(ply), 900, 1, function() 
			if IsValid(ply) then
				ply.CantAFK = false
				ply:ChatPrint("AFK Available again.")
			end
		end)
		
		return
	end
	if not ply.CantAFK then
		if not ply.AFK then
			ply.AFK = true
			ply:Freeze(true)
			ply:SetRenderMode(1)
			ply:SetColor( Color(255,255,255,150) )
			if ply:HasWeapon( "gmod_rp_hands" ) then
				ply:SelectWeapon( "gmod_rp_hands")
			end
			net.Start("sleepeffects")
				net.WriteBit(true)
			net.Send(ply)
			ply:ChatPrint("You are now AFK")
			ply:ChatPrint("You can still be hurt while AFK")
			ply.CantAFK = true
		end	
	else
		ply:ChatPrint("You can only go AFK every 15 minuts.")
	end
end
concommand.Add( "pnrp_afk", plyAFK )
PNRP.ChatConCmd( "/afk", "pnrp_afk" )
--EOF