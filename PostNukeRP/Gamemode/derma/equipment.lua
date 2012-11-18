--require('datastream')

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
--	local ply = LocalPlayer() 
--	local MyWeight = decoded[1]
--	local CarWeight = decoded[2]
--	local MyWeightCap = decoded[3]
	local ply = net.ReadEntity() 
	local MyWeight = tonumber(net.ReadString())
	local CarWeight = net.ReadString()
	local MyWeightCap = net.ReadFloat()
	local foundCar = false
	local CarItemID
	local CarWeightCap

	for n,c in pairs(ents.FindInSphere( ply:GetPos(), 200 )) do
		CarItemID = PNRP.FindItemID( c:GetClass() )
		if CarItemID != nil then
			if CarItemID == "vehicle_jalopy" and c:GetModel() == "models/buggy.mdl" then
				CarItemID = "vehicle_jeep"
			end
			local myCarType = PNRP.Items[CarItemID].Type
			if tostring(c:GetNetworkedString( "Owner" , "None" )) == ply:Nick() && myCarType == "vehicle" then	
				foundCar = true
				CarWeightCap = PNRP.Items[CarItemID].Weight
			end
		end
	end
	
	local eq_frame = vgui.Create( "DFrame" )
		eq_frame:SetSize( 585, 289 ) --Set the size
		eq_frame:SetPos(ScrW() / 2 - eq_frame:GetWide() / 2, ScrH() / 2 - eq_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
		eq_frame:SetTitle( "Equipment Menu" ) --Set title
		eq_frame:SetVisible( true )
		eq_frame:SetDraggable( true )
		eq_frame:ShowCloseButton( true )
		eq_frame:MakePopup()
		eq_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", eq_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_6b.png" )
			screenBG:SetSize(eq_frame:GetWide(), eq_frame:GetTall())	
		
		local eqPanel = vgui.Create( "DPanel", eq_frame )
				eqPanel:SetPos(30, 40)
				eqPanel:SetSize(eq_frame:GetWide() - 275, eq_frame:GetTall() - 80)
				eqPanel.Paint = function() -- Paint function
				--	surface.SetDrawColor( 52, 54, 59, 255 )
				--	surface.DrawRect( 0, 0, eqPanel:GetWide(), eqPanel:GetTall() ) -- Draw the rect
				end
			local Scroller = vgui.Create("DHorizontalScroller", eqPanel) --Create the scroller
			Scroller:SetSize(eqPanel:GetWide()-8, eqPanel:GetTall() - 10)
			Scroller:AlignBottom(5)
			Scroller:AlignLeft(4)
			Scroller:SetOverlap(-1) --Set how much to overlap, negative numbers will space out the panels.
			
			local AmmoListView = vgui.Create( "DListView", eq_frame )
			AmmoListView:SetPos( eq_frame:GetWide() - 205, 40 )
			AmmoListView:SetSize( 155, 80 )
			AmmoListView:SetMultiSelect( false ) -- <removed sarcastic and useless comment>
			AmmoListView:AddColumn("Ammo")
			AmmoListView:AddColumn("Count")
			AmmoListView.Paint = function() -- Paint function
				surface.SetDrawColor( 180, 180, 180, 80 )
			end
			local ammoCount_str = "Equipped Ammo \n"
			for itemname, item in pairs( PNRP.Items ) do
				if item.Type == "ammo" then
					local ammoType = item.ID
					ammoType = string.gsub(ammoType, "ammo_", "")
					
					local ammoCount = ply:GetAmmoCount( ammoType )
					if ammoCount > 0 then
						AmmoListView:AddLine( ammoType, ammoCount )
						ammoCount_str = ammoCount_str..ammoType..": "..tostring(ply:GetAmmoCount(ammoType)).."\n"
					end
				end
			end	
			AmmoListView:SetToolTip( ammoCount_str )
			
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
											RunConsoleCommand("pnrp_dropAmmo","grenade", "1")
										else
											RunConsoleCommand("pnrp_stripWep",v:GetClass())
										end
										eq_frame:Close()
									elseif v:GetClass() == "weapon_pnrp_charge" then
										if ply:GetAmmoCount( v:GetPrimaryAmmoType() ) > 0 then
											RunConsoleCommand("pnrp_dropAmmo","slam", "1")
										else
											RunConsoleCommand("pnrp_stripWep",v:GetClass())
										end
										eq_frame:Close()
									else
										local curWepAmmo = v:Clip1()																
										--datastream.StreamToServer("pnrp_dropWepFromEQ", {myItem.ID, curWepAmmo} )
										net.Start( "pnrp_dropWepFromEQ" )
											net.WriteEntity(ply)
											net.WriteString(myItem.ID)
											net.WriteString(curWepAmmo)
										net.SendToServer()
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
							
							
							if foundCar then	
								pnlPanel.sendCarInv = vgui.Create("DButton", pnlPanel )
								pnlPanel.sendCarInv:SetPos(5, 120)
								pnlPanel.sendCarInv:SetSize(pnlPanel:GetWide() - 10,18)
								pnlPanel.sendCarInv:SetText( ">>Car Inv" )							    	 
								pnlPanel.sendCarInv.DoClick = function()
								
									local weight = CarWeight + myItem.Weight
									
									if weight <= CarWeightCap then
										--RunConsoleCommand("pnrp_addtocarinentoryFromEQ",myItem.ID)
										--datastream.StreamToServer( "pnrp_addtocarinentory", { "FromEQ", myItem.ID, 1  } )
										net.Start( "pnrp_addtocarinentory" )
											net.WriteEntity(ply)
											net.WriteString("FromEQ")
											net.WriteString(myItem.ID)
											net.WriteDouble(1)
										net.SendToServer()
										RunConsoleCommand("pnrp_stripWep",v:GetClass())
										eq_frame:Close()
									else
										eq_frame:Close()
										ply:ChatPrint("You're car trunk is full.")
									end	
								end
							end
								
							
							
							
							Scroller:AddPanel(pnlPanel)
					end
				end
			end
			
		local maxAmmo = 100		
		local ammoSlide = vgui.Create( "DNumSlider", eq_frame )
			ammoSlide:SetWide( 250 )
			ammoSlide:SetPos( eq_frame:GetWide() - 290, AmmoListView:GetTall() + 35 )
			ammoSlide:SetText( "" )
			ammoSlide:SetMin( 0 )
			ammoSlide:SetValue( 0 )
			ammoSlide:SetMax( maxAmmo )
			ammoSlide:SetDecimals( 0 )
			ammoSlide.Paint = function() -- Paint function
				surface.SetDrawColor( 255, 255, 255, 255 )
			end
		local ammoSlideLabel = vgui.Create("DLabel", eq_frame)		
			ammoSlideLabel:SetPos(eq_frame:GetWide() - 205, AmmoListView:GetTall() + 45)
			ammoSlideLabel:SetText("Amount")
			ammoSlideLabel:SetColor(Color( 255, 255, 255, 255 ))
			ammoSlideLabel:SizeToContents() 
			ammoSlideLabel:SetContentAlignment( 5 )
		
		--//Menu	
		local btnHPos = 170
		local btnWPos = eq_frame:GetWide()-220
		local btnHeight = 35
		local lblColor = Color( 245, 218, 210, 180 )
		
		local dropAmmoBtn = vgui.Create("DImageButton", eq_frame)
			dropAmmoBtn:SetPos( btnWPos,btnHPos )
			dropAmmoBtn:SetSize(30,30)
			dropAmmoBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			dropAmmoBtn.DoClick = function() 
				--if AmmoListView:GetSelectedItems() and AmmoListView:GetSelectedItems()[1] then
				if AmmoListView:GetSelectedLine() then
					local ammoAMT
					--local ammoATYPE = AmmoListView:GetSelectedItems()[1]:GetValue()
					local ammoATYPE = AmmoListView:GetLine(AmmoListView:GetSelectedLine()):GetValue(1)
					local ammoFTYPE = "ammo_"..ammoATYPE
					
					if ammoSlide:GetValue() <= 0 then 
						ammoAMT = PNRP.Items[ammoFTYPE].Energy
					else
						ammoAMT = ammoSlide:GetValue()
					end
					if ammoAMT > ply:GetAmmoCount(ammoATYPE) then
						ammoAMT = ply:GetAmmoCount(ammoATYPE)
					end
					RunConsoleCommand("pnrp_dropAmmo",ammoATYPE, ammoAMT)
					eq_frame:Close()
				end
			end
			dropAmmoBtn.Paint = function()
				if dropAmmoBtn:IsDown() then 
					dropAmmoBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					dropAmmoBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local dropAmmoBtnLbl = vgui.Create("DLabel", eq_frame)
			dropAmmoBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
			dropAmmoBtnLbl:SetColor( lblColor )
			dropAmmoBtnLbl:SetText( "Drop Ammo" )
			dropAmmoBtnLbl:SetFont("Trebuchet24")
			dropAmmoBtnLbl:SizeToContents()		
			
		btnHPos = btnHPos + btnHeight
		local invAmmoBtn = vgui.Create("DImageButton", eq_frame)
			invAmmoBtn:SetPos( btnWPos,btnHPos )
			invAmmoBtn:SetSize(30,30)
			invAmmoBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
			invAmmoBtn.DoClick = function() 
				if AmmoListView:GetSelectedLine() then
					local ammoID = "ammo_"..AmmoListView:GetLine(AmmoListView:GetSelectedLine()):GetValue(1)
					RunConsoleCommand("pnrp_addtoinvfromceq-ammo",ammoID)
					eq_frame:Close()
				end
			end
			invAmmoBtn.Paint = function()
				if invAmmoBtn:IsDown() then 
					invAmmoBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
				else
					invAmmoBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				end
			end	
		local invAmmoBtnLbl = vgui.Create("DLabel", eq_frame)
			invAmmoBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
			invAmmoBtnLbl:SetColor( lblColor )
			invAmmoBtnLbl:SetText( "Inventory" )
			invAmmoBtnLbl:SetFont("Trebuchet24")
			invAmmoBtnLbl:SizeToContents()
					
		if foundCar then		
			btnHPos = btnHPos + btnHeight	
			local ammoToCarBtn = vgui.Create("DImageButton", eq_frame)
				ammoToCarBtn:SetPos( btnWPos,btnHPos )
				ammoToCarBtn:SetSize(30,30)
				ammoToCarBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				ammoToCarBtn.DoClick = function() 
					if AmmoListView:GetSelectedLine() then
						local ammoID = "ammo_"..AmmoListView:GetLine(AmmoListView:GetSelectedLine()):GetValue(1)
						local weight = CarWeight + PNRP.Items[ammoID].Weight
						
						if weight <= CarWeightCap then
							
							--datastream.StreamToServer( "pnrp_addtocarinentory", { "FromEQ", ammoID, 1  } )
							net.Start( "pnrp_addtocarinentory" )
								net.WriteEntity(ply)
								net.WriteString("FromEQ")
								net.WriteString(ammoID)
								net.WriteDouble(1)
							net.SendToServer()
							RunConsoleCommand("pnrp_stripAmmo",ammoID)
							eq_frame:Close()
						else
							eq_frame:Close()
							ply:ChatPrint("You're car trunk is full.")
						end	
					end
				end
				ammoToCarBtn.Paint = function()
					if ammoToCarBtn:IsDown() then 
						ammoToCarBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						ammoToCarBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end	
			local ammoToCarBtnLbl = vgui.Create("DLabel", eq_frame)
				ammoToCarBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				ammoToCarBtnLbl:SetColor( lblColor )
				ammoToCarBtnLbl:SetText( "Car Inventory" )
				ammoToCarBtnLbl:SetFont("Trebuchet24")
				ammoToCarBtnLbl:SizeToContents()	
		end
