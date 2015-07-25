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
			if tostring(v:GetNetVar( "Owner" , "None" )) == ply:Nick() && myType == "vehicle" then
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

--local eq_frame
--local eqFrameOpen = false
function GM.EquipmentWindow( )
--	if eqFrameOpen then return end 
	
	eq_frame = PNRP.PNRP_Frame()
	if not eq_frame then return end

	local ply = net.ReadEntity() 
	local MyWeight = tonumber(net.ReadString())
	local MyWeightCap = net.ReadFloat()
	local CarItemID
	local CarWeightCap
	local maxAmmo = 0	
	PNRP.RMDerma()
	
--	eq_frame = vgui.Create( "DFrame" )
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
		PNRP.AddMenu(eq_frame)
		
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
		
		--Ammo Section
					
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
			
		local ammoSlide = vgui.Create( "DNumSlider", eq_frame )
			ammoSlide:SetWide( 250 )
			ammoSlide:SetPos( eq_frame:GetWide() - 290, AmmoListView:GetTall() + 35 )
			ammoSlide:SetText( "" )
			ammoSlide:SetDecimals( 0 )
			ammoSlide:SetMin( 0 )
			ammoSlide:SetMax( maxAmmo )
			ammoSlide:SetValue( 0 )
			ammoSlide.Paint = function() -- Paint function
				surface.SetDrawColor( 255, 255, 255, 255 )
			end
		local ammoSlideLabel = vgui.Create("DLabel", eq_frame)		
			ammoSlideLabel:SetPos(eq_frame:GetWide() - 205, AmmoListView:GetTall() + 45)
			ammoSlideLabel:SetText("Amount")
			ammoSlideLabel:SetColor(Color( 255, 255, 255, 255 ))
			ammoSlideLabel:SizeToContents() 
			ammoSlideLabel:SetContentAlignment( 5 )
			
			--Resize Max Ammo
			AmmoListView.OnRowSelected = function()
				local newMaxAmmo = tonumber(AmmoListView:GetLine(AmmoListView:GetSelectedLine()):GetValue(2))
				ammoSlide:SetMax( newMaxAmmo )
				ammoSlide:SetValue( 0 )
			end
			
			--Weapons
			for k, v in pairs(ply:GetWeapons()) do
			--	local wepCheck = CheckDefWeps(v)
			--	if !wepCheck then

				if string.lower(v:GetModel()) == "models/weapons/v_hands.mdl" and string.lower(v:GetClass()) ~= "weapon_radio" then
					--Do Nothing
				else
					
					if PNRP.FindWepItem(v:GetModel()) and checkGren(ply, v) or string.lower(v:GetClass()) == "weapon_radio" then
						local myItem
						if string.lower(v:GetClass()) == "weapon_radio" then
						--	myItem = PNRP.FindItemID( v:GetClass() )
							myItem = PNRP.Items["wep_radio"]
						else
							myItem = PNRP.FindWepItem( v:GetModel() )
						end

						local pnlPanel = vgui.Create("DPanel", Scroller)
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
								--	RunConsoleCommand("pnrp_addtoinvfromeq",myItem.ID,v:GetClass())
									net.Start( "pnrp_addtoinvfromeq" )
										net.WriteEntity(ply)
										net.WriteString("pnrp_addtoinvfromeq")
										net.WriteString(myItem.ID)
									net.SendToServer()
									RunConsoleCommand("pnrp_stripWep",v:GetClass())
								else
									ply:ChatPrint("Your pack is full.")
								end
								eq_frame:Close()
								
							end	
							
							Scroller:AddPanel(pnlPanel)
					end
				end
			end
		
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
					ammoAMT = math.Round(ammoAMT)
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
				--	RunConsoleCommand("pnrp_addtoinvfromceq-ammo",ammoID)
					net.Start( "pnrp_addtoinvfromeq" )
						net.WriteEntity(ply)
						net.WriteString("pnrp_addtoinvfromceq-ammo")
						net.WriteString(ammoID)
					net.SendToServer()
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
						local ammoTypeSel = AmmoListView:GetLine(AmmoListView:GetSelectedLine()):GetValue(1)
						local ammoID = "ammo_"..ammoTypeSel
						local weight = CarWeight + PNRP.Items[ammoID].Weight
						if ply:GetAmmoCount(ammoTypeSel) < PNRP.Items[ammoID].Energy then
							ply:ChatPrint("Can only put full clips in inventory.")
						else
							if weight <= CarWeightCap then
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
								ply:ChatPrint("Your car trunk is full.")
							end								
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
--[[
	function eq_frame:Close()                  
		eqFrameOpen = false                  
		self:SetVisible( false )                  
		self:Remove()          
	end 
]]--
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
	
	PNRP.RMDerma()
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
		PNRP.AddMenu(menu)
		
		local screenBG = vgui.Create("DImage", pack_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_6b.png" )
			screenBG:SetSize(pack_frame:GetWide(), pack_frame:GetTall())	
			
	--	local funnyLbl = vgui.Create("DLabel", pack_frame)
	--		funnyLbl:SetPos( 40,2 )
	--		funnyLbl:SetColor( Color( 245, 218, 210, 180 ) )
	--		funnyLbl:SetText( "End of the world device (aka Poof Device or Bee Hive)" )
	--		funnyLbl:SetFont("Trebuchet24")
	--		funnyLbl:SizeToContents()	
		
		local ownerLbl = vgui.Create("DLabel", pack_frame)
			ownerLbl:SetPos( 40,2 )
			ownerLbl:SetColor( Color( 245, 218, 210, 180 ) )
			ownerLbl:SetText( "" )
			ownerLbl:SetFont("Trebuchet24")
			ownerLbl:SizeToContents()
		
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
							if getCount < 0 then getCount = 0 end
							if getCount > v then getCount = v end
							local weight = MyWeight + (item.Weight * getCount)
							
							if weight <= MyWeightCap then
								data.items = { k, getCount }
								remFromPack( ply, data, "singleinv", bkEnt )
								pack_frame:Close() 
							else
								ply:ChatPrint("Your pack is full.")
							end
							pack_frame:Close()
							
						end	
						
						Scroller:AddPanel(pnlPanel)
				end
			end
			
			--//Ammo
			for k, v in pairs(contents.ammo) do
				itemID = "ammo_"..k
			--	Msg(itemID.."\n")
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
	PNRP.RMDerma()
	local textColor = Color(200,200,200,255)
	
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
		PNRP.AddMenu(tShopIntFrame)
		
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
					local override = false
					
					if (item.AllHide == true and not (ply:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1)) and not override then
						--do nothing
					else
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
						pnlPanel.bulkSlider:SetPos(300, 45)
						pnlPanel.bulkSlider:SetWide( 300 ) 
						pnlPanel.bulkSlider:SetText( " " )
						pnlPanel.bulkSlider:SetDecimals( 0 )
						pnlPanel.bulkSlider:SetMin( 1 )
						pnlPanel.bulkSlider:SetMax( 100 )
						pnlPanel.bulkSlider:SetValue( 1 )
						pnlPanel.bulkSlider.Label:SetColor(textColor)
						pnlPanel.bulkSlider:SetBGColor(textColor)
						
						pnlPanel.BulkBtn = vgui.Create("DButton", pnlPanel )
						pnlPanel.BulkBtn:SetPos(485, 30)
						pnlPanel.BulkBtn:SetSize(80,17)
						pnlPanel.BulkBtn:SetText( "Create Bulk" )
						pnlPanel.BulkBtn.DoClick = function() 
							net.Start("SpawnBulkCrate")
								net.WriteEntity(ply)
								net.WriteString(item.ID)
								net.WriteDouble(math.Round(pnlPanel.bulkSlider:GetValue()))
							net.SendToServer()
							tShopIntFrame:Close()
						end
					end
				end
			end
end
net.Receive( "pnrp_OpenTShopInterface", GM.TShopInterface)

function playerEQ2()
	EQ2_frame = PNRP.PNRP_Frame()
	if not EQ2_frame then return end
	
	local ply = LocalPlayer()
	
	local melee = "wep_knife"
	local side = "wep_p228"
	local primary = "wep_saw"
	local secondary = "wep_smg"
	local emty = "models/props_c17/streetsign004f.mdl"
	
	local belt = {}
		belt["wep_radio"] = 1
		belt["wep_turretprog"] = 1
		belt["wep_grenade"] = 40
		belt["wep_flaregun"] = 1
		belt["wep_shapedcharge"] = 4	
	
	EQ2_frame:SetSize( 710, 510 ) --Set the size Extra 40 must be from the top bar
	--Set the window in the middle of the players screen/game window
	EQ2_frame:SetPos(ScrW() / 2 - EQ2_frame:GetWide() / 2, ScrH() / 2 - EQ2_frame:GetTall() / 2) 
	EQ2_frame:SetTitle( "Player Info" ) --Set title
	EQ2_frame:SetVisible( true )
	EQ2_frame:SetDraggable( true )
	EQ2_frame:ShowCloseButton( true )
	EQ2_frame:MakePopup()
	EQ2_frame.Paint = function() 
		surface.SetDrawColor( 50, 50, 50, 0 )
	end
	
	local screenBG = vgui.Create("DImage", EQ2_frame)
		screenBG:SetImage( "VGUI/gfx/pnrp_screen_2b.png" )
		screenBG:SetSize(EQ2_frame:GetWide(), EQ2_frame:GetTall())
		
		local mdl = vgui.Create( "DModelPanel", EQ2_frame )
			mdl:SetSize( 250, 360 )
			mdl:SetPos(225,40)
			mdl.Angles = Angle( 0, 0, 0 )			
			mdl:SetFOV( 36 )
			mdl:SetCamPos( Vector( 0, 0, 0 ) )
			mdl:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
			mdl:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
			mdl:SetAmbientLight( Vector( -64, -64, -64 ) )
			mdl:SetAnimated( true )
			mdl:SetLookAt( Vector( -100, 0, -22 ) )
			
			mdl:SetModel( ply:GetModel() ) -- you can only change colors on playermodels
			function mdl.Entity:GetPlayerColor() return ply:GetPlayerColor() end
			
			mdl.Entity:SetPos( Vector( -80, 0, -55 ) )
		
			-- Hold to rotate
			function mdl:DragMousePress()
				self.PressX, self.PressY = gui.MousePos()
				self.Pressed = true
			end

			function mdl:DragMouseRelease() self.Pressed = false end

			function mdl:LayoutEntity( Entity )
			--	if ( self.bAnimated ) then self:RunAnimation() end

				if ( self.Pressed ) then
					local mx, my = gui.MousePos()
					self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )
					
					self.PressX, self.PressY = gui.MousePos()
				end

				Entity:SetAngles( self.Angles )
			end
			
	--Ammo Slots
		local ammoTitle = vgui.Create("DLabel", EQ2_frame)
			ammoTitle:SetPos(50, 100)
			ammoTitle:SetText("Ammo Slots")
			ammoTitle:SetColor(Color( 0, 255, 0, 255 ))
			ammoTitle:SetFont("HudHintTextLarge")
			ammoTitle:SizeToContents()
	
	--Side Arm
		local sY = 160
		local sX = 125
		local sideTitle = vgui.Create("DLabel", EQ2_frame)
			sideTitle:SetPos(sY+5, sX)
			sideTitle:SetText("Sidearm")
			sideTitle:SetColor(Color( 0, 255, 0, 255 ))
			sideTitle:SetFont("HudHintTextLarge")
			sideTitle:SizeToContents() 
		sX = sX + 20
		local pnlSidePanel = vgui.Create("DPanel", EQ2_frame)
			pnlSidePanel:SetPos( sY+10, sX )
			pnlSidePanel:SetSize( 85, 85 )
			pnlSidePanel.Paint = function()
				local GreenColor = 180
				draw.RoundedBox( 1, 0, 0, pnlSidePanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, pnlSidePanel:GetTall()-1, pnlSidePanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, 0, 1, pnlSidePanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, pnlSidePanel:GetWide()-1, 0, 1, pnlSidePanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
			end
		
		local sideItem = PNRP.Items[side]
		local sideModel = emty
		if sideItem then sideModel = sideItem.Model end
		local SpawnI = vgui.Create( "SpawnIcon" , pnlSidePanel ) -- SpawnIcon
			SpawnI:SetPos( 5, 5 )
			SpawnI:SetSize( 75, 75 )
			SpawnI:SetModel( sideModel )
	
	--Melee
		local mY = 160
		local mX = 250
		local meleeTitle = vgui.Create("DLabel", EQ2_frame)
			meleeTitle:SetPos(mY+5, mX)
			meleeTitle:SetText("Melee Weapon")
			meleeTitle:SetColor(Color( 0, 255, 0, 255 ))
			meleeTitle:SetFont("HudHintTextLarge")
			meleeTitle:SizeToContents() 
		mX = mX + 20
		local pnlMPanel = vgui.Create("DPanel", EQ2_frame)
			pnlMPanel:SetPos( mY+10, mX )
			pnlMPanel:SetSize( 85, 85 )
			pnlMPanel.Paint = function()
				local GreenColor = 180
				draw.RoundedBox( 1, 0, 0, pnlMPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, pnlMPanel:GetTall()-1, pnlMPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, 0, 1, pnlMPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, pnlMPanel:GetWide()-1, 0, 1, pnlMPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
			end
		
		local meleeItem = PNRP.Items[melee]
		local meleeModel = emty
		if meleeItem then meleeModel = meleeItem.Model end
		local SpawnI = vgui.Create( "SpawnIcon" , pnlMPanel ) -- SpawnIcon
			SpawnI:SetPos( 5, 5 )
			SpawnI:SetSize( 75, 75 )
			SpawnI:SetModel( meleeModel )
	
	--Primary Weapon
		local pY = 450
		local pX = 125
		local primaryTitle = vgui.Create("DLabel", EQ2_frame)
			primaryTitle:SetPos(pY+5, pX)
			primaryTitle:SetText("Primary Weapon")
			primaryTitle:SetColor(Color( 0, 255, 0, 255 ))
			primaryTitle:SetFont("HudHintTextLarge")
			primaryTitle:SizeToContents() 
		pX = pX + 20
		local pnlPPanel = vgui.Create("DPanel", EQ2_frame)
			pnlPPanel:SetPos( pY+10, pX )
			pnlPPanel:SetSize( 85, 85 )
			pnlPPanel.Paint = function()
				local GreenColor = 180
				draw.RoundedBox( 1, 0, 0, pnlPPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, pnlPPanel:GetTall()-1, pnlPPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, 0, 1, pnlPPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, pnlPPanel:GetWide()-1, 0, 1, pnlPPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
			end
		
		local primaryItem = PNRP.Items[primary]
		local primaryModel = emty
		if primaryItem then primaryModel = primaryItem.Model end
		local SpawnI = vgui.Create( "SpawnIcon" , pnlPPanel ) -- SpawnIcon
			SpawnI:SetPos( 5, 5 )
			SpawnI:SetSize( 75, 75 )
			SpawnI:SetModel( primaryModel )
	
	--Secondary Weapon
		local secY = 450
		local secX = 250
		local secondaryTitle = vgui.Create("DLabel", EQ2_frame)
			secondaryTitle:SetPos(secY+5, secX)
			secondaryTitle:SetText("Secondary Weapon")
			secondaryTitle:SetColor(Color( 0, 255, 0, 255 ))
			secondaryTitle:SetFont("HudHintTextLarge")
			secondaryTitle:SizeToContents() 
		secX = secX + 20
		local pnlSecPanel = vgui.Create("DPanel", EQ2_frame)
			pnlSecPanel:SetPos( secY+10, secX )
			pnlSecPanel:SetSize( 85, 85 )
			pnlSecPanel.Paint = function()
				local GreenColor = 180
				draw.RoundedBox( 1, 0, 0, pnlSecPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, pnlSecPanel:GetTall()-1, pnlSecPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, 0, 1, pnlSecPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, pnlSecPanel:GetWide()-1, 0, 1, pnlSecPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
			end
		
		local secondaryItem = PNRP.Items[secondary]
		local secondaryModel = emty
		if secondaryItem then secondaryModel = secondaryItem.Model end
		local SpawnI = vgui.Create( "SpawnIcon" , pnlSecPanel ) -- SpawnIcon
			SpawnI:SetPos( 5, 5 )
			SpawnI:SetSize( 75, 75 )
			SpawnI:SetModel( secondaryModel )
	
	--Belt Items
		local pnlBeltPanel = vgui.Create("DPanel", EQ2_frame)
			pnlBeltPanel:SetPos( 100, 405 )
			pnlBeltPanel:SetSize( 500, 55 )
			pnlBeltPanel.Paint = function()
				local GreenColor = 180
				draw.RoundedBox( 1, 0, 0, pnlBeltPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, pnlBeltPanel:GetTall()-1, pnlBeltPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, 0, 1, pnlBeltPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, pnlBeltPanel:GetWide()-1, 0, 1, pnlBeltPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
			end
			
		local BeltScroller = vgui.Create("DHorizontalScroller", pnlBeltPanel) --Create the scroller
			BeltScroller:SetSize(pnlBeltPanel:GetWide(), pnlBeltPanel:GetTall())
			BeltScroller:AlignTop(0)
			BeltScroller:AlignLeft(0)
			BeltScroller:SetOverlap(-1)
			
			for k, v in pairs(belt) do
				local beltItem = PNRP.Items[k]
				local pnlBPanel = vgui.Create("DPanel", BeltScroller)
				pnlBPanel:SetSize( 50,50 )
				pnlBPanel.Paint = function() end
				
				local beltIcon = vgui.Create( "SpawnIcon", pnlBPanel )
					beltIcon:SetSize( pnlBPanel:GetWide(), pnlBPanel:GetTall() )
					beltIcon:SetModel( beltItem.Model )
					beltIcon:SetToolTip( beltItem.Name )
					beltIcon.DoClick = function() end
				BeltScroller:AddPanel(pnlBPanel)
			end
end

function playerEQ3()
	EQ2_frame = PNRP.PNRP_Frame()
	if not EQ2_frame then return end
	
	local ply = LocalPlayer()
	
	EQ2_frame:SetSize( 710, 510 ) --Set the size Extra 40 must be from the top bar
	--Set the window in the middle of the players screen/game window
	EQ2_frame:SetPos(ScrW() / 2 - EQ2_frame:GetWide() / 2, ScrH() / 2 - EQ2_frame:GetTall() / 2) 
	EQ2_frame:SetTitle( "Player Info" ) --Set title
	EQ2_frame:SetVisible( true )
	EQ2_frame:SetDraggable( true )
	EQ2_frame:ShowCloseButton( true )
	EQ2_frame:MakePopup()
	EQ2_frame.Paint = function() 
		surface.SetDrawColor( 50, 50, 50, 0 )
	end
	
	local screenBG = vgui.Create("DImage", EQ2_frame)
		screenBG:SetImage( "VGUI/gfx/pnrp_screen_2b.png" )
		screenBG:SetSize(EQ2_frame:GetWide(), EQ2_frame:GetTall())
		
		local mdl = vgui.Create( "DModelPanel", EQ2_frame )
			mdl:SetSize( 250, 360 )
			mdl:SetPos(225,75)
			mdl.Angles = Angle( 0, 0, 0 )			
			mdl:SetFOV( 36 )
			mdl:SetCamPos( Vector( 0, 0, 0 ) )
			mdl:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
			mdl:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
			mdl:SetAmbientLight( Vector( -64, -64, -64 ) )
			mdl:SetAnimated( true )
			mdl:SetLookAt( Vector( -100, 0, -22 ) )
			
			mdl:SetModel( ply:GetModel() ) -- you can only change colors on playermodels
			function mdl.Entity:GetPlayerColor() return ply:GetPlayerColor() end
			
			mdl.Entity:SetPos( Vector( -80, 0, -55 ) )
		
			-- Hold to rotate
			function mdl:DragMousePress()
				self.PressX, self.PressY = gui.MousePos()
				self.Pressed = true
			end

			function mdl:DragMouseRelease() self.Pressed = false end

			function mdl:LayoutEntity( Entity )
			--	if ( self.bAnimated ) then self:RunAnimation() end

				if ( self.Pressed ) then
					local mx, my = gui.MousePos()
					self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )
					
					self.PressX, self.PressY = gui.MousePos()
				end

				Entity:SetAngles( self.Angles )
			end
			
			
		local v3 = 50
		local y3 = 160
		local title = vgui.Create("DLabel", EQ2_frame)
			title:SetPos(y3, v3)
			title:SetText("Medium Ammo")
			title:SetColor(Color( 0, 255, 0, 255 ))
			title:SetFont("HudHintTextLarge")
			title:SizeToContents() 
		v3 = v3 + 20
		local pnlPanel = vgui.Create("DPanel", EQ2_frame)
			pnlPanel:SetPos( y3+10, v3 )
			pnlPanel:SetSize( 85, 85 )
			pnlPanel.Paint = function()
				local GreenColor = 180
				draw.RoundedBox( 1, 0, 0, pnlPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, pnlPanel:GetTall()-1, pnlPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, 0, 1, pnlPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, pnlPanel:GetWide()-1, 0, 1, pnlPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
			end
		local SpawnI = vgui.Create( "SpawnIcon" , pnlPanel ) -- SpawnIcon
			SpawnI:SetPos( 5, 5 )
			SpawnI:SetSize( 75, 75 )
			SpawnI:SetModel( "models/items/boxmrounds.mdl" )
		-----
		v3 = v3 + 100
		local title = vgui.Create("DLabel", EQ2_frame)
			title:SetPos(y3, v3)
			title:SetText("Small Ammo")
			title:SetColor(Color( 0, 255, 0, 255 ))
			title:SetFont("HudHintTextLarge")
			title:SizeToContents()
		v3 = v3 + 20
		local pnlPanel = vgui.Create("DPanel", EQ2_frame)
			pnlPanel:SetPos( y3+10, v3 )
			pnlPanel:SetSize( 85, 85 )
			pnlPanel.Paint = function()
				local GreenColor = 180
				draw.RoundedBox( 1, 0, 0, pnlPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, pnlPanel:GetTall()-1, pnlPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, 0, 1, pnlPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, pnlPanel:GetWide()-1, 0, 1, pnlPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
			end
		local SpawnI = vgui.Create( "SpawnIcon" , pnlPanel ) -- SpawnIcon
			SpawnI:SetPos( 5, 5 )
			SpawnI:SetSize( 75, 75 )
			SpawnI:SetModel( "models/items/boxsrounds.mdl" )
		-----
		v3 = v3 + 100
		local title = vgui.Create("DLabel", EQ2_frame)
			title:SetPos(y3+5, v3)
			title:SetText("Melee Weapon")
			title:SetColor(Color( 0, 255, 0, 255 ))
			title:SetFont("HudHintTextLarge")
			title:SizeToContents() 
		v3 = v3 + 20
		local pnlPanel = vgui.Create("DPanel", EQ2_frame)
			pnlPanel:SetPos( y3+10, v3 )
			pnlPanel:SetSize( 85, 85 )
			pnlPanel.Paint = function()
				local GreenColor = 180
				draw.RoundedBox( 1, 0, 0, pnlPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, pnlPanel:GetTall()-1, pnlPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, 0, 1, pnlPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, pnlPanel:GetWide()-1, 0, 1, pnlPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
			end
		local SpawnI = vgui.Create( "SpawnIcon" , pnlPanel ) -- SpawnIcon
			SpawnI:SetPos( 5, 5 )
			SpawnI:SetSize( 75, 75 )
			SpawnI:SetModel( "models/weapons/w_knife_t.mdl" )
-----------------------------		
		v3 = 50
		y3 = 450
		local title = vgui.Create("DLabel", EQ2_frame)
			title:SetPos(y3, v3)
			title:SetText("Primary Weapon")
			title:SetColor(Color( 0, 255, 0, 255 ))
			title:SetFont("HudHintTextLarge")
			title:SizeToContents() 
		v3 = v3 + 20
		local pnlPanel = vgui.Create("DPanel", EQ2_frame)
			pnlPanel:SetPos( y3+10, v3 )
			pnlPanel:SetSize( 85, 85 )
			pnlPanel.Paint = function()
				local GreenColor = 180
				draw.RoundedBox( 1, 0, 0, pnlPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, pnlPanel:GetTall()-1, pnlPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, 0, 1, pnlPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, pnlPanel:GetWide()-1, 0, 1, pnlPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
			end
		local SpawnI = vgui.Create( "SpawnIcon" , pnlPanel ) -- SpawnIcon
			SpawnI:SetPos( 5, 5 )
			SpawnI:SetSize( 75, 75 )
			SpawnI:SetModel( "models/weapons/w_mach_m249para.mdl" )
		-----
		v3 = v3 + 100
		local title = vgui.Create("DLabel", EQ2_frame)
			title:SetPos(y3-5, v3)
			title:SetText("Secondary Weapon")
			title:SetColor(Color( 0, 255, 0, 255 ))
			title:SetFont("HudHintTextLarge")
			title:SizeToContents()
		v3 = v3 + 20
		local pnlPanel = vgui.Create("DPanel", EQ2_frame)
			pnlPanel:SetPos( y3+10, v3 )
			pnlPanel:SetSize( 85, 85 )
			pnlPanel.Paint = function()
				local GreenColor = 180
				draw.RoundedBox( 1, 0, 0, pnlPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, pnlPanel:GetTall()-1, pnlPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, 0, 1, pnlPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, pnlPanel:GetWide()-1, 0, 1, pnlPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
			end
		local SpawnI = vgui.Create( "SpawnIcon" , pnlPanel ) -- SpawnIcon
			SpawnI:SetPos( 5, 5 )
			SpawnI:SetSize( 75, 75 )
			SpawnI:SetModel( "models/weapons/w_smg1.mdl" )
		-----
		v3 = v3 + 100
		local title = vgui.Create("DLabel", EQ2_frame)
			title:SetPos(y3+20, v3)
			title:SetText("Sidearm")
			title:SetColor(Color( 0, 255, 0, 255 ))
			title:SetFont("HudHintTextLarge")
			title:SizeToContents() 
		v3 = v3 + 20
		local pnlPanel = vgui.Create("DPanel", EQ2_frame)
			pnlPanel:SetPos( y3+10, v3 )
			pnlPanel:SetSize( 85, 85 )
			pnlPanel.Paint = function()
				local GreenColor = 180
				draw.RoundedBox( 1, 0, 0, pnlPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, pnlPanel:GetTall()-1, pnlPanel:GetWide(), 1, Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, 0, 0, 1, pnlPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
				draw.RoundedBox( 1, pnlPanel:GetWide()-1, 0, 1, pnlPanel:GetTall(), Color( 0, GreenColor, 0, 60 ) )
			end
		local SpawnI = vgui.Create( "SpawnIcon" , pnlPanel ) -- SpawnIcon
			SpawnI:SetPos( 5, 5 )
			SpawnI:SetSize( 75, 75 )
			SpawnI:SetModel( "models/weapons/w_pist_p228.mdl" )
end
concommand.Add( "pnrp_eq2",  playerEQ2 )


--EOF