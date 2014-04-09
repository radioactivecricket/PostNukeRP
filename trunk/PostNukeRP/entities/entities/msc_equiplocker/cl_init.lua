include('shared.lua')

local StartTime = CurTime()
local TimeLeft = 60
local breakingIn = false
local savedLocker = nil

function ENT:Draw()
	self.Entity:DrawModel()
end

function LockerViewCheck()
	local myPlayer = LocalPlayer()
	
	local tracedata = {}
	tracedata.start = myPlayer:GetShootPos()
	tracedata.endpos = tracedata.start + (myPlayer:GetAimVector() * 1000)
	tracedata.filter = myPlayer
	local trace = util.TraceLine(tracedata)
	
	if !trace.Entity:IsValid() then return end
	
	if trace.Entity:GetClass() == "msc_equiplocker" then
		local community = trace.Entity:GetNWString("communityName")
		
		surface.SetFont("CenterPrintText")
		local tWidth, tHeight = surface.GetTextSize(community.." Community Equipment")
		
		-- surface.SetTextColor(Color(255,255,255,255))
		-- surface.SetTextPos(ScrW() / 2, ScrH() / 2)
		-- surface.DrawText( community.." Community Locker" )
		draw.WordBox( 8, (ScrW() / 2) - (8 + (tWidth / 2)), (ScrH() / 2) - (16 + tHeight), community.." Community Equipment", "CenterPrintText", Color(50,50,75,100), Color(255,255,255,255) )
		
		-- local gridMessage = "Distance:  "..tostring(distance).."\nSpawn Resources:  "..tostring(resources).."\nSpawn Antlions:  "..tostring(antlions).."\nSpawn Zombies:  "..tostring(zombies).."\nCan Make Mounds:  "..tostring(mounds).."\nIs Indoor:  "..tostring(indoor)
		-- AddWorldTip( self.Entity:EntIndex(), gridMessage, 0.5, self.Entity:GetPos(), self.Entity )
	end
end
hook.Add( "HUDPaint", "LockerViewCheck", LockerViewCheck )

