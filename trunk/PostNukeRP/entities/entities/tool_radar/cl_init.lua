include('shared.lua')

local radarHUD_Switch = "false"
local radarState = "none"
local syncedENTIndex

function ENT:Draw()
	self.Entity:DrawModel()
end

function RadarMenu( um )
	local smallparts = GetResource("Small_Parts")
	local radarHP = um:ReadShort()
	local endIndex = um:ReadShort()
	local radarEnt = um:ReadEntity()
	local Allowed = "true"
	local entMSG = "none"
	ply = LocalPlayer( )
	local owner = radarEnt:GetNWString( "Owner", "None" )
	
	if radarState ~= "none" then
		if endIndex ~= syncedENTIndex then
			--ply:ChatPrint("You are allready Synced to another unit.")
			entMSG = "You are allready Synced to another unit."
			Allowed = "false"
			--return
		end
	end
	
	if owner ~= ply:Nick() then
		entMSG = "You do not own this unit."
		Allowed = "false"
	end
	
	local w = 250
	local h = 175
	local title = "Wastelander Radar System"

	local radar_frame = vgui.Create("DFrame")
	radar_frame:Center()
	radar_frame:SetSize( w, h )
	radar_frame:SetTitle( title )
	radar_frame:SetVisible( true )
	radar_frame:SetDraggable( true )
	radar_frame:ShowCloseButton( true )
	radar_frame:MakePopup()
	
	local StatusBar = vgui.Create( "DPanel", radar_frame )
		StatusBar:SetPos( 10, 40 )
		StatusBar:SetSize( radar_frame:GetWide() - 20, 20 )
		StatusBar.Paint = function()
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.DrawRect( 0, 0, StatusBar:GetWide(), StatusBar:GetTall() )
			surface.SetDrawColor( 122, 197, 205, 125 )
			surface.DrawRect( 0, 0, StatusBar:GetWide(), StatusBar:GetTall() )
			
			surface.SetDrawColor( 122, 197, 205, 255 )
			surface.DrawOutlinedRect(0, 0, StatusBar:GetWide(), StatusBar:GetTall() )
			
			surface.DrawRect( 0, 0, StatusBar:GetWide() * ( radarHP / 200 ) , StatusBar:GetTall())
			
			local StatusLabel = vgui.Create("DLabel", StatusBar)
			StatusLabel:SetPos(5, 3)
			StatusLabel:SetColor( Color( 0, 0, 0, 255 ) )
			StatusLabel:SetText( "Radar Condition:" )
			StatusLabel:SizeToContents()
			
			local amtLabel = vgui.Create("DLabel", StatusBar)
			amtLabel:SetColor( Color( 0, 0, 0, 255 ) )
			amtLabel:SetText( tostring(radarHP).."%" )
			amtLabel:SizeToContents()
			amtLabel:SetPos(StatusBar:GetWide() - 75, 3 )
		end
		
		if Allowed == "true" then
		
			if radarState == "Standby" then
				if radarEnt:IsOutside() then
					local RadarButtonSynch = vgui.Create( "DButton" )
					RadarButtonSynch:SetParent( radar_frame )
					RadarButtonSynch:SetText( "Sync Radar" )
					RadarButtonSynch:SetPos( 10, 75 )
					RadarButtonSynch:SetSize( 125, 25 )
					RadarButtonSynch.DoClick = function ()
						radarState = "Syncing"
						datastream.StreamToServer( "radar_synching_stream", { radarEnt } )
						radar_frame:Close()
					end
				else
					local entOMSGLabel = vgui.Create("DLabel", radar_frame)
					entOMSGLabel:SetPos(10, 75)
					entOMSGLabel:SetColor( Color( 0, 0, 0, 255 ) )
					entOMSGLabel:SetText( "Unit must be outside to sync!" )
					entOMSGLabel:SizeToContents()
				end
			elseif radarState == "Ready" then
				local RadarButtonOff = vgui.Create( "DButton" )
				RadarButtonOff:SetParent( radar_frame )
				RadarButtonOff:SetText( "Shut Down Radar" )
				RadarButtonOff:SetPos( 10, 75 )
				RadarButtonOff:SetSize( 125, 25 )
				RadarButtonOff.DoClick = function ()
					radarState = "none"
					radarHUD_Switch = "false"
					datastream.StreamToServer( "radar_shutdown_stream", { radarEnt } )
					radar_frame:Close()
				end
			end
			
			if radarHUD_Switch == "false" then
				local HUDButtonAt = vgui.Create( "DButton" )
				HUDButtonAt:SetParent( radar_frame )
				HUDButtonAt:SetText( "Attach to HUD" )
				HUDButtonAt:SetPos( 10, 100 )
				HUDButtonAt:SetSize( 125, 25 )
				HUDButtonAt.DoClick = function ()
					if radarState == "none" then
						radarState = "Standby"
						syncedENTIndex = endIndex
					end
					radarHUD_Switch = "true"
					radar_frame:Close()
				end
			else
				local HUDButtonDt = vgui.Create( "DButton" )
				HUDButtonDt:SetParent( radar_frame )
				HUDButtonDt:SetText( "Detach from HUD" )
				HUDButtonDt:SetPos( 10, 100 )
				HUDButtonDt:SetSize( 125, 25 )
				HUDButtonDt.DoClick = function ()
					radarHUD_Switch = "false"
					radar_frame:Close()
				end
			end
		else
		
			local entMSGLabel = vgui.Create("DLabel", radar_frame)
			entMSGLabel:SetPos(10, 75)
			entMSGLabel:SetColor( Color( 0, 0, 0, 255 ) )
			entMSGLabel:SetText( entMSG )
			entMSGLabel:SizeToContents()
			
		end
			
		if radarHP < 200 then
			local FixButton = vgui.Create( "DButton" )
			FixButton:SetParent( radar_frame )
			FixButton:SetText( "Repair Radar" )
			FixButton:SetPos( 10, 125 )
			FixButton:SetSize( 125, 25 )
			FixButton.DoClick = function ()
				datastream.StreamToServer( "radar_repair_stream", { radarEnt } )
				radar_frame:Close()
			end
		end
		
