local ITEM = {}

ITEM.ID = "vehicle_raf_d"

ITEM.Name = "RAF 2203 Latvija"
ITEM.ClassSpawn = "None"
ITEM.Scrap = 275
ITEM.Small_Parts = 150
ITEM.Chemicals = 50
ITEM.Chance = 100
ITEM.Info = "Sturdy, reliable transportation."
ITEM.Type = "vehicle"
ITEM.Remove = true
ITEM.Energy = 0
ITEM.Ent = "prop_vehicle_jeep"
ITEM.EntName = "van001a_01_nodoor"
ITEM.Model = "models/source_vehicles/van001a_01_nodoor.mdl"
ITEM.Script = "scripts/vehicles/van001a-vehicle_van.txt"
ITEM.Hull = "models/props_vehicles/van001a_nodoor.mdl"
ITEM.SeatLoc = {{Pos = Vector(27,38,27), Ang = Angle(0,0,8)},
				{Pos = Vector(0,38,27), Ang = Angle(0,0,8)},
				{Pos = Vector(32,-42,23), Ang = Angle(0,90,8)}}
ITEM.SeatModel = "models/nova/jalopy_seat.mdl"
ITEM.Weight = 40
ITEM.Capacity = 250
ITEM.ShopHide = true

function ITEM.ToolCheck( p )
	return {
		["intm_engine"]=1,
		["intm_car_door"]=2,
		["intm_car_axle"]=2,
		["intm_car_muffler"]=1,
		["intm_car_tire"]=4,
		["intm_oil"]=1,
		["tool_battery"]=1}
end

function ITEM.Use( ply )
	return true	
end


function ITEM.Create( ply, class, pos, iid, angle, model )
	
	local ent = ents.Create(ITEM.Ent)
	if not angle then angle = Angle(0,0,0) end
	angle = angle+Angle(0,0,0)
	ent:SetAngles(angle)
	ent:SetPos(pos)
	
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
	
	ent.IsGasSystem = true
	ent.gas = 0
	ent.tank = 8
	
end

PNRP.AddItem(ITEM)


