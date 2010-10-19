include('shared.lua')

local StartTime = CurTime()
local TimeLeft = 30
local breakingIn = false
local savedStockpile = NullEntity()

function ENT:Draw()
	self.Entity:DrawModel()
end

function StockViewCheck()
	local myPlayer = LocalPlayer()
	
	local tracedata = {}
	tracedata.start = myPlayer:GetShootPos()
	tracedata.endpos = tracedata.start + (myPlayer:GetAimVector() * 1000)
	tracedata.filter = myPlayer
	local trace = util.TraceLine(tracedata)
	
	if trace.Entity == NullEntity() then return end
	
	if trace.Entity:GetClass() == "msc_stockpile" then
		local community = trace.Entity:GetNWString("community_owner")
		
		surface.SetFont("TargetID")
		local tWidth, tHeight = surface.GetTextSize(community.." Community Stockpile")
		
		-- surface.SetTextColor(Color(255,255,255,255))
		-- surface.SetTextPos(ScrW() / 2, ScrH() / 2)
		-- surface.DrawText( community.." Community Stockpile" )
		draw.WordBox( 8, (ScrW() / 2) - (8 + (tWidth / 2)), (ScrH() / 2) - (16 + tHeight), community.." Community Stockpile", "TargetID", Color(50,50,75,100), Color(255,255,255,255) )
		
		-- local gridMessage = "Distance:  "..tostring(distance).."\nSpawn Resources:  "..tostring(resources).."\nSpawn Antlions:  "..tostring(antlions).."\nSpawn Zombies:  "..tostring(zombies).."\nCan Make Mounds:  "..tostring(mounds).."\nIs Indoor:  "..tostring(indoor)
		-- AddWorldTip( self.Entity:EntIndex(), gridMessage, 0.5, self.Entity:GetPos(), self.Entity )
	end
end
hook.Add( "HUDPaint", "StockViewCheck", StockViewCheck )

