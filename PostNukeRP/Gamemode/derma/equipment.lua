function CheckDefWeps(wep)
	local defWeps = table.Add(PNRP.DefWeps)
	for k,v in pairs(defWeps) do
		if string.lower(v) == wep:GetClass() then
			return true
		end
	end
end

function isNearCar(ply)
	for k,v in pairs(ents.FindInSphere( ply:GetPos(), 200 )) do
		local ItemID = PNRP.FindItemID( v:GetClass() )
		if ItemID != nil then
			local myType = PNRP.Items[ItemID].Type
			if tostring(v:GetNetworkedString( "Owner" , "None" )) == ply:Nick() && myType == "vehicle" then
				return true
			end
		end
	end
	return false
end

function ConvertWepEnt( weaponModel )
	for itemname, item in pairs( PNRP.Items ) do
		if weaponModel == item.Model then
			return item.Ent
		end
	end
	return nil
end

function GM.EquipmentWindow( handler, id, encoded, decoded )
	local ply = LocalPlayer() 
	local MyWeight = decoded[1]
	local CarWeight = decoded[2]
	local MyWeightCap = decoded[3]
	
	local eq_frame = vgui.Create( "DFrame" )
		eq_frame:SetSize( 500, 200 ) --Set the size
		eq_frame:SetPos(ScrW() / 2 - eq_frame:GetWide() / 2, ScrH() / 2 - eq_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
		eq_frame:SetTitle( "Equipment Menu" ) --Set title
		eq_frame:SetVisible( true )
		eq_frame:SetDraggable( true )
		eq_frame:ShowCloseButton( true )
		eq_frame:MakePopup()
		
	--	local pnlList = vgui.Create("DPanelList", eq_frame)
	--		pnlList:SetPos(10, 25)
	--		pnlList:SetSize(eq_frame:GetWide() - 150, eq_frame:GetTall() - 35)
	--		pnlList:EnableVerticalScrollbar(false) 
	--		pnlList:EnableHorizontal(true) 
	--		pnlList:SetSpacing(1)
	--		pnlList:SetPadding(10)
		
		local eqPanel = vgui.Create( "DPanel", eq_frame )
				eqPanel:SetPos(10, 25)
				eqPanel:SetSize(eq_frame:GetWide() - 175, eq_frame:GetTall() - 35)
				eqPanel.Paint = function() -- Paint function
					surface.SetDrawColor( 52, 54, 59, 255 )
					surface.DrawRect( 0, 0, eqPanel:GetWide(), eqPanel:GetTall() ) -- Draw the rect
				end
			local Scroller = vgui.Create("DHorizontalScroller", eqPanel) --Create the scroller
			Scroller:SetSize(eqPanel:GetWide()-8, eqPanel:GetTall() - 10)
			Scroller:AlignBottom(5)
			Scroller:AlignLeft(4)
			Scroller:SetOverlap(-1) --Set how much to overlap, negative numbers will space out the panels.
			
			local AmmoComboBox = vgui.Create( "DComboBox", eq_frame )
			AmmoComboBox:SetPos( eqPanel:GetWide() + 20, 25 )
			AmmoComboBox:SetSize( 125, 65 )
			AmmoComboBox:SetMultiple( false ) -- <removed sarcastic and useless comment>
			local ammoCount_str = "Equipped Ammo \n"
			for itemname, item in pairs( PNRP.Items ) do
				if item.Type == "ammo" then
					local ammoType = item.ID
					ammoType = string.gsub(ammoType, "ammo_", "")
					
					local ammoCount = ply:GetAmmoCount( ammoType )
					if ammoCount > 0 then
						AmmoComboBox:AddItem( ammoType )
						ammoCount_str = ammoCount_str..ammoType..": "..tostring(ply:GetAmmoCount(ammoType)).."\n"
					end
				end
			end	
			AmmoComboBox:SetToolTip( ammoCount_str )
			
			for k, v in pairs(ply:GetWeapons()) do
			--	local wepCheck = CheckDefWeps(v)
			--	if !wepCheck then
				if string.lower(v:GetModel()) == "models/weapons/v_hands.mdl" and string.lower(v:GetClass()) ~= "weapon_radio" then
					--Do Nothing
				else
					if PNRP.FindWepItem(v:GetModel()) and checkGren(ply, v) then
						local myItem = PNRP.FindWepItem(v:GetModel())
						local pnlPanel = vgui.Create("DPanel", Scroller)
						--	pnlPanel:SetTall(pnlList:GetTall() - 20)
							pnlPanel:SetSize( 75, eqPanel:GetTall() - 20 )
							pnlPanel.Paint = function()
								draw.RoundedBox( 6, 0, 0, pnlPanel:GetWide(), pnlPanel:GetTall(), Color( 180, 180, 180, 255 ) )		
							end
							
							pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
							pnlPanel.Icon:SetModel(myItem.Model)
							pnlPanel.Icon:SetPos(pnlPanel:GetWide() / 2 - pnlPanel.Icon:GetWide() / 2, 5 )
							pnlPanel.Icon:SetToolTip( nil )
							pnlPanel.Icon.DoClick = function()	
							
								if ( v ) then
									if v:GetClass() == "weapon_frag" then
										if ply:GetAmmoCount( v:GetPrimaryAmmoType() ) > 0 then
											RunConsoleCommand("pnrp_dropAmmo", "grenade")
										else
											RunConsoleCommand("pnrp_stripWep",v:GetClass())
										end
										eq_frame:Close()
									elseif v:GetClass() == "weapon_pnrp_charge" then
										if ply:GetAmmoCount( v:GetPrimaryAmmoType() ) > 0 then
											RunConsoleCommand("pnrp_dropAmmo", "slam")
										else
											RunConsoleCommand("pnrp_stripWep",v:GetClass())
										end
										eq_frame:Close()
									else
										local curWepAmmo = v:Clip1()																
										datastream.StreamToServer("pnrp_dropWepFromEQ", {myItem.ID, curWepAmmo} )
										eq_frame:Close()
										RunConsoleCommand("pnrp_stripWep",v:GetClass())
									end
								end
							
							end
							
							pnlPanel.Name = vgui.Create("DLabel", pnlPanel)		
							pnlPanel.Name:SetPos(5, 80)
							pnlPanel.Name:SetText(myItem.Name)
							pnlPanel.Name:SetColor(Color( 0, 0, 0, 255 ))
							pnlPanel.Name:SizeToContents() 
							pnlPanel.Name:SetContentAlignment( 5 )
							
							pnlPanel.sendToInv = vgui.Create("DButton", pnlPanel )
							pnlPanel.sendToInv:SetPos(5, 100)
							pnlPanel.sendToInv:SetSize(pnlPanel:GetWide() - 10,18)
							pnlPanel.sendToInv:SetText( ">>Inv" )
	--				    	pnlPanel.sendToInv:SizeToContents() 
							pnlPanel.sendToInv.DoClick = function()
								
								local weight = MyWeight + myItem.Weight
								
								if weight <= MyWeightCap then
									RunConsoleCommand("pnrp_addtoinvfromeq",myItem.ID,v:GetClass())
									RunConsoleCommand("pnrp_stripWep",v:GetClass())
								else
									ply:ChatPrint("You're pack is full.")
								end
								eq_frame:Close()
								
							end	
							
							for n,c in pairs(ents.FindInSphere( ply:GetPos(), 200 )) do
								local CarItemID = PNRP.FindItemID( c:GetClass() )
								if CarItemID != nil then
									local myCarType = PNRP.Items[CarItemID].Type
									if tostring(c:GetNetworkedString( "Owner" , "None" )) == ply:Nick() && myCarType == "vehicle" then	
										pnlPanel.sendCarInv = vgui.Create("DButton", pnlPanel )
										pnlPanel.sendCarInv:SetPos(5, 120)
										pnlPanel.sendCarInv:SetSize(pnlPanel:GetWide() - 10,18)
										pnlPanel.sendCarInv:SetText( ">>Car Inv" )							    	 
										pnlPanel.sendCarInv.DoClick = function()
										
											local weight = CarWeight + myItem.Weight
											local weightCap
											
											
											weightCap = PNRP.Items[CarItemID].Weight
											
											if weight <= weightCap then
												RunConsoleCommand("pnrp_addtocarinentoryFromEQ",myItem.ID)
												RunConsoleCommand("pnrp_stripWep",v:GetClass())
												eq_frame:Close()
											else
												eq_frame:Close()
												ply:ChatPrint("You're car trunk is full.")
											end	
										end
										
										local ammoToCar = vgui.Create("DButton", eq_frame )
										ammoToCar:SetPos(eqPanel:GetWide() + 20, AmmoComboBox:GetTall() + 105)
										ammoToCar:SetSize(125,18)
										ammoToCar:SetText( ">>Car Inv" )							    	 
										ammoToCar.DoClick = function()
										
											local weight = CarWeight + myItem.Weight
											local weightCap
											
											
											weightCap = PNRP.Items[CarItemID].Weight
											
											if weight <= weightCap then
												local ammoID = "ammo_"..AmmoComboBox:GetSelectedItems()[1]:GetValue()
												RunConsoleCommand("pnrp_addtocarinentoryFromEQ",ammoID)
												RunConsoleCommand("pnrp_stripAmmo",ammoID)
												eq_frame:Close()
											else
												eq_frame:Close()
												ply:ChatPrint("You're car trunk is full.")
											end	
										end
										
									end
								end
							end
							
							
							Scroller:AddPanel(pnlPanel)
					end
				end
			end
			
		local maxAmmo = 100		
		local ammoSlide = vgui.Create( "DNumSlider", eq_frame )
			ammoSlide:SetSize( AmmoComboBox:GetWide(), 50 ) -- Keep the second number at 50
			ammoSlide:SetPos( eqPanel:GetWide() + 20, AmmoComboBox:GetTall() + 26 )
			ammoSlide:SetText( "Amount" )
			ammoSlide:SetMin( 0 )
			ammoSlide:SetMax( maxAmmo )
			ammoSlide:SetDecimals( 0 )
			
		local dropAmmoBtn = vgui.Create("DButton", eq_frame )
			dropAmmoBtn:SetPos(eqPanel:GetWide() + 20, AmmoComboBox:GetTall() + 65)
			dropAmmoBtn:SetSize(125,18)
			dropAmmoBtn:SetText( "Drop Ammo" )							    	 
			dropAmmoBtn.DoClick = function()
				if AmmoComboBox:GetSelectedItems() and AmmoComboBox:GetSelectedItems()[1] then
					if ammoSlide:GetValue() > 0 then
						RunConsoleCommand("pnrp_dropAmmo",AmmoComboBox:GetSelectedItems()[1]:GetValue(), ammoSlide:GetValue())
						eq_frame:Close()
					else
						RunConsoleCommand("pnrp_dropAmmo",AmmoComboBox:GetSelectedItems()[1]:GetValue())
						eq_frame:Close()
					end
				end
			end
		local invAmmoBtn = vgui.Create("DButton", eq_frame )
			invAmmoBtn:SetPos(eqPanel:GetWide() + 20, AmmoComboBox:GetTall() + 85)
			invAmmoBtn:SetSize(125,18)
			invAmmoBtn:SetText( ">>Inventory" )							    	 
			invAmmoBtn.DoClick = function()
				if AmmoComboBox:GetSelectedItems() and AmmoComboBox:GetSelectedItems()[1] then
					local ammoID = "ammo_"..AmmoComboBox:GetSelectedItems()[1]:GetValue()
					RunConsoleCommand("pnrp_addtoinvfromceq-ammo",ammoID)
					eq_frame:Close()
				end
			end
end
datastream.Hook( "pnrp_OpenEquipmentWindow", GM.EquipmentWindow )

function checkGren(ply, weapon)
	if weapon:GetClass() == "weapon_frag" then
		if ply:GetAmmoCount( weapon:GetPrimaryAmmoType() ) <= 0 then
			return false
		end
	end
	return true
end

function GM.initEquipment(ply)

	RunConsoleCommand("pnrp_initEQ")

end
concommand.Add( "pnrp_eqipment",  GM.initEquipment )

--EOF