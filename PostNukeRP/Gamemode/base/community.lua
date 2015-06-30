
function PNRP.SND_reopenComTab(len, pl)
	local ply = net.ReadEntity()
	local cid = net.ReadString()
	local tab = net.ReadString()
	if pl ~= ply then return end
	local PlayerCommunityName = ply:GetNetVar("community", "none")
	
	local tbl = GetCommunityTbl( cid )
	
	if cid == nil then cid = -1 end --nil check for people no tin community
	local queryPending = "SELECT * FROM community_pending WHERE cid="..SQLStr(cid)
	local resultPending = querySQL(queryPending)
	if not resultPending then resultPending = {} end
	
	local wars = {}
	local allies = {}
	
	for ocid, cStatus in pairs(tbl["diplomacy"]) do
		if ocid ~= nil then
			queryOcid = "SELECT * FROM community_table WHERE cid="..tostring(ocid)
			resultOcid = querySQL(queryOcid)
			local ocName
			if resultOcid then
				local oCtblInfo = resultOcid[1]
				ocName = oCtblInfo["cname"]
			else
				ocName = "[Unknown CID: "..ocid.."] | Click Cancel -->"
			end
			if cStatus == "war" then
				wars[ocid] = tostring(ocName)
			elseif cStatus == "ally" then
				allies[ocid] = tostring(ocName)
			end
		end
	end

	local fullComTable = {}
	fullComTable["communityTable"] = tbl
	fullComTable["communityPending"] = resultPending
	fullComTable["wars"] = wars
	fullComTable["allies"] = allies
	
	net.Start("C_SND_reopenComTab")
		net.WriteString(PlayerCommunityName)
		net.WriteTable(fullComTable)
		net.WriteString(tab)
	net.Send(ply)
end
util.AddNetworkString("SND_reopenComTab")
util.AddNetworkString("C_SND_reopenComTab")
net.Receive( "SND_reopenComTab", PNRP.SND_reopenComTab )

function PNRP.SearchCommunities()
	local ply = net.ReadEntity()
	local searchString = net.ReadString()
	
	local query = "SELECT * FROM community_table WHERE cname LIKE '%"..SQLStr2(searchString).."%'"
	local result = querySQL(query)
	
	if not result then return end
	
	net.Start("C_SND_CommSearchResults")
		net.WriteTable(result)
	net.Send(ply)
end
util.AddNetworkString("SND_CommSearch")
util.AddNetworkString("C_SND_CommSearchResults")
net.Receive( "SND_CommSearch", PNRP.SearchCommunities )

function PNRP.CommSelID()
	local ply = net.ReadEntity()
	local cid = tonumber(net.ReadString())

	local tbl = GetCommunityTbl( cid )
	
	if not tbl then return end
	
	local wars = {}
	local allies = {}
	
	for ocid, cStatus in pairs(tbl["diplomacy"]) do
		if ocid ~= nil then
			queryOcid = "SELECT * FROM community_table WHERE cid="..tostring(ocid)
			resultOcid = querySQL(queryOcid)
			local ocName
			if resultOcid then
				local oCtblInfo = resultOcid[1]
				ocName = oCtblInfo["cname"]
			else
				ocName = "[Unknown CID: "..ocid.."]"
			end
			if cStatus == "war" then
				wars[ocid] = tostring(ocName)
			elseif cStatus == "ally" then
				allies[ocid] = tostring(ocName)
			end
		end
	end
	
	net.Start("C_SND_CommSelResult")
		net.WriteTable(tbl)
		net.WriteTable(wars)
		net.WriteTable(allies)
	net.Send(ply)
end
util.AddNetworkString("SND_CommSelID")
util.AddNetworkString("C_SND_CommSelResult")
net.Receive( "SND_CommSelID", PNRP.CommSelID )

function PNRP.SendPending(len, pl)
	local ply = net.ReadEntity()
	if pl ~= ply then return end 
	
	local queryPending = "SELECT * FROM community_pending, community_table WHERE community_pending.cid = community_table.cid"
	local resultPending = querySQL(queryPending)
	
	if not resultPending then return end
	
	local comQuery = "SELECT * FROM community_table"
	local comTBL = querySQL(comQuery)

	net.Start("SND_CommViewPending")
		net.WriteTable(resultPending or {})
		net.WriteTable(comTBL or {})
	net.Send(ply)
end
util.AddNetworkString("SND_CommViewPending")
util.AddNetworkString("C_SND_CommSendPending")
net.Receive( "SND_CommViewPending", PNRP.SendPending )

function PNRP.SND_DelPending(len, pl)
	local ply = net.ReadEntity()
	local cid = tonumber(net.ReadString())
	local pTime = net.ReadString()
	local fromMenu = net.ReadString()
	if pl ~= ply then return end
	
	local query = "DELETE FROM community_pending WHERE cid="..SQLStr(cid).." AND time="..SQLStr(pTime)
	querySQL(query)

	local query2 = "SELECT * FROM community_pending, community_table WHERE community_pending.cid = community_table.cid"
	local result = querySQL(query2)
	
	local comQuery = "SELECT * FROM community_table"
	local comTBL = querySQL(comQuery)
	
	if not result then return end
	
	if fromMenu == "pending" then
		timer.Simple(0.5, function ()
			net.Start("SND_CommViewPending")
				net.WriteTable(result)
				net.WriteTable(comTBL or {})
			net.Send(ply)
		end)
	end
end
util.AddNetworkString("SND_DelPending")
net.Receive( "SND_DelPending", PNRP.SND_DelPending )

function PNRP.SND_AdmDelComDep(len, pl)
	local ply = net.ReadEntity()
	local cid = tonumber(net.ReadString())
	local ocid = tonumber(net.ReadString())
	if pl ~= ply then return end
	
	if ply:IsAdmin() then
		RemDiplomacy( cid, ocid )
	end
end
util.AddNetworkString("SND_AdmDelComDep")
net.Receive( "SND_AdmDelComDep", PNRP.SND_AdmDelComDep )

--Resets Players Community Info
function PNRP.PlyDelComInfo(ply)
	
	ply.Community = nil
	ply:GetTable().Community = nil
	ply:SetNetVar( "cid", 0 )
	ply:SetNetVar("community", "N/A")
	ply:GetTable().CommunityRank = nil
	ply:SetNetVar("ctitle", "")
	ply.ComDiplomacy = {}
	ply:SendDipl()
	ply:ConCommand("pnrp_save")

end

function PNRP.GetCommunityName(pid)
	local name = "N/A"
	query = "SELECT * FROM community_members WHERE pid="..SQLStr(pid)
	result = querySQL(query)
	if result then 
		query2 = "SELECT * FROM community_table WHERE cid="..tostring(result[1]["cid"])
		result2 = querySQL(query2)
		
		if result2 then
			name = result2[1]["cname"]
		end
	end
		
	return name
end

