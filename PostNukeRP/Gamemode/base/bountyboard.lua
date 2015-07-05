
function startBountyBoard()
	local ply = net.ReadEntity()
	local pid = tostring(ply.pid)
	local bbTable = {}
	local bbCompTable = {}
	local bbPostedTable = {}
	local bbTakenTable  = {}
	
	PNRP.BountyExpCheck()
	--//Open Bounties
	local queryBB = "SELECT * FROM bounty_table WHERE completed != 'true' AND completed != 'expired'"
	local resultBB = querySQL(queryBB)
	if resultBB then 
		for k, v in pairs( resultBB ) do
			local queryTarget = "SELECT * FROM profiles WHERE pid='"..v["target_pid"].."'"
			local target = querySQL(queryTarget)
			local tbl = {}
			tbl["bid"] = v["bid"]
			tbl["pid"] = v["target_pid"]
			tbl["name"] = target[1]["nick"]
			tbl["model"] = target[1]["model"]
			tbl["class"] = target[1]["class"]
			tbl["community"] = PNRP.GetCommunityName(v["target_pid"])
			tbl["date"] = v["poster_date"]
			tbl["payment"] = v["payment"]
			tbl["notes"] = v["notes"]
			tbl["completed"] = v["completed"]
			tbl["player_pid"] = pid
			tbl["poster_pid"] = v["poster_pid"]
			tbl["hitmen_pid"] = v["hitmen_pid"]
			table.insert(bbTable, tbl)
		end
	end
	--//Posted Bounties
	local queryPostedBB = "SELECT * FROM bounty_table WHERE poster_pid="..pid
	local resultPostedBB = querySQL(queryPostedBB)
	if resultPostedBB then
		for k, v in pairs( resultPostedBB ) do
			local queryTarget = "SELECT * FROM profiles WHERE pid='"..v["target_pid"].."'"
			local target = querySQL(queryTarget)
			local tbl = {}
			tbl["bid"] = v["bid"]
			tbl["pid"] = v["target_pid"]
			tbl["name"] = target[1]["nick"]
			tbl["model"] = target[1]["model"]
			tbl["class"] = target[1]["class"]
			tbl["community"] = PNRP.GetCommunityName(v["target_pid"])
			tbl["date"] = v["poster_date"]
			tbl["payment"] = v["payment"]
			tbl["notes"] = v["notes"]
			tbl["completed"] = v["completed"]
			tbl["comption_date"] = v["competion_date"]
			tbl["completed_by"] = PNRP.GetPlayerNamePID(v["completed_by_pid"])
			tbl["posted_by"] = PNRP.GetPlayerNamePID(v["poster_pid"])
			tbl["player_pid"] = pid
			tbl["poster_pid"] = v["poster_pid"]
			table.insert(bbPostedTable, tbl)
		end	
	end
	--//Completed Bounties
	local queryCompBB = "SELECT * FROM bounty_table WHERE completed_by_pid="..pid
	local resultCompBB = querySQL(queryCompBB)
	if resultCompBB then
		for k, v in pairs( resultCompBB ) do
			local queryTarget = "SELECT * FROM profiles WHERE pid='"..v["target_pid"].."'"
			local target = querySQL(queryTarget)
			local tbl = {}
			tbl["bid"] = v["bid"]
			tbl["pid"] = v["target_pid"]
			tbl["name"] = target[1]["nick"]
			tbl["model"] = target[1]["model"]
			tbl["class"] = target[1]["class"]
			tbl["community"] = PNRP.GetCommunityName(v["target_pid"])
			tbl["date"] = v["poster_date"]
			tbl["payment"] = v["payment"]
			tbl["notes"] = v["notes"]
			tbl["completed"] = v["completed"]
			tbl["competion_date"] = v["competion_date"]
			tbl["completed_by"] = PNRP.GetPlayerNamePID(v["completed_by_pid"])
			tbl["posted_by"] = PNRP.GetPlayerNamePID(v["poster_pid"])
			tbl["player_pid"] = pid
			tbl["poster_pid"] = v["poster_pid"]
			table.insert(bbCompTable, tbl)
		end	
	end
	--//Taken Bounties
	local queryTekenBB = "SELECT * FROM bounty_table WHERE hitmen_pid LIKE '%"..pid.."%' AND completed != 'true' AND completed != 'expired'"
	local resultTakenBB = querySQL(queryTekenBB)
	if resultTakenBB then
		for k, v in pairs( resultTakenBB ) do
			local queryTarget = "SELECT * FROM profiles WHERE pid='"..v["target_pid"].."'"
			local target = querySQL(queryTarget)
			local tbl = {}
			tbl["bid"] = v["bid"]
			tbl["pid"] = v["target_pid"]
			tbl["name"] = target[1]["nick"]
			tbl["model"] = target[1]["model"]
			tbl["class"] = target[1]["class"]
			tbl["community"] = PNRP.GetCommunityName(v["target_pid"])
			tbl["date"] = v["poster_date"]
			tbl["payment"] = v["payment"]
			tbl["notes"] = v["notes"]
			tbl["player_pid"] = pid
			tbl["poster_pid"] = v["poster_pid"]
			table.insert(bbTakenTable, tbl)
		end	
	end
	
	net.Start("pnrp_OpenBountyBoard")
		net.WriteTable(bbTable)
		net.WriteTable(bbPostedTable)
		net.WriteTable(bbCompTable)
		net.WriteTable(bbTakenTable)
	net.Send(ply)
