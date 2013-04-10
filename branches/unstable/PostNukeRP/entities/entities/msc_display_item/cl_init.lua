include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

function DispItemViewCheck()
	local myPlayer = LocalPlayer()
	
	local tracedata = {}
	tracedata.start = myPlayer:GetShootPos()
	tracedata.endpos = tracedata.start + (myPlayer:GetAimVector() * 200)
	tracedata.filter = myPlayer
	local trace = util.TraceLine(tracedata)
	local ent = trace.Entity
	if !ent:IsValid() then return end
	
	if ent:GetClass() == "msc_display_item" then
		local itemID = ent:GetNWString("itemID")
		local item = PNRP.Items[itemID]
		local open = ent:GetNWString("open")
		local text = item.Name
		local txtSize
		local cost = ent:GetNWString("cost", "0,0,0,0")
		
		surface.SetFont("CenterPrintText")
		
		if open != "true" then
			text = "Packed "..text.." Display"
		else
			local stringSplit = string.Explode(",", cost)
			local scrap = "Scrap: "..stringSplit[2]
			local sp = "Small Parts: "..stringSplit[3]
			local chems = "Chems: "..stringSplit[4]
			text = text.."\n "..scrap.."\n "..sp.."\n "..chems
		end
		local font = "CenterPrintText"
		local tWidth, tHeight = surface.GetTextSize(text)
		tWidth = tWidth + 15
		tHeight = tHeight + 5
		local x = (ScrW() / 2) - (8 + (tWidth / 2))
		local y = (ScrH() / 2) - (16 + tHeight)
	
		surface.SetDrawColor( 62, 62, 80, 150 )
		surface.DrawRect( x, y, tWidth, tHeight )

		surface.SetDrawColor( 30, 30, 30, 255 )
		surface.DrawOutlinedRect( x, y, tWidth, tHeight )
		
		draw.DrawText( text, font, x+5, y + 2, Color(255,255,255,200), TEXT_ALIGN_LEFT )
	end
end
hook.Add( "HUDPaint", "DispItemViewCheck", DispItemViewCheck )

function dispBuyVerify()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	local item = PNRP.Items[net.ReadString()]
	local costString = net.ReadString()
	local infoTable = string.Explode( ",", costString )
	
	local disVerifyFrame = vgui.Create( "DFrame" )
		disVerifyFrame:SetTitle( item.Name )
		disVerifyFrame:SetVisible( true )
		disVerifyFrame:SetDraggable( true )
		disVerifyFrame:ShowCloseButton( false )
		disVerifyFrame:MakePopup()
		
		local entIcon = vgui.Create( "SpawnIcon" , disVerifyFrame ) -- SpawnIcon
			entIcon:SetPos( 5,30 )
			entIcon:SetModel( item.Model )
		local questionTxt = vgui.Create( "DLabel", disVerifyFrame )
			questionTxt:SetPos( 80, 30 )
			questionTxt:SetText( "Do you want to buy "..item.Name.."?" )
			questionTxt:SizeToContents()
		
		local width = entIcon:GetWide() + questionTxt:GetWide() + 40
		if width < 260 then width = 260 end
		
		disVerifyFrame:SetSize( width, 100 )
		disVerifyFrame:SetPos( ScrW() / 2 - disVerifyFrame:GetWide() / 2, ScrH() / 2 - disVerifyFrame:GetTall() / 2  )
		
		local amountTxt = vgui.Create( "DLabel", disVerifyFrame )
			amountTxt:SetPos( 80, 52 )
			amountTxt:SetText( "Amount to buy:" )
			amountTxt:SizeToContents()
		
		local AmountWang = vgui.Create( "DNumberWang", disVerifyFrame )
			AmountWang:SetPos( 160, 50 )
			AmountWang:SetMin( 1 )
			AmountWang:SetMax( infoTable[1] )
			AmountWang:SetDecimals( 0 )
			AmountWang:SetValue( 1 )
			
		local yesBTN = vgui.Create( "DButton", disVerifyFrame )
			yesBTN:SetPos( 80, 75 )
			yesBTN:SetText( "Yes" )
			yesBTN:SetSize( 75, 20 )
			yesBTN.DoClick = function()
				net.Start("BuyFromVendorDisp")
					net.WriteEntity(ply)
					net.WriteEntity(ent)
					net.WriteString(item.ID)
					net.WriteString(tostring(AmountWang:GetValue()))
				net.SendToServer()
				disVerifyFrame:Close()
			end
		local noBTN = vgui.Create( "DButton", disVerifyFrame )
			noBTN:SetPos( 175, 75 )
			noBTN:SetText( "No" )
			noBTN:SetSize( 75, 20 )
			noBTN.DoClick = function()
				disVerifyFrame:Close()
			end
end
net.Receive("dispBuyVerify", dispBuyVerify)