function LockerMenu( )
	local ply = net.ReadEntity()
	local locker = net.ReadEntity()
	local lockerHealth = net.ReadDouble()
	local itemTble = net.ReadTable()
	local inventoryTble = net.ReadTable()
	
	PNRP.RMDerma()
	local locker_frame = vgui.Create( "DFrame" )
		locker_frame:SetSize( 810, 520 ) --Set the size
		locker_frame:SetPos(ScrW() / 2 - locker_frame:GetWide() / 2, ScrH() / 2 - locker_frame:GetTall() / 2) 
		locker_frame:SetTitle( " " ) --Set title
		locker_frame:SetVisible( true )
		locker_frame:SetDraggable( false )
		locker_frame:ShowCloseButton( true )
		locker_frame:MakePopup()
		locker_frame.Paint = function() -- Paint function
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		PNRP.AddMenu(locker_frame)
		
		local screenBG = vgui.Create("DImage", locker_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_5b.png" )
			screenBG:SetSize(locker_frame:GetWide(), locker_frame:GetTall())	
			
		local paneWidth = 255	
			
		--//Locker Inventory
		local LockerInvLabel = vgui.Create( "DLabel", locker_frame )
			LockerInvLabel:SetText("Locker Inventory")
			LockerInvLabel:SetPos(35, 50)
			LockerInvLabel:SetColor( Color( 255, 255, 255, 255 ) )
			LockerInvLabel:SizeToContents()
			
		local pnlLIList = vgui.Create("DPanelList", locker_frame)
			pnlLIList:SetPos(30, 65)
			pnlLIList:SetSize(paneWidth, locker_frame:GetTall() - 111)
			pnlLIList:EnableVerticalScrollbar(false) 
			pnlLIList:EnableHorizontal(true) 
			pnlLIList:SetSpacing(1)
			pnlLIList:SetPadding(5)
			--Generates the locker's inventory
			for k, v in pairs( itemTble ) do
				local item = PNRP.Items[k]
				if item then
					local pnlLIPanel = vgui.Create("DPanel", pnlLIList)
						pnlLIPanel:SetSize( 75, 100 )
						pnlLIPanel.Paint = function()
							draw.RoundedBox( 6, 0, 0, pnlLIPanel:GetWide(), pnlLIPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
						end
						
						pnlLIList:AddItem(pnlLIPanel)
						
						pnlLIPanel.NumberWang = vgui.Create( "DNumberWang", pnlLIPanel )
						pnlLIPanel.NumberWang:SetPos(pnlLIPanel:GetWide() / 2 - pnlLIPanel.NumberWang:GetWide() / 2, 75 )
						pnlLIPanel.NumberWang:SetMin( 1 )
						pnlLIPanel.NumberWang:SetMax( v )
						pnlLIPanel.NumberWang:SetDecimals( 0 )
						pnlLIPanel.NumberWang:SetValue( 1 )
						
						pnlLIPanel.Icon = vgui.Create("SpawnIcon", pnlLIPanel)
						pnlLIPanel.Icon:SetModel(item.Model)
						pnlLIPanel.Icon:SetPos(pnlLIPanel:GetWide() / 2 - pnlLIPanel.Icon:GetWide() / 2, 5 )
						pnlLIPanel.Icon:SetToolTip( item.Name.."\n".."Count: "..v.."\n Press Icon to move item." )
						pnlLIPanel.Icon.DoClick = function() 
							net.Start("locker_take")
								net.WriteEntity(ply)
								net.WriteEntity(locker)
								net.WriteString(item.ID)
								net.WriteDouble(pnlLIPanel.NumberWang:GetValue())
							net.SendToServer()
							locker_frame:Close()
						end	
				end
			end
					

		--//Player Inventory
		local PlayerInvLabel = vgui.Create( "DLabel", locker_frame )
			PlayerInvLabel:SetText("Player  Inventory")
			PlayerInvLabel:SetPos(320, 50)
			PlayerInvLabel:SetColor( Color( 255, 255, 255, 255 ) )
			PlayerInvLabel:SizeToContents()
			
		local pnlUserIList = vgui.Create("DPanelList", locker_frame)
			pnlUserIList:SetPos(315, 65)
			pnlUserIList:SetSize(paneWidth, locker_frame:GetTall() - 111)
			pnlUserIList:EnableVerticalScrollbar(false) 
			pnlUserIList:EnableHorizontal(true) 
			pnlUserIList:SetSpacing(1)
			pnlUserIList:SetPadding(5)
			--Generates the user's inventory
			if inventoryTble != nil then
				for k, v in pairs( inventoryTble ) do
					local item = PNRP.Items[k]
					if item then
						local pnlUserIPanel = vgui.Create("DPanel", pnlUserIList)
							pnlUserIPanel:SetSize( 75, 100 )
							pnlUserIPanel.Paint = function()
								draw.RoundedBox( 6, 0, 0, pnlUserIPanel:GetWide(), pnlUserIPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
							end
							
							pnlUserIList:AddItem(pnlUserIPanel)
							
							pnlUserIPanel.NumberWang = vgui.Create( "DNumberWang", pnlUserIPanel )
							pnlUserIPanel.NumberWang:SetPos(pnlUserIPanel:GetWide() / 2 - pnlUserIPanel.NumberWang:GetWide() / 2, 75 )
							pnlUserIPanel.NumberWang:SetMin( 1 )
							pnlUserIPanel.NumberWang:SetMax( v )
							pnlUserIPanel.NumberWang:SetDecimals( 0 )
							pnlUserIPanel.NumberWang:SetValue( 1 )
													
							pnlUserIPanel.Icon = vgui.Create("SpawnIcon", pnlUserIPanel)
							pnlUserIPanel.Icon:SetModel(item.Model)
							pnlUserIPanel.Icon:SetPos(pnlUserIPanel:GetWide() / 2 - pnlUserIPanel.Icon:GetWide() / 2, 5 )
							pnlUserIPanel.Icon:SetToolTip( item.Name.."\n".."Count: "..v.."\n Press Icon to move item." )
							pnlUserIPanel.Icon.DoClick = function() 
									if pnlUserIPanel.NumberWang:GetValue() < 1 then
                                    LocalPlayer():ChatPrint("Not enough to store")
                                    return
                                end
								net.Start("locker_put")
									net.WriteEntity(ply)
									net.WriteEntity(locker)
									net.WriteString(item.ID)
									net.WriteString(tostring(pnlUserIPanel.NumberWang:GetValue()))
								net.SendToServer()
								locker_frame:Close()
							end								
					end
				end
			end

		--//Locker Status			
		local lMenuList = vgui.Create( "DPanelList", locker_frame )
			lMenuList:SetPos( 610,45 )
			lMenuList:SetSize( 150, 175 )
			lMenuList:SetSpacing( 5 )
			lMenuList:SetPadding(3)
			lMenuList:EnableHorizontal( false ) 
			lMenuList:EnableVerticalScrollbar( true ) 

			local stockmenuLabel = vgui.Create("DLabel", locker_frame)
				stockmenuLabel:SetColor( Color( 255, 255, 255, 255 ) )
				stockmenuLabel:SetText( "Locker Menu" )
				stockmenuLabel:SetFont("Trebuchet24")
				stockmenuLabel:SizeToContents()
				lMenuList:AddItem( stockmenuLabel )

			local NameLabel = vgui.Create("DLabel", stockStatusBlankLabel1)
				NameLabel:SetColor( Color( 255, 255, 255, 255 ) )
				NameLabel:SetText( " Locker Status" )
				NameLabel:SizeToContents()
				lMenuList:AddItem( NameLabel )
			local LDevide = vgui.Create("DShape") 
				LDevide:SetParent( stockStatusList ) 
				LDevide:SetType("Rect")
				LDevide:SetSize( 100, 2 ) 	
				lMenuList:AddItem( LDevide )	
			local LHPLabel = vgui.Create("DLabel", stockStatusBlankLabel1)
				LHPLabel:SetColor( Color( 255, 255, 255, 255 ) )
				LHPLabel:SetText( " Health: "..lockerHealth.."%" )
				LHPLabel:SizeToContents()
				lMenuList:AddItem( LHPLabel )

			--//Locker Menu	
			local btnHPos = 250
			local btnWPos = locker_frame:GetWide()-220
			local btnHeight = 40
			local lblColor = Color( 245, 218, 210, 180 )
					
			local repairBtn = vgui.Create("DImageButton", locker_frame)
				repairBtn:SetPos( btnWPos,btnHPos )
				repairBtn:SetSize(30,30)
				repairBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				repairBtn.DoClick = function() 
					net.Start("locker_repair")
						net.WriteEntity(ply)
						net.WriteEntity(locker)
					net.SendToServer()
					locker_frame:Close() 
				end
				repairBtn.Paint = function()
					if repairBtn:IsDown() then 
						repairBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						repairBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end	
			local repairBtnLbl = vgui.Create("DLabel", locker_frame)
				repairBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				repairBtnLbl:SetColor( lblColor )
				repairBtnLbl:SetText( "Repair Locker" )
				repairBtnLbl:SetFont("Trebuchet24")
				repairBtnLbl:SizeToContents()
			
			btnHPos = btnHPos + btnHeight			
			local removeBtn = vgui.Create("DImageButton", locker_frame)
				removeBtn:SetPos( btnWPos,btnHPos )
				removeBtn:SetSize(30,30)
				removeBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				removeBtn.DoClick = function() 
					PNRP.OptionVerify( "pnrp_remlocker", nil, nil ) 
					locker_frame:Close()
				end
				removeBtn.Paint = function()
					if removeBtn:IsDown() then 
						removeBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						removeBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end	
			local removeBtnLbl = vgui.Create("DLabel", locker_frame)
				removeBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				removeBtnLbl:SetColor( lblColor )
				removeBtnLbl:SetText( "Remove Locker" )
				removeBtnLbl:SetFont("Trebuchet24")
				removeBtnLbl:SizeToContents()		
				
end
--datastream.Hook("locker_menu", LockerMenu)
net.Receive("locker_menu", LockerMenu)

local function LckrBreakInBar ()
	surface.SetDrawColor( 0, 0, 0, 100)
	surface.DrawRect(ScrW()/2 - 50 , ScrH()/2, 100, 25 )
	
	local percentage = ((CurTime() - StartTime) + (60 - TimeLeft)) / 60
	
	surface.SetDrawColor( 0, 155, 0, 255 )
	surface.DrawOutlinedRect(ScrW()/2 - 50 , ScrH()/2, 100, 25 )
	surface.DrawRect(ScrW()/2 - 50 , ScrH()/2, 100*percentage, 25 )
end

local function LckrRepairBar ()
	surface.SetDrawColor( 0, 0, 0, 100)
	surface.DrawRect(ScrW()/2 - 50 , ScrH()/2, 100, 25 )
	
	local percentage = ( (60 - TimeLeft) - (CurTime() - StartTime) )  / 60
	
	surface.SetDrawColor( 0, 155, 0, 255 )
	surface.DrawOutlinedRect(ScrW()/2 - 50 , ScrH()/2, 100, 25 )
	surface.DrawRect(ScrW()/2 - 50 , ScrH()/2, 100*percentage, 25 )
end

function LockerBreakIn( )
	local locker = net:ReadEntity()
	local length = net:ReadDouble()
	local ply = LocalPlayer()
	StartTime = CurTime()
	TimeLeft = length
	
	hook.Add( "HUDPaint", "BreakInBar", LckrBreakInBar )
	
	net.Start("locker_breakin")
		net.WriteEntity(ply)
		net.WriteEntity(locker)
	net.SendToServer()
end
net.Receive("locker_breakin", LockerBreakIn)

function LckrStopBreakIn( )
	hook.Remove( "HUDPaint", "BreakInBar")
end
net.Receive("locker_stopbreakin", LckrStopBreakIn)

function LockerRepair( )
	local locker = net:ReadEntity()
	local length = net:ReadDouble()
	
	StartTime = CurTime()
	TimeLeft = length
	
	hook.Add( "HUDPaint", "RepairBar", LckrRepairBar )
end
net.Receive("locker_repair", LockerRepair)

function LckrStopRepair( )
	hook.Remove( "HUDPaint", "RepairBar")
end
net.Receive("locker_stoprepair", LckrStopRepair)