end
usermessage.Hook("radar_menu", RadarMenu)

function RadarState( um )

	local getState = um:ReadString()
	local endIndex = um:ReadShort()
	
	if endIndex == syncedENTIndex then
		if getState == "none" then		
			radarHUD_Switch = "false"
		end
		radarState = getState
	end
end
usermessage.Hook("radar_state", RadarState)

RADAR_HUD = { }
local syncTimer = 0
local syncTimerSW = "off"

function pnrpHUD_DrawRadar()
	local ply = LocalPlayer()
	if ( !ply:Alive() ) then 
		radarHUD_Switch = "false"
		return 
	end
	
	if ply:Team() ~= TEAM_WASTELANDER then
		radarState = "none"
		radarHUD_Switch = "false"
	end
	
	font = "TargetID"
	local c =
	{
		shadow = Color( 0, 0, 0, 200 ),
		text = Color( 255, 255, 255, 255 )
	}
	local background = Color( 51, 58, 51, 100 )
	
	if radarHUD_Switch == "true" then
		RADAR_HUD:PaintRoundedPanel( 6, 6, 175, 150, 25, background )
		RADAR_HUD:PaintText( 15, 175, "Wasteland Radar", font, c )
	
		if radarState == "dead" then
			RADAR_HUD:PaintText( 15, 200, "Signal Lost...", font, c )
		end
		if radarState == "Standby" then
			RADAR_HUD:PaintText( 15, 200, "Radar SCXU 8034 in Standby Mode", font, c )
			RADAR_HUD:PaintText( 15, 215, "Use Radar and Sync to activate.", font, c )
			syncTimer = 0
		end
		if radarState == "Syncing" then
			RADAR_HUD:PaintText( 15, 200, "Radar Syncing...", font, c )
			RADAR_HUD:PaintRoundedPanel( 0, 6, 225, 150, 25, background )
			RADAR_HUD:PaintRoundedPanel( 0, 6, 225, 150, 25, background )
			
			if syncTimerSW == "off" then
				syncTimerSW = "on"
				timer.Create( "synch_Timer", 1, 60, function()
					syncTimer = syncTimer + 1 
				end)
			end
			
			RADAR_HUD:PaintRoundedPanel( 0, 6, 225, 150 * ( syncTimer / 60 ), 25, Color( 204, 121, 44, 50 ) )
		else
			syncTimer = 0
			syncTimerSW = "off"
		end
		if radarState == "Ready" then
			--RADAR_HUD:PaintText( 6, 200, "Radar Ready...", font, c )
			--local inerC = Color( 110, 100, 105, 100 )
			--RADAR_HUD:PaintRoundedPanel( 50, 15, 200, 100, 100, inerC )
			RADAR_HUD:DrawRadar()
		end
	end
