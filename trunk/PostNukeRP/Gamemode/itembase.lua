--Item Loader Base File
--Items are loaded from the item folder.

PNRP.Items = {}

--Gets the Item from the Item folder and adds it to the table
--If soemthing is added to the table here it will need to be added to 
--the table on inventory.lua
function PNRP.AddItem( itemtable )

	PNRP.Items[itemtable.ID] =
	{
		ID = itemtable.ID,
		Name = itemtable.Name,
		ClassSpawn = itemtable.ClassSpawn,		
		Scrap = itemtable.Scrap,
		SmallParts = itemtable.Small_Parts,
		Chemicals = itemtable.Chemicals,
		Chance = itemtable.Chance,
		Info = itemtable.Info,	
		Type = itemtable.Type,
		Energy = itemtable.Energy,
		Ent = itemtable.Ent,
		Model = itemtable.Model,
		Spawn = itemtable.Spawn,
		Use = itemtable.Use,
		Remove = itemtable.Remove,
		Script = itemtable.Script,
		Weight = itemtable.Weight,
		Create = itemtable.Create,
	}
	
end	

if (!SERVER) then return end

--Below Code may not acually be needed at this time--

function PNRP.BaseItemSpawn( p, itemtable )

	local trace = {}
	trace.start = p:EyePos()
	trace.endpos = trace.start + p:GetAimVector() * 85
	trace.filter = p
	local tr = util.TraceLine(trace)	


	local sitem = ents.Create( "prop_physics" )
	sitem:SetModel( itemtable.Model )
	sitem:SetPos( tr.HitPos )
	sitem:Spawn()
	sitem:Activate()
	sitem:GetPhysicsObject():Wake()	
	sitem:EmitSound( "physics/cardboard/cardboard_box_break3.wav" )
	sitem.ID = itemtable.ID
	sitem.IsItem = true
	sitem.Use = itemtable.Use
	sitem.Removeable = itemtable.Remove
	
end

function PNRP.BaseVehicle( p, mdl, ent, script, itemtable )

	local trace = {}
	trace.start = p:EyePos()
	trace.endpos = trace.start + p:GetAimVector() * 130
	trace.filter = p
	local tr = util.TraceLine( trace )	

	local jeep = ents.Create( ent )
	jeep:SetModel( mdl )	
	jeep:SetKeyValue( "actionScale", 1 ) 
 	jeep:SetKeyValue( "VehicleLocked", 0 ) 
 	jeep:SetKeyValue( "solid", 6 ) 
	jeep:SetKeyValue( "vehiclescript", script ) 		
	jeep:SetPos( tr.HitPos )
	jeep:Spawn()
	jeep:Activate()	
	jeep.ID = itemtable.ID
	jeep.Use = itemtable.Use	
	
end	

function PNRP.BaseUse( p, itemtable )	
	
--	p:AddEnergy( itemtable.Energy )

end

--EOF