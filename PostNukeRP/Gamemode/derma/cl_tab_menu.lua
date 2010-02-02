local ScoreFrame
local SCFrame = false

function GM:ScoreboardShow()
	SCFrame = true
	
	ScoreFrame = vgui.Create( "DFrame" )
		ScoreFrame:SetSize( 700, 760 ) --Set the size
		--frame:SetPos( ScrW() / 2, ScrH() / 2 ) --Set the window in the middle of the players screen/game window
		ScoreFrame:SetPos(ScrW() / 2 - ScoreFrame:GetWide() / 2, ScrH() / 2 - ScoreFrame:GetTall() / 2)
		ScoreFrame:SetTitle( "Score Frame" ) --Set title
		ScoreFrame:SetVisible( true )
		ScoreFrame:SetDraggable( false )
		ScoreFrame:ShowCloseButton( false )
		ScoreFrame:MakePopup()
		
		PNRP.buildMenu(ScoreFrame)
			
		local PlayerList = vgui.Create("DPanelList", ScoreFrame)
			PlayerList:SetPos(20, 60)
			PlayerList:SetSize(ScoreFrame:GetWide() - 40, ScoreFrame:GetTall() - 80)
			PlayerList:EnableVerticalScrollbar(true) 
			PlayerList:EnableHorizontal(false) 
			PlayerList:SetSpacing(1)
			PlayerList:SetPadding(10)
			
			for _, idiot in pairs(player.GetAll()) do
	
	
				local PlayerPanel = vgui.Create("DPanel")
				PlayerPanel:SetTall(75)
				PlayerPanel.Paint = function()
				
					draw.RoundedBox( 6, 0, 0, PlayerPanel:GetWide(), PlayerPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
			
				end
				PlayerList:AddItem(PlayerPanel)
		
				
				PlayerPanel.Icon = vgui.Create("SpawnIcon", PlayerPanel)
				PlayerPanel.Icon:SetModel(idiot:GetModel())
				PlayerPanel.Icon:SetPos(3, 3)
				PlayerPanel.Icon:SetToolTip( nil )
			
				PlayerPanel.Title = vgui.Create("DLabel", PlayerPanel)
				PlayerPanel.Title:SetPos(90, 5)
				PlayerPanel.Title:SetText(idiot:Nick())
				PlayerPanel.Title:SetColor(team.GetColor(idiot:Team()))
				PlayerPanel.Title:SizeToContents() 
		 		PlayerPanel.Title:SetContentAlignment( 5 )
		
		
				PlayerPanel.Class = vgui.Create("DLabel", PlayerPanel)		
				PlayerPanel.Class:SetPos(90, 55)
				PlayerPanel.Class:SetText(team.GetName(idiot:Team()))
				PlayerPanel.Class:SetColor(team.GetColor(idiot:Team()))
				PlayerPanel.Class:SizeToContents() 
		 		PlayerPanel.Class:SetContentAlignment( 5 )	
		 		
		 		PlayerPanel.Health = vgui.Create("DLabel", PlayerPanel)		
				PlayerPanel.Health:SetPos(180, 55)
				PlayerPanel.Health:SetText("Health: "..idiot:Health())
				PlayerPanel.Health:SetColor(team.GetColor(idiot:Team()))
				PlayerPanel.Health:SizeToContents() 
		 		PlayerPanel.Health:SetContentAlignment( 5 )
		 		
		 		PlayerPanel.Ping = vgui.Create("DLabel", PlayerPanel)		
				PlayerPanel.Ping:SetPos(580, 5)
				PlayerPanel.Ping:SetText("Ping: "..idiot:Ping())
				PlayerPanel.Ping:SetColor(team.GetColor(idiot:Team()))
				PlayerPanel.Ping:SizeToContents() 
		 		PlayerPanel.Ping:SetContentAlignment( 5 )
				
			end
	return true
end

function PNRP.buildMenu(parent_frame)

	classmenu = vgui.Create("DButton") -- Create the button 	
		classmenu:SetParent( parent_frame ) -- parent the button to the frame
		classmenu:SetText( "Class Menu >" ) -- set the button text
		classmenu:SetPos(20, 25) -- set the button position in the frame
		classmenu:SetSize( 100, 20 ) -- set the button size
		classmenu.DoClick = function ( btn ) -- this will be called when the button is clicked
					local menu123 = DermaMenu() -- create a derma menu
					menu123:AddOption("Wastelander", function() RunConsoleCommand( "team_set_wastelander" ) SCFrame=false ScoreFrame:Close() end ) -- adding options
					menu123:AddOption("Scavenger", function() RunConsoleCommand( "team_set_scavenger" ) SCFrame=false ScoreFrame:Close() end )
					menu123:AddOption("Science", function() RunConsoleCommand( "team_set_science" ) SCFrame=false ScoreFrame:Close() end )
					menu123:AddOption("Engineer", function() RunConsoleCommand( "team_set_engineer" ) SCFrame=false ScoreFrame:Close() end )
					menu123:AddOption("Cultivator", function() RunConsoleCommand( "team_set_cultivator" ) SCFrame=false ScoreFrame:Close() end )
					menu123:Open()
			end  -- ending the doclick function
		
		local shopmenu = vgui.Create("DButton") -- Create the button
			shopmenu:SetParent( parent_frame ) -- parent the button to the frame
			shopmenu:SetText( "Shop Menu >" ) -- set the button text
			shopmenu:SetPos(120, 25) -- set the button position in the frame
			shopmenu:SetSize( 100, 20 ) -- set the button size
			shopmenu.DoClick = function() RunConsoleCommand( "pnrp_buy_shop" ) SCFrame=false parent_frame:Close() end 
			
		local invmenu = vgui.Create("DButton") -- Create the button
			invmenu:SetParent( parent_frame ) -- parent the button to the frame
			invmenu:SetText( "Inventory Menu >" ) -- set the button text
			invmenu:SetPos(220, 25) -- set the button position in the frame
			invmenu:SetSize( 100, 20 ) -- set the button size
			invmenu.DoClick = function() RunConsoleCommand( "pnrp_inv" ) SCFrame=false parent_frame:Close() end 
			
		local trademenu = vgui.Create("DButton") -- Create the button
			trademenu:SetParent( parent_frame ) -- parent the button to the frame
			trademenu:SetText( "Trade Menu >" ) -- set the button text
			trademenu:SetPos(320, 25) -- set the button position in the frame
			trademenu:SetSize( 100, 20 ) -- set the button size
			trademenu.DoClick = function() RunConsoleCommand( "pnrp_trade_window" ) SCFrame=false parent_frame:Close() end 	
			
		local adminmenu = vgui.Create("DButton") -- Create the button
			adminmenu:SetParent( parent_frame ) -- parent the button to the frame
			adminmenu:SetText( "Admin Menu >" ) -- set the button text
			adminmenu:SetPos(580, 25) -- set the button position in the frame
			adminmenu:SetSize( 100, 20 ) -- set the button size
			adminmenu.DoClick = function() RunConsoleCommand( "pnrp_admin_window" ) SCFrame=false parent_frame:Close() end 
end

function GM:ScoreboardHide()

	if SCFrame then
		ScoreFrame:Close()
	end
	return true
	
end

--EOF