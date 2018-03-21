--For creating labels of stuff

function PNRP.DrawDeathZombieLabel()
	local myPlayer = LocalPlayer()
	local zombieFont = "CenterPrintText"
	local tracedata = {}
	tracedata.start = myPlayer:GetShootPos()
	tracedata.endpos = tracedata.start + (myPlayer:GetAimVector() * 600)
	tracedata.filter = myPlayer
	local trace = util.TraceLine(tracedata)
	
	if (not trace.Entity) or (not IsValid(trace.Entity)) then return end
	
	if trace.Entity:GetClass() == "npc_zombie" then
		local zombieName = trace.Entity:GetNetVar("deadplayername", "")

		if string.len(zombieName) > 0 then 
		
			surface.SetFont(zombieFont)
			local ZNameText = zombieName.."'s Zombie"
			local tWidth, tHeight = surface.GetTextSize(ZNameText)
			
			draw.WordBox( 8, (ScrW() / 2) - (8 + (tWidth / 2)), (ScrH() / 2) - (16 + tHeight), ZNameText, zombieFont, Color(50,50,75,100), Color(255,255,255,255) )
		end	
	end
end

function GM:HUDDrawTargetID()
	local ply = LocalPlayer()
	
	local showdebug = false
	
	if GetConVarNumber("pnrp_debug") == 1 then
		showdebug = true
	end
	
	if IsValid(ply) then
		if not ply:IsAdmin() then
			showdebug = false
		end
	end

	local ents = ents.FindInSphere(ply:GetPos(), 1024)
	for _, ent in ipairs( ents ) do
		if IsValid(ent) then
						
			if ( ent != ply and ent:Health() > 0 and ent:GetNetVar("Pet", "no")=="yes" ) then
				PetHUDLabel(ent)
			elseif ( ent != ply and ent:Health() > 0 and ent:IsPlayer() ) then
			
				local td = {}
				td.start = LocalPlayer():GetShootPos()
				td.endpos = ent:GetShootPos()
				local trace = util.TraceLine( td )
				
				local traceBlocked = "false"
				if (not trace.Entity) or (not IsValid(trace.Entity)) then
					traceBlocked = "false"
				else
					if trace.Entity:GetClass() == "prop_physics" then
						traceBlocked = "true"
					end
				end
				
				if ( !trace.HitWorld ) and traceBlocked == "false" then	
					local pos = ent:GetShootPos()
					local bone = ent:LookupBone( "ValveBiped.Bip01_Head1" )
					if ( bone ) then
						pos = ent:GetBonePosition( bone )
					end		
					
					local nick = ent:Nick()
					local community = ent:GetNetVar("community", "N/A")
					local title = ent:GetNetVar("ctitle", " ")
					
					local drawPos = ent:GetShootPos():ToScreen()
					local textXPos = ent:GetShootPos():ToScreen()
					local distance = ply:GetShootPos():Distance( pos )
					
					local font = "TargetIDSmall"
					local font2 = "HudHintTextSmall"
					local h
					
					if community == "N/A" then
						h = 24
						title = ""
						community = ""
					else
						if title == " " or title == "" then
							h = 35
						else
							h = 45
						end
					end
					surface.SetFont( font )
					local wNick = surface.GetTextSize( nick ) + 32
					local wCommunity = surface.GetTextSize( community ) + 32
					local wTitle = surface.GetTextSize( title ) + 32
					local w = math.max(wNick, wCommunity, wTitle)

					drawPos.x = drawPos.x - w / 2
					drawPos.y = drawPos.y - h - 45
					
					local alpha = 255
					if ( distance > 64 ) then
						alpha = 120 - math.Clamp( ( distance - 128 ) / ( 1024 - 128 ) * 255, 0, 255 )
					end
					
					surface.SetDrawColor( 62, 62, 62, alpha )
					surface.DrawRect( drawPos.x, drawPos.y, w, h )
					local teamColor = team.GetColor(ent:Team())
					surface.SetDrawColor( teamColor.r, teamColor.g, teamColor.b, alpha )
					surface.DrawOutlinedRect( drawPos.x, drawPos.y, w, h )
					
					local plyCid = tonumber(ply:GetNetVar("cid", -1))
					local oCid = tonumber(ent:GetNetVar("cid", -1))
					
					local text
					
					text = ent:Nick()
										
					local cMaterial = nil
					local cStatus = "none"
					if plyCid >= 0 and oCid >= 0 then
						if plyCid == oCid then
							cMaterial = "gui/icons/flag_green.png"
						else
							
							if ply.ComDiplomacy then
								cStatus = ply.ComDiplomacy[tonumber(oCid)]
							--	text = text.." "..table.ToString(ply.ComDiplomacy).." "..oCid
							end
							
							if cStatus == "ally" then
								cMaterial = "gui/icons/flag_blue.png"
							elseif cStatus == "war" then 
								cMaterial = "gui/icons/flag_red.png"
							else	
								cMaterial = nil
							end
							
						end
						if cMaterial ~= nil then
							surface.SetDrawColor( 255, 255, 255, alpha )
							surface.SetMaterial( Material( cMaterial ) )
							surface.DrawTexturedRect( textXPos.x -((w/2)+16), drawPos.y +15, 15, 15 ) 
						end
					end
					
					
					draw.DrawText( text, font, textXPos.x, drawPos.y + 5, Color(255,255,255,alpha), TEXT_ALIGN_CENTER )
					draw.DrawText( community, font2, textXPos.x, drawPos.y + 20, Color(255,255,255,alpha), TEXT_ALIGN_CENTER )
					draw.DrawText( title, font2, textXPos.x, drawPos.y + 30, Color(255,255,255,alpha), TEXT_ALIGN_CENTER )
				end
			end
			if showdebug then
				local item = PNRP.SearchItembase( ent )
				if item then
					local pos = ent:GetPos()
					
					local drawPos = ent:GetPos():ToScreen()
					local textXPos = ent:GetPos():ToScreen()
					local distance = ply:GetShootPos():Distance( pos )
					
					local font = "TargetIDSmall"
					local h = 48
					
					local text = ""
					text = text..item.Name.." ["..item.ID.."]\n"
					text = text..tostring(ent).." HP:"..ent:Health()
					if ent.gas then text = text.." Gas:"..tostring(math.Round(ent.gas, 2)) end
					
					surface.SetFont( font )
					local w = surface.GetTextSize( text ) + 32
					
					drawPos.x = drawPos.x - w / 2
					drawPos.y = drawPos.y - h - 25
					
					local alpha = 255
					if ( distance > 64 ) then
						alpha = 120 - math.Clamp( ( distance - 128 ) / ( 1024 - 128 ) * 255, 0, 255 )
					end
					
					surface.SetDrawColor( 62, 62, 62, alpha )
					surface.DrawRect( drawPos.x, drawPos.y, w, h )
															
					draw.DrawText( text, font, textXPos.x, drawPos.y + 5, Color(255,255,255,alpha), TEXT_ALIGN_CENTER )

				end
			end
			
		end
	end

