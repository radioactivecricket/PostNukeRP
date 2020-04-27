include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

function WastelandRadioMenu()
	local ply = LocalPlayer()
	local radioENT = net.ReadEntity()
	local radioInfo = net.ReadTable()
	
	local w = 575
	local h = 250
	local title = "Wasteland Radio"
	
	local origVol = radioInfo["Volume"] * 10
	
	local radio_frame = vgui.Create( "DFrame" )
		radio_frame:SetSize( w, h ) 
		radio_frame:SetPos( ScrW() / 2 - radio_frame:GetWide() / 2, ScrH() / 2 - radio_frame:GetTall() / 2 )
		radio_frame:SetTitle( "" )
		radio_frame:SetVisible( true )
		radio_frame:SetDraggable( false )
		radio_frame:ShowCloseButton( true )
		radio_frame:MakePopup()
		radio_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", radio_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_6b.png" )
			screenBG:SetKeepAspect()
			screenBG:SizeToContents()
			screenBG:SetSize(radio_frame:GetWide(), radio_frame:GetTall())
		
		local ToolName = vgui.Create( "DLabel", radio_frame )
			ToolName:SetPos(35,35)
			ToolName:SetColor(Color( 255, 255, 255, 255 ))
			ToolName:SetFont("Trebuchet24")
			ToolName:SetText( title )
			ToolName:SizeToContents()
		local LDevide = vgui.Create("DShape") 
			LDevide:SetParent( radio_frame ) 
			LDevide:SetType("Rect")
			LDevide:SetSize( 160, 2 ) 
			LDevide:SetPos(35,60)	

		local PlayingLabel = vgui.Create("DLabel", radio_frame)
			PlayingLabel:SetColor( Color( 0, 255, 0, 255 ) )
			PlayingLabel:SetText( "Playing: "..radioInfo["Title"] )
			PlayingLabel:SetPos(40,70)	
			PlayingLabel:SizeToContents()
		
		local SetChannelLabel = vgui.Create("DLabel", radio_frame)
			SetChannelLabel:SetColor( Color( 0, 255, 0, 255 ) )
			SetChannelLabel:SetPos(40,100)
			SetChannelLabel:SetText( "Set FM Channel: " )
			SetChannelLabel:SizeToContents()
		local FMNumberWang = vgui.Create( "DNumberWang", radio_frame )
			FMNumberWang:SetPos(140, 97 )
			FMNumberWang:SetMin( 0 )
			FMNumberWang:SetMax( 110 )
			FMNumberWang:SetDecimals( 1 )
			FMNumberWang:SetValue( radioInfo["FM"] )
		local LoadButton = vgui.Create( "DButton" )
			LoadButton:SetParent( radio_frame )
			LoadButton:SetText( "Set" )
			LoadButton:SetPos( 210, 100 )
			LoadButton:SetSize( 100, 15 )
			LoadButton.DoClick = function ()
				local FM = FMNumberWang:GetValue()
				net.Start("setRadoFM")
					net.WriteEntity(ply)
					net.WriteEntity(radioENT)
					net.WriteDouble(FM)
				net.SendToServer()
				radio_frame:Close()
			end
		
		local SetVolumeLabel = vgui.Create("DLabel", radio_frame)
			SetVolumeLabel:SetColor( Color( 0, 255, 0, 255 ) )
			SetVolumeLabel:SetPos(40,120)
			SetVolumeLabel:SetText( "Set Volume: " )
			SetVolumeLabel:SizeToContents()
		local VolNumberWang = vgui.Create( "DNumberWang", radio_frame )
			VolNumberWang:SetPos(140, 117 )
			VolNumberWang:SetMin( 0 )
			VolNumberWang:SetMax( 10 )
			VolNumberWang:SetValue( origVol )
		local VolButton = vgui.Create( "DButton" )
			VolButton:SetParent( radio_frame )
			VolButton:SetText( "Set" )
			VolButton:SetPos( 210, 120 )
			VolButton:SetSize( 100, 15 )
			VolButton.DoClick = function ()
				local Vol = VolNumberWang:GetValue()
				if Vol < 0 or Vol > 10 then
					Vol = 5
				end
				Vol = Vol / 10
				net.Start("setRadioVol")
					net.WriteEntity(ply)
					net.WriteEntity(radioENT)
					net.WriteDouble(Vol)
				net.SendToServer()
				radio_frame:Close()
			end
			
		local SetSLLabel = vgui.Create("DLabel", radio_frame)
			SetSLLabel:SetColor( Color( 0, 255, 0, 255 ) )
			SetSLLabel:SetPos(40,140)
			SetSLLabel:SetText( "Set Sound Level: " )
			SetSLLabel:SizeToContents()
		local SLNumberWang = vgui.Create( "DNumberWang", radio_frame )
			SLNumberWang:SetPos(140, 137 )
			SLNumberWang:SetMin( 0 )
			SLNumberWang:SetMax( 100 )
			SLNumberWang:SetValue( radioInfo["SoundLevel"] )
		local SLButton = vgui.Create( "DButton" )
			SLButton:SetParent( radio_frame )
			SLButton:SetText( "Set" )
			SLButton:SetPos( 210, 140 )
			SLButton:SetSize( 100, 15 )
			SLButton.DoClick = function ()
				local SL = SLNumberWang:GetValue()
				if SL < 0 or SL > 100 then
					SL = 60
				end
				net.Start("setRadioSL")
					net.WriteEntity(ply)
					net.WriteEntity(radioENT)
					net.WriteDouble(SL)
				net.SendToServer()
				radio_frame:Close()
			end
				
			
		--//Status Screen		
		local lMenuList = vgui.Create( "DPanelList", radio_frame )
			lMenuList:SetPos( 370,35 )
			lMenuList:SetSize( 150, 175 )
			lMenuList:SetSpacing( 5 )
			lMenuList:SetPadding(3)
			lMenuList:EnableHorizontal( false ) 
			lMenuList:EnableVerticalScrollbar( true ) 
			
			local isOn = "Off"
			if radioInfo["IsOn"] then 
				isOn = "On"
			end
			local PowerLabel = vgui.Create("DLabel", radio_frame)
				PowerLabel:SetColor( Color( 0, 255, 0, 255 ) )
				PowerLabel:SetText( "Power: "..isOn)
				PowerLabel:SizeToContents()
				lMenuList:AddItem( PowerLabel )
			local CHLabel = vgui.Create("DLabel", radio_frame)
				CHLabel:SetColor( Color( 0, 255, 0, 255 ) )
				CHLabel:SetText( "Channel: "..round(radioInfo["FM"], 1) )
				CHLabel:SizeToContents()
				lMenuList:AddItem( CHLabel )
			local VLabel = vgui.Create("DLabel", radio_frame)
				VLabel:SetColor( Color( 0, 255, 0, 255 ) )
				VLabel:SetText( "Volume: "..round(origVol, 0) )
				VLabel:SizeToContents()
				lMenuList:AddItem( VLabel )
			local SLLabel = vgui.Create("DLabel", radio_frame)
				SLLabel:SetColor( Color( 0, 255, 0, 255 ) )
				SLLabel:SetText( "Sound Level: "..radioInfo["SoundLevel"] )
				SLLabel:SizeToContents()
				lMenuList:AddItem( SLLabel )
		
		--//Menu Menu	
		local btnHPos = 110
		local btnWPos = radio_frame:GetWide()-220
		local btnHeight = 40
		local lblColor = Color( 245, 218, 210, 180 )
					
		btnHPos = btnHPos + btnHeight
		
		local PlayBtn = vgui.Create("DImageButton", radio_frame)
			PlayBtn:SetPos( btnWPos,btnHPos )
			PlayBtn:SetSize(30,30)
			PlayBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			PlayBtn.DoClick = function() 
				net.Start("WR_On")
					net.WriteEntity(ply)
					net.WriteEntity(radioENT)
				net.SendToServer()
				radio_frame:Close()
			end
			PlayBtn.Paint = function()
				if PlayBtn:IsDown() then 
					PlayBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					PlayBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local PlayBtnLbl = vgui.Create("DLabel", radio_frame)
			PlayBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
			PlayBtnLbl:SetColor( lblColor )
			PlayBtnLbl:SetText( "Power On" )
			PlayBtnLbl:SetFont("Trebuchet24")
			PlayBtnLbl:SizeToContents()
			
		btnHPos = btnHPos + btnHeight
		
		local StopBtn = vgui.Create("DImageButton", radio_frame)
			StopBtn:SetPos( btnWPos,btnHPos )
			StopBtn:SetSize(30,30)
			StopBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			StopBtn.DoClick = function() 
				net.Start("WR_Off")
					net.WriteEntity(ply)
					net.WriteEntity(radioENT)
				net.SendToServer()
				radio_frame:Close()
			end
			StopBtn.Paint = function()
				if StopBtn:IsDown() then 
					StopBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					StopBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local StopBtnLbl = vgui.Create("DLabel", radio_frame)
			StopBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
			StopBtnLbl:SetColor( lblColor )
			StopBtnLbl:SetText( "Power Off" )
			StopBtnLbl:SetFont("Trebuchet24")
			StopBtnLbl:SizeToContents()
			

end
net.Receive("OpenRadioStations", WastelandRadioMenu)

