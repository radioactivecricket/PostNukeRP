

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
		text = Color( 255, 255, 255, 150 )
	},
	hp_bar =
	{
		border = Color( 255, 0, 0, 255 ),
		background = Color( 255, 0, 0, 75 ),
		shade = Color( 255, 104, 104, 150 ),
		fill = Color( 232, 0, 0, 150 )
 
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
		offfill = Color( 255, 0, 0, 75 ),
		onhighlight = Color( 200, 255, 200, 125 ),
		onfill = Color( 0, 175, 0, 75 )
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
	marginX = 5,
	marginY = 25,
 
	text_spacing = 2,
	bar_spacing = 5,
 
	bar_height = 5,
	bar_width = 100,
 
	width = 0.15
}

function PNRP:HUD_2()
	ply = client or LocalPlayer()	
	if( !ply:Alive() ) then return end	--If the player is dead, do not draw the HUD
	
	local _, txtHeight = PNRP_HUD:TextSize( "TEXT", HUD_var.font ) --Gets the size (height) of the font
	
	local i = 4		--Number of bars on the HUD (HP, Armor, End, Hunger)
	
	--Gets the players Max HP
	local MaxHealth = ply:GetNetVar( "MaxHealth", 100) 
	
	local stat = {
		HP = string.format( "Health: %iHP", ply:Health( ) ),	-- Heath Text
		POWER = string.format( "Power: %iSP", ply:Armor( ) ),	-- Suit text
		END = string.format( "Endurance: %i", Endurance ), -- Player Endurance
		HUNGER = string.format( "Hunger: %i", Hunger )	
		}
	
	local x = HUD_var.marginX
	local y = HUD_var.marginY
	
	--Flashes when HP Bar is low
	if ply:Health( ) < 40 then
 		HUD_col.hp_bar.fill = Color( 232 * math.abs(math.sin(CurTime()*2)), 0, 0, 255 )
 		HUD_col.hp_bar.shade = Color( 255 * math.abs(math.sin(CurTime()*2)), 104, 104, 255 )
 	else
 		HUD_col.hp_bar.shade = Color( 255, 104, 104, 255 )
		HUD_col.hp_bar.fill = Color( 232, 0, 0, 255 )
	end
	
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
	
	local barH = (HUD_var.padding * 2) + txtHeight + HUD_var.bar_height + HUD_var.text_spacing
	local bgH = (HUD_var.padding * 2) + txtHeight + HUD_var.bar_height + HUD_var.text_spacing
	local bgW = (HUD_var.padding * 2) + HUD_var.bar_width
	local offset = 0
	
	local hpVar = ply:Health( ) / MaxHealth 
	makeBar(x, y + offset, bgH, bgW ,"Health:", ply:Health( ), HUD_col, HUD_col.hp_bar, hpVar)
	
	offset = offset + barH + HUD_var.bar_spacing
	local arVar = ply:Armor( ) / 100 
	makeBar(x, y + offset, bgH, bgW , "Power:", ply:Armor( ), HUD_col, HUD_col.suit_bar, arVar)
	
	offset = offset + barH + HUD_var.bar_spacing
	local endPerc = Endurance / 100
	makeBar(x, y + offset, bgH, bgW , "Endurance:", Endurance, HUD_col, HUD_col.end_bar, endPerc)
	--Inside Indicator
	insideInd(x + bgW + HUD_var.text_spacing, y + offset, bgH, 5)
	
	offset = offset + barH + HUD_var.bar_spacing
	local hungPerc = Hunger / 100
	makeBar(x, y + offset, bgH, bgW , "Hunger:", Hunger, HUD_col, HUD_col.hunger_bar, hungPerc)
	
	--XP, Ownership, Inside Indicator, clock, class, Resources
	
	--Bottem Left Info Panel
	local infPH = txtHeight + (HUD_var.padding * 2)
	local infPW = 150
	local infoPainNum = 3 --Number of items in the info pains
	local blX = HUD_var.marginX
	local blY = ScrH() - HUD_var.marginY - (infPH * infoPainNum)
