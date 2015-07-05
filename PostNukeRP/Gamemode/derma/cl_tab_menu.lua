local ScoreFrame
local SCFrame = false

function GM:ScoreboardShow()
	SCFrame = true
	
	local ply = LocalPlayer()
	ScoreFrame = vgui.Create( "DFrame" )
		ScoreFrame:SetSize( 710, 720 ) --Set the size
		--frame:SetPos( ScrW() / 2, ScrH() / 2 ) --Set the window in the middle of the players screen/game window
		ScoreFrame:SetPos(ScrW() / 2 - ScoreFrame:GetWide() / 2, ScrH() / 2 - ScoreFrame:GetTall() / 2)
		ScoreFrame:SetTitle( "Score Frame" ) --Set title
		ScoreFrame:SetVisible( true )
		ScoreFrame:SetDraggable( false )
		ScoreFrame:ShowCloseButton( false )
		ScoreFrame:MakePopup()
		ScoreFrame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local myImage = vgui.Create("DImage", ScoreFrame)
			myImage:SetImage( "VGUI/gfx/pnrp_screen_1.png" )
			myImage:SetSize(ScoreFrame:GetWide(), ScoreFrame:GetTall())
		
		PNRP.buildMenu(ScoreFrame)
		
		local PlayerCount = table.getn( player.GetAll() )
		local PlayerCountTxt = vgui.Create("DLabel", ScoreFrame)		
			PlayerCountTxt:SetPos(550, 37)
			PlayerCountTxt:SetText("Players Online: "..tostring(PlayerCount))
			PlayerCountTxt:SetColor(Color( 0, 255, 0, 255 ))
			PlayerCountTxt:SizeToContents() 
			
		local PlayerList = vgui.Create("DPanelList", ScoreFrame)
			PlayerList:SetPos(40, 60)
			PlayerList:SetSize(ScoreFrame:GetWide() - 85, ScoreFrame:GetTall() - 105)
			PlayerList:EnableVerticalScrollbar(true) 
			PlayerList:EnableHorizontal(false) 
			PlayerList:SetSpacing(1)
			PlayerList:SetPadding(10)
			PlayerList.Paint = function()
			--	draw.RoundedBox( 8, 0, 0, PlayerList:GetWide(), PlayerList:GetTall(), Color( 50, 50, 50, 255 ) )
			end
			
			for _, idiot in pairs(player.GetAll()) do
	
	
				local PlayerPanel = vgui.Create("DPanel")
				PlayerPanel:SetTall(75)
				PlayerPanel.Paint = function()
				
					draw.RoundedBox( 6, 0, 0, PlayerPanel:GetWide(), PlayerPanel:GetTall(), Color( 180, 180, 180, 180 ) )		
			
				end
				PlayerList:AddItem(PlayerPanel)
		
				
				PlayerPanel.Icon = vgui.Create("SpawnIcon", PlayerPanel)
				PlayerPanel.Icon:SetModel(idiot:GetModel())
				PlayerPanel.Icon:SetPos(3, 3)
				PlayerPanel.Icon:SetToolTip( nil )
				PlayerPanel.Icon.DoClick = function()
					net.Start("start_openPlayerInfoWindow")
						net.WriteEntity(ply)
						net.WriteEntity(idiot)
					net.SendToServer()
					SCFrame=false 
					ScoreFrame:Close() 
				end 
			
				PlayerPanel.Title = vgui.Create("DLabel", PlayerPanel)
				PlayerPanel.Title:SetPos(90, 5)
				local dispName
				if idiot:SteamName() == idiot:Nick() then
					dispName = idiot:SteamName() 
				else
					dispName = idiot:Nick().." ("..idiot:SteamName()..")"
				end
				PlayerPanel.Title:SetText(dispName)
				PlayerPanel.Title:SetColor(team.GetColor(idiot:Team()))
				PlayerPanel.Title:SizeToContents() 
		 		PlayerPanel.Title:SetContentAlignment( 5 )
				
				local MemberOf
				MemberOf = idiot:GetNetVar("community", "N/A")
				
				PlayerPanel.Community = vgui.Create("DLabel", PlayerPanel)
				PlayerPanel.Community:SetPos(90, 25)
				PlayerPanel.Community:SetText("Member of "..MemberOf)
				PlayerPanel.Community:SetColor(team.GetColor(idiot:Team()))
				PlayerPanel.Community:SizeToContents() 
		 		PlayerPanel.Community:SetContentAlignment( 5 )
				
				PlayerPanel.Title = vgui.Create("DLabel", PlayerPanel)
				PlayerPanel.Title:SetPos(90, 40)
				PlayerPanel.Title:SetText(idiot:GetNetVar("ctitle", " "))
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
				PlayerPanel.Ping:SetPos(480, 5)
				PlayerPanel.Ping:SetText("Ping: "..idiot:Ping())
				PlayerPanel.Ping:SetColor(team.GetColor(idiot:Team()))
				PlayerPanel.Ping:SizeToContents() 
		 		PlayerPanel.Ping:SetContentAlignment( 5 )
				
			end
	return true
