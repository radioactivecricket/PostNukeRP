
--require("datastream")

local textColor =
	{
 
		shadow = Color( 90, 81, 28, 200 ),
		text = Color( 229, 198, 3, 255 )
 
	}

-- Not needed
-- local function SKOwnerPaint( )
	-- local trace = {}
	-- trace.start = LocalPlayer():GetShootPos()
	-- trace.endpos = trace.start + (LocalPlayer():GetAimVector() * 300)
	-- trace.filter = LocalPlayer()
	 
	-- tr = util.TraceLine(trace)
	-- local ent = tr.Entity
	
	-- if not ent then return end
	
	-- if ent:IsDoor() then
		-- local doorowner = ent:GetNWEntity( "ownerent", nil )
		
		-- if doorowner then
			-- surface.SetFont( "Trebuchet20" )
			-- local textw, texth = surface.GetTextSize("Owner:  "..doorowner:Nick())

			-- SKPaintRoundedPanel(6,(ScrW()/2)-((textw)/2)-5, (ScrH()/2)-((texth)/2)-5, textw+10 ,texth+10, Color( 0, 0, 0, 100 ) )
			-- SKPaintText( (ScrW()/2)-((textw)/2), (ScrH()/2)-((texth)/2), "Owner:  "..doorowner:Nick(), "Trebuchet20", textColor )
		-- else
			-- surface.SetFont( "Trebuchet20" )
			-- local textw, texth = surface.GetTextSize("Owner:  None")

			-- SKPaintRoundedPanel(6, (ScrW()/2)-((textw)/2)-5, (ScrH()/2)-((texth)/2)-5, textw+10 ,texth+10, Color( 0, 0, 0, 100 ) )
			-- SKPaintText( (ScrW()/2)-((textw)/2), (ScrH()/2)-((texth)/2), "Owner:  None", "Trebuchet20", textColor )
		-- end
	-- end
-- end
-- hook.Add( "HUDPaint", "SKPaintOwner", SKOwnerPaint )

-------------------------------------------
--	Menus
-------------------------------------------