--	surface.SetDrawColor( 200, 200, 200, 90 ) 
--	surface.SetMaterial( Material( "vgui/spawnmenu/bg" ) )
--	surface.DrawTexturedRect( blX, blY, infPW, infPH ) 
	
	--Gets player Resources
	local scrap      = GetResource("Scrap")
	local smallparts = GetResource("Small_Parts")
	local chems      = GetResource("Chemicals")
	
	local txtYOffset = 0
	local xOffset = blX + infPW + HUD_var.bar_spacing
	--Scrap
	PNRP_HUD:PaintRoundedPanel( 0, blX, blY + txtYOffset, infPW, infPH, HUD_col.bg )
	surface.SetDrawColor( HUD_col.border );
	surface.DrawOutlinedRect( blX, blY + txtYOffset, infPW, infPH );
	PNRP_HUD:PaintText( blX + HUD_var.padding + 5, blY + txtYOffset + HUD_var.padding, "Scrap:", HUD_var.font, HUD_col.text )
	PNRP_HUD:PaintText( blX + HUD_var.padding + 90, blY + txtYOffset + HUD_var.padding, scrap, HUD_var.font, HUD_col.text )
	
	--Small Parts
	txtYOffset = txtYOffset + txtHeight + HUD_var.text_spacing + (HUD_var.bar_spacing * 2)
	PNRP_HUD:PaintRoundedPanel( 0, blX, blY + txtYOffset, infPW, infPH, HUD_col.bg )
	surface.SetDrawColor( HUD_col.border );
	surface.DrawOutlinedRect( blX, blY + txtYOffset, infPW, infPH );
	PNRP_HUD:PaintText( blX + HUD_var.padding + 5, blY + txtYOffset + HUD_var.padding, "Small Parts:", HUD_var.font, HUD_col.text )
	PNRP_HUD:PaintText( blX + HUD_var.padding + 90, blY + txtYOffset + HUD_var.padding, smallparts, HUD_var.font, HUD_col.text )
	
	--Chems
	txtYOffset = txtYOffset + txtHeight + HUD_var.text_spacing + (HUD_var.bar_spacing * 2)
	PNRP_HUD:PaintRoundedPanel( 0, blX, blY + txtYOffset, infPW, infPH, HUD_col.bg )
	surface.SetDrawColor( HUD_col.border );
	surface.DrawOutlinedRect( blX, blY + txtYOffset, infPW, infPH );
	PNRP_HUD:PaintText( blX + HUD_var.padding + 5, blY + txtYOffset + HUD_var.padding, "Chemicals:", HUD_var.font, HUD_col.text )
	PNRP_HUD:PaintText( blX + HUD_var.padding + 90, blY + txtYOffset + HUD_var.padding, chems, HUD_var.font, HUD_col.text )
	
	--XP
	PNRP_HUD:PaintRoundedPanel( 0, xOffset, blY + txtYOffset, infPW, infPH, HUD_col.bg )
	surface.SetDrawColor( HUD_col.border );
	surface.DrawOutlinedRect( xOffset, blY + txtYOffset, infPW, infPH );
	PNRP_HUD:PaintText( xOffset + HUD_var.padding + 5, blY + txtYOffset + HUD_var.padding, "Experience:", HUD_var.font, HUD_col.text )
	PNRP_HUD:PaintText( xOffset + HUD_var.padding + 90, blY + txtYOffset + HUD_var.padding, GetXP(), HUD_var.font, HUD_col.text )
	
	local compWidth = 360 + (HUD_var.text_spacing * 4)
	local cxCompass = (ScrW() / 2) - (compWidth / 2)
	PNRP_HUD:compass(cxCompass, HUD_var.marginY, compWidth, HUD_var, HUD_col)
	
	--Clock
	local vtime
	vtime = os.date("%X")
	local vTimeY = HUD_var.marginY + (HUD_var.padding * 2) + txtHeight + HUD_var.bar_spacing
	local vTimeX = cxCompass
	local CHeight = txtHeight + (HUD_var.text_spacing * 2)
	local CWidth = 75
	PNRP_HUD:PaintRoundedPanel( 0, vTimeX, vTimeY, CWidth, CHeight, HUD_col.bg )
	surface.SetDrawColor( HUD_col.border );
	surface.DrawOutlinedRect( vTimeX, vTimeY, CWidth, CHeight );
	PNRP_HUD:PaintText( vTimeX + HUD_var.padding + 5, vTimeY + HUD_var.text_spacing, vtime, HUD_var.font, HUD_col.text )
	
	local tgoWidth = compWidth-(CWidth*2)-(HUD_var.bar_spacing*2)
	showOwner((ScrW() / 2) - (tgoWidth / 2), vTimeY, CHeight, tgoWidth)
	
	PNRP_HUD:showRadio((ScrW() / 2) + (compWidth / 2) -75, vTimeY, CHeight, CWidth)
	
	PNRP_HUD:showGas((ScrW() / 2) - compWidth, HUD_var.marginY, 20, 125, HUD_var, HUD_col)
