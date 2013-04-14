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

function ReceiveGas( )
	local ply = net:ReadEntity()
	local car = net:ReadEntity()
	local gas = net:ReadDouble()
	local tank = net:ReadDouble()
	
	car.gas = gas
	car.tank = tank
	
--	ply:ChatPrint(tostring(gas))
end
net.Receive("sndCarGas", ReceiveGas)