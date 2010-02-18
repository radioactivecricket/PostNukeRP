include( 'shared.lua' ) --Tell the client to load shared.lua

for k, v in pairs(file.FindInLua("PostNukeRP/gamemode/vgui/*.lua")) do
	include("vgui/"..v)	
end

for k, v in pairs(file.FindInLua("PostNukeRP/gamemode/derma/*.lua")) do
	include("derma/"..v)
end

Resources = {}
local PrevHealth
local LastDraw
local dynaset = {}
dynaset.prevyaw = 0
dynaset.newroll = 0

--Get resource
function GetResource(resource)
	return Resources[resource] or 0
end

--Set Resource
function GM.SetResource(um)
	local res = um:ReadString()
	local amount = um:ReadShort()

	Resources[res] = amount
end

usermessage.Hook("pnrp_SetResource",GM.SetResource)

function DrawTopHud()
	local person = LocalPlayer()
	if ( !person:Alive() ) then return end

	local scrap = GetResource("Scrap")
	local smallparts = GetResource("Small_Parts")
	local chems = GetResource("Chemicals")
	
	local hudPos = 15
	local hw, ht = ScrW(), 26 
	
	surface.SetDrawColor( 0, 0, 0, 255 )	
	surface.DrawRect( 0, 0, hw, ht )
	
	surface.SetDrawColor( 0, 0, 0, 255  )
	surface.DrawOutlinedRect( 0, 0, hw, ht )
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetFont( "CenterPrintText" )
	surface.SetTextPos( hudPos + 25, 3 )
	surface.DrawText( "Scrap:  "..scrap )
	
	hudPos = hudPos + 120
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetFont( "CenterPrintText" )
	surface.SetTextPos( hudPos + 25, 3 )
	surface.DrawText( "Small Parts:  "..smallparts )
	
	hudPos = hudPos + 120
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetFont( "CenterPrintText" )
	surface.SetTextPos( hudPos + 25, 3 )
	surface.DrawText( "Chemicals:  "..chems )
	
	hudPos = hudPos + 120
	
	local plLocation = nil
	if person:IsOutside() then
		plLocation = "Outside"
	else
		plLocation = "Inside"
	end
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetFont( "CenterPrintText" )
	surface.SetTextPos( hudPos + 25, 3 )
	surface.DrawText( "Location:  "..plLocation )
	
	hudPos = hudPos + 120
	
	surface.SetTextColor( team.GetColor(person:Team()) )
	surface.SetFont( "CenterPrintText" )
	surface.SetTextPos( hudPos + 25, 3 )
	surface.DrawText( "Class:  "..team.GetName(person:Team()) )
	
	hudPos = hudPos + 120
	
	local trace = {}
	trace.start = person:EyePos()
	trace.endpos = trace.start + person:GetAimVector() * 300
	trace.filter = person
	local tr = util.TraceLine( trace )	
	
	local ent = tr.Entity
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetFont( "CenterPrintText" )
	surface.SetTextPos( hudPos + 25, 3 )
	surface.DrawText( "Owner:  "..ent:GetNWString( "Owner", "None" ))
end
hook.Add("HUDPaint", "HUD_DRAW", DrawTopHud)

