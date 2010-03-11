include( 'shared.lua' ) --Tell the server to load shared.lua
include("itembase.lua")

AddCSLuaFile( "cl_init.lua" ) --Tell the server that the client needs to download cl_init.lua
AddCSLuaFile( "shared.lua" ) --Tell the server that the client needs to download shared.lua
AddCSLuaFile("itembase.lua")

--include('keymap.lua')

--CreateConVar("pnrp_ReproduceRes","1", FCVAR_ARCHIVE + FCVAR_NOTIFY)
--CreateConVar("pnrp_MaxReproducedRes","20",FCVAR_ARCHIVE + FCVAR_NOTIFY)

local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

local firstSpawn = true

--base include
for k, v in pairs(file.FindInLua("PostNukeRP/gamemode/base/*.lua")) do
	include("base/"..v)
end
--plugins include
for k, v in pairs(file.FindInLua("PostNukeRP/gamemode/sv_plugins/*.lua")) do
	include("sv_plugins/"..v)
end
--derma download
for k, v in pairs( file.FindInLua( "PostNukeRP/gamemode/derma/*.lua" ) ) do
	AddCSLuaFile("derma/"..v)	
end
--vgui download
for k, v in pairs( file.FindInLua( "PostNukeRP/gamemode/vgui/*.lua" ) ) do
	AddCSLuaFile("vgui/"..v)
end


for k, v in pairs( file.FindInLua( "PostNukeRP/gamemode/items/*.lua" ) ) do
	include("items/"..v)
end

RunConsoleCommand( "sv_alltalk", tostring(0) )
game.ConsoleCommand( "sbox_godmode 0\n" )
game.ConsoleCommand( "sbox_plpldamage 0\n" )
--game.ConsoleCommand( "sbox_noclip 0\n" )

function GM:PlayerInitialSpawn( ply ) --"When the player first joins the server and spawns" function
	
	ply:SetTeam( TEAM_WASTELANDER ) --Add the player to team 1
	
	ply.Resources = {}
	
	self.LoadCharacter( ply )
	
	--Loads Weapons from Character's Save File
	timer.Create(tostring(ply:UniqueID()), 5, 1, function()  
	    self.LoadWeaps( ply )
	    	
	    ply:IncResource("Scrap",0)
		ply:IncResource("Small_Parts",0)
		ply:IncResource("Chemicals",0)
		
		PNRP.SendInventory( ply )
		PNRP.SendCarInventory( ply )
		
		Msg("Load Timer run for "..ply:Nick().."\n")
	end)
		
--	PNRP.SendInventory( ply )

end --End the "when player first joins server and spawns" function

function GM:PlayerSpawn( ply )  //What happens when the player spawns
 
    self.BaseClass:PlayerSpawn( ply )   // Lines 12 through 18 are all fixes to the sandbox glitch. Don't change
										// them unless you know what you're doing.
    ply:SetGravity( 1 )  
 
    ply:SetWalkSpeed( 150 )  
    
    if ply:Team() == TEAM_WASTELANDER then
    	ply:SetMaxHealth( 150, true )
    elseif ply:Team() == TEAM_SCAVENGER then
    	ply:SetMaxHealth( 75, true )
    	ply:SetHealth(75)
    else 
    	ply:SetMaxHealth( 100, true )
    end
    
    if ply:Team() == TEAM_SCAVENGER then
		ply:SetRunSpeed( 325 ) 
	else
		ply:SetRunSpeed( 295 )
	end
	
	ply:IncResource("Scrap",0)
	ply:IncResource("Small_Parts",0)
	ply:IncResource("Chemicals",0)
 
end

function GM:PlayerDisconnected(ply)
	
	self.SaveCharacter(ply)
	PNRP.GetAllCars( ply )
	Msg("Saved character of disconnecting player "..ply:Nick()..".\n")
end

