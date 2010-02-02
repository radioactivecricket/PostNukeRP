local chatsounds = {}


chatsounds["omg"] = "vo/NovaProspekt/al_ohmygod.wav"

function PNRP.ChatSounds( ply, text )

	for k, v in pairs( chatsounds ) do
	
		if string.find( string.lower( text ), k ) then
		
			ply:EmitSound( v )
			
		end
		
	end
	
end
	
hook.Add("PlayerSay", "PNRPChatSounds", PNRP.ChatSounds)