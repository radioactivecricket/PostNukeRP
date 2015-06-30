include('shared.lua')
local lad_state = "off"

function ENT:Draw()
	self.Entity:DrawModel()
	--[[
	if lad_state == "off" then
		render.SetMaterial( Material( "models/wireframe" ) )
		render.DrawQuadEasy( self:GetPos()-Vector(0,0,-64),    --position of the rect
			self:GetAngles():Forward(),        --direction to face in
			25, 128,              --size of the rect
			Color( 0, 255, 0, 255 )
		) 
	end
	]]--
end

function LadderMenu( )
	local ladderEnt = net:ReadEntity()
	local assembled = net:ReadBit()
	local Allowed = "true"
	local entMSG = "none"
	ply = LocalPlayer( )
	local owner = ladderEnt:GetNetVar( "Owner", "None" )
	
	local w = 180
	local h = 150
	local title = "Ladder Setup"
	
	local lad_f = vgui.Create("DFrame")
	lad_f:Center()
	lad_f:SetSize( w, h )
	lad_f:SetTitle( title )
	lad_f:SetVisible( true )
	lad_f:SetDraggable( true )
	lad_f:ShowCloseButton( true )
	lad_f:MakePopup()
		
		if Allowed == "true" then
		
			if assembled==0 then -- Turn on
						local ladderButtonOn = vgui.Create( "DButton" )
						ladderButtonOn:SetParent( lad_f )
						ladderButtonOn:SetText( "Assemble" )
						ladderButtonOn:SetPos( 30, 50 )
						ladderButtonOn:SetSize( 120, 70 )
						ladderButtonOn.DoClick = function ()
							lad_state = "on"
							net.Start("ladder_assemble")
								net.WriteEntity(ply)
								net.WriteEntity(ladderEnt)
							net.SendToServer()
							lad_f:Close()
						end
			elseif assembled==1 then -- Turn off
				local ladderButtonOff = vgui.Create( "DButton" )
				ladderButtonOff:SetParent( lad_f )
				ladderButtonOff:SetText( "Disassemble" )
				ladderButtonOff:SetPos( 30, 50 )
				ladderButtonOff:SetSize( 120, 70 )
				ladderButtonOff.DoClick = function ()
					lad_state = "off"
					net.Start("ladder_disassemble")
						net.WriteEntity(ply)
						net.WriteEntity(ladderEnt)
					net.SendToServer()
					lad_f:Close()
				end
			end
		
		else
			local entMSGLabel = vgui.Create("DLabel", lad_f)
			entMSGLabel:SetPos(10, 75)
			entMSGLabel:SetColor( Color( 0, 0, 0, 255 ) )
			entMSGLabel:SetText( entMSG )
			entMSGLabel:SizeToContents()
		end
end
net.Receive("ladder_menu", LadderMenu)

--local function ProgBar(st,maxTime)
--	local perc= (CurTime() - st)-30 + maxTime
--	ply:ChatPrint(tostring(perc))
--	local pbase=vgui.Create("DProgress",nil,"lad_progbar")
--	pbase:SetPos(ScrW()/2-60,ScrH()/2+40)
--	pbase:SetSize(120,20)
--	pbase:SetFraction(perc)
--end

--hook.Add("HUDD","ProgBar", ProgBar(net.ReadDouble(),net.ReadDouble()))