end
net.Receive( "startBountyBoard", startBountyBoard )
util.AddNetworkString("startBountyBoard")
util.AddNetworkString("pnrp_OpenBountyBoard")

function runBountyAdmin()
	local ply = net.ReadEntity()
	local pid = tostring(ply.pid)
	local bbTable = {}
	local bbCompTable = {}
	local bbExpTable = {}
	
	PNRP.BountyExpCheck()
	--//Open Bounties
	local queryBB = "SELECT * FROM bounty_table WHERE completed != 'true' AND completed != 'expired'"
	local resultBB = querySQL(queryBB)
	if resultBB then 
		for k, v in pairs( resultBB ) do
			local queryTarget = "SELECT * FROM profiles WHERE pid='"..v["target_pid"].."'"
			local target = querySQL(queryTarget)
			local tbl = {}
			local hitmen = nil
			local hitmen_pid = string.Explode(",",v["hitmen_pid"])
			for v, hpid in pairs(hitmen_pid) do
				local hitman_name = PNRP.GetPlayerNamePID(hpid)
				if hitmen == nil then
					hitmen = hitman_name
				else
					hitmen = hitmen..","..hitman_name
				end
			end
			tbl["bid"] = v["bid"]
			tbl["pid"] = v["target_pid"]
			tbl["name"] = target[1]["nick"]
			tbl["model"] = target[1]["model"]
			tbl["class"] = target[1]["class"]
			tbl["community"] = PNRP.GetCommunityName(v["target_pid"])
			tbl["date"] = v["poster_date"]
			tbl["payment"] = v["payment"]
			tbl["notes"] = v["notes"]
			tbl["completed"] = v["completed"]
			tbl["competion_date"] = v["competion_date"]
			tbl["completed_by"] = PNRP.GetPlayerNamePID(v["completed_by_pid"])
			tbl["posted_by"] = PNRP.GetPlayerNamePID(v["poster_pid"])
			tbl["hitmen"] = hitmen
			table.insert(bbTable, tbl)
		end
	end
	
	--//Completed Bounties
	local queryCompBB = "SELECT * FROM bounty_table WHERE completed='true'"
	local resultCompBB = querySQL(queryCompBB)
	if resultCompBB then
		for k, v in pairs( resultCompBB ) do
			local queryTarget = "SELECT * FROM profiles WHERE pid='"..v["target_pid"].."'"
			local target = querySQL(queryTarget)
			local tbl = {}
			local hitmen = nil
			local hitmen_pid = string.Explode(",",v["hitmen_pid"])
			for _, hpid in pairs(hitmen_pid) do
				local hitman_name = PNRP.GetPlayerNamePID(hpid)
				if hitmen == nil then
					hitmen = hitman_name
				else
					hitmen = hitmen..","..hitman_name
				end
			end
			tbl["bid"] = v["bid"]
			tbl["pid"] = v["target_pid"]
			tbl["name"] = target[1]["nick"]
			tbl["model"] = target[1]["model"]
			tbl["class"] = target[1]["class"]
			tbl["community"] = PNRP.GetCommunityName(v["target_pid"])
			tbl["date"] = v["poster_date"]
			tbl["payment"] = v["payment"]
			tbl["notes"] = v["notes"]
			tbl["completed"] = v["completed"]
			tbl["competion_date"] = v["competion_date"]
			tbl["completed_by"] = PNRP.GetPlayerNamePID(v["completed_by_pid"])
			tbl["posted_by"] = PNRP.GetPlayerNamePID(v["poster_pid"])
			tbl["hitmen"] = hitmen
			table.insert(bbCompTable, tbl)
		end	
	end
	
	--//Expired Bounties
	local queryExpBB = "SELECT * FROM bounty_table WHERE completed='expired'"
	local resultExpBB = querySQL(queryExpBB)
	if resultExpBB then
		for k, v in pairs( resultExpBB ) do
			local queryTarget = "SELECT * FROM profiles WHERE pid='"..v["target_pid"].."'"
			local target = querySQL(queryTarget)
			local tbl = {}
			local hitmen = nil
			local hitmen_pid = string.Explode(",",v["hitmen_pid"])
			for _, hpid in pairs(hitmen_pid) do
				local hitman_name = PNRP.GetPlayerNamePID(hpid)
				if hitmen == nil then
					hitmen = hitman_name
				else
					hitmen = hitmen..","..hitman_name
				end
			end
			tbl["bid"] = v["bid"]
			tbl["pid"] = v["target_pid"]
			tbl["name"] = target[1]["nick"]
			tbl["model"] = target[1]["model"]
			tbl["class"] = target[1]["class"]
			tbl["community"] = PNRP.GetCommunityName(v["target_pid"])
			tbl["date"] = v["poster_date"]
			tbl["payment"] = v["payment"]
			tbl["notes"] = v["notes"]
			tbl["completed"] = v["completed"]
			tbl["competion_date"] = v["competion_date"]
			tbl["completed_by"] = PNRP.GetPlayerNamePID(v["completed_by_pid"])
			tbl["posted_by"] = PNRP.GetPlayerNamePID(v["poster_pid"])
			tbl["hitmen"] = hitmen
			table.insert(bbExpTable, tbl)
		end	
	end
	
	net.Start("pnrp_OpenBountyAdmin")
		net.WriteTable(bbTable)
		net.WriteTable(bbCompTable)
		net.WriteTable(bbExpTable)
	net.Send(ply)
