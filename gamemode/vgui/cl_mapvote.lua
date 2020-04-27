
local maps = {}
local votes = {}
local votesOverZero = 0
local VotedNum = 0
local addsec = 0
local SecondsLeft = 30
ForceClose = 0

local White = Color(190,190,210)
local Green = Color(30,180,30)
local Red = Color(255,0,0)
local VotedForMap = false

--Load the maps
local function GetMaps( mapdata )
	maps = net.ReadTable()
	
	print(table.ToString(maps))
	
	--Add the (C)_ if the added map is the current one.
--	if mapfile==tostring(game.GetMap()) then
--		mapfileT = "(C)_"..mapfile
--		table.insert( maps, mapfileT )
--	else
--		table.insert( maps, mapfile )
--	end
	
end
net.Receive( "SendMaps", GetMaps )

--Update the votes
function UpdateVotes(um)
	--Replace with code below for GM13
	--Old--local t = string.Explode(" ", um:ReadString())
	local td = net.ReadString()
	local t = string.Explode(" ",td)
	--print("TD:" .. td .. "T1:" .. t[1] .. "T2:" .. t[2])
	votes[tonumber(t[1])] = tonumber(t[2])
end
net.Receive("UpdateClientVotes", UpdateVotes)

--Toggle the menu and deal with client side voting
local function VoteMenu()
	if not panel then
		VotedForMap=true
		ForceClose = 0
		
		panel = vgui.Create('DFrame')
		panel:SetSize(230, 320)
		panel:SetPos(20, ScrH() * 0.18)
		panel:SetTitle('Vote for a map! (Open chat for mouse)')
		panel:ShowCloseButton(false)
		panel:SetDraggable(true)
		panel:SetScreenLock(true)
		--panel:MakePopup()
		--panel:SetKeyBoardInputEnabled(false)

		button = vgui.Create('DButton', panel)
		button:SetSize(210, 20)
		button:SetPos(10,275)
		button:SetText('Clear your vote')
		button.DoClick = function()
			if VotedNum>0 then
				RunConsoleCommand("SendVote", VotedNum.." -1")
				VotedNum = 0
			end
		end
		
		VLpanel = vgui.Create( "DPanel", panel )
		VLpanel:SetPos( 185, 298 )
		VLpanel:SetSize( 40, 18 )
		
		votesleft = vgui.Create("DLabel", panel)
		votesleft:SetPos(188,298)
		--votesleft:SetFont("defaultBold")
		votesleft:SetWrap(false)
		votesleft:SetColor(Color(255,20,20,255))
		votesleft:SetText("0%")
		
								
		List = vgui.Create("DListView", panel)
		List:SetPos(10, 26)
		List:SetSize(210, 245)
		List:SetMultiSelect(false)
		MapDList = List:AddColumn("Map")
		VotesDList = List:AddColumn("Votes")
		VotesDList:SetMinWidth(10)
		VotesDList:SetMaxWidth(35)
		
		List.DoDoubleClick = function(parent, index, line)
			if (VotedNum != line:GetID() or VotedNum == 0) and VotedNum>=1 then
				RunConsoleCommand("SendVote", VotedNum.." -1")
			end
			if VotedNum!=line:GetID() then
				RunConsoleCommand("SendVote", line:GetID().." 1")
				VotedNum = line:GetID()
			end
		end
		List.Think = function()
			for k, v in pairs(List:GetLines()) do
				if votes[k] == nil then
					v:SetValue(2, 0)
				else
					v:SetValue(2, votes[k])
				end
			end
		end


		for k, v in pairs(maps) do
			List:AddLine(v, 0)
		end
		
		CDpanel = vgui.Create( "DPanel", panel )
		CDpanel:SetPos( 5, 298 )
		CDpanel:SetSize( 175, 18 )
		
		countdown = vgui.Create("DLabel", CDpanel)
		countdown:SetPos(90,2)
		--countdown:SetFont("defaultBold")
		countdown:SetColor(Color(255,20,20,255))
		countdown:SetText("Vote!")
		
		--if #player.GetAll()>2 then tc=150 else tc=30 end
		tc = math.min( ((#player.GetAll() * 250)/40)*2, 90 ) --Maximum of 90 seconds
		--Update time left counter
		if VotedForMap==true and #maps > 0 and panel then
			
			timer.Create("addsecnd", 1, tc, function()
				
				if tc-addsec > 0 then
					addsec = addsec + 1
					countdown:SetText(tostring( math.Round( (tc-addsec) )).."   ")
					
					countdown:SizeToContents()
					votesOverZero = 0
					
					--Find all votes that aren't 0
					for k,v in pairs(votes) do
						if v > 0 then
							votesOverZero = votesOverZero + v
						end
					end
					
					--Update the votes left %
					local VotesNumber = math.Round(math.min( ((votesOverZero / math.ceil(#player.GetAll()*0.3) )*100), 100) )
					--print("VOZ:"..votesOverZero.." 30% of players:"..math.ceil(#player.GetAll()*0.3).." VotesNumber:"..VotesNumber)
					votesleft:SetText( tostring( VotesNumber ) .. "%")
					
					local VecA = Vector(20,255,20)
					local VecB = Vector(255,20,20)
					local Num = VotesNumber / 100
					local X = VecA[1] * Num + VecB[1] * (1-Num)
					local Y = VecA[2] * Num + VecB[2] * (1-Num)
					local Z = VecA[3] * Num + VecB[3] * (1-Num)
					votesleft:SetColor(Color(X,Y,Z))
					
					if tc-addsec <=10 then
						--surface.PlaySound( "/buttons/blip1.wav" )
						local tcc = math.Round(tc-addsec)
						
						if tcc == 9 then surface.PlaySound( "npc/overwatch/radiovoice/nine.wav" ) end
						if tcc == 8 then surface.PlaySound( "npc/overwatch/radiovoice/eight.wav" ) end
						if tcc == 7 then surface.PlaySound( "npc/overwatch/radiovoice/seven.wav" ) end
						if tcc == 6 then surface.PlaySound( "npc/overwatch/radiovoice/six.wav" ) end
						if tcc == 5 then surface.PlaySound( "npc/overwatch/radiovoice/five.wav" ) end
						if tcc == 4 then surface.PlaySound( "npc/overwatch/radiovoice/four.wav" ) end
						if tcc == 3 then surface.PlaySound( "npc/overwatch/radiovoice/three.wav" ) end
						if tcc == 2 then surface.PlaySound( "npc/overwatch/radiovoice/two.wav" ) end
						if tcc == 1 then surface.PlaySound( "npc/overwatch/radiovoice/one.wav" ) end
						if tcc == 0 then surface.PlaySound( "npc/overwatch/radiovoice/zero.wav" ) end
					end
				end
			end) 
		end
		
	elseif panel then
		panel:Close()
		VotedForMap=false
		timer.Destroy("addsecnd")
	end
	
end
net.Receive( "MenuToggle", VoteMenu )

--Toggle the menu and deal with client side voting
local function TLMenu( )
	local datain = net.ReadString()
	local Ar = string.Explode(" ",datain)
	local map = Ar[1]
	local openORclose = Ar[2]
	--print("Map:"..map.." State:"..openORclose)
	if openORclose == "open" then
		
		TLPanel = vgui.Create("DFrame")
		TLPanel:SetSize(180, 100)
		TLPanel:SetTitle("Map change! Save your stuff!")
		TLPanel:SetPos(20, 200)
		TLPanel:ShowCloseButton(false)
		TLPanel:SetDraggable(false)
		TLPanel:SetScreenLock(true)
		
		
		TLMap1 = vgui.Create("DLabel", TLPanel)
		TLMap1:SetPos(20, 30)
		--TLMap1:SetFont("defaultbold")
		TLMap1:SetText("Changing to:")
		TLMap1:SizeToContents()
		
		TLMap = vgui.Create("DLabel", TLPanel)
		TLMap:SetPos(20, 55)
		--TLMap:SetFont("defaultbold")
		TLMap:SetColor(Color(255,20,20,255))
		TLMap:SetText(map .. "   ")
		--TLMap:SetWrap(true)
		TLMap:SizeToContents()
		
		TLMap2 = vgui.Create("DLabel", TLPanel)
		TLMap2:SetPos(20, 75)
		--TLMap2:SetFont("defaultbold")
		TLMap2:SetText("in <time> seconds")
		--TLMap2:SizeToContents()
		timer.Create("TL",1,30,function() SecondsLeft = SecondsLeft - 1, TLMap2:SetText("in " .. SecondsLeft .. " seconds") end)
		TLMap2:SizeToContents()
		
	elseif openORclose == "close" and ForceClose == 0 or ForceClose == 1 then
		if TLPanel then TLPanel:Close() end
		TLPanel = nil
		timer.Stop("TL")

	end
	
end
net.Receive( "TLMenuToggle", TLMenu )

--Tell the user information
local function pnrp_votemap_msg( len, ply )
	local text = net.ReadString()
	if !text then return end
	
	
	ModText = string.Explode("~",text)
	if #ModText>0 then
		OutText = ModText[1]
		OutNum = ModText[2]
		OutText2 = ModText[3]
	else OutText = text end
	
	chat.AddText( White, "[", Green, "PNRP", White, "] ", White, OutText, Red, OutNum, White, OutText2 )

end
net.Receive( "pnrp_msg", pnrp_votemap_msg )

--Reset the CL file. (#1)
local function Reset()
	votes = {}
	maps = {}
	votesOverZero = {}
	VotedNum = 0
	VotedForMap = false
	addsec = 0
	SecondsLeft = 30
	ForceClose = 1
	--VotesDList:Clear()
	if panel then 
		panel:Close()
		panel = nil
	end
	
	timer.Stop("addsecnd")
end
net.Receive( "Reset", Reset )

--Reset the CL file. #2
local function Reset2()
	votes = {}
	maps = {}
	votesOverZero = {}
	VotedNum = 0
	VotedForMap = false
	addsec = 0
	SecondsLeft = 30
	ForceClose = 1
	panel = nil
	
	timer.Stop("addsecnd")
end
net.Receive( "Reset2", Reset2 )



--This is a hacky work around for "FCVAR_SERVER_CAN_EXECUTE prevented server running command:<command>"
--A request for user messages is sent to the player and then the client does the command.
local function Pnrp_votemap() RunConsoleCommand("pnrp_votemap") end
net.Receive( "pnrp_votemap", Pnrp_votemap )
local function Pnrp_forcevotemap() RunConsoleCommand("pnrp_forcevotemap") end
net.Receive( "pnrp_forcevotemap", Pnrp_forcevotemap )
local function Pnrp_cancelvotemap() RunConsoleCommand("pnrp_cancelvotemap") end
net.Receive( "pnrp_cancelvotemap", Pnrp_cancelvotemap )
local function Pnrp_openvotemap() RunConsoleCommand("pnrp_openvotemap") end
net.Receive( "pnrp_openvotemap", Pnrp_openvotemap )
local function Pnrp_closevotemap() RunConsoleCommand("pnrp_closevotemap") end
net.Receive( "pnrp_closevotemap", Pnrp_closevotemap )
--EOF
--(7-5-12)
--(Up:7-6-12)
--(Up:7-7-12)
--(Up:7-8-12)
--(Up:7-9-12)
--(Up:8-13-12)
--(UP:9-9-12)