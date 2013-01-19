include('shared.lua')

local radarHUD_Enabled = false
local radarState = "none"
local syncedENTIndex
local radar_GPR_Enabled = false
local synchedRadarENT = nil

function ENT:Draw()
	self.Entity:DrawModel()
end

function RadarMenu( )
	local radarHP = math.Round(net:ReadDouble())
	local endIndex = math.Round(net:ReadDouble())
	local radarEnt = net:ReadEntity()
	syncMaxTime = math.Round(net:ReadDouble())
	
	ply = LocalPlayer( )
	
	local radarGPR = radarEnt:GetNWString("EnabledGPR", false)
	local radarState = radarEnt:GetNWString("Status", 0)
	local plyRadarIndex = ply:GetNWString("RadarENTIndex", nil)
	
	local Allowed = false
	local entMSG = "none"
	
	local owner = radarEnt:GetNWString( "Owner", "None" )
	
	if radarState >= 0 then
		if tostring(plyRadarIndex) ~= "" and plyRadarIndex ~= 0 then
			if endIndex ~= plyRadarIndex then
				entMSG = "You are allready Synced to another unit."
				Allowed = false
			else 
				Allowed = true
			end
		else
			Allowed = true
		end
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
		
		local GPR_Upgrad = vgui.Create( "DPanel", radar_frame )
				GPR_Upgrad:SetPos( 155, 100 )
				GPR_Upgrad:SetSize( 80, 20 )
				GPR_Upgrad.Paint = function()
					surface.SetDrawColor( 100, 10, 15, 255 )
					surface.DrawRect( 0, 0, GPR_Upgrad:GetWide(), GPR_Upgrad:GetTall() )
				end
			local UpgradeLabel = vgui.Create("DLabel", GPR_Upgrad)
				UpgradeLabel:SetColor( Color( 0, 0, 0, 255 ) )
				UpgradeLabel:SetText( "GPR Not Found" )
				UpgradeLabel:SizeToContents()
				UpgradeLabel:SetPos( 3, 3 )
		
		if radarGPR then

			GPR_Upgrad.Paint = function()
				surface.SetDrawColor( 10, 100, 10, 255 )
				surface.DrawRect( 0, 0, GPR_Upgrad:GetWide(), GPR_Upgrad:GetTall() )
			end

			UpgradeLabel:SetColor( Color( 0, 0, 0, 255 ) )
			UpgradeLabel:SetText( "GPR Installed" )

		end

		if Allowed then
		
			if radarState == 1 then
				if radarEnt:IsOutside() then
					local RadarButtonSynch = vgui.Create( "DButton" )
					RadarButtonSynch:SetParent( radar_frame )
					RadarButtonSynch:SetText( "Sync Radar" )
					RadarButtonSynch:SetPos( 10, 75 )
					RadarButtonSynch:SetSize( 125, 25 )
					RadarButtonSynch.DoClick = function ()
						net.Start("RADAR_Synch")
							net.WriteEntity(ply)
							net.WriteEntity(radarEnt)
						net.SendToServer()
						radar_frame:Close()
					end
				else
					local entOMSGLabel = vgui.Create("DLabel", radar_frame)
					entOMSGLabel:SetPos(10, 75)
					entOMSGLabel:SetColor( Color( 0, 0, 0, 255 ) )
					entOMSGLabel:SetText( "Unit must be outside to sync!" )
					entOMSGLabel:SizeToContents()
				end
			elseif radarState > 0 then
				local RadarButtonOff = vgui.Create( "DButton" )
				RadarButtonOff:SetParent( radar_frame )
				RadarButtonOff:SetText( "Shut Down Radar" )
				RadarButtonOff:SetPos( 10, 75 )
				RadarButtonOff:SetSize( 125, 25 )
				RadarButtonOff.DoClick = function ()
					net.Start("RADAR_PowerOff")
						net.WriteEntity(ply)
						net.WriteEntity(radarEnt)
					net.SendToServer()
					radar_frame:Close()
				end
			end
			
			if radarState == 0 or not radarHUD_Enabled then
				local HUDButtonAt = vgui.Create( "DButton" )
				HUDButtonAt:SetParent( radar_frame )
				HUDButtonAt:SetText( "Attach to HUD" )
				HUDButtonAt:SetPos( 10, 100 )
				HUDButtonAt:SetSize( 125, 25 )
				HUDButtonAt.DoClick = function ()
					net.Start("RADAR_Attach")
						net.WriteEntity(ply)
						net.WriteEntity(radarEnt)
					net.SendToServer()
					radar_frame:Close()
				end
			else
				local HUDButtonDt = vgui.Create( "DButton" )
				HUDButtonDt:SetParent( radar_frame )
				HUDButtonDt:SetText( "Detach from HUD" )
				HUDButtonDt:SetPos( 10, 100 )
				HUDButtonDt:SetSize( 125, 25 )
				HUDButtonDt.DoClick = function ()
					net.Start("RADAR_Detach")
						net.WriteEntity(ply)
						net.WriteEntity(radarEnt)
					net.SendToServer()
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
				net.Start("RADAR_Repair")
					net.WriteEntity(ply)
					net.WriteEntity(radarEnt)
				net.SendToServer()
				radar_frame:Close()
			end
		end
		
		if radarGPR then
			local DGPRButton = vgui.Create( "DButton" )
				DGPRButton:SetParent( radar_frame )
				DGPRButton:SetText( "Remove GPR" )
				DGPRButton:SetPos( 145, 125 )
				DGPRButton:SetSize( 100, 25 )
				DGPRButton.DoClick = function ()
					net.Start("RADAR_RemoveGPR")
						net.WriteEntity(ply)
						net.WriteEntity(radarEnt)
					net.SendToServer()
					radar_frame:Close()
				end
		else
			local AGPRButton = vgui.Create( "DButton" )
				AGPRButton:SetParent( radar_frame )
				AGPRButton:SetText( "Attach GPR" )
				AGPRButton:SetPos( 145, 125 )
				AGPRButton:SetSize( 100, 25 )
				AGPRButton.DoClick = function ()
					net.Start("RADAR_AttachGPR")
						net.WriteEntity(ply)
						net.WriteEntity(radarEnt)
					net.SendToServer()
					radar_frame:Close()
				end
		end
		
