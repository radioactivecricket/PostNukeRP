local admin_frame

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
						
		local AdminTabSheet = vgui.Create( "DPropertySheet" )
			AdminTabSheet:SetParent( admin_frame )
			AdminTabSheet:SetPos( 5, 50 )
			AdminTabSheet:SetSize( admin_frame:GetWide() - 10, admin_frame:GetTall() - 60 )
--Server Settings
			local GModeSettingsList = vgui.Create( "DPanelList", AdminTabSheet )
				GModeSettingsList:SetPos( 10,10 )
				GModeSettingsList:SetSize( admin_frame:GetWide() - 10, admin_frame:GetTall() - 10 )
				GModeSettingsList:SetSpacing( 5 ) -- Spacing between items
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
				    voiceLimitSlider:SetText( "Voice Limit Range (Def 500)" )
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
				    	local propBanningOnOff
				    	local propAllowingOnOff
				    	local propPayOnOff
				    	local voiceLimitOnOff
				    	local classCostOnOff
				    	local deathCostOnOff
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
				        RunConsoleCommand("pnrp_RunCommand","pnrp_propBanning",tostring(propBanningOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_propAllowing",tostring(propAllowingOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_propPay",tostring(propPayOnOff))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_propCost",tostring(propCostSlider:GetValue()))
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
				
			local maxMobGridRangeSlider = vgui.Create( "DNumSlider", mobGridSetup )
				    maxMobGridRangeSlider:SetSize( mobGridSetup:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxMobGridRangeSlider:SetText( "Max Mob Grid Range (Default 1000)" )
				    maxMobGridRangeSlider:SetMin( 0 )
				    maxMobGridRangeSlider:SetMax( 10000 )
				    maxMobGridRangeSlider:SetDecimals( 0 )
				    maxMobGridRangeSlider:SetValue( mobGridRange )
				mobGridSetup:AddItem( maxMobGridRangeSlider )
				
			local mPGridBTN = vgui.Create("DButton", mobGridSetup )
				    mPGridBTN:SetText( "Place Grid Node" )
				    mPGridBTN.DoClick = function()
				    	mobGridRange=maxMobGridRangeSlider:GetValue()
				        RunConsoleCommand("pnrp_mobsp" , mobGridRange)
				    end
				mobGridSetup:AddItem( mPGridBTN )
				
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
		
		AdminTabSheet:AddSheet( "Mob Grid Settings", mobGridSetup, "gui/silkicons/bomb", false, false, "Mob Grid Settings" )
	else
		ply:ChatPrint("You are not an admin on this server!")
	end
end


concommand.Add( "pnrp_admin_window", GM.open_admin )

--EOF