end
net.Receive( "runBountyAdmin", runBountyAdmin )
util.AddNetworkString("runBountyAdmin")
util.AddNetworkString("pnrp_OpenBountyAdmin")

function postBounty()
	local ply = net.ReadEntity()
	local target = net.ReadEntity()
	local scrap = net.ReadDouble()
	local parts = net.ReadDouble()
	local chems = net.ReadDouble()
	local notes = net.ReadString()
	
	local minScrap = 200
	local minParts = 75
	local minChems  = 10
	local tax = 10
	
	if !IsValid(target) then
		ply:ChatPrint("Invalid target for bounty. Player may have logged off.")
		return
	end
	
	if tostring(ply.pid) == tostring(target.pid) then
		ply:ChatPrint("You can not place a bounty on yourself.")
		return
	end
	
	local queryChk = "SELECT * FROM bounty_table WHERE completed='false' AND poster_pid='"..tostring(ply.pid).."' AND target_pid='"..tostring(target.pid).."'"
	local resultChk = querySQL(queryChk)

	if resultChk then
		ply:ChatPrint("You already have a bounty posted on this target.")
		return
	end
	
	local plyScrap = ply:GetResource("Scrap")
	local plyParts = ply:GetResource("Small_Parts")
	local plyChems = ply:GetResource("Chemicals")
	
	--If player does not have enough to post bounty
	if plyScrap < scrap or plyParts < parts or plyChems < chems then
		ply:ChatPrint("You do not have enough to post a bounty.")
		return
	end
	
	ply:DecResource("Scrap",scrap)
	ply:DecResource("Small_Parts",parts)
	ply:DecResource("Chemicals",chems)
	
	--Bounty Tax
	local cost = tax / 100
	scrap = scrap - math.Round(scrap * cost)
	parts = parts - math.Round(parts * cost)
	chems = chems - math.Round(chems * cost)
	
	local pid = tonumber(ply.pid)
	local tpid = tonumber(target.pid)
	local payment = tostring(scrap)..","..tostring(parts)..","..tostring(chems)
	
	--poster_id, posted_date, target_pid, payment, notes, hitmen_pid, completed, completion_date, completed_by_pid 
	local query = "INSERT INTO bounty_table VALUES ( NULL,"..pid..", '"..os.time().."', '"..tpid.."', '"..payment.."', "..SQLStr(notes)..", NULL, '".."false".."', NULL, NULL )"
	querySQL(query)
	
	ply:ChatPrint("Bounty Posted")
	ply:EmitSound(Sound("items/ammo_pickup.wav"))