function StockpileMenu( data )
	local stockpile = data:ReadEntity()
	local Scrap = data:ReadLong()
	local Small = data:ReadLong()
	local Chems = data:ReadLong()
	
	local stockHealth = data:ReadShort()
	
	local localScrap = GetResource("Scrap")
	local localSmall = GetResource("Small_Parts")
	local localChems = GetResource("Chemicals")
	
	local w = 210
	local h = 470
	local title = "Stockpile Menu"
	
	local stockmenu_frame = vgui.Create( "DFrame" )
		stockmenu_frame:SetSize( w, h ) 
		stockmenu_frame:SetPos( ScrW() / 2 - stockmenu_frame:GetWide() / 2, ScrH() / 2 - stockmenu_frame:GetTall() / 2 )
		stockmenu_frame:SetTitle( " " )
		stockmenu_frame:SetVisible( true )
		stockmenu_frame:SetDraggable( false )
		stockmenu_frame:ShowCloseButton( false )
		stockmenu_frame:MakePopup()
		stockmenu_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		local stockmenuLabel_frame = vgui.Create( "DFrame" )
			stockmenuLabel_frame:SetParent( stockmenu_frame )
			stockmenuLabel_frame:SetSize( 250, 40 ) 
			stockmenuLabel_frame:SetPos(ScrW() / 2 - stockmenu_frame:GetWide() / 2, ScrH() / 2 - stockmenu_frame:GetTall() / 2 - 25)
			stockmenuLabel_frame:SetTitle( " " )
			stockmenuLabel_frame:SetVisible( true )
			stockmenuLabel_frame:SetDraggable( false )
			stockmenuLabel_frame:ShowCloseButton( false )
			stockmenuLabel_frame:MakePopup()
			stockmenuLabel_frame.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
		
			local stockmenuLabel = vgui.Create("DLabel", stockmenuLabel_frame)
				stockmenuLabel:SetPos(0,0)
				stockmenuLabel:SetColor( Color( 255, 255, 255, 255 ) )
				stockmenuLabel:SetText( "Stockpile Menu" )
				stockmenuLabel:SetFont("Trebuchet24")
				stockmenuLabel:SizeToContents()
				
		local stockMenuList = vgui.Create( "DPanelList", stockmenu_frame )
			stockMenuList:SetPos( 0,0 )
			stockMenuList:SetSize( stockmenu_frame:GetWide(), stockmenu_frame:GetTall() )
			stockMenuList:SetSpacing( 1 )
			stockMenuList:SetPadding(5)
			stockMenuList:EnableHorizontal( false ) 
			stockMenuList:EnableVerticalScrollbar( true )
			--//Take Section
			local BlankLabel1 = vgui.Create( "Label", stockMenuList )
				BlankLabel1:SetText(" ")
				BlankLabel1:SizeToContents()
				stockMenuList:AddItem( BlankLabel1 )
			local TakeLabel = vgui.Create( "Label", stockMenuList )
				TakeLabel:SetText("Take Materials:")
				TakeLabel:SizeToContents()
				stockMenuList:AddItem( TakeLabel )
			local ScrapSlider = vgui.Create( "DNumSlider", stockMenuList )
				ScrapSlider:SetSize( stockMenuList:GetWide()-20, 40 )
				ScrapSlider:SetText("Scrap")
				ScrapSlider:SetMin( 0 )
				ScrapSlider:SetMax( Scrap )
				ScrapSlider:SetDecimals( 0 )
				stockMenuList:AddItem( ScrapSlider )
			local SmallSlider = vgui.Create( "DNumSlider", stockMenuList )
				SmallSlider:SetSize( stockMenuList:GetWide()-20, 40 )
				SmallSlider:SetText("Small Parts")
				SmallSlider:SetMin( 0 )
				SmallSlider:SetMax( Small )
				SmallSlider:SetDecimals( 0 )
				stockMenuList:AddItem( SmallSlider )
			local ChemsSlider = vgui.Create( "DNumSlider", stockMenuList )
				ChemsSlider:SetSize( stockMenuList:GetWide()-20, 40 )
				ChemsSlider:SetText("Chemicals")
				ChemsSlider:SetMin( 0 )
				ChemsSlider:SetMax( Chems )
				ChemsSlider:SetDecimals( 0 )
				stockMenuList:AddItem( ChemsSlider )
			local TakeButton = vgui.Create( "DButton" )
				TakeButton:SetParent( stockMenuList )
				TakeButton:SetText( "Take" )
				TakeButton:SetSize( stockMenuList:GetWide()-20, 20 )
				TakeButton.DoClick = function()
					datastream.StreamToServer( "stockpile_take", {["stockpile"] = stockpile, ["scrap"] = ScrapSlider:GetValue(), ["small"] = SmallSlider:GetValue(), ["chems"] = ChemsSlider:GetValue() } )
					stockmenu_frame:Close()
				end
				stockMenuList:AddItem( TakeButton )
			local BlankLabel2 = vgui.Create( "Label", stockMenuList )
				BlankLabel2:SetText(" ")
				BlankLabel2:SizeToContents()
				stockMenuList:AddItem( BlankLabel2 )
			local devide1 = vgui.Create("DShape") 
				devide1:SetParent( stockMenuList ) 
				devide1:SetType("Rect")
				devide1:SetSize( 100, 2 ) 	
				stockMenuList:AddItem( devide1 )
			local BlankLabel3 = vgui.Create( "Label", stockMenuList )
				BlankLabel3:SetText(" ")
				BlankLabel3:SizeToContents()
				stockMenuList:AddItem( BlankLabel3 )
			--//Store Menu
			local StoreLabel = vgui.Create( "Label", stockMenuList )
				StoreLabel:SetText("Store Materials:")
				StoreLabel:SizeToContents()
				stockMenuList:AddItem( StoreLabel )
			local sScrapSlider = vgui.Create( "DNumSlider", stockMenuList )
				sScrapSlider:SetSize( stockMenuList:GetWide()-20, 40 )
				sScrapSlider:SetText("Scrap")
				sScrapSlider:SetMin( 0 )
				sScrapSlider:SetMax( localScrap )
				sScrapSlider:SetDecimals( 0 )
				stockMenuList:AddItem( sScrapSlider )
			local sSmallSlider = vgui.Create( "DNumSlider", stockMenuList )
				sSmallSlider:SetSize( stockMenuList:GetWide()-20, 40 )
				sSmallSlider:SetText("Small Parts")
				sSmallSlider:SetMin( 0 )
				sSmallSlider:SetMax( localSmall )
				sSmallSlider:SetDecimals( 0 )
				stockMenuList:AddItem( sSmallSlider )
			local sChemsSlider = vgui.Create( "DNumSlider", stockMenuList )
				sChemsSlider:SetSize( stockMenuList:GetWide()-20, 40 )
				sChemsSlider:SetText("Chemicals")
				sChemsSlider:SetMin( 0 )
				sChemsSlider:SetMax( localChems )
				sChemsSlider:SetDecimals( 0 )
				stockMenuList:AddItem( sChemsSlider )
			local sTakeButton = vgui.Create( "DButton" )
				sTakeButton:SetParent( stockMenuList )
				sTakeButton:SetText( "Store" )
				sTakeButton:SetSize( stockMenuList:GetWide()-20, 20 )
				sTakeButton.DoClick = function()
					datastream.StreamToServer( "stockpile_put", {["stockpile"] = stockpile, ["scrap"] = sScrapSlider:GetValue(), ["small"] = sSmallSlider:GetValue(), ["chems"] = sChemsSlider:GetValue() } )
					stockmenu_frame:Close()
				end
				stockMenuList:AddItem( sTakeButton )
			local BlankLabel4 = vgui.Create( "Label", stockMenuList )
				BlankLabel4:SetText(" ")
				BlankLabel4:SizeToContents()
				stockMenuList:AddItem( BlankLabel4 )
			local devide2 = vgui.Create("DShape") 
				devide2:SetParent( stockMenuList ) 
				devide2:SetType("Rect")
				devide2:SetSize( 100, 2 ) 	
				stockMenuList:AddItem( devide2 )
			local BlankLabel5 = vgui.Create( "Label", stockMenuList )
				BlankLabel5:SetText(" ")
				BlankLabel5:SizeToContents()
				stockMenuList:AddItem( BlankLabel5 )
			local repStockBtn = vgui.Create("DButton") 
				repStockBtn:SetParent( stockMenuList ) 
				repStockBtn:SetText( "Repair Stockpile" ) 
				repStockBtn:SetSize( 100, 20 ) 
				repStockBtn.DoClick = function() datastream.StreamToServer( "stockpile_repair", {["stockpile"] = stockpile} ) stockmenu_frame:Close() end
				stockMenuList:AddItem( repStockBtn )				
			local remStockBtn = vgui.Create("DButton") 
				remStockBtn:SetParent( stockMenuList ) 
				remStockBtn:SetText( "Remove Stockpile" ) 
				remStockBtn:SetSize( 100, 20 ) 
				remStockBtn.DoClick = function() PNRP.OptionVerify( "pnrp_remstock", nil, nil ) stockmenu_frame:Close() end	
				stockMenuList:AddItem( remStockBtn )
			local exitBtn = vgui.Create("DButton") 
				exitBtn:SetParent( stockMenuList ) 
				exitBtn:SetText( "Exit" ) 
				exitBtn:SetSize( 100, 20 ) 
				exitBtn.DoClick = function() stockmenu_frame:Close() end	
				stockMenuList:AddItem( exitBtn )
	
		--//Community Status Window
		local stockStatus_frame = vgui.Create( "DFrame" )
			stockStatus_frame:SetParent( stockmenu_frame )
			stockStatus_frame:SetSize( 125, 150 ) 
			stockStatus_frame:SetPos(ScrW() / 2 + stockmenu_frame:GetWide() / 2 + 10, ScrH() / 2 - stockmenu_frame:GetTall() / 2) 
			stockStatus_frame:SetTitle( " " )
			stockStatus_frame:SetVisible( true )
			stockStatus_frame:SetDraggable( false )
			stockStatus_frame:ShowCloseButton( false )
			stockStatus_frame:MakePopup()
			stockStatus_frame.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end	
		
		local stockStatusList = vgui.Create( "DPanelList", stockStatus_frame )
				stockStatusList:SetPos( 0,0 )
				stockStatusList:SetSize( stockStatus_frame:GetWide(), stockStatus_frame:GetTall() )
				stockStatusList:SetSpacing( 2 )
				stockStatusList:EnableHorizontal( false ) 
				stockStatusList:EnableVerticalScrollbar( true ) 
			
			local stockStatusBlankLabel1 = vgui.Create("DLabel", stockStatusList)
				stockStatusBlankLabel1:SetColor( Color( 255, 255, 255, 0 ) )
				stockStatusBlankLabel1:SetText( " " )
				stockStatusBlankLabel1:SizeToContents()
				stockStatusList:AddItem( stockStatusBlankLabel1 )
			local stockStatusNameLabel = vgui.Create("DLabel", stockStatusBlankLabel1)
				stockStatusNameLabel:SetColor( Color( 255, 255, 255, 255 ) )
				stockStatusNameLabel:SetText( " Stockpile Status" )
				stockStatusNameLabel:SizeToContents()
				stockStatusList:AddItem( stockStatusNameLabel )
			local stockStatusdevide1 = vgui.Create("DShape") 
				stockStatusdevide1:SetParent( stockStatusList ) 
				stockStatusdevide1:SetType("Rect")
				stockStatusdevide1:SetSize( 100, 2 ) 	
				stockStatusList:AddItem( stockStatusdevide1 )	
			local stockStatusNameLabel = vgui.Create("DLabel", stockStatusBlankLabel1)
				stockStatusNameLabel:SetColor( Color( 255, 255, 255, 255 ) )
				stockStatusNameLabel:SetText( " Health: "..stockHealth.."%" )
				stockStatusNameLabel:SizeToContents()
				stockStatusList:AddItem( stockStatusNameLabel )
			local stockStatusBlankLabel1 = vgui.Create("DLabel", stockStatusList)
				stockStatusBlankLabel1:SetColor( Color( 255, 255, 255, 0 ) )
				stockStatusBlankLabel1:SetText( " " )
				stockStatusBlankLabel1:SizeToContents()
				stockStatusList:AddItem( stockStatusBlankLabel1 )
			local stockStatusNameLabel = vgui.Create("DLabel", stockStatusBlankLabel1)
				stockStatusNameLabel:SetColor( Color( 255, 255, 255, 255 ) )
				stockStatusNameLabel:SetText( " Scrap: "..Scrap )
				stockStatusNameLabel:SizeToContents()
				stockStatusList:AddItem( stockStatusNameLabel )
			local stockStatusNameLabel = vgui.Create("DLabel", stockStatusBlankLabel1)
				stockStatusNameLabel:SetColor( Color( 255, 255, 255, 255 ) )
				stockStatusNameLabel:SetText( " Small Parts: "..Small )
				stockStatusNameLabel:SizeToContents()
				stockStatusList:AddItem( stockStatusNameLabel )
			local stockStatusNameLabel = vgui.Create("DLabel", stockStatusBlankLabel1)
				stockStatusNameLabel:SetColor( Color( 255, 255, 255, 255 ) )
				stockStatusNameLabel:SetText( " Chemicals: "..Chems )
				stockStatusNameLabel:SizeToContents()
				stockStatusList:AddItem( stockStatusNameLabel )
