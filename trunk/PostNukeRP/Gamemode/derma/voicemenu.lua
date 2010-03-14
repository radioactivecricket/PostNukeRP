
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
				local combatcommands = combatvoices:AddSubMenu("Commands")
					combatcommands:AddOption("Follow me!", function() RunConsoleCommand("say", "Follow me!") end)
					combatcommands:AddOption("Heads up!", function() RunConsoleCommand("say", "Heads up!") end)
					combatcommands:AddOption("Take cover!", function() RunConsoleCommand("say", "Take cover!") end)
					combatcommands:AddOption("Get down!", function() RunConsoleCommand("say", "Get down!") end)
					combatcommands:AddOption("Get the hell out!", function() RunConsoleCommand("say", "Get the hell out of here!") end)
					combatcommands:AddOption("Run!", function() RunConsoleCommand("say", "Run!") end)
				
				local combatsupply = combatvoices:AddSubMenu("Supplies")
					combatsupply:AddOption("Take this medkit.", function() RunConsoleCommand("say", "Take this medkit.") end)
					combatsupply:AddOption("Take some ammo.", function() RunConsoleCommand("say", "Take some ammo.") end)
				
				local combatreports = combatvoices:AddSubMenu("Reports")
					combatreports:AddOption("Incoming!", function() RunConsoleCommand("say", "Incoming!") end)
					combatreports:AddOption("Behind you!", function() RunConsoleCommand("say", "Behind you!") end)
					combatreports:AddOption("Zombies!", function() RunConsoleCommand("say", "Zombies!") end)
					combatreports:AddOption("Reloading!", function() RunConsoleCommand("say", "Reloading!") end)
					combatreports:AddOption("I'm hurt!", function() RunConsoleCommand("say", "Im hurt!") end)
					combatreports:AddOption("Help!", function() RunConsoleCommand("say", "Help!") end)
				
				combatvoices:AddSpacer()
				
				local combattaunts = combatvoices:AddSubMenu("Taunts")
					combattaunts:AddOption("Put it on your tombstone.", function() RunConsoleCommand("say", "I'll put it on your tombstone.") end)
					combattaunts:AddOption("Not part of the plan.", function() RunConsoleCommand("say", "I'm pretty sure this wasn't part of the plan.") end)
					combattaunts:AddOption("Got one!", function() RunConsoleCommand("say", "Got one!") end)
				
				local combatconfirm = combatvoices:AddSubMenu("Confirmations")
					combatconfirm:AddOption("Ok.", function() RunConsoleCommand("say", "Okay.") end)
					combatconfirm:AddOption("Affirmative.", function() RunConsoleCommand("say", "Ok, I'm going!") end)
					combatconfirm:AddOption("I'm with you.", function() RunConsoleCommand("say", "I'm with you.") end)
					combatconfirm:AddOption("Lead the way!", function() RunConsoleCommand("say", "Lead the way!") end)
					combatconfirm:AddOption("Coming!", function() RunConsoleCommand("say", "Im coming!") end)
					combatconfirm:AddOption("Wait for me!", function() RunConsoleCommand("say", "Wait for me!") end)
					combatconfirm:AddOption("I'll stay here.", function() RunConsoleCommand("say", "Ill stay here.") end)
				
				combatvoices:AddOption("Hacks!", function() RunConsoleCommand("say", "Hacks!") end)
				
				combatvoices:Open()
			end
	
	local exprmenu = vgui.Create("DButton") -- Create the button
		exprmenu:SetParent( voice_frame )
		exprmenu:SetText( "Expressions" )
		exprmenu:SetPos(150, 30) -- set the button position in the frame
		exprmenu:SetSize( 100, 20 ) -- set the button size
		exprmenu.DoClick = function ( btn ) 
				local exprvoices = DermaMenu()
				local exprexperiences = exprvoices:AddSubMenu("Experiences")
					exprexperiences:AddOption("Omg.", function() RunConsoleCommand("say", "Omg.") end)
					exprexperiences:AddOption("Omfg!", function() RunConsoleCommand("say", "Omfg!") end)
					exprexperiences:AddOption("Deja vu.", function() RunConsoleCommand("say", "Woah!  Deja vu.") end)
				
				local exprexclam = exprvoices:AddSubMenu("Exclamations")
					exprexclam:AddOption("Fantastic!", function() RunConsoleCommand("say", "Fantastic!") end)
					exprexclam:AddOption("Nice!", function() RunConsoleCommand("say", "Nice!") end)
					exprexclam:AddOption("Yeah!", function() RunConsoleCommand("say", "Yeah!") end)
					exprexclam:AddOption("Right on!", function() RunConsoleCommand("say", "Right on!") end)
					exprexclam:AddOption("Bullshit!", function() RunConsoleCommand("say", "Bullshit!") end)
				
				exprvoices:AddOption("Hax!", function() RunConsoleCommand("say", "Hax!") end)
				exprvoices:Open()
			end
			
	local socialmenu = vgui.Create("DButton") -- Create the button
		socialmenu:SetParent( voice_frame )
		socialmenu:SetText( "Social" )
		socialmenu:SetPos(275, 30) -- set the button position in the frame
		socialmenu:SetSize( 100, 20 ) -- set the button size
		socialmenu.DoClick = function ( btn ) 
				local socialvoices = DermaMenu()
				local socialpolite = socialvoices:AddSubMenu("Common")
					socialpolite:AddOption("Hello.", function() RunConsoleCommand("say", "Hello.") end)
					socialpolite:AddOption("I'm ready.", function() RunConsoleCommand("say", "Ok, Im ready.") end)
					socialpolite:AddOption("Over here!", function() RunConsoleCommand("say", "Over here!") end)
					socialpolite:AddOption("Excuse me.", function() RunConsoleCommand("say", "Excuse me.") end)
					socialpolite:AddOption("Pardon me.", function() RunConsoleCommand("say", "Pardon me.") end)
					socialpolite:AddOption("Sorry.", function() RunConsoleCommand("say", "Sorry.") end)
					socialpolite:AddOption("Get out of your way.", function() RunConsoleCommand("say", "Lemme get out of your way.") end)
					
				local socialneeds = socialvoices:AddSubMenu("Needs")
				socialneeds:AddOption("Im hungry.", function() RunConsoleCommand("say", "Im hungry.") end)
				socialneeds:AddOption("Im hurt.", function() RunConsoleCommand("say", "Im hurt.") end)
				socialneeds:AddOption("I cant remember...", function() RunConsoleCommand("say", "I cant remember...") end)
				
				local socialpess = socialvoices:AddSubMenu("Pessamistic")
				socialpess:AddOption("Leave it alone...", function() RunConsoleCommand("say", "Leave it alone...") end)
				socialpess:AddOption("I dont dream...", function() RunConsoleCommand("say", "I dont dream anymore...") end)
				socialpess:AddOption("All getting worse...", function() RunConsoleCommand("say", "Looks to me like it's all getting worse, not better.") end)
				socialpess:AddOption("Odds are not good.", function() RunConsoleCommand("say", "I'm not a betting man, but the odds are not good.") end)
				socialpess:AddOption("One of those days.", function() RunConsoleCommand("say", "I just new it was going to be one of those days.") end)
				
				local socialopti = socialvoices:AddSubMenu("Optamistic")
				socialopti:AddOption("Never know.", function() RunConsoleCommand("say", "Leave it alone...") end)
				socialopti:AddOption("Wanna bet?", function() RunConsoleCommand("say", "Wanna bet?") end)
				socialopti:AddOption("Someday...", function() RunConsoleCommand("say", "Someday, this will all be a bad memory.") end)
				socialopti:AddOption("I wont hold it against you.", function() RunConsoleCommand("say", "I wont hold it against you.") end)
				
				local socialrude = socialvoices:AddSubMenu("Rude")
				socialrude:AddOption("Talking to yourself.", function() RunConsoleCommand("say", "You're talking to yourself again.") end)
				socialrude:AddOption("Why are you telling me?", function() RunConsoleCommand("say", "Why are you telling me?") end)
				
				local socialbusy = socialvoices:AddSubMenu("Busy")
				socialbusy:AddOption("Im busy.", function() RunConsoleCommand("say", "Im busy.") end)
				socialbusy:AddOption("Can we talk later?", function() RunConsoleCommand("say", "Can we talk later?") end)
				
				local socialmisc = socialvoices:AddSubMenu("Misc")
				socialmisc:AddOption("Know what you mean.", function() RunConsoleCommand("say", "Know what you mean.") end)
				socialmisc:AddOption("One way of looking at it.", function() RunConsoleCommand("say", "One way of looking at it.") end)
				socialmisc:AddOption("Concentrate.", function() RunConsoleCommand("say", "Let's concentrate on the task at hand...") end)
				socialmisc:AddOption("Mind is in the gutter.", function() RunConsoleCommand("say", "Your mind is in the gutter...") end)
				socialmisc:AddOption("How about that?", function() RunConsoleCommand("say", "How about that?") end)
				
				socialvoices:Open()
			end
end
concommand.Add( "pnrp_open_voice", GM.OpenVoiceMenu )


function GM.CloseVoiceMenu( ply )
	voice_frame:Close()
end
concommand.Add( "pnrp_close_voice", GM.CloseVoiceMenu )
