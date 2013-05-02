include('shared.lua')

local StartTime = CurTime()
local TimeLeft = 30
local breakingIn = false
local savedStockpile = nil

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
	
	if !trace.Entity:IsValid() then return end
	
	if trace.Entity:GetClass() == "msc_stockpile" then
		local community = trace.Entity:GetNWString("communityName")
		
		surface.SetFont("CenterPrintText")
		local tWidth, tHeight = surface.GetTextSize(community.." Community Stockpile")
		
		-- surface.SetTextColor(Color(255,255,255,255))
		-- surface.SetTextPos(ScrW() / 2, ScrH() / 2)
		-- surface.DrawText( community.." Community Stockpile" )
		draw.WordBox( 8, (ScrW() / 2) - (8 + (tWidth / 2)), (ScrH() / 2) - (16 + tHeight), community.." Community Stockpile", "CenterPrintText", Color(50,50,75,100), Color(255,255,255,255) )
		
		-- local gridMessage = "Distance:  "..tostring(distance).."\nSpawn Resources:  "..tostring(resources).."\nSpawn Antlions:  "..tostring(antlions).."\nSpawn Zombies:  "..tostring(zombies).."\nCan Make Mounds:  "..tostring(mounds).."\nIs Indoor:  "..tostring(indoor)
		-- AddWorldTip( self.Entity:EntIndex(), gridMessage, 0.5, self.Entity:GetPos(), self.Entity )
	end
end
hook.Add( "HUDPaint", "StockViewCheck", StockViewCheck )

