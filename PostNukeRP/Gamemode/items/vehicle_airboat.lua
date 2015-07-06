local ITEM = {}


ITEM.ID = "vehicle_airboat"

ITEM.Name = "Airboat"
ITEM.ClassSpawn = "Engineer"
ITEM.Scrap = 300
ITEM.Small_Parts = 150
ITEM.Chemicals = 50
ITEM.Chance = 100
ITEM.Info = ""
ITEM.Type = "vehicle"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "prop_vehicle_airboat"
ITEM.Model = "models/airboat.mdl"
ITEM.Script = "scripts/vehicles/airboat.txt"
ITEM.Weight = 20
ITEM.Capacity =  200

function ITEM.ToolCheck( p )
	return {["intm_engine"]=1}
end

function ITEM.Use( ply )
	return true	
end

function ITEM.Create( ply, class, pos )
	local ent = ents.Create(ITEM.Ent)
	
	ent:SetAngles(Angle(0,0,0))
	ent:SetPos(pos)
	Msg(tostring(ITEM.Model).."\n")
	//This fixes the seating animation for the seats
	if(ITEM.Ent == "prop_vehicle_prisoner_pod") then
		Msg("Seat fix ran. \n")
		local vname = ITEM.ID
		local VehicleList = list.Get( "Vehicles" )
		local vehicle = VehicleList[ vname ]
		
		ent:SetModel(ITEM.Model)
		
		-- Not a valid vehicle to be spawning..
		if ( vehicle ) then 
			for k, v in pairs( vehicle.KeyValues ) do
				ent:SetKeyValue( k, v )
			end	 
			ent:Spawn()
			ent:Activate()
			
			ent.VehicleName 	= vname
			ent.VehicleTable 	= vehicle
			ent.ClassOverride 	= vehicle.Class
			-- This is the main part that fixes the animation.
			if ( vehicle.Members ) then
				table.Merge( ent, vehicle.Members )
				duplicator.StoreEntityModifier( ent, "VehicleMemDupe", vehicle.Members );
			end
			
			PNRP.SetOwner(ply, ent)
		end
	else
	
		ent:SetModel(ITEM.Model)
		ent:SetKeyValue( "actionScale", 1 ) 
		ent:SetKeyValue( "VehicleLocked", 0 ) 
		ent:SetKeyValue( "solid", 6 ) 
		ent:SetKeyValue( "vehiclescript", ITEM.Script ) 
		
		ent:SetKeyValue( "model", ITEM.Model )
		ent:Spawn()
		ent:Activate()
		PNRP.SetOwner(ply, ent)
		PNRP.AddWorldCache( ply,ITEM.ID,ent )
		
	end
	
	ent.gas = 0
	ent.tank = 5
end

PNRP.AddItem(ITEM)


