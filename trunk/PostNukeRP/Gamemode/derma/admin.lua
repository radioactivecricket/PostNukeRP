local admin_frame
local pp_frame

function GM.open_admin()
	local GM = GAMEMODE
	local ply = LocalPlayer()
	--local GMSettings = decoded["GMSettings"]
	--local SpawnSettings = decoded["SpawnSettings"]
	local GMSettings = net.ReadTable()
	local SpawnSettings = net.ReadTable()
	local mapList = net.ReadTable()
	local importList = net.ReadTable()
	if ply:IsAdmin() then	
		admin_frame = vgui.Create( "DFrame" )
				admin_frame:SetSize( 400, 650 ) --Set the size
				admin_frame:SetPos(ScrW() / 2 - admin_frame:GetWide() / 2, ScrH() / 2 - admin_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
				admin_frame:SetTitle( "Admin Menu" ) --Set title
				admin_frame:SetVisible( true )
				admin_frame:SetDraggable( true )
				admin_frame:ShowCloseButton( true )
				admin_frame:MakePopup()
		
		local shopmenu = vgui.Create("DButton") -- Create the button
			shopmenu:SetParent( admin_frame ) -- parent the button to the frame
			shopmenu:SetText( "Admin Trade >" ) -- set the button text
			shopmenu:SetPos(20, 25) -- set the button position in the frame
			shopmenu:SetSize( 100, 20 ) -- set the button size
			shopmenu.DoClick = function() RunConsoleCommand( "pnrp_admin_trade_window" ) SCFrame=false admin_frame:Close() end 	
			
		local ppmenu = vgui.Create("DButton") -- Create the button
			ppmenu:SetParent( admin_frame ) -- parent the button to the frame
			ppmenu:SetText( "Prop Control >" ) -- set the button text
			ppmenu:SetPos(120, 25) -- set the button position in the frame
			ppmenu:SetSize( 100, 20 ) -- set the button size
			ppmenu.DoClick = function() 
				--datastream.StreamToServer( "Start_open_PropProtection" )
				net.Start("Start_open_PropProtection")
					net.WriteEntity(ply)
				net.SendToServer()
				SCFrame=false 
				admin_frame:Close() 
			end 
		
		local textColor = Color(200,200,200,255)
		local dListBKColor = Color(50,50,50,255)
		
--		local plymenu = vgui.Create("DButton") -- Create the button
--			plymenu:SetParent( admin_frame ) -- parent the button to the frame
--			plymenu:SetText( "Player Control >" ) -- set the button text
--			plymenu:SetPos(220, 25) -- set the button position in the frame
--			plymenu:SetSize( 100, 20 ) -- set the button size
--			plymenu.DoClick = function() RunConsoleCommand( "pnrp_playerAdminList" ) SCFrame=false admin_frame:Close() end 
		
		local AdminTabSheet = vgui.Create( "DPropertySheet" )
			AdminTabSheet:SetParent( admin_frame )
			AdminTabSheet:SetPos( 5, 50 )
			AdminTabSheet:SetSize( admin_frame:GetWide() - 10, admin_frame:GetTall() - 90 ) 
--Server Settings
			local GModeSettingsList = vgui.Create( "DPanelList", AdminTabSheet )
				GModeSettingsList:SetPos( 10,10 )
				GModeSettingsList:SetSize( admin_frame:GetWide() - 10, admin_frame:GetTall() - 10 )
				GModeSettingsList:SetSpacing( 3 ) -- Spacing between items
				GModeSettingsList:SetPadding( 5 )
				GModeSettingsList:EnableHorizontal( false ) -- Only vertical items
				GModeSettingsList:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis	
				GModeSettingsList:SetDrawBackground( true )
				GModeSettingsList.Paint = function()
					draw.RoundedBox( 8, 0, 0, GModeSettingsList:GetWide(), GModeSettingsList:GetTall(), dListBKColor )
				end

				
				local E2RestrictLabel= vgui.Create("DLabel", GModeSettingsList)
					E2RestrictLabel:SetText("E2 Restriction: " )
					E2RestrictLabel:SetColor(textColor)
					E2RestrictLabel:SizeToContents()
				GModeSettingsList:AddItem( E2RestrictLabel )
					
				local E2RestrictSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    E2RestrictSlider:SetSize( GModeSettingsList:GetWide() - 20, 40 ) -- Keep the second number at 50
				--	E2RestrictSlider:SetWide( 50 )
				    E2RestrictSlider:SetText( "0 - None, 1 - Admin, 2 - Eng, 3 - Eng/Science, 4 - All " )
				    E2RestrictSlider:SetMin( 0 )
				    E2RestrictSlider:SetMax( 4 )
				    E2RestrictSlider:SetDecimals( 0 )
					E2RestrictSlider.Label:SetColor(textColor)
					E2RestrictSlider:SetBGColor(textColor)
				    E2RestrictSlider:SetValue( GMSettings.E2Restrict )
					E2RestrictSlider.Label:SizeToContents()
				GModeSettingsList:AddItem( E2RestrictSlider )				
				
				local ToolRestrictLabel= vgui.Create("DLabel", GModeSettingsList)
					ToolRestrictLabel:SetText("Tool Restriction:  (Def: 2)" )
					ToolRestrictLabel:SetColor(textColor)
					ToolRestrictLabel:SizeToContents()
				GModeSettingsList:AddItem( ToolRestrictLabel )
					
				local ToolRestrictSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    ToolRestrictSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    ToolRestrictSlider:SetText( "0 - None, 1 - Admin, 2 - Eng, 3 - Eng/Science, 4 - All " )
				    ToolRestrictSlider:SetMin( 0 )
				    ToolRestrictSlider:SetMax( 4 )
				    ToolRestrictSlider:SetDecimals( 0 )
					ToolRestrictSlider.Label:SetColor(textColor)
				    ToolRestrictSlider:SetValue( GMSettings.ToolLevel )
					ToolRestrictSlider.Label:SizeToContents()
				GModeSettingsList:AddItem( ToolRestrictSlider )
				
				local adminCreateAllTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					adminCreateAllTgl:SetText( "Admin can create all." )
					adminCreateAllTgl:SetTextColor(textColor)
					adminCreateAllTgl:SetValue( GMSettings.AdminCreateAll )
					adminCreateAllTgl:SizeToContents() 
				GModeSettingsList:AddItem( adminCreateAllTgl )
				
				local adminTouchAllTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					adminTouchAllTgl:SetText( "Admin can touch all." )
					adminTouchAllTgl:SetTextColor(textColor)
					adminTouchAllTgl:SetValue( GMSettings.AdminTouchAll )
					adminTouchAllTgl:SizeToContents() 
				GModeSettingsList:AddItem( adminTouchAllTgl )
				
				local adminNoCostTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					adminNoCostTgl:SetText( "Admin No Cost." )
					adminNoCostTgl:SetTextColor(textColor)
					adminNoCostTgl:SetValue( GMSettings.AdminNoCost )
					adminNoCostTgl:SizeToContents() 
				GModeSettingsList:AddItem( adminNoCostTgl )
				
				local propBanningTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					propBanningTgl:SetText( "Prop Banning." )
					propBanningTgl:SetTextColor(textColor)
					propBanningTgl:SetValue( GMSettings.PropBanning )
					propBanningTgl:SizeToContents() 
				GModeSettingsList:AddItem( propBanningTgl )
				
				local propAllowingTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					propAllowingTgl:SetText( "Prop Allowing." )
					propAllowingTgl:SetTextColor(textColor)
					propAllowingTgl:SetValue( GMSettings.PropAllowing )
					propAllowingTgl:SizeToContents() 
				GModeSettingsList:AddItem( propAllowingTgl )
				
				local propSpawnProtectTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					propSpawnProtectTgl:SetText( "Player Spawn Protection." )
					propSpawnProtectTgl:SetTextColor(textColor)
					propSpawnProtectTgl:SetValue( GMSettings.PropSpawnProtection )
					propSpawnProtectTgl:SizeToContents() 
				GModeSettingsList:AddItem( propSpawnProtectTgl )
				
				local plyDeathZombieTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					plyDeathZombieTgl:SetText( "Player Death Zombie Spawn." )
					plyDeathZombieTgl:SetTextColor(textColor)
					plyDeathZombieTgl:SetValue( GMSettings.PlyDeathZombie )
					plyDeathZombieTgl:SizeToContents() 
				GModeSettingsList:AddItem( plyDeathZombieTgl )
				
				local PropExpTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					PropExpTgl:SetText( "Player Exp from Prop Kills." )
					PropExpTgl:SetTextColor(textColor)
					PropExpTgl:SetValue( GMSettings.PropExp )
					PropExpTgl:SizeToContents() 
				GModeSettingsList:AddItem( PropExpTgl )
				
				local PropPuntTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					PropPuntTgl:SetText( "Allow Prop  Punting." )
					PropPuntTgl:SetTextColor(textColor)
					PropPuntTgl:SetValue( GMSettings.PropPunt )
					PropPuntTgl:SizeToContents() 
				GModeSettingsList:AddItem( PropPuntTgl )
				
				local propPayTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					propPayTgl:SetText( "Pay for Props from Q Menu.." )
					propPayTgl:SetTextColor(textColor)
					propPayTgl:SetValue( GMSettings.PropPay )
					propPayTgl:SizeToContents() 
				GModeSettingsList:AddItem( propPayTgl )
				
				local propCostSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    propCostSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    propCostSlider:SetText( "Q Menu Prop Cost (Def 10) [Affects Adv Dupe]" )
					propCostSlider.Label:SetColor(textColor)
				    propCostSlider:SetMin( 0 )
				    propCostSlider:SetMax( 100 )
				    propCostSlider:SetDecimals( 0 )
					propCostSlider:SetValue( GMSettings.PropCost )
					propCostSlider.Label:SizeToContents()
				GModeSettingsList:AddItem( propCostSlider )
				
				local voiceLimitTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					voiceLimitTgl:SetText( "Voice Range Limiter" )
					voiceLimitTgl:SetTextColor(textColor)
					voiceLimitTgl:SetValue( GMSettings.VoiceLimiter )
					voiceLimitTgl:SizeToContents() 
				GModeSettingsList:AddItem( voiceLimitTgl )
				
				local voiceLimitSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    voiceLimitSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    voiceLimitSlider:SetText( "Voice Limit Range (Def 750)" )
					voiceLimitSlider.Label:SetColor(textColor)
				    voiceLimitSlider:SetMin( 0 )
				    voiceLimitSlider:SetMax( 2000 )
				    voiceLimitSlider:SetDecimals( 0 )
					voiceLimitSlider.Label:SizeToContents()
				    voiceLimitSlider:SetValue( GMSettings.VoiceDistance )
				GModeSettingsList:AddItem( voiceLimitSlider )
				
				local classCostTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					classCostTgl:SetText( "Charg for Class Change" )
					classCostTgl:SetTextColor(textColor)
					classCostTgl:SetValue( GMSettings.ClassChangePay )
					classCostTgl:SizeToContents() 
					classCostTgl.Label:SizeToContents()
				GModeSettingsList:AddItem( classCostTgl )
				
				local classCostSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    classCostSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    classCostSlider:SetText( "Class Change Cost (Def 10)" )
					classCostSlider.Label:SetColor(textColor)
				    classCostSlider:SetMin( 0 )
				    classCostSlider:SetMax( 100 )
				    classCostSlider:SetDecimals( 0 )
				    classCostSlider:SetValue( GMSettings.ClassChangeCost )
					classCostSlider.Label:SizeToContents()
				GModeSettingsList:AddItem( classCostSlider )
				
				local deathCostTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					deathCostTgl:SetText( "Charg for Death Penalty" )
					deathCostTgl:SetTextColor(textColor)
					deathCostTgl:SetValue( GMSettings.DeathPay )
					deathCostTgl:SizeToContents() 
					deathCostTgl.Label:SizeToContents()
				GModeSettingsList:AddItem( deathCostTgl )
				
				local deathCostSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    deathCostSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    deathCostSlider:SetText( "Death Penalty Cost (Def 10)" )
					deathCostSlider.Label:SetColor(textColor)
				    deathCostSlider:SetMin( 0 )
				    deathCostSlider:SetMax( 100 )
				    deathCostSlider:SetDecimals( 0 )
				    deathCostSlider:SetValue( GMSettings.DeathCost )
					deathCostSlider.Label:SizeToContents()
				GModeSettingsList:AddItem( deathCostSlider )
				
				local ownDoorsSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    ownDoorsSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    ownDoorsSlider:SetText( "Number of doors that can be owned (Def 3)" )
					ownDoorsSlider.Label:SetColor(textColor)
				    ownDoorsSlider:SetMin( 0 )
				    ownDoorsSlider:SetMax( 10 )
				    ownDoorsSlider:SetDecimals( 0 )
				    ownDoorsSlider:SetValue( GMSettings.MaxOwnDoors )
				    ownDoorsSlider.Label:SizeToContents()
				GModeSettingsList:AddItem( ownDoorsSlider )
								
			AdminTabSheet:AddSheet( "GMode Settings", GModeSettingsList, "gui/icons/brick_edit.png", false, false, "GMode Settings" )	
--Mob Spawning Settings				
			local SpawnerList = vgui.Create( "DPanelList", AdminTabSheet )
				SpawnerList:SetPos( 10,10 )
				SpawnerList:SetSize( admin_frame:GetWide() - 10, admin_frame:GetTall() - 10 )
				SpawnerList:SetSpacing( 5 ) -- Spacing between items
				SpawnerList:EnableHorizontal( false ) -- Only vertical items
				SpawnerList:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis		  
				 	
			  local MobSpawnerSettingsCats = vgui.Create("DCollapsibleCategory", SpawnerList)
					MobSpawnerSettingsCats:SetSize( SpawnerList:GetWide()-4, 50 ) -- Keep the second number at 50
					MobSpawnerSettingsCats:SetExpanded( 0 ) -- Expanded when popped up
					MobSpawnerSettingsCats:SetLabel( "Mob Spawner Settings" )
					 
					MobCategoryList = vgui.Create( "DPanelList" )
					MobCategoryList:SetAutoSize( true )
					MobCategoryList:SetSpacing( 5 )
					MobCategoryList:EnableHorizontal( false )
					MobCategoryList:EnableVerticalScrollbar( true )
					MobCategoryList.Paint = function()
						draw.RoundedBox( 8, 0, 0, MobCategoryList:GetWide(), MobCategoryList:GetTall(), Color( 50, 50, 50, 255 ) )
					end
					
					MobSpawnerSettingsCats:SetContents( MobCategoryList )
				
				local countMobsBTN = vgui.Create("DButton", MobCategoryList )
				    countMobsBTN:SetText( "Count Mobs" )
				    countMobsBTN.DoClick = function()
				        RunConsoleCommand( "pnrp_countmobs" )
				    end
				MobCategoryList:AddItem( countMobsBTN )	
					
				local clearMobsBTN = vgui.Create("DButton", MobCategoryList )
				    clearMobsBTN:SetText( "Clear Mobs" )
				    clearMobsBTN.DoClick = function()
				        RunConsoleCommand( "pnrp_clearmobs" )
				    end
				MobCategoryList:AddItem( clearMobsBTN )
				
				local mobSpawnerTgl = vgui.Create( "DCheckBoxLabel", MobCategoryList )
					mobSpawnerTgl:SetText( "Mob Spawner" )
					mobSpawnerTgl.Label:SetColor(textColor)
					mobSpawnerTgl:SetValue( SpawnSettings.SpawnMobs )
					mobSpawnerTgl:SizeToContents() 
				MobCategoryList:AddItem( mobSpawnerTgl )
				
				local maxZombiesSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxZombiesSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxZombiesSlider:SetText( "Max Zombies (Default 30)" )
					maxZombiesSlider.Label:SetColor(textColor)
				    maxZombiesSlider:SetMin( 0 )
				    maxZombiesSlider:SetMax( 100 )
				    maxZombiesSlider:SetDecimals( 0 )
				    maxZombiesSlider:SetValue( SpawnSettings.MaxZombies )
					maxZombiesSlider.Label:SizeToContents()
				MobCategoryList:AddItem( maxZombiesSlider )
				
				local maxFastZombiesSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxFastZombiesSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxFastZombiesSlider:SetText( "Max Fast Zombies (Default 5)" )
					maxFastZombiesSlider.Label:SetColor(textColor)
				    maxFastZombiesSlider:SetMin( 0 )
				    maxFastZombiesSlider:SetMax( 100 )
				    maxFastZombiesSlider:SetDecimals( 0 )
				    maxFastZombiesSlider:SetValue( SpawnSettings.MaxFastZombies )
					maxFastZombiesSlider.Label:SizeToContents()
				MobCategoryList:AddItem( maxFastZombiesSlider )
				
				local maxPoisonZombiesSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxPoisonZombiesSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxPoisonZombiesSlider:SetText( "Max Poison Zombies (Default 2)" )
					maxPoisonZombiesSlider.Label:SetColor(textColor)
				    maxPoisonZombiesSlider:SetMin( 0 )
				    maxPoisonZombiesSlider:SetMax( 100 )
				    maxPoisonZombiesSlider:SetDecimals( 0 )
				    maxPoisonZombiesSlider:SetValue( SpawnSettings.MaxPoisonZombs )
					maxPoisonZombiesSlider.Label:SizeToContents()
				MobCategoryList:AddItem( maxPoisonZombiesSlider )
				
				local maxAntlionsSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxAntlionsSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxAntlionsSlider:SetText( "Max Antlions (Default 10)" )
					maxAntlionsSlider.Label:SetColor(textColor)
				    maxAntlionsSlider:SetMin( 0 )
				    maxAntlionsSlider:SetMax( 100 )
				    maxAntlionsSlider:SetDecimals( 0 )
				    maxAntlionsSlider:SetValue( SpawnSettings.MaxAntlions )
					maxAntlionsSlider.Label:SizeToContents()
				MobCategoryList:AddItem( maxAntlionsSlider )
				
				local maxAntGuardSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxAntGuardSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxAntGuardSlider:SetText( "Max Ant Guard (Default 1)" )
					maxAntGuardSlider.Label:SetColor(textColor)
				    maxAntGuardSlider:SetMin( 0 )
				    maxAntGuardSlider:SetMax( 100 )
				    maxAntGuardSlider:SetDecimals( 0 )
				    maxAntGuardSlider:SetValue( SpawnSettings.MaxAntGuards )
					maxAntGuardSlider.Label:SizeToContents()
				MobCategoryList:AddItem( maxAntGuardSlider )
				
				SpawnerList:AddItem( MobSpawnerSettingsCats )
		--End Mob Spawn Settings
		--Start Mound Settings
				local MoundSpawnerSettingsCats = vgui.Create("DCollapsibleCategory", SpawnerList)
					MoundSpawnerSettingsCats:SetSize( SpawnerList:GetWide()-4, 50 ) -- Keep the second number at 50
					MoundSpawnerSettingsCats:SetExpanded( 0 ) -- Expanded when popped up
					MoundSpawnerSettingsCats:SetLabel( "Antlion Mound Spawner Settings" )
					 
					MoundCategoryList = vgui.Create( "DPanelList" )
					MoundCategoryList:SetAutoSize( true )
					MoundCategoryList:SetSpacing( 3 )
					MoundCategoryList:EnableHorizontal( false )
					MoundCategoryList:EnableVerticalScrollbar( true )
					MoundCategoryList.Paint = function()
						draw.RoundedBox( 8, 0, 0, MoundCategoryList:GetWide(), MoundCategoryList:GetTall(), Color( 50, 50, 50, 255 ) )
					end
					 
					MoundSpawnerSettingsCats:SetContents( MoundCategoryList )
					
				local clearMoundsBTN = vgui.Create("DButton", MobCategoryList )
				    clearMoundsBTN:SetText( "Clear Antlion Mounds" )
				    clearMoundsBTN.DoClick = function()
				        RunConsoleCommand( "pnrp_clearmounds" )
				    end
				MoundCategoryList:AddItem( clearMoundsBTN )
				
				local maxMounds = vgui.Create( "DNumSlider", MoundCategoryList )
				    maxMounds:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxMounds:SetText( "Max Ant Lion Mounds (Default 1)" )
					maxMounds.Label:SetColor(textColor)
				    maxMounds:SetMin( 0 )
				    maxMounds:SetMax( 100 )
				    maxMounds:SetDecimals( 0 )
				    maxMounds:SetValue( SpawnSettings.MaxAntMounds )
					maxMounds.Label:SizeToContents()
				MoundCategoryList:AddItem( maxMounds )
				
				local moundSpawnRate = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundSpawnRate:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundSpawnRate:SetText( "Mound Spawn Rate (Default 5min)" )
					moundSpawnRate.Label:SetColor(textColor)
				    moundSpawnRate:SetMin( 0 )
				    moundSpawnRate:SetMax( 100 )
				    moundSpawnRate:SetDecimals( 0 )
				    moundSpawnRate:SetValue( SpawnSettings.AntMoundRate )
					moundSpawnRate.Label:SizeToContents()
				MoundCategoryList:AddItem( moundSpawnRate )
				
				local moundSpawnChance = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundSpawnChance:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundSpawnChance:SetText( "Mound Spawn Chance (Default 15%)" )
					moundSpawnChance.Label:SetColor(textColor)
				    moundSpawnChance:SetMin( 0 )
				    moundSpawnChance:SetMax( 100 )
				    moundSpawnChance:SetDecimals( 0 )
				    moundSpawnChance:SetValue( SpawnSettings.AntMoundChance )
					moundSpawnChance.Label:SizeToContents()
				MoundCategoryList:AddItem( moundSpawnChance )
				
				local moundMaxAntlions = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundMaxAntlions:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundMaxAntlions:SetText( "Mound Max Antlions (Default 10)" )
					moundMaxAntlions.Label:SetColor(textColor)
				    moundMaxAntlions:SetMin( 0 )
				    moundMaxAntlions:SetMax( 100 )
				    moundMaxAntlions:SetDecimals( 0 )
				    moundMaxAntlions:SetValue( SpawnSettings.MaxMoundAntlions )
					moundMaxAntlions.Label:SizeToContents()
				MoundCategoryList:AddItem( moundMaxAntlions )
				
				local moundAntlionsPerCycle = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundAntlionsPerCycle:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundAntlionsPerCycle:SetText( "Mound Antlions Spawned Per Cycle (Default 5)" )
					moundAntlionsPerCycle.Label:SetColor(textColor)
				    moundAntlionsPerCycle:SetMin( 0 )
				    moundAntlionsPerCycle:SetMax( 100 )
				    moundAntlionsPerCycle:SetDecimals( 0 )
				    moundAntlionsPerCycle:SetValue( SpawnSettings.MoundAntlionsPerCycle )
					moundAntlionsPerCycle.Label:SizeToContents()
				MoundCategoryList:AddItem( moundAntlionsPerCycle )
				
				local moundMaxAntlionGuards = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundMaxAntlionGuards:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundMaxAntlionGuards:SetText( "Mound Max Antlion Guards (Default 1)" )
					moundMaxAntlionGuards.Label:SetColor(textColor)
				    moundMaxAntlionGuards:SetMin( 0 )
				    moundMaxAntlionGuards:SetMax( 100 )
				    moundMaxAntlionGuards:SetDecimals( 0 )
				    moundMaxAntlionGuards:SetValue( SpawnSettings.MaxMoundGuards )
					moundMaxAntlionGuards.Label:SizeToContents()
				MoundCategoryList:AddItem( moundMaxAntlionGuards )
				
				local moundMobRate = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundMobRate:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundMobRate:SetText( "Mound NPC Spawn Rate (Default 5min)" )
					moundMobRate.Label:SetColor(textColor)
				    moundMobRate:SetMin( 0 )
				    moundMobRate:SetMax( 100 )
				    moundMobRate:SetDecimals( 0 )
				    moundMobRate:SetValue( SpawnSettings.AntMoundMobRate )
					moundMobRate.Label:SizeToContents()
				MoundCategoryList:AddItem( moundMobRate )
				
				local moundGuardChance = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundGuardChance:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundGuardChance:SetText( "Mound Guard Spawn Chance (Default 10%)" )
					moundGuardChance.Label:SetColor(textColor)
				    moundGuardChance:SetMin( 0 )
				    moundGuardChance:SetMax( 100 )
				    moundGuardChance:SetDecimals( 0 )
				    moundGuardChance:SetValue( SpawnSettings.MoundGuardChance )
					moundGuardChance.Label:SizeToContents()
				MoundCategoryList:AddItem( moundGuardChance )
				
				SpawnerList:AddItem( MoundSpawnerSettingsCats )
		--End Mound Settings
		--Start Resource Settings
				local RecSpawnerSettingsCats = vgui.Create("DCollapsibleCategory", SpawnerList)
					RecSpawnerSettingsCats:SetSize( SpawnerList:GetWide()-4, 50 ) -- Keep the second number at 50
					RecSpawnerSettingsCats:SetExpanded( 0 ) -- Expanded when popped up
					RecSpawnerSettingsCats:SetLabel( "Recource Spawner Settings" )
					 
					RecCategoryList = vgui.Create( "DPanelList" )
					RecCategoryList:SetAutoSize( true )
					RecCategoryList:SetSpacing( 5 )
					RecCategoryList:EnableHorizontal( false )
					RecCategoryList:EnableVerticalScrollbar( true )
					RecCategoryList.Paint = function()
						draw.RoundedBox( 8, 0, 0, RecCategoryList:GetWide(), RecCategoryList:GetTall(), Color( 50, 50, 50, 255 ) )
					end
					  
					RecSpawnerSettingsCats:SetContents( RecCategoryList )
				
				local countRecsBTN = vgui.Create("DButton", RecCategoryList )
				    countRecsBTN:SetText( "Count Recources" )
				    countRecsBTN.DoClick = function()
				        RunConsoleCommand( "pnrp_countres" )
				    end
				RecCategoryList:AddItem( countRecsBTN )
				
				local clearRecsBTN = vgui.Create("DButton", RecCategoryList )
				    clearRecsBTN:SetText( "Clear Recources" )
				    clearRecsBTN.DoClick = function()
				        RunConsoleCommand( "pnrp_clearres" )
				    end
				RecCategoryList:AddItem( clearRecsBTN )
				
				local recSpawnerTgl = vgui.Create( "DCheckBoxLabel", RecCategoryList )
					recSpawnerTgl:SetText( "Recource Spawner" )
					recSpawnerTgl:SetValue( SpawnSettings.ReproduceRes )
					recSpawnerTgl:SizeToContents() 
				RecCategoryList:AddItem( recSpawnerTgl )
				
				local maxReproducedRes = vgui.Create( "DNumSlider", RecCategoryList )
				    maxReproducedRes:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxReproducedRes:SetText( "Max Recources (Default 20)" )
					maxReproducedRes.Label:SetColor(textColor)
				    maxReproducedRes:SetMin( 0 )
				    maxReproducedRes:SetMax( 100 )
				    maxReproducedRes:SetDecimals( 0 )
				    maxReproducedRes:SetValue( SpawnSettings.MaxReproducedRes )
					maxReproducedRes.Label:SizeToContents()
				RecCategoryList:AddItem( maxReproducedRes )
				
				SpawnerList:AddItem( RecSpawnerSettingsCats )
		
		AdminTabSheet:AddSheet( "Spawn Settings", SpawnerList, "gui/icons/bug_add.png", false, false, "Spawn Settings" )
-- Mob Grid Settings		
		local mobGridRange = 1000
		
		local mobGridSetup = vgui.Create( "DPanelList", AdminTabSheet )
				mobGridSetup:SetPos( 10,10 )
				mobGridSetup:SetSize( admin_frame:GetWide() - 10, admin_frame:GetTall() - 10 )
				mobGridSetup:SetSpacing( 5 ) -- Spacing between items
				mobGridSetup:EnableHorizontal( false ) -- Only vertical items
				mobGridSetup:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis
				
			local mSGridBTN = vgui.Create("DButton", mobGridSetup )
				    mSGridBTN:SetText( "Save Grid" )
				    mSGridBTN.DoClick = function()
				        RunConsoleCommand("pnrp_savegrid" )
				    end
				mobGridSetup:AddItem( mSGridBTN )
				
			local mLGridBTN = vgui.Create("DButton", mobGridSetup )
				    mLGridBTN:SetText( "Load Grid" )
				    mLGridBTN.DoClick = function()
				        RunConsoleCommand("pnrp_loadgrid" )
				    end
				mobGridSetup:AddItem( mLGridBTN )
			
			local mSPGridBTN = vgui.Create("DButton", mobGridSetup )
				    mSPGridBTN:SetText( "Edit Grid" )
				    mSPGridBTN.DoClick = function()
				        RunConsoleCommand("pnrp_editgrid" )
				    end
				mobGridSetup:AddItem( mSPGridBTN )
			
			local mDLGridBTN = vgui.Create("DButton", mobGridSetup )
				    mDLGridBTN:SetText( "Remove Grid Entities" )
				    mDLGridBTN.DoClick = function()
				        RunConsoleCommand("pnrp_clearspawnnodes" )
				    end
				mobGridSetup:AddItem( mDLGridBTN )
			
			local MapExpListView = vgui.Create( "DListView", mobGridSetup )
					MapExpListView:SetSize( mobGridSetup:GetWide(), 150 )
					MapExpListView:SetMultiSelect( false ) -- <removed sarcastic and useless comment>
					MapExpListView:AddColumn("Map Name")
					MapExpListView:AddColumn("Saved Nodes")
					for k, v in pairs( mapList ) do
						MapExpListView:AddLine( v["map"], v["nodes"] )
					end
				
				mobGridSetup:AddItem( MapExpListView )
			
			local mapExpBTN = vgui.Create("DButton", mobGridSetup )
				    mapExpBTN:SetText( "Export Map Grid" )
				    mapExpBTN.DoClick = function()
						if MapExpListView:GetSelectedLine() then
							local mapName = MapExpListView:GetLine(MapExpListView:GetSelectedLine()):GetValue(1)
							net.Start( "exportMapGrid" )
								net.WriteEntity(ply)
								net.WriteString(mapName)
							net.SendToServer()
						end
						admin_frame:Close() 
				    end
				mobGridSetup:AddItem( mapExpBTN )
			
			local MapImpListView = vgui.Create( "DListView", mobGridSetup )
					MapImpListView:SetSize( mobGridSetup:GetWide(), 150 )
					MapImpListView:SetMultiSelect( false ) -- <removed sarcastic and useless comment>
					MapImpListView:AddColumn("Map Name")
					MapImpListView:AddColumn("Saved Nodes")
					for k, v in pairs( importList ) do
						MapImpListView:AddLine( v[1], v[2] )
					end
				
				mobGridSetup:AddItem( MapImpListView )
				
			local mapImpBTN = vgui.Create("DButton", mobGridSetup )
				    mapImpBTN:SetText( "Import Map Grid" )
				    mapImpBTN.DoClick = function()
						if MapImpListView:GetSelectedLine() then
							local impMapName = MapImpListView:GetLine(MapImpListView:GetSelectedLine()):GetValue(1)
							net.Start( "importMapGrid" )
								net.WriteEntity(ply)
								net.WriteString(impMapName)
							net.SendToServer()
						end
						admin_frame:Close() 
				    end
				mobGridSetup:AddItem( mapImpBTN )
		
		AdminTabSheet:AddSheet( "Mob Grid Settings", mobGridSetup, "gui/icons/bug_edit.png", false, false, "Mob Grid Settings" )
				
		local saveBtn = vgui.Create("DButton") -- Create the button
			saveBtn:SetParent( admin_frame ) -- parent the button to the frame
			saveBtn:SetText( "Save Settings" ) -- set the button text
			saveBtn:SetPos(5, admin_frame:GetTall() - 30) -- set the button position in the frame
			saveBtn:SetSize( admin_frame:GetWide() - 10, 20 ) -- set the button size
			saveBtn.DoClick = function()  
			
				GMSettings.E2Restrict = tonumber(E2RestrictSlider:GetValue())
				GMSettings.ToolLevel = tonumber(ToolRestrictSlider:GetValue())
				GMSettings.AdminCreateAll = toIntfromBool(adminCreateAllTgl:GetChecked())
				GMSettings.AdminTouchAll = toIntfromBool(adminTouchAllTgl:GetChecked())
				GMSettings.AdminNoCost = toIntfromBool(adminNoCostTgl:GetChecked())
				GMSettings.PropBanning = toIntfromBool(propBanningTgl:GetChecked())
				GMSettings.PropAlowing = toIntfromBool(propAllowingTgl:GetChecked())
				GMSettings.PropSpawnProtection = toIntfromBool(propSpawnProtectTgl:GetChecked())
				GMSettings.PlyDeathZombie = toIntfromBool(plyDeathZombieTgl:GetChecked())
				GMSettings.PropPunt = toIntfromBool(PropPuntTgl:GetChecked())
				GMSettings.PropExp = toIntfromBool(PropExpTgl:GetChecked())
				GMSettings.PropPay = toIntfromBool(propPayTgl:GetChecked())
				GMSettings.PropCost = tonumber(propCostSlider:GetValue())
				GMSettings.VoiceLimiter = toIntfromBool(voiceLimitTgl:GetChecked())
				GMSettings.VoiceDistance = tonumber(voiceLimitSlider:GetValue())
				GMSettings.ClassChangePay = toIntfromBool(classCostTgl:GetChecked())
				GMSettings.ClassChangeCost = tonumber(classCostSlider:GetValue())
				GMSettings.DeathPay = toIntfromBool(deathCostTgl:GetChecked())
				GMSettings.DeathCost = tonumber(deathCostSlider:GetValue())
				GMSettings.MaxOwnDoors = tonumber(ownDoorsSlider:GetValue())
				
				SpawnSettings.SpawnMobs = toIntfromBool(mobSpawnerTgl:GetChecked())
				SpawnSettings.MaxZombies = tonumber(maxZombiesSlider:GetValue())
				SpawnSettings.MaxFastZombies = tonumber(maxFastZombiesSlider:GetValue())
				SpawnSettings.MaxPoisonZombs = tonumber(maxPoisonZombiesSlider:GetValue())
				SpawnSettings.MaxAntlions = tonumber(maxAntlionsSlider:GetValue())
				SpawnSettings.MaxAntGuards = tonumber(maxAntGuardSlider:GetValue())
				SpawnSettings.MaxAntMounds = tonumber(maxMounds:GetValue())
				SpawnSettings.AntMoundRate = tonumber(moundSpawnRate:GetValue())
				SpawnSettings.AntMoundChance = tonumber(moundSpawnChance:GetValue())
				SpawnSettings.MaxMoundAntlions = tonumber(moundMaxAntlions:GetValue())
				SpawnSettings.MoundAntlionsPerCycle = tonumber(moundAntlionsPerCycle:GetValue())
				SpawnSettings.MaxMoundGuards = tonumber(moundMaxAntlionGuards:GetValue())
				SpawnSettings.AntMoundMobRate = tonumber(moundMobRate:GetValue())
				SpawnSettings.MoundGuardChance = tonumber(moundGuardChance:GetValue())
				SpawnSettings.ReproduceRes = toIntfromBool(recSpawnerTgl:GetChecked())
				SpawnSettings.MaxReproducedRes = tonumber(maxReproducedRes:GetValue())
				
				--datastream.StreamToServer( "UpdateFromAdminMenu", { ["GMSettings"] = GMSettings, ["SpawnSettings"] = SpawnSettings })
				net.Start( "UpdateFromAdminMenu" )
					net.WriteEntity(ply)
					net.WriteTable(GMSettings)
					net.WriteTable(SpawnSettings)
				net.SendToServer()
			end 
	else
		ply:ChatPrint("You are not an admin on this server!")
	end
end
--datastream.Hook( "pnrp_OpenAdminWindow", GM.open_admin )
net.Receive( "pnrp_OpenAdminWindow", GM.open_admin )

function GM.initAdmin(ply)
	if ply:IsAdmin() then	
		RunConsoleCommand("pnrp_OpenAdmin")
	else
		ply:ChatPrint("You are not an admin on this server!")
	end

end
concommand.Add( "pnrp_admin_window",  GM.initAdmin )

-----------------------------------------------------------------------------
function GM.OpenPropProtectWindow( )
	local BannedPropList = net.ReadTable()
	local AllowedPropList = net.ReadTable()
	local GM = GAMEMODE
	local ply = LocalPlayer()
	local tr = ply:TraceFromEyes(400)
	local ent = tr.Entity
	local model
	if ply:IsAdmin() then	
		pp_frame = vgui.Create( "DFrame" )
				pp_frame:SetSize( 500, 450 ) --Set the size
				pp_frame:SetPos(ScrW() / 2 - pp_frame:GetWide() / 2, ScrH() / 2 - pp_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
				pp_frame:SetTitle( " " ) --Set title
				pp_frame:SetVisible( true )
				pp_frame:SetDraggable( true )
				pp_frame:ShowCloseButton( false )
				pp_frame:MakePopup()
				pp_frame.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
			
		local pp_TabSheet = vgui.Create( "DPropertySheet" )
			pp_TabSheet:SetParent( pp_frame )
			pp_TabSheet:SetPos( 5, 25 )
			pp_TabSheet:SetSize( pp_frame:GetWide() - 10, pp_frame:GetTall() - 55 )
			
		--	local ppvLabel = vgui.Create("DLabel", pp_frame)
		--		ppvLabel:SetPos(10, 25)
		--		ppvLabel:SetColor( Color( 0, 0, 0, 255 ) )
		--		ppvLabel:SetText( "Blocked Props" )
		--		ppvLabel:SizeToContents()
			local pBanPanel = vgui.Create( "DPanel", pp_TabSheet )
				pBanPanel:SetPos( 5, 5 )
				pBanPanel:SetSize( pp_TabSheet:GetWide(), pp_TabSheet:GetTall() )
				pBanPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
			--//Banned Prop List//--
			local pnlBList = vgui.Create("DPanelListOld", pBanPanel)
				pnlBList:SetPos(5, 5)
				pnlBList:SetSize(pBanPanel:GetWide() - 125, pBanPanel:GetTall() - 40)
				pnlBList:EnableVerticalScrollbar(false) 
				pnlBList:EnableHorizontal(true) 
				pnlBList:SetSpacing(1)
				pnlBList:SetPadding(10)
				if BannedPropList != nil then
					for k, v in pairs( BannedPropList ) do		
						
						local slot = vgui.Create("SpawnIcon", pBanPanel)

						slot:SetModel(v)
						slot:SetToolTip(v)
						slot.DoClick = function()
							PNRP.RemoveItemVerify(v, 1)
						end
						
						pnlBList:AddItem(slot)
					end
				end
			local pp_add = vgui.Create("DButton") 
					pp_add:SetParent( pBanPanel ) 
					pp_add:SetText( "Add Item" ) 
					pp_add:SetPos(pnlBList:GetWide() + 15, 5)
					pp_add:SetSize( 100, 20 ) 
					pp_add.DoClick = function() 
						if tostring(ent) == "[NULL Entity]" or ent == nil or ent:IsWorld() then 
							pp_frame:Close()
							ply:ChatPrint("You are not looking at anything.")
						else
							model = tostring(ent:GetModel())
							ply:ChatPrint(model)
							--datastream.StreamToServer("PropProtect_AddItem", {model, 1} ) 
							net.Start("PropProtect_AddItem")
								net.WriteEntity(ply)
								net.WriteString(model)
								net.WriteDouble(1)
							net.SendToServer()
							pp_frame:Close()
							--datastream.StreamToServer( "Start_open_PropProtection" )
							net.Start("Start_open_PropProtection")
								net.WriteEntity(ply)
							net.SendToServer()
						end
						
					end	
			local ppb_exit = vgui.Create("DButton") 
					ppb_exit:SetParent( pBanPanel ) 
					ppb_exit:SetText( "Exit" ) 
					ppb_exit:SetPos(pnlBList:GetWide() + 15, pnlBList:GetTall() - 20)
					ppb_exit:SetSize( 100, 20 ) 
					ppb_exit.DoClick = function() 
						pp_frame:Close()						
					end	
			pp_TabSheet:AddSheet( "Banned Props List", pBanPanel, "gui/icons/brick_add.png", false, false, "Banned Props List" )
			
			--//Allowed Prop List//--
			local pAllowedPanel = vgui.Create( "DPanel", pp_TabSheet )
				pAllowedPanel:SetPos( 5, 5 )
				pAllowedPanel:SetSize( pp_TabSheet:GetWide(), pp_TabSheet:GetTall() )
				pAllowedPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
			local pnlAList = vgui.Create("DPanelListOld", pAllowedPanel)
				pnlAList:SetPos(5, 5)
				pnlAList:SetSize(pAllowedPanel:GetWide() - 125, pAllowedPanel:GetTall() - 40)
				pnlAList:EnableVerticalScrollbar(false) 
				pnlAList:EnableHorizontal(true) 
				pnlAList:SetSpacing(1)
				pnlAList:SetPadding(10)
				if AllowedPropList != nil then
					for k, v in pairs( AllowedPropList ) do		
						
						local slot = vgui.Create("SpawnIcon", pAllowedPanel)

						slot:SetModel(v)
						slot:SetToolTip(v)
						slot.DoClick = function()
							PNRP.RemoveItemVerify(v, 2)
						end
						
						pnlAList:AddItem(slot)
					end
				end
			local ppa_add = vgui.Create("DButton") 
					ppa_add:SetParent( pAllowedPanel ) 
					ppa_add:SetText( "Add Item" ) 
					ppa_add:SetPos(pnlAList:GetWide() + 15, 5)
					ppa_add:SetSize( 100, 20 ) 
					ppa_add.DoClick = function() 
						if tostring(ent) == "[NULL Entity]" or ent == nil or ent:IsWorld() then 
							pp_frame:Close()
							ply:ChatPrint("You are not looking at anything.")
						else
							model = tostring(ent:GetModel())
							ply:ChatPrint(model)
							--datastream.StreamToServer("PropProtect_AddItem", {model, 2} ) 
							net.Start("PropProtect_AddItem")
								net.WriteEntity(ply)
								net.WriteString(model)
								net.WriteDouble(2)
							net.SendToServer()
							pp_frame:Close()
							--datastream.StreamToServer( "Start_open_PropProtection" )
							net.Start("Start_open_PropProtection")
								net.WriteEntity(ply)
							net.SendToServer()
						end
						
					end	
			local ppa_exit = vgui.Create("DButton") 
					ppa_exit:SetParent( pAllowedPanel ) 
					ppa_exit:SetText( "Exit" ) 
					ppa_exit:SetPos(pnlAList:GetWide() + 15, pnlAList:GetTall() - 20)
					ppa_exit:SetSize( 100, 20 ) 
					ppa_exit.DoClick = function() 
						pp_frame:Close()						
					end	
			pp_TabSheet:AddSheet( "Allowed Props List", pAllowedPanel, "gui/icons/brick_add.png", false, false, "Allowed Props List" )
	end
end
--datastream.Hook( "pnrp_OpenPropProtectWindow", GM.OpenPropProtectWindow )
net.Receive( "pnrp_OpenPropProtectWindow", GM.OpenPropProtectWindow )

function PNRP.RemoveItemVerify(model, switch)
	local ply = LocalPlayer()
	if ply:IsAdmin() then	
		local ppv_frame = vgui.Create( "DFrame" )
				ppv_frame:SetSize( 175, 85 ) --Set the size
				ppv_frame:SetPos(ScrW() / 2 - ppv_frame:GetWide() / 2, ScrH() / 2 - ppv_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
				ppv_frame:SetTitle( "Prop Protection Menu" ) --Set title
				ppv_frame:SetVisible( true )
				ppv_frame:SetDraggable( true )
				ppv_frame:ShowCloseButton( true )
				ppv_frame:MakePopup()
				
			local ppvLabel = vgui.Create("DLabel", ppv_frame)
				ppvLabel:SetPos(15, 30)
				ppvLabel:SetColor( Color( 0, 0, 0, 255 ) )
				ppvLabel:SetText( "Delete this item from the list?" )
				ppvLabel:SizeToContents()
				
				local ppv_yes = vgui.Create("DButton") -- Create the button
					ppv_yes:SetParent( ppv_frame ) -- parent the button to the frame
					ppv_yes:SetText( "Yes" ) -- set the button text
					ppv_yes:SetPos(30, 50) -- set the button position in the frame
					ppv_yes:SetSize( 50, 20 ) -- set the button size
					ppv_yes.DoClick = function() 
						--datastream.StreamToServer( "PropProtect_RemoveItem", {model, switch}) 
						net.Start("PropProtect_RemoveItem")
							net.WriteEntity(ply)
							net.WriteString(model)
							net.WriteDouble(switch)
						net.SendToServer()
						ppv_frame:Close() 
						pp_frame:Close() 
						--datastream.StreamToServer( "Start_open_PropProtection" )
						net.Start("Start_open_PropProtection")
							net.WriteEntity(ply)
						net.SendToServer()
					end 
				
				local ppv_no = vgui.Create("DButton") -- Create the button
					ppv_no:SetParent( ppv_frame ) -- parent the button to the frame
					ppv_no:SetText( "No" ) -- set the button text
					ppv_no:SetPos(85, 50) -- set the button position in the frame
					ppv_no:SetSize( 50, 20 ) -- set the button size
					ppv_no.DoClick = function() ppv_frame:Close() end
					
	end
end

local PlyAdminLs_frame
local PlyAdminLsFrameCK = false
function GM.OpenPlyAdminLstWindow( )
	local GM = GAMEMODE
	local ply = LocalPlayer()
	local Players =  net.ReadTable()
	PlyAdminLsFrameCK = true
	
	PlyAdminLs_frame = vgui.Create( "DFrame" )
		PlyAdminLs_frame:SetSize( 400, 450 ) 
		PlyAdminLs_frame:SetPos(ScrW() / 2 - PlyAdminLs_frame:GetWide() / 2, ScrH() / 2 - PlyAdminLs_frame:GetTall() / 2)
		PlyAdminLs_frame:SetTitle( "Player Admin" )
		PlyAdminLs_frame:SetVisible( true )
		PlyAdminLs_frame:SetDraggable( true )
		PlyAdminLs_frame:ShowCloseButton( true )
		PlyAdminLs_frame:MakePopup()
		
		local PlyAdminLs_TabSheet = vgui.Create( "DPropertySheet" )
			PlyAdminLs_TabSheet:SetParent( PlyAdminLs_frame )
			PlyAdminLs_TabSheet:SetPos( 5, 25 )
			PlyAdminLs_TabSheet:SetSize( PlyAdminLs_frame:GetWide() - 15, PlyAdminLs_frame:GetTall() - 55 )
		
			local PlyAdminLsPanel = vgui.Create( "DPanel", PlyAdminLs_TabSheet )
				PlyAdminLsPanel:SetPos( 5, 5 )
				PlyAdminLsPanel:SetSize( PlyAdminLs_TabSheet:GetWide(), PlyAdminLs_TabSheet:GetTall() )
				PlyAdminLsPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
			local PlyAdminLsList = vgui.Create("DPanelList", PlyAdminLsPanel)
				PlyAdminLsList:SetPos(5, 5)
				PlyAdminLsList:SetSize(PlyAdminLsPanel:GetWide() - 10, PlyAdminLsPanel:GetTall() - 40)
				PlyAdminLsList:EnableVerticalScrollbar(true) 
				PlyAdminLsList:EnableHorizontal(false) 
				PlyAdminLsList:SetSpacing(1)
				PlyAdminLsList:SetPadding(10)
				
				for k, v in pairs( Players ) do
					local PLyPanel = vgui.Create("DPanel")
						PLyPanel:SetTall(75)
						PLyPanel.Paint = function()
							draw.RoundedBox( 6, 0, 0, PLyPanel:GetWide(), PLyPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
						end
						PlyAdminLsList:AddItem(PLyPanel)
						
						PLyPanel.Title = vgui.Create("DLabel", PLyPanel)
						PLyPanel.Title:SetPos(10, 5)
						PLyPanel.Title:SetText(v["name"])
						PLyPanel.Title:SetColor(Color( 0, 0, 0, 255 ))
						PLyPanel.Title:SizeToContents() 
						PLyPanel.Title:SetContentAlignment( 5 )
				end
	
	function PlyAdminLs_frame:Close()                  
		PlyAdminLsFrameCK = false                  
		self:SetVisible( false )                  
		self:Remove()          
	end 
end
--datastream.Hook( "pnrp_OpenPlyAdminLstWindow", GM.OpenPlyAdminLstWindow )
net.Receive( "pnrp_OpenPlyAdminLstWindow", GM.OpenPlyAdminLstWindow )

local communityAdmin_frame
function GM.communityAdminMenu()
	local communityTable = net.ReadTable()
	communityAdmin_frame = vgui.Create( "DFrame" )
		communityAdmin_frame:SetSize( 710, 520 ) 
		communityAdmin_frame:SetPos(ScrW() / 2 - communityAdmin_frame:GetWide() / 2, ScrH() / 2 - communityAdmin_frame:GetTall() / 2)
		communityAdmin_frame:SetTitle( " " )
		communityAdmin_frame:SetVisible( true )
		communityAdmin_frame:SetDraggable( false )
		communityAdmin_frame:ShowCloseButton( true )
		communityAdmin_frame:MakePopup()
		communityAdmin_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", communityAdmin_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_3b.png" )
			screenBG:SetSize(communityAdmin_frame:GetWide(), communityAdmin_frame:GetTall())
		
		local PaneLabel = vgui.Create("DLabel", communityAdmin_frame)
			PaneLabel:SetPos(50,40)
			PaneLabel:SetColor( Color( 255, 255, 255, 255 ) )
			PaneLabel:SetText( "Communities on the Server" )
			PaneLabel:SizeToContents()
					
		local comList = vgui.Create("DPanelList", communityAdmin_frame)
			comList:SetPos(40, 70)
			comList:SetSize(communityAdmin_frame:GetWide() - 225, communityAdmin_frame:GetTall() - 120)
			comList:EnableVerticalScrollbar(true) 
			comList:EnableHorizontal(false) 
			comList:SetSpacing(1)
			comList:SetPadding(10)
			comList.Paint = function()
			--	draw.RoundedBox( 8, 0, 0, cMemberList:GetWide(), cMemberList:GetTall(), Color( 50, 50, 50, 255 ) )
			end
			for k, v in pairs( communityTable ) do
				local comPanel = vgui.Create("DPanel")
					comPanel:SetTall(75)
					comPanel.Paint = function()			
						draw.RoundedBox( 6, 0, 0, comPanel:GetWide(), comPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
					end
					comList:AddItem(comPanel)
					
					comPanel.Title = vgui.Create("DLabel", comPanel)
					comPanel.Title:SetPos(5, 5)
					comPanel.Title:SetText(v["cname"])
					comPanel.Title:SetColor(Color( 255, 255, 255, 255 ))
					comPanel.Title:SizeToContents() 
					comPanel.Title:SetContentAlignment( 5 )
					
					comPanel.Founded = vgui.Create("DLabel", comPanel)
					comPanel.Founded:SetPos(5, 25)
					comPanel.Founded:SetText("Founded: "..v["founded"])
					comPanel.Founded:SetColor(Color( 255, 255, 255, 255 ))
					comPanel.Founded:SizeToContents() 
					comPanel.Founded:SetContentAlignment( 5 )
					
					comPanel.EditBtn = vgui.Create("DButton", comPanel )
					comPanel.EditBtn:SetPos(345, 5)
					comPanel.EditBtn:SetSize(100,17)
					comPanel.EditBtn:SetText( "Edit Community" )
					comPanel.EditBtn.DoClick = function() 
						RunConsoleCommand( "pnrp_AdmEditCom", v["cid"] )
						communityAdmin_frame:Close() 
					end
					
					comPanel.DelteBtn = vgui.Create("DButton", comPanel )
					comPanel.DelteBtn:SetPos(345, 25)
					comPanel.DelteBtn:SetSize(100,17)
					comPanel.DelteBtn:SetText( "Delete Community" )
					comPanel.DelteBtn.DoClick = function() 
						PNRP.OptionVerify( "pnrp_AdminDelCom", v["cid"], "pnrp_communityAdmin", communityAdmin_frame ) 
					--	RunConsoleCommand( "pnrp_communityAdmin" ) 
					end
			end
end
net.Receive( "pnrp_OpenCommAdminWindow", GM.communityAdminMenu )

local communityEdit_frame
local comEditFrame = false
--Main Community Menu
function GM.communityEdit_window( )
	if comEditFrame then return end 
	local communityTable = net.ReadTable()
	local cid = net.ReadString()
	local communityName = communityTable["name"]

	local communityUsers = communityTable["users"]
	local communityCount
	local CommuntityError = false
	comEditFrame = true
	communityCount = "none"

	if communityName then
		communityCount = table.getn(communityUsers) + 1
		communityName = " Editing Community: "..communityName
	else
		communityName = "Error Pulling Community Data"
		CommuntityError = true
	end
	
	communityEdit_frame = vgui.Create( "DFrame" )
		communityEdit_frame:SetSize( 710, 520 ) 
		communityEdit_frame:SetPos(ScrW() / 2 - communityEdit_frame:GetWide() / 2, ScrH() / 2 - communityEdit_frame:GetTall() / 2)
		communityEdit_frame:SetTitle( " " )
		communityEdit_frame:SetVisible( true )
		communityEdit_frame:SetDraggable( false )
		communityEdit_frame:ShowCloseButton( false )
		communityEdit_frame:MakePopup()
		communityEdit_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", communityEdit_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_4b.png" )
			screenBG:SetSize(communityEdit_frame:GetWide(), communityEdit_frame:GetTall())	
		
			
			local UCommunityNameLabel = vgui.Create("DLabel", communityEdit_frame)
					UCommunityNameLabel:SetPos(50,40)
					UCommunityNameLabel:SetColor( Color( 255, 255, 255, 255 ) )
					UCommunityNameLabel:SetText( communityName )
					UCommunityNameLabel:SizeToContents()
					
			local UCommunityCountLabel = vgui.Create("DLabel", communityEdit_frame)
					UCommunityCountLabel:SetPos(275,55)
					UCommunityCountLabel:SetColor( Color( 255, 255, 255, 255 ) )
					UCommunityCountLabel:SetText( "Member Count: "..communityCount )
					UCommunityCountLabel:SizeToContents()
			
			if CommuntityError then
			
			
			else
				--//List of Current Members	
				local cMemberList = vgui.Create("DPanelList", communityEdit_frame)
					cMemberList:SetPos(40, 70)
					cMemberList:SetSize(communityEdit_frame:GetWide() - 350, communityEdit_frame:GetTall() - 120)
					cMemberList:EnableVerticalScrollbar(true) 
					cMemberList:EnableHorizontal(false) 
					cMemberList:SetSpacing(1)
					cMemberList:SetPadding(10)
					cMemberList.Paint = function()
					--	draw.RoundedBox( 8, 0, 0, cMemberList:GetWide(), cMemberList:GetTall(), Color( 50, 50, 50, 255 ) )
					end
					if communityName != "none" then
						--table.sort(communityUsers, function(a["rank"],b["rank"]) return a["rank"]>b["rank"] end)
						for k, v in pairs( communityUsers ) do		
								
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
							
							MemberPanel.LastOn = vgui.Create("DLabel", MemberPanel)
							MemberPanel.LastOn:SetPos(90, 55)
							MemberPanel.LastOn:SetText("Last On: "..v["lastlog"])
							MemberPanel.LastOn:SetColor(Color( 0, 0, 0, 255 ))
							MemberPanel.LastOn:SizeToContents() 
							MemberPanel.LastOn:SetContentAlignment( 5 )
														
							MemberPanel.PromoteBtn = vgui.Create("DButton", MemberPanel )
							MemberPanel.PromoteBtn:SetPos(255, 5)
							MemberPanel.PromoteBtn:SetSize(75,17)
							MemberPanel.PromoteBtn:SetText( "Promote" )
							MemberPanel.PromoteBtn.DoClick = function() 
								RunConsoleCommand( "pnrp_rankcomm", v["name"], v["rank"] + 1 )
								communityEdit_frame:Close() 
								RunConsoleCommand( "pnrp_AdmEditCom", cid )
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
								communityEdit_frame:Close() 
								RunConsoleCommand( "pnrp_AdmEditCom", cid )
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
								communityEdit_frame:Close() 
								RunConsoleCommand( "pnrp_OpenCommunity" )
							end					
						end
					end
			end
		--//Community Main Menu
								
					local btnHPos = 50
					local btnHeight = 40
					local lblColor = Color( 245, 218, 210, 180 )
							
										
					local disbandBtn = vgui.Create("DImageButton", communityEdit_frame)
						disbandBtn:SetPos( communityEdit_frame:GetWide()-260,btnHPos )
						disbandBtn:SetSize(30,30)
						disbandBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
						disbandBtn.DoClick = function() 
							PNRP.OptionVerify( "pnrp_AdminDelCom", cid, "pnrp_communityAdmin", communityEdit_frame ) 
						end	
						disbandBtn.Paint = function()
							if disbandBtn:IsDown() then 
								disbandBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
							else
								disbandBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
							end
						end
						
					local disbandBtnLbl = vgui.Create("DLabel", communityEdit_frame)
						disbandBtnLbl:SetPos( communityEdit_frame:GetWide()-210,btnHPos+2 )
						disbandBtnLbl:SetColor( lblColor )
						disbandBtnLbl:SetText( "Disband Community" )
						disbandBtnLbl:SetFont("Trebuchet24")
						disbandBtnLbl:SizeToContents()	
						
					btnHPos = btnHPos + btnHeight --Blank Space
					
					btnHPos = btnHPos + btnHeight
					local editStockBtn = vgui.Create("DImageButton", communityEdit_frame)
						editStockBtn:SetPos( communityEdit_frame:GetWide()-260,btnHPos )
						editStockBtn:SetSize(30,30)
						if CommuntityError then
							editStockBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						else
							editStockBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
							editStockBtn.DoClick = function() 
							--	RunConsoleCommand( "pnrp_placestock" ) 
								communityEdit_frame:Close()
							end
							editStockBtn.Paint = function()
								if editStockBtn:IsDown() then 
									editStockBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
								else
									editStockBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
								end
							end
						end
					local editStockBtnLbl = vgui.Create("DLabel", communityEdit_frame)
						editStockBtnLbl:SetPos( communityEdit_frame:GetWide()-210,btnHPos+2 )
						editStockBtnLbl:SetColor( lblColor )
						editStockBtnLbl:SetText( "Edit Stockpile" )
						editStockBtnLbl:SetFont("Trebuchet24")
						editStockBtnLbl:SizeToContents()
						
					btnHPos = btnHPos + btnHeight
					local editLockerBtn = vgui.Create("DImageButton", communityEdit_frame)
						editLockerBtn:SetPos( communityEdit_frame:GetWide()-260,btnHPos )
						editLockerBtn:SetSize(30,30)
						if CommuntityError then
							editLockerBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						else
							editLockerBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
							editLockerBtn.DoClick = function() 
								--	RunConsoleCommand( "pnrp_placelocker" ) 
									communityEdit_frame:Close()
							end
							editLockerBtn.Paint = function()
								if editLockerBtn:IsDown() then 
									editLockerBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
								else
									editLockerBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
								end
							end
						end
					local editLockerBtnLbl = vgui.Create("DLabel", communityEdit_frame)
						editLockerBtnLbl:SetPos( communityEdit_frame:GetWide()-210,btnHPos+2 )
						editLockerBtnLbl:SetColor( lblColor )
						editLockerBtnLbl:SetText( "Edit Locker" )
						editLockerBtnLbl:SetFont("Trebuchet24")
						editLockerBtnLbl:SizeToContents()
					
					btnHPos = btnHPos + btnHeight --Blank Space
					
					btnHPos = btnHPos + btnHeight
					local comAdminBtn = vgui.Create("DImageButton", communityEdit_frame)
						comAdminBtn:SetPos( communityEdit_frame:GetWide()-260,btnHPos )
						comAdminBtn:SetSize(30,30)
						comAdminBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
						comAdminBtn.DoClick = function() 
							RunConsoleCommand( "pnrp_communityAdmin" ) 
							communityEdit_frame:Close()
						end	
						comAdminBtn.Paint = function()
							if comAdminBtn:IsDown() then 
								comAdminBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
							else
								comAdminBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
							end
						end
					local comAdminBtnLbl = vgui.Create("DLabel", communityEdit_frame)
						comAdminBtnLbl:SetPos( communityEdit_frame:GetWide()-210,btnHPos+2 )
						comAdminBtnLbl:SetColor( lblColor )
						comAdminBtnLbl:SetText( "Communities Admin" )
						comAdminBtnLbl:SetFont("Trebuchet24")
						comAdminBtnLbl:SizeToContents()	
						
					
	function communityEdit_frame:Close()                  
		comEditFrame = false                  
		self:SetVisible( false )                  
		self:Remove()          
	end 
end
net.Receive( "pnrp_OpenEditCommunityWindow", GM.communityEdit_window )

function GM.initPlyAdminLst(ply)
	if ply:IsAdmin() then	
		RunConsoleCommand("pnrp_OpenPlyAdminLst")
	else
		ply:ChatPrint("You are not an admin on this server!")
	end

end
--concommand.Add( "pnrp_playerAdminList",  GM.initPlyAdminLst )

--EOF