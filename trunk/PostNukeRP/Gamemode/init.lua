include( 'shared.lua' ) --Tell the server to load shared.lua
include("itembase.lua")

AddCSLuaFile( "cl_init.lua" ) --Tell the server that the client needs to download cl_init.lua
AddCSLuaFile( "shared.lua" ) --Tell the server that the client needs to download shared.lua
AddCSLuaFile("itembase.lua")

--include('keymap.lua')

CreateConVar("pnrp_ReproduceRes","1")
CreateConVar("pnrp_MaxReproducedRes","20",FCVAR_ARCHIVE)

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
    
    ply:Spawn() -- Make the player respawn
 
end
 
function team_set_scavenger( ply )
 
    ply:SetTeam( TEAM_SCAVENGER )
    
    ply:Spawn() -- Make the player respawn
    
end

function team_set_science( ply )
 
    ply:SetTeam( TEAM_SCIENCE )
    
    ply:Spawn() -- Make the player respawn
    
end

function team_set_engineer( ply )
 
    ply:SetTeam( TEAM_ENGINEER )
    
    ply:Spawn() -- Make the player respawn
    
end

function team_set_cultivator( ply )
 
    ply:SetTeam( TEAM_CULTIVATOR )
    
    ply:Spawn() -- Make the player respawn
    
end
 
concommand.Add( "team_set_wastelander", team_set_wastelander )
concommand.Add( "team_set_scavenger", team_set_scavenger )
concommand.Add( "team_set_science", team_set_science )
concommand.Add( "team_set_engineer", team_set_engineer )
concommand.Add( "team_set_cultivator", team_set_cultivator )

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
	
	RunConsoleCommand( arg[1], arg[2] )	
					
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
	
	local ItemID = PNRP.FindItemID( ent:GetClass() )
	print("This is the ItemID:  "..ItemID)
	
	if ItemID then
		print("This is the type:  "..PNRP.Items[ItemID].Type)
		local myType = PNRP.Items[ItemID].Type
		if myType == "vehicle" then
			if tostring(ent:GetNetworkedString( "Owner" , "None" )) == ply:Nick() then
				ply:ConCommand("pnrp_removeowner")
			else
				ply:ConCommand("pnrp_addowner")
			end
		else
			if myType == "weapon" or myType == "ammo" or myType == "medical" or myType == "food" or myType == "tool" then
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
	ply:ConCommand("pnrp_inv")
end
--F4 Button
function GM:ShowSpare2( ply )
	ply:ConCommand("pnrp_buy_shop")
end

function PNRP.GetCar( ply )
	for k,v in pairs(ents.GetAll()) do
		local ItemID = PNRP.FindItemID( v:GetClass() )
		if ItemID != nil then
			local myType = PNRP.Items[ItemID].Type
			if tostring(v:GetNetworkedString( "Owner" , "None" )) == ply:Nick() && myType == "vehicle" then
				local myModel = v:GetModel()
				if myModel == "models/buggy.mdl" then
					Msg("Sending ".."vehicle_jeep".." to "..ply:Nick().."'s Inventory".."\n")
					PNRP.AddToInentory( ply, "vehicle_jeep" )
					v:Remove()
				elseif myModel == "models/airboat.mdl" then
					Msg("Sending "..ItemID.." to "..ply:Nick().."'s Inventory".."\n")
					PNRP.AddToInentory( ply, ItemID )
					v:Remove()
				elseif myModel == "models/vehicle.mdl" then
					Msg("Sending ".."vehicle_jalopy".." to "..ply:Nick().."'s Inventory".."\n")
					PNRP.AddToInentory( ply, "vehicle_jalopy" )
					v:Remove()
				elseif myModel == "models/nova/jeep_seat.mdl" then
					Msg("Sending ".."vehicle_jeep_seat".." to "..ply:Nick().."'s Inventory".."\n")
					PNRP.AddToInentory( ply, "vehicle_jeep_seat" )
					v:Remove()
				elseif myModel == "models/nova/airboat_seat.mdl" then
					Msg("Sending ".."vehicle_airboat_seat".." to "..ply:Nick().."'s Inventory".."\n")
					PNRP.AddToInentory( ply, "vehicle_airboat_seat" )
					v:Remove()
				end
				
			end
		end	
	end
end

concommand.Add( "pnrp_GetCar", PNRP.GetCar )

--EOF