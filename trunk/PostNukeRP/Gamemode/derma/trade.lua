
local trade_frame

function open_trade(ply)

	local scrap = GetResource("Scrap")
	local smallparts = GetResource("Small_Parts")
	local chems = GetResource("Chemicals")
	
	local scAmount
	local spAmount
	local chemAmount
	
	trade_frame = vgui.Create( "DFrame" )
			trade_frame:SetSize( 375, 250 ) --Set the size
			trade_frame:SetPos(ScrW() / 2 - trade_frame:GetWide() / 2, ScrH() / 2 - trade_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
			trade_frame:SetTitle( "Trade Menu" ) --Set title
			trade_frame:SetVisible( true )
			trade_frame:SetDraggable( true )
			trade_frame:ShowCloseButton( true )
			trade_frame:MakePopup()

	local TradeComboBox = vgui.Create( "DComboBox", trade_frame )
		TradeComboBox:SetPos( 10, 35 )
		TradeComboBox:SetSize( 125, 200 )
		TradeComboBox:SetMultiple( false ) -- <removed sarcastic and useless comment>

		for k,v in pairs(ents.FindInSphere( ply:GetPos(), 500 )) do
			if v:GetClass()=="player" then
				if v:GetName() != ply:Nick() then
					TradeComboBox:AddItem( v:GetName())
				end
			end

		end
		
		local giveScrapSlide = vgui.Create( "DNumSlider", trade_frame )
				    giveScrapSlide:SetSize( 200, 50 ) -- Keep the second number at 50
				    giveScrapSlide:SetPos( 150, 50 )
				    giveScrapSlide:SetText( "Scrap" )
				    giveScrapSlide:SetMin( 0 )
				    giveScrapSlide:SetMax( scrap )
				    giveScrapSlide:SetDecimals( 0 )

		local givePartsSlide = vgui.Create( "DNumSlider", trade_frame )
				    givePartsSlide:SetSize( 200, 50 ) -- Keep the second number at 50
				    givePartsSlide:SetPos( 150, 100 )
				    givePartsSlide:SetText( "Small Parts" )
				    givePartsSlide:SetMin( 0 )
				    givePartsSlide:SetMax( smallparts )
				    givePartsSlide:SetDecimals( 0 )

		local giveChemsSlide = vgui.Create( "DNumSlider", trade_frame )
				    giveChemsSlide:SetSize( 200, 50 ) -- Keep the second number at 50
				    giveChemsSlide:SetPos( 150, 150 )
				    giveChemsSlide:SetText( "Chemicals" )
				    giveChemsSlide:SetMin( 0 )
				    giveChemsSlide:SetMax( chems )
				    giveChemsSlide:SetDecimals( 0 )

		local tradeBTN = vgui.Create("DButton", trade_frame )
				    tradeBTN:SetText( "Trade" )
				    tradeBTN:SetPos( 150, 215 )
				    tradeBTN.DoClick = function()
					    if TradeComboBox:GetSelectedItems() and TradeComboBox:GetSelectedItems()[1] then 
	        				local tradeTO = TradeComboBox:GetSelectedItems()[1]:GetValue()
					    
					    	RunConsoleCommand( "pnrp_give_res", "Scrap", giveScrapSlide:GetValue(), tradeTO )
					    	RunConsoleCommand( "pnrp_give_res", "Small_Parts", givePartsSlide:GetValue(), tradeTO )
					    	RunConsoleCommand( "pnrp_give_res", "Chemicals", giveChemsSlide:GetValue(), tradeTO )

							trade_frame:Close()
					    end
				    end	    
				   
end

concommand.Add( "pnrp_trade_window", open_trade )

--EOF