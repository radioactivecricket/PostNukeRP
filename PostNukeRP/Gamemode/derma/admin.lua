local admin_frame
local pp_frame

function GM.open_admin(handler, id, encoded, decoded)
	local GM = GAMEMODE
	local ply = LocalPlayer()
	local GMSettings = decoded["GMSettings"]
	local SpawnSettings = decoded["SpawnSettings"]
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
			ppmenu.DoClick = function() datastream.StreamToServer( "Start_open_PropProtection" ) SCFrame=false admin_frame:Close() end 
		
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
				
				local E2RestrictLabel= vgui.Create("DLabel", GModeSettingsList)
					E2RestrictLabel:SetText("E2 Restriction:  (Def: 1)" )
					E2RestrictLabel:SizeToContents()
				GModeSettingsList:AddItem( E2RestrictLabel )
					
				local E2RestrictSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    E2RestrictSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    E2RestrictSlider:SetText( "0 - None, 1 - Admin, 2 - Engineer, 3 - Engineer/Science, 4 - Everyone" )
				    E2RestrictSlider:SetMin( 0 )
				    E2RestrictSlider:SetMax( 4 )
				    E2RestrictSlider:SetDecimals( 0 )
				    E2RestrictSlider:SetValue( GMSettings.E2Restrict )
				GModeSettingsList:AddItem( E2RestrictSlider )				
				
				local ToolRestrictLabel= vgui.Create("DLabel", GModeSettingsList)
					ToolRestrictLabel:SetText("Tool Restriction:  (Def: 2)" )
					ToolRestrictLabel:SizeToContents()
				GModeSettingsList:AddItem( ToolRestrictLabel )
					
				local ToolRestrictSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    ToolRestrictSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    ToolRestrictSlider:SetText( "0 - None, 1 - Admin, 2 - Engineer, 3 - Engineer/Science, 4 - Everyone" )
				    ToolRestrictSlider:SetMin( 0 )
				    ToolRestrictSlider:SetMax( 4 )
				    ToolRestrictSlider:SetDecimals( 0 )
				    ToolRestrictSlider:SetValue( GMSettings.ToolLevel )
				GModeSettingsList:AddItem( ToolRestrictSlider )
				
				local adminCreateAllTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					adminCreateAllTgl:SetText( "Admin can create all." )
					adminCreateAllTgl:SetValue( GMSettings.AdminCreateAll )
					adminCreateAllTgl:SizeToContents() 
				GModeSettingsList:AddItem( adminCreateAllTgl )
				
				local adminTouchAllTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					adminTouchAllTgl:SetText( "Admin can touch all." )
					adminTouchAllTgl:SetValue( GMSettings.AdminTouchAll )
					adminTouchAllTgl:SizeToContents() 
				GModeSettingsList:AddItem( adminTouchAllTgl )
				
				local adminNoCostTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					adminNoCostTgl:SetText( "Admin No Cost." )
					adminNoCostTgl:SetValue( GMSettings.AdminNoCost )
					adminNoCostTgl:SizeToContents() 
				GModeSettingsList:AddItem( adminNoCostTgl )
				
				local propBanningTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					propBanningTgl:SetText( "Prop Banning." )
					propBanningTgl:SetValue( GMSettings.PropBanning )
					propBanningTgl:SizeToContents() 
				GModeSettingsList:AddItem( propBanningTgl )
				
				local propAllowingTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					propAllowingTgl:SetText( "Prop Allowing." )
					propAllowingTgl:SetValue( GMSettings.PropAllowing )
					propAllowingTgl:SizeToContents() 
				GModeSettingsList:AddItem( propAllowingTgl )
				
				local propSpawnProtectTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					propSpawnProtectTgl:SetText( "Player Spawn Prtection." )
					propSpawnProtectTgl:SetValue( GMSettings.PropSpawnProtection )
					propSpawnProtectTgl:SizeToContents() 
				GModeSettingsList:AddItem( propSpawnProtectTgl )
				
				local plyDeathZombieTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					plyDeathZombieTgl:SetText( "Player Death Zombie Spawn." )
					plyDeathZombieTgl:SetValue( GMSettings.PlyDeathZombie )
					plyDeathZombieTgl:SizeToContents() 
				GModeSettingsList:AddItem( plyDeathZombieTgl )
				
				local PropExpTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					PropExpTgl:SetText( "Player Exp from Prop Kills." )
					PropExpTgl:SetValue( GMSettings.PropExp )
					PropExpTgl:SizeToContents() 
				GModeSettingsList:AddItem( PropExpTgl )
				
				local propPayTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					propPayTgl:SetText( "Pay for Props from Q Menu.." )
					propPayTgl:SetValue( GMSettings.PropPay )
					propPayTgl:SizeToContents() 
				GModeSettingsList:AddItem( propPayTgl )
				
				local propCostSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    propCostSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    propCostSlider:SetText( "Q Menu Prop Cost (Def 10) [Affects Adv Dupe]" )
				    propCostSlider:SetMin( 0 )
				    propCostSlider:SetMax( 100 )
				    propCostSlider:SetDecimals( 0 )
					propCostSlider:SetValue( GMSettings.PropCost )
				GModeSettingsList:AddItem( propCostSlider )
				
				local voiceLimitTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					voiceLimitTgl:SetText( "Voice Range Limiter" )
					voiceLimitTgl:SetValue( GMSettings.VoiceLimiter )
					voiceLimitTgl:SizeToContents() 
				GModeSettingsList:AddItem( voiceLimitTgl )
				
				local voiceLimitSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    voiceLimitSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    voiceLimitSlider:SetText( "Voice Limit Range (Def 750)" )
				    voiceLimitSlider:SetMin( 0 )
				    voiceLimitSlider:SetMax( 2000 )
				    voiceLimitSlider:SetDecimals( 0 )
				    voiceLimitSlider:SetValue( GMSettings.VoiceDistance )
				GModeSettingsList:AddItem( voiceLimitSlider )
				
				local classCostTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					classCostTgl:SetText( "Charg for Class Change" )
					classCostTgl:SetValue( GMSettings.ClassChangePay )
					classCostTgl:SizeToContents() 
				GModeSettingsList:AddItem( classCostTgl )
				
				local classCostSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    classCostSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    classCostSlider:SetText( "Class Change Cost (Def 10)" )
				    classCostSlider:SetMin( 0 )
				    classCostSlider:SetMax( 100 )
				    classCostSlider:SetDecimals( 0 )
				    classCostSlider:SetValue( GMSettings.ClassChangeCost )
				GModeSettingsList:AddItem( classCostSlider )
				
				local deathCostTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					deathCostTgl:SetText( "Charg for Death Penalty" )
					deathCostTgl:SetValue( GMSettings.DeathPay )
					deathCostTgl:SizeToContents() 
				GModeSettingsList:AddItem( deathCostTgl )
				
				local deathCostSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    deathCostSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    deathCostSlider:SetText( "Death Penalty Cost (Def 10)" )
				    deathCostSlider:SetMin( 0 )
				    deathCostSlider:SetMax( 100 )
				    deathCostSlider:SetDecimals( 0 )
				    deathCostSlider:SetValue( GMSettings.DeathCost )
				GModeSettingsList:AddItem( deathCostSlider )
				
				local ownDoorsSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    ownDoorsSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    ownDoorsSlider:SetText( "Number of doors that can be owned (Def 3)" )
				    ownDoorsSlider:SetMin( 0 )
				    ownDoorsSlider:SetMax( 10 )
				    ownDoorsSlider:SetDecimals( 0 )
				    ownDoorsSlider:SetValue( GMSettings.MaxOwnDoors )
				GModeSettingsList:AddItem( ownDoorsSlider )
								
			AdminTabSheet:AddSheet( "GMode Settings", GModeSettingsList, "gui/silkicons/bomb", false, false, "GMode Settings" )	
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
					mobSpawnerTgl:SetValue( SpawnSettings.SpawnMobs )
					mobSpawnerTgl:SizeToContents() 
				MobCategoryList:AddItem( mobSpawnerTgl )
				
				local maxZombiesSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxZombiesSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxZombiesSlider:SetText( "Max Zombies (Default 30)" )
				    maxZombiesSlider:SetMin( 0 )
				    maxZombiesSlider:SetMax( 100 )
				    maxZombiesSlider:SetDecimals( 0 )
				    maxZombiesSlider:SetValue( SpawnSettings.MaxZombies )
				MobCategoryList:AddItem( maxZombiesSlider )
				
				local maxFastZombiesSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxFastZombiesSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxFastZombiesSlider:SetText( "Max Fast Zombies (Default 5)" )
				    maxFastZombiesSlider:SetMin( 0 )
				    maxFastZombiesSlider:SetMax( 100 )
				    maxFastZombiesSlider:SetDecimals( 0 )
				    maxFastZombiesSlider:SetValue( SpawnSettings.MaxFastZombies )
				MobCategoryList:AddItem( maxFastZombiesSlider )
				
				local maxPoisonZombiesSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxPoisonZombiesSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxPoisonZombiesSlider:SetText( "Max Poison Zombies (Default 2)" )
				    maxPoisonZombiesSlider:SetMin( 0 )
				    maxPoisonZombiesSlider:SetMax( 100 )
				    maxPoisonZombiesSlider:SetDecimals( 0 )
				    maxPoisonZombiesSlider:SetValue( SpawnSettings.MaxPoisonZombs )
				MobCategoryList:AddItem( maxPoisonZombiesSlider )
				
				local maxAntlionsSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxAntlionsSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxAntlionsSlider:SetText( "Max Antlions (Default 10)" )
				    maxAntlionsSlider:SetMin( 0 )
				    maxAntlionsSlider:SetMax( 100 )
				    maxAntlionsSlider:SetDecimals( 0 )
				    maxAntlionsSlider:SetValue( SpawnSettings.MaxAntlions )
				MobCategoryList:AddItem( maxAntlionsSlider )
				
				local maxAntGuardSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxAntGuardSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxAntGuardSlider:SetText( "Max Ant Guard (Default 1)" )
				    maxAntGuardSlider:SetMin( 0 )
				    maxAntGuardSlider:SetMax( 100 )
				    maxAntGuardSlider:SetDecimals( 0 )
				    maxAntGuardSlider:SetValue( SpawnSettings.MaxAntGuards )
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
				    maxMounds:SetMin( 0 )
				    maxMounds:SetMax( 100 )
				    maxMounds:SetDecimals( 0 )
				    maxMounds:SetValue( SpawnSettings.MaxAntMounds )
				MoundCategoryList:AddItem( maxMounds )
				
				local moundSpawnRate = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundSpawnRate:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundSpawnRate:SetText( "Mound Spawn Rate (Default 5min)" )
				    moundSpawnRate:SetMin( 0 )
				    moundSpawnRate:SetMax( 100 )
				    moundSpawnRate:SetDecimals( 0 )
				    moundSpawnRate:SetValue( SpawnSettings.AntMoundRate )
				MoundCategoryList:AddItem( moundSpawnRate )
				
				local moundSpawnChance = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundSpawnChance:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundSpawnChance:SetText( "Mound Spawn Chance (Default 15%)" )
				    moundSpawnChance:SetMin( 0 )
				    moundSpawnChance:SetMax( 100 )
				    moundSpawnChance:SetDecimals( 0 )
				    moundSpawnChance:SetValue( SpawnSettings.AntMoundChance )
				MoundCategoryList:AddItem( moundSpawnChance )
				
				local moundMaxAntlions = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundMaxAntlions:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundMaxAntlions:SetText( "Mound Max Antlions (Default 10)" )
				    moundMaxAntlions:SetMin( 0 )
				    moundMaxAntlions:SetMax( 100 )
				    moundMaxAntlions:SetDecimals( 0 )
				    moundMaxAntlions:SetValue( SpawnSettings.MaxMoundAntlions )
				MoundCategoryList:AddItem( moundMaxAntlions )
				
				local moundAntlionsPerCycle = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundAntlionsPerCycle:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundAntlionsPerCycle:SetText( "Mound Antlions Spawned Per Cycle (Default 5)" )
				    moundAntlionsPerCycle:SetMin( 0 )
				    moundAntlionsPerCycle:SetMax( 100 )
				    moundAntlionsPerCycle:SetDecimals( 0 )
				    moundAntlionsPerCycle:SetValue( SpawnSettings.MoundAntlionsPerCycle )
				MoundCategoryList:AddItem( moundAntlionsPerCycle )
				
				local moundMaxAntlionGuards = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundMaxAntlionGuards:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundMaxAntlionGuards:SetText( "Mound Max Antlion Guards (Default 1)" )
				    moundMaxAntlionGuards:SetMin( 0 )
				    moundMaxAntlionGuards:SetMax( 100 )
				    moundMaxAntlionGuards:SetDecimals( 0 )
				    moundMaxAntlionGuards:SetValue( SpawnSettings.MaxMoundGuards )
				MoundCategoryList:AddItem( moundMaxAntlionGuards )
				
				local moundMobRate = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundMobRate:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundMobRate:SetText( "Mound NPC Spawn Rate (Default 5min)" )
				    moundMobRate:SetMin( 0 )
				    moundMobRate:SetMax( 100 )
				    moundMobRate:SetDecimals( 0 )
				    moundMobRate:SetValue( SpawnSettings.AntMoundMobRate )
				MoundCategoryList:AddItem( moundMobRate )
				
				local moundGuardChance = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundGuardChance:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundGuardChance:SetText( "Mound Guard Spawn Chance (Default 10%)" )
				    moundGuardChance:SetMin( 0 )
				    moundGuardChance:SetMax( 100 )
				    moundGuardChance:SetDecimals( 0 )
				    moundGuardChance:SetValue( SpawnSettings.MoundGuardChance )
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
				    maxReproducedRes:SetMin( 0 )
				    maxReproducedRes:SetMax( 100 )
				    maxReproducedRes:SetDecimals( 0 )
				    maxReproducedRes:SetValue( SpawnSettings.MaxReproducedRes )
				RecCategoryList:AddItem( maxReproducedRes )
				
				SpawnerList:AddItem( RecSpawnerSettingsCats )
		
		AdminTabSheet:AddSheet( "Spawn Settings", SpawnerList, "gui/silkicons/bomb", false, false, "Spawn Settings" )
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
		
		AdminTabSheet:AddSheet( "Mob Grid Settings", mobGridSetup, "gui/silkicons/bomb", false, false, "Mob Grid Settings" )
		
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
				
				datastream.StreamToServer( "UpdateFromAdminMenu", { ["GMSettings"] = GMSettings, ["SpawnSettings"] = SpawnSettings })
			end 
	else
		ply:ChatPrint("You are not an admin on this server!")
	end
