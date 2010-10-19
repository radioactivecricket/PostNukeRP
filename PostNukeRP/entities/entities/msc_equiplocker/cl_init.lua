include('shared.lua')

local StartTime = CurTime()
local TimeLeft = 60
local breakingIn = false
local savedLocker = NullEntity()

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
	
	if trace.Entity == NullEntity() then return end
	
	if trace.Entity:GetClass() == "msc_equiplocker" then
		local community = trace.Entity:GetNWString("community_owner")
		
		surface.SetFont("TargetID")
		local tWidth, tHeight = surface.GetTextSize(community.." Community Equipment")
		
		-- surface.SetTextColor(Color(255,255,255,255))
		-- surface.SetTextPos(ScrW() / 2, ScrH() / 2)
		-- surface.DrawText( community.." Community Locker" )
		draw.WordBox( 8, (ScrW() / 2) - (8 + (tWidth / 2)), (ScrH() / 2) - (16 + tHeight), community.." Community Equipment", "TargetID", Color(50,50,75,100), Color(255,255,255,255) )
		
		-- local gridMessage = "Distance:  "..tostring(distance).."\nSpawn Resources:  "..tostring(resources).."\nSpawn Antlions:  "..tostring(antlions).."\nSpawn Zombies:  "..tostring(zombies).."\nCan Make Mounds:  "..tostring(mounds).."\nIs Indoor:  "..tostring(indoor)
		-- AddWorldTip( self.Entity:EntIndex(), gridMessage, 0.5, self.Entity:GetPos(), self.Entity )
	end
end
hook.Add( "HUDPaint", "LockerViewCheck", LockerViewCheck )