end
usermessage.Hook("stockpile_menu", StockpileMenu)

local function BreakInBar ()
	surface.SetDrawColor( 0, 0, 0, 100)
	surface.DrawRect(ScrW()/2 - 50 , ScrH()/2, 100, 25 )
	
	local percentage = ((CurTime() - StartTime) + (30 - TimeLeft)) / 30
	
	surface.SetDrawColor( 0, 155, 0, 255 )
	surface.DrawOutlinedRect(ScrW()/2 - 50 , ScrH()/2, 100, 25 )
	surface.DrawRect(ScrW()/2 - 50 , ScrH()/2, 100*percentage, 25 )
end

local function RepairBar ()
	surface.SetDrawColor( 0, 0, 0, 100)
	surface.DrawRect(ScrW()/2 - 50 , ScrH()/2, 100, 25 )
	
	local percentage = ( (30 - TimeLeft) - (CurTime() - StartTime) )  / 30
	
	surface.SetDrawColor( 0, 155, 0, 255 )
	surface.DrawOutlinedRect(ScrW()/2 - 50 , ScrH()/2, 100, 25 )
	surface.DrawRect(ScrW()/2 - 50 , ScrH()/2, 100*percentage, 25 )
end

function StockpileBreakIn( data )
	local stockpile = data:ReadEntity()
	local length = data:ReadShort()
	
	StartTime = CurTime()
	TimeLeft = length
	
	hook.Add( "HUDPaint", "BreakInBar", BreakInBar )
	
	datastream.StreamToServer( "stockpile_breakin", {["stockpile"] = stockpile} )
end
usermessage.Hook("stockpile_breakin", StockpileBreakIn)

function StopBreakIn( data )
	hook.Remove( "HUDPaint", "BreakInBar")
end
usermessage.Hook("stockpile_stopbreakin", StopBreakIn)

function StockpileRepair( data )
	local stockpile = data:ReadEntity()
	local length = data:ReadShort()
	
	StartTime = CurTime()
	TimeLeft = length
	
	hook.Add( "HUDPaint", "RepairBar", RepairBar )
end
usermessage.Hook("stockpile_repair", StockpileRepair)

function StopRepair( data )
	hook.Remove( "HUDPaint", "RepairBar")
end
usermessage.Hook("stockpile_stoprepair", StopRepair)
