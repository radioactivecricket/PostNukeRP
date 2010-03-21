----------------------------------------
---  This file receives variable-sending 
---  usermessages
----------------------------------------

function ReceiveEndurance( um )
	Endurance = um:ReadShort()
end
usermessage.Hook("endurancemsg", ReceiveEndurance)
