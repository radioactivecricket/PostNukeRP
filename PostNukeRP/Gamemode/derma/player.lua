
function viewPlayerInfoWindow()

	player_frame = PNRP.PNRP_Frame()
	if not player_frame then return end

	local ply = LocalPlayer()
	local targetPly = net.ReadEntity()

	player_frame:SetSize( 710, 510 ) --Set the size Extra 40 must be from the top bar
	--Set the window in the middle of the players screen/game window
	player_frame:SetPos(ScrW() / 2 - player_frame:GetWide() / 2, ScrH() / 2 - player_frame:GetTall() / 2) 
	player_frame:SetTitle( "Player Info" ) --Set title
	player_frame:SetVisible( true )
	player_frame:SetDraggable( true )
	player_frame:ShowCloseButton( true )
	player_frame:MakePopup()
	player_frame.Paint = function() 
		surface.SetDrawColor( 50, 50, 50, 0 )
	end
	
	local screenBG = vgui.Create("DImage", player_frame)
		screenBG:SetImage( "VGUI/gfx/pnrp_screen_2b.png" )
		screenBG:SetSize(player_frame:GetWide(), player_frame:GetTall())
	
	sideMenu(player_frame)
	
	local mdl = vgui.Create( "DModelPanel", player_frame )
		mdl:SetSize( 350, 740 )
		mdl:SetPos(-50,-125)
		mdl.Angles = Angle( 0, 0, 0 )			
		mdl:SetFOV( 36 )
		mdl:SetCamPos( Vector( 0, 0, 0 ) )
		mdl:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
		mdl:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
		mdl:SetAmbientLight( Vector( -64, -64, -64 ) )
		mdl:SetAnimated( true )
		mdl:SetLookAt( Vector( -100, 0, -22 ) )
		
		mdl:SetModel( targetPly:GetModel() ) -- you can only change colors on playermodels
		function mdl.Entity:GetPlayerColor() return targetPly:GetPlayerColor() end
		
		local numBG = mdl.Entity:GetNumBodyGroups()
		local newSkin = mdl.Entity:GetSkin()
		local bgString = ""
		for i=0, numBG do
			bgString = bgString..tostring(targetPly:GetBodygroup( i ))
		end
		mdl.Entity:SetSkin(targetPly:GetSkin())
		mdl.Entity:SetBodyGroups( bgString )
		mdl.Entity:SetPos( Vector( -100, 0, -61 ) )
	
		-- Hold to rotate
		function mdl:DragMousePress()
			self.PressX, self.PressY = gui.MousePos()
			self.Pressed = true
		end

		function mdl:DragMouseRelease() self.Pressed = false end

		function mdl:LayoutEntity( Entity )
		--	if ( self.bAnimated ) then self:RunAnimation() end

			if ( self.Pressed ) then
				local mx, my = gui.MousePos()
				self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )
				
				self.PressX, self.PressY = gui.MousePos()
			end

			Entity:SetAngles( self.Angles )
		end
		
	local name = vgui.Create("DLabel", player_frame)
		name:SetPos(250, 50)
		name:SetText("Name: "..targetPly:Nick())
		name:SetColor(Color( 0, 200, 0, 255 ))
		name:SetFont("Trebuchet24")
		name:SizeToContents() 
	local community = vgui.Create("DLabel", player_frame)
		community:SetPos(250, 75)
		local MemberOf
		MemberOf = targetPly:GetNetVar("community", "N/A")
		community:SetText("Member of "..MemberOf)
		community:SetColor(Color( 0, 200, 0, 255 ))
		community:SetFont("HudHintTextLarge")
		community:SizeToContents() 
	local title = vgui.Create("DLabel", player_frame)
		title:SetPos(250, 90)
		title:SetText(targetPly:GetNetVar("ctitle", " "))
		title:SetColor(Color( 0, 200, 0, 255 ))
		title:SetFont("HudHintTextLarge")
		title:SizeToContents() 
	local class = vgui.Create("DLabel", player_frame)
		class:SetPos(250, 115)
		class:SetText("Class: "..team.GetName(targetPly:Team()))
		class:SetColor(Color( 0, 200, 0, 255 ))
		class:SetFont("HudHintTextLarge")
		class:SizeToContents() 
	
	local steamName = vgui.Create("DLabel", player_frame)
		steamName:SetPos(250, 150)
		steamName:SetText("Steam Name: "..targetPly:SteamName())
		steamName:SetColor(Color( 0, 200, 0, 255 ))
		steamName:SetFont("HudHintTextLarge")
		steamName:SizeToContents() 
		
	local steamID_Label = vgui.Create("DLabel", player_frame)
		steamID_Label:SetPos(250, 170)
		steamID_Label:SetText("SteamID: ")
		steamID_Label:SetColor(Color( 0, 200, 0, 255 ))
		steamID_Label:SetFont("HudHintTextLarge")
		steamID_Label:SizeToContents() 
		
	local TextSteamID = vgui.Create( "DTextEntry", player_frame )	-- create the form as a child of frame
		TextSteamID:SetPos( 320, 170 )
		TextSteamID:SetSize( 150, 16 )
		TextSteamID:SetText( targetPly:SteamID() )

