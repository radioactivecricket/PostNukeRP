
require("datastream")

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
	
	-- if not ent:IsValid() then return end
	
	-- if ent:IsDoor() then
		-- local doorowner = ent:GetNWEntity( "ownerent", NullEntity() )
		
		-- if doorowner:IsValid() then
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
local function ManageDoor( handle, id, encoded, decoded )
	local door = decoded.doorEnt
	local doorCoowners = decoded.coowners
	
	local manage_frame = vgui.Create( "DFrame" )
	manage_frame:SetSize( 400, 300 )
	manage_frame:Center()
	manage_frame:SetTitle( "Door Management" )
	manage_frame:SetVisible( true )
	manage_frame:SetDraggable( true )
	manage_frame:ShowCloseButton( true )
	manage_frame:MakePopup()
	
	local found = false
	local PlyComboBox = vgui.Create( "DComboBox", manage_frame )
		PlyComboBox:SetPos( 20, 30 )
		PlyComboBox:SetSize( 125, 250 )
		PlyComboBox:SetMultiple( false )
		
		for k, v in pairs(player.GetAll()) do
			found = false
			if doorCoowners and doorCoowners[1] then
				for k2, v2 in pairs(doorCoowners) do
					if v == v2 then found = true end
				end
			end
			if v == LocalPlayer() then found = true end
			if not found and v:IsValid() then
				PlyComboBox:AddItem( v:GetName())
			end
		end
	
	local COComboBox = vgui.Create( "DComboBox", manage_frame )
		COComboBox:SetPos( 255, 30 )
		COComboBox:SetSize( 125, 250 )
		COComboBox:SetMultiple( false )
		
		if doorCoowners and doorCoowners[1] then
			for k, v in pairs(doorCoowners) do
				if v:IsValid() then
					COComboBox:AddItem( v:GetName())
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
			--datastream.StreamToServer( "ReleaseOwnership", { ["doorEnt"] = door } )
			if PlyComboBox:GetSelectedItems() and PlyComboBox:GetSelectedItems()[1] then
				local plyValue = PlyComboBox:GetSelectedItems()[1]:GetValue()
				local newCoowner = NullEntity()
				
				for k, v in pairs(player.GetAll()) do
					if plyValue == v:GetName() then
						newCoowner = v
					end
				end
				
				if newCoowner:IsValid() then
					datastream.StreamToServer( "SKAddCoowner", { ["doorEnt"] = door, ["newCoowner"] = newCoowner } )
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
			if COComboBox:GetSelectedItems() and COComboBox:GetSelectedItems()[1] then
				local COValue = COComboBox:GetSelectedItems()[1]:GetValue()
				local coowner = NullEntity()
				
				for k, v in pairs(player.GetAll()) do
					if COValue == v:GetName() then
						coowner = v
					end
				end
				
				if coowner:IsValid() then
					datastream.StreamToServer( "SKRemCoowner", { ["doorEnt"] = door, ["coowner"] = coowner } )
					manage_frame:Close()
				end
			end
		end
		
	local RemAllCoownerBTN = vgui.Create("DButton", manage_frame )
		RemAllCoownerBTN:SetText( "Remove All" )
		RemAllCoownerBTN:SetPos( 150, 90 )
		RemAllCoownerBTN:SetSize(100, 25)
		RemAllCoownerBTN.DoClick = function()
			datastream.StreamToServer( "SKRemAllCoowner", { ["doorEnt"] = door } )
			manage_frame:Close()
		end
end
datastream.Hook( "manageDoor", ManageDoor );


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