end
net.Receive("radar_menu", RadarMenu)

RADAR_HUD = { }
local syncTimer = 0
local syncTimerSW = "off"

function pnrpHUD_DrawRadar()
	local ply = LocalPlayer()
	local plyRadarIndex = ply:GetNWString("RadarENTIndex")
	local radarENT = nil
	
	if ( !ply:Alive() ) then 
		radarHUD_Enabled = false
		return 
	end
	
--	if plyRadarIndex then
--		local foundRadars = ents.FindByClass("tool_radar")
--		for k, v in pairs(foundRadars) do
--			if v:EntIndex() == plyRadarIndex then
--				radarENT = v
--				radarHUD_Enabled = true
--			end
--		end
--	else
--		radarHUD_Enabled = false
--		return 
--	end
	
	radarENT = ply:GetNWEntity("RadarENT")
	if IsValid(radarENT) and radarENT ~= ply and plyRadarIndex ~= 0 then
		radarHUD_Enabled = true
	else
		radarHUD_Enabled = false
		return 
	end
	
	local radarState = radarENT:GetNWString("Status", 0)
	radar_GPR_Enabled = radarENT:GetNWString("EnabledGPR", false)
--	if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then 
		--Admin Overide
--	else
--		if ply:Team() ~= TEAM_WASTELANDER then
--			radarState = "none"
--			radarHUD_Enabled = "false"
--		end
--	end
	
	font = "TargetID"
	local c =
	{
		shadow = Color( 0, 0, 0, 200 ),
		text = Color( 255, 255, 255, 255 )
	}
	local background = Color( 51, 58, 51, 100 )
		
	local hPos = 200
	local vPos = 15