function GM:PlayerLoadout( ply ) --Weapon/ammo/item function
	
    if ply:Team() == TEAM_WASTELANDER then --If player team equals 1

        ply:Give( "weapon_physcannon" ) --Give them the Gravity Gun 
        ply:Give( "weapon_physgun" ) 
        ply:Give( "gmod_rp_hands" ) --Give them Hands
        ply:Give( "weapon_real_cs_knife" ) --Give them the Knife
        ply:Give( "gmod_camera" )
        ply:Give( "gmod_tool" )
        
		ply:ChatPrint("You are now in the Wastelander Class")
 
    elseif ply:Team() == TEAM_SCAVENGER then 
 
        ply:Give( "weapon_physcannon" ) 
        ply:Give( "weapon_physgun" ) 
        ply:Give( "gmod_rp_hands" ) 
        ply:Give( "weapon_real_cs_knife" ) 
        ply:Give( "gmod_camera" )
        ply:Give( "gmod_tool" )
        
		ply:ChatPrint("You are now in the Scavenger Class")
 
    elseif ply:Team() == TEAM_SCIENCE then 
 
        ply:Give( "weapon_physcannon" ) 
        ply:Give( "weapon_physgun" ) 
        ply:Give( "gmod_rp_hands" ) 
        ply:Give( "weapon_real_cs_knife" ) 
        ply:Give( "gmod_camera" )
        ply:Give( "gmod_tool" ) 
        
		ply:ChatPrint("You are now in the Science Class")
 
    elseif ply:Team() == TEAM_ENGINEER then 
 
        ply:Give( "weapon_physcannon" ) 
        ply:Give( "weapon_physgun" ) 
        ply:Give( "gmod_rp_hands" ) 
        ply:Give( "weapon_real_cs_knife" ) 
        ply:Give( "gmod_camera" )
        ply:Give( "gmod_tool" )
        
		ply:ChatPrint("You are now in the Engineer Class")
    
    elseif ply:Team() == TEAM_CULTIVATOR then 
 
        ply:Give( "weapon_physcannon" ) 
        ply:Give( "weapon_physgun" ) 
        ply:Give( "gmod_rp_hands" ) 
        ply:Give( "weapon_real_cs_knife" ) 
        ply:Give( "gmod_camera" )
        ply:Give( "gmod_tool" )
        
		ply:ChatPrint("You are now in the Cultivator Class")
    end 
    
end --Here we end the Loadout function

function team_set_wastelander( ply )
 
    ply:SetTeam( TEAM_WASTELANDER )
    classChangeCost(ply, "Scrap")
    classChangeCost(ply, "Small_Parts")
    classChangeCost(ply, "Chemicals")
    ply:Spawn() -- Make the player respawn
 
end
 
function team_set_scavenger( ply )
 
    ply:SetTeam( TEAM_SCAVENGER )
   classChangeCost(ply, "Scrap")
    classChangeCost(ply, "Small_Parts")
    classChangeCost(ply, "Chemicals")
    ply:Spawn() -- Make the player respawn
    
end

function team_set_science( ply )
 
    ply:SetTeam( TEAM_SCIENCE )
    classChangeCost(ply, "Scrap")
    classChangeCost(ply, "Small_Parts")
    classChangeCost(ply, "Chemicals")
    ply:Spawn() -- Make the player respawn
    
end

function team_set_engineer( ply )
 
    ply:SetTeam( TEAM_ENGINEER )
    classChangeCost(ply, "Scrap")
    classChangeCost(ply, "Small_Parts")
    classChangeCost(ply, "Chemicals")
    ply:Spawn() -- Make the player respawn
    
end

function team_set_cultivator( ply )
 
    ply:SetTeam( TEAM_CULTIVATOR )    
    classChangeCost(ply, "Scrap")
    classChangeCost(ply, "Small_Parts")
    classChangeCost(ply, "Chemicals")
    ply:Spawn() -- Make the player respawn
    
end
 
concommand.Add( "team_set_wastelander", team_set_wastelander )
concommand.Add( "team_set_scavenger", team_set_scavenger )
concommand.Add( "team_set_science", team_set_science )
concommand.Add( "team_set_engineer", team_set_engineer )
concommand.Add( "team_set_cultivator", team_set_cultivator )

