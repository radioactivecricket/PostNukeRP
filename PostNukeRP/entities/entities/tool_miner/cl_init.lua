include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

local minerState = "off"

function MinerMenu( )
	local smallparts = GetResource("Small_Parts")
	local minerHP = math.Round(net:ReadDouble())
	local endIndex = math.Round(net:ReadDouble())
	local minerPower = math.Round(net:ReadDouble())
	local minerEnt = net:ReadEntity()
	local Allowed = "true"
	local entMSG = "none"
	ply = LocalPlayer( )
	local owner = minerEnt:GetNWString( "Owner", "None" )
	--Verifies the miners state
	if minerPower == 0 then
		minerState = "off"
	else
		minerState = "on"
	end
	
--	if owner ~= ply:Nick() then
--		if ply:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1 then
--			ply:ChatPrint("Admin overide.")
--		else
--			entMSG = "You do not own this unit."
--			Allowed = "false"
--		end
--	end
	
	if minerHP <= 0 then minerState = "off" end
	
	local w = 250
	local h = 175
	local title = "Automated Sonic Miner"
	
	local miner_frame = vgui.Create("DFrame")
	miner_frame:Center()
	miner_frame:SetSize( w, h )
	miner_frame:SetTitle( title )
	miner_frame:SetVisible( true )
	miner_frame:SetDraggable( true )
	miner_frame:ShowCloseButton( true )
	miner_frame:MakePopup()
	
	local StatusBar = vgui.Create( "DPanel", miner_frame )
		StatusBar:SetPos( 10, 40 )
		StatusBar:SetSize( miner_frame:GetWide() - 20, 20 )
		StatusBar.Paint = function()
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.DrawRect( 0, 0, StatusBar:GetWide(), StatusBar:GetTall() )
			surface.SetDrawColor( 122, 197, 205, 125 )
			surface.DrawRect( 0, 0, StatusBar:GetWide(), StatusBar:GetTall() )
			
			surface.SetDrawColor( 122, 197, 205, 255 )
			surface.DrawOutlinedRect(0, 0, StatusBar:GetWide(), StatusBar:GetTall() )
			
			surface.DrawRect( 0, 0, StatusBar:GetWide() * ( minerHP / 200 ) , StatusBar:GetTall())
			
			local StatusLabel = vgui.Create("DLabel", StatusBar)
			StatusLabel:SetPos(5, 3)
			StatusLabel:SetColor( Color( 0, 0, 0, 255 ) )
			StatusLabel:SetText( "Condition:" )
			StatusLabel:SizeToContents()
			
			local amtLabel = vgui.Create("DLabel", StatusBar)
			amtLabel:SetColor( Color( 0, 0, 0, 255 ) )
			amtLabel:SetText( tostring(minerHP).."%" )
			amtLabel:SizeToContents()
			amtLabel:SetPos(StatusBar:GetWide() - 75, 3 )
		end
		
		if Allowed == "true" then
		
			if minerState == "off" then
				if minerEnt:IsOutside() then
					if minerHP > 199 then
						local minerButtonOn = vgui.Create( "DButton" )
						minerButtonOn:SetParent( miner_frame )
						minerButtonOn:SetText( "Set Miner Online" )
						minerButtonOn:SetPos( 10, 75 )
						minerButtonOn:SetSize( 125, 25 )
						minerButtonOn.DoClick = function ()
							minerState = "on"
							--datastream.StreamToServer( "miner_online_stream", { minerEnt } )
							net.Start("miner_online_stream")
								net.WriteEntity(ply)
								net.WriteEntity(minerEnt)
							net.SendToServer()
							miner_frame:Close()
						end
					end
				else
					local entOMSGLabel = vgui.Create("DLabel", miner_frame)
					entOMSGLabel:SetPos(10, 100)
					entOMSGLabel:SetColor( Color( 0, 0, 0, 255 ) )
					entOMSGLabel:SetText( "Unit must be outside!" )
					entOMSGLabel:SizeToContents()
				end
			elseif minerState == "on" then
				local minerButtonOff = vgui.Create( "DButton" )
				minerButtonOff:SetParent( miner_frame )
				minerButtonOff:SetText( "Set Miner Offline" )
				minerButtonOff:SetPos( 10, 100 )
				minerButtonOff:SetSize( 125, 25 )
				minerButtonOff.DoClick = function ()
					minerState = "off"
					--datastream.StreamToServer( "miner_shutdown_stream", { minerEnt } )
					net.Start("miner_shutdown_stream")
						net.WriteEntity(ply)
						net.WriteEntity(minerEnt)
					net.SendToServer()
					miner_frame:Close()
				end
			end
		
		else
			local entMSGLabel = vgui.Create("DLabel", miner_frame)
			entMSGLabel:SetPos(10, 75)
			entMSGLabel:SetColor( Color( 0, 0, 0, 255 ) )
			entMSGLabel:SetText( entMSG )
			entMSGLabel:SizeToContents()
		end
		
		if minerHP < 200 then
			local FixButton = vgui.Create( "DButton" )
			FixButton:SetParent( miner_frame )
			FixButton:SetText( "Repair Unit" )
			FixButton:SetPos( 10, 125 )
			FixButton:SetSize( 125, 25 )
			FixButton.DoClick = function ()
				--datastream.StreamToServer( "miner_repair_stream", { minerEnt } )
				net.Start("miner_repair_stream")
					net.WriteEntity(ply)
					net.WriteEntity(minerEnt)
				net.SendToServer()
				miner_frame:Close()
			end
		end
end

net.Receive("miner_menu", MinerMenu)

