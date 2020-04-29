include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
end

function HopperMenu( )
	local ply = LocalPlayer()
	local hopperEnt = net:ReadEntity()
	local inv = net:ReadTable()
	local w = 575
	local h = 240
	
	local hop_frame = vgui.Create("DFrame")
		--smelt_frame:SetPos( (ScrW()/2) - (w / 2), (ScrH()/2) - (h / 2))
		hop_frame:SetSize( w, h )
		hop_frame:SetTitle( "" )
		hop_frame:SetVisible( true )
		hop_frame:SetDraggable( true )
		hop_frame:ShowCloseButton( true )
		hop_frame:Center()
		hop_frame:MakePopup()
		hop_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
	
		local screenBG = vgui.Create("DImage", hop_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_6b.png" )
			screenBG:SetKeepAspect()
			screenBG:SizeToContents()
			screenBG:SetSize(hop_frame:GetWide(), hop_frame:GetTall())
		
		
		local pnlList = vgui.Create("DPanelList", hop_frame)
			pnlList:SetPos(20, 30)
			pnlList:SetSize(hop_frame:GetWide() - 260, hop_frame:GetTall() - 50)
			pnlList:EnableVerticalScrollbar(true) 
			pnlList:EnableHorizontal(false) 
			pnlList:SetSpacing(1)
			pnlList:SetPadding(10)
			pnlList.Paint = function()
			--	draw.RoundedBox( 8, 0, 0, pnlList:GetWide(), pnlList:GetTall(), Color( 50, 50, 50, 255 ) )
			end	
			
			local spwnIcnSize = 30
			local model = ""
			local name = ""
			for itemID, val in pairs(inv) do
				if val > 0 then
					local pnlPanel = vgui.Create("DPanel")
						pnlPanel:SetTall(40)
						pnlPanel.Paint = function()
						
							draw.RoundedBox( 3, 0, 0, pnlPanel:GetWide(), pnlPanel:GetTall(), Color( 180, 180, 180, 30 ) )		
					
						end
					if itemID == "msc_scrapnug" then
						
						model = "models/gibs/scanner_gib02.mdl"
						name = "Scrap"
						HopperItemPnl(hop_frame, pnlPanel, pnlList, itemID, model, name, val, hopperEnt)
						
					elseif itemID == "msc_smallnug" then
						
						model = "models/props_wasteland/gear02.mdl"
						name = "Small Parts"
						HopperItemPnl(hop_frame, pnlPanel, pnlList, itemID, model, name, val, hopperEnt)
						
					elseif itemID == "msc_chemnug" then
						
						model = "models/grub_nugget_medium.mdl"
						name = "Chemicals"
						HopperItemPnl(hop_frame, pnlPanel, pnlList, itemID, model, name, val, hopperEnt)
						
					else 
						local Item = PNRP.Items[itemID]
						if Item then
							
							model = Item.Model
							name = Item.Name
							HopperItemPnl(hop_frame, pnlPanel, pnlList, itemID, model, name, val, hopperEnt)
							
						end
					end
				end
			end
		
		--//Status Screen			
		local genIcon = vgui.Create("SpawnIcon", hop_frame)
			genIcon:SetModel(hopperEnt:GetModel())
			genIcon:SetPos(360,25)
			
		local NameLabel = vgui.Create("DLabel", hop_frame)
			NameLabel:SetColor( Color( 255, 255, 255, 255 ) )
			NameLabel:SetText( "Resource/Item Hopper" )
			NameLabel:SetPos( 420,35 )
			NameLabel:SizeToContents()
			
		local WarningTxt = vgui.Create("DLabel", hop_frame)
			WarningTxt:SetColor( Color( 255, 255, 255, 255 ) )
			WarningTxt:SetText( "Warning: Stored items are \nnot saved." )
			WarningTxt:SetPos( 375,85 )
			WarningTxt:SizeToContents()

				
		--//Menu Menu	
		local btnHPos = 150
		local btnWPos = hop_frame:GetWide()-220
		local btnHeight = 40
		local lblColor = Color( 245, 218, 210, 180 )
	
		local TakeAllBtn = vgui.Create("DImageButton", hop_frame)
			TakeAllBtn:SetPos( btnWPos,btnHPos )
			TakeAllBtn:SetSize(30,30)
			TakeAllBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			TakeAllBtn.DoClick = function() 
				net.Start("takeall_hopper")
					net.WriteEntity(ply)
					net.WriteEntity(hopperEnt)
				net.SendToServer()
				hop_frame:Close() 
			end
			TakeAllBtn.Paint = function()
				if TakeAllBtn:IsDown() then 
					TakeAllBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					TakeAllBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end

			local TakeAllBtnLbl = vgui.Create("DLabel", hop_frame)
				TakeAllBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				TakeAllBtnLbl:SetColor( lblColor )
				TakeAllBtnLbl:SetText( "Take All Resource" )
				TakeAllBtnLbl:SetFont("Trebuchet24")
				TakeAllBtnLbl:SizeToContents()
				
		btnHPos = btnHPos + btnHeight
		local DropAllBtn = vgui.Create("DImageButton", hop_frame)
			DropAllBtn:SetPos( btnWPos,btnHPos )
			DropAllBtn:SetSize(30,30)
			DropAllBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			DropAllBtn.DoClick = function() 
				net.Start("dropall_hopper")
					net.WriteEntity(ply)
					net.WriteEntity(hopperEnt)
				net.SendToServer()
				hop_frame:Close() 
			end
			DropAllBtn.Paint = function()
				if DropAllBtn:IsDown() then 
					DropAllBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					DropAllBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end

			local DropAllBtnLbl = vgui.Create("DLabel", hop_frame)
				DropAllBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				DropAllBtnLbl:SetColor( lblColor )
				DropAllBtnLbl:SetText( "Drop All Items" )
				DropAllBtnLbl:SetFont("Trebuchet24")
				DropAllBtnLbl:SizeToContents()
end
net.Receive("hopper_menu", HopperMenu)

function HopperItemPnl(parent_frame, pnlPanel, pnlList, itemID, model, name, count, hopperEnt)
	local ply = LocalPlayer()
	
	pnlList:AddItem(pnlPanel)
	pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
	pnlPanel.Icon:SetModel(model)
	pnlPanel.Icon:SetPos(5, 5)
	pnlPanel.Icon:SetSize( 30, 30 )
	pnlPanel.Icon:SetToolTip( nil )
	pnlPanel.Icon.DoClick = function()
	
	end
	
	pnlPanel.Title = vgui.Create("DLabel", pnlPanel)
	pnlPanel.Title:SetPos(45, 8)
	pnlPanel.Title:SetText(name)
	pnlPanel.Title:SetColor(Color( 0, 0, 0, 255 ))
	pnlPanel.Title:SizeToContents() 
	pnlPanel.Title:SetContentAlignment( 5 )
	
	pnlPanel.Count = vgui.Create("DLabel", pnlPanel)		
	pnlPanel.Count:SetPos(45, 25)
	pnlPanel.Count:SetText("Count: "..tostring(count))
	pnlPanel.Count:SetColor(Color( 0, 0, 0, 255 ))
	pnlPanel.Count:SizeToContents() 
	pnlPanel.Count:SetContentAlignment( 5 )
	
	local textColor = Color(200,200,200,255)
	
	pnlPanel.bulkSlider = vgui.Create( "DNumSlider", pnlPanel )
	pnlPanel.bulkSlider:SetPos(130, -5) 
	pnlPanel.bulkSlider:SetWide( 175 )
	pnlPanel.bulkSlider:SetText( "" )
	pnlPanel.bulkSlider:SetMin( 1 )
	pnlPanel.bulkSlider:SetMax( count )
	pnlPanel.bulkSlider:SetDecimals( 0 )
	pnlPanel.bulkSlider:SetValue( 1 )
	pnlPanel.bulkSlider.Label:SizeToContents()
	
	local Item = PNRP.Items[itemID]local Item = PNRP.Items[itemID]
	if Item then
		BtnW = 75
		pnlPanel.BulkDropBtn = vgui.Create("DButton", pnlPanel )
		pnlPanel.BulkDropBtn:SetPos(130, 23)
		pnlPanel.BulkDropBtn:SetSize(150,15)
		pnlPanel.BulkDropBtn:SetText( "Drop Item" )
		pnlPanel.BulkDropBtn.DoClick = function() 
			net.Start("dropitem_hopper")
				net.WriteEntity(ply)
				net.WriteEntity(hopperEnt)
				net.WriteString(itemID)
				net.WriteDouble(math.Round(tonumber(pnlPanel.bulkSlider:GetValue())))
			net.SendToServer()
			parent_frame:Close()
		end
	else
		pnlPanel.BulkTakeBtn = vgui.Create("DButton", pnlPanel )
		pnlPanel.BulkTakeBtn:SetPos(130, 23)
		pnlPanel.BulkTakeBtn:SetSize(150,15)
		pnlPanel.BulkTakeBtn:SetText( "Take Resource" )
		pnlPanel.BulkTakeBtn.DoClick = function() 
			net.Start("takeres_hopper")
				net.WriteEntity(ply)
				net.WriteEntity(hopperEnt)
				net.WriteString(itemID)
				net.WriteDouble(math.Round(tonumber(pnlPanel.bulkSlider:GetValue())))
			net.SendToServer()
			parent_frame:Close()
		end
	end
	
	
end

