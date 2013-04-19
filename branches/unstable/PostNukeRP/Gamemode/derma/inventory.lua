--Build Inventory Window

local CurCarInvWeight
local inventory_frame
local inventoryFrameCK = false

function GM.inventory_window( len )
	--Stops the multi window exploit
	if inventoryFrameCK then return end 
	inventoryFrameCK = true
	
	local MyInventory = net.ReadTable()		
	local CurWeight = net.ReadString()	
	CurCarInvWeight = net.ReadString()
	local ply = LocalPlayer()	
	inventory_frame = vgui.Create( "DFrame" )
		inventory_frame:SetSize( 710, 720 ) --Set the size
		--Set the window in the middle of the players screen/game window
		inventory_frame:SetPos(ScrW() / 2 - inventory_frame:GetWide() / 2, ScrH() / 2 - inventory_frame:GetTall() / 2) 
		inventory_frame:SetTitle( "Inventory Menu" ) --Set title
		inventory_frame:SetVisible( true )
		inventory_frame:SetDraggable( true )
		inventory_frame:ShowCloseButton( true )
		inventory_frame:MakePopup()
		inventory_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", inventory_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_1b.png" )
			screenBG:SetKeepAspect()
			screenBG:SizeToContents()
			screenBG:SetSize(inventory_frame:GetWide(), inventory_frame:GetTall())
		
		PNRP.buildMenu(inventory_frame)
		
	local PropertySheet = vgui.Create( "DPropertySheet" )
			PropertySheet:SetParent( inventory_frame )
			PropertySheet:SetPos( 40, 60 )
			PropertySheet:SetSize( inventory_frame:GetWide() - 85 , inventory_frame:GetTall() - 105 )
			PropertySheet:SetFadeTime( 0.5 )
			PropertySheet.Paint = function() 
				surface.SetDrawColor( 50, 50, 50, 0 )
			end
			
			local weaponPanel = PNRP.build_inv_List(ply, "weapon", inventory_frame, PropertySheet, MyInventory)
			local ammoPanel = PNRP.build_inv_List(ply, "ammo", inventory_frame, PropertySheet, MyInventory)
			local medicalPanel = PNRP.build_inv_List(ply, "medical", inventory_frame, PropertySheet, MyInventory)
			local foodPanel = PNRP.build_inv_List(ply, "food", inventory_frame, PropertySheet, MyInventory)
			local vehiclePanel = PNRP.build_inv_List(ply, "vehicle", inventory_frame, PropertySheet, MyInventory)
			local toolsPanel = PNRP.build_inv_List(ply, "tool", inventory_frame, PropertySheet, MyInventory)
			local partsPanel = PNRP.build_inv_List(ply, "part", inventory_frame, PropertySheet, MyInventory)
			local miscPanel = PNRP.build_inv_List(ply, "misc", inventory_frame, PropertySheet, MyInventory)
			local allPanel = PNRP.build_inv_List(ply, "all", inventory_frame, PropertySheet, MyInventory)
						
			PropertySheet:AddSheet( "Weapons", weaponPanel, "gui/icons/bomb.png", false, false, "Build Weapons" )
			PropertySheet:AddSheet( "Ammo", ammoPanel, "gui/icons/box.png", false, false, "Create Ammo" )
			PropertySheet:AddSheet( "Medical", medicalPanel, "gui/icons/heart.png", false, false, "Medical Items" )
			PropertySheet:AddSheet( "Food and Drink", foodPanel, "gui/icons/cup_add.png", false, false, "Food and Drink Items" )
			PropertySheet:AddSheet( "Vehicles", vehiclePanel, "gui/icons/car.png", false, false, "Create Vehicles" )
			PropertySheet:AddSheet( "Tools", toolsPanel, "gui/icons/wrench.png", false, false, "Make Tools - Still in Development" )
			PropertySheet:AddSheet( "Parts", partsPanel, "gui/icons/cog.png", false, false, "Got to find them all." )
			PropertySheet:AddSheet( "Misc", miscPanel, "gui/icons/bug.png", false, false, "Pets, paper, etc..." )
			
			PropertySheet:AddSheet( "All", allPanel, "gui/icons/add.png", false, false, "Everything including the kitchen sink." )
			
	local InvWeight = vgui.Create("DLabel", inventory_frame)		
			InvWeight:SetPos(555, 38 )
			local maxWeight
			if ply:Team() == TEAM_SCAVENGER then
				maxWeight = GetConVar("pnrp_packCapScav"):GetInt() + (GetSkill("Backpacking")*10)
			else
				maxWeight = GetConVar("pnrp_packCap"):GetInt() + (GetSkill("Backpacking")*10)
			end
			InvWeight:SetText("Weight: "..tostring(CurWeight).."/"..tostring(maxWeight))
			local whColor
			if tonumber(CurWeight) >= tonumber(maxWeight) then
				whColor = Color( 255, 0, 0, 255 )
			else
				whColor = Color( 0, 255, 0, 255 )
			end
			InvWeight:SetColor(whColor)
			InvWeight:SizeToContents() 
			
	function inventory_frame:Close()                  
		inventoryFrameCK = false                  
		self:SetVisible( false )                  
		self:Remove()          
	end 
