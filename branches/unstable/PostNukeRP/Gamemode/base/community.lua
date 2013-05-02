
function PNRP.SND_reopenComTab()
	local ply = net.ReadEntity()
	local cid = net.ReadString()
	local tab = net.ReadString()
	local PlayerCommunityName = ply:GetNWString("community", "none")
	
	local tbl = GetCommunityTbl( cid )
	
	local queryPending = "SELECT * FROM community_pending WHERE cid="..tostring(cid)
	local resultPending = querySQL(queryPending)
	if not resultPending then resultPending = {} end
	
	local wars = {}
	local allies = {}
	
	for ocid, cStatus in pairs(tbl["diplomacy"]) do
		queryOcid = "SELECT * FROM community_table WHERE cid="..tostring(ocid)
		resultOcid = querySQL(queryOcid)
		local oCtblInfo = resultOcid[1]
		local ocName = oCtblInfo["cname"]
		if cStatus == "war" then
			wars[ocid] = tostring(ocName)
		elseif cStatus == "ally" then
			allies[ocid] = tostring(ocName)
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
	
	local query = "SELECT * FROM community_table WHERE cname LIKE '%"..tostring(searchString).."%'"
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
		queryOcid = "SELECT * FROM community_table WHERE cid="..tostring(ocid)
		resultOcid = querySQL(queryOcid)
		local oCtblInfo = resultOcid[1]
		local ocName = oCtblInfo["cname"]
		if cStatus == "war" then
			wars[ocid] = tostring(ocName)
		elseif cStatus == "ally" then
			allies[ocid] = tostring(ocName)
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

function PNRP.SendPending()
	local ply = net.ReadEntity()
	
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

function PNRP.SND_DelPending()
	local ply = net.ReadEntity()
	local cid = tonumber(net.ReadString())
	local pTime = net.ReadString()
	local fromMenu = net.ReadString()

	local query = "DELETE FROM community_pending WHERE cid="..tostring(cid).." AND time='"..pTime.."'"
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

function PNRP.SND_AdmDelComDep()
	local ply = net.ReadEntity()
	local cid = tonumber(net.ReadString())
	local ocid = tonumber(net.ReadString())
	
	if ply:IsAdmin() then
		RemDiplomacy( cid, ocid )
	end
end
util.AddNetworkString("SND_AdmDelComDep")
net.Receive( "SND_AdmDelComDep", PNRP.SND_AdmDelComDep )