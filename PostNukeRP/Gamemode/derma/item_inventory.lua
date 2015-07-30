
local itemIncentory_frame
local itemIncentory_body
function PNRP.ItemStorageWindow()
	local ply = LocalPlayer()
	
	local itemID = net.ReadString()
	local inventory_table = net.ReadTable()
	local plyInventoryTble = net.ReadTable()
	local PlayerInvWeight = net.ReadString()
	local CurInvWeight = net.ReadString()
	local weightCap = net.ReadString()
	local capacity = net.ReadString()
	local sid = net.ReadString()
	local origin_iid = net.ReadString()
	
	if not itemIncentory_frame or tostring(itemIncentory_frame) == "[NULL Panel]" then
		itemIncentory_frame = PNRP.PNRP_Frame()
		if not itemIncentory_frame then return end
		
		local w = 810
		local h = 520
		
		itemIncentory_frame:SetSize( w, h ) 
			itemIncentory_frame:SetPos( ScrW() / 2 - itemIncentory_frame:GetWide() / 2, ScrH() / 2 - itemIncentory_frame:GetTall() / 2 )
			itemIncentory_frame:SetTitle( "" )
			itemIncentory_frame:SetVisible( true )
			itemIncentory_frame:SetDraggable( false )
			itemIncentory_frame:ShowCloseButton( true )
			itemIncentory_frame:MakePopup()
			itemIncentory_frame.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
			
			local screenBG = vgui.Create("DImage", itemIncentory_frame)
				screenBG:SetImage( "VGUI/gfx/pnrp_screen_5b.png" )
				screenBG:SetKeepAspect()
				screenBG:SizeToContents()
				screenBG:SetSize(itemIncentory_frame:GetWide(), itemIncentory_frame:GetTall())
				
			local Item = PNRP.Items[itemID]
			local icon
			if Item.EntName then
				icon = vgui.Create( "ContentIcon", itemIncentory_frame )
				icon:SetSize( 125, 125 )
				icon:SetMaterial( "entities/"..Item.EntName..".png" )
				icon:SetName( Item.Name )
				icon:SetToolTip( nil )
				icon.DoClick = function() end
			else
				local skin = 0
				if Item.HullSkin then skin = Item.HullSkin end
				icon = vgui.Create( "SpawnIcon", itemIncentory_frame )
				icon:SetSize( 125, 125 )
				icon:SetModel( Item.Model, skin )
				icon:SetToolTip( nil )
				icon.DoClick = function() end
			end
			icon:SetPos(itemIncentory_frame:GetWide() - 185, 50)
			
	end
	
	buildInvStoragePanels(itemID, inventory_table,plyInventoryTble,PlayerInvWeight,CurInvWeight,weightCap,capacity,sid,origin_iid)	
	
		local btnHPos = 240
		local btnWPos = 160
		local btnHeight = 80
		local lblColor = Color( 245, 218, 210, 180 )
			
		if PNRP.Items[itemID].CanRepair then
			local tr = ply:TraceFromEyes(200)
			local ent = tr.Entity
			
			if ent then
				local hpLabel = vgui.Create("DLabel", itemIncentory_frame)
					hpLabel:SetPos(itemIncentory_frame:GetWide()-155,175)
					hpLabel:SetColor( Color( 0, 255, 0, 255 ) )
					hpLabel:SetText( "HP: "..ent:Health().." / "..PNRP.Items[itemID].HP )
					hpLabel:SizeToContents()
				
				local repairBtn = vgui.Create("DImageButton", itemIncentory_frame)
					repairBtn:SetPos( itemIncentory_frame:GetWide()-btnWPos-50,btnHPos )
					repairBtn:SetSize(30,30)
					repairBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					repairBtn.DoClick = function() 
						net.Start("PNRP_DoRepairItem")
							net.WriteEntity(ent)
						net.SendToServer()
						itemIncentory_frame:Close()
					end
					repairBtn.Paint = function()
						if repairBtn:IsDown() then 
							repairBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						else
							repairBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
						end
					end	
				local repairBtnLbl = vgui.Create("DLabel", itemIncentory_frame)
					repairBtnLbl:SetPos( itemIncentory_frame:GetWide()-btnWPos,btnHPos+2 )
					repairBtnLbl:SetColor( lblColor )
					repairBtnLbl:SetText( "Repair" )
					repairBtnLbl:SetFont("Trebuchet24")
					repairBtnLbl:SizeToContents()
			end
		end
