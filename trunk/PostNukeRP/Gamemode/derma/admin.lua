local admin_frame

function GM.open_admin(ply)
	local GM = GAMEMODE
	if ply:IsAdmin() then	
		admin_frame = vgui.Create( "DFrame" )
				admin_frame:SetSize( 400, 500 ) --Set the size
				admin_frame:SetPos(ScrW() / 2 - admin_frame:GetWide() / 2, ScrH() / 2 - admin_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
				admin_frame:SetTitle( "Admin Menu" ) --Set title
				admin_frame:SetVisible( true )
				admin_frame:SetDraggable( true )
				admin_frame:ShowCloseButton( true )
				admin_frame:MakePopup()
				
		local AdminTabSheet = vgui.Create( "DPropertySheet" )
			AdminTabSheet:SetParent( admin_frame )
			AdminTabSheet:SetPos( 5, 30 )
			AdminTabSheet:SetSize( admin_frame:GetWide() - 10, admin_frame:GetTall() - 40 )
			
			local SpawnerList = vgui.Create( "DPanelList", AdminTabSheet )
				SpawnerList:SetPos( 10,10 )
				SpawnerList:SetSize( admin_frame:GetWide() - 10, admin_frame:GetTall() - 10 )
				SpawnerList:SetSpacing( 5 ) -- Spacing between items
				SpawnerList:EnableHorizontal( false ) -- Only vertical items
				SpawnerList:EnableVerticalScrollbar( true ) -- Allow scrollbar if you exceed the Y axis

				local mobsSpawnOnBTN = vgui.Create("DButton", SpawnerList )
				    mobsSpawnOnBTN:SetText( "Mob Spawner On" )
				    mobsSpawnOnBTN.DoClick = function()
				        RunConsoleCommand("pnrp_RunCommand","pnrp_SpawnMobs","1")				        
				    end
				SpawnerList:AddItem( mobsSpawnOnBTN )
				
				local mobsSpawnOffBTN = vgui.Create("DButton", SpawnerList )
				    mobsSpawnOffBTN:SetText( "Mob Spawner Off" )
				    mobsSpawnOffBTN.DoClick = function()
				        RunConsoleCommand("pnrp_RunCommand","pnrp_SpawnMobs","0")				        
				    end
				SpawnerList:AddItem( mobsSpawnOffBTN )
				
				local clearMobsBTN = vgui.Create("DButton", SpawnerList )
				    clearMobsBTN:SetText( "Clear Mobs" )
				    clearMobsBTN.DoClick = function()
				        RunConsoleCommand( "pnrp_clearmobs" )
				    end
				SpawnerList:AddItem( clearMobsBTN )
				
				local maxZombiesSlider = vgui.Create( "DNumSlider", SpawnerList )
				    maxZombiesSlider:SetSize( SpawnerList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxZombiesSlider:SetText( "Max Zombies (Default 30)" )
				    maxZombiesSlider:SetMin( 0 )
				    maxZombiesSlider:SetMax( 100 )
				    maxZombiesSlider:SetDecimals( 0 )
				    maxZombiesSlider:SetValue( GetConVar("pnrp_MaxZombies"):GetInt() )
				SpawnerList:AddItem( maxZombiesSlider )
				
				local maxFastZombiesSlider = vgui.Create( "DNumSlider", SpawnerList )
				    maxFastZombiesSlider:SetSize( SpawnerList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxFastZombiesSlider:SetText( "Max Fast Zombies (Default 5)" )
				    maxFastZombiesSlider:SetMin( 0 )
				    maxFastZombiesSlider:SetMax( 100 )
				    maxFastZombiesSlider:SetDecimals( 0 )
				    maxFastZombiesSlider:SetValue( GetConVar("pnrp_MaxFastZombies"):GetInt() )
				SpawnerList:AddItem( maxFastZombiesSlider )
				
				local maxPoisonZombiesSlider = vgui.Create( "DNumSlider", SpawnerList )
				    maxPoisonZombiesSlider:SetSize( SpawnerList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxPoisonZombiesSlider:SetText( "Max Poison Zombies (Default 2)" )
				    maxPoisonZombiesSlider:SetMin( 0 )
				    maxPoisonZombiesSlider:SetMax( 100 )
				    maxPoisonZombiesSlider:SetDecimals( 0 )
				    maxPoisonZombiesSlider:SetValue( GetConVar("pnrp_MaxPoisonZombs"):GetInt() )
				SpawnerList:AddItem( maxPoisonZombiesSlider )
				
				local maxAntlionsSlider = vgui.Create( "DNumSlider", SpawnerList )
				    maxAntlionsSlider:SetSize( SpawnerList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxAntlionsSlider:SetText( "Max Antlions (Default 10)" )
				    maxAntlionsSlider:SetMin( 0 )
				    maxAntlionsSlider:SetMax( 100 )
				    maxAntlionsSlider:SetDecimals( 0 )
				    maxAntlionsSlider:SetValue( GetConVar("pnrp_MaxAntlions"):GetInt() )
				SpawnerList:AddItem( maxAntlionsSlider )
				
				local maxAntGuardSlider = vgui.Create( "DNumSlider", SpawnerList )
				    maxAntGuardSlider:SetSize( SpawnerList:GetWide() - 20, 50 ) -- Keep the second number at 50
				    maxAntGuardSlider:SetText( "Max Ant Guard (Default 1)" )
				    maxAntGuardSlider:SetMin( 0 )
				    maxAntGuardSlider:SetMax( 100 )
				    maxAntGuardSlider:SetDecimals( 0 )
				    maxAntGuardSlider:SetValue( GetConVar("pnrp_MaxAntGuards"):GetInt() )
				SpawnerList:AddItem( maxAntGuardSlider )
				
				local mobSettingsSaveBTN = vgui.Create("DButton", SpawnerList )
				    mobSettingsSaveBTN:SetText( "Save Settings" )
				    mobSettingsSaveBTN.DoClick = function()
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MaxZombies",tostring(maxZombiesSlider:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MaxFastZombies",tostring(maxFastZombiesSlider:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MaxPoisonZombs",tostring(maxPoisonZombiesSlider:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MaxAntlions",tostring(maxAntlionsSlider:GetValue()))
				        RunConsoleCommand("pnrp_RunCommand","pnrp_MaxAntGuards",tostring(maxAntGuardSlider:GetValue()))
				    end
				SpawnerList:AddItem( mobSettingsSaveBTN )
		
		AdminTabSheet:AddSheet( "Spawn Settings", SpawnerList, "gui/silkicons/bomb", false, false, "Spawn Settings" )
		
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