function set_class()
 
	local frame = vgui.Create( "DFrame" )
		frame:SetPos( ScrW() / 2, ScrH() / 2 ) --Set the window in the middle of the players screen/game window
		frame:SetSize( 350, 350 ) --Set the size
		frame:SetTitle( "Change Class" ) --Set title
		frame:SetVisible( true )
		frame:SetDraggable( false )
		frame:ShowCloseButton( true )
		frame:MakePopup()
		 
		team_1 = vgui.Create( "DButton", frame )
		team_1:SetPos( frame:GetTall() / 2, 10 ) --Place it half way on the tall and 5 units in horizontal
		team_1:SetSize( 75, 75)
		team_1:SetText( "Wastelander" )
		team_1.DoClick = function() --Make the player join team 1
		
	    RunConsoleCommand( "team_set_wastelander" )
	end
	 
		team_2 = vgui.Create( "DButton", frame )
		team_2:SetPos( frame:GetTall() / 2, 85 ) --Place it next to our previous one
		team_2:SetSize( 75, 75)
		team_2:SetText( "Scavenger" )
		team_2.DoClick = function() --Make the player join team 2
		
	    RunConsoleCommand( "team_set_scavenger" )
	end
	 
		team_2 = vgui.Create( "DButton", frame )
		team_2:SetPos( frame:GetTall() / 2, 160 ) --Place it next to our previous one
		team_2:SetSize( 75, 75)
		team_2:SetText( "Science" )
		team_2.DoClick = function() --Make the player join team 2
		
	    RunConsoleCommand( "team_set_science" )
	end
	 
		team_2 = vgui.Create( "DButton", frame )
		team_2:SetPos( frame:GetTall() / 2, 235 ) --Place it next to our previous one
		team_2:SetSize( 75, 75)
		team_2:SetText( "Engineer" )
		team_2.DoClick = function() --Make the player join team 2
		
	    RunConsoleCommand( "team_set_engineer" )
	end
	
		team_2 = vgui.Create( "DButton", frame )
		team_2:SetPos( frame:GetTall() / 2, 235 ) --Place it next to our previous one
		team_2:SetSize( 75, 75)
		team_2:SetText( "Cultivator" )
		team_2.DoClick = function() --Make the player join team 2
		
	    RunConsoleCommand( "team_set_cultivator" )
	end
 
end
concommand.Add( "class_menu", set_class )

local function DynaEyeTilt()
	local person = LocalPlayer()
	local val = {}
	local sideways = 0
	local towards = 1
	local running = 0
	local sprint = 1
	val.pitch, val.yaw, val.roll = person:EyeAngles().p, person:EyeAngles().y, person:EyeAngles().r
	
	-- /*
	-- SWEP = person:GetActiveWeapon()
	-- if (SWEP:IsValid() and (SWEP:GetClass() == "gmod_cam_amateur")) then return end
	-- */
	
	val.basediff = math.Clamp(math.AngleDifference(dynaset.prevyaw,val.yaw),-5,5)
	//bottom + (top-bottom)*perc
	dynaset.newroll = math.Clamp(dynaset.newroll+val.basediff,-5,5) 
	
	
	if ( person:KeyDown( IN_MOVELEFT ) ) then sideways = sideways - 3 end
	if ( person:KeyDown( IN_MOVERIGHT ) ) then sideways = sideways + 3 end
	
	if ( person:KeyDown( IN_FORWARD  ) ) then 
		towards = 5 
		running = 1
	elseif ( person:KeyDown( IN_BACK  ) ) then 
		towards = -5 
		running = 1
	else
		runnning = 0
	end 
	
	if ( (person:KeyDown( IN_MOVELEFT  ) or
		  person:KeyDown( IN_MOVERIGHT ) or 
		  person:KeyDown( IN_FORWARD   ) or
		  person:KeyDown( IN_BACK      )    ) and person:KeyDown( IN_SPEED ) ) then sprint = 2 end
	
	local isonground = 0
	if (person:IsOnGround()) then isonground = 1 end
	
	local top = dynaset.newroll
	local bottom = (0.5/7*towards*sprint)*isonground + sideways --math.sin(RealTime()*3*towards*sprint)
	dynaset.newroll = bottom + (top-bottom)*0.7
	dynaset.prevyaw = val.yaw

	if (person:Alive() ) then person:SetEyeAngles(Angle(val.pitch+(math.sin(RealTime()*8*running*sprint*isonground)/(8-(sprint-1)*4)),val.yaw,dynaset.newroll)) end
end

hook.Add("Think", "DynaEyeTilt", DynaEyeTilt)

local function DamageBlur()
	local person = LocalPlayer()
	local delay = 0.5
	local blurmax = 0.75
	if person:Alive() then
		if !LastDraw and !PrevHealth then 
			LastDraw = CurTime() + 2
			PrevHealth = person:Health()
		end
		
		if person:Health() < PrevHealth then
			LastDraw = CurTime()
			PrevHealth = person:Health()
		end
		
		local TimeDif = CurTime() - LastDraw 
		
		if TimeDif < delay then
			DrawMotionBlur( ( TimeDif / delay ) * blurmax, 0.79, 0.05) --*((PrevHealth-person:Health())/10)
		end
	end
end
hook.Add( "RenderScreenspaceEffects", "RenderDamage", DamageBlur )


