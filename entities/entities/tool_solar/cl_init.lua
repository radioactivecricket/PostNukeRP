include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

function SolGenMenu( )
	local health = math.Round(net:ReadDouble())
	local powerLevel = math.Round(net:ReadDouble())
	local fuel = math.Round(net:ReadDouble())
	local availFuel = math.Round(net:ReadDouble())
	local isOn = tobool(net:ReadBit())
	local isMeltdown = tobool(net:ReadBit())
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
			genMainLabel:SetText( "Solar Panel" )
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
				NameLabel:SetText( " Panel Status" )
				NameLabel:SizeToContents()
				lMenuList:AddItem( NameLabel )
			local LDevide = vgui.Create("DShape") 
				LDevide:SetParent( stockStatusList ) 
				LDevide:SetType("Rect")
				LDevide:SetSize( 100, 2 ) 	
				lMenuList:AddItem( LDevide )
			local HealthLabel = vgui.Create("DLabel", gen_frame)
			--	HealthLabel:SetPos(10, 55)
				HealthLabel:SetColor( Color( 0, 255, 0, 255 ) )
				HealthLabel:SetText( "Health:  "..tostring(health) )
				HealthLabel:SizeToContents()
				lMenuList:AddItem( HealthLabel )
			local StatusLabel = vgui.Create("DLabel", gen_frame)
			--	StatusLabel:SetPos(10, 40)
				StatusLabel:SetColor( Color( 0, 255, 0, 255 ) )
				StatusLabel:SetText( "Net Power:  "..tostring(powerLevel) )
				StatusLabel:SizeToContents()
				lMenuList:AddItem( StatusLabel )
		
		--//Menu Menu	
		local btnHPos = 150
		local btnWPos = gen_frame:GetWide()-220
		local btnHeight = 40
		local lblColor = Color( 245, 218, 210, 180 )
	
		local PowerBtn = vgui.Create("DImageButton", gen_frame)
			PowerBtn:SetPos( btnWPos,btnHPos )
			PowerBtn:SetSize(30,30)
			if health <= 0 then
				PowerBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
			else
				PowerBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				PowerBtn.DoClick = function() 
					net.Start("togglesolgen_stream")
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
			if health < 200 then
				RepairBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				RepairBtn.DoClick = function() 
					net.Start("repsolgen_stream")
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
net.Receive("solgen_menu", SolGenMenu)
