util.AddNetworkString("pnrp_msg") 
util.AddNetworkString("pnrp_votemap")
util.AddNetworkString("pnrp_forcevotemap")
util.AddNetworkString("pnrp_cancelvotemap")
util.AddNetworkString("pnrp_openvotemap")
util.AddNetworkString("pnrp_closevotemap")

util.AddNetworkString("UpdateClientVotes") 
util.AddNetworkString("TLMenuToggle") 
util.AddNetworkString("MenuToggle") 
util.AddNetworkString("SendMaps") 
util.AddNetworkString("Reset")
util.AddNetworkString("Reset2")

local Prefixes={}
--local Prefixes={"pn_","gm_"}

local Total_Votes = 0
local maps = {}
local ties = {}
local votes = {}
local votesOverZero = 0
local MasterVoteSwitch = false
local MVSN = 0
local CanVote = true
local MapPicked = false
local HasVotedToStart = false
local CloseTime = 3600
for k,v in pairs(player.GetAll()) do v.HasVotedToStart = false end
WinningMapT = nil
WinningMap = nil

--Gets the map table
function buildMapTable()
	if not sql.TableExists("spawn_grids") then
		ErrorNoHalt("SQL ERROR:  spawn_grid TABLE does not exist.")
		return
	end
	
	local mapList = {}
	local mapListExport = {}
	map = {}
	local result = querySQL("SELECT * FROM spawn_grids")
	if result then
		for k, v in pairs(result) do
			votes[k] = 0 --Set all of the votes to 0
			local mapName = v["map"]
			if !mapList[mapName] then
				if file.Find( "maps/"..mapName..".bsp","GAME") then
					if mapName==tostring(game.GetMap()) then
						table.insert( mapListExport, "(C)_"..mapName )
					else
						table.insert( mapListExport, mapName )
					end
					table.insert( maps, mapName )
					mapList[mapName] = {map = mapName}
				end	
			end
		end
	end
	
	return mapListExport
end


--Send messages to the player or all players
local localPlayer = FindMetaTable( "Player" )

local function pnrp_chat_msg_all( text )

	if !text then return end

	net.Start("pnrp_msg")
		net.WriteString( text )
	net.Broadcast()

end
function pnrp_chat_msg( Ply, text )
	if not text then return end
	
	net.Start("pnrp_msg")
		net.WriteString( text )
	net.Send( Ply )

end

--Cancel the map switch.
function Cancel()
	if CanVote==true or Total_Votes>0 then
		pnrp_chat_msg_all("Map change cancelled.")
		
		--Toggle the time left menu
		timer.Simple(1, function() 
			net.Start("TLMenuToggle")
				net.WriteString( "<map name>"  .. " close")
			net.Broadcast()

		end )
		
		timer.Stop("1sec")
		timer.Stop("20sec")
		timer.Stop("30sec")
		timer.Stop("34sec")
		timer.Stop("TLM")

		if MapPicked==false then
			net.Start("Reset")
			net.Broadcast()
		else
			net.Start("Reset2")
			net.Broadcast()
		end
		
		maps={}
		votes={}
		ties={}
		votesOverZero=0
		
		CanVote = true
		MapPicked = false
		WinningMapT = nil
		WinningMap = nil
		VoteTime = nil
		Total_Votes = 0
		
		for k,v in pairs( player.GetAll() ) do
			v.HasVotedToStart = false
		end
		HasVotedToStart=false
	end
end
concommand.Add("pnrp_cancelvotemap", Cancel)


