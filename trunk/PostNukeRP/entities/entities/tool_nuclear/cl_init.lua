include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

function NucGenMenu( )
	local health = math.Round(net:ReadDouble())
	local powerLevel = math.Round(net:ReadDouble())
	local fuel = math.Round(net:ReadDouble())
	local fuelLeft = math.Round(net:ReadDouble())
	local availFuel = math.Round(net:ReadDouble())
	local isOn = tobool(net:ReadBit())
	local isMeltdown = tobool(net:ReadBit())
	local toMeltdown = math.Round(net:ReadDouble())
	local isNoReturn = tobool(net:ReadBit())
	local toCrit = math.Round(net:ReadDouble())
	local genEnt = net:ReadEntity()
	local ply = LocalPlayer()
	
	local w = 575
	local h = 250
	local title = "Generator Menu"

	local gen_frame = vgui.Create("DFrame")
		gen_frame:SetSize( w, h )
		gen_frame:SetTitle( title )
		gen_frame:SetVisible( true )
		gen_frame:SetDraggable( true )
		gen_frame:ShowCloseButton( true )
		gen_frame:Center()
		gen_frame:MakePopup()
		gen_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
	
		local screenBG = vgui.Create("DImage", gen_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_6b.png" )
			screenBG:SetKeepAspect()
			screenBG:SizeToContents()
			screenBG:SetSize(gen_frame:GetWide(), gen_frame:GetTall())		
			
		local genIcon = vgui.Create("SpawnIcon", gen_frame)
			genIcon:SetModel(genEnt:GetModel())
			genIcon:SetPos(30,30)
		local genMainLabel = vgui.Create("DLabel", gen_frame)
			genMainLabel:SetColor( Color( 255, 255, 255, 255 ) )
			genMainLabel:SetPos(100,40)
			genMainLabel:SetText( "Nuclear Generator" )
			genMainLabel:SetFont("Trebuchet24")
			genMainLabel:SizeToContents()
		local LDevide = vgui.Create("DShape") 
			LDevide:SetParent( gen_frame ) 
			LDevide:SetType("Rect")
			LDevide:SetSize( 130, 2 ) 
			LDevide:SetPos(100,65)	
	
		local powertxt = "off"
		local PowerlLabel = vgui.Create("DLabel", gen_frame)
			PowerlLabel:SetColor( Color( 0, 255, 0, 255 ) )
			PowerlLabel:SetPos(40,90)
			PowerlLabel:SetText( "Power: " )
			PowerlLabel:SizeToContents()	
		local pwrIndicator = vgui.Create("DShape") 
			pwrIndicator:SetParent( gen_frame ) 
			pwrIndicator:SetType("Rect")
			pwrIndicator:SetSize( 100, 15 ) 
			if isOn then
				powertxt = "Online"
				pwrIndicator:SetColor( Color( 0, 255, 0, 255 ) )
			else
				powertxt = "Offline"
				pwrIndicator:SetColor( Color( 255, 0, 0, 255 ) )
			end
			pwrIndicator:SetPos(80,90)
		local isOnLabel = vgui.Create("DLabel", gen_frame)
			isOnLabel:SetColor( Color( 255, 255, 255, 255 ) )
			isOnLabel:SetPos(110,90)
			isOnLabel:SetText( powertxt )
			isOnLabel:SizeToContents()
		local genhasFuelLabel = vgui.Create("DLabel", gen_frame)
			genhasFuelLabel:SetColor( Color( 0, 255, 0, 255 ) )
			genhasFuelLabel:SetPos(40,108)
			genhasFuelLabel:SetText( "Fuel Level: "..fuel )
			genhasFuelLabel:SizeToContents()
			
		local loadFuelLabel = vgui.Create("DLabel", gen_frame)
			loadFuelLabel:SetColor( Color( 0, 255, 0, 255 ) )
			loadFuelLabel:SetPos(40,130)
			loadFuelLabel:SetText( "Load More Fuel: " )
			loadFuelLabel:SizeToContents()
		local fuelNumberWang = vgui.Create( "DNumberWang", gen_frame )
			fuelNumberWang:SetPos(140, 127 )
			fuelNumberWang:SetMin( 0 )
			fuelNumberWang:SetMax( availFuel )
			fuelNumberWang:SetDecimals( 0 )
			fuelNumberWang:SetValue( 0 )
		local LoadButton = vgui.Create( "DButton" )
			LoadButton:SetParent( gen_frame )
			LoadButton:SetText( "Load" )
			LoadButton:SetPos( 210, 130 )
			LoadButton:SetSize( 100, 15 )
			LoadButton.DoClick = function ()
				local lFuel = fuelNumberWang:GetValue()
				if lFuel < 0 then lFuel = 0 end
				if lFuel > availFuel then lFuel = availFuel end
				net.Start("loadnucgen_stream")
					net.WriteDouble(lFuel)
					net.WriteEntity(ply)
					net.WriteEntity(genEnt)
				net.SendToServer()
				gen_frame:Close()
			end
			
		local unloadFuelLabel = vgui.Create("DLabel", gen_frame)
			unloadFuelLabel:SetColor( Color( 0, 255, 0, 255 ) )
			unloadFuelLabel:SetPos(40,160)
			unloadFuelLabel:SetText( "Unload Some Fuel: " )
			unloadFuelLabel:SizeToContents()
		local fuel2NumberWang = vgui.Create( "DNumberWang", gen_frame )
			fuel2NumberWang:SetPos(140, 157 )
			fuel2NumberWang:SetMin( 0 )
			fuel2NumberWang:SetMax( fuel )
			fuel2NumberWang:SetDecimals( 0 )
			fuel2NumberWang:SetValue( 0 )
		local UnloadButton = vgui.Create( "DButton" )
			UnloadButton:SetParent( gen_frame )
			UnloadButton:SetText( "Unload" )
			UnloadButton:SetPos( 210, 160 )
			UnloadButton:SetSize( 100, 15 )
			UnloadButton.DoClick = function ()
				local unFuel = fuel2NumberWang:GetValue()
				fuel = tonumber(fuel)
				if unFuel > 0 then 
					if unFuel > fuel then unFuel = fuel end
					net.Start("unloadnucgen_stream")
						net.WriteDouble(unFuel)
						net.WriteEntity(ply)
						net.WriteEntity(genEnt)
					net.SendToServer()
				end
				gen_frame:Close()
			end
	
		--//Status Screen		
		local lMenuList = vgui.Create( "DPanelList", gen_frame )
			lMenuList:SetPos( 375,35 )
			lMenuList:SetSize( 150, 175 )
			lMenuList:SetSpacing( 5 )
			lMenuList:SetPadding(3)
			lMenuList:EnableHorizontal( false ) 
			lMenuList:EnableVerticalScrollbar( true ) 
			
			local NameLabel = vgui.Create("DLabel")
				NameLabel:SetColor( Color( 255, 255, 255, 255 ) )
				NameLabel:SetText( " Generator Status" )
				NameLabel:SizeToContents()
				lMenuList:AddItem( NameLabel )
			local LDevide = vgui.Create("DShape") 
				LDevide:SetParent( stockStatusList ) 
				LDevide:SetType("Rect")
				LDevide:SetSize( 100, 2 ) 	
				lMenuList:AddItem( LDevide )
			local HealthLabel = vgui.Create("DLabel", gen_frame)
				HealthLabel:SetColor( Color( 0, 255, 0, 255 ) )
				HealthLabel:SetText( "Health:  "..tostring(health) )
				HealthLabel:SizeToContents()
				lMenuList:AddItem( HealthLabel )
			local StatusLabel = vgui.Create("DLabel", gen_frame)
				StatusLabel:SetColor( Color( 0, 255, 0, 255 ) )
				StatusLabel:SetText( "Net Power:  "..tostring(powerLevel) )
				StatusLabel:SizeToContents()
				lMenuList:AddItem( StatusLabel )
			local fuelTime = fuel
			fuelLeft = round(fuelLeft / 60, 2) + fuelTime
			local FuelLabel = vgui.Create("DLabel", gen_frame)
				FuelLabel:SetColor( Color( 0, 255, 0, 255 ) )
				FuelLabel:SetText( fuelLeft.." minute(s) of fuel" )
				FuelLabel:SizeToContents()
				lMenuList:AddItem( FuelLabel )
				
		--//Menu Menu	
		local btnHPos = 150
		local btnWPos = gen_frame:GetWide()-220
		local btnHeight = 40
		local lblColor = Color( 245, 218, 210, 180 )
	
		local PowerBtn = vgui.Create("DImageButton", gen_frame)
			PowerBtn:SetPos( btnWPos,btnHPos )
			PowerBtn:SetSize(30,30)
		--//If Unit is in meltdown	
			if isMeltdown then
				
				PowerlLabel:SetVisible( false )
				pwrIndicator:SetVisible( false )
				isOnLabel:SetVisible( false )
				genhasFuelLabel:SetVisible( false )
				loadFuelLabel:SetVisible( false )
				fuelNumberWang:SetVisible( false )
				LoadButton:SetVisible( false )
				unloadFuelLabel:SetVisible( false )
				fuel2NumberWang:SetVisible( false )
				UnloadButton:SetVisible( false )
		
				local MeltDownLabel = vgui.Create("DLabel", gen_frame)
					MeltDownLabel:SetColor( Color( 255, 0, 0, 255 ) )
					MeltDownLabel:SetPos(100,75)
					MeltDownLabel:SetText( "[[EMERGENCY]]" )
					MeltDownLabel:SetFont("Trebuchet24")
					MeltDownLabel:SizeToContents()
				local MeltDownLabel = vgui.Create("DLabel", gen_frame)
					MeltDownLabel:SetColor( Color( 255, 0, 0, 255 ) )
					MeltDownLabel:SetPos(110,100)
					MeltDownLabel:SetText( "Meltdown in progress" )
					MeltDownLabel:SetFont("Trebuchet18")
					MeltDownLabel:SizeToContents()
				
				local EmergencyButtonRdEdges = vgui.Create( "DPanel", gen_frame )
					EmergencyButtonRdEdges:SetPos( 85, 120 )
					EmergencyButtonRdEdges:SetSize( 170, 40 )
					EmergencyButtonRdEdges.Paint = function() -- Paint function
						draw.RoundedBox( 6, 0, 0, EmergencyButtonRdEdges:GetWide(), EmergencyButtonRdEdges:GetTall(), Color( 50, 50, 50, 255 ) )							
					end
				
				local EmergencyButton = vgui.Create( "DImageButton" )
					EmergencyButton:SetParent( gen_frame )
				--	EmergencyButton:SetColor( Color( 255, 0, 0, 255 ) )
					EmergencyButton:SetPos( 90, 125 )
					EmergencyButton:SetSize( 160, 30 )
					EmergencyButton:SetMaterial( "phoenix_storms/stripes" )
					EmergencyButton.DoClick = function ()
						net.Start("emernucgen_stream")
							net.WriteEntity(ply)
							net.WriteEntity(genEnt)
						net.SendToServer()
						gen_frame:Close()
					end
				local MeltDownLabel = vgui.Create("DLabel", gen_frame)
					MeltDownLabel:SetColor( Color( 255, 255, 255, 255 ) )
					MeltDownLabel:SetPos(110,130)
					MeltDownLabel:SetText( "Emergency Shutdown!" )
					MeltDownLabel:SetFont("Trebuchet18")
					MeltDownLabel:SizeToContents()
				local MeltDownLabel = vgui.Create("DLabel", gen_frame)
					MeltDownLabel:SetColor( Color( 255, 0, 0, 255 ) )
					MeltDownLabel:SetPos(100,170)
					MeltDownLabel:SetText( "Unit goes CRITICAL in "..toMeltdown )
					MeltDownLabel:SetFont("Trebuchet18")
					MeltDownLabel:SizeToContents()
				
			end
			if isNoReturn then
				PowerlLabel:SetVisible( false )
				pwrIndicator:SetVisible( false )
				isOnLabel:SetVisible( false )
				genhasFuelLabel:SetVisible( false )
				loadFuelLabel:SetVisible( false )
				fuelNumberWang:SetVisible( false )
				LoadButton:SetVisible( false )
				unloadFuelLabel:SetVisible( false )
				fuel2NumberWang:SetVisible( false )
				UnloadButton:SetVisible( false )
				
				local TheEndBGRdEdges = vgui.Create( "DPanel", gen_frame )
					TheEndBGRdEdges:SetPos( 50, 80 )
					TheEndBGRdEdges:SetSize( 250, 130 )
					TheEndBGRdEdges.Paint = function() -- Paint function
						draw.RoundedBox( 6, 0, 0, TheEndBGRdEdges:GetWide(), TheEndBGRdEdges:GetTall(), Color( 50, 50, 50, 255 ) )							
					end
					local TheEndBG = vgui.Create( "DImageButton" )
						TheEndBG:SetParent( TheEndBGRdEdges )
						TheEndBG:SetColor( Color( 255, 0, 0, 255 ) )
						TheEndBG:SetPos( 5, 5 )
						TheEndBG:SetSize( TheEndBGRdEdges:GetWide()-10, TheEndBGRdEdges:GetTall()-10 )
						TheEndBG:SetMaterial( "phoenix_storms/stripes" )
						TheEndBG.DoClick = function ()
							ply:ChatPrint("There is nothing more you can do. RUN FOR IT!")
						end
				local MeltDownLabel = vgui.Create("DLabel", gen_frame)
					MeltDownLabel:SetColor( Color( 255, 150, 20, 255 ) )
					MeltDownLabel:SetPos(100,85)
					MeltDownLabel:SetText( "<[-[ DANGER ]-]>" )
					MeltDownLabel:SetFont("Trebuchet24")
					MeltDownLabel:SizeToContents()
				local MeltDownLabel = vgui.Create("DLabel", gen_frame)
					MeltDownLabel:SetColor( Color( 255, 150, 20, 255 ) )
					MeltDownLabel:SetPos(70,110)
					MeltDownLabel:SetText( "UNIT IS GOING CRITICLE" )
					MeltDownLabel:SetFont("Trebuchet24")
					MeltDownLabel:SizeToContents()
				
				local MeltDownLabel = vgui.Create("DLabel", gen_frame)
					MeltDownLabel:SetColor( Color( 255, 150, 20, 255 ) )
					MeltDownLabel:SetPos(65,140)
					MeltDownLabel:SetText( "EMERGENCY SHUTDOWN NOT POSSIBLE" )
					MeltDownLabel:SetFont("Trebuchet18")
					MeltDownLabel:SizeToContents()
				local MeltDownLabel = vgui.Create("DLabel", gen_frame)
					MeltDownLabel:SetColor( Color( 255, 150, 20, 255 ) )
					MeltDownLabel:SetPos(120,155)
					MeltDownLabel:SetText( "EVACUATE THE AREA" )
					MeltDownLabel:SetFont("Trebuchet18")
					MeltDownLabel:SizeToContents()
				local MeltDownLabel = vgui.Create("DLabel", gen_frame)
					MeltDownLabel:SetColor( Color( 255, 150, 20, 255 ) )
					MeltDownLabel:SetPos(135,180)
					MeltDownLabel:SetText( "CRITICAL IN "..toCrit )
					MeltDownLabel:SetFont("Trebuchet18")
					MeltDownLabel:SizeToContents()	
			end
			if isMeltdown or health <= 0 or isNoReturn then
				PowerBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
			else
				PowerBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				PowerBtn.DoClick = function() 
					net.Start("togglenucgen_stream")
						net.WriteEntity(ply)
						net.WriteEntity(genEnt)
					net.SendToServer()
					gen_frame:Close() 
				end
				PowerBtn.Paint = function()
					if PowerBtn:IsDown() then 
						PowerBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						PowerBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end
			end
			local PowerBtnLbl = vgui.Create("DLabel", gen_frame)
				PowerBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				PowerBtnLbl:SetColor( lblColor )
				PowerBtnLbl:SetText( "Toggle Power" )
				PowerBtnLbl:SetFont("Trebuchet24")
				PowerBtnLbl:SizeToContents()
				
		btnHPos = btnHPos + btnHeight
		local RepairBtn = vgui.Create("DImageButton", gen_frame)
			RepairBtn:SetPos( btnWPos,btnHPos )
			RepairBtn:SetSize(30,30)
			if health < 200 and not isNoReturn and not isMeltdown then
				RepairBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				RepairBtn.DoClick = function() 
					net.Start("repnucgen_stream")
						net.WriteEntity(ply)
						net.WriteEntity(genEnt)
					net.SendToServer()
					gen_frame:Close() 
				end
				RepairBtn.Paint = function()
					if RepairBtn:IsDown() then 
						RepairBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						RepairBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end			
			else
				RepairBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
			end
			local RepairBtnLbl = vgui.Create("DLabel", gen_frame)
				RepairBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				RepairBtnLbl:SetColor( lblColor )
				RepairBtnLbl:SetText( "Repair Unit" )
				RepairBtnLbl:SetFont("Trebuchet24")
				RepairBtnLbl:SizeToContents()

end
net.Receive("nucgen_menu", NucGenMenu)