end

function PNRP.buildMenu(parent_frame)
	
	local ply = LocalPlayer()
	local MarginTop = 35
	local MarginLeft = 45
	local ButtonWidth = 100
	local btnSpacing = MarginLeft
	classmenu = vgui.Create("DButton") -- Create the button 	
		classmenu:SetParent( parent_frame ) -- parent the button to the frame
		classmenu:SetText( "Class Menu >" ) -- set the button text
		classmenu:SetPos(btnSpacing, MarginTop) -- set the button position in the frame
		classmenu:SetSize( ButtonWidth, 20 ) -- set the button size
		classmenu.DoClick = function() RunConsoleCommand( "pnrp_classmenu" ) SCFrame=false parent_frame:Close() end 
		
		btnSpacing = btnSpacing + ButtonWidth
		local shopmenu = vgui.Create("DButton") -- Create the button
			shopmenu:SetParent( parent_frame ) -- parent the button to the frame
			shopmenu:SetText( "Shop Menu >" ) -- set the button text
			shopmenu:SetPos(btnSpacing, MarginTop) -- set the button position in the frame
			shopmenu:SetSize( ButtonWidth, 20 ) -- set the button size
			shopmenu.DoClick = function() RunConsoleCommand( "pnrp_buy_shop" ) SCFrame=false parent_frame:Close() end 
		
		btnSpacing = btnSpacing + ButtonWidth	
		local invmenu = vgui.Create("DButton") -- Create the button
			invmenu:SetParent( parent_frame ) -- parent the button to the frame
			invmenu:SetText( "Inventory Menu >" ) -- set the button text
			invmenu:SetPos(btnSpacing, MarginTop) -- set the button position in the frame
			invmenu:SetSize( ButtonWidth, 20 ) -- set the button size
			invmenu.DoClick = function() RunConsoleCommand( "pnrp_inv" ) SCFrame=false parent_frame:Close() end 
		
		btnSpacing = btnSpacing + ButtonWidth
		local trademenu = vgui.Create("DButton") -- Create the button
			trademenu:SetParent( parent_frame ) -- parent the button to the frame
			trademenu:SetText( "Trade Menu >" ) -- set the button text
			trademenu:SetPos(btnSpacing, MarginTop) -- set the button position in the frame
			trademenu:SetSize( ButtonWidth, 20 ) -- set the button size
			trademenu.DoClick = function() RunConsoleCommand( "pnrp_trade_window" ) SCFrame=false parent_frame:Close() end 	
		
		btnSpacing = btnSpacing + ButtonWidth
		local equipmentmenu = vgui.Create("DButton") -- Create the button
			equipmentmenu:SetParent( parent_frame ) -- parent the button to the frame
			equipmentmenu:SetText( "Equipment Menu >" ) -- set the button text
			equipmentmenu:SetPos(btnSpacing, MarginTop) -- set the button position in the frame
			equipmentmenu:SetSize( ButtonWidth, 20 ) -- set the button size
			equipmentmenu.DoClick = function() RunConsoleCommand( "pnrp_eqipment" ) SCFrame=false parent_frame:Close() end		
		