--Initiate a map vote
function PNRP_MAPVOTE() -- This is global incase you want to call it for map voting inside PNRP or some other script.
	if not CanVote then return end
	if VoteTime==false then return end

	local FullMapList = buildMapTable()
	net.Start( "SendMaps" )
		net.WriteTable( FullMapList )
	net.Broadcast()
	
	--Set all the votes to 0
	--for I = 0, #FullMapList do
	--	I = I + 1
	--	votes[I] = 0
	--end
	
	timer.Create("1sec", 1, 1, function() 
		for k,v in pairs( player.GetAll() ) do
			v.HasVotedMap = false
		end
		net.Start("MenuToggle")
		net.Broadcast()
	end )
	
	tc = math.min( ((#player.GetAll() * 250)/40)*2, 90 ) --Maximum of 90 seconds
	timer.Create("20sec", tc+2, 1, function() 
		--150 seconds
		VoteTime = false --End voting
	
		
		--Find all votes that aren't 0
		for k,v in pairs(votes) do
			if v > 0 then
				votesOverZero = votesOverZero + v
			end
		end
		
		if votesOverZero > 0 and CanVote==false and (votesOverZero >= math.ceil(#player.GetAll() * 0.3) ) then
		
			--Determine the highest number in the table.
			WinningMapT = maps[table.GetWinningKey(votes)]
			
			--Cycle through the maps table to find
			for k,v in pairs(maps) do
				if WinningMapT == tostring(v) then
					WMKey = votes[k]
				end
			end
			
			--If the winning map's number of votes is found again in the votes table, add that to the ties table.
			for k,v in pairs(votes) do
				if WMKey == v then
					table.insert( ties, k )
				end
			end
			
			if #ties > 1 then
				pnrp_chat_msg_all( "~"..#ties .."~ map(s) are tied! Picking randomly.")
				print("[PNRP_LOG]"..#ties .." map(s) are tied! Picking randomly.")
				WinningMap = maps[ties[math.Round(math.Rand(1,#ties))]]
			else
				WinningMap = WinningMapT
			end
			
			pnrp_chat_msg_all("Voting over! Map changing to: ~"..WinningMap.."~ in 30 seconds.")
			print("[PNRP_LOG] Voting is over, map is set to change to: "..WinningMap)
			MapPicked=true
			
			--Toggle the time left menu
			timer.Create("TLM", 1, 1, function() 
				net.Start("TLMenuToggle")
					net.WriteString( WinningMap .. " open" )
				net.Broadcast()
			end )

			--Close menu
			net.Start("MenuToggle")
			net.Broadcast()
				
			--Change the map after a period of time.
			timer.Create("30sec", 30, 1, function()

				net.Start("TLMenuToggle")
					net.WriteString( WinningMap .. " close")
				net.Broadcast()

				local MapPlusBsp = WinningMap .. ".bsp"
				local MapToChange = file.Exists("maps/"..MapPlusBsp, "GAME")

				if MapToChange then 
					pnrp_chat_msg_all("Map changing ~now~...")
				else
					pnrp_chat_msg_all("Map cannot change, it's missing or corrupt!")
				end
			end )
			
			--Actually change it :E
			timer.Create("34sec", 34, 1, function()
				print("[PNRP_LOG] Changing map to: "..WinningMap)
				RunConsoleCommand("changelevel",WinningMap)
			end )
			
		elseif votesOverZero < math.ceil(#player.GetAll() * 0.3) and votesOverZero>0 then
			pnrp_chat_msg_all("Not enough people voted!")
			print("[PNRP_LOG] Cancelled map vote, not enough people voted!")
			
			Cancel()

		elseif votesOverZero <= 0 then
		--elseif table.GetWinningKey(votes)>0 then
			pnrp_chat_msg_all("No one voted!")
			print("[PNRP_LOG] Cancelled map vote, no one voted!")
			
			Cancel()
			
		end
	end )
end

--Tell the clients to update their votes.
local function UpdateClientVotes(votestring)
	
	net.Start("UpdateClientVotes")
		net.WriteString(votestring)
	net.Broadcast()
end	
--Insert the vote, make sure it can't be anything other than 1, 0, or -1
local function InsertVote(key, value)

	if value>=1 then
		Avalue=1
	elseif value==0 then
		Avalue=0
	elseif value<=-1 then
		Avalue=-1
	end
	
	votes[key] = votes[key] + Avalue
end	
--Insert the client's vote to the server vote table, update the client's votes table.
function HandleVote(ply, cmd, args)
	local EStr = string.Explode(" ", args[1])
	
	InsertVote( tonumber(EStr[1]), tonumber(EStr[2]) )
	UpdateClientVotes( EStr[1] .. " " .. votes[tonumber(EStr[1])] )
end
concommand.Add("SendVote", HandleVote)

--Make sure you can start the vote.
local function TryToMapVote()

	if file.Exists("PostNukeRP/votemap.txt","DATA") then
		PNRP_MAPVOTE() //Call the main vote function.
	else
		timer.Simple(1, TryToMapVote)
	end
end

--Separate function for the last part of the vote so I can call it elsewhere
function CheckVote2()
	if Total_Votes >= math.Round( #player.GetAll() * (#player.GetAll() > 2 and 0.66 or 1) ) then
		pnrp_chat_msg_all( "Please double click a map on the left to vote." )
		print("[PNRP_LOG]Map vote started")
		
		TryToMapVote()
				
		
		CanVote=false --Don't allow /votemap to be recognized
		VoteTime = true --It's time to vote!
	end
end

--Determine if there is enough votes
local function CheckVote( ply )
	--VotesNeeded = (math.Round( #player.GetAll() * 0.66 )-Total_Votes)
	
	--Make players wait 60 minutes at the start of a map change so the map does not change so often.
	if MasterVoteSwitch==false then 
		pnrp_chat_msg(ply, "Voting closed, wait " .. math.Round( ((CloseTime - MVSN)/60),1) .. " minutes before voting!") 
	return end
	
	if ply.HasVotedToStart==true then pnrp_chat_msg(ply, "You have already voted to change the map!" ) return end //do not allow voting twice
	
	--if ply.HasVotedToStart==true then ply:pnrp_chat_msg( "You have already voted to change the map!" ) return end
	ply.HasVotedToStart=true
	
	
	Total_Votes = Total_Votes + 1

	
	pnrp_chat_msg_all( ply:Nick().." has voted for a map change! ")
	if (math.Round( #player.GetAll() * (#player.GetAll() > 2 and 0.66 or 1) )-Total_Votes)>0 then 
		if #player.GetAll()>1 then
			pnrp_chat_msg_all( "("..(math.Round( #player.GetAll() * (#player.GetAll() > 2 and 0.66 or 1) )-Total_Votes).." more votes(s) needed.)" )
		end
	end
	
	CheckVote2()

end
concommand.Add( "pnrp_votemap", CheckVote )

--Force a map vote
local function ForceVote( ply )

	if not ply:IsAdmin() and not ply:IsSuperAdmin() then return end
	if MapPicked==true then return end
	
	pnrp_chat_msg_all( "An Admin has forced a map vote." )
	pnrp_chat_msg_all( "Please vote for a map from the left panel." )
	print("[PNRP_LOG]Admin forced a map vote.")
	
	Total_Votes = 1
	
	for k,v in pairs(player.GetAll()) do
		v.HasVotedToStart=true
	end
	
	TryToMapVote() --Call the main vote function.
		
	CanVote=false --Don't allow /votemap to be recognized
	VoteTime = true --It's time to vote!
end
concommand.Add( "pnrp_forcevotemap", ForceVote )

--Open map vote if it's closed and an admins calls it.
local function OpenVote( )
	if MasterVoteSwitch==false then 

		MasterVoteSwitch = true
		MVSN = 3600
		timer.Stop("master delay")

		pnrp_chat_msg_all("Map voting opened! Type /votemap to vote.")
	end
end
concommand.Add( "pnrp_openvotemap", OpenVote )

--Close voting for a period
local function CloseVote( ply )
	if MasterVoteSwitch==true then 

		MasterVoteSwitch = false
		MVSN = 0

		timer.Create("master delay",1,CloseTime, function() MVSN = MVSN + 1 end)
		timer.Simple(CloseTime, function() MasterVoteSwitch=true, OpenVote() end)

		pnrp_chat_msg_all("Map voting closed for ".. CloseTime/60 .." minutes.")

		Cancel()
		
	end
end
concommand.Add( "pnrp_closevotemap", CloseVote )

--Start a 30 minute timer at the beginning of the gamemode start.
local function timers()
	timer.Create("master delay",1,CloseTime, function() MVSN = MVSN + 1 end)
	timer.Simple(CloseTime, function() 
		MasterVoteSwitch=true 
		OpenVote() 
	end)
end
hook.Add( "Initialize", "gamemode_start", timers() )

--Recognize chat votes
local function ChatVote( ply, text )

	local lastSaid = string.lower( text )
	local LSNA = string.Explode(" ", lastSaid)
	local LS = LSNA[1]
	local LSN = LSNA[2]
		
	if lastSaid == "/votemap" then
		if CanVote==true then
			--ply:ConCommand( "pnrp_votemap" )
			net.Start("pnrp_votemap")
			net.Send(ply)
		end
		
		if ply.HasVotedToStart==false then 
			pnrp_chat_msg(ply, "You voted for a map change!") 
		end
	elseif lastSaid == "/forcevotemap" then
		if ply:IsAdmin() or ply:IsSuperAdmin() then
			if VoteTime == false or VoteTime==nil then				
				net.Start("pnrp_forcevotemap")
				net.Send(ply)
			elseif VoteTime == true then
				pnrp_chat_msg(ply, "There is already a vote active!")
			end
		else
			pnrp_chat_msg(ply, "You are not an admin!")
		end
	elseif lastSaid == "/openvotemap" then
		if ply:IsAdmin() or ply:IsSuperAdmin() then
			if MasterVoteSwitch == false then				
				net.Start("pnrp_openvotemap")
				net.Send(ply)
			elseif MasterVoteSwitch == true then
				pnrp_chat_msg(ply, "Voting is already open!")
			end
		else
			pnrp_chat_msg(ply, "You are not an admin!")
		end
	elseif LS == "/closevotemap" and LSN then
		if ply:IsAdmin() or ply:IsSuperAdmin() then
			if MasterVoteSwitch == true then
				net.Start("pnrp_closevotemap")
				net.Send(ply)
				CloseTime = math.Min(LSN,1440)*60
			elseif MasterVoteSwitch == false then
				pnrp_chat_msg(ply, "Voting is already closed!")
			end
		else
			pnrp_chat_msg(ply, "You are not an admin!")
		end
	elseif (lastSaid == "/cancelvotemap" or lastSaid == "/cancel") then
		if ply:IsAdmin() or ply:IsSuperAdmin() then
			if VoteTime==true or MapPicked==true or Total_Votes > 0 then
				net.Start("pnrp_cancelvotemap")
				net.Send(ply)
			else
				pnrp_chat_msg(ply, "There is no vote to cancel!")
			end
		else
			pnrp_chat_msg(ply, "You are not an admin!")
		end
	end
end
hook.Add( "PlayerSay", "PNRP_PlayerSay", ChatVote )


--Remove the votes of players who have left
local function RemoveVotes( ply )

	if CanVote==true then
		if ply.HasVotedToStart==true and VoteTime==false then
			Total_Votes = Total_Votes - 1
			pnrp_chat_msg_all("Player "..ply:Nick().." Has left, removing their vote.")
		end
		
		--Check if the vote can go through now
		--timer.Simple(1, function()
			CheckVote2()
		--end)
	end

end
hook.Add( "PlayerDisconnected", "RemoveVotes", RemoveVotes )
 

--EOF
--(7-5-12)
--(Up:7-6-12)
--(Up:7-7-12)
--(Up:7-16-12)
--(Up:8-13-12)
--(UP:9-9-12)