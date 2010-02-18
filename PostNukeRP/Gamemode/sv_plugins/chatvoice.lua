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


function GM:PlayerCanHearPlayersVoice( pListener, pTalker )
	local curDistance = pListener:GetShootPos():Distance(pTalker:GetShootPos())
	local maxDistance = GetConVarNumber("pnrp_voiceDist")
	
	if GetConVarNumber("pnrp_voiceLimit") == 1 then
		if curDistance < maxDistance then
			return true
		else
			return false
		end
	end
	return true
end

function GM:PlayerCanSeePlayersChat( strText, bTeamOnly, pListener, pTalker )
	local curDistance = pListener:GetShootPos():Distance(pTalker:GetShootPos())
	local maxDistance = GetConVarNumber("pnrp_voiceDist")
	
	if GetConVarNumber("pnrp_voiceLimit") == 1 then
		if curDistance < maxDistance then
			return true
		else
			return false
		end
	end
	return true
end

--EOF