----------------------------------------
---  This file receives variable-sending 
---  usermessages
----------------------------------------
Hunger = 100
Endurance = 100

function ReceiveEndurance( )
	Endurance = math.Round(net:ReadDouble())
end
net.Receive("endurancemsg", ReceiveEndurance)

function ReceiveHunger( )
	Hunger = math.Round(net:ReadDouble())
end
net.Receive("hungermsg", ReceiveHunger)