function LockerMenu( handle, id, encoded, decoded )
	local locker = decoded["locker"]
	local itemTble = decoded["items"]
	local inventoryTble = decoded["inventory"]
	local lockerHealth = decoded["health"]
	
	local locker_frame = vgui.Create( "DFrame" )
		locker_frame:SetSize( 560, 450 ) --Set the size
		locker_frame:SetPos(ScrW() / 2 - locker_frame:GetWide() / 2, ScrH() / 2 - locker_frame:GetTall() / 2) 
		locker_frame:SetTitle( " " ) --Set title
		locker_frame:SetVisible( true )
		locker_frame:SetDraggable( false )
		locker_frame:ShowCloseButton( false )
		locker_frame:MakePopup()
		locker_frame.Paint = function() -- Paint function
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		--Floating Lable
		local lockermenuLabel_frame = vgui.Create( "DFrame" )
			lockermenuLabel_frame:SetParent( locker_frame )
			lockermenuLabel_frame:SetSize( 250, 40 ) 
			lockermenuLabel_frame:SetPos(ScrW() / 2 - locker_frame:GetWide() / 2, ScrH() / 2 - locker_frame:GetTall() / 2 - 25)
			lockermenuLabel_frame:SetTitle( " " )
			lockermenuLabel_frame:SetVisible( true )
			lockermenuLabel_frame:SetDraggable( false )
			lockermenuLabel_frame:ShowCloseButton( false )
			lockermenuLabel_frame:MakePopup()
			lockermenuLabel_frame.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
			local stockmenuLabel = vgui.Create("DLabel", lockermenuLabel_frame)
				stockmenuLabel:SetPos(0,0)
				stockmenuLabel:SetColor( Color( 255, 255, 255, 255 ) )
				stockmenuLabel:SetText( "Community Locker Menu" )
				stockmenuLabel:SetFont("Trebuchet24")
				stockmenuLabel:SizeToContents()
		--//Locker Inventory
		local fi_TabSheet = vgui.Create( "DPropertySheet" )
			fi_TabSheet:SetParent( locker_frame )
			fi_TabSheet:SetPos( 5, 0 )
			fi_TabSheet:SetSize( locker_frame:GetWide() / 2 - 10, locker_frame:GetTall() )
			
			local pnlLIList = vgui.Create("DPanelList", fi_TabSheet)
				pnlLIList:SetPos(5, 5)
				pnlLIList:SetSize(fi_TabSheet:GetWide() - 5, fi_TabSheet:GetTall() - 40)
				pnlLIList:EnableVerticalScrollbar(false) 
				pnlLIList:EnableHorizontal(true) 
				pnlLIList:SetSpacing(1)
				pnlLIList:SetPadding(5)
				--Generates the locker's inventory
				for k, v in pairs( itemTble ) do
					local item = PNRP.Items[k]
					local pnlLIPanel = vgui.Create("DPanel", pnlLIList)
						pnlLIPanel:SetSize( 80, 100 )
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
							datastream.StreamToServer( "locker_take", {["locker"] = locker, ["item"] = item.ID, ["amount"] = pnlLIPanel.NumberWang:GetValue() } )
							locker_frame:Close()
						end							
				end
					
		fi_TabSheet:AddSheet( "Locker Inventory", pnlLIList, "gui/silkicons/brick_add", false, false, "Locker Inventory" )
		--//Player Inventory
		local pi_TabSheet = vgui.Create( "DPropertySheet" )
			pi_TabSheet:SetParent( locker_frame )
			pi_TabSheet:SetPos( locker_frame:GetWide() / 2 + 5, 0 )
			pi_TabSheet:SetSize( locker_frame:GetWide() / 2 - 10, locker_frame:GetTall() )
			
			local pnlUserIList = vgui.Create("DPanelList", pi_TabSheet)
				pnlUserIList:SetPos(5, 5)
				pnlUserIList:SetSize(pi_TabSheet:GetWide() - 5, pi_TabSheet:GetTall() - 40)
				pnlUserIList:EnableVerticalScrollbar(false) 
				pnlUserIList:EnableHorizontal(true) 
				pnlUserIList:SetSpacing(1)
				pnlUserIList:SetPadding(5)
				--Generates the user's inventory
				if inventoryTble != nil then
					for k, v in pairs( inventoryTble ) do
						local item = PNRP.Items[k]
						local pnlUserIPanel = vgui.Create("DPanel", pnlUserIList)
							pnlUserIPanel:SetSize( 80, 100 )
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
								datastream.StreamToServer( "locker_put", {["locker"] = locker, ["item"] = item.ID, ["amount"] = pnlUserIPanel.NumberWang:GetValue() } )
								locker_frame:Close()
							end								
					end
				end
		
		pi_TabSheet:AddSheet( "Player Inventory", pnlUserIList, "gui/silkicons/user", false, false, "Player Inventory" )
		--//Locker Menu and Status
		local communityMenu_frame = vgui.Create( "DFrame" )
			communityMenu_frame:SetParent( locker_frame )
			communityMenu_frame:SetSize( 100, pnlLIList:GetTall() + 40 ) 
			communityMenu_frame:SetPos( ScrW() / 2 + locker_frame:GetWide() / 2 + 5, ScrH() / 2 - locker_frame:GetTall() / 2 )
			communityMenu_frame:SetTitle( " " )
			communityMenu_frame:SetVisible( true )
			communityMenu_frame:SetDraggable( false )
			communityMenu_frame:ShowCloseButton( true )
			communityMenu_frame:MakePopup()
			communityMenu_frame.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
			
		local lMenuList = vgui.Create( "DPanelList", communityMenu_frame )
			lMenuList:SetPos( 0,0 )
			lMenuList:SetSize( communityMenu_frame:GetWide(), communityMenu_frame:GetTall() )
			lMenuList:SetSpacing( 5 )
			lMenuList:SetPadding(3)
			lMenuList:EnableHorizontal( false ) 
			lMenuList:EnableVerticalScrollbar( true ) 	
			
			local BlankLabel = vgui.Create("DLabel", lMenuList	)
				BlankLabel:SetColor( Color( 255, 255, 255, 0 ) )
				BlankLabel:SetText( " " )
				BlankLabel:SizeToContents()
				lMenuList:AddItem( BlankLabel )
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
			local BlankLabel = vgui.Create("DLabel", lMenuList	)
				BlankLabel:SetColor( Color( 255, 255, 255, 0 ) )
				BlankLabel:SetText( " " )
				BlankLabel:SizeToContents()
				lMenuList:AddItem( BlankLabel )
			local LDevide = vgui.Create("DShape") 
				LDevide:SetParent( stockStatusList ) 
				LDevide:SetType("Rect")
				LDevide:SetSize( 100, 2 ) 	
				lMenuList:AddItem( LDevide )
			local repLockerBtn = vgui.Create("DButton") 
				repLockerBtn:SetParent( lMenuList ) 
				repLockerBtn:SetText( "Repair Locker" ) 
				repLockerBtn:SetSize( 100, 20 ) 
				repLockerBtn.DoClick = function() datastream.StreamToServer( "locker_repair", {["locker"] = locker} ) locker_frame:Close() end
				lMenuList:AddItem( repLockerBtn )
			local remLockerBtn = vgui.Create("DButton") 
				remLockerBtn:SetParent( lMenuList ) 
				remLockerBtn:SetText( "Remove Locker" ) 
				remLockerBtn:SetSize( 100, 20 ) 
				remLockerBtn.DoClick = function() PNRP.OptionVerify( "pnrp_remlocker", nil, nil ) locker_frame:Close() end	
				lMenuList:AddItem( remLockerBtn )
			local exitBtn = vgui.Create("DButton") 
				exitBtn:SetParent( lMenuList ) 
				exitBtn:SetText( "Exit" ) 
				exitBtn:SetSize( 100, 20 ) 
				exitBtn.DoClick = function() locker_frame:Close() end	
				lMenuList:AddItem( exitBtn )
end
datastream.Hook("locker_menu", LockerMenu)

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

function LockerBreakIn( data )
	local locker = data:ReadEntity()
	local length = data:ReadShort()
	
	StartTime = CurTime()
	TimeLeft = length
	
	hook.Add( "HUDPaint", "BreakInBar", LckrBreakInBar )
	
	datastream.StreamToServer( "locker_breakin", {["locker"] = locker} )
end
usermessage.Hook("locker_breakin", LockerBreakIn)

function LckrStopBreakIn( data )
	hook.Remove( "HUDPaint", "BreakInBar")
end
usermessage.Hook("locker_stopbreakin", LckrStopBreakIn)

function LockerRepair( data )
	local locker = data:ReadEntity()
	local length = data:ReadShort()
	
	StartTime = CurTime()
	TimeLeft = length
	
	hook.Add( "HUDPaint", "RepairBar", LckrRepairBar )
end
usermessage.Hook("locker_repair", LockerRepair)

function LckrStopRepair( data )
	hook.Remove( "HUDPaint", "RepairBar")
end
usermessage.Hook("locker_stoprepair", LckrStopRepair)
