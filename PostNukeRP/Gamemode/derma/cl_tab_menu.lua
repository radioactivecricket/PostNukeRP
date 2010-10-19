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
		
		local PlayerCount = table.getn( player.GetAll() )
		local PlayerCountTxt = vgui.Create("DLabel", ScoreFrame)		
			PlayerCountTxt:SetPos(580, 45 )
			PlayerCountTxt:SetText("Players Online: "..tostring(PlayerCount))
			PlayerCountTxt:SizeToContents() 
			
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
				
				local MemberOf
				MemberOf = idiot:GetNWString("community", "N/A")
				
				PlayerPanel.Community = vgui.Create("DLabel", PlayerPanel)
				PlayerPanel.Community:SetPos(90, 25)
				PlayerPanel.Community:SetText("Member of "..MemberOf)
				PlayerPanel.Community:SetColor(team.GetColor(idiot:Team()))
				PlayerPanel.Community:SizeToContents() 
		 		PlayerPanel.Community:SetContentAlignment( 5 )
		
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
				PlayerPanel.Ping:SetPos(575, 5)
				PlayerPanel.Ping:SetText("Ping: "..idiot:Ping())
				PlayerPanel.Ping:SetColor(team.GetColor(idiot:Team()))
				PlayerPanel.Ping:SizeToContents() 
		 		PlayerPanel.Ping:SetContentAlignment( 5 )
				
			end
	return true
end

function PNRP.buildMenu(parent_frame)
	
	local ply = LocalPlayer()

	classmenu = vgui.Create("DButton") -- Create the button 	
		classmenu:SetParent( parent_frame ) -- parent the button to the frame
		classmenu:SetText( "Class Menu >" ) -- set the button text
		classmenu:SetPos(20, 25) -- set the button position in the frame
		classmenu:SetSize( 100, 20 ) -- set the button size
		classmenu.DoClick = function() RunConsoleCommand( "pnrp_classmenu" ) SCFrame=false parent_frame:Close() end 
		
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
		
--		local PlyOptionsMnuBtn = vgui.Create("DButton")
--			PlyOptionsMnuBtn:SetParent( parent_frame )
--			PlyOptionsMnuBtn:SetText( "Player Options >>" )
--			PlyOptionsMnuBtn:SetPos(320, 25)
--			PlyOptionsMnuBtn:SetSize( 100, 20 )
--			PlyOptionsMnuBtn.DoClick = function ( btn )
--				local PlyOptionsMnuBtnOptions = DermaMenu() -- Creates the menu
--				PlyOptionsMnuBtnOptions:AddOption("Trade Menu", function() RunConsoleCommand( "pnrp_trade_window" ) SCFrame=false parent_frame:Close() end )
--				PlyOptionsMnuBtnOptions:AddOption("Equipment Menu", function() RunConsoleCommand( "pnrp_eqipment" ) SCFrame=false parent_frame:Close() end )
--				PlyOptionsMnuBtnOptions:Open()
--			end

		
		local trademenu = vgui.Create("DButton") -- Create the button
			trademenu:SetParent( parent_frame ) -- parent the button to the frame
			trademenu:SetText( "Trade Menu >" ) -- set the button text
			trademenu:SetPos(320, 25) -- set the button position in the frame
			trademenu:SetSize( 100, 20 ) -- set the button size
			trademenu.DoClick = function() RunConsoleCommand( "pnrp_trade_window" ) SCFrame=false parent_frame:Close() end 	
		
		local equipmentmenu = vgui.Create("DButton") -- Create the button
			equipmentmenu:SetParent( parent_frame ) -- parent the button to the frame
			equipmentmenu:SetText( "Equipment Menu >" ) -- set the button text
			equipmentmenu:SetPos(420, 25) -- set the button position in the frame
			equipmentmenu:SetSize( 100, 20 ) -- set the button size
			equipmentmenu.DoClick = function() RunConsoleCommand( "pnrp_eqipment" ) SCFrame=false parent_frame:Close() end		
		