--	Door Management
local function ManageDoor( )
	local door = net.ReadEntity()
	local doorCoowners = net.ReadTable()
	
	local item = PNRP.SearchItembase( door )
	local Title = "Door Management"
	local canRepair = false
	
	if item then 
		Title = item.Name.." Management"
		if item.CanRepair then canRepair = true end
	end
	
	local ply = LocalPlayer()
	local manage_frame = vgui.Create( "DFrame" )
	manage_frame:SetSize( 400, 300 )
	manage_frame:Center()
	manage_frame:SetTitle( Title )
	manage_frame:SetVisible( true )
	manage_frame:SetDraggable( true )
	manage_frame:ShowCloseButton( true )
	manage_frame:MakePopup()
	
	local found = false
	local PlyListView = vgui.Create( "DListView", manage_frame )
		PlyListView:SetPos( 20, 30 )
		PlyListView:SetSize( 125, 250 )
		PlyListView:SetMultiSelect( false ) -- <removed sarcastic and useless comment>
		PlyListView:AddColumn("Players")
		
		for k, v in pairs(player.GetAll()) do
			found = false
			if doorCoowners and doorCoowners[1] then
				for k2, v2 in pairs(doorCoowners) do
					if v == v2 then found = true end
				end
			end
			if v == ply then found = true end
			if not found and v then
				PlyListView:AddLine( v:GetName())
			end
		end
	
	local CoOwnerListView = vgui.Create( "DListView", manage_frame )
		CoOwnerListView:SetPos( 255, 30 )
		CoOwnerListView:SetSize( 125, 250 )
		CoOwnerListView:SetMultiSelect( false ) -- <removed sarcastic and useless comment>
		CoOwnerListView:AddColumn("Co-Owers")
		
		if doorCoowners and doorCoowners[1] then
			for k, v in pairs(doorCoowners) do
				if v and IsValid(v) then
					CoOwnerListView:AddLine( v:GetName())
				end
			end
		end
	
	local ReleaseBTN = vgui.Create("DButton", manage_frame )
		ReleaseBTN:SetText( "Unown" )
		ReleaseBTN:SetPos( 150, 250 )
		ReleaseBTN:SetSize(100, 25)
		ReleaseBTN.DoClick = function()
			--datastream.StreamToServer( "SKReleaseOwner", { ["doorEnt"] = door } )
			RunConsoleCommand("pnrp_removeowner")
			manage_frame:Close()
		end
		
	local AddCoownerBTN = vgui.Create("DButton", manage_frame )
		AddCoownerBTN:SetText( "Add Co-owner" )
		AddCoownerBTN:SetPos( 150, 30 )
		AddCoownerBTN:SetSize(100, 25)
		AddCoownerBTN.DoClick = function()

			if PlyListView:GetSelectedLine() then
				local plyValue = PlyListView:GetLine(PlyListView:GetSelectedLine()):GetValue(1)
				local newCoowner = nil
				
				for k, v in pairs(player.GetAll()) do
					if plyValue == v:GetName() then
						newCoowner = v
					end
				end
				
				if newCoowner then
					net.Start("SKAddCoowner")
						net.WriteEntity(ply)
						net.WriteEntity(door)
						net.WriteEntity(newCoowner)
					net.SendToServer()
					manage_frame:Close()
				else
					print("Player not found.")
				end
			end
		end
		
	local RemCoownerBTN = vgui.Create("DButton", manage_frame )
		RemCoownerBTN:SetText( "Remove Co-owner" )
		RemCoownerBTN:SetPos( 150, 60 )
		RemCoownerBTN:SetSize(100, 25)
		RemCoownerBTN.DoClick = function()
			if CoOwnerListView:GetSelectedLine() then
				local COValue = CoOwnerListView:GetLine(CoOwnerListView:GetSelectedLine()):GetValue(1)
				local coowner = nil
				
				for k, v in pairs(player.GetAll()) do
					if COValue == v:GetName() then
						coowner = v
					end
				end
				
				if coowner then
					net.Start("SKRemCoowner")
						net.WriteEntity(ply)
						net.WriteEntity(door)
						net.WriteEntity(coowner)
					net.SendToServer()
					manage_frame:Close()
				end
			end
		end
		
	local RemAllCoownerBTN = vgui.Create("DButton", manage_frame )
		RemAllCoownerBTN:SetText( "Remove All" )
		RemAllCoownerBTN:SetPos( 150, 90 )
		RemAllCoownerBTN:SetSize(100, 25)
		RemAllCoownerBTN.DoClick = function()
			net.Start("SKRemAllCoowner")
				net.WriteEntity(ply)
				net.WriteEntity(door)
			net.SendToServer()
			manage_frame:Close()
		end
			
	if canRepair then
		local repairBTN = vgui.Create("DButton", manage_frame )
			repairBTN:SetText( "Repair" )
			repairBTN:SetPos( 150, 120 )
			repairBTN:SetSize(100, 25)
			repairBTN.DoClick = function()
				net.Start("PNRP_DoRepairItem")
					net.WriteEntity(door)
				net.SendToServer()
				manage_frame:Close()
			end
		local hpLabel = vgui.Create("DLabel", manage_frame)		
			hpLabel:SetPos(150, 150)
			hpLabel:SetText("HP: "..door:Health().." / "..item.HP)
			hpLabel:SetColor(Color( 0, 255, 0, 255 ))
			hpLabel:SizeToContents() 
			hpLabel:SetContentAlignment( 5 )
	end
	
end
net.Receive( "manageDoor", ManageDoor );

