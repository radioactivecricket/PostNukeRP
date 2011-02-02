--Main Community Derma Menus

local community_frame
local comFrame = false
--Main Community Menu
function GM.community_window(handler, id, encoded, decoded)
--	if community_frame != nil then 
--		community_frame = nil
--		return 
--	end
	if comFrame then return end 
	local communityName = decoded["CommunityName"]
	local communityTable = decoded["communityTable"]		
	local ply = LocalPlayer()
	local communityRank
	local communityUsers = communityTable["users"]
	local communityCount
	local isLocalUser
	comFrame = true
	communityRank = "none"
	communityCount = "none"
	
	if communityName != "none" then
		for i, u in pairs(communityUsers) do
			if ply:UniqueID() == i then
				communityRank = u["rank"]
			end
		end
	end
	community_frame = vgui.Create( "DFrame" )
		community_frame:SetSize( 400, 450 ) 
		community_frame:SetPos(ScrW() / 2 - community_frame:GetWide() / 2, ScrH() / 2 - community_frame:GetTall() / 2)
		community_frame:SetTitle( " " )
		community_frame:SetVisible( true )
		community_frame:SetDraggable( false )
		community_frame:ShowCloseButton( false )
		community_frame:MakePopup()
		community_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local communityLabel_frame = vgui.Create( "DFrame" )
			communityLabel_frame:SetParent( community_frame )
			communityLabel_frame:SetSize( 250, 40 ) 
			communityLabel_frame:SetPos(ScrW() / 2 - community_frame:GetWide() / 2, ScrH() / 2 - community_frame:GetTall() / 2 - 15)
			communityLabel_frame:SetTitle( " " )
			communityLabel_frame:SetVisible( true )
			communityLabel_frame:SetDraggable( false )
			communityLabel_frame:ShowCloseButton( false )
			communityLabel_frame:MakePopup()
			communityLabel_frame.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
		
		local CommunityLabel = vgui.Create("DLabel", communityLabel_frame)
			CommunityLabel:SetPos(10,0)
			CommunityLabel:SetColor( Color( 255, 255, 255, 255 ) )
			CommunityLabel:SetText( "Community Window" )
			CommunityLabel:SetFont("Trebuchet24")
			CommunityLabel:SizeToContents()
			
		
		local community_TabSheet = vgui.Create( "DPropertySheet" )
			community_TabSheet:SetParent( community_frame )
			community_TabSheet:SetPos( 5, 25 )
			community_TabSheet:SetSize( community_frame:GetWide() - 15, community_frame:GetTall() - 55 )
		--//List of Current Members	
			local cMemberPanel = vgui.Create( "DPanel", community_TabSheet )
				cMemberPanel:SetPos( 5, 5 )
				cMemberPanel:SetSize( community_TabSheet:GetWide(), community_TabSheet:GetTall() )
				cMemberPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
			local cMemberList = vgui.Create("DPanelList", cMemberPanel)
				cMemberList:SetPos(5, 5)
				cMemberList:SetSize(cMemberPanel:GetWide() - 10, cMemberPanel:GetTall() - 40)
				cMemberList:EnableVerticalScrollbar(true) 
				cMemberList:EnableHorizontal(false) 
				cMemberList:SetSpacing(1)
				cMemberList:SetPadding(10)
				if communityName != "none" then
					communityCount = table.Count( communityUsers )
					--table.sort(communityUsers, function(a["rank"],b["rank"]) return a["rank"]>b["rank"] end)
					for k, v in pairs( communityUsers ) do		
						
						if ply:UniqueID() == k then
							isLocalUser = true
						else 
							isLocalUser = false
						end
						
						local MemberPanel = vgui.Create("DPanel")
						MemberPanel:SetTall(75)
						MemberPanel.Paint = function()
						
							draw.RoundedBox( 6, 0, 0, MemberPanel:GetWide(), MemberPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
					
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
						
						MemberPanel.LastOn = vgui.Create("DLabel", MemberPanel)
						MemberPanel.LastOn:SetPos(90, 55)
						MemberPanel.LastOn:SetText("Last On: "..v["lastlog"])
						MemberPanel.LastOn:SetColor(Color( 0, 0, 0, 255 ))
						MemberPanel.LastOn:SizeToContents() 
						MemberPanel.LastOn:SetContentAlignment( 5 )
						
						if !isLocalUser then
							
							MemberPanel.PromoteBtn = vgui.Create("DButton", MemberPanel )
							MemberPanel.PromoteBtn:SetPos(255, 5)
							MemberPanel.PromoteBtn:SetSize(75,17)
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
							MemberPanel.DemoteBtn:SetPos(255, 25)
							MemberPanel.DemoteBtn:SetSize(75,17)
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
							MemberPanel.BootBtn:SetPos(255, 45)
							MemberPanel.BootBtn:SetSize(75,17)
							MemberPanel.BootBtn:SetText( "Remove" )
							MemberPanel.BootBtn.DoClick = function() 
								RunConsoleCommand( "pnrp_remcomm", v["name"] )
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
			community_TabSheet:AddSheet( "Community Member List", cMemberPanel, "gui/silkicons/group", false, false, "Community Member List" )
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
							
								draw.RoundedBox( 6, 0, 0, iPlayerPanel:GetWide(), iPlayerPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
						
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
			
				community_TabSheet:AddSheet( "Invite Members", cInvitePanel, "gui/silkicons/add", false, false, "Invite Members" )	
			end
		
		--//Community Main Menu
		local communityMenu_frame = vgui.Create( "DFrame" )
			communityMenu_frame:SetParent( community_frame )
			communityMenu_frame:SetSize( 100, cMemberList:GetTall() ) 
			communityMenu_frame:SetPos( ScrW() / 2 + community_frame:GetWide() / 2 + 5, ScrH() / 2 - community_frame:GetTall() / 2 + 50 )
			communityMenu_frame:SetTitle( " " )
			communityMenu_frame:SetVisible( true )
			communityMenu_frame:SetDraggable( false )
			communityMenu_frame:ShowCloseButton( true )
			communityMenu_frame:MakePopup()
			communityMenu_frame.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
			
			local cMenuList = vgui.Create( "DPanelList", communityMenu_frame )
					cMenuList:SetPos( 0,0 )
					cMenuList:SetSize( communityMenu_frame:GetWide(), communityMenu_frame:GetTall() )
					cMenuList:SetSpacing( 5 )
					cMenuList:SetPadding(3)
					cMenuList:EnableHorizontal( false ) 
					cMenuList:EnableVerticalScrollbar( true ) 	
					
					local BlankLabel1 = vgui.Create("DLabel", cMenuList	)
						BlankLabel1:SetColor( Color( 255, 255, 255, 0 ) )
						BlankLabel1:SetText( " " )
						BlankLabel1:SizeToContents()
						cMenuList:AddItem( BlankLabel1 )
					local createBtn = vgui.Create("DButton") 
						createBtn:SetParent( cMenuList ) 
						createBtn:SetText( "Create" ) 
						createBtn:SetSize( 100, 20 ) 
						if communityName == "none" then 
							createBtn:SetDisabled( false ) 
						else
							createBtn:SetDisabled( true ) 
						end
						createBtn.DoClick = function() PNRP.CreateCommWindow() end	
						cMenuList:AddItem( createBtn )
					local disbandBtn = vgui.Create("DButton") 
						disbandBtn:SetParent( cMenuList ) 
						disbandBtn:SetText( "Disband" ) 
						disbandBtn:SetSize( 100, 20 ) 
						if communityRank == 3 then 
							disbandBtn:SetDisabled( false ) 
						else
							disbandBtn:SetDisabled( true ) 
						end
						disbandBtn.DoClick = function() PNRP.OptionVerify( "pnrp_delcomm", nil, "pnrp_OpenCommunity", community_frame ) end	
						cMenuList:AddItem( disbandBtn )
					local leaveBtn = vgui.Create("DButton") 
						leaveBtn:SetParent( cMenuList ) 
						leaveBtn:SetText( "Leave" ) 
						leaveBtn:SetSize( 100, 20 ) 
						if communityName != "none" then 
							leaveBtn:SetDisabled( false ) 
						else
							leaveBtn:SetDisabled( true ) 
						end
						leaveBtn.DoClick = function() PNRP.OptionVerify( "pnrp_leavecomm", nil, "pnrp_OpenCommunity", community_frame ) end	
						cMenuList:AddItem( leaveBtn )
					local demoteSelfBtn = vgui.Create("DButton") 
						demoteSelfBtn:SetParent( cMenuList ) 
						demoteSelfBtn:SetText( "Demote Self" ) 
						demoteSelfBtn:SetSize( 100, 20 ) 
						if communityName == "none" or tonumber(communityRank) >= 1 then 
							demoteSelfBtn:SetDisabled( false ) 
						else
							demoteSelfBtn:SetDisabled( true ) 
						end
						demoteSelfBtn.DoClick = function() PNRP.OptionVerify( "pnrp_demselfcomm", nil, "pnrp_OpenCommunity", community_frame ) end	
						cMenuList:AddItem( demoteSelfBtn )
					local BlankLabel2 = vgui.Create("DLabel", cMenuList	)
						BlankLabel2:SetColor( Color( 255, 255, 255, 0 ) )
						BlankLabel2:SetText( " " )
						BlankLabel2:SizeToContents()
						cMenuList:AddItem( BlankLabel2 )	
					local devide1menu2 = vgui.Create("DShape") 
						devide1menu2:SetParent( cMenuList ) 
						devide1menu2:SetType("Rect")
						devide1menu2:SetSize( 100, 2 ) 	
						cMenuList:AddItem( devide1menu2 )
					local BlankLabel3 = vgui.Create("DLabel", cMenuList	)
						BlankLabel3:SetColor( Color( 255, 255, 255, 0 ) )
						BlankLabel3:SetText( " " )
						BlankLabel3:SizeToContents()
						cMenuList:AddItem( BlankLabel3 )
					local placeStockBtn = vgui.Create("DButton") 
						placeStockBtn:SetParent( cMenuList ) 
						placeStockBtn:SetText( "Place Stockpile" ) 
						placeStockBtn:SetSize( 100, 20 ) 
						if communityRank == 3 then 
							placeStockBtn:SetDisabled( false ) 
						else
							placeStockBtn:SetDisabled( true ) 
						end
						placeStockBtn.DoClick = function() RunConsoleCommand( "pnrp_placestock" ) community_frame:Close() end	
						cMenuList:AddItem( placeStockBtn )
					local remStockBtn = vgui.Create("DButton") 
						remStockBtn:SetParent( cMenuList ) 
						remStockBtn:SetText( "Remove Stockpile" ) 
						remStockBtn:SetSize( 100, 20 ) 
						if communityRank == 3 then 
							remStockBtn:SetDisabled( false ) 
						else
							remStockBtn:SetDisabled( true ) 
						end
						remStockBtn.DoClick = function() PNRP.OptionVerify( "pnrp_remstock", nil, nil, community_frame ) end	
						cMenuList:AddItem( remStockBtn )	
					local placeLockerBtn = vgui.Create("DButton") 
						placeLockerBtn:SetParent( cMenuList ) 
						placeLockerBtn:SetText( "Place Locker" ) 
						placeLockerBtn:SetSize( 100, 20 ) 
						if communityRank == 3 then 
							placeLockerBtn:SetDisabled( false ) 
						else
							placeLockerBtn:SetDisabled( true ) 
						end
						placeLockerBtn.DoClick = function() RunConsoleCommand( "pnrp_placelocker" ) community_frame:Close() end	
						cMenuList:AddItem( placeLockerBtn )
					local remLockerBtn = vgui.Create("DButton") 
						remLockerBtn:SetParent( cMenuList ) 
						remLockerBtn:SetText( "Remove Locker" ) 
						remLockerBtn:SetSize( 100, 20 ) 
						if communityRank == 3 then 
							remLockerBtn:SetDisabled( false ) 
						else
							remLockerBtn:SetDisabled( true ) 
						end
						remLockerBtn.DoClick = function() PNRP.OptionVerify( "pnrp_remlocker", nil, nil, community_frame ) end	
						cMenuList:AddItem( remLockerBtn )
						
					local BlankLabel4 = vgui.Create("DLabel", cMenuList	)
						BlankLabel4:SetColor( Color( 255, 255, 255, 0 ) )
						BlankLabel4:SetText( " " )
						BlankLabel4:SizeToContents()
						cMenuList:AddItem( BlankLabel4 )	
					local devide1menu3 = vgui.Create("DShape") 
						devide1menu3:SetParent( cMenuList ) 
						devide1menu3:SetType("Rect")
						devide1menu3:SetSize( 100, 2 ) 	
						cMenuList:AddItem( devide1menu3 )
					local BlankLabel5 = vgui.Create("DLabel", cMenuList	)
						BlankLabel5:SetColor( Color( 255, 255, 255, 0 ) )
						BlankLabel5:SetText( " " )
						BlankLabel5:SizeToContents()
						cMenuList:AddItem( BlankLabel5 )	
					local exitBtn = vgui.Create("DButton") 
						exitBtn:SetParent( cMenuList ) 
						exitBtn:SetText( "Exit" ) 
						exitBtn:SetSize( 100, 20 ) 
						exitBtn.DoClick = function() 
							community_frame:Close() 
							community_frame = nil
						end	
						cMenuList:AddItem( exitBtn )
		
		--//Community Status Window
		local communityStatus_frame = vgui.Create( "DFrame" )
			communityStatus_frame:SetParent( community_frame )
			communityStatus_frame:SetSize( 175, cMemberList:GetTall() ) 
			communityStatus_frame:SetPos(ScrW() / 2 + community_frame:GetWide() / 2 + 110, ScrH() / 2 - community_frame:GetTall() / 2 + 50) 
			communityStatus_frame:SetTitle( " " )
			communityStatus_frame:SetVisible( true )
			communityStatus_frame:SetDraggable( false )
			communityStatus_frame:ShowCloseButton( false )
			communityStatus_frame:MakePopup()
			communityStatus_frame.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end	
		
		local communityStatusList = vgui.Create( "DPanelList", communityStatus_frame )
				communityStatusList:SetPos( 0,0 )
				communityStatusList:SetSize( communityStatus_frame:GetWide() - 10, communityStatus_frame:GetTall() )
				communityStatusList:SetSpacing( 5 )
				communityStatusList:EnableHorizontal( false ) 
				communityStatusList:EnableVerticalScrollbar( true ) 	
		
			local UCommunityBlankLabel = vgui.Create("DLabel", communityStatusList)
					UCommunityBlankLabel:SetColor( Color( 255, 255, 255, 0 ) )
					UCommunityBlankLabel:SetText( " " )
					UCommunityBlankLabel:SizeToContents()
					communityStatusList:AddItem( UCommunityBlankLabel )
			
			local UCommunityNameLabel = vgui.Create("DLabel", communityStatusList)
					UCommunityNameLabel:SetColor( Color( 255, 255, 255, 255 ) )
					UCommunityNameLabel:SetText( "  Member of: "..communityName )
					UCommunityNameLabel:SizeToContents()
					communityStatusList:AddItem( UCommunityNameLabel )
			
			local UCommunityRankLabel = vgui.Create("DLabel", communityStatusList)
					UCommunityRankLabel:SetColor( Color( 255, 255, 255, 255 ) )
					UCommunityRankLabel:SetText( "  Rank: Level "..communityRank )
					UCommunityRankLabel:SizeToContents()
					communityStatusList:AddItem( UCommunityRankLabel )
					
			local UCommunityCountLabel = vgui.Create("DLabel", communityStatusList)
					UCommunityCountLabel:SetColor( Color( 255, 255, 255, 255 ) )
					UCommunityCountLabel:SetText( "  Member Count: "..communityCount )
					UCommunityCountLabel:SizeToContents()
					communityStatusList:AddItem( UCommunityCountLabel )	
					
	function community_frame:Close()                  
		comFrame = false                  
		self:SetVisible( false )                  
		self:Remove()          
	end 
end
datastream.Hook( "pnrp_OpenCommunityWindow", GM.community_window )

function GM.initCommunity(ply)
--	if community_frame != nil then 
--		community_frame = nil
--		return 
--	end
	RunConsoleCommand("pnrp_OpenCommunity")

end
concommand.Add( "pnrp_community",  GM.initCommunity )

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
		local CCWtextbox = vgui.Create("TextEntry", CCW_frame)
			CCWtextbox:SetText("Community Name")
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

function RecCInvite( data )
	local PlayerNIC = data:ReadString() 
	local CommunityName = data:ReadString() 
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
usermessage.Hook( "sendinvite", RecCInvite )

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