--		btnSpacing = btnSpacing + ButtonWidth
--		if ply:IsAdmin() then	
--			local adminmenu = vgui.Create("DButton") -- Create the button
--				adminmenu:SetParent( parent_frame ) -- parent the button to the frame
--				adminmenu:SetText( "Admin Menu >" ) -- set the button text
--				adminmenu:SetPos(btnSpacing + 5, MarginTop) -- set the button position in the frame
--				adminmenu:SetSize( ButtonWidth, 20 ) -- set the button size
--				adminmenu.DoClick = function() RunConsoleCommand( "pnrp_admin_window" ) SCFrame=false parent_frame:Close() end
--		end		
		
		sideMenu(parent_frame)
		--[[
		local menuH = 260
		--Add space needed for Admin Button
		if ply:IsAdmin() then
			menuH = 285
		end
		
		local menu2_frame = vgui.Create( "DFrame" )
			menu2_frame:SetParent( parent_frame )
			menu2_frame:SetSize( 125, menuH ) 
			menu2_frame:SetPos( ScrW() / 2 + parent_frame:GetWide() / 2 + 5, ScrH() / 2 - parent_frame:GetTall() / 2 )
			menu2_frame:SetTitle( " " )
			menu2_frame:SetVisible( true )
			menu2_frame:SetDraggable( true )
			menu2_frame:ShowCloseButton( false )
			menu2_frame:MakePopup()
			menu2_frame.Paint = function( ) 
				draw.RoundedBox( 8, 0, 0, menu2_frame:GetWide(), menu2_frame:GetTall(), Color( 50, 50, 50, 0 ) )
			end
	
			local vlimit
			local vlimitColor
			if GetConVarNumber("pnrp_voiceLimit") == 1 then
				vlimit = "On"
				vlimitColor = Color( 0, 255, 0, 255 )
			else
				vlimit = "Off"
				vlimitColor = Color( 255, 0, 0, 255 )
			end
			
			local pcost
			local pcostColor
			if GetConVarNumber("pnrp_propPay") == 1 then
				pcostColor = Color( 0, 255, 0, 255 )
				pcost = "On @ "..GetConVarNumber("pnrp_propCost").."%"
			else
				pcostColor = Color( 255, 0, 0, 255 )
				pcost = "Off"
			end
			
			local menu2List = vgui.Create( "DPanelList", menu2_frame )
					menu2List:SetPos( 0,0 )
				--	menu2List:SetSize( menu2_frame:GetWide(), menu2_frame:GetTall() )
					menu2List:SetWide( menu2_frame:GetWide())
					menu2List:SetSpacing( 5 )
					menu2List:SetPadding( 5 )
					menu2List:EnableHorizontal( false ) 
					menu2List:EnableVerticalScrollbar( true ) 
					menu2List:SetAutoSize(true)	
					menu2List.Paint = function()
						draw.RoundedBox( 8, 0, 0, menu2List:GetWide(), menu2List:GetTall(), Color( 50, 50, 50, 255 ) )
					end
					
					local VoiceLimiterLabel = vgui.Create("DLabel", menu2List	)
						VoiceLimiterLabel:SetColor( vlimitColor )
						VoiceLimiterLabel:SetText( "Voice Limiter: "..vlimit )
						VoiceLimiterLabel:SizeToContents()
						menu2List:AddItem( VoiceLimiterLabel )
					local PCostLabel = vgui.Create("DLabel", menu2List	)
						PCostLabel:SetColor( pcostColor )
						PCostLabel:SetText( "Prop Cost: "..pcost )
						PCostLabel:SizeToContents()
						menu2List:AddItem( PCostLabel )					
					
					if ply:IsAdmin() then
						local devide1menu2adm = vgui.Create("DShape") 
							devide1menu2adm:SetParent( menu2List ) 
							devide1menu2adm:SetType("Rect")
							devide1menu2adm:SetSize( 100, 2 ) 	
							menu2List:AddItem( devide1menu2adm )
						local adminmenu = vgui.Create("DButton") 
							adminmenu:SetParent( menu2List ) 
							adminmenu:SetText( "Admin Menu >" ) 
							adminmenu:SetSize( 100, 20 ) 
							adminmenu.DoClick = function() RunConsoleCommand( "pnrp_admin_window" ) SCFrame=false parent_frame:Close() end
							menu2List:AddItem( adminmenu )
					end
					local devide1menu2a = vgui.Create("DShape") 
						devide1menu2a:SetParent( menu2List ) 
						devide1menu2a:SetType("Rect")
						devide1menu2a:SetSize( 100, 2 ) 	
						menu2List:AddItem( devide1menu2a )
					local skillsmenu = vgui.Create("DButton") 
						skillsmenu:SetParent( menu2List ) 
						skillsmenu:SetText( "Player Profile >" ) 
						skillsmenu:SetSize( 100, 20 ) 
					--	skillsmenu.DoClick = function() RunConsoleCommand( "pnrp_skills" ) SCFrame=false parent_frame:Close() end
						skillsmenu.DoClick = function() RunConsoleCommand( "pnrp_playerprofile" ) SCFrame=false parent_frame:Close() end
						menu2List:AddItem( skillsmenu )
					local communitymenu = vgui.Create("DButton") 
						communitymenu:SetParent( menu2List ) 
						communitymenu:SetText( "Community Menu >" ) 
						communitymenu:SetSize( 100, 20 ) 
						communitymenu.DoClick = function() RunConsoleCommand( "pnrp_OpenCommunity" ) SCFrame=false parent_frame:Close() end	
						menu2List:AddItem( communitymenu )
					local buddymenu = vgui.Create("DButton") 
						buddymenu:SetParent( menu2List ) 
						buddymenu:SetText( "Buddy Menu >" ) 
						buddymenu:SetSize( 100, 20 ) 
						buddymenu.DoClick = function() RunConsoleCommand( "pnrp_buddy_window" ) SCFrame=false parent_frame:Close() end	
						menu2List:AddItem( buddymenu )
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
		]]--