end
net.Receive( "viewPlayerInfoWindow", viewPlayerInfoWindow )

function playerProfileWindow()

	local profile_frame = PNRP.PNRP_Frame()
	if not profile_frame then return end
	
	local ply = LocalPlayer()
	local newModel = ply:GetModel()
	local playerColor = Vector( GetConVarString( "cl_playercolor" ) )
	local wepColor = Vector( GetConVarString( "cl_weaponcolor" ) )
	
	profile_frame:SetSize( 710, 510 ) --Set the size Extra 40 must be from the top bar
		--Set the window in the middle of the players screen/game window
		profile_frame:SetPos(ScrW() / 2 - profile_frame:GetWide() / 2, ScrH() / 2 - profile_frame:GetTall() / 2) 
		profile_frame:SetTitle( "Player Info" ) --Set title
		profile_frame:SetVisible( true )
		profile_frame:SetDraggable( true )
		profile_frame:ShowCloseButton( true )
		profile_frame:MakePopup()
		profile_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", profile_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_2b.png" )
			screenBG:SetSize(profile_frame:GetWide(), profile_frame:GetTall())
		
		sideMenu(profile_frame)
		
		local mdl = vgui.Create( "DModelPanel", profile_frame )
			mdl:SetSize( 350, 740 )
			mdl:SetPos(-50,-140)
			mdl.Angles = Angle( 0, 0, 0 )			
			mdl:SetFOV( 36 )
			mdl:SetCamPos( Vector( 0, 0, 0 ) )
			mdl:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
			mdl:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
			mdl:SetAmbientLight( Vector( -64, -64, -64 ) )
			mdl:SetAnimated( true )
			mdl:SetLookAt( Vector( -100, 0, -22 ) )
			
			mdl:SetModel( ply:GetModel() ) -- you can only change colors on playermodels
			function mdl.Entity:GetPlayerColor() return Vector( GetConVarString( "cl_playercolor" ) ) end
			
			local numBG = mdl.Entity:GetNumBodyGroups()
			local newSkin = mdl.Entity:GetSkin()
			local bgString = ""
			for i=0, numBG do
				bgString = bgString..tostring(ply:GetBodygroup( i ))
			end
			mdl.Entity:SetSkin(ply:GetSkin())
			mdl.Entity:SetBodyGroups( bgString )
			mdl.Entity:SetPos( Vector( -100, 0, -61 ) )
			
			-- Hold to rotate
			function mdl:DragMousePress()
				self.PressX, self.PressY = gui.MousePos()
				self.Pressed = true
			end

			function mdl:DragMouseRelease() self.Pressed = false end

			function mdl:LayoutEntity( Entity )

				if ( self.Pressed ) then
					local mx, my = gui.MousePos()
					self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )
					
					self.PressX, self.PressY = gui.MousePos()
				end

				Entity:SetAngles( self.Angles )
			end
		
		local profile_TabSheet = vgui.Create( "DPropertySheet" )
			profile_TabSheet:SetParent( profile_frame )
			profile_TabSheet:SetPos( 200, 45 )
			profile_TabSheet:SetSize( profile_frame:GetWide() - 250, profile_frame:GetTall() - 80 )
			profile_TabSheet.Paint = function() -- Paint function
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
		
			local pInfoPanel = vgui.Create( "DPanel", profile_TabSheet )
				pInfoPanel:SetPos( 5, 5 )
				pInfoPanel:SetSize( profile_TabSheet:GetWide(), profile_TabSheet:GetTall() )
				pInfoPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
				
				local name = vgui.Create("DLabel", pInfoPanel)
					name:SetPos(0, 10)
					name:SetText("Name: ")
					name:SetColor(Color( 0, 200, 0, 255 ))
					name:SetFont("Trebuchet24")
					name:SizeToContents()
				local TextName = vgui.Create( "DTextEntry", pInfoPanel )
					TextName:SetPos( 60, 12 )
					TextName:SetSize( 175, 22 )
					TextName:SetText( ply:Nick() )
					TextName.OnEnter = function( self )
						chName()
					end
				local NameChangeBtn = vgui.Create("DButton", pInfoPanel )
					NameChangeBtn:SetPos(250, 12)
					NameChangeBtn:SetSize(75,20)
					NameChangeBtn:SetText( "Set Name" )
					NameChangeBtn.DoClick = function()
						chName()
					end
					
				function chName(newName)
					net.Start("PNRP_ChangeRPName")
						net.WriteString(TextName:GetValue())
					net.SendToServer()
				end
					
				local community = vgui.Create("DLabel", pInfoPanel)
					community:SetPos(0, 50)
					local MemberOf
					MemberOf = ply:GetNetVar("community", "N/A")
					community:SetText("Member of "..MemberOf)
					community:SetColor(Color( 0, 200, 0, 255 ))
					community:SetFont("HudHintTextLarge")
					community:SizeToContents() 
				local title = vgui.Create("DLabel", pInfoPanel)
					title:SetPos(0, 63)
					title:SetText(ply:GetNetVar("ctitle", " "))
					title:SetColor(Color( 0, 200, 0, 255 ))
					title:SetFont("HudHintTextLarge")
					title:SizeToContents() 
				local class = vgui.Create("DLabel", pInfoPanel)
					class:SetPos(0, 80)
					class:SetText("Class: "..team.GetName(ply:Team()))
					class:SetColor(Color( 0, 200, 0, 255 ))
					class:SetFont("HudHintTextLarge")
					class:SizeToContents() 
		profile_TabSheet:AddSheet( "Player Info", pInfoPanel, "gui/icons/user.png", false, false, "Player Info" )

			local Skills_DPanel = vgui.Create( "DPanel", profile_TabSheet )
				Skills_DPanel:SetPos( 5, 5 )
				Skills_DPanel:SetSize( profile_TabSheet:GetWide(), profile_TabSheet:GetTall() - 70 )
				Skills_DPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
				
				Skills_DPanel.XP = vgui.Create("DLabel", Skills_DPanel)
				Skills_DPanel.XP:SetPos(5, 10)
				Skills_DPanel.XP:SetText("Current Experience: "..GetXP())
				Skills_DPanel.XP:SetColor( Color( 255, 255, 255, 255 ) )
				Skills_DPanel.XP:SizeToContents() 
				Skills_DPanel.XP:SetContentAlignment( 5 )
				
				Skills_DPanel.Run = vgui.Create("DLabel", Skills_DPanel)
				Skills_DPanel.Run:SetPos(325, 10)
				Skills_DPanel.Run:SetText("Run Speed: "..ply:GetRunSpeed( ))
				Skills_DPanel.Run:SetColor( Color( 255, 255, 255, 255 ) )
				Skills_DPanel.Run:SizeToContents() 
				Skills_DPanel.Run:SetContentAlignment( 5 )
							
				local maxWeight
				if ply:Team() == TEAM_SCAVENGER then
					maxWeight = GetConVar("pnrp_packCapScav"):GetInt() + (GetSkill("Backpacking")*10)
				else
					maxWeight = GetConVar("pnrp_packCap"):GetInt() + (GetSkill("Backpacking")*10)
				end
				Skills_DPanel.BackPk = vgui.Create("DLabel", Skills_DPanel)
				Skills_DPanel.BackPk:SetPos(325, 25)
				Skills_DPanel.BackPk:SetText("Backpack Size: "..maxWeight)
				Skills_DPanel.BackPk:SetColor( Color( 255, 255, 255, 255 ) )
				Skills_DPanel.BackPk:SizeToContents() 
				Skills_DPanel.BackPk:SetContentAlignment( 5 )
				
				local SkillScrollPanel = vgui.Create( "DScrollPanel", Skills_DPanel)
					SkillScrollPanel:SetSize( Skills_DPanel:GetWide()-20, Skills_DPanel:GetTall()-20 )
					SkillScrollPanel:SetPos( 0, 50 )
					
				--Skills Section
				local skillYLoc = 5
				SkillScrollPanel.SKBLabel = vgui.Create("DLabel", SkillScrollPanel)
				SkillScrollPanel.SKBLabel:SetPos(10, skillYLoc)
				SkillScrollPanel.SKBLabel:SetText("Base Skills:")
				SkillScrollPanel.SKBLabel:SetColor( Color( 255, 255, 255, 255 ) )
				SkillScrollPanel.SKBLabel:SizeToContents() 
				SkillScrollPanel.SKBLabel:SetContentAlignment( 5 )
				
				skillYLoc = skillYLoc + 20
				local btnXLoc = SkillScrollPanel:GetWide() - 118
				
				for skillname, skill in pairs( PNRP.Skills ) do
					if skill.class == nil then

						SkillScrollPanel.Skill = vgui.Create("DLabel", SkillScrollPanel)
						SkillScrollPanel.Skill:SetPos(10, skillYLoc+2)
						SkillScrollPanel.Skill:SetText(skill.name.." (Max Level "..skill.maxlvl..")")
						SkillScrollPanel.Skill:SetColor( Color( 255, 255, 255, 255 ) )
						SkillScrollPanel.Skill:SizeToContents() 
						SkillScrollPanel.Skill:SetContentAlignment( 5 )
						ProfileUpSkillBtn(skill.name, btnXLoc, skillYLoc, SkillScrollPanel, profile_frame)
						SKlevel_Bar(skill.name, GetSkill(skill.name), 10, skillYLoc+20, SkillScrollPanel)
					
						skillYLoc = skillYLoc + 40
					end
				end
				
				skillYLoc = skillYLoc + 10
				SkillScrollPanel.ClsSKLabel = vgui.Create("DLabel", SkillScrollPanel)
				SkillScrollPanel.ClsSKLabel:SetPos(10, skillYLoc)
				SkillScrollPanel.ClsSKLabel:SetText("Class Skill:")
				SkillScrollPanel.ClsSKLabel:SetColor( Color( 255, 255, 255, 255 ) )
				SkillScrollPanel.ClsSKLabel:SizeToContents() 
				SkillScrollPanel.ClsSKLabel:SetContentAlignment( 5 )
				
				skillYLoc = skillYLoc + 20 --Adjusts for the for loop
				for skillname, skill in pairs( PNRP.Skills ) do
					if skill.class != nil then
						for classname, class in pairs( PNRP.Skills[skill.name].class ) do
							if tostring(ply:Team()) == tostring(class) then
								SkillScrollPanel.ClsSkill = vgui.Create("DLabel", SkillScrollPanel, profile_frame)
								SkillScrollPanel.ClsSkill:SetPos(10, skillYLoc+2)
								SkillScrollPanel.ClsSkill:SetText(skill.name.." (Max Level "..skill.maxlvl..")")
								SkillScrollPanel.ClsSkill:SetColor( Color( 255, 255, 255, 255 ) )
								SkillScrollPanel.ClsSkill:SizeToContents() 
								SkillScrollPanel.ClsSkill:SetContentAlignment( 5 )
								ProfileUpSkillBtn(skill.name, btnXLoc, skillYLoc, SkillScrollPanel, profile_frame)
								SKlevel_Bar(skill.name, GetSkill(skill.name), 10, skillYLoc+20, SkillScrollPanel)
							
								skillYLoc = skillYLoc + 40
							end
						end
					else
					
						
					end
				end	
				
		profile_TabSheet:AddSheet( "Skills", Skills_DPanel, "gui/icons/wrench.png", false, false, "Skills" )
		
			local pModelPanel = vgui.Create( "DPanel", profile_TabSheet )
				pModelPanel:SetPos( 5, 5 )
				pModelPanel:SetSize( profile_TabSheet:GetWide(), profile_TabSheet:GetTall() )
				pModelPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
				
				local BodyGroupScrollPanel = vgui.Create( "DScrollPanel", pModelPanel)
					BodyGroupScrollPanel:SetSize( 155, pModelPanel:GetTall() - 50 )
					BodyGroupScrollPanel:SetPos( 0, 5 )
					BodyGroupScrollPanel:SetPadding(5)
				
				function skinBodyGroup( mdlEnt )
					BodyGroupScrollPanel:Clear()
					local layout = vgui.Create( "DListLayout", BodyGroupScrollPanel )
						layout:SetSize(  BodyGroupScrollPanel:GetWide()-15, BodyGroupScrollPanel:GetTall()-15 )
						layout:SetPos( 0, 0 )
						
						local Skins = mdlEnt:SkinCount()
						if Skins > 1 then
							local skinList = vgui.Create( "DListView", layout )
								skinList:SetMultiSelect( false )
								skinList:AddColumn( "Skins" )
							for i=1, Skins do
								skinList:AddLine( "Skin ("..tostring(i-1)..")", i-1 )
							end
							skinList:SetSize( layout:GetWide(), 70 )
							
							local oldSkin = mdlEnt:GetSkin()
							skinList:SelectItem( skinList:GetLine(oldSkin+1) )
							
							layout:Add(skinList)
							skinList.OnRowSelected = function( panel , index )
								myVar = panel:GetLine(index):GetValue(2)
								mdl.Entity:SetSkin( myVar ) 
							end	
						end
						
						local bodyGroups = mdlEnt:GetBodyGroups()
						
						local modelName = bodyGroups[1]["name"]
						for _, v in pairs(bodyGroups) do
							
							if v["name"] ~= modelName then
								local catList = vgui.Create( "DListView", layout )
									catList:SetMultiSelect( false )
									catList:AddColumn( v["name"] )
									
								local catHeight = 0
									for mID, submodel in pairs(v["submodels"]) do
										
										submodel = string.gsub(submodel, ".smd", "")
										submodel = string.gsub(submodel, modelName.."_", "")
										submodel = string.gsub(submodel, "_", " ")
										if submodel == "" then submodel = "None" end
										
										catList:AddLine( submodel, mID )
										catHeight = catHeight + 25
									end
								if catHeight > 70 then catHeight = 70 end
								if catHeight < 35 then catHeight = 35 end
								catList:SetSize( layout:GetWide(), catHeight )
								catList.OnRowSelected = function( panel , index )
									myVar = panel:GetLine(index):GetValue(2)
									mdl.Entity:SetBodygroup( v["id"], myVar ) 
								end
								layout:Add(catList)
								local oldBG = mdl.Entity:GetBodygroup( v["id"] )
								catList:SelectItem( catList:GetLine(oldBG+1) )
							end
						end
				end
				
				skinBodyGroup( mdl.Entity )
				
				local ModelScrollPanel = vgui.Create( "DScrollPanel", pModelPanel)
					ModelScrollPanel:SetSize( pModelPanel:GetWide()-175, pModelPanel:GetTall()-50 )
					ModelScrollPanel:SetPos( 160, 5 )
					
					local List	= vgui.Create( "DIconLayout", ModelScrollPanel )
						List:SetSize( ModelScrollPanel:GetWide(), ModelScrollPanel:GetTall() )
						List:SetPos( 0, 0 )
						List:SetSpaceY( 5 )
						List:SetSpaceX( 5 )
						
						local mdlList = player_manager.AllValidModels( )
						for name, model in pairs( mdlList ) do
							local ListItem = List:Add( "DPanel" )
							ListItem:SetSize( 64, 64 )
							ListItem.Paint = function() -- Paint function
								if string.lower(ply:GetModel()) == string.lower(model) then
									draw.RoundedBox( 6, 0, 0, ListItem:GetWide(), ListItem:GetTall(), Color( 0, 180, 0, 25 ) )
								else
									surface.SetDrawColor( 50, 50, 50, 0 )
								end
							end
							local modelIcon = vgui.Create( "SpawnIcon", ListItem )
							modelIcon:SetPos( 0, 0 )
							modelIcon:SetSize( ListItem:GetWide(), ListItem:GetTall() ) 
							modelIcon:SetModel( model )
							modelIcon:SetTooltip( name )
							modelIcon.DoClick = function()
								mdl:SetModel( model )
								newModel = model
								function mdl.Entity:GetPlayerColor() return Vector( GetConVarString( "cl_playercolor" ) ) end
								mdl.Entity:SetPos( Vector( -100, 0, -61 ) )
								
								skinBodyGroup( mdl.Entity )
							end
						end
				
		profile_TabSheet:AddSheet( "Player Model", pModelPanel, "gui/icons/user_edit.png", false, false, "Player Model" )
			
			local pColorPanel = vgui.Create( "DPanel", profile_TabSheet )
				pColorPanel:SetPos( 5, 10 )
				pColorPanel:SetSize( profile_TabSheet:GetWide(), profile_TabSheet:GetTall() )
				pColorPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
									
				local plyModelCol = vgui.Create( "DColorMixer", pColorPanel )
					plyModelCol:Dock( FILL )			--Make Mixer fill place of Frame
					plyModelCol:SetPalette( false ) 		--Show/hide the palette			DEF:true
					plyModelCol:SetAlphaBar( false ) 		--Show/hide the alpha bar		DEF:true
					plyModelCol:SetWangs( true )			--Show/hide the R G B A indicators 	DEF:true
					plyModelCol:SetColor( Color( 30, 100, 160 ) )	--Set the default color
					plyModelCol:SetVector( playerColor )
					plyModelCol.ValueChanged = function()
						function mdl.Entity:GetPlayerColor() return plyModelCol:GetVector() end
						playerColor = plyModelCol:GetVector()
					end
					
		profile_TabSheet:AddSheet( "Player Color", pColorPanel, "gui/icons/user_edit.png", false, false, "Player Color" )
		
			local pWColorPanel = vgui.Create( "DPanel", profile_TabSheet )
				pWColorPanel:SetPos( 5, 5 )
				pWColorPanel:SetSize( profile_TabSheet:GetWide(), profile_TabSheet:GetTall() )
				pWColorPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
					
				local plyWeaponCol = vgui.Create( "DColorMixer", pWColorPanel )
					plyWeaponCol:Dock( FILL )			--Make Mixer fill place of Frame
					plyWeaponCol:SetPalette( false ) 		--Show/hide the palette			DEF:true
					plyWeaponCol:SetAlphaBar( false ) 		--Show/hide the alpha bar		DEF:true
					plyWeaponCol:SetWangs( true )			--Show/hide the R G B A indicators 	DEF:true
					plyWeaponCol:SetColor( Color( 30, 100, 160 ) )	--Set the default color
					plyWeaponCol:SetVector( wepColor )
					plyWeaponCol.ValueChanged = function()
						wepColor = plyWeaponCol:GetVector()
					end
					
				
				
		profile_TabSheet:AddSheet( "Weapon Color", pWColorPanel, "gui/icons/user_edit.png", false, false, "Weapon Color" )
	
	local WColorChangeBtn = vgui.Create("DButton", profile_frame )
		WColorChangeBtn:SetPos(50, profile_frame:GetTall()-63)
		WColorChangeBtn:SetSize(150,17)
		WColorChangeBtn:SetText( "Update Player Model" )
		WColorChangeBtn.DoClick = function()
			RunConsoleCommand( "cl_playercolor", tostring( plyModelCol:GetVector() ) )
			RunConsoleCommand( "cl_weaponcolor", tostring( plyWeaponCol:GetVector() ) )
			updateModel()
		end
					
	function updateModel()
		
		local numBG = mdl.Entity:GetNumBodyGroups()
		local newSkin = mdl.Entity:GetSkin()
		local bgString = ""
		
		for i=0, numBG do
			bgString = bgString..tostring(mdl.Entity:GetBodygroup( i ))
		end
		
		net.Start("PNRP_SetPlayerModel")
			net.WriteString(newModel)
			net.WriteVector(playerColor)
			net.WriteVector(wepColor)
			net.WriteString(newSkin)
			net.WriteString(bgString)
		net.SendToServer()
	end
		
end
concommand.Add( "pnrp_playerprofile",  playerProfileWindow )

function ProfileUpSkillBtn(Skill, XLoc, YLoc, parent_frame, profile_frame)
	local SKUpBtn = vgui.Create("DButton") 
		SKUpBtn:SetParent( parent_frame ) 
		SKUpBtn:SetText( "Upgrade" ) 
		SKUpBtn:SetPos( XLoc, YLoc)
		SKUpBtn:SetSize( 100, 20 ) 
		SKUpBtn:SetDisabled(canUpSkillBtn(Skill, GetSkill(Skill)))
		SKUpBtn.DoClick = function() 
			RunConsoleCommand( "pnrp_upgradeskill", Skill )
			profile_frame:Close() 
			openProfileTimer()
		end	
end

function openProfileTimer()
	local ply = LocalPlayer()
	timer.Create(tostring(ply:UniqueID()), 0.5, 1, function()  
		RunConsoleCommand( "pnrp_playerprofile" )
	end)
end