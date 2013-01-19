include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

function WastelandTransMenu()
	local ply = LocalPlayer()
	local radioENT = net.ReadEntity()
	local stations = net.ReadTable()
	local playList = net.ReadTable()
	local Info = net.ReadTable()
	
	local w = 810
	local h = 520
	local title = "Wasteland Radio"
	
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
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_5b.png" )
			screenBG:SetKeepAspect()
			screenBG:SizeToContents()
			screenBG:SetSize(radio_frame:GetWide(), radio_frame:GetTall())
		
		local FoundMusicLabel = vgui.Create("DLabel", radio_frame)
			FoundMusicLabel:SetColor( Color( 0, 255, 0, 255 ) )
			FoundMusicLabel:SetPos(40,40)
			FoundMusicLabel:SetText( "Available Music" )
			FoundMusicLabel:SizeToContents()
			
		local PlaylistLabel = vgui.Create("DLabel", radio_frame)
			PlaylistLabel:SetColor( Color( 0, 255, 0, 255 ) )
			PlaylistLabel:SetPos(320,40)
			PlaylistLabel:SetText( "Playlist (Right-Click song to remove it)" )
			PlaylistLabel:SizeToContents()
			
	--//Playlist	
		local PlaylistView = vgui.Create("DListView")
			PlaylistView:SetParent(radio_frame)
			PlaylistView:SetPos(320, 60)
			PlaylistView:SetSize(240, 405)
			PlaylistView:SetMultiSelect(false)
			PlaylistView:AddColumn("Track")
			PlaylistView:AddColumn("File")
			PlaylistView:AddColumn("Time")	
			PlaylistView.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 150 )
			end			
			local listCounter = 1
			for k,v in pairs(playList) do
				PlaylistView:AddLine(v[1], v[2],round(v[3]/60,2)) 
				listCounter = listCounter + 1
			end
			if playList and table.Count(playList) > 0 then
				local tblSize = table.Count(playList)
				listCounter = playList[tblSize][1] + 1
			end
			PlaylistView.OnRowRightClick = function( panel, line, isselected )
				PlaylistView:RemoveLine(line)
				table.remove(playList, line)
				net.Start("WR_FMUpdatePlaylist")
					net.WriteEntity(ply)
					net.WriteEntity(radioENT)
					net.WriteTable(playList)
				net.SendToServer()
			end
			
	--Music List	
		local pnlList = vgui.Create("DPanelList", radio_frame)
			pnlList:SetPos(20, 55)
			pnlList:SetSize(260, radio_frame:GetTall() - 105)
			pnlList:EnableVerticalScrollbar(true) 
			pnlList:EnableHorizontal(false) 
			pnlList:SetSpacing(1)
			pnlList:SetPadding(10)
			pnlList.Paint = function()
			--	draw.RoundedBox( 8, 0, 0, pnlList:GetWide(), pnlList:GetTall(), Color( 50, 50, 50, 255 ) )
			end
		for k, v in pairs(file.Find("sound/music/*", "GAME" )) do
			if not stations[v] then
				stations[v] = SoundDuration( "music/"..v ) * 2
			end
		end
			
			for file, sTime in pairs(stations) do
				local pnlPanel = vgui.Create("DPanel")
				pnlPanel:SetTall(25)
				pnlPanel.Paint = function()
					draw.RoundedBox( 1, 0, 0, pnlPanel:GetWide(), pnlPanel:GetTall(), Color( 0, 0, 0, 150 ) )		
				end
				pnlList:AddItem(pnlPanel)
				local fileName = string.sub(file, 0, -5)
				pnlPanel.Title = vgui.Create("DLabel", pnlPanel)
				pnlPanel.Title:SetPos(5, 5)
				pnlPanel.Title:SetText(fileName)
				pnlPanel.Title:SetColor(Color( 0, 255, 0, 255 ))
				pnlPanel.Title:SizeToContents() 
				pnlPanel.Title:SetContentAlignment( 5 )
				
				local duration = sTime / 60
				pnlPanel.Duration = vgui.Create("DLabel", pnlPanel)
				pnlPanel.Duration:SetPos(180, 5)
				pnlPanel.Duration:SetText(round(duration,2))
				pnlPanel.Duration:SetColor(Color( 0, 255, 0, 255 ))
				pnlPanel.Duration:SizeToContents() 
				pnlPanel.Duration:SetContentAlignment( 5 )
				
				pnlPanel.PlayBtn = vgui.Create("DImageButton", pnlPanel )
				pnlPanel.PlayBtn:SetImage( "gui/icons/add.png" )
				pnlPanel.PlayBtn:SetPos(210, 5)
				pnlPanel.PlayBtn:SetSize(15,15)
				pnlPanel.PlayBtn.DoClick = function() 
				--	playList[listCounter] = {file, sTime}
					table.insert(playList, {listCounter, file, sTime})
					net.Start("WR_FMUpdatePlaylist")
						net.WriteEntity(ply)
						net.WriteEntity(radioENT)
						net.WriteTable(playList)
					net.SendToServer()
					PlaylistView:AddLine(listCounter, fileName,round((sTime/60),2))
					listCounter = listCounter + 1
				--	radio_frame:Close()
				end
			end
				
		--//Status Screen		
		local lMenuList = vgui.Create( "DPanelList", radio_frame )
			lMenuList:SetPos( 610,35 )
			lMenuList:SetSize( 155, 175 )
			lMenuList:SetSpacing( 5 )
			lMenuList:SetPadding(3)
			lMenuList:EnableHorizontal( false ) 
			lMenuList:EnableVerticalScrollbar( true )
			local ToolName = vgui.Create( "DLabel", radio_frame )
				ToolName:SetColor(Color( 0, 255, 0, 255 ))
				ToolName:SetFont("Trebuchet24")
				ToolName:SetText( title )
				ToolName:SizeToContents()
				lMenuList:AddItem( ToolName )
			local LDevide = vgui.Create("DShape") 
					LDevide:SetParent( stockStatusList ) 
					LDevide:SetColor(Color( 0, 255, 0, 255 ))
					LDevide:SetType("Rect")
					LDevide:SetSize( 100, 2 ) 	
					lMenuList:AddItem( LDevide )
			local isPowerOn = "Off"
			if Info["isOn"] then isPowerOn = "On" end
			local PowerLbl = vgui.Create( "DLabel", radio_frame )
				PowerLbl:SetColor(Color( 0, 255, 0, 255 ))
				PowerLbl:SetText( "Power: "..isPowerOn )
				PowerLbl:SizeToContents()
				lMenuList:AddItem( PowerLbl )
			local isPlaying
			if Info["playing"] then isPlaying = "Yes"
			else isPlaying = "No" end
			local PlayingLbl = vgui.Create( "DLabel", radio_frame )
				PlayingLbl:SetColor(Color( 0, 255, 0, 255 ))
				PlayingLbl:SetText( "Playing: "..isPlaying )
				PlayingLbl:SizeToContents()
				lMenuList:AddItem( PlayingLbl )
			local stFileName = Info["file"]
			stFileName = string.sub(stFileName, 0, 5)	
			local FileNameLbl = vgui.Create( "DLabel", radio_frame )
				FileNameLbl:SetColor(Color( 0, 255, 0, 255 ))
				FileNameLbl:SetText( "File: " )
				FileNameLbl:SizeToContents()
				lMenuList:AddItem( FileNameLbl )
			local ChannelLbl = vgui.Create( "DLabel", radio_frame )
				ChannelLbl:SetColor(Color( 0, 255, 0, 255 ))
				ChannelLbl:SetText( "Channel: "..round(Info["FM"], 2))
				ChannelLbl:SizeToContents()
				lMenuList:AddItem( ChannelLbl )
			local TrackLbl = vgui.Create( "DLabel", radio_frame )
				TrackLbl:SetColor(Color( 0, 255, 0, 255 ))
				TrackLbl:SetText( "Track: "..tostring(Info["Track"]))
				TrackLbl:SizeToContents()
				lMenuList:AddItem( TrackLbl )
				
		--//Menu Menu	
		local btnHPos = 220
		local btnWPos = radio_frame:GetWide()-220
		local btnHeight = 40
		local lblColor = Color( 245, 218, 210, 180 )
		
		local PowerBtn = vgui.Create("DImageButton", radio_frame)
			PowerBtn:SetPos( btnWPos,btnHPos )
			PowerBtn:SetSize(30,30)
			PowerBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			PowerBtn.DoClick = function() 
				net.Start("WR_FMTogglePower")
					net.WriteEntity(ply)
					net.WriteEntity(radioENT)
				net.SendToServer()
				radio_frame:Close()
			end
			PowerBtn.Paint = function()
				if PowerBtn:IsDown() then 
					PowerBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					PowerBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local PowerBtnLbl = vgui.Create("DLabel", radio_frame)
			PowerBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
			PowerBtnLbl:SetColor( lblColor )
			PowerBtnLbl:SetText( "Toggle Power" )
			PowerBtnLbl:SetFont("Trebuchet24")
			PowerBtnLbl:SizeToContents()
		
		btnHPos = btnHPos + btnHeight		
		local SetChannelBtn = vgui.Create("DImageButton", radio_frame)
			SetChannelBtn:SetPos( btnWPos,btnHPos )
			SetChannelBtn:SetSize(30,30)
			SetChannelBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			SetChannelBtn.DoClick = function() 
				WR_TransFM(radioENT, Info["FM"])
				radio_frame:Close()	
			end
			SetChannelBtn.Paint = function()
				if SetChannelBtn:IsDown() then 
					SetChannelBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					SetChannelBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local SetChannelBtnLbl = vgui.Create("DLabel", radio_frame)
			SetChannelBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
			SetChannelBtnLbl:SetColor( lblColor )
			SetChannelBtnLbl:SetText( "Set Channel" )
			SetChannelBtnLbl:SetFont("Trebuchet24")
			SetChannelBtnLbl:SizeToContents()
		
		btnHPos = btnHPos + btnHeight
		local PlayBtn = vgui.Create("DImageButton", radio_frame)
			PlayBtn:SetPos( btnWPos,btnHPos )
			PlayBtn:SetSize(30,30)
			PlayBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			PlayBtn.DoClick = function() 
				net.Start("WR_FMToggleTreansmit")
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
			PlayBtnLbl:SetText( "Play/Stop" )
			PlayBtnLbl:SetFont("Trebuchet24")
			PlayBtnLbl:SizeToContents()
		
		btnHPos = btnHPos + btnHeight
		local NextBtn = vgui.Create("DImageButton", radio_frame)
			NextBtn:SetPos( btnWPos,btnHPos )
			NextBtn:SetSize(30,30)
			NextBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			NextBtn.DoClick = function() 
				net.Start("WR_FMNextTrack")
					net.WriteEntity(ply)
					net.WriteEntity(radioENT)
				net.SendToServer()
				radio_frame:Close()
			end
			NextBtn.Paint = function()
				if NextBtn:IsDown() then 
					NextBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					NextBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local StopBtnLbl = vgui.Create("DLabel", radio_frame)
			StopBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
			StopBtnLbl:SetColor( lblColor )
			StopBtnLbl:SetText( "Next Track" )
			StopBtnLbl:SetFont("Trebuchet24")
			StopBtnLbl:SizeToContents()
			
		btnHPos = btnHPos + btnHeight		
		local ClearListBtn = vgui.Create("DImageButton", radio_frame)
			ClearListBtn:SetPos( btnWPos,btnHPos )
			ClearListBtn:SetSize(30,30)
			ClearListBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			ClearListBtn.DoClick = function() 
				net.Start("WR_FMResetPlaylist")
					net.WriteEntity(ply)
					net.WriteEntity(radioENT)
				net.SendToServer()
				radio_frame:Close()				
			end
			ClearListBtn.Paint = function()
				if ClearListBtn:IsDown() then 
					ClearListBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					ClearListBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local ClearListBtnLbl = vgui.Create("DLabel", radio_frame)
			ClearListBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
			ClearListBtnLbl:SetColor( lblColor )
			ClearListBtnLbl:SetText( "Clear Playlist" )
			ClearListBtnLbl:SetFont("Trebuchet24")
			ClearListBtnLbl:SizeToContents()
		
		btnHPos = btnHPos + btnHeight		
		local TglVoiceBtn = vgui.Create("DImageButton", radio_frame)
			TglVoiceBtn:SetPos( btnWPos,btnHPos )
			TglVoiceBtn:SetSize(30,30)
			TglVoiceBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			TglVoiceBtn.DoClick = function() 
				
				--Toggle Voice Code here
				
			end
			TglVoiceBtn.Paint = function()
				if TglVoiceBtn:IsDown() then 
					TglVoiceBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					TglVoiceBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
				TglVoiceBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
			end	
		local TglVoiceBtnLbl = vgui.Create("DLabel", radio_frame)
			TglVoiceBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
			TglVoiceBtnLbl:SetColor( lblColor )
			TglVoiceBtnLbl:SetText( "Toggle Voice" )
			TglVoiceBtnLbl:SetFont("Trebuchet24")
			TglVoiceBtnLbl:SizeToContents()
			