end

function sideMenu(parent_frame)
	local ply = LocalPlayer()
	local menu2_frame = vgui.Create( "DFrame" )
		menu2_frame:SetParent( parent_frame )
		menu2_frame:SetSize( 180, 450 ) 
		menu2_frame:SetPos( ScrW() / 2 + parent_frame:GetWide() / 2 + 5, ScrH() / 2 - parent_frame:GetTall() / 2 )
		menu2_frame:SetTitle( " " )
		menu2_frame:SetVisible( true )
		menu2_frame:SetDraggable( true )
		menu2_frame:ShowCloseButton( false )
		menu2_frame:MakePopup()
		menu2_frame.Paint = function( ) 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local menu2BG = vgui.Create("DImage", menu2_frame)
			menu2BG:SetImage( "VGUI/gfx/pnrp_screen_7b.png" )
			menu2BG:SetSize(menu2_frame:GetWide(), menu2_frame:GetTall())
			
		local vlimit
		local vlimitColor
		if GetConVarNumber("pnrp_voiceLimit") == 1 then
			vlimit = "On"
			vlimitColor = Color( 0, 255, 0, 255 )
		else
			vlimit = "Off"
			vlimitColor = Color( 255, 0, 0, 255 )
		end
		
		local pcost
		local pcostColor
		if GetConVarNumber("pnrp_propPay") == 1 then
			pcostColor = Color( 0, 255, 0, 255 )
			pcost = "On @ "..GetConVarNumber("pnrp_propCost").."%"
		else
			pcostColor = Color( 255, 0, 0, 255 )
			pcost = "Off"
		end	
		
		local VoiceLimiterLabel = vgui.Create("DLabel", menu2_frame	)
			VoiceLimiterLabel:SetPos(40,40)
			VoiceLimiterLabel:SetColor( vlimitColor )
			VoiceLimiterLabel:SetText( "Voice Limiter: "..vlimit )
			VoiceLimiterLabel:SizeToContents()
			
		local PCostLabel = vgui.Create("DLabel", menu2_frame )
			PCostLabel:SetPos(40,60)
			PCostLabel:SetColor( pcostColor )
			PCostLabel:SetText( "Prop Cost: "..pcost )
			PCostLabel:SizeToContents()
		
		local btnHPos = 125
		local btnWPos = 10
		local btnHeight = 30
		local lblColor = Color( 245, 228, 220, 180 )
		local menuFont = "HudHintTextLarge"
		local devideW = 150
		
		if ply:IsAdmin() then	
			local adminmenuBtn = vgui.Create("DImageButton", menu2_frame)
				adminmenuBtn:SetPos( btnWPos,btnHPos )
				adminmenuBtn:SetSize(25,25)
				adminmenuBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				adminmenuBtn.DoClick = function() 
					RunConsoleCommand( "pnrp_admin_window" ) 
					SCFrame=false 
					parent_frame:Close()
				end
				adminmenuBtn.Paint = function()
					if adminmenuBtn:IsDown() then 
						adminmenuBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						adminmenuBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end	
			local adminmenuBtnLbl = vgui.Create("DLabel", menu2_frame)
				adminmenuBtnLbl:SetPos( btnWPos+35,btnHPos+5 )
				adminmenuBtnLbl:SetColor( lblColor )
				adminmenuBtnLbl:SetText( "Admin Menu" )
				adminmenuBtnLbl:SetFont(menuFont)
				adminmenuBtnLbl:SizeToContents()	
			btnHPos = btnHPos + btnHeight
			local devide1menu2a = vgui.Create("DShape") 
				devide1menu2a:SetParent( menu2_frame ) 
				devide1menu2a:SetPos( btnWPos,btnHPos )
				devide1menu2a:SetType("Rect")
				devide1menu2a:SetSize( devideW, 2 ) 
			btnHPos = btnHPos + 10
		end
		
		local skillsmenuBtn = vgui.Create("DImageButton", menu2_frame)
			skillsmenuBtn:SetPos( btnWPos,btnHPos )
			skillsmenuBtn:SetSize(25,25)
			skillsmenuBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			skillsmenuBtn.DoClick = function() 
				RunConsoleCommand( "pnrp_playerprofile" ) 
				SCFrame=false 
				parent_frame:Close()
			end
			skillsmenuBtn.Paint = function()
				if skillsmenuBtn:IsDown() then 
					skillsmenuBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					skillsmenuBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local skillsmenuBtnLbl = vgui.Create("DLabel", menu2_frame)
			skillsmenuBtnLbl:SetPos( btnWPos+35,btnHPos+5 )
			skillsmenuBtnLbl:SetColor( lblColor )
			skillsmenuBtnLbl:SetText( "Player Profile" )
			skillsmenuBtnLbl:SetFont(menuFont)
			skillsmenuBtnLbl:SizeToContents()	
		btnHPos = btnHPos + btnHeight
	
		local communitymenuBtn = vgui.Create("DImageButton", menu2_frame)
			communitymenuBtn:SetPos( btnWPos,btnHPos )
			communitymenuBtn:SetSize(25,25)
			communitymenuBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			communitymenuBtn.DoClick = function() 
				RunConsoleCommand( "pnrp_OpenCommunity" ) 
				SCFrame=false 
				parent_frame:Close()
			end
			communitymenuBtn.Paint = function()
				if communitymenuBtn:IsDown() then 
					communitymenuBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					communitymenuBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local communitymenuBtnLbl = vgui.Create("DLabel", menu2_frame)
			communitymenuBtnLbl:SetPos( btnWPos+35,btnHPos+5 )
			communitymenuBtnLbl:SetColor( lblColor )
			communitymenuBtnLbl:SetText( "Community Menu" )
			communitymenuBtnLbl:SetFont(menuFont)
			communitymenuBtnLbl:SizeToContents()	
		btnHPos = btnHPos + btnHeight
		
		local buddymenuBtn = vgui.Create("DImageButton", menu2_frame)
			buddymenuBtn:SetPos( btnWPos,btnHPos )
			buddymenuBtn:SetSize(25,25)
			buddymenuBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			buddymenuBtn.DoClick = function() 
				RunConsoleCommand( "pnrp_buddy_window" ) 
				SCFrame=false 
				parent_frame:Close()
			end
			buddymenuBtn.Paint = function()
				if buddymenuBtn:IsDown() then 
					buddymenuBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					buddymenuBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local buddymenuBtnLbl = vgui.Create("DLabel", menu2_frame)
			buddymenuBtnLbl:SetPos( btnWPos+35,btnHPos+5 )
			buddymenuBtnLbl:SetColor( lblColor )
			buddymenuBtnLbl:SetText( "Buddy Menu" )
			buddymenuBtnLbl:SetFont(menuFont)
			buddymenuBtnLbl:SizeToContents()	
		btnHPos = btnHPos + btnHeight
		
		local devide1menu2b = vgui.Create("DShape") 
			devide1menu2b:SetParent( menu2_frame ) 
			devide1menu2b:SetPos( btnWPos,btnHPos )
			devide1menu2b:SetType("Rect")
			devide1menu2b:SetSize( devideW, 2 ) 
		btnHPos = btnHPos + 10
		
		local sleepBtn = vgui.Create("DImageButton", menu2_frame)
			sleepBtn:SetPos( btnWPos,btnHPos )
			sleepBtn:SetSize(25,25)
			sleepBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			sleepBtn.DoClick = function() 
				RunConsoleCommand( "pnrp_sleep" ) 
				SCFrame=false 
				parent_frame:Close()
			end
			sleepBtn.Paint = function()
				if sleepBtn:IsDown() then 
					sleepBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					sleepBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local sleepBtnLbl = vgui.Create("DLabel", menu2_frame)
			sleepBtnLbl:SetPos( btnWPos+35,btnHPos+5 )
			sleepBtnLbl:SetColor( lblColor )
			sleepBtnLbl:SetText( "Sleep" )
			sleepBtnLbl:SetFont(menuFont)
			sleepBtnLbl:SizeToContents()	
		btnHPos = btnHPos + btnHeight
		
		local wakeBtn = vgui.Create("DImageButton", menu2_frame)
			wakeBtn:SetPos( btnWPos,btnHPos )
			wakeBtn:SetSize(25,25)
			wakeBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			wakeBtn.DoClick = function() 
				RunConsoleCommand( "pnrp_wake" ) 
				SCFrame=false 
				parent_frame:Close()
			end
			wakeBtn.Paint = function()
				if wakeBtn:IsDown() then 
					wakeBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					wakeBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local wakeBtnLbl = vgui.Create("DLabel", menu2_frame)
			wakeBtnLbl:SetPos( btnWPos+35,btnHPos+5 )
			wakeBtnLbl:SetColor( lblColor )
			wakeBtnLbl:SetText( "Wake" )
			wakeBtnLbl:SetFont(menuFont)
			wakeBtnLbl:SizeToContents()	
		btnHPos = btnHPos + btnHeight
		
		local gCarBtn = vgui.Create("DImageButton", menu2_frame)
			gCarBtn:SetPos( btnWPos,btnHPos )
			gCarBtn:SetSize(25,25)
			gCarBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			gCarBtn.DoClick = function() 
				RunConsoleCommand( "pnrp_GetCar" ) 
				SCFrame=false 
				parent_frame:Close()
			end
			gCarBtn.Paint = function()
				if gCarBtn:IsDown() then 
					gCarBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					gCarBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local gCarBtnLbl = vgui.Create("DLabel", menu2_frame)
			gCarBtnLbl:SetPos( btnWPos+35,btnHPos+5 )
			gCarBtnLbl:SetColor( lblColor )
			gCarBtnLbl:SetText( "Get Car" )
			gCarBtnLbl:SetFont(menuFont)
			gCarBtnLbl:SizeToContents()	
		btnHPos = btnHPos + btnHeight
		
		local gCarsBtn = vgui.Create("DImageButton", menu2_frame)
			gCarsBtn:SetPos( btnWPos,btnHPos )
			gCarsBtn:SetSize(25,25)
			gCarsBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			gCarsBtn.DoClick = function() 
				RunConsoleCommand( "pnrp_GetAllCar" ) 
				SCFrame=false 
				parent_frame:Close()
			end
			gCarsBtn.Paint = function()
				if gCarsBtn:IsDown() then 
					gCarsBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					gCarsBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local gCarsBtnLbl = vgui.Create("DLabel", menu2_frame)
			gCarsBtnLbl:SetPos( btnWPos+35,btnHPos+5 )
			gCarsBtnLbl:SetColor( lblColor )
			gCarsBtnLbl:SetText( "Get All Cars" )
			gCarsBtnLbl:SetFont(menuFont)
			gCarsBtnLbl:SizeToContents()	
		btnHPos = btnHPos + btnHeight
		
		local saveBtn = vgui.Create("DImageButton", menu2_frame)
			saveBtn:SetPos( btnWPos,btnHPos )
			saveBtn:SetSize(25,25)
			saveBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			saveBtn.DoClick = function() 
				RunConsoleCommand( "pnrp_save" ) 
				SCFrame=false 
				parent_frame:Close()
			end
			saveBtn.Paint = function()
				if saveBtn:IsDown() then 
					saveBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					saveBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local saveBtnLbl = vgui.Create("DLabel", menu2_frame)
			saveBtnLbl:SetPos( btnWPos+35,btnHPos+5 )
			saveBtnLbl:SetColor( lblColor )
			saveBtnLbl:SetText( "Save" )
			saveBtnLbl:SetFont(menuFont)
			saveBtnLbl:SizeToContents()	
		btnHPos = btnHPos + btnHeight
end

function GM:ScoreboardHide()

	if SCFrame then
		ScoreFrame:Close()
	end
	return true
	
end


--EOF