end
net.Receive( "pnrp_OpenEquipmentWindow", GM.EquipmentWindow)

function GM.BackpackWindow()
	local ply = net.ReadEntity() 
	local bkEnt = net.ReadEntity() 
	local MyWeight = net.ReadFloat()
	local MyWeightCap = net.ReadFloat()
	local contents = net.ReadTable()
	
	local data = {}
	data.res = {}
	data.items = {}
	data.ammo = {}
	
	local pack_frame = vgui.Create( "DFrame" )
		pack_frame:SetSize( 585, 289 ) --Set the size
		pack_frame:SetPos(ScrW() / 2 - pack_frame:GetWide() / 2, ScrH() / 2 - pack_frame:GetTall() / 2) 
		pack_frame:SetTitle( "" ) --Set title
		pack_frame:SetVisible( true )
		pack_frame:SetDraggable( true )
		pack_frame:ShowCloseButton( true )
		pack_frame:MakePopup()
		pack_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", pack_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_6b.png" )
			screenBG:SetSize(pack_frame:GetWide(), pack_frame:GetTall())	
			
		local funnyLbl = vgui.Create("DLabel", pack_frame)
			funnyLbl:SetPos( 40,2 )
			funnyLbl:SetColor( Color( 245, 218, 210, 180 ) )
			funnyLbl:SetText( "End of the world device (aka Poof Device or Bee Hive)" )
			funnyLbl:SetFont("Trebuchet24")
			funnyLbl:SizeToContents()	
				
		local ResListView = vgui.Create( "DListView", pack_frame )
			ResListView:SetPos( pack_frame:GetWide() - 205, 40 )
			ResListView:SetSize( 155, 100 )
			ResListView:SetMultiSelect( false ) -- <removed sarcastic and useless comment>
			ResListView:AddColumn("Resource")
			ResListView:AddColumn("Amount")
			ResListView.Paint = function() -- Paint function
				surface.SetDrawColor( 180, 180, 180, 80 )
			end
			for res, v in pairs( contents.res ) do
				if res == "scrap" then res = "Scrap" end
				if res == "small" then res = "Small Parts" end
				if res == "chems" then res = "Chemicals" end
				ResListView:AddLine( res, v )
			end		
			
		local pkPanel = vgui.Create( "DPanel", pack_frame )
				pkPanel:SetPos(30, 40)
				pkPanel:SetSize(pack_frame:GetWide() - 275, pack_frame:GetTall() - 80)
				pkPanel.Paint = function() -- Paint function
				--	surface.SetDrawColor( 52, 54, 59, 255 )
				--	surface.DrawRect( 0, 0, pkPanel:GetWide(), pkPanel:GetTall() ) -- Draw the rect
				end
			local Scroller = vgui.Create("DHorizontalScroller", pkPanel) --Create the scroller
			Scroller:SetSize(pkPanel:GetWide()-8, pkPanel:GetTall() - 10)
			Scroller:AlignBottom(5)
			Scroller:AlignLeft(4)
			Scroller:SetOverlap(-1) --Set how much to overlap, negative numbers will space out the panels.
			
			--//Items
			for k, v in pairs(contents.inv) do
				local item = PNRP.Items[k]
				if item then
					local pnlPanel = vgui.Create("DPanel", Scroller)
						pnlPanel:SetSize( 75, pkPanel:GetTall() - 20 )
						pnlPanel.Paint = function()
							draw.RoundedBox( 6, 0, 0, pnlPanel:GetWide(), pnlPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
						end
						
						pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
						pnlPanel.Icon:SetModel(item.Model)
						pnlPanel.Icon:SetPos(pnlPanel:GetWide() / 2 - pnlPanel.Icon:GetWide() / 2, 5 )
						pnlPanel.Icon:SetToolTip( nil )
						pnlPanel.Icon.DoClick = function()
							data.items = { k, 1 }
							remFromPack( ply, data, "singledrop", bkEnt )
							pack_frame:Close() 
						end
						pnlPanel.Name = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.Name:SetPos(5, 80)
						pnlPanel.Name:SetText(item.Name)
						pnlPanel.Name:SetColor(Color( 0, 0, 0, 255 ))
						pnlPanel.Name:SizeToContents() 
					--	pnlPanel.Name:SetContentAlignment( 5 )
						
						pnlPanel.Count = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.Count:SetPos(5, 105)
						pnlPanel.Count:SetText("Count: "..v)
						pnlPanel.Count:SetColor(Color( 0, 0, 0, 255 ))
						pnlPanel.Count:SizeToContents() 
					--	pnlPanel.Count:SetContentAlignment( 5 )
						
						pnlPanel.equipBtn = vgui.Create("DButton", pnlPanel )
						pnlPanel.equipBtn:SetPos(5, 125)
						pnlPanel.equipBtn:SetSize(pnlPanel:GetWide() - 10,18)
						pnlPanel.equipBtn:SetText( "Equip" )
						pnlPanel.equipBtn.DoClick = function()
							data.items = { k, 1 }
							remFromPack( ply, data, "singleeq", bkEnt )
							pack_frame:Close() 
						end
						
						pnlPanel.NumberWang = vgui.Create( "DNumberWang", pnlPanel )
						pnlPanel.NumberWang:SetPos(pnlPanel:GetWide() / 2 - pnlPanel.NumberWang:GetWide() / 2, 150 )
						pnlPanel.NumberWang:SetMin( 1 )
						pnlPanel.NumberWang:SetMax( v )
						pnlPanel.NumberWang:SetDecimals( 0 )
						pnlPanel.NumberWang:SetValue( 1 )
						
						pnlPanel.sendToInv = vgui.Create("DButton", pnlPanel )
						pnlPanel.sendToInv:SetPos(5, 170)
						pnlPanel.sendToInv:SetSize(pnlPanel:GetWide() - 10,18)
						pnlPanel.sendToInv:SetText( ">>Inv" )
						pnlPanel.sendToInv.DoClick = function()
							local getCount = pnlPanel.NumberWang:GetValue()
							if getCount > v then getCount = v end
							local weight = MyWeight + (item.Weight * getCount)
							
							if weight <= MyWeightCap then
								data.items = { k, getCount }
								remFromPack( ply, data, "singleinv", bkEnt )
								pack_frame:Close() 
							else
								ply:ChatPrint("You're pack is full.")
							end
							pack_frame:Close()
							
						end	
						
						Scroller:AddPanel(pnlPanel)
				end
			end
			
			--//Ammo
			for k, v in pairs(contents.ammo) do
				itemID = "ammo_"..k
				Msg(itemID.."\n")
				local item = PNRP.Items[itemID]
				if item then
					local pnlPanel = vgui.Create("DPanel", Scroller)
						pnlPanel:SetSize( 75, pkPanel:GetTall() - 20 )
						pnlPanel.Paint = function()
							draw.RoundedBox( 6, 0, 0, pnlPanel:GetWide(), pnlPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
						end
						
						pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
						pnlPanel.Icon:SetModel(item.Model)
						pnlPanel.Icon:SetPos(pnlPanel:GetWide() / 2 - pnlPanel.Icon:GetWide() / 2, 5 )
						pnlPanel.Icon:SetToolTip( nil )
						pnlPanel.Icon.DoClick = function()
							data.ammo = { k, v }
							remFromPack( ply, data, "singledrop", bkEnt )
							pack_frame:Close() 
						end
						pnlPanel.Name = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.Name:SetPos(5, 80)
						pnlPanel.Name:SetText(item.Name)
						pnlPanel.Name:SetColor(Color( 0, 0, 0, 255 ))
						pnlPanel.Name:SizeToContents() 
						pnlPanel.Name:SetContentAlignment( 5 )
						
						pnlPanel.Count = vgui.Create("DLabel", pnlPanel)		
						pnlPanel.Count:SetPos(5, 105)
						pnlPanel.Count:SetText("Count: "..v)
						pnlPanel.Count:SetColor(Color( 0, 0, 0, 255 ))
						pnlPanel.Count:SizeToContents() 
						pnlPanel.Count:SetContentAlignment( 5 )
						
						pnlPanel.equipBtn = vgui.Create("DButton", pnlPanel )
						pnlPanel.equipBtn:SetPos(5, 125)
						pnlPanel.equipBtn:SetSize(pnlPanel:GetWide() - 10,18)
						pnlPanel.equipBtn:SetText( "Equip" )
						pnlPanel.equipBtn.DoClick = function()
							data.ammo = { k, v }
							remFromPack( ply, data, "singleeq", bkEnt )
							pack_frame:Close() 
						end
						
						pnlPanel.sendToInv = vgui.Create("DButton", pnlPanel )
						pnlPanel.sendToInv:SetPos(5, 143)
						pnlPanel.sendToInv:SetSize(pnlPanel:GetWide() - 10,18)
						pnlPanel.sendToInv:SetText( ">>Inv" )
						pnlPanel.sendToInv.DoClick = function()
							data.ammo = { k, v }
							remFromPack( ply, data, "singleinv", bkEnt )
							pack_frame:Close() 
						end	
						
						Scroller:AddPanel(pnlPanel)
				end	
			end
									
			--//Menu	
			local btnHPos = 170
			local btnWPos = pack_frame:GetWide()-220
			local btnHeight = 35
			local lblColor = Color( 245, 218, 210, 180 )
			
			local takeResBtn = vgui.Create("DImageButton", pack_frame)
				takeResBtn:SetPos( btnWPos,btnHPos )
				takeResBtn:SetSize(30,30)
				takeResBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				takeResBtn.DoClick = function() 
					remFromPack( ply, data, "takeres", bkEnt )
					pack_frame:Close() 
				end
				takeResBtn.Paint = function()
					if takeResBtn:IsDown() then 
						takeResBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						takeResBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end	
			local takeResBtnLbl = vgui.Create("DLabel", pack_frame)
				takeResBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				takeResBtnLbl:SetColor( lblColor )
				takeResBtnLbl:SetText( "Take Resources" )
				takeResBtnLbl:SetFont("Trebuchet24")
				takeResBtnLbl:SizeToContents()	
			
			btnHPos = btnHPos + btnHeight
			local eqAllBtn = vgui.Create("DImageButton", pack_frame)
				eqAllBtn:SetPos( btnWPos,btnHPos )
				eqAllBtn:SetSize(30,30)
				eqAllBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				eqAllBtn.DoClick = function() 
					remFromPack( ply, data, "equipall", bkEnt )
					pack_frame:Close() 
				end
				eqAllBtn.Paint = function()
					if eqAllBtn:IsDown() then 
						eqAllBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						eqAllBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end	
			local eqAllBtnLbl = vgui.Create("DLabel", pack_frame)
				eqAllBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				eqAllBtnLbl:SetColor( lblColor )
				eqAllBtnLbl:SetText( "Equip All" )
				eqAllBtnLbl:SetFont("Trebuchet24")
				eqAllBtnLbl:SizeToContents()
				
			btnHPos = btnHPos + btnHeight	
			local takeAllBtn = vgui.Create("DImageButton", pack_frame)
				takeAllBtn:SetPos( btnWPos,btnHPos )
				takeAllBtn:SetSize(30,30)
				takeAllBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				takeAllBtn.DoClick = function() 
					remFromPack( ply, data, "takeall", bkEnt )
					pack_frame:Close() 
				end
				takeAllBtn.Paint = function()
					if takeAllBtn:IsDown() then 
						takeAllBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						takeAllBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end	
			local takeAllBtnLbl = vgui.Create("DLabel", pack_frame)
				takeAllBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				takeAllBtnLbl:SetColor( lblColor )
				takeAllBtnLbl:SetText( "Take All" )
				takeAllBtnLbl:SetFont("Trebuchet24")
				takeAllBtnLbl:SizeToContents()			
end
net.Receive( "pnrp_OpenBackpackWindow", GM.BackpackWindow)

function remFromPack( ply, data, option, bkEnt )
--	data.res = {}
--	data.items = {}
--	data.ammo = {}
	net.Start( "pnrp_RemoveFromPack" )
		net.WriteEntity(ply)
		net.WriteEntity(bkEnt)
		net.WriteTable(data)
		net.WriteString(option) --singledrop, singleeq, singleinv, equipall, takeall, takeres
	net.SendToServer()

end

function checkGren(ply, weapon)
	if weapon:GetClass() == "weapon_frag" then
		if ply:GetAmmoCount( weapon:GetPrimaryAmmoType() ) <= 0 then
			return false
		end
	end
	if weapon:GetClass() == "weapon_pnrp_charge" then
		if ply:GetAmmoCount( weapon:GetPrimaryAmmoType() ) <= 0 then
			return false
		end
	end	
	
	return true
end

function GM.initEquipment(ply)

	RunConsoleCommand("pnrp_initEQ")

end
concommand.Add( "pnrp_eqipment", GM.initEquipment )

local tShopIntFrame
function GM.TShopInterface()
	local ply = net.ReadEntity() 
	local ToolEnt = net.ReadEntity()
	local ItemTable = net.ReadTable()
	
	tShopIntFrame = vgui.Create( "DFrame" )
		tShopIntFrame:SetSize( 710, 520 ) --Set the size
		tShopIntFrame:SetPos(ScrW() / 2 - tShopIntFrame:GetWide() / 2, ScrH() / 2 - tShopIntFrame:GetTall() / 2)
		tShopIntFrame:SetTitle( "" ) --Set title
		tShopIntFrame:SetVisible( true )
		tShopIntFrame:SetDraggable( true )
		tShopIntFrame:ShowCloseButton( true )
		tShopIntFrame:MakePopup()
		tShopIntFrame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", tShopIntFrame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_2b.png" )
			screenBG:SetKeepAspect()
			screenBG:SizeToContents()
			screenBG:SetSize(tShopIntFrame:GetWide(), tShopIntFrame:GetTall())
			
		local tool = PNRP.Items[PNRP.FindItemID(ToolEnt:GetClass())]
		local ToolName = vgui.Create( "DLabel", tShopIntFrame )
			ToolName:SetPos(60,40)
			ToolName:SetColor(Color( 255, 255, 255, 255 ))
			ToolName:SetText( tool.Name )
			ToolName:SizeToContents()	
		local ToolDesc = vgui.Create( "DLabel", tShopIntFrame )
			ToolDesc:SetPos(60,50)
			ToolDesc:SetColor(Color( 255, 255, 255, 255 ))
			ToolDesc:SetText( tool.Info )
			ToolDesc:SizeToContents()	
			
		local pnlList = vgui.Create("DPanelList", tShopIntFrame)
			pnlList:SetPos(40, 70)
			pnlList:SetSize(tShopIntFrame:GetWide() - 85, tShopIntFrame:GetTall() - 120)
			pnlList:EnableVerticalScrollbar(true) 
			pnlList:EnableHorizontal(false) 
			pnlList:SetSpacing(1)
			pnlList:SetPadding(10)
			
			for _, v in pairs(ItemTable) do
				if PNRP.Items[v] then
					local item = PNRP.Items[v] 
					
					local neededParts = item.ToolCheck( )
					local partsText = nil
					if type(neededParts) == "table" then
						partsText = "Needed Parts: \n--------------------"
						for p, n in pairs(neededParts) do
							if PNRP.Items[p] then
								partsText = partsText.."\n"..PNRP.Items[p].Name.." : "..tostring(n)
							end
						end
					end
					
					local pnlPanel = vgui.Create("DPanel")
					pnlPanel:SetTall(75)
					pnlPanel.Paint = function()
						draw.RoundedBox( 6, 0, 0, pnlPanel:GetWide(), pnlPanel:GetTall(), Color( 180, 180, 180, 80 ) )		
					end
					pnlList:AddItem(pnlPanel)
					
					pnlPanel.Icon = vgui.Create("SpawnIcon", pnlPanel)
						pnlPanel.Icon:SetModel(item.Model)
						pnlPanel.Icon:SetPos(3, 5)
						pnlPanel.Icon:SetToolTip( partsText )
						pnlPanel.Icon.DoClick = function()
								RunConsoleCommand("pnrp_buildItem", v)
								tShopIntFrame:Close()
						end	
						
					pnlPanel.Title = vgui.Create("DLabel", pnlPanel)
					pnlPanel.Title:SetPos(90, 5)
					pnlPanel.Title:SetText(item.Name)
					pnlPanel.Title:SetColor(Color( 0, 0, 0, 255 ))
					pnlPanel.Title:SizeToContents() 
					pnlPanel.Title:SetContentAlignment( 5 )	
					
					if ply:Team() == TEAM_ENGINEER then
						if item.Scrap != nil then sc = math.ceil( item.Scrap * (1 - (0.02 * ply:GetSkill("Construction"))))  else sc = 0 end
						if item.SmallParts != nil then sp = math.ceil(item.SmallParts * (1 - (0.02 * ply:GetSkill("Construction")))) else sp = 0 end
						if item.Chemicals != nil then ch = math.ceil(item.Chemicals * (1 - (0.02 * ply:GetSkill("Construction")))) else ch = 0 end
					else
						if item.Scrap != nil then sc = item.Scrap else sc = 0 end
						if item.SmallParts != nil then sp =item.SmallParts else sp = 0 end
						if item.Chemicals != nil then ch = item.Chemicals else ch = 0 end
					end
					
					pnlPanel.Cost = vgui.Create("DLabel", pnlPanel)		
					pnlPanel.Cost:SetPos(90, 55)
					pnlPanel.Cost:SetText("Cost: Scrap "..tostring(sc).." | Small Parts "..tostring(sp).." | Chemicals "..tostring(ch))
					pnlPanel.Cost:SetColor(Color( 0, 0, 0, 255 ))
					pnlPanel.Cost:SizeToContents() 
					pnlPanel.Cost:SetContentAlignment( 5 )	
					
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
					pnlPanel.bulkSlider:SetPos(400, 30)
					pnlPanel.bulkSlider:SetSize( 75, 40 ) 
					pnlPanel.bulkSlider:SetText( " " )
					pnlPanel.bulkSlider:SetMin( 1 )
					pnlPanel.bulkSlider:SetMax( 100 )
					pnlPanel.bulkSlider:SetDecimals( 0 )
					pnlPanel.bulkSlider:SetValue( 1 )
					
					pnlPanel.BulkBtn = vgui.Create("DButton", pnlPanel )
					pnlPanel.BulkBtn:SetPos(485, 30)
					pnlPanel.BulkBtn:SetSize(80,17)
					pnlPanel.BulkBtn:SetText( "Create Bulk" )
					pnlPanel.BulkBtn.DoClick = function() 
						net.Start("SpawnBulkCrate")
							net.WriteEntity(ply)
							net.WriteString(itemname)
							net.WriteDouble(pnlPanel.bulkSlider:GetValue())
						net.SendToServer()
						tShopIntFrame:Close()
					end
				end
			end
end
net.Receive( "pnrp_OpenTShopInterface", GM.TShopInterface)




--EOF