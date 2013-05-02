include( 'shared.lua' ) --Tell the client to load shared.lua

--Msg("Ping \n")
--local files, directories = file.Find("postnukerp/gamemode/*", "LUA")
-- for k, v in pairs(file.Find("*", "GAME")) do
	-- Msg("File "..v.."\n")	
-- end

--for k, v in pairs(files) do
--	Msg("Files "..v.."\n")
--end

--for k, v in pairs(directories) do
--	Msg("Dirs "..v.."\n")
--end

--Msg("Pong \n")
for k, v in pairs(file.Find(PNRP_Path.."gamemode/vgui/*.lua", "LUA")) do
	include("vgui/"..v)	
end

for k, v in pairs(file.Find(PNRP_Path.."gamemode/derma/*.lua", "LUA")) do
	include("derma/"..v)
end

Resources = {}
Skills = {}
Endurance = 100
XP = 0
local PrevHealth
local LastDraw
local dynaset = {}
dynaset.prevyaw = 0
dynaset.newroll = 0

pnDerma = {}

timer.Create( "autosave", 300, 0, function()
	RunConsoleCommand("pnrp_save")
	LocalPlayer():ChatPrint("Heeeyyy!  Autosaved.")
end )

-- Once again, pretty much the same as DarkRP
-- Make sure the client sees the RP name where they expect to see the name
local pmeta = FindMetaTable("Player")

pmeta.SteamName = pmeta.Name
function pmeta:Name()
	if IsValid(self) then
		return self.rpname or self:SteamName()
	else
		return "Unknown"
	end

	--if not self or not self.IsValid or not IsValid(self) then return "" end
	--return self.rpname or self:SteamName()
end

pmeta.GetName = pmeta.Name
pmeta.Nick = pmeta.Name

local function RcvNewRPName( )
	local target = net:ReadEntity()
	local newname = net:ReadString()
	local suppressMessage = tobool(net:ReadBit())
	
	if not suppressMessage then LocalPlayer():ChatPrint(target:Nick().." changed their name to "..newname..".") end
	target.rpname = newname
end
net.Receive( "RPNameChange", RcvNewRPName )
-- End

-- Chat override
function GM:OnPlayerChat( ply, strText, bTeamOnly, bPlayerIsDead )
 
	-- I've made this all look more complicated than it is. Here's the easy version
	-- chat.AddText( ply:GetName(), Color( 255, 255, 255 ), ": ", strText )
 
	local tab = {}
 
	if ( bPlayerIsDead ) then
		table.insert( tab, Color( 255, 30, 40 ) )
		table.insert( tab, "*DEAD* " )
	end
 
	if ( bTeamOnly ) then
		table.insert( tab, Color( 30, 160, 40 ) )
		table.insert( tab, "[RADIO] " )
	end
 
	if ( IsValid( ply ) ) then
		local curTeam = ply:Team()
		local teamColor = team.GetColor(curTeam)
		table.insert( tab, Color(teamColor.r, teamColor.g, teamColor.b) )

		table.insert( tab, ply:GetName() )
	else
		table.insert( tab, "Console" )
	end
 
	table.insert( tab, Color( 255, 255, 255 ) )
	table.insert( tab, ": "..strText )
 
	chat.AddText( unpack(tab) )
 
	return true
 
end

--Get resource
function GetResource(resource)
	return Resources[resource] or 0
end

--Set Resource
function GM.SetResource( )
	local res = net:ReadString()
	local amount = math.Round(net:ReadDouble())

	Resources[res] = amount
end
net.Receive("pnrp_SetResource",GM.SetResource)

local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:GetSkill(skill)
	return GetSkill(skill)
end

--Get skill
function GetSkill(skill)
	return Skills[skill] or 0
end

--Set skill
function GM.SetSkill( )
	local skill = net:ReadString()
	local amount = math.Round(net:ReadDouble())

	Skills[skill] = amount
end
net.Receive("pnrp_SetSkill",GM.SetSkill)

--Get experience
function GetXP()
	return XP or 0
end

--Set experience
function GM.SetXP( )
	local amount = math.Round(net:ReadDouble())
	
	XP = amount
end
net.Receive("pnrp_SetXP",GM.SetXP)

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
		team_2.DoClick = function() --Make the player join team 3
		
	    RunConsoleCommand( "team_set_science" )
	end
	 
		team_2 = vgui.Create( "DButton", frame )
		team_2:SetPos( frame:GetTall() / 2, 235 ) --Place it next to our previous one
		team_2:SetSize( 75, 75)
		team_2:SetText( "Engineer" )
		team_2.DoClick = function() --Make the player join team 4
		
	    RunConsoleCommand( "team_set_engineer" )
	end
	
		team_2 = vgui.Create( "DButton", frame )
		team_2:SetPos( frame:GetTall() / 2, 235 ) --Place it next to our previous one
		team_2:SetSize( 75, 75)
		team_2:SetText( "Cultivator" )
		team_2.DoClick = function() --Make the player join team 5
		
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
	
	--Vehicle Check
	if !person:InVehicle( ) then
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

function PNRP:GetUID( ply )
	local plUID = tostring(ply:GetNetworkedString( "UID" , "None" ))
	if plUID == "None" then
		plUID = ply:UniqueID()
	end
	
	return plUID
end

--Debugs, REMOVE LATER
function SendUmsgTable()
	local umsgTable = usermessage.GetTable()
	
	net.Start("printUmsgTable")
		net.WriteTable(umsgTable)
	net.SendToServer()
end
net.Receive( "sendUmsgTable", SendUmsgTable)

function PNRP.AddMenu(menu)
    table.insert( pnDerma, menu )
end

function PNRP.RMDerma()
--	ply = LocalPlayer()
	if pnDerma then
		for _, menu in pairs( pnDerma ) do
			if IsValid(menu) then
				menu:Remove()
			end
		end
	end
	pnDerma = {}
end
