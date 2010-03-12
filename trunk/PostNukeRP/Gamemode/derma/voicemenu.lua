
-------------------
-- Quick acess voice menu
-------------------

local voice_frame

function GM.OpenVoiceMenu( ply )
	voice_frame = vgui.Create( "DFrame" )
		voice_frame:SetSize( 425, 60 ) --Set the size
		voice_frame:SetPos(ScrW() / 2 - voice_frame:GetWide() / 2, ScrH() - voice_frame:GetTall() - 26 ) --Set the window in the middle of the players screen/game window
		voice_frame:SetTitle( "Voice Menu" ) --Set title
		voice_frame:SetVisible( true )
		voice_frame:SetDraggable( true )
		voice_frame:ShowCloseButton( false )
	
	local combatmenu = vgui.Create("DButton") -- Create the button
		combatmenu:SetParent( voice_frame )
		combatmenu:SetText( "Combat" )
		combatmenu:SetPos(25, 30) -- set the button position in the frame
		combatmenu:SetSize( 100, 20 ) -- set the button size
		combatmenu.DoClick = function ( btn ) 
						local combatvoices = DermaMenu()
						combatvoices:AddOption("Incoming!", function() RunConsoleCommand("say", "Incoming!") end)
						combatvoices:AddOption("Hacks!", function() RunConsoleCommand("say", "Hacks!") end)
						combatvoices:AddOption("Get down!", function() RunConsoleCommand("say", "Get down!") end)
						combatvoices:AddOption("Get out!", function() RunConsoleCommand("say", "Get out!") end)
						combatvoices:AddOption("Behind you!", function() RunConsoleCommand("say", "Behind you!") end)
						combatvoices:Open()
			end
	
	local exprmenu = vgui.Create("DButton") -- Create the button
		exprmenu:SetParent( voice_frame )
		exprmenu:SetText( "Expressions" )
		exprmenu:SetPos(150, 30) -- set the button position in the frame
		exprmenu:SetSize( 100, 20 ) -- set the button size
		exprmenu.DoClick = function ( btn ) 
						local exprvoices = DermaMenu()
						exprvoices:AddOption("Omg.", function() RunConsoleCommand("say", "Omg.") end)
						exprvoices:AddOption("Omfg!", function() RunConsoleCommand("say", "Omfg!") end)
						exprvoices:AddOption("Hax!", function() RunConsoleCommand("say", "Hax!") end)
						exprvoices:AddOption("Fantastic!", function() RunConsoleCommand("say", "Fantastic!") end)
						exprvoices:Open()
			end
			
	local socialmenu = vgui.Create("DButton") -- Create the button
		socialmenu:SetParent( voice_frame )
		socialmenu:SetText( "Social" )
		socialmenu:SetPos(275, 30) -- set the button position in the frame
		socialmenu:SetSize( 100, 20 ) -- set the button size
		socialmenu.DoClick = function ( btn ) 
						local socialvoices = DermaMenu()
						socialvoices:AddOption("Excuse me.", function() RunConsoleCommand("say", "Excuse me.") end)
						socialvoices:AddOption("Im busy.", function() RunConsoleCommand("say", "Im busy.") end)
						socialvoices:Open()
			end
end
concommand.Add( "pnrp_open_voice", GM.OpenVoiceMenu )


function GM.CloseVoiceMenu( ply )
	voice_frame:Close()
end
concommand.Add( "pnrp_close_voice", GM.CloseVoiceMenu )