function StockpileMenu( )
	local ply = LocalPlayer()
	PNRP.RMDerma()
	local stockpile = net:ReadEntity()
	local Scrap = math.Round(net:ReadDouble())
	local Small = math.Round(net:ReadDouble())
	local Chems = math.Round(net:ReadDouble())
	
	local stockHealth = math.Round(net:ReadDouble())
	
	local localScrap = GetResource("Scrap")
	local localSmall = GetResource("Small_Parts")
	local localChems = GetResource("Chemicals")
	
	local w = 810
	local h = 520
	local title = "Stockpile Menu"
		
	local stockmenu_frame = vgui.Create( "DFrame" )
		stockmenu_frame:SetSize( w, h ) 
		stockmenu_frame:SetPos( ScrW() / 2 - stockmenu_frame:GetWide() / 2, ScrH() / 2 - stockmenu_frame:GetTall() / 2 )
		stockmenu_frame:SetTitle( " " )
		stockmenu_frame:SetVisible( true )
		stockmenu_frame:SetDraggable( false )
		stockmenu_frame:ShowCloseButton( true )
		stockmenu_frame:MakePopup()
		stockmenu_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		PNRP.AddMenu(stockmenu_frame)
		
		local screenBG = vgui.Create("DImage", stockmenu_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_5b.png" )
			screenBG:SetSize(stockmenu_frame:GetWide(), stockmenu_frame:GetTall())	
				
		--//Take Section		
		local takeStockMenuList = vgui.Create( "DPanelList", stockmenu_frame )
			takeStockMenuList:SetPos( 40,50 )
			takeStockMenuList:SetSize( 225, stockmenu_frame:GetTall() - 150 )
			takeStockMenuList:SetSpacing( 1 )
			takeStockMenuList:SetPadding(5)
			takeStockMenuList:EnableHorizontal( false ) 
			takeStockMenuList:EnableVerticalScrollbar( true )
			
			local TakeLabel = vgui.Create( "DLabel", takeStockMenuList )
				TakeLabel:SetText("Take Materials:")
				TakeLabel:SetColor( Color( 255, 255, 255, 255 ) )
				TakeLabel:SizeToContents()
				takeStockMenuList:AddItem( TakeLabel )
			local tScrapSlider = vgui.Create( "DNumSlider", takeStockMenuList )
				tScrapSlider:SetSize( takeStockMenuList:GetWide()-20, 40 )
				tScrapSlider:SetText("Scrap")
				tScrapSlider:SetMin( 0 )
				tScrapSlider:SetMax( Scrap )
				tScrapSlider:SetDecimals( 0 )
				tScrapSlider:SetValue( 0 )
				tScrapSlider.Label:SetWide(75)
				takeStockMenuList:AddItem( tScrapSlider )
			local tSmallSlider = vgui.Create( "DNumSlider", takeStockMenuList )
				tSmallSlider:SetSize( takeStockMenuList:GetWide()-20, 40 )
				tSmallSlider:SetText("Small Parts")
				tSmallSlider:SetMin( 0 )
				tSmallSlider:SetMax( Small )
				tSmallSlider:SetDecimals( 0 )
				tSmallSlider:SetValue( 0 )
				tSmallSlider.Label:SetWide(75)
				takeStockMenuList:AddItem( tSmallSlider )
			local tChemsSlider = vgui.Create( "DNumSlider", takeStockMenuList )
				tChemsSlider:SetSize( takeStockMenuList:GetWide()-20, 40 )
				tChemsSlider:SetText("Chemicals")
				tChemsSlider:SetMin( 0 )
				tChemsSlider:SetMax( Chems )
				tChemsSlider:SetDecimals( 0 )
				tChemsSlider:SetValue( 0 )
				tChemsSlider.Label:SetWide(75)
				takeStockMenuList:AddItem( tChemsSlider )
			local stockBlankLabel1 = vgui.Create("DLabel", takeStockMenuList)
				stockBlankLabel1:SetColor( Color( 255, 255, 255, 0 ) )
				stockBlankLabel1:SetText( " " )
				stockBlankLabel1:SizeToContents()
				takeStockMenuList:AddItem( stockBlankLabel1 )
			local TakeButton = vgui.Create( "DButton" )
				TakeButton:SetParent( takeStockMenuList )
				TakeButton:SetText( "Take" )
				TakeButton:SetSize( takeStockMenuList:GetWide()-20, 20 )
				TakeButton.DoClick = function()
					net.Start("stockpile_take")
						net.WriteEntity(ply)
						net.WriteEntity(stockpile)
						net.WriteDouble(tScrapSlider:GetValue())
						net.WriteDouble(tSmallSlider:GetValue())
						net.WriteDouble(tChemsSlider:GetValue())
					net.SendToServer()
					stockmenu_frame:Close()
				end
				takeStockMenuList:AddItem( TakeButton )
				
		--//Store Menu	
		local storeStockMenuList = vgui.Create( "DPanelList", stockmenu_frame )
			storeStockMenuList:SetPos( 320,50 )
			storeStockMenuList:SetSize( 225, stockmenu_frame:GetTall() - 150 )
			storeStockMenuList:SetSpacing( 1 )
			storeStockMenuList:SetPadding(5)
			storeStockMenuList:EnableHorizontal( false ) 
			storeStockMenuList:EnableVerticalScrollbar( true )
			
			local StoreLabel = vgui.Create( "DLabel", storeStockMenuList )
				StoreLabel:SetText("Store Materials:")
				StoreLabel:SetColor( Color( 255, 255, 255, 255 ) )
				StoreLabel:SizeToContents()
				storeStockMenuList:AddItem( StoreLabel )
			local sScrapSlider = vgui.Create( "DNumSlider", storeStockMenuList )
				sScrapSlider:SetSize( storeStockMenuList:GetWide()-20, 40 )
				sScrapSlider:SetText("Scrap")
				sScrapSlider:SetMin( 0 )
				sScrapSlider:SetMax( localScrap )
				sScrapSlider:SetDecimals( 0 )
				sScrapSlider:SetValue( 0 )
				sScrapSlider.Label:SetWide(75)
				storeStockMenuList:AddItem( sScrapSlider )
			local sSmallSlider = vgui.Create( "DNumSlider", storeStockMenuList )
				sSmallSlider:SetSize( storeStockMenuList:GetWide()-20, 40 )
				sSmallSlider:SetText("Small Parts")
				sSmallSlider:SetMin( 0 )
				sSmallSlider:SetMax( localSmall )
				sSmallSlider:SetDecimals( 0 )
				sSmallSlider:SetValue( 0 )
				sSmallSlider.Label:SetWide(75)
				storeStockMenuList:AddItem( sSmallSlider )
			local sChemsSlider = vgui.Create( "DNumSlider", storeStockMenuList )
				sChemsSlider:SetSize( storeStockMenuList:GetWide()-20, 40 )
				sChemsSlider:SetText("Chemicals")
				sChemsSlider:SetMin( 0 )
				sChemsSlider:SetMax( localChems )
				sChemsSlider:SetDecimals( 0 )
				sChemsSlider:SetValue( 0 )
				sChemsSlider.Label:SetWide(75)
				storeStockMenuList:AddItem( sChemsSlider )
			local stockBlankLabel1 = vgui.Create("DLabel", storeStockMenuList)
				stockBlankLabel1:SetColor( Color( 255, 255, 255, 0 ) )
				stockBlankLabel1:SetText( " " )
				stockBlankLabel1:SizeToContents()
				storeStockMenuList:AddItem( stockBlankLabel1 )
			local sTakeButton = vgui.Create( "DButton" )
				sTakeButton:SetParent( storeStockMenuList )
				sTakeButton:SetText( "Store" )
				sTakeButton:SetSize( storeStockMenuList:GetWide()-20, 20 )
				sTakeButton.DoClick = function()
					net.Start("stockpile_put")
						net.WriteEntity(ply)
						net.WriteEntity(stockpile)
						net.WriteDouble(sScrapSlider:GetValue())
						net.WriteDouble(sSmallSlider:GetValue())
						net.WriteDouble(sChemsSlider:GetValue())
					net.SendToServer()
					stockmenu_frame:Close()
				end
				storeStockMenuList:AddItem( sTakeButton )
				
			--//Stockpile Menu	
			local btnHPos = 250
			local btnWPos = stockmenu_frame:GetWide()-220
			local btnHeight = 40
			local lblColor = Color( 245, 218, 210, 180 )
					
			local repairBtn = vgui.Create("DImageButton", stockmenu_frame)
				repairBtn:SetPos( btnWPos,btnHPos )
				repairBtn:SetSize(30,30)
				repairBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				repairBtn.DoClick = function() 
					net.Start("stockpile_repair")
						net.WriteEntity(ply)
						net.WriteEntity(stockpile)
					net.SendToServer()
					stockmenu_frame:Close() 
				end
				repairBtn.Paint = function()
					if repairBtn:IsDown() then 
						repairBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						repairBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end	
			local repairBtnLbl = vgui.Create("DLabel", stockmenu_frame)
				repairBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				repairBtnLbl:SetColor( lblColor )
				repairBtnLbl:SetText( "Repair Stockpile" )
				repairBtnLbl:SetFont("Trebuchet24")
				repairBtnLbl:SizeToContents()
			
			btnHPos = btnHPos + btnHeight			
			local removeBtn = vgui.Create("DImageButton", stockmenu_frame)
				removeBtn:SetPos( btnWPos,btnHPos )
				removeBtn:SetSize(30,30)
				removeBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				removeBtn.DoClick = function() 
					PNRP.OptionVerify( "pnrp_remstock", nil, nil ) 
					stockmenu_frame:Close()
				end
				removeBtn.Paint = function()
					if removeBtn:IsDown() then 
						removeBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						removeBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end	
			local removeBtnLbl = vgui.Create("DLabel", stockmenu_frame)
				removeBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				removeBtnLbl:SetColor( lblColor )
				removeBtnLbl:SetText( "Remove Stockpile" )
				removeBtnLbl:SetFont("Trebuchet24")
				removeBtnLbl:SizeToContents()		

	
		--//Community Status Window
		local stockStatusList = vgui.Create( "DPanelList", stockmenu_frame )
				stockStatusList:SetPos( 610,45 )
				stockStatusList:SetSize( 150, 175 )
				stockStatusList:SetSpacing( 2 )
				stockStatusList:EnableHorizontal( false ) 
				stockStatusList:EnableVerticalScrollbar( false ) 
			
			local stockmenuLabel = vgui.Create("DLabel", stockmenu_frame)
			--	stockmenuLabel:SetPos(40,50)
				stockmenuLabel:SetColor( Color( 255, 255, 255, 255 ) )
				stockmenuLabel:SetText( "Stockpile Menu" )
				stockmenuLabel:SetFont("Trebuchet24")
				stockmenuLabel:SizeToContents()	
				stockStatusList:AddItem( stockmenuLabel )				
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
net.Receive("stockpile_menu", StockpileMenu)

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

function StockpileBreakIn( )
	local stockpile = net:ReadEntity()
	local length = net:ReadDouble()
	local ply = LocalPlayer()
	
	StartTime = CurTime()
	TimeLeft = length
	
	hook.Add( "HUDPaint", "BreakInBar", BreakInBar )
	
	--datastream.StreamToServer( "stockpile_breakin", {["stockpile"] = stockpile} )
	net.Start("stockpile_breakin")
		net.WriteEntity(ply)
		net.WriteEntity(stockpile)
	net.SendToServer()
end
net.Receive("stockpile_breakin", StockpileBreakIn)

function StopBreakIn( )
	hook.Remove( "HUDPaint", "BreakInBar")
end
net.Receive("stockpile_stopbreakin", StopBreakIn)

function StockpileRepair( )
	local stockpile = net:ReadEntity()
	local length = net:ReadDouble()
	
	StartTime = CurTime()
	TimeLeft = length
	
	hook.Add( "HUDPaint", "RepairBar", RepairBar )
end
net.Receive("stockpile_repair", StockpileRepair)

function StopRepair( )
	hook.Remove( "HUDPaint", "RepairBar")
end
net.Receive("stockpile_stoprepair", StopRepair)
