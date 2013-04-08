
function PNRP.SearchCommunities()
	local ply = net.ReadEntity()
	local searchString = net.ReadString()
	
	query = "SELECT * FROM community_table WHERE cname LIKE '%"..tostring(searchString).."%'"
	result = querySQL(query)
	
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

	result = GetCommunityTbl( cid )
	
	if not result then return end
	
	net.Start("C_SND_CommSelResult")
		net.WriteTable(result)
	net.Send(ply)
end
util.AddNetworkString("SND_CommSelID")
util.AddNetworkString("C_SND_CommSelResult")
net.Receive( "SND_CommSelID", PNRP.CommSelID )