end
net.Receive( "postBounty", postBounty )
util.AddNetworkString("postBounty")

function takeBounty()
	local ply = net.ReadEntity()
	local pid = tostring(ply.pid)
	local bid = net.ReadString()
	local target_name = net.ReadString()
	local tpid = net.ReadString()
	
	if tostring(pid) == tostring(tpid) then
		ply:ChatPrint("You can not accept a bounty on yourself.")
		return
	end
	
	local queryBB = "SELECT * FROM bounty_table WHERE completed != 'true' AND completed != 'expired' AND bid="..SQLStr(bid).." AND hitmen_pid LIKE '%"..pid.."%'"
	local resultCHK = querySQL(queryBB)
	
	if resultCHK then
		ply:ChatPrint("You have allready accepted this bounty.")
		return
	else
		local queryGetBB = "SELECT * FROM bounty_table WHERE completed != 'true' AND completed != 'expired' AND bid="..SQLStr(bid)
		local result = querySQL(queryGetBB)

		local hitmen = result[1]["hitmen_pid"]
		if hitmen == nil then
			hitmen = tostring(pid)
		else
			hitmen = hitmen..","..tostring(pid)
		end
		
		query = "UPDATE bounty_table SET hitmen_pid='"..hitmen.."' WHERE bid='"..bid.."'"
		querySQL(query)
		ply:ChatPrint("You have take the bounty on "..target_name)
	end
	
	
end
net.Receive( "takeBounty", takeBounty )
util.AddNetworkString("takeBounty")

