--Main Community Derma Menus

local community_frame
local comFrame = false
--Main Community Menu
function GM.community_window( )
	if comFrame then return end 
	local communityName = net.ReadString()
	local communityTable = net.ReadTable()
	local plyPID = net.ReadString()
	local ply = LocalPlayer()
	local communityRank = -1
	local communityUsers = communityTable["users"]
	local communityCount
	local isLocalUser
	comFrame = true
	communityCount = "none"
	
	if communityName != "none" then
		communityCount = 0
		for i, u in pairs(communityUsers) do
			if plyPID == i then
				communityRank = u["rank"]
			end
			communityCount = communityCount + 1
		end
	end
	community_frame = vgui.Create( "DFrame" )
		community_frame:SetSize( 710, 520 ) 
		community_frame:SetPos(ScrW() / 2 - community_frame:GetWide() / 2, ScrH() / 2 - community_frame:GetTall() / 2)
		community_frame:SetTitle( " " )
		community_frame:SetVisible( true )
		community_frame:SetDraggable( false )
		community_frame:ShowCloseButton( true )
		community_frame:MakePopup()
		community_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", community_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_4b.png" )
			screenBG:SetSize(community_frame:GetWide(), community_frame:GetTall())	
		
			
			local UCommunityNameLabel = vgui.Create("DLabel", community_frame)
					UCommunityNameLabel:SetPos(50,40)
					UCommunityNameLabel:SetColor( Color( 255, 255, 255, 255 ) )
					UCommunityNameLabel:SetText( communityName )
					UCommunityNameLabel:SizeToContents()
			
			local UCommunityRankLabel = vgui.Create("DLabel", community_frame)
					UCommunityRankLabel:SetPos(50,55)
					UCommunityRankLabel:SetColor( Color( 255, 255, 255, 255 ) )
					local RankVar = "none"
					if tonumber(communityRank) >= 0 then
						RankVar = communityRank
					end
					UCommunityRankLabel:SetText( "Rank: Level "..communityRank )
					UCommunityRankLabel:SizeToContents()
					
			local UCommunityCountLabel = vgui.Create("DLabel", community_frame)
					UCommunityCountLabel:SetPos(275,55)
					UCommunityCountLabel:SetColor( Color( 255, 255, 255, 255 ) )
					UCommunityCountLabel:SetText( "Member Count: "..communityCount )
					UCommunityCountLabel:SizeToContents()

					
		
		local community_TabSheet = vgui.Create( "DPropertySheet" )
			community_TabSheet:SetParent( community_frame )
			community_TabSheet:SetPos( 40, 70 )
			community_TabSheet:SetSize( community_frame:GetWide() - 350, community_frame:GetTall() - 120 )
			community_TabSheet.Paint = function() -- Paint function
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
		--//List of Current Members	
			local cMemberPanel = vgui.Create( "DPanel", community_TabSheet )
				cMemberPanel:SetPos( 5, 5 )
				cMemberPanel:SetSize( community_TabSheet:GetWide(), community_TabSheet:GetTall() )
				cMemberPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
			local cMemberList = vgui.Create("DPanelList", cMemberPanel)
				cMemberList:SetPos(0, 0)
				cMemberList:SetSize(cMemberPanel:GetWide() - 5, cMemberPanel:GetTall() - 40)
				cMemberList:EnableVerticalScrollbar(true) 
				cMemberList:EnableHorizontal(false) 
				cMemberList:SetSpacing(1)
				cMemberList:SetPadding(10)
				cMemberList.Paint = function()
				--	draw.RoundedBox( 8, 0, 0, cMemberList:GetWide(), cMemberList:GetTall(), Color( 50, 50, 50, 255 ) )
				end
				if communityName != "none" then
					communityCount = table.Count( communityUsers )
					--table.sort(communityUsers, function(a["rank"],b["rank"]) return a["rank"]>b["rank"] end)
					for k, v in pairs( communityUsers ) do		
					
						if plyPID == k then
							isLocalUser = true
						else 
							isLocalUser = false
						end
						
						local MemberPanel = vgui.Create("DPanel")
						MemberPanel:SetTall(75)
						MemberPanel.Paint = function()
						
							draw.RoundedBox( 6, 0, 0, MemberPanel:GetWide(), MemberPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
					
						end
						cMemberList:AddItem(MemberPanel)
						
						MemberPanel.Icon = vgui.Create("SpawnIcon", MemberPanel)
						MemberPanel.Icon:SetModel(v["model"])
						MemberPanel.Icon:SetPos(3, 3)
						MemberPanel.Icon:SetToolTip( nil )
						
						MemberPanel.Title = vgui.Create("DLabel", MemberPanel)
						MemberPanel.Title:SetPos(90, 5)
						MemberPanel.Title:SetText(v["name"])
						MemberPanel.Title:SetColor(Color( 0, 0, 0, 255 ))
						MemberPanel.Title:SizeToContents() 
						MemberPanel.Title:SetContentAlignment( 5 )
						
						MemberPanel.Rank = vgui.Create("DLabel", MemberPanel)
						MemberPanel.Rank:SetPos(90, 25)
						MemberPanel.Rank:SetText("Rank: Level "..v["rank"])
						MemberPanel.Rank:SetColor(Color( 0, 0, 0, 255 ))
						MemberPanel.Rank:SizeToContents() 
						MemberPanel.Rank:SetContentAlignment( 5 )
						
						MemberPanel.Title = vgui.Create("DLabel", MemberPanel)
						MemberPanel.Title:SetPos(90, 40)
						MemberPanel.Title:SetText(v["title"])
						MemberPanel.Title:SetColor(Color( 0, 0, 0, 255 ))
						MemberPanel.Title:SizeToContents() 
						MemberPanel.Title:SetContentAlignment( 5 )
						
						MemberPanel.LastOn = vgui.Create("DLabel", MemberPanel)
						MemberPanel.LastOn:SetPos(90, 55)
						MemberPanel.LastOn:SetText("Last On: "..v["lastlog"])
						MemberPanel.LastOn:SetColor(Color( 0, 0, 0, 255 ))
						MemberPanel.LastOn:SizeToContents() 
						MemberPanel.LastOn:SetContentAlignment( 5 )
						
						MemberPanel.TitleBtn = vgui.Create("DButton", MemberPanel )
						MemberPanel.TitleBtn:SetPos(255, 5)
						MemberPanel.TitleBtn:SetSize(75,15)
						MemberPanel.TitleBtn:SetText( "Set Title" )
						MemberPanel.TitleBtn.DoClick = function() 
							SetTitle(v)
						--	RunConsoleCommand( "pnrp_rankcomm", v["name"], v["rank"] + 1 )
						--	community_frame:Close() 
						--	RunConsoleCommand( "pnrp_OpenCommunity" )
						end
						if tonumber(communityRank) == 3 then 
							MemberPanel.TitleBtn:SetDisabled( false )
						else
							MemberPanel.TitleBtn:SetDisabled( true )
						end
							
						if !isLocalUser then
							
							MemberPanel.PromoteBtn = vgui.Create("DButton", MemberPanel )
							MemberPanel.PromoteBtn:SetPos(255, 20)
							MemberPanel.PromoteBtn:SetSize(75,15)
							MemberPanel.PromoteBtn:SetText( "Promote" )
							MemberPanel.PromoteBtn.DoClick = function() 
								RunConsoleCommand( "pnrp_rankcomm", v["name"], v["rank"] + 1 )
								community_frame:Close() 
								RunConsoleCommand( "pnrp_OpenCommunity" )
							end
							if tonumber(v["rank"]) == 3 then 
								MemberPanel.PromoteBtn:SetDisabled( true )
							else
								MemberPanel.PromoteBtn:SetDisabled( false )
							end
							
							MemberPanel.DemoteBtn = vgui.Create("DButton", MemberPanel )
							MemberPanel.DemoteBtn:SetPos(255, 35)
							MemberPanel.DemoteBtn:SetSize(75,15)
							MemberPanel.DemoteBtn:SetText( "Demote" )
							MemberPanel.DemoteBtn.DoClick = function() 
								RunConsoleCommand( "pnrp_rankcomm", v["name"], v["rank"] - 1 )
								community_frame:Close() 
								RunConsoleCommand( "pnrp_OpenCommunity" )
							end
							if tonumber(v["rank"]) == 1 then 
								MemberPanel.DemoteBtn:SetDisabled( true )
							else
								MemberPanel.DemoteBtn:SetDisabled( false )
							end
							
							MemberPanel.BootBtn = vgui.Create("DButton", MemberPanel )
							MemberPanel.BootBtn:SetPos(255, 50)
							MemberPanel.BootBtn:SetSize(75,17)
							MemberPanel.BootBtn:SetText( "Remove" )
							MemberPanel.BootBtn.DoClick = function() 
								RunConsoleCommand( "pnrp_remcomm", v["pid"] )
								community_frame:Close() 
								RunConsoleCommand( "pnrp_OpenCommunity" )
							end
							--If the User has the correct Rank (Owner = 3)
							if tonumber(communityRank) == 3 then 
								MemberPanel.PromoteBtn:SetDisabled( false )
								MemberPanel.DemoteBtn:SetDisabled( false )		
								MemberPanel.BootBtn:SetDisabled( false )
							else
								MemberPanel.PromoteBtn:SetDisabled( true )
								MemberPanel.DemoteBtn:SetDisabled( true )
								MemberPanel.BootBtn:SetDisabled( true )
							end
						end
					end
				end
			community_TabSheet:AddSheet( "Community Member List", cMemberPanel, "gui/icons/group.png", false, false, "Community Member List" )
			if communityName != "none" and tonumber(communityRank) >= 3 then
				--//Invite Panel
				local cInvitePanel = vgui.Create( "DPanel", community_TabSheet )
					cInvitePanel:SetPos( 5, 5 )
					cInvitePanel:SetSize( community_TabSheet:GetWide(), community_TabSheet:GetTall() )
					cInvitePanel.Paint = function() 
						surface.SetDrawColor( 50, 50, 50, 0 )
					end
				
				local cInviteList = vgui.Create("DPanelList", cInvitePanel)
					cInviteList:SetPos(5, 5)
					cInviteList:SetSize(cInvitePanel:GetWide() - 10, cInvitePanel:GetTall() - 40)
					cInviteList:EnableVerticalScrollbar(true) 
					cInviteList:EnableHorizontal(false) 
					cInviteList:SetSpacing(1)
					cInviteList:SetPadding(10)
					
					for _, iplayer in pairs(player.GetAll()) do
						local getCommunity
						getCommunity = iplayer:GetNWString("community", "N/A")
						if getCommunity == "N/A" then
							local iPlayerPanel = vgui.Create("DPanel")
							iPlayerPanel:SetTall(75)
							iPlayerPanel.Paint = function()
							
								draw.RoundedBox( 6, 0, 0, iPlayerPanel:GetWide(), iPlayerPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
						
							end
							cInviteList:AddItem(iPlayerPanel)
							
							iPlayerPanel.Icon = vgui.Create("SpawnIcon", iPlayerPanel)
							iPlayerPanel.Icon:SetModel(iplayer:GetModel())
							iPlayerPanel.Icon:SetPos(3, 3)
							iPlayerPanel.Icon:SetToolTip( nil )
							
							iPlayerPanel.Title = vgui.Create("DLabel", iPlayerPanel)
							iPlayerPanel.Title:SetPos(90, 5)
							iPlayerPanel.Title:SetText(iplayer:Nick())
							iPlayerPanel.Title:SetColor(Color( 0, 0, 0, 255 ))
							iPlayerPanel.Title:SizeToContents() 
							iPlayerPanel.Title:SetContentAlignment( 5 )
							
							iPlayerPanel.InviteBtn = vgui.Create("DButton", iPlayerPanel )
							iPlayerPanel.InviteBtn:SetPos(255, 5)
							iPlayerPanel.InviteBtn:SetSize(75,17)
							iPlayerPanel.InviteBtn:SetText( "Invite" )
							iPlayerPanel.InviteBtn.DoClick = function() 
								RunConsoleCommand( "pnrp_invcomm", iplayer:Nick() )
								community_frame:Close() 
							--	RunConsoleCommand( "pnrp_OpenCommunity" )
							end
							
						end
					end
			
				community_TabSheet:AddSheet( "Invite Members", cInvitePanel, "gui/icons/add.png", false, false, "Invite Members" )	
			end
		
		--//Community Main Menu
								
					local btnHPos = 50
					local btnHeight = 40
					local lblColor = Color( 245, 218, 210, 180 )
							
					local createBtn = vgui.Create("DImageButton", community_frame)
						createBtn:SetPos( community_frame:GetWide()-260,btnHPos )
						createBtn:SetSize(30,30)
						if communityName == "none" then 
							createBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
							createBtn.DoClick = function() PNRP.CreateCommWindow() end
							createBtn.Paint = function()
								if createBtn:IsDown() then 
									createBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
								else
									createBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
								end
							end
						else
							createBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						end	
					local createBtnLbl = vgui.Create("DLabel", community_frame)
						createBtnLbl:SetPos( community_frame:GetWide()-210,btnHPos+2 )
						createBtnLbl:SetColor( lblColor )
						createBtnLbl:SetText( "Create Community" )
						createBtnLbl:SetFont("Trebuchet24")
						createBtnLbl:SizeToContents()
					
					btnHPos = btnHPos + btnHeight
					local disbandBtn = vgui.Create("DImageButton", community_frame)
						disbandBtn:SetPos( community_frame:GetWide()-260,btnHPos )
						disbandBtn:SetSize(30,30)
						if communityRank == 3 then 
							disbandBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
							disbandBtn.DoClick = function() 
								PNRP.OptionVerify( "pnrp_delcomm", nil, "pnrp_OpenCommunity", community_frame ) 
							end	
							disbandBtn.Paint = function()
								if disbandBtn:IsDown() then 
									disbandBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
								else
									disbandBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
								end
							end
						else
							disbandBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						end
					local disbandBtnLbl = vgui.Create("DLabel", community_frame)
						disbandBtnLbl:SetPos( community_frame:GetWide()-210,btnHPos+2 )
						disbandBtnLbl:SetColor( lblColor )
						disbandBtnLbl:SetText( "Disband Community" )
						disbandBtnLbl:SetFont("Trebuchet24")
						disbandBtnLbl:SizeToContents()	

					btnHPos = btnHPos + btnHeight
					local leaveBtn = vgui.Create("DImageButton", community_frame)
						leaveBtn:SetPos( community_frame:GetWide()-260,btnHPos )
						leaveBtn:SetSize(30,30)
						if communityName != "none" then 
							leaveBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
							leaveBtn.DoClick = function() 
								PNRP.OptionVerify( "pnrp_leavecomm", nil, "pnrp_OpenCommunity", community_frame ) 
							end	
							leaveBtn.Paint = function()
								if leaveBtn:IsDown() then 
									leaveBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
								else
									leaveBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
								end
							end
						else
							leaveBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						end
					local leaveBtnLbl = vgui.Create("DLabel", community_frame)
						leaveBtnLbl:SetPos( community_frame:GetWide()-210,btnHPos+2 )
						leaveBtnLbl:SetColor( lblColor )
						leaveBtnLbl:SetText( "Leave Community" )
						leaveBtnLbl:SetFont("Trebuchet24")
						leaveBtnLbl:SizeToContents()
					
					btnHPos = btnHPos + btnHeight
					local demoteSelfBtn = vgui.Create("DImageButton", community_frame)
						demoteSelfBtn:SetPos( community_frame:GetWide()-260,btnHPos )
						demoteSelfBtn:SetSize(30,30)
						if communityName ~= "none" or tonumber(communityRank) >= 1 then
							demoteSelfBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
							demoteSelfBtn.DoClick = function() 
								PNRP.OptionVerify( "pnrp_demselfcomm", nil, "pnrp_OpenCommunity", community_frame ) 
							end	
							demoteSelfBtn.Paint = function()
								if demoteSelfBtn:IsDown() then 
									demoteSelfBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
								else
									demoteSelfBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
								end
							end
						else
							demoteSelfBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						end
					local demoteSelfBtnLbl = vgui.Create("DLabel", community_frame)
						demoteSelfBtnLbl:SetPos( community_frame:GetWide()-210,btnHPos+2 )
						demoteSelfBtnLbl:SetColor( lblColor )
						demoteSelfBtnLbl:SetText( "Demote Self" )
						demoteSelfBtnLbl:SetFont("Trebuchet24")
						demoteSelfBtnLbl:SizeToContents()
						
					btnHPos = btnHPos + btnHeight --Blank Space
					
					btnHPos = btnHPos + btnHeight
					local placeStockBtn = vgui.Create("DImageButton", community_frame)
						placeStockBtn:SetPos( community_frame:GetWide()-260,btnHPos )
						placeStockBtn:SetSize(30,30)
						if tonumber(communityRank) >= 2 then
							placeStockBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
							placeStockBtn.DoClick = function() 
								RunConsoleCommand( "pnrp_placestock" ) 
								community_frame:Close()
							end	
							placeStockBtn.Paint = function()
								if placeStockBtn:IsDown() then 
									placeStockBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
								else
									placeStockBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
								end
							end
						else
							placeStockBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						end
					local placeStockBtnLbl = vgui.Create("DLabel", community_frame)
						placeStockBtnLbl:SetPos( community_frame:GetWide()-210,btnHPos+2 )
						placeStockBtnLbl:SetColor( lblColor )
						placeStockBtnLbl:SetText( "Place Stockpile" )
						placeStockBtnLbl:SetFont("Trebuchet24")
						placeStockBtnLbl:SizeToContents()
					
					btnHPos = btnHPos + btnHeight
					local remStockBtn = vgui.Create("DImageButton", community_frame)
						remStockBtn:SetPos( community_frame:GetWide()-260,btnHPos )
						remStockBtn:SetSize(30,30)
						if tonumber(communityRank) >= 2 then
							remStockBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
							remStockBtn.DoClick = function() 
								PNRP.OptionVerify( "pnrp_remstock", nil, nil, community_frame )
							end	
							remStockBtn.Paint = function()
								if remStockBtn:IsDown() then 
									remStockBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
								else
									remStockBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
								end
							end
						else
							remStockBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						end
					local remStockBtnLbl = vgui.Create("DLabel", community_frame)
						remStockBtnLbl:SetPos( community_frame:GetWide()-210,btnHPos+2 )
						remStockBtnLbl:SetColor( lblColor )
						remStockBtnLbl:SetText( "Remove Stockpile" )
						remStockBtnLbl:SetFont("Trebuchet24")
						remStockBtnLbl:SizeToContents()
						
					btnHPos = btnHPos + btnHeight
					local placeLockerBtn = vgui.Create("DImageButton", community_frame)
						placeLockerBtn:SetPos( community_frame:GetWide()-260,btnHPos )
						placeLockerBtn:SetSize(30,30)
						if tonumber(communityRank) >= 2 then
							placeLockerBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
							placeLockerBtn.DoClick = function() 
								RunConsoleCommand( "pnrp_placelocker" ) 
								community_frame:Close()
							end	
							placeLockerBtn.Paint = function()
								if placeLockerBtn:IsDown() then 
									placeLockerBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
								else
									placeLockerBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
								end
							end
						else
							placeLockerBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						end
					local placeLockerBtnLbl = vgui.Create("DLabel", community_frame)
						placeLockerBtnLbl:SetPos( community_frame:GetWide()-210,btnHPos+2 )
						placeLockerBtnLbl:SetColor( lblColor )
						placeLockerBtnLbl:SetText( "Place Locker" )
						placeLockerBtnLbl:SetFont("Trebuchet24")
						placeLockerBtnLbl:SizeToContents()
						
					btnHPos = btnHPos + btnHeight
					local remLockerBtn = vgui.Create("DImageButton", community_frame)
						remLockerBtn:SetPos( community_frame:GetWide()-260,btnHPos )
						remLockerBtn:SetSize(30,30)
						if tonumber(communityRank) >= 2 then
							remLockerBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
							remLockerBtn.DoClick = function() 
								PNRP.OptionVerify( "pnrp_remlocker", nil, nil, community_frame )
							end	
							remLockerBtn.Paint = function()
								if remLockerBtn:IsDown() then 
									remLockerBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
								else
									remLockerBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
								end
							end
						else
							remLockerBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						end
					local placeLockerBtnLbl = vgui.Create("DLabel", community_frame)
						placeLockerBtnLbl:SetPos( community_frame:GetWide()-210,btnHPos+2 )
						placeLockerBtnLbl:SetColor( lblColor )
						placeLockerBtnLbl:SetText( "Remove Locker" )
						placeLockerBtnLbl:SetFont("Trebuchet24")
						placeLockerBtnLbl:SizeToContents()
					
					btnHPos = btnHPos + btnHeight --Blank Space
					
					btnHPos = btnHPos + btnHeight
					local comSearchBtn = vgui.Create("DImageButton", community_frame)
						comSearchBtn:SetPos( community_frame:GetWide()-260,btnHPos )
						comSearchBtn:SetSize(30,30)
						comSearchBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
						comSearchBtn.DoClick = function() 
							RunConsoleCommand( "pnrp_communitysearch" ) 
							community_frame:Close()
						end	
						comSearchBtn.Paint = function()
							if comSearchBtn:IsDown() then 
								comSearchBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
							else
								comSearchBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
							end
						end
					local comSearchBtnLbl = vgui.Create("DLabel", community_frame)
						comSearchBtnLbl:SetPos( community_frame:GetWide()-210,btnHPos+2 )
						comSearchBtnLbl:SetColor( lblColor )
						comSearchBtnLbl:SetText( "Search Communities" )
						comSearchBtnLbl:SetFont("Trebuchet24")
						comSearchBtnLbl:SizeToContents()
						
				--	if ply:IsAdmin() then
				--		btnHPos = btnHPos + btnHeight
				--		local comAdminBtn = vgui.Create("DImageButton", community_frame)
				--			comAdminBtn:SetPos( community_frame:GetWide()-260,btnHPos )
				--			comAdminBtn:SetSize(30,30)
				--			comAdminBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				--			comAdminBtn.DoClick = function() 
				--				RunConsoleCommand( "pnrp_communityAdmin" ) 
				--				community_frame:Close()
				--			end	
				--			comAdminBtn.Paint = function()
				--				if comAdminBtn:IsDown() then 
				--					comAdminBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				--				else
				--					comAdminBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				--				end
				--			end
				--		local comAdminBtnLbl = vgui.Create("DLabel", community_frame)
				--			comAdminBtnLbl:SetPos( community_frame:GetWide()-210,btnHPos+2 )
				--			comAdminBtnLbl:SetColor( lblColor )
				--			comAdminBtnLbl:SetText( "Communities Admin" )
				--			comAdminBtnLbl:SetFont("Trebuchet24")
				--			comAdminBtnLbl:SizeToContents()
				--	end
					
	function community_frame:Close()                  
		comFrame = false                  
		self:SetVisible( false )                  
		self:Remove()          
	end 
end
--datastream.Hook( "pnrp_OpenCommunityWindow", GM.community_window )
net.Receive( "pnrp_OpenCommunityWindow", GM.community_window )

function GM.initCommunity(ply)
--	if community_frame != nil then 
--		community_frame = nil
--		return 
--	end
	RunConsoleCommand("pnrp_OpenCommunity")

end
concommand.Add( "pnrp_community",  GM.initCommunity )

function SetTitle(person)
	local CTW_frame = vgui.Create( "DFrame" )
		CTW_frame:SetSize( 250, 115 )
		CTW_frame:SetPos(ScrW() / 2 - CTW_frame:GetWide() / 2, ScrH() / 2 - CTW_frame:GetTall() / 2) 
		CTW_frame:SetTitle( "Set Title." ) 
		CTW_frame:SetVisible( true )
		CTW_frame:SetDraggable( true )
		CTW_frame:ShowCloseButton( true )
		CTW_frame:MakePopup()
		
		local CTWtextbox = vgui.Create("DTextEntry", CTW_frame)
			CTWtextbox:SetText("Community Name")
			CTWtextbox:SetText("")
			CTWtextbox:SetMultiline(false)
			CTWtextbox:SetSize(CTW_frame:GetWide() - 20, 20) 
			CTWtextbox:SetPos(CTW_frame:GetWide() / 2 - CTWtextbox:GetWide() / 2, 50)
		local CTWBtn = vgui.Create("DButton") 
			CTWBtn:SetParent( CTW_frame )
			CTWBtn:SetText( "Set Title" ) 
			CTWBtn:SetSize( 100, 20 ) 
			CTWBtn:SetPos(CTW_frame:GetWide() / 2 - CTWBtn:GetWide() / 2, 80)
			CTWBtn.DoClick = function() 
				RunConsoleCommand( "pnrp_setTitle", person["pid"], CTWtextbox:GetValue() )
				CTW_frame:Close()
				community_frame:Close()
				RunConsoleCommand( "pnrp_OpenCommunity" )
			end
end

function PNRP.CreateCommWindow()

	local CCW_frame = vgui.Create( "DFrame" )
			CCW_frame:SetSize( 250, 115 )
			CCW_frame:SetPos(ScrW() / 2 - CCW_frame:GetWide() / 2, ScrH() / 2 - CCW_frame:GetTall() / 2) 
			CCW_frame:SetTitle( "Create a new Community." ) 
			CCW_frame:SetVisible( true )
			CCW_frame:SetDraggable( true )
			CCW_frame:ShowCloseButton( true )
			CCW_frame:MakePopup()
		local CCWLabel = vgui.Create("DLabel", CCW_frame)
			CCWLabel:SetColor( Color( 0, 0, 0, 255 ) )
			CCWLabel:SetText( "Enter the name of your new Community." )
			CCWLabel:SizeToContents()
			CCWLabel:SetPos(CCW_frame:GetWide() / 2 - CCWLabel:GetWide() / 2, 30)
		local CCWtextbox = vgui.Create("DTextEntry", CCW_frame)
			CCWtextbox:SetText("Community Name")
			CCWtextbox:SetText("")
			CCWtextbox:SetMultiline(false)
			CCWtextbox:SetSize(CCW_frame:GetWide() - 20, 20) 
			CCWtextbox:SetPos(CCW_frame:GetWide() / 2 - CCWtextbox:GetWide() / 2, 50)
		local CCWBtn = vgui.Create("DButton") 
			CCWBtn:SetParent( CCW_frame )
			CCWBtn:SetText( "Create Community" ) 
			CCWBtn:SetSize( 100, 20 ) 
			CCWBtn:SetPos(CCW_frame:GetWide() / 2 - CCWBtn:GetWide() / 2, 80)
			CCWBtn.DoClick = function() 
				RunConsoleCommand( "pnrp_newcomm", CCWtextbox:GetValue() )
				CCW_frame:Close()
				community_frame:Close()
				RunConsoleCommand( "pnrp_OpenCommunity" )
			end
end

function RecCInvite( )
	local PlayerNIC = net:ReadString() 
--	local CommunityID = net:ReadString() 
	local CommunityName = net:ReadString() 
	local ply = LocalPlayer()
	
	local inv_frame = vgui.Create( "DFrame" )
			inv_frame:SetSize( 300, 85 ) 
			inv_frame:SetPos(ScrW() / 2 - inv_frame:GetWide() / 2, ScrH() / 2 - inv_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
			inv_frame:SetTitle( "Do you want to Join?" )
			inv_frame:SetVisible( true )
			inv_frame:SetDraggable( true )
			inv_frame:ShowCloseButton( false )
			inv_frame:MakePopup()
			
		local invLabel = vgui.Create("DLabel", inv_frame)
			invLabel:SetColor( Color( 0, 0, 0, 255 ) )
			invLabel:SetText( PlayerNIC.." has invited you to "..CommunityName )
			invLabel:SizeToContents()
			invLabel:SetPos(inv_frame:GetWide() / 2 - invLabel:GetWide() / 2, 30)
			
			local inv_yes = vgui.Create("DButton") 
				inv_yes:SetParent( inv_frame ) 
				inv_yes:SetText( "Accept" ) 
				inv_yes:SetPos(inv_frame:GetWide() / 2 - 85, 50) 
				inv_yes:SetSize( 75, 20 ) 
				inv_yes.DoClick = function()  
					RunConsoleCommand( "pnrp_accinvite" )
					inv_frame:Close()
				end 
			
			local inv_no = vgui.Create("DButton") 
				inv_no:SetParent( inv_frame )
				inv_no:SetText( "Decline" )
				inv_no:SetPos(inv_frame:GetWide() / 2 + 35, 50)
				inv_no:SetSize( 75, 20 ) 
				inv_no.DoClick = function() 
					RunConsoleCommand( "pnrp_denyinvite" )
					inv_frame:Close() 
				end
end
net.Receive( "sendinvite", RecCInvite )

function PNRP.OptionVerify(Command, Option, returnToMenu, frame)
	local ply = LocalPlayer()
		
	local opv_frame = vgui.Create( "DFrame" )
			opv_frame:SetSize( 200, 85 ) 
			opv_frame:SetPos(ScrW() / 2 - opv_frame:GetWide() / 2, ScrH() / 2 - opv_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
			opv_frame:SetTitle( "Verify" )
			opv_frame:SetVisible( true )
			opv_frame:SetDraggable( true )
			opv_frame:ShowCloseButton( false )
			opv_frame:MakePopup()
			
		local opvLabel = vgui.Create("DLabel", opv_frame)
			opvLabel:SetColor( Color( 0, 0, 0, 255 ) )
			opvLabel:SetText( "Are you sure you want to do this?" )
			opvLabel:SizeToContents()
			opvLabel:SetPos(opv_frame:GetWide() / 2 - opvLabel:GetWide() / 2, 30)
			
			local opv_yes = vgui.Create("DButton") 
				opv_yes:SetParent( opv_frame ) 
				opv_yes:SetText( "Yes" ) 
				opv_yes:SetPos(opv_frame:GetWide() / 2 - 60, 50) 
				opv_yes:SetSize( 50, 20 ) 
				opv_yes.DoClick = function() 
					if Option != nil then
					--	ply:ChatPrint(Option)
						RunConsoleCommand( Command, Option )
					else
						RunConsoleCommand( Command )
					end
					opv_frame:Close() 
					if frame != nil then
						frame:Close()
						frame = nil
					end
					if returnToMenu != nil then
						RunConsoleCommand( returnToMenu )
					end
				end 
			
			local opv_no = vgui.Create("DButton") 
				opv_no:SetParent( opv_frame )
				opv_no:SetText( "No" )
				opv_no:SetPos(opv_frame:GetWide() / 2 + 10, 50)
				opv_no:SetSize( 50, 20 ) 
				opv_no.DoClick = function() 
					opv_frame:Close() 
					if returnToMenu != nil then
						RunConsoleCommand( returnToMenu )
					end
					if frame != nil then
						frame:Close()
						frame = nil
					end
				end
					
	
end

local commSearch_Frame
local comSFrame = false
local CommSearchBody_Frame
local commSearchPanel
function GM.commSearchWindow()
	if comSFrame then return end
	local ply = LocalPlayer()
	comSFrame = true
	
	commSearch_Frame = vgui.Create( "DFrame" )
		commSearch_Frame:SetSize( 575, 265 ) 
		commSearch_Frame:SetPos(ScrW() / 2 - commSearch_Frame:GetWide() / 2, ScrH() / 2 - commSearch_Frame:GetTall() / 2)
		commSearch_Frame:SetTitle( " " )
		commSearch_Frame:SetVisible( true )
		commSearch_Frame:SetDraggable( false )
		commSearch_Frame:ShowCloseButton( true )
		commSearch_Frame:MakePopup()
		commSearch_Frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", commSearch_Frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_6b.png" )
			screenBG:SetSize(commSearch_Frame:GetWide(), commSearch_Frame:GetTall())	
		
		--Creates the body to keep it from beeing nil
		CommSearchBody_Frame = vgui.Create( "DPanel", commSearch_Frame )
			CommSearchBody_Frame:SetPos( 30, 33 ) -- Set the position of the panel
			CommSearchBody_Frame:SetSize( commSearch_Frame:GetWide() - 250, commSearch_Frame:GetTall() - 40)
			CommSearchBody_Frame.Paint = function() 
			--	surface.SetDrawColor( 50, 50, 50, 0 )
			end
		
		--Search Bar
		commSearchPanel = vgui.Create( "DPanel", commSearch_Frame )
			commSearchPanel:SetPos( 370, 35 ) -- Set the position of the panel
			commSearchPanel:SetSize( 155, 100 )
			commSearchPanel.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
		local DLabel = vgui.Create( "DLabel", commSearchPanel )
			DLabel:SetPos( 5, 5 )
			DLabel:SetText( "Community Search" )
			DLabel:SizeToContents()
		local sCommNameTxt = vgui.Create("DTextEntry", commSearchPanel)
			sCommNameTxt:SetText("")
			sCommNameTxt:SetPos(5,25)
			sCommNameTxt:SetWide(150)
			sCommNameTxt.OnEnter = function()
				CommSearchBody_Frame:Remove()
				net.Start("SND_CommSearch")
					net.WriteEntity(ply)
					net.WriteString(sCommNameTxt:GetValue())
				net.SendToServer()
			end
		local DButton = vgui.Create( "DButton", commSearchPanel )
			 DButton:SetPos( 5, 55 )
			 DButton:SetText( "Search" )
			 DButton:SetSize( 150, 20 )
			 DButton.DoClick = function()
				CommSearchBody_Frame:Remove()
				net.Start("SND_CommSearch")
					net.WriteEntity(ply)
					net.WriteString(sCommNameTxt:GetValue())
				net.SendToServer()
			 end
			
	function commSearch_Frame:Close()                  
		comSFrame = false                  
		self:SetVisible( false )                  
		self:Remove()          
	end 
end
concommand.Add( "pnrp_communitysearch",  GM.commSearchWindow )

function sCommDispResults()
	local result = net.ReadTable()
	
	CommSearchBody_Frame = vgui.Create( "DPanel", commSearch_Frame )
		CommSearchBody_Frame:SetPos( 25, 40 ) -- Set the position of the panel
		CommSearchBody_Frame:SetSize( commSearch_Frame:GetWide() - 260, commSearch_Frame:GetTall() - 40)
		CommSearchBody_Frame.Paint = function() 
		--	surface.SetDrawColor( 50, 50, 50, 0 )
		end
	local cCommList = vgui.Create("DPanelList", CommSearchBody_Frame)
		cCommList:SetPos(0, 0)
		cCommList:SetSize(CommSearchBody_Frame:GetWide() - 5, CommSearchBody_Frame:GetTall() - 40)
		cCommList:EnableVerticalScrollbar(true) 
		cCommList:EnableHorizontal(false) 
		cCommList:SetSpacing(1)
		cCommList:SetPadding(10)
		cCommList.Paint = function()
		--	draw.RoundedBox( 8, 0, 0, cMemberList:GetWide(), cMemberList:GetTall(), Color( 50, 50, 50, 255 ) )
		end
		
		for k, v in pairs(result) do
			local CommPanel = vgui.Create("DPanel")
				CommPanel:SetTall(25)
				CommPanel.Paint = function()
					draw.RoundedBox( 6, 0, 0, CommPanel:GetWide(), CommPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
				end
				cCommList:AddItem(CommPanel)
				
				CommPanel.Title = vgui.Create("DLabel", CommPanel)
				CommPanel.Title:SetPos(10, 5)
				CommPanel.Title:SetText(tostring(v["cname"]))
				CommPanel.Title:SetColor(Color( 0, 255, 0, 255 ))
				CommPanel.Title:SizeToContents() 
				CommPanel.Title:SetContentAlignment( 5 )
				
				if ply:IsAdmin() then
					local ADMButton = vgui.Create( "DButton", CommPanel )
						ADMButton:SetPos( 175, 3 )
						ADMButton:SetText( "ADM Edit" )
						ADMButton:SetSize( 50, 20 )
						ADMButton.DoClick = function()
							commSearch_Frame:Close()
							RunConsoleCommand( "pnrp_AdmEditCom", v["cid"] )
						end
				end
				
				local DButton = vgui.Create( "DButton", CommPanel )
					DButton:SetPos( 225 , 3 )
					DButton:SetText( "Select" )
					DButton:SetSize( 50, 20 )
					DButton.DoClick = function()
						CommSearchBody_Frame:Remove()

						net.Start("SND_CommSelID")
							net.WriteEntity(ply)
							net.WriteString(v["cid"])
						net.SendToServer()
					end
		end
end
net.Receive("C_SND_CommSearchResults", sCommDispResults)

function sCommDispComm()
	local result = net.ReadTable()

	CommSearchBody_Frame = vgui.Create( "DPanel", commSearch_Frame )
		CommSearchBody_Frame:SetPos( 25, 35 ) -- Set the position of the panel
		CommSearchBody_Frame:SetSize( commSearch_Frame:GetWide() - 270, commSearch_Frame:GetTall() - 30)
		CommSearchBody_Frame.Paint = function() 
		--	surface.SetDrawColor( 50, 50, 50, 0 )
		end
	
		local CommRPanel = vgui.Create("DPanel", CommSearchBody_Frame)
			CommRPanel:SetPos( 0, 0 )
			CommRPanel:SetSize(CommSearchBody_Frame:GetWide() - 5, CommSearchBody_Frame:GetTall() - 40)
			CommRPanel.Paint = function()
			--	draw.RoundedBox( 6, 0, 0, CommRPanel:GetWide(), CommRPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
			end
			
			local CommName = vgui.Create("DLabel", CommRPanel)
				CommName:SetPos(10, 5)
				CommName:SetText("Community: "..tostring(result["name"]))
				CommName:SetColor(Color( 0, 255, 0, 255 ))
				CommName:SizeToContents() 
				CommName:SetContentAlignment( 5 )
			local CommCDate = vgui.Create("DLabel", CommRPanel)
				CommCDate:SetPos(10, 20)
				CommCDate:SetText("Founded: "..tostring(result["founded"]))
				CommCDate:SetColor(Color( 0, 255, 0, 255 ))
				CommCDate:SizeToContents() 
				CommCDate:SetContentAlignment( 5 )
			local CommMCount = vgui.Create("DLabel", CommRPanel)
				CommMCount:SetPos(200, 20)
				CommMCount:SetText("Members: "..tostring(table.Count(result["users"])))
				CommMCount:SetColor(Color( 0, 255, 0, 255 ))
				CommMCount:SizeToContents() 
				CommMCount:SetContentAlignment( 5 )
				
			local cMemList = vgui.Create("DPanelList", CommRPanel)
				cMemList:SetPos(5, 40)
				cMemList:SetSize(CommRPanel:GetWide() - 5, CommRPanel:GetTall() - 40)
				cMemList:EnableVerticalScrollbar(true) 
				cMemList:EnableHorizontal(false) 
				cMemList:SetSpacing(1)
				cMemList:SetPadding(10)
				cMemList.Paint = function()
				--	draw.RoundedBox( 8, 0, 0, cMemList:GetWide(), cMemList:GetTall(), Color( 50, 50, 50, 255 ) )
				end
				for k, v in pairs(result["users"]) do
					local memPanel = vgui.Create("DPanel")
						memPanel:SetTall(40)
						memPanel.Paint = function()
							draw.RoundedBox( 6, 0, 0, memPanel:GetWide(), memPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
						end
						cMemList:AddItem(memPanel)
						
						memPanel.Icon = vgui.Create("SpawnIcon", memPanel)
						memPanel.Icon:SetSize( 38, 38 )
						memPanel.Icon:SetModel(v["model"])
						memPanel.Icon:SetPos(10, 1)
						memPanel.Icon:SetToolTip( nil )
						
						memPanel.Rank = vgui.Create("DLabel", memPanel)
						memPanel.Rank:SetPos(50, 5)
						memPanel.Rank:SetText("Rank: "..tostring(v["rank"]))
						memPanel.Rank:SetColor(Color( 0, 255, 0, 255 ))
						memPanel.Rank:SizeToContents() 
						memPanel.Rank:SetContentAlignment( 5 )
						
						memPanel.Name = vgui.Create("DLabel", memPanel)
						memPanel.Name:SetPos(100, 5)
						memPanel.Name:SetText("Name: "..tostring(v["name"]))
						memPanel.Name:SetColor(Color( 0, 255, 0, 255 ))
						memPanel.Name:SizeToContents() 
						memPanel.Name:SetContentAlignment( 5 )
						
						memPanel.Title = vgui.Create("DLabel", memPanel)
						memPanel.Title:SetPos(100, 20)
						memPanel.Title:SetText("Title: "..tostring(v["title"]))
						memPanel.Title:SetColor(Color( 0, 255, 0, 255 ))
						memPanel.Title:SizeToContents() 
						memPanel.Title:SetContentAlignment( 5 )
				end		
end
net.Receive("C_SND_CommSelResult", sCommDispComm)