end

hook.Add( "HUDPaint", "pnrpHUD_DrawRadar", pnrpHUD_DrawRadar )

function RADAR_HUD:DrawRadar()
	local ply = LocalPlayer()
	local ply_pos = ply:GetPos()
	--local inerC = Color( 110, 100, 105, 100 )
	local inerC = Color( 204, 121, 44, 75 )
	local npcC = Color( 0, 0, 229, 100 )
	local playerC = Color( 0, 229, 0, 100 )
	local recC = Color( 0, 225, 225, 100 )
	local npcHostileC = Color( 229 * math.abs(math.sin(CurTime()*2)), 0, 0, 125 )
	local dotSize = 6
	local radar_x = 15
	local radar_y = 200
	local radar_w = 125
	local radar_h = 125
	local radar_r = radar_w/2.75 --radius
	local center_x = radar_x+radar_w/2
	local center_y = radar_y+radar_h/2
	RADAR_HUD:PaintRoundedPanel( 62, radar_x, radar_y, radar_w, radar_h, inerC )
	
	local found_ents = ents.FindInSphere( ply:GetPos(), 2000)
	for i, ent in ipairs(found_ents) do
		if ent:IsNPC() then
			--Calculates in relation to the local player
			local loc_diff = ent:GetPos()-ply_pos
			local tx = (loc_diff.x/radar_r)
			local ty = (loc_diff.y/radar_r)
			local class = ent:GetClass()
			--Code for radar rotation
			local z = math.sqrt( tx*tx + ty*ty )
			local phi = math.Deg2Rad( math.Rad2Deg( math.atan2( tx, ty ) ) - math.Rad2Deg( math.atan2( ply:GetAimVector().x, ply:GetAimVector().y ) ) - 90 )
			tx = math.cos(phi)*z
			ty = math.sin(phi)*z
			
			if class == "npc_antlionguard" then
				local guardDot = dotSize + 4
				RADAR_HUD:PaintRoundedPanel( 4, center_x+tx-(guardDot/2), center_y+ty-(guardDot/2), guardDot, guardDot, npcHostileC )
			elseif  class == "npc_antlion" or
					class == "npc_zombie" or class == "npc_zombie_torso" or
					class == "npc_fastzombie" or class == "npc_fastzombie_torso" or
					class == "npc_poisonzombie" or
					class == "npc_headcrab" or class == "npc_headcrab_fast" or class == "npc_headcrab_poison" then
				
				RADAR_HUD:PaintRoundedPanel( 4, center_x+tx-(dotSize/2), center_y+ty-(dotSize/2), dotSize, dotSize, npcHostileC )
			else
				RADAR_HUD:PaintRoundedPanel( 4, center_x+tx-(dotSize/2), center_y+ty-(dotSize/2), dotSize, dotSize, npcC )
			end
		end
		if ent:IsPlayer() then
			if ent ~= ply then
				--Calculates in relation to the local player
				local loc_diff = ent:GetPos()-ply_pos
				local tx = (loc_diff.x/radar_r)
				local ty = (loc_diff.y/radar_r)
				--Code for radar rotation
				local z = math.sqrt( tx*tx + ty*ty )
				local phi = math.Deg2Rad( math.Rad2Deg( math.atan2( tx, ty ) ) - math.Rad2Deg( math.atan2( ply:GetAimVector().x, ply:GetAimVector().y ) ) - 90 )
				tx = math.cos(phi)*z
				ty = math.sin(phi)*z
				RADAR_HUD:PaintRoundedPanel( 4, center_x+tx-dotSize, center_y+ty-dotSize, dotSize, dotSize, playerC )
			end
		end
		for k,v in pairs(PNRP.JunkModels) do
			if v == ent:GetModel() then 
				--Calculates in relation to the local player
				local loc_diff = ent:GetPos()-ply_pos
				local tx = (loc_diff.x/radar_r)
				local ty = (loc_diff.y/radar_r)
				--Code for radar rotation
				local z = math.sqrt( tx*tx + ty*ty )
				local phi = math.Deg2Rad( math.Rad2Deg( math.atan2( tx, ty ) ) - math.Rad2Deg( math.atan2( ply:GetAimVector().x, ply:GetAimVector().y ) ) - 90 )
				tx = math.cos(phi)*z
				ty = math.sin(phi)*z
				RADAR_HUD:PaintRoundedPanel( 4, center_x+tx-dotSize, center_y+ty-dotSize, dotSize, dotSize, recC )
			end
		end
		for k,v in pairs(PNRP.ChemicalModels) do
			if v == ent:GetModel() then 
				--Calculates in relation to the local player
				local loc_diff = ent:GetPos()-ply_pos
				local tx = (loc_diff.x/radar_r)
				local ty = (loc_diff.y/radar_r)
				--Code for radar rotation
				local z = math.sqrt( tx*tx + ty*ty )
				local phi = math.Deg2Rad( math.Rad2Deg( math.atan2( tx, ty ) ) - math.Rad2Deg( math.atan2( ply:GetAimVector().x, ply:GetAimVector().y ) ) - 90 )
				tx = math.cos(phi)*z
				ty = math.sin(phi)*z
				RADAR_HUD:PaintRoundedPanel( 4, center_x+tx-dotSize, center_y+ty-dotSize, dotSize, dotSize, recC )
			end
		end
		for k,v in pairs(PNRP.SmallPartsModels) do
			if v == ent:GetModel() then 
				--Calculates in relation to the local player
				local loc_diff = ent:GetPos()-ply_pos
				local tx = (loc_diff.x/radar_r)
				local ty = (loc_diff.y/radar_r)
				--Code for radar rotation
				local z = math.sqrt( tx*tx + ty*ty )
				local phi = math.Deg2Rad( math.Rad2Deg( math.atan2( tx, ty ) ) - math.Rad2Deg( math.atan2( ply:GetAimVector().x, ply:GetAimVector().y ) ) - 90 )
				tx = math.cos(phi)*z
				ty = math.sin(phi)*z
				RADAR_HUD:PaintRoundedPanel( 4, center_x+tx-dotSize, center_y+ty-dotSize, dotSize, dotSize, recC )
			end
		end
	end
end

function RADAR_HUD:PaintText( x, y, text, font, color )
 
	surface.SetFont( font );
 
	surface.SetTextPos( x + 1, y + 1 );
	surface.SetTextColor( color.shadow );
	surface.DrawText( text );
 
	surface.SetTextPos( x, y );
	surface.SetTextColor( color.text  );
	surface.DrawText( text );
 
end

function RADAR_HUD:PaintPanel( x, y, w, h, color )
 
	surface.SetDrawColor( color.border );
	surface.DrawOutlinedRect( x, y, w, h );
 
	x = x + 1; y = y + 1;
	w = w - 2; h = h - 2;
 
	surface.SetDrawColor( color.background );
	surface.DrawRect( x, y, w, h );
 
end

function RADAR_HUD:PaintRoundedPanel(r, x, y, w, h, color )
  
	x = x + 1; y = y + 1;
	w = w - 2; h = h - 2;
 
	draw.RoundedBox(r, x, y, w, h, color)
 
end