function classChangeCost(ply, Recource)
	
	if GetConVarNumber("pnrp_classChangePay") == 1 then
	    local getRec
	    local int
	    local cost = GetConVarNumber("pnrp_classChangeCost") / 100
  
	    getRec = ply:GetResource(Recource)
	    int = getRec * cost
	    int = math.Round(int)
	    if getRec - int >= 0 then
	    	Msg("Class change cost applied to "..Recource.." \n")
	    	ply:ChatPrint("Changing classes has cost you "..int.." "..Recource..".")
	    	ply:DecResource(Recource,int)
	    end
	end
end



----Code Below This Line----

/*---------------------------------------------------------
  Other
---------------------------------------------------------*/
function PlayerMeta:TraceFromEyes(dist)
	local trace = {}
	trace.start = self:GetShootPos()
	trace.endpos = trace.start + (self:GetAimVector() * dist)
	trace.filter = self

	return util.TraceLine(trace)
end

function PNRP.ClassIsNearby(pos,class,range)
	local nearby = false
	for k,v in pairs(ents.FindInSphere(pos,range)) do
		if v:GetClass() == class and (pos-Vector(v:LocalToWorld(v:OBBCenter()).x,v:LocalToWorld(v:OBBCenter()).y,pos.z)):Length() <= range then
			nearby = true
		end
	end

	return nearby
end

function string.Capitalize(str)
	local str = string.Explode("_",str)
	for k,v in pairs(str) do
		str[k] = string.upper(string.sub(v,1,1))..string.sub(v,2)
	end

	str = string.Implode("_",str)
	return str
end

function GM.run_Command(ply, command, arg)
	if ply:IsAdmin() then
		RunConsoleCommand( arg[1], arg[2] )	
	end				
end

concommand.Add( "pnrp_RunCommand", GM.run_Command )

function GM:ShowHelp(ply)

	ply:ConCommand("pnrp_help")
	return false
	
end

--F2 Button
function GM:ShowTeam( ply )
	local tr = ply:TraceFromEyes(200)
	local ent = tr.Entity
	local myClass
	--Added to remove the Null Entity error
	if tostring(ent) == "[NULL Entity]" then return end
	
	if ent:GetClass() == "prop_vehicle_prisoner_pod" then
		myClass = "weapon_seat"
	else
		myClass = ent:GetClass()
	end
	
	if myClass == "prop_physics" then
		local myModel = ent:GetModel()
		
		for itemname, item in pairs( PNRP.Items ) do
			if myModel == item.Model and item.Type != "junk" and item.Type != "build" then
