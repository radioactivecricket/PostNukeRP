local admin_frame
local pp_frame

function GM.open_admin(ply)
	local GM = GAMEMODE
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
			
		local AdminTabSheet = vgui.Create( "DPropertySheet" )
			AdminTabSheet:SetParent( admin_frame )
			AdminTabSheet:SetPos( 5, 50 )
			AdminTabSheet:SetSize( admin_frame:GetWide() - 10, admin_frame:GetTall() - 60 ) 
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
				    E2RestrictSlider:SetValue( GetConVar("pnrp_exp2Level"):GetInt() )
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
				    ToolRestrictSlider:SetValue( GetConVar("pnrp_toolLevel"):GetInt() )
				GModeSettingsList:AddItem( ToolRestrictSlider )
				
				local adminCreateAllTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					adminCreateAllTgl:SetText( "Admin can create all." )
					adminCreateAllTgl:SetValue( GetConVar("pnrp_adminCreateAll"):GetInt() )
					adminCreateAllTgl:SizeToContents() 
				GModeSettingsList:AddItem( adminCreateAllTgl )
				
				local adminTouchAllTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					adminTouchAllTgl:SetText( "Admin can touch all." )
					adminTouchAllTgl:SetValue( GetConVar("pnrp_adminTouchAll"):GetInt() )
					adminTouchAllTgl:SizeToContents() 
				GModeSettingsList:AddItem( adminTouchAllTgl )
				
				local adminNoCostTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					adminNoCostTgl:SetText( "Admin No Cost." )
					adminNoCostTgl:SetValue( GetConVar("pnrp_adminNoCost"):GetInt() )
					adminNoCostTgl:SizeToContents() 
				GModeSettingsList:AddItem( adminNoCostTgl )
				
				local propBanningTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					propBanningTgl:SetText( "Prop Banning." )
					propBanningTgl:SetValue( GetConVar("pnrp_propBanning"):GetInt() )
					propBanningTgl:SizeToContents() 
				GModeSettingsList:AddItem( propBanningTgl )
				
				local propAllowingTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					propAllowingTgl:SetText( "Prop Allowing." )
					propAllowingTgl:SetValue( GetConVar("pnrp_propAllowing"):GetInt() )
					propAllowingTgl:SizeToContents() 
				GModeSettingsList:AddItem( propAllowingTgl )
				
				local propSpawnProtectTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					propSpawnProtectTgl:SetText( "Player Spawn Prtection." )
					propSpawnProtectTgl:SetValue( GetConVar("pnrp_propSpawnpointProtection"):GetInt() )
					propSpawnProtectTgl:SizeToContents() 
				GModeSettingsList:AddItem( propSpawnProtectTgl )
				
				local plyDeathZombieTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					plyDeathZombieTgl:SetText( "Player Death Zombie Spawn." )
					plyDeathZombieTgl:SetValue( GetConVar("pnrp_PlyDeathZombie"):GetInt() )
					plyDeathZombieTgl:SizeToContents() 
				GModeSettingsList:AddItem( plyDeathZombieTgl )
				
				local propPayTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					propPayTgl:SetText( "Pay for Props from Q Menu.." )
					propPayTgl:SetValue( GetConVar("pnrp_propPay"):GetInt() )
					propPayTgl:SizeToContents() 
				GModeSettingsList:AddItem( propPayTgl )
				
				local propCostSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    propCostSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    propCostSlider:SetText( "Q Menu Prop Cost (Def 10) [Affects Adv Dupe]" )
				    propCostSlider:SetMin( 0 )
				    propCostSlider:SetMax( 100 )
				    propCostSlider:SetDecimals( 0 )
				    propCostSlider:SetValue( GetConVar("pnrp_propCost"):GetInt() )
				GModeSettingsList:AddItem( propCostSlider )
				
				local voiceLimitTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					voiceLimitTgl:SetText( "Voice Range Limiter" )
					voiceLimitTgl:SetValue( GetConVar("pnrp_voiceLimit"):GetInt() )
					voiceLimitTgl:SizeToContents() 
				GModeSettingsList:AddItem( voiceLimitTgl )
				
				local voiceLimitSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    voiceLimitSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    voiceLimitSlider:SetText( "Voice Limit Range (Def 750)" )
				    voiceLimitSlider:SetMin( 0 )
				    voiceLimitSlider:SetMax( 2000 )
				    voiceLimitSlider:SetDecimals( 0 )
				    voiceLimitSlider:SetValue( GetConVar("pnrp_voiceDist"):GetInt() )
				GModeSettingsList:AddItem( voiceLimitSlider )
				
				local classCostTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					classCostTgl:SetText( "Charg for Class Change" )
					classCostTgl:SetValue( GetConVar("pnrp_classChangePay"):GetInt() )
					classCostTgl:SizeToContents() 
				GModeSettingsList:AddItem( classCostTgl )
				
				local classCostSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    classCostSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    classCostSlider:SetText( "Class Change Cost (Def 10)" )
				    classCostSlider:SetMin( 0 )
				    classCostSlider:SetMax( 100 )
				    classCostSlider:SetDecimals( 0 )
				    classCostSlider:SetValue( GetConVar("pnrp_classChangeCost"):GetInt() )
				GModeSettingsList:AddItem( classCostSlider )
				
				local deathCostTgl = vgui.Create( "DCheckBoxLabel", GModeSettingsList )
					deathCostTgl:SetText( "Charg for Death Penalty" )
					deathCostTgl:SetValue( GetConVar("pnrp_deathPay"):GetInt() )
					deathCostTgl:SizeToContents() 
				GModeSettingsList:AddItem( deathCostTgl )
				
				local deathCostSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    deathCostSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    deathCostSlider:SetText( "Death Penalty Cost (Def 10)" )
				    deathCostSlider:SetMin( 0 )
				    deathCostSlider:SetMax( 100 )
				    deathCostSlider:SetDecimals( 0 )
				    deathCostSlider:SetValue( GetConVar("pnrp_deathCost"):GetInt() )
				GModeSettingsList:AddItem( deathCostSlider )
				
				local ownDoorsSlider = vgui.Create( "DNumSlider", GModeSettingsList )
				    ownDoorsSlider:SetSize( GModeSettingsList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    ownDoorsSlider:SetText( "Number of doors that can be owned (Def 3)" )
				    ownDoorsSlider:SetMin( 0 )
				    ownDoorsSlider:SetMax( 10 )
				    ownDoorsSlider:SetDecimals( 0 )
				    ownDoorsSlider:SetValue( GetConVar("pnrp_maxOwnDoors"):GetInt() )
				GModeSettingsList:AddItem( ownDoorsSlider )
					
				--Saves the Settings from the GMode Settings
				local GModeSettingsSaveBTN = vgui.Create("DButton", SpawnerList )
				    GModeSettingsSaveBTN:SetText( "Save Settings" )
				    GModeSettingsSaveBTN.DoClick = function()
				    	local adminCreateAllOnOff
				    	local adminTouchAllOnOff
				    	local adminNoCostOnOff
				    	local propBanningOnOff
				    	local propAllowingOnOff
				    	local propPayOnOff
				    	local voiceLimitOnOff
				    	local classCostOnOff
				    	local deathCostOnOff
						local plyDeathZombieTglOnOff
				    	if adminCreateAllTgl:GetChecked(true) then
				    		adminCreateAllOnOff = 1
				    	else
				    		adminCreateAllOnOff = 0
				    	end
				    	if adminTouchAllTgl:GetChecked(true) then
				    		adminTouchAllOnOff = 1
				    	else
				    		adminTouchAllOnOff = 0
				    	end
				    	if adminNoCostTgl:GetChecked(true) then
				    		adminNoCostOnOff = 1
				    	else
				    		adminNoCostOnOff = 0
				    	end
						if plyDeathZombieTgl:GetChecked(true) then
				    		plyDeathZombieTglOnOff = 1
				    	else
				    		plyDeathZombieTglOnOff = 0
				    	end
				    	if propBanningTgl:GetChecked(true) then
				    		propBanningOnOff = 1
				    	else
				    		propBanningOnOff = 0
				    	end
				    	if propAllowingTgl:GetChecked(true) then
				    		propAllowingOnOff = 1
				    	else
				    		propAllowingOnOff = 0
				    	end
						if propSpawnProtectTgl:GetChecked(true) then
				    		propSpawnProtectOnOff = 1
				    	else
				    		propSpawnProtectOnOff = 0
				    	end
				    	if propPayTgl:GetChecked(true) then
				    		propPayOnOff = 1
				    	else
				    		propPayOnOff = 0
				    	end
				    	if voiceLimitTgl:GetChecked(true) then
				    		voiceLimitOnOff = 1
				    	else
				    		voiceLimitOnOff = 0
				    	end
				    	if classCostTgl:GetChecked(true) then
				    		classCostOnOff = 1
				    	else
				    		classCostOnOff = 0
				    	end
				    	if deathCostTgl:GetChecked(true) then
				    		deathCostOnOff = 1
				    	else
				    		deathCostOnOff = 0
				    	end
				    	RunConsoleCommand("pnrp_RunCommand","pnrp_exp2Level",tostring(E2RestrictSlider:GetValue()))
				    	RunConsoleCommand("pnrp_RunCommand","pnrp_toolLevel",tostring(ToolRestrictSlider:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_adminCreateAll",tostring(adminCreateAllOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_adminTouchAll",tostring(adminTouchAllOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_adminNoCost",tostring(adminNoCostOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_propBanning",tostring(propBanningOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_propAllowing",tostring(propAllowingOnOff))
						RunConsoleCommand("pnrp_RunCommand","pnrp_propSpawnpointProtection",tostring(propSpawnProtectOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_propPay",tostring(propPayOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_propCost",tostring(propCostSlider:GetValue()))
						RunConsoleCommand("pnrp_RunCommand","pnrp_PlyDeathZombie",tostring(plyDeathZombieTglOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_voiceLimit",tostring(voiceLimitOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_voiceDist",tostring(voiceLimitSlider:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_classChangePay",tostring(classCostOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_classChangeCost",tostring(classCostSlider:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_deathPay",tostring(deathCostOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_deathCost",tostring(deathCostSlider:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_maxOwnDoors",tostring(ownDoorsSlider:GetValue()))
				    end
				GModeSettingsList:AddItem( GModeSettingsSaveBTN )
				
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
					mobSpawnerTgl:SetValue( GetConVar("pnrp_SpawnMobs"):GetInt() )
					mobSpawnerTgl:SizeToContents() 
				MobCategoryList:AddItem( mobSpawnerTgl )
				
				local maxZombiesSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxZombiesSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxZombiesSlider:SetText( "Max Zombies (Default 30)" )
				    maxZombiesSlider:SetMin( 0 )
				    maxZombiesSlider:SetMax( 100 )
				    maxZombiesSlider:SetDecimals( 0 )
				    maxZombiesSlider:SetValue( GetConVar("pnrp_MaxZombies"):GetInt() )
				MobCategoryList:AddItem( maxZombiesSlider )
				
				local maxFastZombiesSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxFastZombiesSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxFastZombiesSlider:SetText( "Max Fast Zombies (Default 5)" )
				    maxFastZombiesSlider:SetMin( 0 )
				    maxFastZombiesSlider:SetMax( 100 )
				    maxFastZombiesSlider:SetDecimals( 0 )
				    maxFastZombiesSlider:SetValue( GetConVar("pnrp_MaxFastZombies"):GetInt() )
				MobCategoryList:AddItem( maxFastZombiesSlider )
				
				local maxPoisonZombiesSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxPoisonZombiesSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxPoisonZombiesSlider:SetText( "Max Poison Zombies (Default 2)" )
				    maxPoisonZombiesSlider:SetMin( 0 )
				    maxPoisonZombiesSlider:SetMax( 100 )
				    maxPoisonZombiesSlider:SetDecimals( 0 )
				    maxPoisonZombiesSlider:SetValue( GetConVar("pnrp_MaxPoisonZombs"):GetInt() )
				MobCategoryList:AddItem( maxPoisonZombiesSlider )
				
				local maxAntlionsSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxAntlionsSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxAntlionsSlider:SetText( "Max Antlions (Default 10)" )
				    maxAntlionsSlider:SetMin( 0 )
				    maxAntlionsSlider:SetMax( 100 )
				    maxAntlionsSlider:SetDecimals( 0 )
				    maxAntlionsSlider:SetValue( GetConVar("pnrp_MaxAntlions"):GetInt() )
				MobCategoryList:AddItem( maxAntlionsSlider )
				
				local maxAntGuardSlider = vgui.Create( "DNumSlider", MobCategoryList )
				    maxAntGuardSlider:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxAntGuardSlider:SetText( "Max Ant Guard (Default 1)" )
				    maxAntGuardSlider:SetMin( 0 )
				    maxAntGuardSlider:SetMax( 100 )
				    maxAntGuardSlider:SetDecimals( 0 )
				    maxAntGuardSlider:SetValue( GetConVar("pnrp_MaxAntGuards"):GetInt() )
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
				    maxMounds:SetValue( GetConVar("pnrp_MaxMounds"):GetInt() )
				MoundCategoryList:AddItem( maxMounds )
				
				local moundSpawnRate = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundSpawnRate:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundSpawnRate:SetText( "Mound Spawn Rate (Default 5min)" )
				    moundSpawnRate:SetMin( 0 )
				    moundSpawnRate:SetMax( 100 )
				    moundSpawnRate:SetDecimals( 0 )
				    moundSpawnRate:SetValue( GetConVar("pnrp_MoundRate"):GetInt() )
				MoundCategoryList:AddItem( moundSpawnRate )
				
				local moundSpawnChance = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundSpawnChance:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundSpawnChance:SetText( "Mound Spawn Chance (Default 15%)" )
				    moundSpawnChance:SetMin( 0 )
				    moundSpawnChance:SetMax( 100 )
				    moundSpawnChance:SetDecimals( 0 )
				    moundSpawnChance:SetValue( GetConVar("pnrp_MoundChance"):GetInt() )
				MoundCategoryList:AddItem( moundSpawnChance )
				
				local moundMaxAntlions = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundMaxAntlions:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundMaxAntlions:SetText( "Mound Max Antlions (Default 10)" )
				    moundMaxAntlions:SetMin( 0 )
				    moundMaxAntlions:SetMax( 100 )
				    moundMaxAntlions:SetDecimals( 0 )
				    moundMaxAntlions:SetValue( GetConVar("pnrp_MaxMoundAntlions"):GetInt() )
				MoundCategoryList:AddItem( moundMaxAntlions )
				
				local moundAntlionsPerCycle = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundAntlionsPerCycle:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundAntlionsPerCycle:SetText( "Mound Antlions Spawned Per Cycle (Default 5)" )
				    moundAntlionsPerCycle:SetMin( 0 )
				    moundAntlionsPerCycle:SetMax( 100 )
				    moundAntlionsPerCycle:SetDecimals( 0 )
				    moundAntlionsPerCycle:SetValue( GetConVar("pnrp_MoundAntlionsPerCycle"):GetInt() )
				MoundCategoryList:AddItem( moundAntlionsPerCycle )
				
				local moundMaxAntlionGuards = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundMaxAntlionGuards:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundMaxAntlionGuards:SetText( "Mound Max Antlion Guards (Default 1)" )
				    moundMaxAntlionGuards:SetMin( 0 )
				    moundMaxAntlionGuards:SetMax( 100 )
				    moundMaxAntlionGuards:SetDecimals( 0 )
				    moundMaxAntlionGuards:SetValue( GetConVar("pnrp_MaxMoundGuards"):GetInt() )
				MoundCategoryList:AddItem( moundMaxAntlionGuards )
				
				local moundMobRate = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundMobRate:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundMobRate:SetText( "Mound NPC Spawn Rate (Default 5min)" )
				    moundMobRate:SetMin( 0 )
				    moundMobRate:SetMax( 100 )
				    moundMobRate:SetDecimals( 0 )
				    moundMobRate:SetValue( GetConVar("pnrp_MoundMobRate"):GetInt() )
				MoundCategoryList:AddItem( moundMobRate )
				
				local moundGuardChance = vgui.Create( "DNumSlider", MoundCategoryList )
				    moundGuardChance:SetSize( MoundSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    moundGuardChance:SetText( "Mound Guard Spawn Chance (Default 10%)" )
				    moundGuardChance:SetMin( 0 )
				    moundGuardChance:SetMax( 100 )
				    moundGuardChance:SetDecimals( 0 )
				    moundGuardChance:SetValue( GetConVar("pnrp_MoundGuardChance"):GetInt() )
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
					recSpawnerTgl:SetValue( GetConVar("pnrp_ReproduceRes"):GetInt() )
					recSpawnerTgl:SizeToContents() 
				RecCategoryList:AddItem( recSpawnerTgl )
				
				local maxReproducedRes = vgui.Create( "DNumSlider", RecCategoryList )
				    maxReproducedRes:SetSize( MobSpawnerSettingsCats:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxReproducedRes:SetText( "Max Recources (Default 20)" )
				    maxReproducedRes:SetMin( 0 )
				    maxReproducedRes:SetMax( 100 )
				    maxReproducedRes:SetDecimals( 0 )
				    maxReproducedRes:SetValue( GetConVar("pnrp_MaxReproducedRes"):GetInt() )
				RecCategoryList:AddItem( maxReproducedRes )
				
				SpawnerList:AddItem( RecSpawnerSettingsCats )
				
				--Saves the Settings from the Spawner
				local mobSettingsSaveBTN = vgui.Create("DButton", SpawnerList )
				    mobSettingsSaveBTN:SetText( "Save Settings" )
				    mobSettingsSaveBTN.DoClick = function()
				    	local mbOnOff
				    	if mobSpawnerTgl:GetChecked(true) then
				    		mbOnOff = 1
				    	else
				    		mbOnOff = 0
				    	end
				    	RunConsoleCommand("pnrp_RunCommand","pnrp_SpawnMobs",tostring(mbOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MaxZombies",tostring(maxZombiesSlider:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MaxFastZombies",tostring(maxFastZombiesSlider:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MaxPoisonZombs",tostring(maxPoisonZombiesSlider:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MaxAntlions",tostring(maxAntlionsSlider:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MaxAntGuards",tostring(maxAntGuardSlider:GetValue()))
						
						RunConsoleCommand("pnrp_RunCommand","pnrp_MaxMounds",tostring(maxMounds:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MoundRate",tostring(moundSpawnRate:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MoundChance",tostring(moundSpawnChance:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MaxMoundAntlions",tostring(moundMaxAntlions:GetValue()))
						RunConsoleCommand("pnrp_RunCommand","pnrp_MoundAntlionsPerCycle",tostring(moundAntlionsPerCycle:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MaxMoundGuards",tostring(moundMaxAntlionGuards:GetValue()))
						RunConsoleCommand("pnrp_RunCommand","pnrp_MoundMobRate",tostring(moundMobRate:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MoundGuardChance",tostring(moundGuardChance:GetValue()))
				        
				        local rcOnOff
				    	if recSpawnerTgl:GetChecked(true) then
				    		rcOnOff = 1
				    	else
				    		rcOnOff = 0
				    	end
				        RunConsoleCommand("pnrp_RunCommand","pnrp_ReproduceRes",tostring(rcOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MaxReproducedRes",tostring(maxReproducedRes:GetValue()))
				    end
				SpawnerList:AddItem( mobSettingsSaveBTN )
		
		AdminTabSheet:AddSheet( "Spawn Settings", SpawnerList, "gui/silkicons/bomb", false, false, "Spawn Settings" )
-- Mob Grid Settings		
		local mobGridRange = 1000
		
		local mobGridSetup = vgui.Create( "DPanelList", AdminTabSheet )
				mobGridSetup:SetPos( 10,10 )
				mobGridSetup:SetSize( admin_frame:GetWide() - 10, admin_frame:GetTall() - 10 )
				mobGridSetup:SetSpacing( 5 ) -- Spacing between items
				mobGridSetup:EnableHorizontal( false ) -- Only vertical items
				mobGridSetup:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis
				
		--	local maxMobGridRangeSlider = vgui.Create( "DNumSlider", mobGridSetup )
		--		    maxMobGridRangeSlider:SetSize( mobGridSetup:GetWide() - 20, 50 ) -- Keep the second number at 50
		--		    maxMobGridRangeSlider:SetText( "Max Mob Grid Range (Default 1000)" )
		--		    maxMobGridRangeSlider:SetMin( 0 )
		--		    maxMobGridRangeSlider:SetMax( 10000 )
		--		    maxMobGridRangeSlider:SetDecimals( 0 )
		--		    maxMobGridRangeSlider:SetValue( mobGridRange )
		--		mobGridSetup:AddItem( maxMobGridRangeSlider )
				
		--	local mPGridBTN = vgui.Create("DButton", mobGridSetup )
		--		    mPGridBTN:SetText( "Place Grid Node" )
		--		    mPGridBTN.DoClick = function()
		--		    	mobGridRange=maxMobGridRangeSlider:GetValue()
		--		        RunConsoleCommand("pnrp_mobsp" , mobGridRange)
		--		    end
		--		mobGridSetup:AddItem( mPGridBTN )
				
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
	else
		ply:ChatPrint("You are not an admin on this server!")
	end
end
concommand.Add( "pnrp_admin_window", GM.open_admin )

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
--EOF