end
net.Receive("OpenTransMainMenu", WastelandTransMenu)

function WR_TransFM(transENT, FM)
	local ply = LocalPlayer()
	
	local w = 410
	local h = 250
	local title = "Wasteland Radio"
	
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
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_2b.png" )
			screenBG:SetKeepAspect()
			screenBG:SizeToContents()
			screenBG:SetSize(radio_frame:GetWide(), radio_frame:GetTall())
			
		local FoundMusicLabel = vgui.Create("DLabel", radio_frame)
			FoundMusicLabel:SetColor( Color( 0, 255, 0, 255 ) )
			FoundMusicLabel:SetPos(60,40)
			FoundMusicLabel:SetFont("Trebuchet24")
			FoundMusicLabel:SetText( "Set Transmitter Channel" )
			FoundMusicLabel:SizeToContents()
			
		local SetChannelLabel = vgui.Create("DLabel", radio_frame)
			SetChannelLabel:SetColor( Color( 0, 255, 0, 255 ) )
			SetChannelLabel:SetPos(60,80)
			SetChannelLabel:SetText( "Set FM Channel: " )
			SetChannelLabel:SizeToContents()
		local FMNumberWang = vgui.Create( "DNumberWang", radio_frame )
			FMNumberWang:SetPos(160, 77 )
			FMNumberWang:SetMin( 0 )
			FMNumberWang:SetMax( 110 )
			FMNumberWang:SetDecimals( 1 )
			FMNumberWang:SetValue( FM )
		local LoadButton = vgui.Create( "DButton" )
			LoadButton:SetParent( radio_frame )
			LoadButton:SetText( "Set" )
			LoadButton:SetPos( 230, 80 )
			LoadButton:SetSize( 100, 15 )
			LoadButton.DoClick = function ()
				local newFM = FMNumberWang:GetValue()
				net.Start("WR_FMSetChannel")
					net.WriteEntity(ply)
					net.WriteEntity(transENT)
					net.WriteDouble(newFM)
				net.SendToServer()
				radio_frame:Close()
			end
end


