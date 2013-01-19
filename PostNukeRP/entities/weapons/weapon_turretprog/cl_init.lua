include('shared.lua')

SWEP.PrintName			= "L.O.S.T. Turret Programmer"			
SWEP.Slot				= 5
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.WepSelectIcon		= nil

--SWEP.Frequency			= 400
--SWEP.Power				= "off"

function open_prgmenu()
	local turretEnt = net.ReadEntity()
	local whitelist = tobool(net.ReadBit())
	local ProgTable = net.ReadTable()
	
	if whitelist then
		whitelist = true
	else
		whitelist = false
	end
	
	local textColor = Color(200,200,200,255)
	local ply = LocalPlayer()
	
	local prog_menu_frame = vgui.Create( "DFrame" )
		prog_menu_frame:SetSize( 400, 300 )
		prog_menu_frame:Center()
		prog_menu_frame:SetTitle( "L.O.S.T. Turret Programmer" )
		prog_menu_frame:SetVisible( true )
		prog_menu_frame:SetDraggable( true )
		prog_menu_frame:ShowCloseButton( true )
		prog_menu_frame:MakePopup()
		
	local PlyListView = vgui.Create( "DListView", prog_menu_frame )
		PlyListView:SetPos( 20, 30 )
		PlyListView:SetSize( 125, 250 )
		PlyListView:SetMultiSelect( false ) -- <removed sarcastic and useless comment>
		PlyListView:AddColumn("Players")
		
		for k, v in pairs(player.GetAll()) do
			found = false
			if ProgTable and ProgTable[1] then
				for k2, v2 in pairs(ProgTable) do
					if v == v2 then found = true end
				end
			end
			if v == ply then found = true end
			if not found and v then
				PlyListView:AddLine( v:GetName())
			end
		end
	
	local TrgListView = vgui.Create( "DListView", prog_menu_frame )
		TrgListView:SetPos( 255, 30 )
		TrgListView:SetSize( 125, 250 )
		TrgListView:SetMultiSelect( false ) -- <removed sarcastic and useless comment>
		TrgListView:AddColumn("Co-Owers")
		
		if ProgTable and ProgTable[1] then
			for k, v in pairs(ProgTable) do
				if v and IsValid(v) then
					TrgListView:AddLine( v:GetName())
				end
			end
		end
	
	if whitelist then
		local WhitelistBTN = vgui.Create("DButton", prog_menu_frame )
		WhitelistBTN:SetText( "SET TO Blacklist" )
		WhitelistBTN:SetPos( 150, 30 )
		WhitelistBTN:SetSize(100, 25)
		WhitelistBTN.DoClick = function()
				net.Start("Turret_Whitelist")
					net.WriteEntity(turretEnt)
				net.SendToServer()
				prog_menu_frame:Close()
			end
	else
		local WhitelistBTN = vgui.Create("DButton", prog_menu_frame )
		WhitelistBTN:SetText( "SET TO Whitelist" )
		WhitelistBTN:SetPos( 150, 30 )
		WhitelistBTN:SetSize(100, 25)
		WhitelistBTN.DoClick = function()
				net.Start("Turret_Whitelist")
					net.WriteEntity(turretEnt)
				net.SendToServer()
				prog_menu_frame:Close()
			end
	end
	
	local AddTrgBTN = vgui.Create("DButton", prog_menu_frame )
		AddTrgBTN:SetText( "Add Target" )
		AddTrgBTN:SetPos( 150, 100 )
		AddTrgBTN:SetSize(100, 25)
		AddTrgBTN.DoClick = function()
			if PlyListView:GetSelectedLine() then
				local trgValue = PlyListView:GetLine(PlyListView:GetSelectedLine()):GetValue(1)
				local trgEnt = nil
				
				for k, v in pairs(player.GetAll()) do
					if trgValue == v:GetName() then
						trgEnt = v
					end
				end
				
				if trgEnt then
					net.Start("Turret_AddTrg")
						net.WriteEntity(turretEnt)
						net.WriteEntity(trgEnt)
					net.SendToServer()
					prog_menu_frame:Close()
				end
			end
		end
		
	local RemTrgBTN = vgui.Create("DButton", prog_menu_frame )
		RemTrgBTN:SetText( "Remove Target" )
		RemTrgBTN:SetPos( 150, 125 )
		RemTrgBTN:SetSize(100, 25)
		RemTrgBTN.DoClick = function()
			if TrgListView:GetSelectedLine() then
				local trgValue = TrgListView:GetLine(TrgListView:GetSelectedLine()):GetValue(1)
				local trgEnt = nil
				
				for k, v in pairs(player.GetAll()) do
					if trgValue == v:GetName() then
						trgEnt = v
					end
				end
				
				if trgEnt then
					net.Start("Turret_RemTrg")
						net.WriteEntity(turretEnt)
						net.WriteEntity(trgEnt)
					net.SendToServer()
					prog_menu_frame:Close()
				end
			end
		end
	
	local ClearTrgBTN = vgui.Create("DButton", prog_menu_frame )
		ClearTrgBTN:SetText( "Clear Targets" )
		ClearTrgBTN:SetPos( 150, 150 )
		ClearTrgBTN:SetSize(100, 25)
		ClearTrgBTN.DoClick = function()				
			net.Start("Turret_ClearTrg")
				net.WriteEntity(turretEnt)
			net.SendToServer()
			prog_menu_frame:Close()
		end
end
net.Receive( "turretprog_menu", open_prgmenu )