local function repairMenu( )
	
	local ply = LocalPlayer() 
	local ent = net.ReadEntity()
	
	local Item = PNRP.SearchItembase( ent )
	local canRepair = false
	
	if Item then 
		if !Item.CanRepair then return end
	else	
		return
	end
	
	if !Item.HP then return end
	if !Item.RepairClass then return end
	
	if table.getn(Item.RepairClass) == 0 then
		canRepair = true
	elseif inTable(Item.RepairClass, ply:Team()) then
		canRepair = true
	end
	
	if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then canRepair = true end
	
	if canRepair then
		local repair_frame = vgui.Create( "DFrame" )
		repair_frame:SetSize( 585, 289 ) --Set the size
		repair_frame:SetPos(ScrW() / 2 - repair_frame:GetWide() / 2, ScrH() / 2 - repair_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
		repair_frame:SetTitle( "Repair Menu" ) --Set title
		repair_frame:SetVisible( true )
		repair_frame:SetDraggable( true )
		repair_frame:ShowCloseButton( true )
		repair_frame:MakePopup()
		repair_frame.Paint = function() 
			surface.SetDrawColor( 50, 50, 50, 0 )
		end
		
		local screenBG = vgui.Create("DImage", repair_frame)
			screenBG:SetImage( "VGUI/gfx/pnrp_screen_6b.png" )
			screenBG:SetSize(repair_frame:GetWide(), repair_frame:GetTall())
			
			local icon
			if Item.EntName then
				icon = vgui.Create( "ContentIcon", repair_frame )
				icon:SetSize( 125, 125 )
				icon:SetMaterial( "entities/"..Item.EntName..".png" )
				icon:SetName( Item.Name )
				icon:SetToolTip( nil )
				icon.DoClick = function() end
			else
				local skin = 0
				if Item.HullSkin then skin = Item.HullSkin end
				icon = vgui.Create( "SpawnIcon", repair_frame )
				icon:SetSize( 125, 125 )
				icon:SetModel( Item.Model, skin )
				icon:SetToolTip( nil )
				icon.DoClick = function() end
				local itemLabel = vgui.Create("DLabel", repair_frame)		
					itemLabel:SetPos(icon:GetPos() + 45, icon:GetPos() + icon:GetTall() + 50)
					itemLabel:SetText(Item.Name)
					itemLabel:SetColor(Color( 0, 255, 0, 255 ))
					itemLabel:SizeToContents() 
					itemLabel:SetContentAlignment( 5 )
			end
			icon:SetPos(40, 40)
			
			local ownerLabel = vgui.Create("DLabel", repair_frame)		
				ownerLabel:SetPos(repair_frame:GetWide()-200,45)
				ownerLabel:SetText("Owner: "..ent:GetNetVar( "Owner", "None" ))
				ownerLabel:SetColor(Color( 0, 255, 0, 255 ))
				ownerLabel:SizeToContents() 
				ownerLabel:SetContentAlignment( 5 )
			
			local hpLabel = vgui.Create("DLabel", repair_frame)
				hpLabel:SetPos(repair_frame:GetWide()-200,65)
				hpLabel:SetColor( Color( 0, 255, 0, 255 ) )
				hpLabel:SetText( "HP: "..ent:Health().." / "..Item.HP )
				hpLabel:SizeToContents()			
				
			--//Menu	
			local btnHPos = 170
			local btnWPos = repair_frame:GetWide()-220
			local btnHeight = 35
			local lblColor = Color( 245, 218, 210, 180 )
			
			local repairBtn = vgui.Create("DImageButton", repair_frame)
				repairBtn:SetPos( btnWPos,btnHPos )
				repairBtn:SetSize(30,30)
				repairBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
				repairBtn.DoClick = function()
					net.Start("PNRP_DoRepairItem")
						net.WriteEntity(ent)
					net.SendToServer()
					repair_frame:Close()
				end
				repairBtn.Paint = function()
					if repairBtn:IsDown() then 
						repairBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
					else
						repairBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					end
				end	
			local repairBtnLbl = vgui.Create("DLabel", repair_frame)
				repairBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
				repairBtnLbl:SetColor( lblColor )
				repairBtnLbl:SetText( "Repair" )
				repairBtnLbl:SetFont("Trebuchet24")
				repairBtnLbl:SizeToContents()
			
			btnHPos = btnHPos + btnHeight
			local doorowner = ent:GetNetVar( "ownerent", nil )
			if Item.Keys and doorowner == ply then
				local keysBtn = vgui.Create("DImageButton", repair_frame)
					keysBtn:SetPos( btnWPos,btnHPos )
					keysBtn:SetSize(30,30)
					keysBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
					keysBtn.DoClick = function() 
						net.Start( "pnrp_StartKeysMenu" )
							net.WriteEntity(ent)
						net.SendToServer()
						repair_frame:Close()
					end
					keysBtn.Paint = function()
						if keysBtn:IsDown() then 
							keysBtn:SetImage( "VGUI/gfx/pnrp_button_down.png" )
						else
							keysBtn:SetImage( "VGUI/gfx/pnrp_button.png" )
						end
					end	
				local keysBtnLbl = vgui.Create("DLabel", repair_frame)
					keysBtnLbl:SetPos( btnWPos+40,btnHPos+2 )
					keysBtnLbl:SetColor( lblColor )
					keysBtnLbl:SetText( "Keys Menu" )
					keysBtnLbl:SetFont("Trebuchet24")
					keysBtnLbl:SizeToContents()
			end
	end
end
net.Receive( "repairMenu", repairMenu)

-------------------------------------------
-- Client-Side Utilities
-------------------------------------------

--HUD Drawing
-- function SKPaintText( x, y, text, font, color )
 
	-- surface.SetFont( font );
 
	-- surface.SetTextPos( x + 1, y + 1 );
	-- surface.SetTextColor( color.shadow );
	-- surface.DrawText( text );
 
	-- surface.SetTextPos( x, y );
	-- surface.SetTextColor( color.text  );
	-- surface.DrawText( text );
 
-- end

-- function SKPaintRoundedPanel(r, x, y, w, h, color )
  
	-- x = x + 1; y = y + 1;
	-- w = w - 2; h = h - 2;
 
	-- draw.RoundedBox(r, x, y, w, h, color)
 
-- end

-- Should already be repeated
--Entity Utils
-- local EntityMeta = FindMetaTable("Entity")
-- function EntityMeta:IsDoor() --Repeat on client side, to make sure.
	-- local class = self:GetClass()

	-- if class == "func_door" or
		-- class == "func_door_rotating" or
		-- class == "prop_door_rotating" or
		-- class == "prop_dynamic" then
		-- return true
	-- end
	-- return false
-- end