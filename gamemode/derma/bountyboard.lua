
local bbFrame = false
local bounty_Frame

function GM.bountyBoardMenu()
	if bbFrame then return end
	bbFrame = true
	
	local ply = LocalPlayer()
	local bountyTable = net.ReadTable()
	local bountyPostedTable = net.ReadTable()
	local bountyCompTable = net.ReadTable()
	local bountyTakenTable = net.ReadTable()
	
	bounty_Frame = vgui.Create( "DFrame" )
		bounty_Frame:SetSize( 710, 520 ) 
		bounty_Frame:SetPos(ScrW() / 2 - bounty_Frame:GetWide() / 2, ScrH() / 2 - bounty_Frame:GetTall() / 2)
		bounty_Frame:SetTitle( " " )
		bounty_Frame:SetVisible( true )
		bounty_Frame:SetDraggable( false )
		bounty_Frame:ShowCloseButton( true )
		bounty_Frame:MakePopup()
		bounty_Frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end	
		
		local screenBG = vgui.Create("DImage", bounty_Frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_4b.png" )
			screenBG:SetSize(bounty_Frame:GetWide(), bounty_Frame:GetTall())	
		
		local openBountySheet
		local bounty_TabSheet = vgui.Create( "DPropertySheet" )
			bounty_TabSheet:SetParent( bounty_Frame )
			bounty_TabSheet:SetPos( 40, 40 )
			bounty_TabSheet:SetSize( bounty_Frame:GetWide() - 340, bounty_Frame:GetTall() - 90 )
			bounty_TabSheet.Paint = function() -- Paint function
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
		--//Open Bounties
			
			local openBountiesPanel = vgui.Create( "DPanel", bounty_TabSheet )
				openBountiesPanel:SetPos( 5, 5 )
				openBountiesPanel:SetSize( bounty_TabSheet:GetWide(), bounty_TabSheet:GetTall() )
				openBountiesPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
				
				local oBountyList = vgui.Create("DPanelList", openBountiesPanel)
					oBountyList:SetPos(0, 0)
					oBountyList:SetSize(openBountiesPanel:GetWide() - 15, openBountiesPanel:GetTall() - 40)
					oBountyList:EnableVerticalScrollbar(true) 
					oBountyList:EnableHorizontal(false) 
					oBountyList:SetSpacing(1)
					oBountyList:SetPadding(10)
					oBountyList.Paint = function()
					--	draw.RoundedBox( 8, 0, 0, cMemberList:GetWide(), cMemberList:GetTall(), Color( 50, 50, 50, 255 ) )
					end
				--	ply:ChatPrint(table.ToString(bountyTable))
					for k, v in pairs( bountyTable ) do
						
						local obColor = Color( 180, 180, 180, 80 )
						local hTbl = string.Explode(",", tostring(v["hitmen_pid"]))
						for _, hpid in pairs(hTbl) do
							if tostring(v["player_pid"]) == tostring(hpid) then
								obColor = Color( 200, 200, 120, 80 )
							end
						end
						if tostring(v["player_pid"]) == tostring(v["poster_pid"]) then
							obColor = Color( 160, 160, 200, 80 )
						end
						
						local oBountyPanel = vgui.Create("DPanel")
						oBountyPanel:SetTall(75)
						oBountyPanel.Paint = function()
							draw.RoundedBox( 6, 0, 0, oBountyPanel:GetWide(), oBountyPanel:GetTall(), obColor )		
						end
						oBountyList:AddItem(oBountyPanel)
						
						oBountyPanel.Icon = vgui.Create("SpawnIcon", oBountyPanel)
						oBountyPanel.Icon:SetModel(v["model"])
						oBountyPanel.Icon:SetPos(3, 3)
						oBountyPanel.Icon:SetToolTip( nil )
						oBountyPanel.Icon.DoClick = function() 
							viewBounty(v, "open") 
							bounty_Frame:Close()
						end
						
						oBountyPanel.Name = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Name:SetPos(90, 5)
						oBountyPanel.Name:SetText("Target: "..v["name"])
						oBountyPanel.Name:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Name:SizeToContents() 
						oBountyPanel.Name:SetContentAlignment( 5 )
						
						oBountyPanel.Class = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Class:SetPos(90, 15)
						oBountyPanel.Class:SetText(team.GetName(tonumber(v["class"])))
						oBountyPanel.Class:SetColor(team.GetColor(tonumber(v["class"])))
						oBountyPanel.Class:SizeToContents() 
						oBountyPanel.Class:SetContentAlignment( 5 )
						
						oBountyPanel.Community = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Community:SetPos(90, 27)
						oBountyPanel.Community:SetText("Member of: "..v["community"])
						oBountyPanel.Community:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Community:SizeToContents() 
						oBountyPanel.Community:SetContentAlignment( 5 )
						
						oBountyPanel.Reward = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Reward:SetPos(90, 40)
						oBountyPanel.Reward:SetText("Reward: "..v["payment"])
						oBountyPanel.Reward:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Reward:SizeToContents() 
						oBountyPanel.Reward:SetContentAlignment( 5 )
						
						local postDate = os.date("%x %X", v["date"])
						oBountyPanel.Date = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Date:SetPos(90, 55)
						oBountyPanel.Date:SetText("Posted on: "..postDate)
						oBountyPanel.Date:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Date:SizeToContents() 
						oBountyPanel.Date:SetContentAlignment( 5 )
					end
					
			openBountySheet = bounty_TabSheet:AddSheet( "Open Bounties", openBountiesPanel, "gui/icons/group.png", false, false, "Open Bounties" )
		
		--//Bounties Taken
			local takenBountiesPanel = vgui.Create( "DPanel", bounty_TabSheet )
				takenBountiesPanel:SetPos( 5, 5 )
				takenBountiesPanel:SetSize( bounty_TabSheet:GetWide(), bounty_TabSheet:GetTall() )
				takenBountiesPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
				
				local oBountyList = vgui.Create("DPanelList", takenBountiesPanel)
					oBountyList:SetPos(0, 0)
					oBountyList:SetSize(takenBountiesPanel:GetWide() - 15, takenBountiesPanel:GetTall() - 40)
					oBountyList:EnableVerticalScrollbar(true) 
					oBountyList:EnableHorizontal(false) 
					oBountyList:SetSpacing(1)
					oBountyList:SetPadding(10)
					oBountyList.Paint = function()
					--	draw.RoundedBox( 8, 0, 0, cMemberList:GetWide(), cMemberList:GetTall(), Color( 50, 50, 50, 255 ) )
					end
					for k, v in pairs( bountyTakenTable ) do
						local oBountyPanel = vgui.Create("DPanel")
						oBountyPanel:SetTall(75)
						oBountyPanel.Paint = function()
							draw.RoundedBox( 6, 0, 0, oBountyPanel:GetWide(), oBountyPanel:GetTall(), Color( 200, 200, 120, 80 ) )		
						end
						oBountyList:AddItem(oBountyPanel)
						
						oBountyPanel.Icon = vgui.Create("SpawnIcon", oBountyPanel)
						oBountyPanel.Icon:SetModel(v["model"])
						oBountyPanel.Icon:SetPos(3, 3)
						oBountyPanel.Icon:SetToolTip( nil )
						oBountyPanel.Icon.DoClick = function() 
							viewBounty(v, "view") 
							bounty_Frame:Close()
						end
						
						oBountyPanel.Name = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Name:SetPos(90, 5)
						oBountyPanel.Name:SetText("Target: "..v["name"])
						oBountyPanel.Name:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Name:SizeToContents() 
						oBountyPanel.Name:SetContentAlignment( 5 )
						
						oBountyPanel.Class = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Class:SetPos(90, 15)
						oBountyPanel.Class:SetText(team.GetName(tonumber(v["class"])))
						oBountyPanel.Class:SetColor(team.GetColor(tonumber(v["class"])))
						oBountyPanel.Class:SizeToContents() 
						oBountyPanel.Class:SetContentAlignment( 5 )
						
						oBountyPanel.Community = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Community:SetPos(90, 27)
						oBountyPanel.Community:SetText("Member of: "..v["community"])
						oBountyPanel.Community:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Community:SizeToContents() 
						oBountyPanel.Community:SetContentAlignment( 5 )
						
						oBountyPanel.Reward = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Reward:SetPos(90, 40)
						oBountyPanel.Reward:SetText("Reward: "..v["payment"])
						oBountyPanel.Reward:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Reward:SizeToContents() 
						oBountyPanel.Reward:SetContentAlignment( 5 )
						
						local postDate = os.date("%x %X", v["date"])
						oBountyPanel.Date = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Date:SetPos(90, 55)
						oBountyPanel.Date:SetText("Posted on: "..postDate)
						oBountyPanel.Date:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Date:SizeToContents() 
						oBountyPanel.Date:SetContentAlignment( 5 )
					end
					
			openBountySheet = bounty_TabSheet:AddSheet( "Bounties Taken", takenBountiesPanel, "gui/icons/group.png", false, false, "Bounties Taken" )
		
		--//Bounties Posted
			local postedBountiesPanel = vgui.Create( "DPanel", bounty_TabSheet )
				postedBountiesPanel:SetPos( 5, 5 )
				postedBountiesPanel:SetSize( bounty_TabSheet:GetWide(), bounty_TabSheet:GetTall() )
				postedBountiesPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
				
				local oBountyList = vgui.Create("DPanelList", postedBountiesPanel)
					oBountyList:SetPos(0, 0)
					oBountyList:SetSize(postedBountiesPanel:GetWide() - 15, postedBountiesPanel:GetTall() - 40)
					oBountyList:EnableVerticalScrollbar(true) 
					oBountyList:EnableHorizontal(false) 
					oBountyList:SetSpacing(1)
					oBountyList:SetPadding(10)
					oBountyList.Paint = function()
					--	draw.RoundedBox( 8, 0, 0, cMemberList:GetWide(), cMemberList:GetTall(), Color( 50, 50, 50, 255 ) )
					end
					for k, v in pairs( bountyPostedTable ) do
						local completed = v["completed"]
						local status = "Open"
						local compColor = Color( 160, 160, 200, 80 )
						if completed == "true" then
							status = "Completed"
							compColor = Color( 180, 200, 180, 80 )
						elseif completed == "expired" then
							status = "Expired"
							compColor = Color( 200, 180, 180, 80 )
						end
						local oBountyPanel = vgui.Create("DPanel")
						oBountyPanel:SetTall(75)
						oBountyPanel.Paint = function()
							draw.RoundedBox( 6, 0, 0, oBountyPanel:GetWide(), oBountyPanel:GetTall(), compColor )		
						end
						oBountyList:AddItem(oBountyPanel)
						
						oBountyPanel.Icon = vgui.Create("SpawnIcon", oBountyPanel)
						oBountyPanel.Icon:SetModel(v["model"])
						oBountyPanel.Icon:SetPos(3, 3)
						oBountyPanel.Icon:SetToolTip( nil )
						oBountyPanel.Icon.DoClick = function() 
							viewBounty(v, "full") 
							bounty_Frame:Close()
						end
						
						oBountyPanel.Name = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Name:SetPos(90, 5)
						oBountyPanel.Name:SetText("Target: "..v["name"])
						oBountyPanel.Name:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Name:SizeToContents() 
						oBountyPanel.Name:SetContentAlignment( 5 )
						
						oBountyPanel.Status = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Status:SetPos(225, 15)
						oBountyPanel.Status:SetText("Status: "..status)
						oBountyPanel.Status:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Status:SizeToContents() 
						oBountyPanel.Status:SetContentAlignment( 5 )
						
						oBountyPanel.Class = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Class:SetPos(90, 15)
						oBountyPanel.Class:SetText(team.GetName(tonumber(v["class"])))
						oBountyPanel.Class:SetColor(team.GetColor(tonumber(v["class"])))
						oBountyPanel.Class:SizeToContents() 
						oBountyPanel.Class:SetContentAlignment( 5 )
						
						oBountyPanel.Community = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Community:SetPos(90, 27)
						oBountyPanel.Community:SetText("Member of: "..v["community"])
						oBountyPanel.Community:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Community:SizeToContents() 
						oBountyPanel.Community:SetContentAlignment( 5 )
						
						oBountyPanel.Reward = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Reward:SetPos(90, 40)
						oBountyPanel.Reward:SetText("Reward: "..v["payment"])
						oBountyPanel.Reward:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Reward:SizeToContents() 
						oBountyPanel.Reward:SetContentAlignment( 5 )
						
						local postDate = os.date("%x %X", v["date"])
						oBountyPanel.Date = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Date:SetPos(90, 55)
						oBountyPanel.Date:SetText("Posted on: "..postDate)
						oBountyPanel.Date:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Date:SizeToContents() 
						oBountyPanel.Date:SetContentAlignment( 5 )
						
						
					end
					
			openBountySheet = bounty_TabSheet:AddSheet( "Posted", postedBountiesPanel, "gui/icons/group.png", false, false, "Bounties Posted" )
		
		--//Bounties Completed 
			local CompBountiesPanel = vgui.Create( "DPanel", bounty_TabSheet )
				CompBountiesPanel:SetPos( 5, 5 )
				CompBountiesPanel:SetSize( bounty_TabSheet:GetWide(), bounty_TabSheet:GetTall() )
				CompBountiesPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
				
				local oBountyList = vgui.Create("DPanelList", CompBountiesPanel)
					oBountyList:SetPos(0, 0)
					oBountyList:SetSize(CompBountiesPanel:GetWide() - 15, CompBountiesPanel:GetTall() - 40)
					oBountyList:EnableVerticalScrollbar(true) 
					oBountyList:EnableHorizontal(false) 
					oBountyList:SetSpacing(1)
					oBountyList:SetPadding(10)
					oBountyList.Paint = function()
					--	draw.RoundedBox( 8, 0, 0, cMemberList:GetWide(), cMemberList:GetTall(), Color( 50, 50, 50, 255 ) )
					end
					for k, v in pairs( bountyCompTable ) do
						local oBountyPanel = vgui.Create("DPanel")
						oBountyPanel:SetTall(75)
						oBountyPanel.Paint = function()
							draw.RoundedBox( 6, 0, 0, oBountyPanel:GetWide(), oBountyPanel:GetTall(), Color( 180, 200, 180, 80 ) )		
						end
						oBountyList:AddItem(oBountyPanel)
						
						oBountyPanel.Icon = vgui.Create("SpawnIcon", oBountyPanel)
						oBountyPanel.Icon:SetModel(v["model"])
						oBountyPanel.Icon:SetPos(3, 3)
						oBountyPanel.Icon:SetToolTip( nil )
						oBountyPanel.Icon.DoClick = function() 
							viewBounty(v, "full") 
							bounty_Frame:Close()
						end
						
						oBountyPanel.Name = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Name:SetPos(90, 5)
						oBountyPanel.Name:SetText("Target: "..v["name"])
						oBountyPanel.Name:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Name:SizeToContents() 
						oBountyPanel.Name:SetContentAlignment( 5 )
						
						oBountyPanel.Class = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Class:SetPos(90, 15)
						oBountyPanel.Class:SetText(team.GetName(tonumber(v["class"])))
						oBountyPanel.Class:SetColor(team.GetColor(tonumber(v["class"])))
						oBountyPanel.Class:SizeToContents() 
						oBountyPanel.Class:SetContentAlignment( 5 )
						
						oBountyPanel.Community = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Community:SetPos(90, 27)
						oBountyPanel.Community:SetText("Member of: "..v["community"])
						oBountyPanel.Community:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Community:SizeToContents() 
						oBountyPanel.Community:SetContentAlignment( 5 )
						
						oBountyPanel.Reward = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Reward:SetPos(90, 40)
						oBountyPanel.Reward:SetText("Reward: "..v["payment"])
						oBountyPanel.Reward:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Reward:SizeToContents() 
						oBountyPanel.Reward:SetContentAlignment( 5 )
						
						local postDate = os.date("%x %X", v["comption_date"])
						oBountyPanel.Date = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Date:SetPos(90, 55)
						oBountyPanel.Date:SetText("Completed on: "..postDate)
						oBountyPanel.Date:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Date:SizeToContents() 
						oBountyPanel.Date:SetContentAlignment( 5 )
						
						
					end
					
			openBountySheet = bounty_TabSheet:AddSheet( "Completed", CompBountiesPanel, "gui/icons/group.png", false, false, "Bounties Completed" )
		
		--//Main Menu
								
			local btnHPos = 50
			local btnHeight = 40
			local lblColor = Color( 245, 218, 210, 180 )
			
			local bbLbl = vgui.Create("DLabel", bounty_Frame)
				bbLbl:SetPos( bounty_Frame:GetWide()-260,btnHPos )
				bbLbl:SetColor( lblColor )
				bbLbl:SetText( "Wasteland Bounty Board" )
				bbLbl:SetFont("Trebuchet24")
				bbLbl:SizeToContents()
				
			btnHPos = btnHPos + btnHeight		
			local createBtn = vgui.Create("DImageButton", bounty_Frame)
				createBtn:SetPos( bounty_Frame:GetWide()-260,btnHPos )
				createBtn:SetSize(30,30)

				createBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				createBtn.DoClick = function() 
					PNRP.PostBountyWindow() 
					bounty_Frame:Close()
				end
				createBtn.Paint = function()
					if createBtn:IsDown() then 
						createBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						createBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end
				
			local postBtnLbl = vgui.Create("DLabel", bounty_Frame)
				postBtnLbl:SetPos( bounty_Frame:GetWide()-210,btnHPos+2 )
				postBtnLbl:SetColor( lblColor )
				postBtnLbl:SetText( "Post Bounty" )
				postBtnLbl:SetFont("Trebuchet24")
				postBtnLbl:SizeToContents()
			
		--	if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then	
			if ply:IsAdmin() then
				btnHPos = btnHPos + btnHeight
				local adminBtn = vgui.Create("DImageButton", bounty_Frame)
					adminBtn:SetPos( bounty_Frame:GetWide()-260,btnHPos )
					adminBtn:SetSize(30,30)

					adminBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					adminBtn.DoClick = function() 
						net.Start("runBountyAdmin")
							net.WriteEntity(ply)
						net.SendToServer()
						bounty_Frame:Close()
					end
					adminBtn.Paint = function()
						if adminBtn:IsDown() then 
							adminBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						else
							adminBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
						end
					end
					
				local postBtnLbl = vgui.Create("DLabel", bounty_Frame)
					postBtnLbl:SetPos( bounty_Frame:GetWide()-210,btnHPos+2 )
					postBtnLbl:SetColor( lblColor )
					postBtnLbl:SetText( "Bounty Admin" )
					postBtnLbl:SetFont("Trebuchet24")
					postBtnLbl:SizeToContents()
			end
				
			btnHPos = btnHPos + btnHeight
			local bbTxt = "Bounties are subject to a 10% tax. \n"
			bbTxt = bbTxt.."Bounty tax will be deducted even if the bounty has not been completed.\n"
			bbTxt = bbTxt.."Bounty tax is non refundable.\n\n"
			bbTxt = bbTxt.."Bounties will expire after 3 days\n\n"
			bbTxt = bbTxt.."Bounty must be Accepted before the Target is terminated to be completed.\n\n\n"
			bbTxt = bbTxt.."Color Code:\n"
			bbTxt = bbTxt.."Grey = Open Bounty\n"
			bbTxt = bbTxt.."Blue = Your Posted Bounties\n"
			bbTxt = bbTxt.."Yellow = Your Accepted Bounties\n"
			bbTxt = bbTxt.."Green = Completed Bounties\n"
			bbTxt = bbTxt.."Red = Expired Bounties\n"
			local costLbl = vgui.Create("DLabel", bounty_Frame)
				costLbl:SetPos( bounty_Frame:GetWide()-265,btnHPos )
				costLbl:SetColor( lblColor )
				costLbl:SetWrap( true )
				costLbl:SetText( bbTxt )
				costLbl:SetFont("HudHintTextLarge")
				costLbl:SetWidth(240)
				costLbl:SetAutoStretchVertical( true )
			
	function bounty_Frame:Close()                  
		bbFrame = false                  
		self:SetVisible( false )                  
		self:Remove()          
	end 
end
net.Receive( "pnrp_OpenBountyBoard", GM.bountyBoardMenu )

local adminBounty_Frame
local adminBounty = false
function GM.OpenBountyAdmin()
	if adminBounty then return end
	adminBounty = true 
	
	local ply = LocalPlayer()
	local bountyTable = net.ReadTable()
	local bountyCompTable = net.ReadTable()
	local bountyExpTable = net.ReadTable()
	
	adminBounty_Frame = vgui.Create( "DFrame" )
		adminBounty_Frame:SetSize( 710, 520 ) 
		adminBounty_Frame:SetPos(ScrW() / 2 - adminBounty_Frame:GetWide() / 2, ScrH() / 2 - adminBounty_Frame:GetTall() / 2)
		adminBounty_Frame:SetTitle( " " )
		adminBounty_Frame:SetVisible( true )
		adminBounty_Frame:SetDraggable( false )
		adminBounty_Frame:ShowCloseButton( true )
		adminBounty_Frame:MakePopup()
		adminBounty_Frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end	
		
		local screenBG = vgui.Create("DImage", adminBounty_Frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_4b.png" )
			screenBG:SetSize(adminBounty_Frame:GetWide(), adminBounty_Frame:GetTall())	
		
		local openBountySheet
		local bounty_TabSheet = vgui.Create( "DPropertySheet" )
			bounty_TabSheet:SetParent( adminBounty_Frame )
			bounty_TabSheet:SetPos( 40, 40 )
			bounty_TabSheet:SetSize( adminBounty_Frame:GetWide() - 340, adminBounty_Frame:GetTall() - 90 )
			bounty_TabSheet.Paint = function() -- Paint function
				surface.SetDrawColor( 50, 50, 50, 0 )
			end

		--//Open Bounties	
			local openBountiesPanel = vgui.Create( "DPanel", bounty_TabSheet )
				openBountiesPanel:SetPos( 5, 5 )
				openBountiesPanel:SetSize( bounty_TabSheet:GetWide(), bounty_TabSheet:GetTall() )
				openBountiesPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
				
				local oBountyList = vgui.Create("DPanelList", openBountiesPanel)
					oBountyList:SetPos(0, 0)
					oBountyList:SetSize(openBountiesPanel:GetWide() - 15, openBountiesPanel:GetTall() - 40)
					oBountyList:EnableVerticalScrollbar(true) 
					oBountyList:EnableHorizontal(false) 
					oBountyList:SetSpacing(1)
					oBountyList:SetPadding(10)
					oBountyList.Paint = function()
					--	draw.RoundedBox( 8, 0, 0, cMemberList:GetWide(), cMemberList:GetTall(), Color( 50, 50, 50, 255 ) )
					end
				--	ply:ChatPrint(table.ToString(bountyTable))
					for k, v in pairs( bountyTable ) do
						local oBountyPanel = vgui.Create("DPanel")
						oBountyPanel:SetTall(75)
						oBountyPanel.Paint = function()
							draw.RoundedBox( 6, 0, 0, oBountyPanel:GetWide(), oBountyPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
						end
						oBountyList:AddItem(oBountyPanel)
						
						oBountyPanel.Icon = vgui.Create("SpawnIcon", oBountyPanel)
						oBountyPanel.Icon:SetModel(v["model"])
						oBountyPanel.Icon:SetPos(3, 3)
						oBountyPanel.Icon:SetToolTip( nil )
						oBountyPanel.Icon.DoClick = function() 
							viewBounty(v, "admin") 
							adminBounty_Frame:Close()
						end
						
						oBountyPanel.Name = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Name:SetPos(90, 5)
						oBountyPanel.Name:SetText("Target: "..v["name"])
						oBountyPanel.Name:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Name:SizeToContents() 
						oBountyPanel.Name:SetContentAlignment( 5 )
						
						oBountyPanel.Class = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Class:SetPos(90, 15)
						oBountyPanel.Class:SetText(team.GetName(tonumber(v["class"])))
						oBountyPanel.Class:SetColor(team.GetColor(tonumber(v["class"])))
						oBountyPanel.Class:SizeToContents() 
						oBountyPanel.Class:SetContentAlignment( 5 )
						
						oBountyPanel.Community = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Community:SetPos(90, 27)
						oBountyPanel.Community:SetText("Member of: "..v["community"])
						oBountyPanel.Community:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Community:SizeToContents() 
						oBountyPanel.Community:SetContentAlignment( 5 )
						
						oBountyPanel.Reward = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Reward:SetPos(90, 40)
						oBountyPanel.Reward:SetText("Reward: "..v["payment"])
						oBountyPanel.Reward:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Reward:SizeToContents() 
						oBountyPanel.Reward:SetContentAlignment( 5 )
						
						local postDate = os.date("%x %X", v["date"])
						oBountyPanel.Date = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Date:SetPos(90, 55)
						oBountyPanel.Date:SetText("Posted on: "..postDate)
						oBountyPanel.Date:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Date:SizeToContents() 
						oBountyPanel.Date:SetContentAlignment( 5 )
					end
					
			openBountySheet = bounty_TabSheet:AddSheet( "Open Bounties", openBountiesPanel, "gui/icons/group.png", false, false, "Open Bounties" )

		--//Bounties Completed 
			local CompBountiesPanel = vgui.Create( "DPanel", bounty_TabSheet )
				CompBountiesPanel:SetPos( 5, 5 )
				CompBountiesPanel:SetSize( bounty_TabSheet:GetWide(), bounty_TabSheet:GetTall() )
				CompBountiesPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
				
				local oBountyList = vgui.Create("DPanelList", CompBountiesPanel)
					oBountyList:SetPos(0, 0)
					oBountyList:SetSize(CompBountiesPanel:GetWide() - 15, CompBountiesPanel:GetTall() - 40)
					oBountyList:EnableVerticalScrollbar(true) 
					oBountyList:EnableHorizontal(false) 
					oBountyList:SetSpacing(1)
					oBountyList:SetPadding(10)
					oBountyList.Paint = function()
					--	draw.RoundedBox( 8, 0, 0, cMemberList:GetWide(), cMemberList:GetTall(), Color( 50, 50, 50, 255 ) )
					end
					for k, v in pairs( bountyCompTable ) do
						local oBountyPanel = vgui.Create("DPanel")
						oBountyPanel:SetTall(75)
						oBountyPanel.Paint = function()
							draw.RoundedBox( 6, 0, 0, oBountyPanel:GetWide(), oBountyPanel:GetTall(), Color( 180, 200, 180, 80 ) )		
						end
						oBountyList:AddItem(oBountyPanel)
						
						oBountyPanel.Icon = vgui.Create("SpawnIcon", oBountyPanel)
						oBountyPanel.Icon:SetModel(v["model"])
						oBountyPanel.Icon:SetPos(3, 3)
						oBountyPanel.Icon:SetToolTip( nil )
						oBountyPanel.Icon.DoClick = function() 
							viewBounty(v, "admin") 
							adminBounty_Frame:Close()
						end
						
						oBountyPanel.Name = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Name:SetPos(90, 4)
						oBountyPanel.Name:SetText("Target: "..v["name"])
						oBountyPanel.Name:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Name:SizeToContents() 
						oBountyPanel.Name:SetContentAlignment( 5 )
						
						oBountyPanel.poster = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.poster:SetPos(90, 17)
						oBountyPanel.poster:SetText("Posted by: "..v["posted_by"])
						oBountyPanel.poster:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.poster:SizeToContents() 
						oBountyPanel.poster:SetContentAlignment( 5 )
						
						oBountyPanel.hitman = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.hitman:SetPos(90, 30)
						oBountyPanel.hitman:SetText("Hitman: "..v["completed_by"])
						oBountyPanel.hitman:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.hitman:SizeToContents() 
						oBountyPanel.hitman:SetContentAlignment( 5 )
						
						oBountyPanel.Reward = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Reward:SetPos(90, 42)
						oBountyPanel.Reward:SetText("Reward: "..v["payment"])
						oBountyPanel.Reward:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Reward:SizeToContents() 
						oBountyPanel.Reward:SetContentAlignment( 5 )
						
						local postDate = os.date("%x %X", v["comption_date"])
						oBountyPanel.Date = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Date:SetPos(90, 55)
						oBountyPanel.Date:SetText("Completed on: "..postDate)
						oBountyPanel.Date:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Date:SizeToContents() 
						oBountyPanel.Date:SetContentAlignment( 5 )
						
						
					end
					
			openBountySheet = bounty_TabSheet:AddSheet( "Completed", CompBountiesPanel, "gui/icons/group.png", false, false, "Bounties Completed" )

		--//Bounties Expired 
			local ExpBountiesPanel = vgui.Create( "DPanel", bounty_TabSheet )
				ExpBountiesPanel:SetPos( 5, 5 )
				ExpBountiesPanel:SetSize( bounty_TabSheet:GetWide(), bounty_TabSheet:GetTall() )
				ExpBountiesPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
				
				local oBountyList = vgui.Create("DPanelList", ExpBountiesPanel)
					oBountyList:SetPos(0, 0)
					oBountyList:SetSize(ExpBountiesPanel:GetWide() - 15, ExpBountiesPanel:GetTall() - 40)
					oBountyList:EnableVerticalScrollbar(true) 
					oBountyList:EnableHorizontal(false) 
					oBountyList:SetSpacing(1)
					oBountyList:SetPadding(10)
					oBountyList.Paint = function()
					--	draw.RoundedBox( 8, 0, 0, cMemberList:GetWide(), cMemberList:GetTall(), Color( 50, 50, 50, 255 ) )
					end
					for k, v in pairs( bountyExpTable ) do
						local oBountyPanel = vgui.Create("DPanel")
						oBountyPanel:SetTall(75)
						oBountyPanel.Paint = function()
							draw.RoundedBox( 6, 0, 0, oBountyPanel:GetWide(), oBountyPanel:GetTall(), Color( 200, 180, 180, 80 ) )		
						end
						oBountyList:AddItem(oBountyPanel)
						
						oBountyPanel.Icon = vgui.Create("SpawnIcon", oBountyPanel)
						oBountyPanel.Icon:SetModel(v["model"])
						oBountyPanel.Icon:SetPos(3, 3)
						oBountyPanel.Icon:SetToolTip( nil )
						oBountyPanel.Icon.DoClick = function() 
							viewBounty(v, "admin") 
							adminBounty_Frame:Close()
						end
						
						oBountyPanel.Name = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Name:SetPos(90, 5)
						oBountyPanel.Name:SetText("Target: "..v["name"])
						oBountyPanel.Name:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Name:SizeToContents() 
						oBountyPanel.Name:SetContentAlignment( 5 )
						
						oBountyPanel.Class = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Class:SetPos(90, 15)
						oBountyPanel.Class:SetText(team.GetName(tonumber(v["class"])))
						oBountyPanel.Class:SetColor(team.GetColor(tonumber(v["class"])))
						oBountyPanel.Class:SizeToContents() 
						oBountyPanel.Class:SetContentAlignment( 5 )
						
						oBountyPanel.Community = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Community:SetPos(90, 27)
						oBountyPanel.Community:SetText("Member of: "..v["community"])
						oBountyPanel.Community:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Community:SizeToContents() 
						oBountyPanel.Community:SetContentAlignment( 5 )
						
						oBountyPanel.Reward = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Reward:SetPos(90, 40)
						oBountyPanel.Reward:SetText("Reward: "..v["payment"])
						oBountyPanel.Reward:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Reward:SizeToContents() 
						oBountyPanel.Reward:SetContentAlignment( 5 )
						
						local postDate = os.date("%x %X", v["comption_date"])
						oBountyPanel.Date = vgui.Create("DLabel", oBountyPanel)
						oBountyPanel.Date:SetPos(90, 55)
						oBountyPanel.Date:SetText("Completed on: "..postDate)
						oBountyPanel.Date:SetColor(Color( 0, 0, 0, 255 ))
						oBountyPanel.Date:SizeToContents() 
						oBountyPanel.Date:SetContentAlignment( 5 )
						
						
					end
					
			openBountySheet = bounty_TabSheet:AddSheet( "Expired", ExpBountiesPanel, "gui/icons/group.png", false, false, "Bounties Expired" )
		
		--//Main Menu
								
			local btnHPos = 50
			local btnHeight = 40
			local lblColor = Color( 245, 218, 210, 180 )
			
			local bbLbl = vgui.Create("DLabel", adminBounty_Frame)
				bbLbl:SetPos( adminBounty_Frame:GetWide()-260,btnHPos )
				bbLbl:SetColor( lblColor )
				bbLbl:SetText( "Wasteland Bounty Board" )
				bbLbl:SetFont("Trebuchet24")
				bbLbl:SizeToContents()
				bbLbl:SetContentAlignment( 8 )
			
			btnHPos = btnHPos + btnHeight
			local bbLbl = vgui.Create("DLabel", adminBounty_Frame)
				bbLbl:SetPos( adminBounty_Frame:GetWide()-240,btnHPos )
				bbLbl:SetColor( lblColor )
				bbLbl:SetText( "Administration Panel" )
				bbLbl:SetFont("Trebuchet24")
				bbLbl:SizeToContents()
				bbLbl:SetContentAlignment( 8 )
				
			btnHPos = btnHPos + btnHeight
			local bbTxt = "Select bounty to view or delete. \n"
			local costLbl = vgui.Create("DLabel", adminBounty_Frame)
				costLbl:SetPos( adminBounty_Frame:GetWide()-265,btnHPos )
				costLbl:SetColor( lblColor )
				costLbl:SetWrap( true )
				costLbl:SetText( bbTxt )
				costLbl:SetFont("HudHintTextLarge")
				costLbl:SetSize(240,40)
	
	function adminBounty_Frame:Close()                  
		adminBounty = false                  
		self:SetVisible( false )                  
		self:Remove()          
	end 
end
net.Receive( "pnrp_OpenBountyAdmin", GM.OpenBountyAdmin )

local bbVewBounty_Frame
local bbViewBounty = false
function viewBounty(target, option)
	if bbViewBounty then return end
	bbViewBounty = true 
	
	local ply = LocalPlayer()
	if option ~= "admin" then
		if tostring(target["player_pid"]) == tostring(target["poster_pid"]) then
			option = "owner"
		end
		
		if tostring(target["player_pid"]) == tostring(target["pid"]) then
			option = "self"
		end
	end
	
	bbVewBounty_Frame = vgui.Create( "DFrame" )
		bbVewBounty_Frame:SetSize( 575, 265 ) 
		bbVewBounty_Frame:SetPos(ScrW() / 2 - bbVewBounty_Frame:GetWide() / 2, ScrH() / 2 - bbVewBounty_Frame:GetTall() / 2)
		bbVewBounty_Frame:SetTitle( " " )
		bbVewBounty_Frame:SetVisible( true )
		bbVewBounty_Frame:SetDraggable( false )
		bbVewBounty_Frame:ShowCloseButton( true )
		bbVewBounty_Frame:MakePopup()
		bbVewBounty_Frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", bbVewBounty_Frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_6b.png" )
			screenBG:SetSize(bbVewBounty_Frame:GetWide(), bbVewBounty_Frame:GetTall())
		
			local bbPostPanel = vgui.Create( "DPanel", bbVewBounty_Frame )
				bbPostPanel:SetPos( 20, 30 )
				bbPostPanel:SetSize( bbVewBounty_Frame:GetWide(), bbVewBounty_Frame:GetTall() )
				bbPostPanel.Paint = function() 
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
			
			local targetIcom = vgui.Create("SpawnIcon", bbVewBounty_Frame)
				targetIcom:SetModel(target["model"])
				targetIcom:SetPos(40, 40)
				targetIcom:SetSize(75, 75)
				targetIcom:SetToolTip( nil )
				
			local targetName = vgui.Create("DLabel", bbVewBounty_Frame)
				targetName:SetPos(125, 40)
				targetName:SetText("Name: "..target["name"])
				targetName:SetColor(Color( 0, 255, 0, 255 ))
				targetName:SizeToContents() 
				targetName:SetContentAlignment( 5 )
				
			local targetClass = vgui.Create("DLabel", bbVewBounty_Frame)
				targetClass:SetPos(125, 55)
				targetClass:SetText("Class: "..team.GetName(tonumber(target["class"])))
				targetClass:SetColor(Color(0,255,0,255))
				targetClass:SizeToContents() 
				targetClass:SetContentAlignment( 5 )
			
			local targetCommunity = vgui.Create("DLabel", bbVewBounty_Frame)
				targetCommunity:SetPos(125, 70)
				targetCommunity:SetText("Member of: "..target["community"])
				targetCommunity:SetColor(Color( 0, 255, 0, 255 ))
				targetCommunity:SizeToContents() 
				targetCommunity:SetContentAlignment( 5 )
			
			local notes = target["notes"]
			if option == "admin" then
				notes = "Registered Hitmen: "..tostring(target["hitmen"]).."\n\n"..notes
			end

			local note_Panel = vgui.Create( "DScrollPanel", bbVewBounty_Frame )
				note_Panel:SetSize(290, 100)
				note_Panel:SetPos(40, 125)
				
				local targetNotes = vgui.Create("DLabel", note_Panel)
					targetNotes:SetPos(0, 0)
					targetNotes:SetMultiline(true)
					targetNotes:SetWrap( true )
					targetNotes:SetText(notes)
					targetNotes:SetColor(Color( 0, 255, 0, 255 ))
				--	targetNotes:SetSize( 300, 100)
					targetNotes:SetAutoStretchVertical( true )
					targetNotes:SetWide(300)
					targetNotes:SetContentAlignment( 7 )
			
			local wPos = bbVewBounty_Frame:GetWide() - 200
			local postedon = os.date("%x %X", target["date"])
			local targetPosted = vgui.Create("DLabel", bbVewBounty_Frame)
				targetPosted:SetPos(wPos, 40)
				targetPosted:SetText("Posted on: "..postedon)
				targetPosted:SetColor(Color( 0, 255, 0, 255 ))
				targetPosted:SizeToContents() 
				targetPosted:SetContentAlignment( 5 )
				
			local award = string.Explode(",", target["payment"])
			local targetPayment = vgui.Create("DLabel", bbVewBounty_Frame)
				targetPayment:SetPos(wPos+2, 55)
				targetPayment:SetText("Award: \n |-Scrap:  "..award[1].."\n |-SmParts:  "..award[2].."\n |-Chems:  "..award[3])
				targetPayment:SetColor(Color( 0, 255, 0, 255 ))
				targetPayment:SizeToContents() 
				targetPayment:SetContentAlignment( 5 )
				
			if option == "full"	or option == "admin" then
				local postedBy = vgui.Create("DLabel", bbVewBounty_Frame)
					postedBy:SetPos(wPos, 108)
					postedBy:SetText("Posted by: "..target["posted_by"])
					postedBy:SetColor(Color( 0, 255, 0, 255 ))
					postedBy:SizeToContents() 
					postedBy:SetContentAlignment( 5 )
				local hitmanName = vgui.Create("DLabel", bbVewBounty_Frame)
					hitmanName:SetPos(wPos, 120)
					hitmanName:SetText("Hitman : "..target["completed_by"])
					hitmanName:SetColor(Color( 0, 255, 0, 255 ))
					hitmanName:SizeToContents() 
					hitmanName:SetContentAlignment( 5 )
					
				local completedOn = vgui.Create("DLabel", bbVewBounty_Frame)
					completedOn:SetPos(125, 100)
					completedOn:SetText("Bounty Completed: "..os.date("%x %X",target["competion_date"]))
					completedOn:SetColor(Color( 0, 255, 0, 255 ))
					completedOn:SizeToContents() 
					completedOn:SetContentAlignment( 5 )
			end
				
	--//Side Menu
		local btnHPos = 160
		local btnWPos = bbVewBounty_Frame:GetWide()-215
		local btnHeight = 40
		local lblOffset = 50
		local lblColor = Color( 245, 218, 210, 180 )
		local closeBtnLbl = "Decline"
		
		if option == "open" then
			local acceptBtn = vgui.Create("DImageButton", bbVewBounty_Frame)
				acceptBtn:SetPos( btnWPos,btnHPos )
				acceptBtn:SetSize(30,30)

				acceptBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				acceptBtn.DoClick = function() 
					net.Start("takeBounty")
						net.WriteEntity(ply)
						net.WriteString(target["bid"])
						net.WriteString(target["name"])
						net.WriteString(target["pid"])
					net.SendToServer()
					
					bbVewBounty_Frame:Close()
				end
				acceptBtn.Paint = function()
					if acceptBtn:IsDown() then 
						acceptBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						acceptBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end
				
			local acceptBtnLbl = vgui.Create("DLabel", bbVewBounty_Frame)
				acceptBtnLbl:SetPos( btnWPos+lblOffset,btnHPos+2 )
				acceptBtnLbl:SetColor( lblColor )
				acceptBtnLbl:SetText( "Accept" )
				acceptBtnLbl:SetFont("Trebuchet24")
				acceptBtnLbl:SizeToContents()
		elseif option == "admin" then
			local deleteBtn = vgui.Create("DImageButton", bbVewBounty_Frame)
				deleteBtn:SetPos( btnWPos,btnHPos )
				deleteBtn:SetSize(30,30)

				deleteBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				deleteBtn.DoClick = function() 
					net.Start("remBounty")
						net.WriteEntity(ply)
						net.WriteString(target["bid"])
					net.SendToServer()
					
					bbVewBounty_Frame:Close()
					
					net.Start("runBountyAdmin")
						net.WriteEntity(ply)
					net.SendToServer()
				end
				deleteBtn.Paint = function()
					if deleteBtn:IsDown() then 
						deleteBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						deleteBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end
				
			local deleteBtnLbl = vgui.Create("DLabel", bbVewBounty_Frame)
				deleteBtnLbl:SetPos( btnWPos+lblOffset,btnHPos+2 )
				deleteBtnLbl:SetColor( lblColor )
				deleteBtnLbl:SetText( "Delete Bounty" )
				deleteBtnLbl:SetFont("Trebuchet24")
				deleteBtnLbl:SizeToContents()
				
			closeBtnLbl = "Cancel"
		elseif option == "owner" then
			if target["completed"] == "false" then
				local remBtn = vgui.Create("DImageButton", bbVewBounty_Frame)
					remBtn:SetPos( btnWPos,btnHPos )
					remBtn:SetSize(30,30)

					remBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					remBtn.DoClick = function() 
						net.Start("remBounty")
							net.WriteEntity(ply)
							net.WriteString(target["bid"])
						net.SendToServer()
						
						bbVewBounty_Frame:Close()
					end
					remBtn.Paint = function()
						if remBtn:IsDown() then 
							remBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						else
							remBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
						end
					end
					
				local remBtnLbl = vgui.Create("DLabel", bbVewBounty_Frame)
					remBtnLbl:SetPos( btnWPos+lblOffset,btnHPos+2 )
					remBtnLbl:SetColor( lblColor )
					remBtnLbl:SetText( "Cancel Bounty" )
					remBtnLbl:SetFont("Trebuchet24")
					remBtnLbl:SizeToContents()
			end
			closeBtnLbl = "Back"
		elseif option == "self" then
			closeBtnLbl = "Back"
		else
			closeBtnLbl = "Close"
		end
		
		btnHPos = btnHPos + btnHeight
		local declineBtn = vgui.Create("DImageButton", bbVewBounty_Frame)
			declineBtn:SetPos( btnWPos,btnHPos )
			declineBtn:SetSize(30,30)

			declineBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			declineBtn.DoClick = function() 
				bbVewBounty_Frame:Close()
				
				if option == "admin" then
					net.Start("runBountyAdmin")
						net.WriteEntity(ply)
					net.SendToServer()
				else
					net.Start( "startBountyBoard" )
						net.WriteEntity(ply)		
					net.SendToServer()
				end
			end
			declineBtn.Paint = function()
				if declineBtn:IsDown() then 
					declineBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					declineBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end
			
		local declineBtnLbl = vgui.Create("DLabel", bbVewBounty_Frame)
			declineBtnLbl:SetPos( btnWPos+lblOffset,btnHPos+2 )
			declineBtnLbl:SetColor( lblColor )
			declineBtnLbl:SetText( closeBtnLbl )
			declineBtnLbl:SetFont("Trebuchet24")
			declineBtnLbl:SizeToContents()
					
	function bbVewBounty_Frame:Close()                  
		bbViewBounty = false                  
		self:SetVisible( false )                  
		self:Remove()          
	end 
end

local bbPost_Frame
local bbPost = false
function PNRP.PostBountyWindow()
	if bbPost then return end
	bbPost = true 
	
	local ply = LocalPlayer()
	local scrap = GetResource("Scrap")
	local smallparts = GetResource("Small_Parts")
	local chems = GetResource("Chemicals")
	local bountySelect = nil
	
	local minScrap = 200
	local minParts = 75
	local minChems = 10
	
	bbPost_Frame = vgui.Create( "DFrame" )
		bbPost_Frame:SetSize( 575, 265 ) 
		bbPost_Frame:SetPos(ScrW() / 2 - bbPost_Frame:GetWide() / 2, ScrH() / 2 - bbPost_Frame:GetTall() / 2)
		bbPost_Frame:SetTitle( " " )
		bbPost_Frame:SetVisible( true )
		bbPost_Frame:SetDraggable( false )
		bbPost_Frame:ShowCloseButton( true )
		bbPost_Frame:MakePopup()
		bbPost_Frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", bbPost_Frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_6b.png" )
			screenBG:SetSize(bbPost_Frame:GetWide(), bbPost_Frame:GetTall())
		
			local bbPostPanel = vgui.Create( "DPanel", bbPost_Frame )
				bbPostPanel:SetPos( 20, 30 )
				bbPostPanel:SetSize( bbPost_Frame:GetWide(), bbPost_Frame:GetTall() )
				bbPostPanel.Paint = function() 
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
			
			--Right Pane
			local PlayerSelectTxt = vgui.Create("DLabel", bbPost_Frame)		
				PlayerSelectTxt:SetPos(bbPost_Frame:GetWide() - 200, 40)
				PlayerSelectTxt:SetText("Selected: None")
				PlayerSelectTxt:SetColor(Color( 0, 255, 0, 255 ))
				PlayerSelectTxt:SizeToContents() 
			
			--Bounty Player Lists	
			local bbPostList = vgui.Create("DPanelList", bbPostPanel)
				bbPostList:SetPos(0, 0)
				bbPostList:SetSize(bbPostPanel:GetWide() - 265, bbPostPanel:GetTall() - 70)
				bbPostList:EnableVerticalScrollbar(true) 
				bbPostList:EnableHorizontal(false) 
				bbPostList:SetSpacing(1)
				bbPostList:SetPadding(10)
				
			local setTxt = vgui.Create("DTextEntry", bbPostPanel)
				setTxt:SetMultiline(true)
				setTxt:SetText("")
				setTxt:SetPos(10,40)
				setTxt:SetVisible(false)
				setTxt:SetSize(300,150)
			local txtLabel = vgui.Create( "DLabel", bbPostPanel )
				txtLabel:SetPos(170,20)
				txtLabel:SetVisible(false)
				txtLabel:SetColor(Color( 0, 255, 0, 255 ))
				txtLabel:SetText( "Enter Bounty Notes below." )
				txtLabel:SizeToContents()
			local cancelTxtBtn = vgui.Create( "DButton", bbPostPanel )
				cancelTxtBtn:SetSize( 150, 15 )
				cancelTxtBtn:SetPos( 10, 20)
				cancelTxtBtn:SetText( "Cancel Target" )
				cancelTxtBtn:SetVisible(false)
				cancelTxtBtn.DoClick = function( )
					bbPostList:SetVisible(true)
					setTxt:SetVisible(false)
					cancelTxtBtn:SetVisible(false)
					txtLabel:SetVisible(false)
					PlayerSelectTxt:SetText("Selected: None")
					bountySelect = nil
				end
			
			local resHPos = 35
			local resWPos = bbPostPanel:GetWide() - 220
			local resHeight = 20
			local giveScrapLBL = vgui.Create("DLabel", bbPostPanel)
				giveScrapLBL:SetPos(resWPos, resHPos)
				giveScrapLBL:SetText("Scrap")
				giveScrapLBL:SetColor(Color(0,255,0,255))
				giveScrapLBL:SizeToContents() 
				giveScrapLBL:SetContentAlignment( 5 )	
			local giveScrap = vgui.Create( "DNumberWang", bbPostPanel )
				giveScrap:SetPos( resWPos+75, resHPos-5 )
				giveScrap:SetMin( minScrap )
				giveScrap:SetMax( scrap )
				giveScrap:SetDecimals( 0 )
				giveScrap:SetValue( minScrap )	
			resHPos = resHPos + resHeight	
			local givePartsLBL = vgui.Create("DLabel", bbPostPanel)
				givePartsLBL:SetPos(resWPos, resHPos)
				givePartsLBL:SetText("Small Parts")
				givePartsLBL:SetColor(Color(0,255,0,255))
				givePartsLBL:SizeToContents() 
				givePartsLBL:SetContentAlignment( 5 )	
			local giveParts = vgui.Create( "DNumberWang", bbPostPanel )
				giveParts:SetPos( resWPos+75, resHPos-5 )
				giveParts:SetMin( minParts )
				giveParts:SetMax( smallparts )
				giveParts:SetDecimals( 0 )
				giveParts:SetValue( minParts )	
			resHPos = resHPos + resHeight		
			local giveChemsLBL = vgui.Create("DLabel", bbPostPanel)
				giveChemsLBL:SetPos(resWPos, resHPos)
				giveChemsLBL:SetText("Chemicals")
				giveChemsLBL:SetColor(Color(0,255,0,255))
				giveChemsLBL:SizeToContents() 
				giveChemsLBL:SetContentAlignment( 5 )	
			local giveChems = vgui.Create( "DNumberWang", bbPostPanel )
				giveChems:SetPos( resWPos+75, resHPos-5 )
				giveChems:SetMin( minChems )
				giveChems:SetMax( chems )
				giveChems:SetDecimals( 0 )
				giveChems:SetValue( minChems )	
		
			for _, iplayer in pairs(player.GetAll()) do
				if iplayer:GetClass()=="player" and iplayer ~= ply then
			--	if iplayer:GetClass()=="player" then
					local iPlayerPanel = vgui.Create("DPanel")
					iPlayerPanel:SetTall(50)
					iPlayerPanel.Paint = function()
						draw.RoundedBox( 6, 0, 0, iPlayerPanel:GetWide(), iPlayerPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
					end
					bbPostList:AddItem(iPlayerPanel)
					
					iPlayerPanel.Icon = vgui.Create("SpawnIcon", iPlayerPanel)
					iPlayerPanel.Icon:SetModel(iplayer:GetModel())
					iPlayerPanel.Icon:SetPos(3, 3)
					iPlayerPanel.Icon:SetSize(45, 45)
					iPlayerPanel.Icon:SetToolTip( nil )
					iPlayerPanel.Icon.DoClick = function() 
						bountySelect = iplayer
						PlayerSelectTxt:SetText("Selected: "..iplayer:Nick())
						PlayerSelectTxt:SizeToContents()
						bbPostList:SetVisible(false)
						setTxt:SetVisible(true)
						cancelTxtBtn:SetVisible(true)
						txtLabel:SetVisible(true)
					end
					
					iPlayerPanel.Title = vgui.Create("DLabel", iPlayerPanel)
					iPlayerPanel.Title:SetPos(90, 5)
					iPlayerPanel.Title:SetText(iplayer:Nick())
					iPlayerPanel.Title:SetColor(Color( 0, 0, 0, 255 ))
					iPlayerPanel.Title:SizeToContents() 
					iPlayerPanel.Title:SetContentAlignment( 5 )
					
					iPlayerPanel.Class = vgui.Create("DLabel", iPlayerPanel)
					iPlayerPanel.Class:SetPos(90, 20)
					iPlayerPanel.Class:SetText(team.GetName(iplayer:Team()))
					iPlayerPanel.Class:SetColor(team.GetColor(iplayer:Team()))
					iPlayerPanel.Class:SizeToContents() 
					iPlayerPanel.Class:SetContentAlignment( 5 )
					
					local MemberOf
					MemberOf = iplayer:GetNetVar("community", "N/A")
					
					iPlayerPanel.Community = vgui.Create("DLabel", iPlayerPanel)
					iPlayerPanel.Community:SetPos(90, 35)
					iPlayerPanel.Community:SetText("Member of: "..MemberOf)
					iPlayerPanel.Community:SetColor(Color( 0, 0, 0, 255 ))
					iPlayerPanel.Community:SizeToContents() 
					iPlayerPanel.Community:SetContentAlignment( 5 )
				end
			end
		
		--Side Menu
		local btnHPos = 160
		local btnWPos = bbPost_Frame:GetWide()-225
		local btnHeight = 40
		local lblOffset = 50
		local lblColor = Color( 245, 218, 210, 180 )
				
		local postBtn = vgui.Create("DImageButton", bbPost_Frame)
			postBtn:SetPos( btnWPos,btnHPos )
			postBtn:SetSize(30,30)

			postBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			postBtn.DoClick = function() 
				local scrapAmount = math.Round(giveScrap:GetValue())
				local partsAmount = math.Round(giveParts:GetValue())
				local chemsAmount = math.Round(giveChems:GetValue())
				
				--If player does not have enough to post bounty
				if scrap < minScrap or smallparts < minParts or chems < minChems then
					ply:ChatPrint("You do not have enough to post a bounty.")
					ply:ChatPrint("Minumun: Scrap 200, Small Parts 75, and Chems 10")
					
					return
				end
				
				--Player resource limit check
				if scrapAmount > scrap or partsAmount > smallparts or chemsAmount > chems then
					ply:ChatPrint("You don't have that many resources. Adjusting...")
					if scrapAmount > scrap then giveScrap:SetValue( scrap )	end
					if partsAmount > smallparts then giveParts:SetValue( scrap )	end
					if chemsAmount > chems then giveChems:SetValue( scrap )	end
					
					return
				end
				
				if bountySelect == nil then  --If no one is selected
					ply:ChatPrint("Bounty Target not selected")
				else
					--If enough was not selected to post bounty
					if scrapAmount < minScrap or partsAmount < minParts or chemsAmount < minChems then
						ply:ChatPrint("Minimum bounty not set.")
						ply:ChatPrint("Minumun: Scrap 200, Small Parts 75, and Chems 10")
					else
						--If all is good, post bounty
						net.Start("postBounty")
							net.WriteEntity(ply)
							net.WriteEntity(bountySelect)
							net.WriteDouble(scrapAmount)
							net.WriteDouble(partsAmount)
							net.WriteDouble(chemsAmount)
							net.WriteString(setTxt:GetValue())
						net.SendToServer()
						
						bbPost_Frame:Close()
					end
				end
			end
			postBtn.Paint = function()
				if postBtn:IsDown() then 
					postBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					postBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end
			
		local postBtnLbl = vgui.Create("DLabel", bbPost_Frame)
			postBtnLbl:SetPos( btnWPos+lblOffset,btnHPos+2 )
			postBtnLbl:SetColor( lblColor )
			postBtnLbl:SetText( "Post Bounty" )
			postBtnLbl:SetFont("Trebuchet24")
			postBtnLbl:SizeToContents()
		
		btnHPos = btnHPos + btnHeight
		local cancelBtn = vgui.Create("DImageButton", bbPost_Frame)
			cancelBtn:SetPos( btnWPos,btnHPos )
			cancelBtn:SetSize(30,30)

			cancelBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			cancelBtn.DoClick = function() 
				bbPost_Frame:Close()
			end
			cancelBtn.Paint = function()
				if cancelBtn:IsDown() then 
					cancelBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					cancelBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end
			
		local cancelBtnLbl = vgui.Create("DLabel", bbPost_Frame)
			cancelBtnLbl:SetPos( btnWPos+lblOffset,btnHPos+2 )
			cancelBtnLbl:SetColor( lblColor )
			cancelBtnLbl:SetText( "Cancel" )
			cancelBtnLbl:SetFont("Trebuchet24")
			cancelBtnLbl:SizeToContents()
	
	function bbPost_Frame:Close()                  
		bbPost = false                  
		self:SetVisible( false )                  
		self:Remove()       
	end 
end 