end

function PNRP.build_inv_List(ply, itemtype, parent_frame, PropertySheet, MyInventory)

	local sc = 0
	local sp = 0
	local ch = 0

	local pnlList = vgui.Create("DPanelList", PropertySheet)
		pnlList:SetPos(20, 80)
		pnlList:SetSize(parent_frame:GetWide() - 40, parent_frame:GetTall() - 100)
		pnlList:EnableVerticalScrollbar(true) 
		pnlList:EnableHorizontal(false) 
		pnlList:SetSpacing(1)
		pnlList:SetPadding(10)
		pnlList.Paint = function()
		--	draw.RoundedBox( 8, 0, 0, pnlList:GetWide(), pnlList:GetTall(), Color( 50, 50, 50, 255 ) )
		end		
		
		for itemname, item in pairs(PNRP.Items) do
			if item.Type == tostring( itemtype ) or tostring( itemtype ) == "all" then
				for k, v in pairs( MyInventory ) do
					if string.lower(k) == string.lower(itemname) then
						local pnlPanel = vgui.Create("DPanel")
						pnlPanel:SetTall(75)
						pnlPanel.Paint = function()
						
							draw.RoundedBox( 6, 0, 0, pnlPanel:GetWide(), pnlPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
					
						end
						pnlList:AddItem(pnlPanel)
						
						pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
						pnlPanel.Icon:SetModel(item.Model)
						pnlPanel.Icon:SetPos(3, 5)
						pnlPanel.Icon:SetToolTip( nil )
						pnlPanel.Icon.DoClick = function()
								RunConsoleCommand("inventory_drop", itemname)
								parent_frame:Close()
						end	
						
						pnlPanel.Title = vgui.Create("DLabel", pnlPanel)
						pnlPanel.Title:SetPos(90, 5)
						pnlPanel.Title:SetText(item.Name)
						pnlPanel.Title:SetColor(Color( 0, 0, 0, 255 ))
						pnlPanel.Title:SizeToContents() 
				 		pnlPanel.Title:SetContentAlignment( 5 )
				 		
				 		if item.Scrap != nil then sc = item.Scrap else sc = 0 end
				 		if item.SmallParts != nil then sp = item.SmallParts else sp = 0 end
				 		if item.Chemicals != nil then ch = item.Chemicals else ch = 0 end
				 		
				 		pnlPanel.Count = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.Count:SetPos(90, 55)
						pnlPanel.Count:SetText("Count: "..tostring(v))
						pnlPanel.Count:SetColor(Color( 0, 0, 0, 255 ))
						pnlPanel.Count:SizeToContents() 
				 		pnlPanel.Count:SetContentAlignment( 5 )	
				 		
				 		if item.Type == "food" or item.Type == "medical" or item.Type == "weapon" or item.Type == "ammo" then
					 		pnlPanel.salvageItem = vgui.Create("DButton", pnlPanel )
							pnlPanel.salvageItem:SetPos(200, 55)
					 		pnlPanel.salvageItem:SetSize(100,17)
					    	pnlPanel.salvageItem:SetText( "Use Item" )
					    	pnlPanel.salvageItem.DoClick = function() 
								net.Start("UseFromInv")
									net.WriteEntity(ply)
									net.WriteString(item.ID)
									net.WriteString("1")
								net.SendToServer()
					    		parent_frame:Close() 
					    	end
					    end
				 		
				 		pnlPanel.ClassBuild = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.ClassBuild:SetPos(250, 5)
						pnlPanel.ClassBuild:SetText("Required Class: "..item.ClassSpawn)
						pnlPanel.ClassBuild:SetColor(Color( 0, 0, 0, 255 ))
						pnlPanel.ClassBuild:SizeToContents() 
				 		pnlPanel.ClassBuild:SetContentAlignment( 5 )
				 		
				 		pnlPanel.ClassBuild = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.ClassBuild:SetPos(90, 25)
						pnlPanel.ClassBuild:SetText(item.Info)
						pnlPanel.ClassBuild:SetColor(Color( 0, 0, 0, 255 ))
						pnlPanel.ClassBuild:SetWide(300)
						pnlPanel.ClassBuild:SetTall(25)
						pnlPanel.ClassBuild:SetWrap(true) 
				 		pnlPanel.ClassBuild:SetContentAlignment( 5 )	
				 		
				 		pnlPanel.ItemWeight = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.ItemWeight:SetPos(340, 55)
						pnlPanel.ItemWeight:SetText("Weight: "..item.Weight)
						pnlPanel.ItemWeight:SetColor(Color( 0, 0, 0, 255 ))
						pnlPanel.ItemWeight:SizeToContents() 
				 		pnlPanel.ItemWeight:SetContentAlignment( 5 )	
				 		
						pnlPanel.bulkSlider = vgui.Create( "DNumSlider", pnlPanel )
						pnlPanel.bulkSlider:SetPos(400, 20) 
						pnlPanel.bulkSlider:SetWide( 175 )
						pnlPanel.bulkSlider:SetText( "" )
						pnlPanel.bulkSlider:SetMin( 1 )
						pnlPanel.bulkSlider:SetMax( v )
						pnlPanel.bulkSlider:SetDecimals( 0 )
						pnlPanel.bulkSlider:SetValue( 1 )
						pnlPanel.bulkSlider.Label:SizeToContents()
						
				 		if itemtype != "vehicle" then							
							if item.Type == "tool" or item.Type == "junk" or item.Type == "misc" then
								--Since GMod does not like Not or's
							else								
								pnlPanel.BulkBtn = vgui.Create("DButton", pnlPanel )
								pnlPanel.BulkBtn:SetPos(485, 5)
								pnlPanel.BulkBtn:SetSize(80,17)
								pnlPanel.BulkBtn:SetText( "Drop Bulk" )
								pnlPanel.BulkBtn.DoClick = function() 
									net.Start("DropBulkCrate")
										net.WriteEntity(ply)
										net.WriteString(itemname)
										net.WriteDouble(math.Round(tonumber(pnlPanel.bulkSlider:GetValue())))
									net.SendToServer()
									parent_frame:Close()
								end
							end
							
					    	for _, car in pairs(ents.FindInSphere( ply:GetPos(), 200 )) do
								local ItemID = PNRP.FindItemID( car:GetClass() )
								if ItemID != nil then
									if ItemID == "vehicle_jalopy" and car:GetModel() == "models/buggy.mdl" then
										ItemID = "vehicle_jeep"
									end
									local myType = PNRP.Items[ItemID].Type
									if tostring(car:GetNetworkedString( "Owner_UID" , "None" )) == PNRP:GetUID(ply) && myType == "vehicle" then
									
										pnlPanel.sendCarInvBlk = vgui.Create("DButton", pnlPanel )
										pnlPanel.sendCarInvBlk:SetPos(400, 55)
										pnlPanel.sendCarInvBlk:SetSize(80,18)
										pnlPanel.sendCarInvBlk:SetText( "Send to Car Inv" )
										pnlPanel.sendCarInvBlk.DoClick = function()
											local weightCur = CurCarInvWeight + item.Weight
											local weightBlk
											local weightCapBlk
											local amt = pnlPanel.bulkSlider:GetValue()
											
											--Idiot ammount check
											if amt <= 0 then amt = 1 end
											if amt >= v then amt = v end

											weightBlk = item.Weight * amt
											
											weightCap = PNRP.Items[ItemID].Weight
											if weightCur <= weightCap then
												net.Start( "pnrp_addtocarinentory" )
													net.WriteEntity(ply)
													net.WriteString("BlkCarInv")
													net.WriteString(item.ID)
													net.WriteDouble(math.Round(amt))
												net.SendToServer()

												parent_frame:Close()
											else
												local RemainingW = weightCap - weightCur
												if RemainingW >= 1 then
													amt = RemainingW / item.Weight
													amt = floor(amt)
													if amt >= 1 then
														net.Start( "pnrp_addtocarinentory" )
															net.WriteEntity(ply)
															net.WriteString("BlkCarInv")
															net.WriteString(item.ID)
															net.WriteDouble(math.Round(amt))
														net.SendToServer()
														parent_frame:Close()
													else
														parent_frame:Close()
														ply:ChatPrint("You're car trunk is full.")
													end
												else
													parent_frame:Close()
													ply:ChatPrint("You're car trunk is full.")
												end
											end										
										end
										
									end
						
								end
					    	
					    	end

						end
						
						pnlPanel.salvageItem = vgui.Create("DButton", pnlPanel )
						pnlPanel.salvageItem:SetPos(485, 55)
				 		pnlPanel.salvageItem:SetSize(80,17)
				    	pnlPanel.salvageItem:SetText( "Salvage Item" )
				    	pnlPanel.salvageItem.DoClick = function() 
							local getBSalvageCount = pnlPanel.bulkSlider:GetValue()
							if getBSalvageCount then
								if getBSalvageCount < 0 then
									getBSalvageCount = 0
								end
								if getBSalvageCount > v then
									getBSalvageCount = v
								end
								local sndSTR = item.ID..","..tostring(math.Round(getBSalvageCount))
								PNRP.OptionVerify( "pnrp_dosalvage", sndSTR, nil, nil) parent_frame:Close() 
							end
						end
				 	end
				end
			end
		end	
	
	return pnlList

end
net.Receive("pnrp_OpenInvWindow", GM.inventory_window)
 
function PNRP.InvToCarBlk(item, carMdl, count)
	local ply = LocalPlayer()
	
	local weight = CurCarInvWeight + item.Weight
	local weightCap
	
	local BlkToCar_frame = vgui.Create( "DFrame" )
		BlkToCar_frame:SetSize( 500, 200 ) --Set the size
		--Set the window in the middle of the players screen/game window
		BlkToCar_frame:SetPos(ScrW() / 2 - eq_frame:GetWide() / 2, ScrH() / 2 - eq_frame:GetTall() / 2) 
		BlkToCar_frame:SetTitle( "Bulk to Car Menu" ) --Set title
		BlkToCar_frame:SetVisible( true )
		BlkToCar_frame:SetDraggable( true )
		BlkToCar_frame:ShowCloseButton( true )
		BlkToCar_frame:MakePopup()
		
		local BlkToCar_Icon = vgui.Create("SpawnIcon", BlkToCar_frame)
			BlkToCar_Icon:SetModel(carMdl)
			BlkToCar_Icon:SetPos(20, 20)
			BlkToCar_Icon:SetToolTip( nil )
		
		local BlkToCar_DPanel = vgui.Create("DLabel", BlkToCar_frame)
			BlkToCar_DPanel:SetPos(90, 20)
			BlkToCar_DPanel:SetText("Select amount to place in the Car.")
			BlkToCar_DPanel:SetColor( Color( 255, 255, 255, 255 ) )
			BlkToCar_DPanel:SizeToContents() 
			BlkToCar_DPanel:SetContentAlignment( 5 )
end

function GM.initInventory(ply)

	RunConsoleCommand("pnrp_OpenInventory")

end
concommand.Add( "pnrp_inv",  GM.initInventory )

--EOF