end
net.Receive("pnrp_OpenItemStorageWindow", PNRP.ItemStorageWindow)

function buildInvStoragePanels(itemID, inventory_table,plyInventoryTble,PlayerInvWeight,CurInvWeight,weightCap,capacity,sid,origin_iid)
		
		if not itemIncentory_frame then return end
		if itemIncentory_body then itemIncentory_body:Remove() end
		
		local stoItem = PNRP.Items[itemID]
		
		itemIncentory_body = vgui.Create( "DPanel", itemIncentory_frame )
			itemIncentory_body:SetPos( 0, 0 ) -- Set the position of the panel
			itemIncentory_body:SetSize( itemIncentory_frame:GetWide()-50, itemIncentory_frame:GetTall())
			itemIncentory_body.Paint = function() end
		
		local invWeightText = "Weight: "..tostring(CurInvWeight).."/"..tostring(capacity).."\n"
		local yourWeightText = "Weight:"..tostring(PlayerInvWeight).."/"..tostring(weightCap)
		local invWeightColor = Color( 0, 255, 0, 255 )
		local yourWeightColor = Color( 0, 255, 0, 255 )
		
		if tonumber(CurInvWeight) >= tonumber(capacity) then
			invWeightColor = Color( 255, 0, 0, 255 )
		end
		if tonumber(PlayerInvWeight) >= tonumber(weightCap) then
			yourWeightColor = Color( 255, 0, 0, 255 )
		end
					
		local paneWidth = 255
		
		--//Storage Inventory
		local StorageInvLabel = vgui.Create( "DLabel", itemIncentory_body )
			StorageInvLabel:SetText(tostring(stoItem.Name).." Inventory")
			StorageInvLabel:SetPos(35, 40)
			StorageInvLabel:SetColor( Color( 0, 255, 0, 255 ) )
			StorageInvLabel:SizeToContents()
		local InvWeight = vgui.Create("DLabel", itemIncentory_body)
			InvWeight:SetPos(190, 40 )
			InvWeight:SetText(invWeightText)
			InvWeight:SetColor(invWeightColor)
			InvWeight:SizeToContents()
		local pnlLIList = vgui.Create("DPanelList", itemIncentory_body)
			pnlLIList:SetPos(30, 55)
			pnlLIList:SetSize(paneWidth, itemIncentory_body:GetTall() - 111)
			pnlLIList:EnableVerticalScrollbar(true) 
			pnlLIList:EnableHorizontal(false) 
			pnlLIList:SetSpacing(1)
			pnlLIList:SetPadding(5)
			
		--Generates the Storage's inventory
		if inventory_table == nil then
			local EmptyLabel = vgui.Create( "DLabel" )
				EmptyLabel:SetText("Storage Inventory is Empty")
				EmptyLabel:SetColor( Color( 0, 255, 0, 255 ) )
				EmptyLabel:SizeToContents()
				
				pnlLIList:AddItem(EmptyLabel)
		else
			for k, v in pairs( inventory_table ) do
				local item = PNRP.Items[v["itemid"]]
				if item then
					local pnlPanel = vgui.Create("DPanel")
						pnlPanel:SetTall(75)
						pnlPanel.Paint = function()
							draw.RoundedBox( 1, 0, 0, pnlPanel:GetWide(), 1, Color( 0, 255, 0, 80 ) )
							draw.RoundedBox( 1, 0, pnlPanel:GetTall()-1, pnlPanel:GetWide(), 1, Color( 0, 255, 0, 80 ) )
						end
						pnlLIList:AddItem(pnlPanel)
						
						local model = item.Model
						local skin = 0
						local Info = item.Info
						local countTxt = "Count: "..tostring(v["count"])
						if v["status_table"] != "" then
							countTxt = ""
							local HP = PNRP.GetFromStat(v["status_table"], "HP")
							if HP then 	countTxt = "HP: "..HP end
							local PowerLevel = PNRP.GetFromStat(v["status_table"], "PowerLevel")
							if PowerLevel then 	countTxt = countTxt.." Charge: "..tostring(math.Round(PowerLevel/100)).."% " end
							local FuelLevel = PNRP.GetFromStat(v["status_table"], "FuelLevel")
							if FuelLevel then countTxt = countTxt.." Fuel: "..tostring(FuelLevel) end
							local GasLevel = PNRP.GetFromStat(v["status_table"], "Gas")
							if GasLevel then countTxt = countTxt.." Gas: "..tostring(math.Round(100-((item.Tank-GasLevel)/item.Tank)*100)).."% " end
							
							local newModel = PNRP.GetFromStat(v["status_table"], "Model")
							local newSkin = PNRP.GetFromStat(v["status_table"], "Skin")
							if newModel then model = newModel end
							if newSkin then skin = tonumber(newSkin) end
						end
													
						pnlPanel.Title = vgui.Create("DLabel", pnlPanel)
						pnlPanel.Title:SetPos(70, 5)
						pnlPanel.Title:SetText(item.Name)
						pnlPanel.Title:SetColor(Color( 0, 255, 0, 255 ))
						pnlPanel.Title:SizeToContents() 
						pnlPanel.Title:SetContentAlignment( 5 )
						
						local weightTXT = "Weight: "..item.Weight
						if item.Capacity then
							weightTXT = weightTXT.." | Capacity: "..item.Capacity
						end
						pnlPanel.ItemWeight = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.ItemWeight:SetPos(70, 55)
						pnlPanel.ItemWeight:SetText(weightTXT)
						pnlPanel.ItemWeight:SetColor(Color( 0, 200, 0, 255 ))
						pnlPanel.ItemWeight:SizeToContents() 
						pnlPanel.ItemWeight:SetContentAlignment( 5 )
						
						pnlPanel.Count = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.Count:SetPos(70, 40)
						pnlPanel.Count:SetText(countTxt)
						pnlPanel.Count:SetColor(Color( 0, 255, 0, 255 ))
						pnlPanel.Count:SizeToContents() 
						pnlPanel.Count:SetContentAlignment( 5 )
						
						pnlPanel.bulkSlider = vgui.Create( "DNumSlider", pnlPanel )
						pnlPanel.bulkSlider:SetPos(5, 15) 
						pnlPanel.bulkSlider:SetWide( 240 )
						pnlPanel.bulkSlider:SetText( "" )
						pnlPanel.bulkSlider:SetMin( 1 )
						pnlPanel.bulkSlider:SetMax( v["count"] )
						pnlPanel.bulkSlider:SetDecimals( 0 )
						pnlPanel.bulkSlider:SetValue( 1 )
						pnlPanel.bulkSlider:Hide()
						pnlPanel.bulkSlider.Label:SizeToContents()
						
						if item.Type == "food" or item.Type == "medical" or item.Type == "weapon" or item.Type == "ammo" then
							local useBtn = vgui.Create("DButton", pnlPanel )
								useBtn:SetPos(70, 20)
								useBtn:SetSize(35,17)
								useBtn:SetText( "Use" )
								useBtn.DoClick = function() 
									net.Start("UseFromInvStoreage")
										net.WriteString("storage")
										net.WriteString(item.ID)
										net.WriteString(sid)
										net.WriteString(origin_iid)
									net.SendToServer() 
								end
						end
						
						if v["iid"] == "" and v["count"] > 1 then
							pnlPanel.bulkSlider:Show()
						end 
						
						local toolTip = nil
						if tostring(item.Info) ~= "" then toolTip = tostring(item.Info) end
						pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
						pnlPanel.Icon:SetModel(model, skin)
						pnlPanel.Icon:SetPos(3, 5)
						pnlPanel.Icon:SetToolTip( toolTip )
						pnlPanel.Icon.DoClick = function()
							local weightCur = CurInvWeight + item.Weight
							local weightBlk
							local weightCapBlk
							local amt = pnlPanel.bulkSlider:GetValue()
							
							--Idiot ammount check
							if amt <= 0 then amt = 1 end
							if amt >= v["count"] then amt = v["count"] end
							
							if amt >= 1 then								
								net.Start("pnrp_PlyInvTakeFromItemStorage")
									net.WriteString(item.ID)
									net.WriteDouble(math.Round(amt))
									net.WriteString(tostring(v["iid"]))
									net.WriteString(sid)
									net.WriteString(origin_iid)
								net.SendToServer()
							else
								ply:ChatPrint("Your pack is to full.")
							end
						end
				end
			end
		end
			
		--//Player Inventory
		local PlayerInvLabel = vgui.Create( "DLabel", itemIncentory_body )
			PlayerInvLabel:SetText("Player  Inventory")
			PlayerInvLabel:SetPos(320, 40)
			PlayerInvLabel:SetColor( Color( 0, 255, 0, 255 ) )
			PlayerInvLabel:SizeToContents()
		local yourWeight = vgui.Create("DLabel", itemIncentory_body)
			yourWeight:SetPos(475, 40 )
			yourWeight:SetText(yourWeightText)
			yourWeight:SetColor(yourWeightColor)
			yourWeight:SizeToContents() 
			
		local pnlUserIList = vgui.Create("DPanelList", itemIncentory_body)
			pnlUserIList:SetPos(315, 55)
			pnlUserIList:SetSize(paneWidth, itemIncentory_body:GetTall() - 111)
			pnlUserIList:EnableVerticalScrollbar(true) 
			pnlUserIList:EnableHorizontal(false) 
			pnlUserIList:SetSpacing(1)
			pnlUserIList:SetPadding(5)
		--Generates the user's inventory
		if plyInventoryTble == nil then
			local EmptyLabel = vgui.Create( "DLabel", itemIncentory_body )
				EmptyLabel:SetText("Player Inventory is Empty")
				EmptyLabel:SetColor( Color( 0, 255, 0, 255 ) )
				EmptyLabel:SizeToContents()
				
				pnlUserIList:AddItem(EmptyLabel)
		else
			for k, v in pairs( plyInventoryTble ) do
				local item = PNRP.Items[v["itemid"]]
				if item then
					local pnlPanel = vgui.Create("DPanel")
						pnlPanel:SetTall(75)
						pnlPanel.Paint = function()
							draw.RoundedBox( 1, 0, 0, pnlPanel:GetWide(), 1, Color( 0, 255, 0, 80 ) )
							draw.RoundedBox( 1, 0, pnlPanel:GetTall()-1, pnlPanel:GetWide(), 1, Color( 0, 255, 0, 80 ) )
						end
						pnlUserIList:AddItem(pnlPanel)
						
						local model = item.Model
						local skin = 0
						local Info = item.Info
						local countTxt = "Count: "..tostring(v["count"])
						if v["status_table"] != "" then
							countTxt = ""
							local HP = PNRP.GetFromStat(v["status_table"], "HP")
							if HP then 	countTxt = "HP: "..HP end
							local PowerLevel = PNRP.GetFromStat(v["status_table"], "PowerLevel")
							if PowerLevel then 	countTxt = countTxt.." Charge: "..tostring(math.Round(PowerLevel/100)).."% " end
							local FuelLevel = PNRP.GetFromStat(v["status_table"], "FuelLevel")
							if FuelLevel then countTxt = countTxt.." Fuel: "..tostring(FuelLevel) end
							local GasLevel = PNRP.GetFromStat(v["status_table"], "Gas")
							if GasLevel then countTxt = countTxt.." Gas: "..tostring(math.Round(100-((item.Tank-GasLevel)/item.Tank)*100)).."% " end
							
							local newModel = PNRP.GetFromStat(v["status_table"], "Model")
							local newSkin = PNRP.GetFromStat(v["status_table"], "Skin")
							if newModel then model = newModel end
							if newSkin then skin = tonumber(newSkin) end
						end
													
						pnlPanel.Title = vgui.Create("DLabel", pnlPanel)
						pnlPanel.Title:SetPos(70, 5)
						pnlPanel.Title:SetText(item.Name)
						pnlPanel.Title:SetColor(Color( 0, 255, 0, 255 ))
						pnlPanel.Title:SizeToContents() 
						pnlPanel.Title:SetContentAlignment( 5 )
						
						local weightTXT = "Weight: "..item.Weight
						if item.Capacity then
							weightTXT = weightTXT.." | Capacity: "..item.Capacity
						end
						pnlPanel.ItemWeight = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.ItemWeight:SetPos(70, 55)
						pnlPanel.ItemWeight:SetText(weightTXT)
						pnlPanel.ItemWeight:SetColor(Color( 0, 200, 0, 255 ))
						pnlPanel.ItemWeight:SizeToContents() 
						pnlPanel.ItemWeight:SetContentAlignment( 5 )
						
						pnlPanel.Count = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.Count:SetPos(70, 40)
						pnlPanel.Count:SetText(countTxt)
						pnlPanel.Count:SetColor(Color( 0, 255, 0, 255 ))
						pnlPanel.Count:SizeToContents() 
						pnlPanel.Count:SetContentAlignment( 5 )
						
						pnlPanel.bulkSlider = vgui.Create( "DNumSlider", pnlPanel )
						pnlPanel.bulkSlider:SetPos(0, 15) 
						pnlPanel.bulkSlider:SetWide( 250 )
						pnlPanel.bulkSlider:SetText( "" )
						pnlPanel.bulkSlider:SetMin( 1 )
						pnlPanel.bulkSlider:SetMax( v["count"] )
						pnlPanel.bulkSlider:SetDecimals( 0 )
						pnlPanel.bulkSlider:SetValue( 1 )
						pnlPanel.bulkSlider:Hide()
						pnlPanel.bulkSlider.Label:SizeToContents()
						
						if item.Type == "food" or item.Type == "medical" or item.Type == "weapon" or item.Type == "ammo" then
							local useBtn = vgui.Create("DButton", pnlPanel )
								useBtn:SetPos(70, 20)
								useBtn:SetSize(35,17)
								useBtn:SetText( "Use" )
								useBtn.DoClick = function() 
									net.Start("UseFromInvStoreage")
										net.WriteString("player")
										net.WriteString(item.ID)
										net.WriteString(sid)
										net.WriteString(origin_iid)
									net.SendToServer() 
								end
						end
						
						if v["iid"] == "" and v["count"] > 1 then
							pnlPanel.bulkSlider:Show()
						end 
						
						local toolTip = nil
						if tostring(item.Info) ~= "" then toolTip = tostring(item.Info) end
						pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
						pnlPanel.Icon:SetModel(model, skin)
						pnlPanel.Icon:SetPos(3, 5)
						pnlPanel.Icon:SetToolTip( toolTip )
						pnlPanel.Icon.DoClick = function()
							local weightCur = CurInvWeight + item.Weight
							local weightBlk
							local weightCapBlk
							local amt = pnlPanel.bulkSlider:GetValue()
							
							--Idiot ammount check
							if amt <= 0 then amt = 1 end
							if amt >= v["count"] then amt = v["count"] end
														
							if amt >= 1 then
								net.Start("pnrp_PlyInvAddToItemStorage")
									net.WriteString(item.ID)
									net.WriteDouble(math.Round(amt))
									net.WriteString(tostring(v["iid"]))
									net.WriteString(sid)
									net.WriteString(origin_iid)
								net.SendToServer()
							else
								ply:ChatPrint("Not enough storage space.")
							end
						end
				end
			end
		end	