end
datastream.Hook( "pnrp_OpenAdminWindow", GM.open_admin )
--concommand.Add( "pnrp_admin_window", GM.open_admin )

function GM.initAdmin(ply)
	if ply:IsAdmin() then	
		RunConsoleCommand("pnrp_OpenAdmin")
	else
		ply:ChatPrint("You are not an admin on this server!")
	end

end
concommand.Add( "pnrp_admin_window",  GM.initAdmin )

-----------------------------------------------------------------------------
function GM.OpenPropProtectWindow( handler, id, encoded, decoded )
	local BannedPropList = decoded[1]
	local AllowedPropList = decoded[2]		
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
			local pnlBList = vgui.Create("DPanelList", pBanPanel)
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
							datastream.StreamToServer("PropProtect_AddItem", {model, 1} ) 
							pp_frame:Close()
							datastream.StreamToServer( "Start_open_PropProtection" )
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
			pp_TabSheet:AddSheet( "Banned Props List", pBanPanel, "gui/silkicons/brick_add", false, false, "Banned Props List" )
			
			--//Allowed Prop List//--
			local pAllowedPanel = vgui.Create( "DPanel", pp_TabSheet )
				pAllowedPanel:SetPos( 5, 5 )
				pAllowedPanel:SetSize( pp_TabSheet:GetWide(), pp_TabSheet:GetTall() )
				pAllowedPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 50, 50, 50, 0 )
				end
			local pnlAList = vgui.Create("DPanelList", pAllowedPanel)
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
							datastream.StreamToServer("PropProtect_AddItem", {model, 2} ) 
							pp_frame:Close()
							datastream.StreamToServer( "Start_open_PropProtection" )
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
			pp_TabSheet:AddSheet( "Allowed Props List", pAllowedPanel, "gui/silkicons/brick_add", false, false, "Allowed Props List" )
	end
end
datastream.Hook( "pnrp_OpenPropProtectWindow", GM.OpenPropProtectWindow )

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
						datastream.StreamToServer( "PropProtect_RemoveItem", {model, switch}) 
						ppv_frame:Close() 
						pp_frame:Close() 
						datastream.StreamToServer( "Start_open_PropProtection" )
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
function GM.OpenPlyAdminLstWindow(handler, id, encoded, decoded)
	local GM = GAMEMODE
	local ply = LocalPlayer()
	local Players = decoded["Players"]
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
datastream.Hook( "pnrp_OpenPlyAdminLstWindow", GM.OpenPlyAdminLstWindow )

function GM.initPlyAdminLst(ply)
	if ply:IsAdmin() then	
		RunConsoleCommand("pnrp_OpenPlyAdminLst")
	else
		ply:ChatPrint("You are not an admin on this server!")
	end

end
--concommand.Add( "pnrp_playerAdminList",  GM.initPlyAdminLst )

--EOF