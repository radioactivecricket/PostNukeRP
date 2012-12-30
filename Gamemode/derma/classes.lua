

local class_Frame

function PNRP.ClassMenu(ply)
	if ply:InVehicle() then
		ply:ChatPrint("Can not change classes while in a vehicle.")
		return
	end
	class_Frame = vgui.Create( "DFrame" )
		class_Frame:SetSize( 710, 510 ) --Set the size
		class_Frame:SetPos(ScrW() / 2 - class_Frame:GetWide() / 2, ScrH() / 2 - class_Frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
		class_Frame:SetTitle( "Class Selection Menu" ) --Set title
		class_Frame:SetVisible( true )
		class_Frame:SetDraggable( true )
		class_Frame:ShowCloseButton( true )
		class_Frame:MakePopup()
		class_Frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", class_Frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_2b.png" )
			screenBG:SetSize(class_Frame:GetWide(), class_Frame:GetTall())
		PNRP.buildMenu(class_Frame)
		
		local InfoFrame = vgui.Create( "DLabel", class_Frame )
		InfoFrame:SetPos(85,60)
		InfoFrame:SetColor(Color( 0, 175, 0, 255 ))
		local changeCost
		if GetConVar("pnrp_classChangePay"):GetInt() == 1 then
			changeCost = "Class change cost is ON and will cost "..GetConVar("pnrp_classChangeCost"):GetInt().."% of your resources." 
		else 
			changeCost = "Class change cost is OFF." 
		end
		InfoFrame:SetText( changeCost )
		InfoFrame:SizeToContents()
		
		local PropertySheet = vgui.Create( "DPropertySheet" )
			PropertySheet:SetParent( class_Frame )
			PropertySheet:SetPos( 40, 60 )
			PropertySheet:SetSize( class_Frame:GetWide() - 85 , class_Frame:GetTall() - 80 )
			PropertySheet.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
			
			local pnlList = vgui.Create("DPanelList", PropertySheet)
				pnlList:SetPos(10, 10)
				pnlList:SetSize(PropertySheet:GetWide() - 20, PropertySheet:GetTall() - 20)
				pnlList:EnableVerticalScrollbar(true) 
				pnlList:EnableHorizontal(false) 
				pnlList:SetSpacing(1)
				pnlList:SetPadding(10)
			--	pnlList.Paint = function()
			--		draw.RoundedBox( 8, 0, 0, pnlList:GetWide(), pnlList:GetTall(), Color( 50, 50, 50, 255 ) )
			--	end
				
				local wastelanderPanel = vgui.Create("DPanel")
				wastelanderPanel:SetTall(75)
				wastelanderPanel.Paint = function()
				
					draw.RoundedBox( 6, 0, 0, wastelanderPanel:GetWide(), wastelanderPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
			
				end
				pnlList:AddItem(wastelanderPanel)
				
				wastelanderPanel.Icon = vgui.Create("SpawnIcon", wastelanderPanel)
				wastelanderPanel.Icon:SetModel("models/items/hevsuit.mdl")
				wastelanderPanel.Icon:SetPos(3, 5)
				wastelanderPanel.Icon:SetToolTip( nil )
				wastelanderPanel.Icon.DoClick = function()
						RunConsoleCommand( "team_set_wastelander" )
						class_Frame:Close()
				end	
												
				wastelanderPanel.Title = vgui.Create("DLabel", wastelanderPanel)
				wastelanderPanel.Title:SetPos(90, 5)
				wastelanderPanel.Title:SetText("The Wastelander")
				wastelanderPanel.Title:SetColor(team.GetColor(TEAM_WASTELANDER))
				wastelanderPanel.Title:SizeToContents() 
		 		wastelanderPanel.Title:SetContentAlignment( 5 )
		 		
		 		wastelanderPanel.Info1 = vgui.Create("DLabel", wastelanderPanel)
				wastelanderPanel.Info1:SetPos(200, 5)
				wastelanderPanel.Info1:SetText("The Tank of the classes.")
				wastelanderPanel.Info1:SetColor(Color( 0, 0, 0, 255 ))
				wastelanderPanel.Info1:SizeToContents() 
		 		wastelanderPanel.Info1:SetContentAlignment( 5 )
		 		wastelanderPanel.Info2 = vgui.Create("DLabel", wastelanderPanel)
				wastelanderPanel.Info2:SetPos(215, 22)
				wastelanderPanel.Info2:SetText("Bonus to Health (Starts at 150HP)")
				wastelanderPanel.Info2:SetColor(Color( 0, 0, 0, 255 ))
				wastelanderPanel.Info2:SizeToContents() 
		 		wastelanderPanel.Info2:SetContentAlignment( 5 )
		 		wastelanderPanel.Info3 = vgui.Create("DLabel", wastelanderPanel)
				wastelanderPanel.Info3:SetPos(215, 34)
				wastelanderPanel.Info3:SetText("Bonus to Endurance")
				wastelanderPanel.Info3:SetColor(Color( 0, 0, 0, 255 ))
				wastelanderPanel.Info3:SizeToContents() 
		 		wastelanderPanel.Info3:SetContentAlignment( 5 )
		 		wastelanderPanel.Info4 = vgui.Create("DLabel", wastelanderPanel)
				wastelanderPanel.Info4:SetPos(215, 46)
				wastelanderPanel.Info4:SetText("Bonus to Salvage")
				wastelanderPanel.Info4:SetColor(Color( 0, 0, 0, 255 ))
				wastelanderPanel.Info4:SizeToContents() 
		 		wastelanderPanel.Info4:SetContentAlignment( 5 )	
		 		
		 		
		 		local scavengerPanel = vgui.Create("DPanel")
				scavengerPanel:SetTall(75)
				scavengerPanel.Paint = function()
				
					draw.RoundedBox( 6, 0, 0, scavengerPanel:GetWide(), scavengerPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
			
				end
				pnlList:AddItem(scavengerPanel)
				
				scavengerPanel.Icon = vgui.Create("SpawnIcon", scavengerPanel)
				scavengerPanel.Icon:SetModel("models/weapons/w_knife_t.mdl")
				scavengerPanel.Icon:SetPos(3, 5)
				scavengerPanel.Icon:SetToolTip( nil )
				scavengerPanel.Icon.DoClick = function()
						RunConsoleCommand( "team_set_scavenger" )
						class_Frame:Close()
				end	
												
				scavengerPanel.Title = vgui.Create("DLabel", scavengerPanel)
				scavengerPanel.Title:SetPos(90, 5)
				scavengerPanel.Title:SetText("The Scavenger")
				scavengerPanel.Title:SetColor(team.GetColor(TEAM_SCAVENGER))
				scavengerPanel.Title:SizeToContents() 
		 		scavengerPanel.Title:SetContentAlignment( 5 )

		 		scavengerPanel.Info1 = vgui.Create("DLabel", scavengerPanel)
				scavengerPanel.Info1:SetPos(200, 5)
				scavengerPanel.Info1:SetText("The Scout Class.")
				scavengerPanel.Info1:SetColor(Color( 0, 0, 0, 255 ))
				scavengerPanel.Info1:SizeToContents() 
		 		scavengerPanel.Info1:SetContentAlignment( 5 )
		 		scavengerPanel.Info2 = vgui.Create("DLabel", scavengerPanel)
				scavengerPanel.Info2:SetPos(215, 22)
				scavengerPanel.Info2:SetText("Bonus to Run Speed")
				scavengerPanel.Info2:SetColor(Color( 0, 0, 0, 255 ))
				scavengerPanel.Info2:SizeToContents() 
		 		scavengerPanel.Info2:SetContentAlignment( 5 )
		 		scavengerPanel.Info3 = vgui.Create("DLabel", scavengerPanel)
				scavengerPanel.Info3:SetPos(215, 34)
				scavengerPanel.Info3:SetText("Bonus to Gathering Speed")
				scavengerPanel.Info3:SetColor(Color( 0, 0, 0, 255 ))
				scavengerPanel.Info3:SizeToContents() 
		 		scavengerPanel.Info3:SetContentAlignment( 5 )	
		 		scavengerPanel.Info4 = vgui.Create("DLabel", scavengerPanel)
				scavengerPanel.Info4:SetPos(215, 46)
				scavengerPanel.Info4:SetText("Reduced Max HP (75 HP)")
				scavengerPanel.Info4:SetColor(Color( 0, 0, 0, 255 ))
				scavengerPanel.Info4:SizeToContents() 
		 		scavengerPanel.Info4:SetContentAlignment( 5 )	 
		 		scavengerPanel.Info5 = vgui.Create("DLabel", scavengerPanel)
				scavengerPanel.Info5:SetPos(215, 58)
				scavengerPanel.Info5:SetText("Bonus to Salvage")
				scavengerPanel.Info5:SetColor(Color( 0, 0, 0, 255 ))
				scavengerPanel.Info5:SizeToContents() 
		 		scavengerPanel.Info5:SetContentAlignment( 5 )		
		 		
		 		local sciencePanel = vgui.Create("DPanel")
				sciencePanel:SetTall(75)
				sciencePanel.Paint = function()
				
					draw.RoundedBox( 6, 0, 0, sciencePanel:GetWide(), sciencePanel:GetTall(), Color( 180, 180, 180, 255 ) )		
			
				end
				pnlList:AddItem(sciencePanel)
				
				sciencePanel.Icon = vgui.Create("SpawnIcon", sciencePanel)
				sciencePanel.Icon:SetModel("models/items/healthkit.mdl")
				sciencePanel.Icon:SetPos(3, 5)
				sciencePanel.Icon:SetToolTip( nil )
				sciencePanel.Icon.DoClick = function()
						 RunConsoleCommand( "team_set_science" )
						class_Frame:Close()
				end	
												
				sciencePanel.Title = vgui.Create("DLabel", sciencePanel)
				sciencePanel.Title:SetPos(90, 5)
				sciencePanel.Title:SetText("The Scientist")
				sciencePanel.Title:SetColor(team.GetColor(TEAM_SCIENCE))
				sciencePanel.Title:SizeToContents() 
		 		sciencePanel.Title:SetContentAlignment( 5 )
		 		
		 		sciencePanel.Info1 = vgui.Create("DLabel", sciencePanel)
				sciencePanel.Info1:SetPos(200, 5)
				sciencePanel.Info1:SetText("The Healer, among other things....")
				sciencePanel.Info1:SetColor(Color( 0, 0, 0, 255 ))
				sciencePanel.Info1:SizeToContents() 
		 		sciencePanel.Info1:SetContentAlignment( 5 )
		 		sciencePanel.Info2 = vgui.Create("DLabel", sciencePanel)
				sciencePanel.Info2:SetPos(215, 22)
				sciencePanel.Info2:SetText("Able to create Health Kits")
				sciencePanel.Info2:SetColor(Color( 0, 0, 0, 255 ))
				sciencePanel.Info2:SizeToContents() 
		 		sciencePanel.Info2:SetContentAlignment( 5 )
		 		sciencePanel.Info3 = vgui.Create("DLabel", sciencePanel)
				sciencePanel.Info3:SetPos(215, 34)
				sciencePanel.Info3:SetText("Able to create Armor Batteries")
				sciencePanel.Info3:SetColor(Color( 0, 0, 0, 255 ))
				sciencePanel.Info3:SizeToContents() 
		 		sciencePanel.Info3:SetContentAlignment( 5 )	
		 		sciencePanel.Info4 = vgui.Create("DLabel", sciencePanel)
				sciencePanel.Info4:SetPos(215, 46)
				sciencePanel.Info4:SetText("Able to create Explosives")
				sciencePanel.Info4:SetColor(Color( 0, 0, 0, 255 ))
				sciencePanel.Info4:SizeToContents() 
		 		sciencePanel.Info4:SetContentAlignment( 5 )	
		 		sciencePanel.Info5 = vgui.Create("DLabel", sciencePanel)
				sciencePanel.Info5:SetPos(215, 58)
				sciencePanel.Info5:SetText("Able to create Turrets")
				sciencePanel.Info5:SetColor(Color( 0, 0, 0, 255 ))
				sciencePanel.Info5:SizeToContents() 
		 		sciencePanel.Info5:SetContentAlignment( 5 )	 		
		 		
		 		local engineerPanel = vgui.Create("DPanel")
				engineerPanel:SetTall(75)
				engineerPanel.Paint = function()
				
					draw.RoundedBox( 6, 0, 0, engineerPanel:GetWide(), engineerPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
			
				end
				pnlList:AddItem(engineerPanel)
				
				engineerPanel.Icon = vgui.Create("SpawnIcon", engineerPanel)
				engineerPanel.Icon:SetModel("models/weapons/w_models/w_toolbox.mdl")
				engineerPanel.Icon:SetPos(3, 5)
				engineerPanel.Icon:SetToolTip( nil )
				engineerPanel.Icon.DoClick = function()
						RunConsoleCommand( "team_set_engineer" )
						class_Frame:Close()
				end		
												
				engineerPanel.Title = vgui.Create("DLabel", engineerPanel)
				engineerPanel.Title:SetPos(90, 5)
				engineerPanel.Title:SetText("The Engineer")
				engineerPanel.Title:SetColor(team.GetColor(TEAM_ENGINEER))
				engineerPanel.Title:SizeToContents() 
		 		engineerPanel.Title:SetContentAlignment( 5 )
		 		
				engineerPanel.Info1 = vgui.Create("DLabel", engineerPanel)
				engineerPanel.Info1:SetPos(200, 5)
				engineerPanel.Info1:SetText("The builder of many things")
				engineerPanel.Info1:SetColor(Color( 0, 0, 0, 255 ))
				engineerPanel.Info1:SizeToContents() 
		 		engineerPanel.Info1:SetContentAlignment( 5 )
		 		engineerPanel.Info2 = vgui.Create("DLabel", engineerPanel)
				engineerPanel.Info2:SetPos(215, 22)
				engineerPanel.Info2:SetText("Able to build Guns")
				engineerPanel.Info2:SetColor(Color( 0, 0, 0, 255 ))
				engineerPanel.Info2:SizeToContents() 
		 		engineerPanel.Info2:SetContentAlignment( 5 )
		 		engineerPanel.Info3 = vgui.Create("DLabel", engineerPanel)
				engineerPanel.Info3:SetPos(215, 34)
				engineerPanel.Info3:SetText("Able to create ammo")
				engineerPanel.Info3:SetColor(Color( 0, 0, 0, 255 ))
				engineerPanel.Info3:SizeToContents() 
		 		engineerPanel.Info3:SetContentAlignment( 5 )	
		 		engineerPanel.Info4 = vgui.Create("DLabel", engineerPanel)
				engineerPanel.Info4:SetPos(215, 46)
				engineerPanel.Info4:SetText("Able to build vehicles")
				engineerPanel.Info4:SetColor(Color( 0, 0, 0, 255 ))
				engineerPanel.Info4:SizeToContents() 
		 		engineerPanel.Info4:SetContentAlignment( 5 )	
		 		
		 		local cultivatorPanel = vgui.Create("DPanel")
				cultivatorPanel:SetTall(75)
				cultivatorPanel.Paint = function()
				
					draw.RoundedBox( 6, 0, 0, cultivatorPanel:GetWide(), cultivatorPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
			
				end
				pnlList:AddItem(cultivatorPanel)
				
				cultivatorPanel.Icon = vgui.Create("SpawnIcon", cultivatorPanel)
				cultivatorPanel.Icon:SetModel("models/props_junk/watermelon01.mdl")
				cultivatorPanel.Icon:SetPos(3, 5)
				cultivatorPanel.Icon:SetToolTip( nil )
				cultivatorPanel.Icon.DoClick = function()
						RunConsoleCommand( "team_set_cultivator" )
						class_Frame:Close()
				end	
												
				cultivatorPanel.Title = vgui.Create("DLabel", cultivatorPanel)
				cultivatorPanel.Title:SetPos(90, 5)
				cultivatorPanel.Title:SetText("The Cultivator")
				cultivatorPanel.Title:SetColor(team.GetColor(TEAM_CULTIVATOR))
				cultivatorPanel.Title:SizeToContents() 
		 		cultivatorPanel.Title:SetContentAlignment( 5 )
		 		
		 		cultivatorPanel.Info1 = vgui.Create("DLabel", cultivatorPanel)
				cultivatorPanel.Info1:SetPos(200, 5)
				cultivatorPanel.Info1:SetText("The grower of food")
				cultivatorPanel.Info1:SetColor(Color( 0, 0, 0, 255 ))
				cultivatorPanel.Info1:SizeToContents() 
		 		cultivatorPanel.Info1:SetContentAlignment( 5 )
		 		cultivatorPanel.Info2 = vgui.Create("DLabel", cultivatorPanel)
				cultivatorPanel.Info2:SetPos(215, 22)
				cultivatorPanel.Info2:SetText("Able to create a variety of foods.")
				cultivatorPanel.Info2:SetColor(Color( 0, 0, 0, 255 ))
				cultivatorPanel.Info2:SizeToContents() 
		 		cultivatorPanel.Info2:SetContentAlignment( 5 )
		 		
end


concommand.Add( "pnrp_classmenu", PNRP.ClassMenu )

--EOF