end

function PNRP.AskRepair()
	local ply = LocalPlayer()
	local ent = net.ReadEntity()
	
	local item = PNRP.SearchItembase( ent )
	if not item then return end
	
	local opv_frame = vgui.Create( "DFrame" )
			opv_frame:SetSize( 200, 85 ) 
			opv_frame:SetPos(ScrW() / 2 - opv_frame:GetWide() / 2, ScrH() / 2 - opv_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
			opv_frame:SetTitle( item.Name )
			opv_frame:SetVisible( true )
			opv_frame:SetDraggable( true )
			opv_frame:ShowCloseButton( false )
			opv_frame:MakePopup()
			
		local opvLabel = vgui.Create("DLabel", opv_frame)
			opvLabel:SetColor( Color( 0, 255, 0, 255 ) )
			opvLabel:SetText( "Do you want to repair this? HP: "..ent:Health().."/"..item.HP )
			opvLabel:SizeToContents()
			opvLabel:SetPos(opv_frame:GetWide() / 2 - opvLabel:GetWide() / 2, 30)
			
			local opv_yes = vgui.Create("DButton") 
				opv_yes:SetParent( opv_frame ) 
				opv_yes:SetText( "Yes" ) 
				opv_yes:SetPos(opv_frame:GetWide() / 2 - 60, 50) 
				opv_yes:SetSize( 50, 20 ) 
				opv_yes.DoClick = function() 
					
					net.Start("PNRP_DoRepairItem")
						net.WriteEntity(ent)
					net.SendToServer()
					
					opv_frame:Close() 
				end 
			
			local opv_no = vgui.Create("DButton") 
				opv_no:SetParent( opv_frame )
				opv_no:SetText( "No" )
				opv_no:SetPos(opv_frame:GetWide() / 2 + 10, 50)
				opv_no:SetSize( 50, 20 ) 
				opv_no.DoClick = function() 
					opv_frame:Close() 
				end
end
net.Receive("PNRP_CL_AskRepair", PNRP.AskRepair)