end

function PowerUsageHUDLabel()
	local myPlayer = LocalPlayer()
	if IsValid(myPlayer) then
		local tracedata = {}
		tracedata.start = myPlayer:GetShootPos()
		tracedata.endpos = tracedata.start + (myPlayer:GetAimVector() * 1000)
		tracedata.filter = myPlayer
		local trace = util.TraceLine(tracedata)
		
		if !trace.Entity:IsValid() then return end
		
		if IsValid(myPlayer:GetActiveWeapon()) then
			if myPlayer:GetActiveWeapon():GetClass() == "gmod_tool" then
				if tostring(myPlayer:GetActiveWeapon():GetMode()) == "pnrp_powerlinker" then
					if trace.Entity:GetNetVar("PowerUsage", "none") ~= "none" then
						local font = "CenterPrintText"
						local text = "Required Power: "..tostring(-tonumber(trace.Entity:GetNetVar("PowerUsage")))
						surface.SetFont(font)
						local tWidth, tHeight = surface.GetTextSize(text)
						
						draw.WordBox( 8, (ScrW() / 2) - (8 + (tWidth / 2)), (ScrH() / 2) - (16 + tHeight), text, font, Color(50,50,75,100), Color(255,255,255,255) )
					end
				end
			end
		end
	end
end
hook.Add( "HUDPaint", "PowerUsageHUDLabel", PowerUsageHUDLabel )

function PetHUDLabel(ent)
	local ply = LocalPlayer()
	
	if IsValid(ent) then
		if ( ent != ply and ent:Health() > 0 ) then
		
			local td = {}
			td.start = LocalPlayer():GetShootPos()
			td.endpos = ent:GetPos()
			local trace = util.TraceLine( td )
			
			if ( !trace.HitWorld ) then	
				local pos = ent:GetPos()
				local bone = ent:LookupBone( "ValveBiped.Bip01_Head1" )
				if ( bone ) then
					pos = ent:GetBonePosition( bone )
				end		
				
				local name = ent:GetNetVar("name", "Pet")

				local drawPos = ent:GetPos():ToScreen()
				local textXPos = ent:GetPos():ToScreen()
				local distance = ply:GetShootPos():Distance( pos )
				
				local font = "TargetIDSmall"
				local font2 = "HudHintTextSmall"
				local h = 24
				
				surface.SetFont( font )
				local wName = surface.GetTextSize( name ) + 32
				local w = wName
								
				drawPos.x = drawPos.x - w / 2
				drawPos.y = drawPos.y - h - 80
				
				local alpha = 180
				if ( distance > 64 ) then
					alpha = 120 - math.Clamp( ( distance - 128 ) / ( 1024 - 128 ) * 255, 0, 255 )
				end
				
				surface.SetDrawColor( 62, 62, 62, alpha )
				surface.DrawRect( drawPos.x, drawPos.y, w, h )
				surface.SetDrawColor( 150,150,150,alpha )
				surface.DrawOutlinedRect( drawPos.x, drawPos.y, w, h )
				
				local text
				
				text = name
				
				draw.DrawText( text, font, textXPos.x, drawPos.y + 5, Color(255,255,255,alpha), TEXT_ALIGN_CENTER )
			end
		end
	end
	
end