--				myClass = item.ID
				
				local weight = PNRP.InventoryWeight( ply ) + PNRP.Items[item.ID].Weight
				local weightCap
				
				if team.GetName(ply:Team()) == "Scavenger" then
					weightCap = GetConVarNumber("pnrp_packCapScav")
				else
					weightCap = GetConVarNumber("pnrp_packCap")
				end
				
				if weight <= weightCap then
					PNRP.AddToInentory( ply, item.ID )
					ent:Remove()
				else
					ply:ChatPrint("You're pack is too full and cannot carry this.")
				end
			end
		end		
	end
	
	local ItemID = PNRP.FindItemID( myClass )
	print("This is the ItemID:  "..ItemID)
	
	if ItemID != nil then
		print("This is the type:  "..PNRP.Items[ItemID].Type)
		local myType = PNRP.Items[ItemID].Type
		if myType == "vehicle" then
			if tonumber(ent:GetNetworkedString( "Type" , "0" )) == 1 then
				if ent:GetModel() == "models/nova/jeep_seat.mdl" then
					ItemID = "seat_jeep"
				else
					ItemID = "seat_airboat"
				end
				
				local weight = PNRP.InventoryWeight( ply ) + PNRP.Items[ItemID].Weight
				local weightCap
				
				if team.GetName(ply:Team()) == "Scavenger" then
					weightCap = GetConVarNumber("pnrp_packCapScav")
				else
					weightCap = GetConVarNumber("pnrp_packCap")
				end
				
				if weight <= weightCap then
					PNRP.AddToInentory( ply, ItemID )
					ent:Remove()
				else
					ply:ChatPrint("You're pack is too full and cannot carry this.")
				end
			else
				if tostring(ent:GetNetworkedString( "Owner" , "None" )) == ply:Nick() then
					ply:ConCommand("pnrp_removeowner")
				else
					ply:ConCommand("pnrp_addowner")
				end
			end
		else
			if myType == "weapon" then
				-- ply:ChatPrint("InvWeight Debug:  "..tostring(PNRP.InventoryWeight( ply )))
				-- ply:ChatPrint("ItemWeight Debug:  "..tostring(PNRP.Items[ItemID].Weight))
				-- ply:ChatPrint("ItemID Debug:  "..tostring(ItemID))
				local weight = PNRP.InventoryWeight( ply ) + PNRP.Items[ItemID].Weight
				local weightCap
				
				if team.GetName(ply:Team()) == "Scavenger" then
					weightCap = GetConVarNumber("pnrp_packCapScav")
				else
					weightCap = GetConVarNumber("pnrp_packCap")
				end
				
				if weight <= weightCap then
					PNRP.AddToInentory( ply, ItemID )
					if tonumber(ent:GetNetworkedString("Ammo")) > 0 then
						ply:GiveAmmo(tonumber(ent:GetNetworkedString("Ammo")), PNRP.FindAmmoType( ItemID, nil))
					end
					ent:Remove()
				else
					ply:ChatPrint("You're pack is too full and cannot carry this.")
				end
			elseif myType == "ammo" then
				local boxes = math.floor( tonumber(ent:GetNWString("Ammo")) / tonumber(ent:GetNWString("NormalAmmo")) )
				local ammoLeft = tonumber(ent:GetNWString("Ammo"))
				local overweight = false
				
				local weightCap
						
				if team.GetName(ply:Team()) == "Scavenger" then
					weightCap = GetConVarNumber("pnrp_packCapScav")
				else
					weightCap = GetConVarNumber("pnrp_packCap")
				end
				
				if boxes > 0 then
					for box = 1, boxes do
						local weight = PNRP.InventoryWeight( ply ) + PNRP.Items[ItemID].Weight
						
						if weight <= weightCap then
							PNRP.AddToInentory( ply, ItemID )
							ammoLeft = ammoLeft - tonumber(ent:GetNWString("NormalAmmo"))
						else
							ply:ChatPrint("You're pack is too full and cannot carry all of this.")
							overweight = true
							break
						end
					end
				end
				
				local ammoType
--				if ent:GetClass() == "ammo_smg1" then
--					ammoType = "smg1"
--				elseif ent:GetClass() == "ammo_shotgun" then
--					ammoType = "buckshot"
--				elseif ent:GetClass() == "ammo_pistol" then
--					ammoType = "pistol"
--				elseif ent:GetClass() == "ammo_357" then
--					ammoType = "357"
--				end
				
				ammoType = string.gsub(ent:GetClass(),"ammo_","")
				
				if ammoLeft > 0 and boxes > 0 and not overweight then
					ply:ChatPrint("You have loaded the rest of your ammo onto your combat vest.  "..tostring(ammoLeft).." extra rounds taken.")
					ply:GiveAmmo(ammoLeft, ammoType)
					ent:Remove()
				elseif ammoLeft > 0 and boxes > 0 and overweight then
					ply:ChatPrint("The rest stays on the ground.")
					ent:SetNetworkedString("Ammo", tostring(ammoLeft))
				elseif ammoLeft > 0 then
					ply:ChatPrint("This isn't enough to worry about.  Only "..tostring(ammoLeft).." rounds here.")
				else
					ply:ChatPrint("You have picked up all of this ammo.")
					ent:Remove()
				end
			elseif myType == "medical" or myType == "food" or myType == "tool" then
				local weight = PNRP.InventoryWeight( ply ) + PNRP.Items[ItemID].Weight
				local weightCap
				
				if team.GetName(ply:Team()) == "Scavenger" then
					weightCap = GetConVarNumber("pnrp_packCapScav")
				else
					weightCap = GetConVarNumber("pnrp_packCap")
				end
				
				if weight <= weightCap then
					PNRP.AddToInentory( ply, ItemID )
					ent:Remove()
				else
					ply:ChatPrint("You're pack is too full and cannot carry this.")
				end

			end
		end
	end