function PNRP.BountyCheck(target, ply)
	local pid = ply.pid
	local tpid = target.pid
	local queryB = "SELECT * FROM bounty_table WHERE completed != 'true' AND completed != 'expired' AND target_pid='"..tpid.."' AND hitmen_pid LIKE '%"..pid.."%'"
	local bountyTbl = querySQL(queryB)
	
	if bountyTbl then
		for _, bounty in pairs(bountyTbl) do
			local bid = bounty["bid"]
			local queryCB = "UPDATE bounty_table SET completed='true', completion_date='"..os.time().."', completed_by_pid='"..pid.."' WHERE bid='"..bid.."'"
			querySQL(queryCB)
			
			local resources = string.Explode(",", bounty["payment"])
			local scrap = resources[1]
			local parts = resources[2]
			local chems = resources[3]
			
			ply:IncResource("Scrap",scrap)
			ply:IncResource("Small_Parts",parts)
			ply:IncResource("Chemicals",chems)
			
			local payStr = scrap..", "..parts..", "..chems
			local poster_pid = bounty["poster_pid"]
			local clientName = PNRP.GetPlayerNamePID(poster_pid)
			
			ply:ChatPrint("You have been paid "..payStr.." by "..clientName.." for the hit on "..target:Nick())
			target:ChatPrint("You were taken out due to a bounty on your head.")
			
			local hitmen = string.Explode(",",bounty["hitmen_pid"])
			for _, iplayer in pairs(player.GetAll()) do
				if iplayer:GetClass()=="player" then
					for _, hpid in pairs(hitmen) do
						if tostring(hpid) == tostring(iplayer.pid) then
							iplayer:ChatPrint("The bounty for "..target:Nick().." has ended.")
						end
					end
					
					if tostring(iplayer.pid) == tostring(poster_pid) then
						iplayer:ChatPrint("You paid "..ply:Nick().." "..payStr.." for the bounty on "..target:Nick())
					end
				end		
			end
			
			ErrorNoHalt("[Bounty] Target: "..target:Nick()..", Hitman:"..ply:Nick()..", Client: "..clientName..", Award: "..payStr.."\n")
		end
	end
end

function PNRP.BountyExpCheck()
	local expSec = 3 * 24 * 60 * 60 --3 days
	local expTime = os.time() - expSec
	
	local query = "SELECT * FROM bounty_table WHERE completed != 'true' AND completed != 'expired' AND posted_date < '"..expTime.."'"
	local result = querySQL(query)
	
	if result then
		for _, bounty in pairs(result) do
			local bid = bounty["bid"]
			local poster_pid = bounty["poster_pid"]
			local res = bounty["payment"]
			local expQuery = "UPDATE bounty_table SET completed='expired' WHERE bid='"..bid.."'"
			querySQL(expQuery)
			
			--lets the player know if they are on
			for _, iplayer in pairs(player.GetAll()) do
				if tostring(bounty["poster_pid"]) == tostring(iplayer.pid) then
					iplayer:ChatPrint("Your bounty on "..tostring(PNRP.GetPlayerNamePID(bounty["target_pid"])).." expired.")
				end
			end
			
			local resTbl = string.Explode(",", res)
			PNRP.refundRes(poster_pid, resTbl[1], resTbl[2], resTbl[3])
		end
	end
	
end

function remBounty()
	local ply = net.ReadEntity()
	local bid = net.ReadString()
	
	local query = "SELECT * FROM bounty_table WHERE bid="..SQLStr(bid)
	local result = querySQL(query)
	
	if result then
		result = result[1]
		local completed = result["completed"]
		local pid = result["poster_pid"]
		local res = result["payment"]
		local target = PNRP.GetPlayerNamePID(result["target_pid"])
		
		if completed == "false" then
			local resTbl = string.Explode(",", res)
			PNRP.refundRes(pid, resTbl[1], resTbl[2], resTbl[3])
		end
		
		querySQL("DELETE FROM bounty_table WHERE bid="..SQLStr(tonumber(bid)))
		
		if tostring(ply.pid) == tostring(pid) then
			ply:ChatPrint("Bounty Deleted")
		else
			for _, iplayer in pairs(player.GetAll()) do
				if iplayer:GetClass()=="player" then
					if tostring(pid) == tostring(iplayer.pid) then
						iplayer:ChatPrint("Your bounty on "..target.." was deleted.")
					end
				end
			end
		end
	end
end
net.Receive( "remBounty", remBounty )
util.AddNetworkString("remBounty")



