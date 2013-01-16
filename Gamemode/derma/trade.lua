
local trade_frame

function open_trade(ply)
	
	trade_frame = vgui.Create( "DFrame" )
		trade_frame:SetSize( 710, 510 ) --Set the size
		trade_frame:SetPos(ScrW() / 2 - trade_frame:GetWide() / 2, ScrH() / 2 - trade_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
		trade_frame:SetTitle( "Trade Menu" ) --Set title
		trade_frame:SetVisible( true )
		trade_frame:SetDraggable( true )
		trade_frame:ShowCloseButton( true )
		trade_frame:MakePopup()
		trade_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", trade_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_2b.png" )
			screenBG:SetSize(trade_frame:GetWide(), trade_frame:GetTall())
			
		PNRP.buildMenu(trade_frame)
		
		local PlayerList = vgui.Create("DPanelList", trade_frame)
			PlayerList:SetPos(40, 60)
			PlayerList:SetSize(trade_frame:GetWide() - 85, trade_frame:GetTall() - 105)
			PlayerList:EnableVerticalScrollbar(true) 
			PlayerList:EnableHorizontal(false) 
			PlayerList:SetSpacing(1)
			PlayerList:SetPadding(10)
			PlayerList.Paint = function()
			--	draw.RoundedBox( 8, 0, 0, PlayerList:GetWide(), PlayerList:GetTall(), Color( 50, 50, 50, 255 ) )
			end
		
		local listPlayers = ents.FindInSphere( ply:GetPos(), 500 )
		local counter = 0
		for _, v in pairs(listPlayers) do
			if v:GetClass()=="player" and v ~= ply then
				
				counter = counter + 1
				
				local PlayerPanel = vgui.Create("DPanel")
				PlayerPanel:SetTall(75)
				PlayerPanel.Paint = function()
				
					draw.RoundedBox( 6, 0, 0, PlayerPanel:GetWide(), PlayerPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
			
				end
				PlayerList:AddItem(PlayerPanel)
		
				PlayerPanel.Icon = vgui.Create("SpawnIcon", PlayerPanel)
				PlayerPanel.Icon:SetModel(v:GetModel())
				PlayerPanel.Icon:SetPos(3, 3)
				PlayerPanel.Icon:SetToolTip( nil )
			
				PlayerPanel.Title = vgui.Create("DLabel", PlayerPanel)
				PlayerPanel.Title:SetPos(90, 5)
				local dispName
				if v:SteamName() == v:Nick() then
					dispName = v:SteamName() 
				else
					dispName = v:Nick().." ("..v:SteamName()..")"
				end
				PlayerPanel.Title:SetText(dispName)
				PlayerPanel.Title:SetColor(team.GetColor(v:Team()))
				PlayerPanel.Title:SizeToContents() 
				PlayerPanel.Title:SetContentAlignment( 5 )
				
				local MemberOf
				MemberOf = v:GetNWString("community", "N/A")
				
				PlayerPanel.Community = vgui.Create("DLabel", PlayerPanel)
				PlayerPanel.Community:SetPos(90, 25)
				PlayerPanel.Community:SetText("Member of "..MemberOf)
				PlayerPanel.Community:SetColor(team.GetColor(v:Team()))
				PlayerPanel.Community:SizeToContents() 
				PlayerPanel.Community:SetContentAlignment( 5 )
				
				PlayerPanel.Title = vgui.Create("DLabel", PlayerPanel)
				PlayerPanel.Title:SetPos(90, 40)
				PlayerPanel.Title:SetText(v:GetNWString("ctitle", " "))
				PlayerPanel.Title:SetColor(team.GetColor(v:Team()))
				PlayerPanel.Title:SizeToContents() 
				PlayerPanel.Title:SetContentAlignment( 5 )
		
				PlayerPanel.Class = vgui.Create("DLabel", PlayerPanel)		
				PlayerPanel.Class:SetPos(90, 55)
				PlayerPanel.Class:SetText(team.GetName(v:Team()))
				PlayerPanel.Class:SetColor(team.GetColor(v:Team()))
				PlayerPanel.Class:SizeToContents() 
				PlayerPanel.Class:SetContentAlignment( 5 )	
				
				PlayerPanel.tradeToBtn = vgui.Create("DButton", PlayerPanel )
				PlayerPanel.tradeToBtn:SetPos(475, 5)
				PlayerPanel.tradeToBtn:SetSize(100,20)
				PlayerPanel.tradeToBtn:SetText( "Trade Resources" )
				PlayerPanel.tradeToBtn.DoClick = function() 
					openTradeToMenu(ply, v, "trade")
					trade_frame:Close() 
				end
			end
		end
		
		if counter < 1 then
			noPlayerName = vgui.Create("DLabel", trade_frame)
			noPlayerName:SetPos(80, 80)
			noPlayerName:SetText("No players within range.")
			noPlayerName:SetColor(Color(0,255,0,255))
			noPlayerName:SizeToContents() 
			noPlayerName:SetContentAlignment( 5 )
		end
end

function openTradeToMenu(ply, targetPly, option)
	local scrap = GetResource("Scrap")
	local smallparts = GetResource("Small_Parts")
	local chems = GetResource("Chemicals")
	
	local minRes = 0
	if option == "admin_trade" and ply:IsAdmin() then
		minRes = -2000
		scrap = 2000
		smallparts = 2000
		chems = 2000
	end
	
	local tradeTo_frame = vgui.Create( "DFrame" )
		tradeTo_frame:SetSize( 575, 265 ) --Set the size
		tradeTo_frame:SetPos(ScrW() / 2 - tradeTo_frame:GetWide() / 2, ScrH() / 2 - tradeTo_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
		tradeTo_frame:SetTitle( "Trade Menu" ) --Set title
		tradeTo_frame:SetVisible( true )
		tradeTo_frame:SetDraggable( true )
		tradeTo_frame:ShowCloseButton( true )
		tradeTo_frame:MakePopup()
		tradeTo_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", tradeTo_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_6b.png" )
			screenBG:SetSize(tradeTo_frame:GetWide(), tradeTo_frame:GetTall())
			
		toPlayerIcon = vgui.Create("SpawnIcon", tradeTo_frame)
			toPlayerIcon:SetModel(targetPly:GetModel())
			toPlayerIcon:SetPos(40, 40)
			toPlayerIcon:SetToolTip( nil )
			
		toPlayerName = vgui.Create("DLabel", tradeTo_frame)
			toPlayerName:SetPos(125, 40)
			toPlayerName:SetText(targetPly:Nick())
			toPlayerName:SetColor(Color(0,255,0,255))
			toPlayerName:SizeToContents() 
			toPlayerName:SetContentAlignment( 5 )
			
		toPlayerTradeAmountLBL = vgui.Create("DLabel", tradeTo_frame)
			toPlayerTradeAmountLBL:SetPos(40, 115)
			toPlayerTradeAmountLBL:SetText("Set Trade Amount")
			toPlayerTradeAmountLBL:SetColor(Color(0,255,0,255))
			toPlayerTradeAmountLBL:SizeToContents() 
			toPlayerTradeAmountLBL:SetContentAlignment( 5 )	
		
		giveScrapLBL = vgui.Create("DLabel", tradeTo_frame)
			giveScrapLBL:SetPos(50, 140)
			giveScrapLBL:SetText("Scrap")
			giveScrapLBL:SetColor(Color(0,255,0,255))
			giveScrapLBL:SizeToContents() 
			giveScrapLBL:SetContentAlignment( 5 )	
		giveScrap = vgui.Create( "DNumberWang", tradeTo_frame )
			giveScrap:SetPos( 125, 135 )
			giveScrap:SetMin( 0 )
			giveScrap:SetMax( scrap )
			giveScrap:SetDecimals( 0 )
			giveScrap:SetValue( 0 )	
			
		givePartsLBL = vgui.Create("DLabel", tradeTo_frame)
			givePartsLBL:SetPos(50, 170)
			givePartsLBL:SetText("Small Parts")
			givePartsLBL:SetColor(Color(0,255,0,255))
			givePartsLBL:SizeToContents() 
			givePartsLBL:SetContentAlignment( 5 )	
		giveParts = vgui.Create( "DNumberWang", tradeTo_frame )
			giveParts:SetPos( 125, 165 )
			giveParts:SetMin( 0 )
			giveParts:SetMax( smallparts )
			giveParts:SetDecimals( 0 )
			giveParts:SetValue( 0 )	
			
		giveChemsLBL = vgui.Create("DLabel", tradeTo_frame)
			giveChemsLBL:SetPos(50, 200)
			giveChemsLBL:SetText("Chemicals")
			giveChemsLBL:SetColor(Color(0,255,0,255))
			giveChemsLBL:SizeToContents() 
			giveChemsLBL:SetContentAlignment( 5 )	
		giveChems = vgui.Create( "DNumberWang", tradeTo_frame )
			giveChems:SetPos( 125, 195 )
			giveChems:SetMin( 0 )
			giveChems:SetMax( chems )
			giveChems:SetDecimals( 0 )
			giveChems:SetValue( 0 )	
		
		--//Player Info			
		local lMenuList = vgui.Create( "DPanelList", tradeTo_frame )
			lMenuList:SetPos( 375,30 )
			lMenuList:SetSize( 150, 175 )
			lMenuList:SetSpacing( 4 )
			lMenuList:SetPadding(3)
			lMenuList:EnableHorizontal( false ) 
			lMenuList:EnableVerticalScrollbar( true ) 
			
			if option == "admin_trade" then
				local plymenuLabel = vgui.Create("DLabel", tradeTo_frame)
					plymenuLabel:SetColor( Color( 0, 255, 0, 255 ) )
					plymenuLabel:SetText( "Admin Trade" )
					plymenuLabel:SetFont("Trebuchet24")
					plymenuLabel:SizeToContents()
					lMenuList:AddItem( plymenuLabel )
			else
				local plymenuLabel = vgui.Create("DLabel", tradeTo_frame)
					plymenuLabel:SetColor( Color( 0, 255, 0, 255 ) )
					plymenuLabel:SetText( "Trade Menu" )
					plymenuLabel:SetFont("Trebuchet24")
					plymenuLabel:SizeToContents()
					lMenuList:AddItem( plymenuLabel )

				local NameLabel = vgui.Create("DLabel")
					NameLabel:SetColor( Color( 0, 255, 0, 255 ) )
					NameLabel:SetText( " Player Resources" )
					NameLabel:SizeToContents()
					lMenuList:AddItem( NameLabel )
				local LDevide = vgui.Create("DShape") 
					LDevide:SetParent( lMenuList ) 
					LDevide:SetType("Rect")
					LDevide:SetSize( 100, 2 ) 	
					lMenuList:AddItem( LDevide )	
				local ScrapLabel = vgui.Create("DLabel")
					ScrapLabel:SetColor( Color( 0, 255, 0, 255 ) )
					ScrapLabel:SetText( " Scrap: "..tostring(scrap) )
					ScrapLabel:SizeToContents()
					lMenuList:AddItem( ScrapLabel )
				local SPLabel = vgui.Create("DLabel")
					SPLabel:SetColor( Color( 0, 255, 0, 255 ) )
					SPLabel:SetText( " Small Parts: "..tostring(smallparts) )
					SPLabel:SizeToContents()
					lMenuList:AddItem( SPLabel )
				local ChemsLabel = vgui.Create("DLabel")
					ChemsLabel:SetColor( Color( 0, 255, 0, 255 ) )
					ChemsLabel:SetText( " Chemicals: "..tostring(chems) )
					ChemsLabel:SizeToContents()
					lMenuList:AddItem( ChemsLabel )
			end
			--//Vendor Owner Menu Menu	
			local btnHPos = 160
			local btnWPos = tradeTo_frame:GetWide()-210
			local btnHeight = 40
			local lblColor = Color( 245, 218, 210, 180 )
					
			local tradeBtn = vgui.Create("DImageButton", tradeTo_frame)
				tradeBtn:SetPos( btnWPos,btnHPos )
				tradeBtn:SetSize(30,30)
				tradeBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				tradeBtn.DoClick = function() 	
					local scrapAmount = giveScrap:GetValue()
					local partsAmount = giveParts:GetValue()
					local chemsAmount = giveChems:GetValue()
					
					if option ~= "admin_trade" then
						if tonumber(scrapAmount) < 0 then
							scrapAmount = 0
						elseif tonumber(scrapAmount) > scrap then
							scrapAmount = scrap
						end
						if tonumber(partsAmount) < 0 then
							partsAmount = 0
						elseif tonumber(partsAmount) > smallparts then
							partsAmount = smallparts
						end
						if tonumber(chemsAmount) < 0 then
							chemsAmount = 0
						elseif tonumber(chemsAmount) > chems then
							chemsAmount = chems
						end
					end
					
					net.Start("tradeResTo")
						net.WriteEntity(ply)
						net.WriteEntity(targetPly)
						net.WriteDouble(scrapAmount)
						net.WriteDouble(partsAmount)
						net.WriteDouble(chemsAmount)
						net.WriteString(option)
					net.SendToServer()
					tradeTo_frame:Close() 
				end
				tradeBtn.Paint = function()
					if tradeBtn:IsDown() then 
						tradeBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						tradeBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end	
			local tradeBtnLbl = vgui.Create("DLabel", tradeTo_frame)
				tradeBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				tradeBtnLbl:SetColor( lblColor )
				tradeBtnLbl:SetText( "Trade" )
				tradeBtnLbl:SetFont("Trebuchet24")
				tradeBtnLbl:SizeToContents()
			
			btnHPos = btnHPos + btnHeight			
			local cancelBtn = vgui.Create("DImageButton", tradeTo_frame)
				cancelBtn:SetPos( btnWPos,btnHPos )
				cancelBtn:SetSize(30,30)
				cancelBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				cancelBtn.DoClick = function() 
					tradeTo_frame:Close()
				end
				cancelBtn.Paint = function()
					if cancelBtn:IsDown() then 
						cancelBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						cancelBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end	
			local cancelBtnLbl = vgui.Create("DLabel", tradeTo_frame)
				cancelBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				cancelBtnLbl:SetColor( lblColor )
				cancelBtnLbl:SetText( "Cancel" )
				cancelBtnLbl:SetFont("Trebuchet24")
				cancelBtnLbl:SizeToContents()	
end
concommand.Add( "pnrp_trade_window", open_trade )

local admin_trade_frame

function open_admin_trade(ply)
	if ply:IsAdmin() then	
			admin_trade_frame = vgui.Create( "DFrame" )
		admin_trade_frame:SetSize( 710, 510 ) --Set the size
		admin_trade_frame:SetPos(ScrW() / 2 - admin_trade_frame:GetWide() / 2, ScrH() / 2 - admin_trade_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
		admin_trade_frame:SetTitle( "Trade Menu" ) --Set title
		admin_trade_frame:SetVisible( true )
		admin_trade_frame:SetDraggable( true )
		admin_trade_frame:ShowCloseButton( true )
		admin_trade_frame:MakePopup()
		admin_trade_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", admin_trade_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_2b.png" )
			screenBG:SetSize(admin_trade_frame:GetWide(), admin_trade_frame:GetTall())
		
		local plymenuLabel = vgui.Create("DLabel", admin_trade_frame)
			plymenuLabel:SetPos(50, 40)
			plymenuLabel:SetColor( Color( 0, 255, 0, 255 ) )
			plymenuLabel:SetText( "Admin Trade" )
			plymenuLabel:SetFont("Trebuchet24")
			plymenuLabel:SizeToContents()
		
		local PlayerList = vgui.Create("DPanelList", admin_trade_frame)
			PlayerList:SetPos(40, 60)
			PlayerList:SetSize(admin_trade_frame:GetWide() - 85, admin_trade_frame:GetTall() - 105)
			PlayerList:EnableVerticalScrollbar(true) 
			PlayerList:EnableHorizontal(false) 
			PlayerList:SetSpacing(1)
			PlayerList:SetPadding(10)
			PlayerList.Paint = function()
			--	draw.RoundedBox( 8, 0, 0, PlayerList:GetWide(), PlayerList:GetTall(), Color( 50, 50, 50, 255 ) )
			end
		
		local listPlayers = player.GetAll()
		local counter = 0
		for _, v in pairs(listPlayers) do
			if v:GetClass()=="player" then
				
				counter = counter + 1
				
				local PlayerPanel = vgui.Create("DPanel")
				PlayerPanel:SetTall(75)
				PlayerPanel.Paint = function()
				
					draw.RoundedBox( 6, 0, 0, PlayerPanel:GetWide(), PlayerPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
			
				end
				
				PlayerList:AddItem(PlayerPanel)
		
				PlayerPanel.Icon = vgui.Create("SpawnIcon", PlayerPanel)
				PlayerPanel.Icon:SetModel(v:GetModel())
				PlayerPanel.Icon:SetPos(3, 3)
				PlayerPanel.Icon:SetToolTip( nil )
			
				PlayerPanel.Title = vgui.Create("DLabel", PlayerPanel)
				PlayerPanel.Title:SetPos(90, 5)
				local dispName
				if v:SteamName() == v:Nick() then
					dispName = v:SteamName() 
				else
					dispName = v:Nick().." ("..v:SteamName()..")"
				end
				PlayerPanel.Title:SetText(dispName)
				PlayerPanel.Title:SetColor(team.GetColor(v:Team()))
				PlayerPanel.Title:SizeToContents() 
				PlayerPanel.Title:SetContentAlignment( 5 )
				
				local MemberOf
				MemberOf = v:GetNWString("community", "N/A")
				
				PlayerPanel.Community = vgui.Create("DLabel", PlayerPanel)
				PlayerPanel.Community:SetPos(90, 25)
				PlayerPanel.Community:SetText("Member of "..MemberOf)
				PlayerPanel.Community:SetColor(team.GetColor(v:Team()))
				PlayerPanel.Community:SizeToContents() 
				PlayerPanel.Community:SetContentAlignment( 5 )
				
				PlayerPanel.Title = vgui.Create("DLabel", PlayerPanel)
				PlayerPanel.Title:SetPos(90, 40)
				PlayerPanel.Title:SetText(v:GetNWString("ctitle", " "))
				PlayerPanel.Title:SetColor(team.GetColor(v:Team()))
				PlayerPanel.Title:SizeToContents() 
				PlayerPanel.Title:SetContentAlignment( 5 )
		
				PlayerPanel.Class = vgui.Create("DLabel", PlayerPanel)		
				PlayerPanel.Class:SetPos(90, 55)
				PlayerPanel.Class:SetText(team.GetName(v:Team()))
				PlayerPanel.Class:SetColor(team.GetColor(v:Team()))
				PlayerPanel.Class:SizeToContents() 
				PlayerPanel.Class:SetContentAlignment( 5 )	
				
				PlayerPanel.tradeToBtn = vgui.Create("DButton", PlayerPanel )
				PlayerPanel.tradeToBtn:SetPos(475, 5)
				PlayerPanel.tradeToBtn:SetSize(100,20)
				PlayerPanel.tradeToBtn:SetText( "Trade Resources" )
				PlayerPanel.tradeToBtn.DoClick = function() 
					openTradeToMenu(ply, v, "admin_trade")
					admin_trade_frame:Close() 
				end
			end
		end
		
		if counter < 1 then
			noPlayerName = vgui.Create("DLabel", admin_trade_frame)
			noPlayerName:SetPos(80, 80)
			noPlayerName:SetText("No players within range.")
			noPlayerName:SetColor(Color(0,255,0,255))
			noPlayerName:SizeToContents() 
			noPlayerName:SetContentAlignment( 5 )
		end
	else
		ply:ChatPrint("Admin access only")
	end
end
concommand.Add( "pnrp_admin_trade_window", open_admin_trade )

--EOF