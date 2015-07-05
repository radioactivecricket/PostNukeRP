
CreateConVar("pnrp_HUD","1",FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_DeathNotice","1",FCVAR_NOTIFY + FCVAR_ARCHIVE)

PNRP_HUD = { }

local HUD_col =
{
 	bg =
	{
		border = Color( 190, 255, 128, 255 ),
		background = Color( 51, 58, 51, 100 )
	},
	text =
	{
		shadow = Color( 0, 0, 0, 200 ),
		text = Color( 255, 255, 255, 255 )
	},
	hp_bar =
	{
		border = Color( 255, 0, 0, 255 ),
		background = Color( 255, 0, 0, 75 ),
		shade = Color( 255, 104, 104, 255 ),
		fill = Color( 232, 0, 0, 255 )
 
	},
	suit_bar =
	{
		border = Color( 0, 0, 255, 255 ),
		background = Color( 0, 0, 255, 75 ),
		shade = Color( 136, 136, 255, 255 ),
		fill = Color( 0, 0, 219, 255 )
	},
	inside_indic =
	{
		offhighlight = Color( 200, 155, 200, 125 ),
		offfill = Color( 255, 0, 0, 255 ),
		onhighlight = Color( 200, 255, 200, 125 ),
		onfill = Color( 0, 175, 0, 255 )
	},
	end_bar =
	{
		border = Color( 200, 0, 200, 255 ),
		background = Color( 200, 0, 200, 75 ),
		shade = Color( 165, 4, 255, 255 ),
		fill = Color(112, 4, 168, 155)
	},
	hunger_bar =
	{
		border = Color( 0, 255, 0, 255 ),
		background = Color( 0, 255, 0, 75 ),
		shade = Color( 136, 255, 136, 255 ),
		fill = Color(0, 255, 30, 155)
	},
	border = Color( 0, 100, 0, 150 )
}

local HUD_var =
{
	font = "CenterPrintText",
	info_font = "CenterPrintText",
	zombie_font = "CenterPrintText",
 
	padding = 5,
	marginX = 2,
	marginY = 22,
 
	text_spacing = 2,
	bar_spacing = 5,
 
	bar_height = 10,
 
	width = 0.15
}



local function HUDPaint( )
--	DrawInfoHUD( HUD_var )
	PNRP.DrawDeathZombieLabel()
	
	if GetConVarNumber("pnrp_HUD") == 1 then
		HUD_Default()
		DrawInfoHUD( HUD_var )
	elseif GetConVarNumber("pnrp_HUD") == 2 then
		--HUD_Default()
		--DrawInfoHUD( HUD_var )
		PNRP:HUD_2()
	else
		HUD_Default()
		DrawInfoHUD( HUD_var )
	end
	
end
hook.Add( "HUDPaint", "PaintHud", HUDPaint )

function hidehud(name)
	for k, v in pairs{"CHudHealth", "CHudBattery"} do
		if name == v then return false end
	end
end
hook.Add("HUDShouldDraw", "hidehud", hidehud)

function HUD_Default()
	client = client or LocalPlayer()	
	if( !client:Alive() ) then return end	--If the player is dead, do not draw the HUD
	
	local ply = LocalPlayer()

	local font = HUD_var.font
	local bar = {
		padding = HUD_var.bar_spacing,
		margin = HUD_var.margin,
		spacing = HUD_var.bar_spacing,
		height = HUD_var.bar_height,
		width = HUD_var.width,
		txt_space = HUD_var.text_spacing
		}
		
	local _, txtHeight = PNRP_HUD:TextSize( "TEXT", font ) --Gets the size (height) of the font

	local i = 4		--Number of bars on the HUD (HP, Armor, End, Hunger)
	
	local width = ( ScrW() - bar.padding * 2 )
	local bar_width = (width / i ) - bar.spacing - bar.padding
	local height = bar.height + ( bar.padding * 2 ) + bar.txt_space + txtHeight
	
	--Screen Margin
	local marginX = HUD_var.marginX
	local marginY = HUD_var.marginY
	
	--Gets Initial Position (Magin + Padding)
	local x = marginX + bar.padding
	local y = marginY + bar.padding
	
	--Paints the Background Panel
	PNRP_HUD:PaintRoundedPanel( 6, marginX, marginY, width, height, HUD_col.bg )
	
	--Gets the players Max HP
	local MaxHealth = ply:GetNetVar( "MaxHealth", 100 ) 
	
	local stat = {
		HP = string.format( "Health: %iHP", ply:Health( ) ),	-- Heath Text
		POWER = string.format( "Suit Power: %iSP", ply:Armor( ) ),	-- Suit text
		END = string.format( "Endurance: %i", Endurance ), -- Player Endurance
		HUNGER = string.format( "Hunger: %i", Hunger )	
		}
	
	--Initial Offset
	--Bar 1
	local offset = bar.padding
	
	--Paints the HP Bar TXT
	PNRP_HUD:PaintText( x, y, stat.HP, font, HUD_col.text )
	--Flashes when HP Bar is low
	if client:Health( ) < 40 then
 		HUD_col.hp_bar.fill = Color( 232 * math.abs(math.sin(CurTime()*2)), 0, 0, 255 )
 		HUD_col.hp_bar.shade = Color( 255 * math.abs(math.sin(CurTime()*2)), 104, 104, 255 )
 	else
 		HUD_col.hp_bar.shade = Color( 255, 104, 104, 255 )
		HUD_col.hp_bar.fill = Color( 232, 0, 0, 255 )
	end
	--Paints the HP Bar
	PNRP_HUD:PaintBar( x, y + txtHeight + bar.txt_space, bar_width, bar.height, HUD_col.hp_bar, ply:Health( ) / MaxHealth )
	
	--Bar 2
	offset = offset + bar_width + bar.spacing
	
	--Paint Suit text
	PNRP_HUD:PaintText( x + offset, y, stat.POWER, font, HUD_col.text )	
	--Paint Suit Bar
	PNRP_HUD:PaintBar( x + offset, y + txtHeight + bar.txt_space, bar_width, bar.height, HUD_col.suit_bar, ply:Armor( ) / 100 )
	
	--Bar 3
	offset = offset + ( bar_width + bar.spacing * 2 )
	
	--% of Endurance
	local endPerc = Endurance / 100
	--Endurance Bar and Text
	PNRP_HUD:PaintText( x + offset, y, stat.END, font, HUD_col.text )	
	PNRP_HUD:PaintBar( x + offset, y + txtHeight + bar.txt_space, bar_width, bar.height, HUD_col.end_bar, endPerc )
	
	--Draws the sleep indication line
 	draw.RoundedBox(0, x + bar_width * 0.8 + offset, y + txtHeight + bar.txt_space, 1, bar.height, Color(255, 255, 255, 150))
	--When the players End drops below 20
 	if Endurance < 20 then
 		local ehx
 		local ehy
 		ehx = ScrW( ) / 2 -20
 		ehy = ScrH( ) - txtHeight - 40
 		eh_font = "TargetID"
 		local eh_text = { }
 		eh_text.shadow = Color( 0, 0, 0, 200 )
		eh_text.text = Color( 255, 255, 255, 255 * math.abs(math.sin(CurTime()*1.2)) )
 		
 		PNRP_HUD:PaintText( ehx, ehy, "You need to rest!", eh_font, eh_text )	
 		HUD_col.end_bar.fill = Color( 112 * math.abs(math.sin(CurTime()*2)), 4, 168, 255 )
 		HUD_col.end_bar.shade = Color( 165 * math.abs(math.sin(CurTime()*2)), 4, 255, 255 )
 	else
 		HUD_col.end_bar.shade = Color( 165, 4, 255, 255 )
		HUD_col.end_bar.fill = Color(112, 4, 168, 155)
 	end
	
	--Bar 4
	offset = offset + ( bar_width + bar.spacing * 2 )
	
	--% of Hunger
	local hungPerc = Hunger / 100
	
	--Draws the hunger text and bar
	PNRP_HUD:PaintText( x + offset, y, stat.HUNGER, font, HUD_col.text )	
 	PNRP_HUD:PaintBar( x + offset, y + txtHeight + bar.txt_space, bar_width, bar.height, HUD_col.hunger_bar, hungPerc )
	
	--If Hunger is below 20
	if Hunger < 20 then
 		local hux
 		local huy
 		hux = ScrW( ) / 2 -20
 		huy = ScrH( ) - txtHeight - 60
 		hu_font = "TargetID"
 		local hu_text = { }
 		hu_text.shadow = Color( 0, 0, 0, 200 )
 		hu_text.text = Color( 255, 255, 255, 255 * math.abs(math.sin(CurTime()*1.2)) )
		
 		PNRP_HUD:PaintText( hux, huy, "You need to eat!", hu_font, hu_text )
 		HUD_col.hunger_bar.fill = Color( 0, 255 * math.abs(math.sin(CurTime()*2)), 30, 255 )
 		HUD_col.hunger_bar.shade = Color( 136, 255 * math.abs(math.sin(CurTime()*2)), 136, 255 )
 		--Plays hunger sound
 		if HungSoundSW == 1 then
 			--checks if the player is femail
			if string.find(string.lower(client:GetModel()), "/female") or
				string.find(string.lower(client:GetModel()), "mossman") or
			    string.find(string.lower(client:GetModel()), "alyx") then
	 			
			    client:EmitSound( "vo/npc/female01/question28.wav" )
	 		else
	 			client:EmitSound( "vo/npc/male01/question28.wav" )
	 		end
 			HungSoundSW = 0
 		end
 	else
 		HUD_col.hunger_bar.shade = Color( 136, 255, 136, 255 )
		HUD_col.hunger_bar.fill = Color(0, 255, 30, 155)
 	end
	--Restes the sound switch
 	if Hunger >= 21 then
 		HungSoundSW = 1
 	end
	
	--Draws Location Indicator
 	local indW = 10
 	local indH = 10
 	
 	PNRP_HUD:PaintRoundedPanel( 6, marginX, marginY + height, indW + (bar.padding * 2) + 60, indH + (bar.padding * 2), HUD_col.bg )
 	PNRP_HUD:PaintInsideIndic(marginX + bar.padding, marginY + height + bar.padding + 2, indW, indH, font, HUD_col.inside_indic )
 	
	PNRP_HUD:PaintRoundedPanel( 6, marginX + 100, marginY + height, indW + (bar.padding * 2) + 60, indH + (bar.padding * 2), HUD_col.bg )
	PNRP_HUD:PaintXPIndic(marginX + bar.padding + 100, marginY + height + bar.padding + 2, HUD_var )
	
	PNRP_HUD:showRadio(marginX + bar.padding + 200, marginY + height,txtHeight + (HUD_var.text_spacing * 2), 75)
	
	local compWidth = 360 + (HUD_var.text_spacing * 4)
	local cxCompass = (ScrW() / 2) - (compWidth / 2)
	PNRP_HUD:compass(cxCompass,  marginY + height + bar.padding + 2, compWidth, HUD_var, HUD_col)
	
	PNRP_HUD:showGas((ScrW() / 2) - compWidth, marginY + height + bar.padding + 2, 20, 125, HUD_var, HUD_col)
end

--Not sure what this does atm
function PNRP_HUD:PaintRoundedPanel(r, x, y, w, h, color )
  
	x = x + 1; y = y + 1;
	w = w - 2; h = h - 2;
 
	draw.RoundedBox(r, x, y, w, h, color.background)
 
end

--Creates Text Label
function PNRP_HUD:PaintText( x, y, text, font, color )
 
	surface.SetFont( font );
 
	surface.SetTextPos( x + 1, y + 1 );
	surface.SetTextColor( color.shadow );
	surface.DrawText( text );
 
	surface.SetTextPos( x, y );
	surface.SetTextColor( color.text );
	surface.DrawText( text );
 
end

-- Paints the Status Bar
function PNRP_HUD:PaintBar( x, y, w, h, color, value )
 
	self:PaintPanel( x, y, w, h, color );
 
	x = x + 1; y = y + 1;
	w = w - 2; h = h - 2;
 
	local width = w * math.Clamp( value, 0, 1 );
	local shade = 4;
 
	surface.SetDrawColor( color.shade );
	surface.DrawRect( x, y, width, shade );
 
	surface.SetDrawColor( color.fill );
	surface.DrawRect( x, y + shade, width, h - shade );
 
end

-- Paints the Status Panel
function PNRP_HUD:PaintPanel( x, y, w, h, color )
 
	surface.SetDrawColor( color.border );
	surface.DrawOutlinedRect( x, y, w, h );
 
	x = x + 1; y = y + 1;
	w = w - 2; h = h - 2;
 
	surface.SetDrawColor( color.background );
	surface.DrawRect( x, y, w, h );
 
end

--Paints the XP Indicator
function PNRP_HUD:PaintXPIndic(x, y, var )
	surface.SetFont( var.font )
	surface.SetTextPos( x+5, y-6 )
	surface.color = Color(255,255,255,255)
	surface.DrawText( "XP: "..GetXP() )
end

--Paints the Inside Indicator
function PNRP_HUD:PaintInsideIndic(x, y, w, h, font, color )
	
	surface.SetFont( font )
	surface.SetTextPos( x+w+5, y-6 )
	surface.color = Color(255,255,255,255)
	
	if (LocalPlayer():IsOutside()) then
	
		surface.SetDrawColor( color.offfill ) 
		surface.DrawRect(x, y, w, h )
		
		surface.SetDrawColor( color.offhighlight ) 
		surface.DrawRect(x+1, y+1, w/2, h/2 )
		surface.DrawText( "Outside" )
	
	else 
	
		surface.SetDrawColor( color.onfill ) 
		surface.DrawRect(x, y, w, h )
		
		surface.SetDrawColor( color.onhighlight ) 
		surface.DrawRect(x+1, y+1, w/2, h/2 )
		surface.DrawText( "Inside" )
	end

end

--Gets the height of text
function PNRP_HUD:TextSize( text, font )
	surface.SetFont( font );
	return surface.GetTextSize( text );
 
end

function DrawInfoHUD( HUD )

	local ply = LocalPlayer()
	if ( !ply:Alive() ) then return end
	
	--Gets player Resources
	local scrap = GetResource("Scrap")
	local smallparts = GetResource("Small_Parts")
	local chems = GetResource("Chemicals")
	--Gets Player End %
	local endur = Endurance
	local endPerc = endur / 100
	
	--Top bar
	local hudPos = 15
	local hw, ht = ScrW(), 26 
	
	--Draws the Top Bae
	surface.SetDrawColor( 0, 0, 0, 255 )	
	surface.DrawRect( 0, 0, hw, ht )
	
	surface.SetDrawColor( 0, 0, 0, 255  )
	surface.DrawOutlinedRect( 0, 0, hw, ht )
	
	--Prints Scap
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetFont( HUD.info_font )
	surface.SetTextPos( hudPos + 25, 3 )
	surface.DrawText( "Scrap:  "..scrap )
	
	--Prints Small Parts
	hudPos = hudPos + 120
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetFont( HUD.info_font )
	surface.SetTextPos( hudPos, 3 )
	surface.DrawText( "Small Parts:  "..smallparts )
	
	--Prints Chems
	hudPos = hudPos + 120
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetFont( HUD.info_font )
	surface.SetTextPos( hudPos, 3 )
	surface.DrawText( "Chemicals:  "..chems )
	
	--Prints Player Class
	hudPos = hudPos + 120
	
	surface.SetTextColor( team.GetColor(ply:Team()) )
	surface.SetFont( HUD.info_font )
	surface.SetTextPos( hudPos, 3 )
	surface.DrawText( "Class:  "..team.GetName(ply:Team()) )
	
	--Prints the Clock
	hudPos = hudPos + 140
	
	local vtime
	vtime = os.date("Time: %X")
	
	surface.SetTextColor( Color( 255, 255, 255, 255 ) )
	surface.SetFont( HUD.info_font )
	surface.SetTextPos( hudPos, 3 )
	surface.DrawText( vtime )
	
	--Prints Ent's Owner
	hudPos = hudPos + 120
	
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 300
	trace.filter = ply
	local tr = util.TraceLine( trace )	
	
	local ent = tr.Entity
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetFont( HUD.info_font )
	surface.SetTextPos( hudPos, 3 )
	
	local OwnerNick = " "
	if IsValid(ent) then
		OwnerNick = ent:GetNetVar( "Owner", "None" )
	else
		OwnerNick = " "
	end
	
	surface.DrawText( "Owner:  "..OwnerNick)
	
	--Quick Key Referance (Bottom Bar)
	local hudBPos = 15
	local rfBarY = ScrH() -ht
	
	surface.SetDrawColor( 0, 0, 0, 255 )	
	surface.DrawRect( 0, rfBarY, hw, ht )
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetFont( HUD.info_font )
	surface.SetTextPos( hudBPos + 25, rfBarY + 3 )
	surface.DrawText( "Tab: Main Menu   F1: Help   F2: Pickup   F3: Inventory   F4: Shop   F5: Screenshot   F11: Take/Remove Ownership " )
	
end

--Radio
function PNRP_HUD:showRadio(x, y, h, w)
	local ply = LocalPlayer()
	--ply.Channel = frequency
	--self.Owner.RdioPower
	surface.SetDrawColor( Color( 255, 0, 0, 50 ) )
	local RdioTxt = "No radio"
	local rdioEnt
	local ply = LocalPlayer()
	for k, v in pairs(ply:GetWeapons()) do
		if(tostring(v:GetClass()) == 'weapon_radio') then
			surface.SetDrawColor( HUD_col.bg.background ) 
			RdioTxt = "- - - -"
			rdioEnt = v
		end
	end
		
	if rdioEnt then
		if ply.radioFreq then
		--	RdioTxt = rdioEnt.Frequency.."MHz"
			RdioTxt = ply.radioFreq.."MHz"
		end
	--	if rdioEnt.Power == "on" then
		if ply.radioPower then
			surface.SetDrawColor( Color( 0, 175, 0, 50 ) ) 
		else
			surface.SetDrawColor( Color( 255, 0, 0, 50 ) ) 
		end
	end
	
	surface.DrawRect(x, y, w, h)
--	PNRP_HUD:PaintRoundedPanel( 0, x, y, w, h, HUD_col.bg )
	surface.SetDrawColor( HUD_col.border );
	surface.DrawOutlinedRect( x, y, w, h );
	
	PNRP_HUD:PaintText( x + HUD_var.padding + 5, y + HUD_var.text_spacing, RdioTxt, HUD_var.font, HUD_col.text )
end

--Compass
function PNRP_HUD:compass(x,y,width,hudVar,colors)

	local _, txtHeight = PNRP_HUD:TextSize( "TEXT", hudVar.font ) --Gets the size (height) of the font
	
	local yaw
	
	if LocalPlayer():InVehicle() then
		yaw = LocalPlayer():GetVehicle():EyeAngles().y + 90
	else
		yaw = LocalPlayer():EyeAngles().y
	end
	
	--local width = 360 + (hudVar.text_spacing * 4)
	
	PNRP_HUD:PaintRoundedPanel( 0, x, y, width, txtHeight + (hudVar.text_spacing * 2), colors.bg )
	surface.SetDrawColor( colors.border );
	surface.DrawOutlinedRect( x, y, width, txtHeight + (hudVar.text_spacing * 2) );
	
	local sinX = math.sin((yaw)/180*math.pi)
	local cosX = math.cos((yaw)/180*math.pi)
	
	local center = x + 180
	
	local sinYawN = 180*math.sin((yaw)/180*math.pi) + center
	local sinYawS = -180*math.sin((yaw)/180*math.pi) + center
	local cosYawE = 180*math.cos((yaw)/180*math.pi) + center
	local cosYawW = -180*math.cos((yaw)/180*math.pi) + center
		
	if(cosX > 0) then
		PNRP_HUD:PaintText( sinYawN, y + hudVar.text_spacing, "N", hudVar.font, colors.text )
	end
	
	if(cosX < 0) then
		PNRP_HUD:PaintText( sinYawS, y + hudVar.text_spacing, "S", hudVar.font, colors.text )
	end
	
	if(sinX < 0) then
		PNRP_HUD:PaintText( cosYawE, y + hudVar.text_spacing, "E", hudVar.font, colors.text )
	end
	
	if(sinX > 0) then
		PNRP_HUD:PaintText( cosYawW, y + hudVar.text_spacing, "W", hudVar.font, colors.text )
	end
	
	--45 Degree Marks
	if(math.sin((yaw-45)/180*math.pi) < 0) then --NE
		local sinYawNE = 180*math.sin((yaw+45)/180*math.pi) + center
		PNRP_HUD:PaintText( sinYawNE, y + hudVar.text_spacing, "|", hudVar.font, colors.text )
	end

	if(math.sin((yaw-135)/180*math.pi) < 0) then --NW
		local sinYawNW = -180*math.sin((yaw+135)/180*math.pi) + center
		PNRP_HUD:PaintText( sinYawNW, y + hudVar.text_spacing, "|", hudVar.font, colors.text )
	end
	
	if(math.sin((yaw+45)/180*math.pi) < 0) then --SE
		local sinYawSW = -180*math.sin((yaw-45)/180*math.pi) + center
		PNRP_HUD:PaintText( sinYawSW, y + hudVar.text_spacing, "|", hudVar.font, colors.text )
	end
	
	if(math.cos((yaw+45)/180*math.pi) < 0) then --SW
		local sinYawSW = -180*math.cos((yaw-45)/180*math.pi) + center
		PNRP_HUD:PaintText( sinYawSW, y + hudVar.text_spacing, "|", hudVar.font, colors.text )
	end
	
	--Tics
	if(math.sin((yaw-67.5)/180*math.pi) < 0) then --NNE
		local sinYawNNE = 180*math.sin((yaw+22.5)/180*math.pi) + center
		PNRP_HUD:PaintText( sinYawNNE, y + hudVar.text_spacing, "'", hudVar.font, colors.text )
	end
	
	if(math.sin((yaw-25.5)/180*math.pi) < 0) then --ENE
		local sinYawENE = 180*math.sin((yaw+67.5)/180*math.pi) + center
		PNRP_HUD:PaintText( sinYawENE, y + hudVar.text_spacing, "'", hudVar.font, colors.text )
	end
	
	if(math.sin((yaw+25.5)/180*math.pi) < 0) then --ESE
		local sinYawESE = 180*math.sin((yaw+112.5)/180*math.pi) + center
		PNRP_HUD:PaintText( sinYawESE, y + hudVar.text_spacing, "'", hudVar.font, colors.text )
	end
	
	if(math.sin((yaw+67.5)/180*math.pi) < 0) then --SSE
		local sinYawSSE = 180*math.sin((yaw+157.5)/180*math.pi) + center
		PNRP_HUD:PaintText( sinYawSSE, y + hudVar.text_spacing, "'", hudVar.font, colors.text )
	end
	--
	if(math.sin((yaw+112.5)/180*math.pi) < 0) then --SSW
		local sinYawSSW = 180*math.sin((yaw-157.5)/180*math.pi) + center
		PNRP_HUD:PaintText( sinYawSSW, y + hudVar.text_spacing, "'", hudVar.font, colors.text )
	end
	
	if(math.sin((yaw+157.5)/180*math.pi) < 0) then --WSW
		local sinYawWSW = 180*math.sin((yaw-112.5)/180*math.pi) + center
		PNRP_HUD:PaintText( sinYawWSW, y + hudVar.text_spacing, "'", hudVar.font, colors.text )
	end
	
	if(math.sin((yaw-157.5)/180*math.pi) < 0) then --WNW
		local sinYawWNW = 180*math.sin((yaw-67.5)/180*math.pi) + center
		PNRP_HUD:PaintText( sinYawWNW, y + hudVar.text_spacing, "'", hudVar.font, colors.text )
	end
	
	if(math.sin((yaw-112.5)/180*math.pi) < 0) then --NNW
		local sinYawNNW = 180*math.sin((yaw-22.5)/180*math.pi) + center
		PNRP_HUD:PaintText( sinYawNNW, y + hudVar.text_spacing, "'", hudVar.font, colors.text )
	end
end

function PNRP_HUD:showGas(x,y,h,w,hudVar,colors)
	local ply = LocalPlayer()
	if ply:InVehicle() then
		local car = ply:GetVehicle()
		local gas = car.gas
		local tank = car.tank
		
		if !gas then gas = 0 end
		if !tank then tank = 0 end
		
		local showHUD = car:GetNetVar( "hud" , true )
		if showHUD then
			local gasW = w - 24
			local gX = x + 12
			local percent = 1 - ((tank - gas) / tank)
			local barPos = gasW * percent
			
			surface.SetDrawColor( colors.bg.background )
			surface.DrawRect(x+1, y+1, w, h )
			surface.SetDrawColor( colors.border )
			surface.DrawOutlinedRect( x, y, w+1, h+1 )
			
			PNRP_HUD:PaintText( x+4, y+2, "E", hudVar.font, colors.text )
			PNRP_HUD:PaintText( x+w-10, y+2, "F", hudVar.font, colors.text )
			
			surface.SetDrawColor( colors.text )
			surface.DrawRect( gX, y+2, 1, h-12 )
			surface.DrawRect( gX+ (gasW*0.25), y+2, 1, 5 )
			surface.DrawRect( gX+ (gasW*0.5), y+2, 1, h-10 )
			surface.DrawRect( gX+ (gasW*0.75), y+2, 1, 5 )
			surface.DrawRect( gX+ gasW, y+2, 1, h-12 )
			
			local gBarColor = Color(0,250,0,200)
			if percent < 0.1 then
				gBarColor = Color(250,0,0,200)
			end
			surface.SetDrawColor( gBarColor )
			surface.DrawRect( barPos+gX-1, y+4, 2, h-5 )
			
			if percent < 0.05 then
				surface.SetDrawColor( Color(250,0,0,200) )
				surface.DrawOutlinedRect( x-12, y+2, 10, 8 )
				surface.DrawRect( x-12, y+11, 10, 9 )
				surface.DrawRect( x-15, y+11, 3, 5 )
				surface.DrawRect( x-15, y+6, 1, 5 )
				surface.DrawRect( x-15, y+6, 4, 1 )
			end
		end
	end
end

--Progress Bar Code
local pbarStartTime
local pbarMaxTime
function ProgressBar()
	surface.SetDrawColor( 0, 0, 0, 100)
	surface.DrawRect(ScrW()/2 - 50 , ScrH()/2, 100, 25 )
	
	local percentage = (CurTime() - pbarStartTime) / pbarMaxTime
	
	surface.SetDrawColor( 0, 155, 0, 255 )
	surface.DrawOutlinedRect(ScrW()/2 - 50 , ScrH()/2, 100, 25 )
	surface.DrawRect(ScrW()/2 - 50 , ScrH()/2, 100*percentage, 25 )
end

function StartProgressBar( )
	local length = net:ReadDouble()
	
	pbarStartTime = CurTime()
	pbarMaxTime = length
	
	hook.Add( "HUDPaint", "ProgressBar", ProgressBar )
end
net.Receive("startProgressBar", StartProgressBar)

function StopProgressBar( )
	hook.Remove( "HUDPaint", "ProgressBar")
end
net.Receive("stopProgressBar", StopProgressBar)
---

function GM:DrawDeathNotice(x, y)
	local deathnotice = GetConVarNumber("pnrp_DeathNotice")
	local txtHeight = PNRP_HUD:TextSize( "TEXT", HUD_var.zombie_font )
	local height = HUD_var.bar_height + ( HUD_var.padding * 4 ) + txtHeight
	y = height / ScrH()
	if deathnotice == 1 then 
		self.BaseClass:DrawDeathNotice(x, y)
	else
		return
	end
end

--EOF