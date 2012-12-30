----------------------------------------
---  This file receives variable-sending 
---  usermessages
----------------------------------------
Hunger = 100
Endurance = 100

function ReceiveEndurance( um )
	Endurance = um:ReadShort()
end
usermessage.Hook("endurancemsg", ReceiveEndurance)

function ReceiveHunger( um )
	Hunger = um:ReadShort()
end
usermessage.Hook("hungermsg", ReceiveHunger)