end


function showOwner(x, y, h, w)
	local ply = LocalPlayer()
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 300
	trace.filter = ply
	local tr = util.TraceLine( trace )	
	
	local ent = tr.Entity
	local targetSTR = " "
	
	if IsValid(ent) then
		local OwnerNick = ent:GetNetVar( "Owner", "None" )
		
		if(OwnerNick == "None") then
			targetSTR = "Press F11 to own"
		elseif(ent:IsWorld()) then
			targetSTR = "World"
		else
			targetSTR = OwnerNick
		end
	else
		targetSTR = " "
	end
	
	PNRP_HUD:PaintRoundedPanel( 0, x, y, w, h, HUD_col.bg )
	surface.SetDrawColor( HUD_col.border );
	surface.DrawOutlinedRect( x, y, w, h );
	
	PNRP_HUD:PaintText( x + HUD_var.padding + 5, y + HUD_var.text_spacing, targetSTR, HUD_var.font, HUD_col.text )
end

function insideInd(x, y, h, w)
	
	if (LocalPlayer():IsOutside()) then
		surface.SetDrawColor( HUD_col.inside_indic.offfill ) 
		
	else
		surface.SetDrawColor( HUD_col.inside_indic.onfill ) 
	end
	
	surface.DrawRect(x, y, w, h)
	
	PNRP_HUD:PaintRoundedPanel( 0, x-1, y, w, h, HUD_col.bg )
	surface.SetDrawColor( HUD_col.border );
	surface.DrawOutlinedRect( x, y, w, h );

end

function makeBar(x, y, bgH, bgW, txt1, txt2, color, barcolor, barVar)

	local _, txtHeight = PNRP_HUD:TextSize( "TEXT", HUD_var.font ) --Gets the size (height) of the font

	local bar_width = HUD_var.bar_width
	local bar_height = HUD_var.bar_height
	
--	local bgH = (HUD_var.padding * 2) + txtHeight + bar_height + HUD_var.text_spacing
--	local bgW = (HUD_var.padding * 2) + bar_width
	
--	surface.SetDrawColor( 200, 200, 200, 90 ) 
--	surface.SetMaterial( Material( "vgui/spawnmenu/bg" ) )
--	surface.DrawTexturedRect( x, y, bgW, bgH ) 
	surface.SetDrawColor( HUD_col.border );
	surface.DrawOutlinedRect( x, y, bgW, bgH );
	PNRP_HUD:PaintRoundedPanel( 0, x, y, bgW, bgH, color.bg )
	
	--Paints the Bar TXT
	local txtY = y + HUD_var.padding
	PNRP_HUD:PaintText( x + HUD_var.padding, txtY, txt1, HUD_var.font, color.text )
	PNRP_HUD:PaintText( x + HUD_var.padding + 75, txtY, txt2, HUD_var.font, color.text )
	
	--Paints the Bar
	local barY = y + txtHeight + HUD_var.text_spacing
	PNRP_HUD:PaintBar( x + HUD_var.padding, barY, bar_width, bar_height, barcolor, barVar )

end