--	RADAR_HUD:PaintText( 150, 25, "Radar ENT: "..tostring(radarENT), font, c )
--	RADAR_HUD:PaintText( 150, 45, "HUD Switch: "..tostring(radarHUD_Enabled), font, c )
--	RADAR_HUD:PaintText( 150, 65, "Radar State: "..tostring(radarState), font, c )
--	RADAR_HUD:PaintText( 150, 85, "syncTimerSW: "..tostring(syncTimerSW), font, c )
--	RADAR_HUD:PaintText( 150, 105, "syncTimer: "..tostring(syncTimer), font, c )
--	RADAR_HUD:PaintText( 150, 125, "syncMaxTime: "..tostring(syncMaxTime), font, c )
--	RADAR_HUD:PaintText( 150, 145, "TimeExists: "..tostring(timer.Exists( "synch_Timer"..tostring(ply))), font, c )
	RADAR_HUD:PaintText( 150, 25, "radar_GPR_Enabled: "..tostring(radar_GPR_Enabled), font, c )
	if radarHUD_Enabled then
		RADAR_HUD:PaintRoundedPanel( 0, 6, hPos-5, 150, 25, background )
		RADAR_HUD:PaintText( vPos, hPos, "Wasteland Radar", font, c )
		surface.SetDrawColor( Color( 0, 100, 0, 150 ) )
		surface.DrawOutlinedRect( 6, hPos-5, 150, 25 )
		
		hPos = hPos + 25
		if radarState < 0 then --Dead or No Power
			RADAR_HUD:PaintText( vPos, hPos, "Signal Lost...", font, c )
		end 
		if radarState == 1 then --Standby
			RADAR_HUD:PaintRoundedPanel( 0, 6, hPos-6, 300, 45, background )
			RADAR_HUD:PaintText( vPos, hPos, "Radar SCXU 8034 in Standby Mode", font, c )
			RADAR_HUD:PaintText( vPos, hPos + 15, "Use Radar and Sync to activate.", font, c )
			surface.SetDrawColor( Color( 0, 100, 0, 150 ) )
			surface.DrawOutlinedRect( 6, hPos-6, 300, 45 )
			syncTimer = 0
		end
		if radarState == 2 then --Synching
			RADAR_HUD:PaintText( vPos, hPos, "Radar Syncing...", font, c )
			RADAR_HUD:PaintRoundedPanel( 0, 6, 222, 150, 25, background )
			
			if syncTimerSW == "off" then
				syncTimerSW = "on"
				timer.Create( "synch_Timer"..tostring(ply), 1, syncMaxTime, function()
					syncTimer = syncTimer + 1 
				end)
			end
			hPos = hPos + 25
			RADAR_HUD:PaintRoundedPanel( 0, 6, hPos, 150 * ( syncTimer / syncMaxTime ), 25, Color( 204, 121, 44, 50 ) )
			surface.SetDrawColor( Color( 0, 100, 0, 150 ) )
			surface.DrawOutlinedRect( 6, hPos, 150, 25 )
		else
			syncTimer = 0
			if syncTimerSW == "on" then
				timer.Destroy("synch_Timer"..tostring(ply))
			end
			syncTimerSW = "off"
		end
		if radarState == 3 then --Ready
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
	local radar_y = 225
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
			local phi = math.rad( math.deg( math.atan2( tx, ty ) ) - math.deg( math.atan2( ply:GetAimVector().x, ply:GetAimVector().y ) ) - 90 )
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
				local phi = math.rad( math.deg( math.atan2( tx, ty ) ) - math.deg( math.atan2( ply:GetAimVector().x, ply:GetAimVector().y ) ) - 90 )
				tx = math.cos(phi)*z
				ty = math.sin(phi)*z
				RADAR_HUD:PaintRoundedPanel( 4, center_x+tx-dotSize, center_y+ty-dotSize, dotSize, dotSize, playerC )
			end
		end
		
		if radar_GPR_Enabled then
			local isREC = RADAR_HUD:IsRecModel( ent:GetModel() ) 
			if 	isREC then
				--Calculates in relation to the local player
				local loc_diff = ent:GetPos()-ply_pos
				local tx = (loc_diff.x/radar_r)
				local ty = (loc_diff.y/radar_r)
				--Code for radar rotation
				local z = math.sqrt( tx*tx + ty*ty )
				local phi = math.rad( math.deg( math.atan2( tx, ty ) ) - math.deg( math.atan2( ply:GetAimVector().x, ply:GetAimVector().y ) ) - 90 )
				tx = math.cos(phi)*z
				ty = math.sin(phi)*z
				RADAR_HUD:PaintRoundedPanel( 4, center_x+tx-dotSize, center_y+ty-dotSize, dotSize, dotSize, recC )
			end
			
		end
	end
end

function RADAR_HUD:IsRecModel( mdl )
	for k,v in pairs(PNRP.JunkModels) do
		if string.lower(mdl) == string.lower(v) then
			return true
		end
	end
	for k,v in pairs(PNRP.ChemicalModels) do
		if string.lower(mdl) == string.lower(v) then
			return true
		end
	end
	for k,v in pairs(PNRP.SmallPartsModels) do
		if string.lower(mdl) == string.lower(v) then
			return true
		end
	end
	return false
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
