
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

	local ply = LocalPlayer()
	local manage_frame = vgui.Create( "DFrame" )
	manage_frame:SetSize( 400, 300 )
	manage_frame:Center()
	manage_frame:SetTitle( "Door Management" )
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
end
net.Receive( "manageDoor", ManageDoor );

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