end
--F3 Button
function GM:ShowSpare1( ply )
	local tr = ply:TraceFromEyes(200)
	local ent = tr.Entity
	--Opens Car inventory when looking at a car owned by you.
	if tostring(ent) != "[NULL Entity]" then
		local ItemID = PNRP.FindItemID( ent:GetClass() )
		if ItemID != nil then
			local myType = PNRP.Items[ItemID].Type
			if tostring(ent:GetNetworkedString( "Owner" , "None" )) == ply:Nick() && myType == "vehicle" then
				local myModel = ent:GetModel()
				if myModel == "models/buggy.mdl" then ItemID = "vehicle_jeep" end
				ply:SendLua( "CurCarMaxWeight = "..tostring(PNRP.Items[ItemID].Weight) )
				ply:ConCommand("pnrp_carinv")
			else
				--If not looking at the car, open normal inventory.
				ply:ConCommand("pnrp_inv")
			end
		else
			--If not looking at the car, open normal inventory.
			ply:ConCommand("pnrp_inv")
		end
	else
	--If not looking at the car, open normal inventory.
		ply:ConCommand("pnrp_inv")
	
	end
end
concommand.Add( "pnrp_ShowSpare1", GM.ShowSpare1 )

--F4 Button
function GM:ShowSpare2( ply )
	ply:ConCommand("pnrp_buy_shop")
end

function PNRP.GetAllCars( ply )
	for k,v in pairs(ents.GetAll()) do
		local myClass = v:GetClass()
		local ItemID = PNRP.FindItemID( myClass )
		if ItemID != nil then
			local myType = PNRP.Items[ItemID].Type
			if tostring(v:GetNetworkedString( "Owner" , "None" )) == ply:Nick() && myType == "vehicle" then
				local myModel = v:GetModel()
								
				if myModel == "models/buggy.mdl" then ItemID = "vehicle_jeep"
				elseif myModel == "models/vehicle.mdl" then ItemID = "vehicle_jalopy" end
				
				Msg("Sending "..ItemID.." to "..ply:Nick().."'s Inventory".."\n")
				PNRP.AddToInentory( ply, ItemID )
				v:Remove()
				
			end
		end	
	end
end
concommand.Add( "pnrp_GetAllCar", PNRP.GetAllCars )
PNRP.ChatConCmd( "/getallcars", "pnrp_GetAllCar" )

function PNRP.GetCar( ply )
	
	local tr = ply:TraceFromEyes(200)
	local ent = tr.Entity
	if tostring(ent) != "[NULL Entity]" then
		local myClass = ent:GetClass()
		local ItemID = PNRP.FindItemID( myClass )
		if ItemID != nil then
			local myType = PNRP.Items[ItemID].Type
			if tostring(ent:GetNetworkedString( "Owner" , "None" )) == ply:Nick() && myType == "vehicle" then
				local myModel = ent:GetModel()
								
				if myModel == "models/buggy.mdl" then ItemID = "vehicle_jeep"
				elseif myModel == "models/vehicle.mdl" then ItemID = "vehicle_jalopy" end
				
				Msg("Sending "..ItemID.." to "..ply:Nick().."'s Inventory".."\n")
				PNRP.AddToInentory( ply, ItemID )
				ent:Remove()
				
			end
		end	
	end
end
concommand.Add( "pnrp_GetCar", PNRP.GetCar )
PNRP.ChatConCmd( "/getcar", "pnrp_GetCar" )

--This is an override to hide death notices.
function GM:PlayerDeath( Victim, Inflictor, Attacker )  

   -- Don't spawn for at least 2 seconds
   Victim.NextSpawnTime = CurTime() + 2
   Victim.DeathTime = CurTime()

end   

--EOF