--		local communitymenu = vgui.Create("DButton") -- Create the button
--			communitymenu:SetParent( parent_frame ) -- parent the button to the frame
--			communitymenu:SetText( "Community Menu >" ) -- set the button text
--			communitymenu:SetPos(420, 25) -- set the button position in the frame
--			communitymenu:SetSize( 100, 20 ) -- set the button size
--			communitymenu.DoClick = function() RunConsoleCommand( "pnrp_OpenCommunity" ) SCFrame=false parent_frame:Close() end	
		
		if ply:IsAdmin() then	
			local adminmenu = vgui.Create("DButton") -- Create the button
				adminmenu:SetParent( parent_frame ) -- parent the button to the frame
				adminmenu:SetText( "Admin Menu >" ) -- set the button text
				adminmenu:SetPos(580, 25) -- set the button position in the frame
				adminmenu:SetSize( 100, 20 ) -- set the button size
				adminmenu.DoClick = function() RunConsoleCommand( "pnrp_admin_window" ) SCFrame=false parent_frame:Close() end
		end		

		local menu2_frame = vgui.Create( "DFrame" )
			menu2_frame:SetParent( parent_frame )
			menu2_frame:SetSize( 110, 220 ) 
			menu2_frame:SetPos( ScrW() / 2 + parent_frame:GetWide() / 2 + 5, ScrH() / 2 - parent_frame:GetTall() / 2 )
			menu2_frame:SetTitle( " " )
			menu2_frame:SetVisible( true )
			menu2_frame:SetDraggable( true )
			menu2_frame:ShowCloseButton( false )
			menu2_frame:MakePopup()
			menu2_frame.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
			
			local menu2List = vgui.Create( "DPanelList", menu2_frame )
					menu2List:SetPos( 0,0 )
					menu2List:SetSize( menu2_frame:GetWide(), menu2_frame:GetTall() )
					menu2List:SetSpacing( 5 )
					menu2List:SetPadding( 5 )
					menu2List:EnableHorizontal( false ) 
					menu2List:EnableVerticalScrollbar( true ) 	
					
					local BlankLabel1 = vgui.Create("DLabel", menu2List	)
						BlankLabel1:SetColor( Color( 255, 255, 255, 0 ) )
						BlankLabel1:SetText( " " )
						BlankLabel1:SizeToContents()
						menu2List:AddItem( BlankLabel1 )
					local skillsmenu = vgui.Create("DButton") 
						skillsmenu:SetParent( menu2List ) 
						skillsmenu:SetText( "Skills Menu >" ) 
						skillsmenu:SetSize( 100, 20 ) 
						skillsmenu.DoClick = function() ply:ChatPrint("Skills not available yet.") SCFrame=false parent_frame:Close() end	
						menu2List:AddItem( skillsmenu )
					local communitymenu = vgui.Create("DButton") 
						communitymenu:SetParent( menu2List ) 
						communitymenu:SetText( "Community Menu >" ) 
						communitymenu:SetSize( 100, 20 ) 
						communitymenu.DoClick = function() RunConsoleCommand( "pnrp_OpenCommunity" ) SCFrame=false parent_frame:Close() end	
						menu2List:AddItem( communitymenu )
					local devide1menu2 = vgui.Create("DShape") 
						devide1menu2:SetParent( menu2List ) 
						devide1menu2:SetType("Rect")
						devide1menu2:SetSize( 100, 2 ) 	
						menu2List:AddItem( devide1menu2 )
					local sleepBtn = vgui.Create("DButton") 
						sleepBtn:SetParent( menu2List ) 
						sleepBtn:SetText( "Sleep" ) 
						sleepBtn:SetSize( 100, 20 ) 
						sleepBtn.DoClick = function() RunConsoleCommand( "pnrp_sleep" ) SCFrame=false parent_frame:Close() end	
						menu2List:AddItem( sleepBtn )
					local wakeBtn = vgui.Create("DButton") 
						wakeBtn:SetParent( menu2List ) 
						wakeBtn:SetText( "Wake" ) 
						wakeBtn:SetSize( 100, 20 ) 
						wakeBtn.DoClick = function() RunConsoleCommand( "pnrp_wake" ) SCFrame=false parent_frame:Close() end	
						menu2List:AddItem( wakeBtn )
					local gCarBtn = vgui.Create("DButton") 
						gCarBtn:SetParent( menu2List ) 
						gCarBtn:SetText( "Get Car" ) 
						gCarBtn:SetSize( 100, 20 ) 
						gCarBtn.DoClick = function() RunConsoleCommand( "pnrp_GetCar" ) SCFrame=false parent_frame:Close() end	
						menu2List:AddItem( gCarBtn )
					local gCarsBtn = vgui.Create("DButton") 
						gCarsBtn:SetParent( menu2List ) 
						gCarsBtn:SetText( "Get All Cars" ) 
						gCarsBtn:SetSize( 100, 20 ) 
						gCarsBtn.DoClick = function() RunConsoleCommand( "pnrp_GetAllCar" ) SCFrame=false parent_frame:Close() end	
						menu2List:AddItem( gCarsBtn )
					local saveBtn = vgui.Create("DButton") 
						saveBtn:SetParent( menu2List ) 
						saveBtn:SetText( "Save" ) 
						saveBtn:SetSize( 100, 20 ) 
						saveBtn.DoClick = function() RunConsoleCommand( "pnrp_save" ) SCFrame=false parent_frame:Close() end	
						menu2List:AddItem( saveBtn )
end

function GM:ScoreboardHide()

	if SCFrame then
		ScoreFrame:Close()
	end
	return true
	
end

--EOF