--Chat Commands
PNRP.ChatCommands = { }

function PNRP.ChatCmd( cmdtext, callback )

	table.insert( PNRP.ChatCommands, { cmd = cmdtext, cb = callback } );

end

local function chtTest( ply, cmd, text )

	ply:ChatPrint("Test")

end
PNRP.ChatCmd( "/test", chtTest );


/*---------------------------------------------------------
  Save/Load
---------------------------------------------------------*/
function GM.SaveCharacter(ply,cmd,args)
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/Saves") then file.CreateDir("PostNukeRP/Saves") end

	local tbl = {}
	tbl["class"] = ply:Team()
	tbl["resources"] = {}
	tbl["date"] = os.date("%A %m/%d/%y")
	tbl["name"] = ply:Nick()
	tbl["weapons"] = {}
	--Sets Resources
	for k,v in pairs(ply.Resources) do
		if v <= 0 then
			v = 0
		end
		tbl["resources"][k] = v
	end
	--Sets Weapons
	for k, v in pairs(ply:GetWeapons()) do
		local wepCheck = PNRP.CheckDefWeps(v)
		if !wepCheck then
			local ammotbl = {}
			local ammo = ply:GetAmmoCount( v:GetPrimaryAmmoType() ) 
			local ammoType = PNRP.ConvertAmmoType(v:GetPrimaryAmmoType())
			--tbl["weapons"][tostring(v:GetClass())] = tostring(ammo)
			if ammoType then
				ammotbl[ammoType] = ammo
				
				tbl["weapons"][tostring(v:GetClass())] = ammotbl
			end
		end
	end 
	
	file.Write("PostNukeRP/Saves/"..ply:UniqueID()..".txt",util.TableToKeyValues(tbl))
end

function GM.LoadCharacter( ply )
	if file.Exists("PostNukeRP/Saves/"..ply:UniqueID()..".txt") then
		local tbl = util.KeyValuesToTable(file.Read("PostNukeRP/Saves/"..ply:UniqueID()..".txt"))
		
		ply:SetTeam( tonumber(tbl.class) )
		
		PNRP:LoadRecources(ply, tbl)
		
--		PNRP:LoadWeaps(ply, tbl)
		
	else
		ply:SetResource("Scrap",0)
		ply:SetResource("Small_Parts",0)
		ply:SetResource("Chemicals",0)
	end
end

function PNRP:LoadRecources(ply, tbl)
	if tbl["resources"] then
		for k,v in pairs(tbl["resources"]) do
			ply:SetResource(string.Capitalize(k),v)
		end
	end
end

function GM.LoadWeaps( ply )
	if file.Exists("PostNukeRP/Saves/"..ply:UniqueID()..".txt") then
		local tbl = util.KeyValuesToTable(file.Read("PostNukeRP/Saves/"..ply:UniqueID()..".txt"))
		
		if tbl["weapons"] then
			for k,v in pairs(tbl["weapons"]) do
				ply:Give(string.lower(k))
				if v then
					for ammoType,ammoNum in pairs(v) do
						ply:GiveAmmo(ammoNum, ammoType)
					end
				end
			end
		end
	end
end

concommand.Add( "pnrp_save", GM.SaveCharacter )
concommand.Add( "pnrp_load", GM.LoadCharacter )
concommand.Add( "pnrp_loadweps", GM.LoadWeaps )
/*-------------------------------------------------------*/

function GM:DoPlayerDeath( ply, attacker, dmginfo )
	
	ply:CreateRagdoll()
 
	ply:AddDeaths( 1 )
 
	if ( attacker:IsValid() && attacker:IsPlayer() ) then
 
		if ( attacker == ply ) then
			attacker:AddFrags( -1 )
		else
			attacker:AddFrags( 1 )
		end
 
	end
	
	local pos = ply:GetPos() + Vector(0,0,20)	
	--Drop Weapons
	for k, v in pairs(ply:GetWeapons()) do
		local wepCheck = PNRP.CheckDefWeps(v) and v != "weapon_real_cs_admin_weapon"
		if !wepCheck then
			local ent = ents.Create(v:GetClass())
	        --ply:PrintMessage( HUD_PRINTTALK, v:GetPrintName( ) )
			ent:SetModel(v:GetModel())
	        ent:SetAngles(Angle(0,0,0))
			ent:SetPos(pos)
			ent:Spawn()
			ent:SetClip1(v:Clip1())
			ent:SetNetworkedString("Owner", "World")
		end
	end 		
end

function PNRP.CheckDefWeps(wep)
	local defWeps = table.Add(PNRP.DefWeps)
	for k,v in pairs(defWeps) do
		if string.lower(v) == wep:GetClass() then
			return true
		end
	end
end

function GM.set_Zombies(ply, command, arg) 
	RunConsoleCommand( "pnrp_MaxZombies", arg[1] )
	
	return GetConVarNumber("pnrp_MaxZombies")
end
concommand.Add( "pnrp_SetZombies", GM.set_Zombies )


function PNRP.ConvertAmmoType(ammoType)

	local sendType = nil
	
	if ammoType == 1 then sendType = "ar2" end -- Ammunition of the AR2/Pulse Rifle
	if ammoType == 2 then sendType = "alyxgun" end -- (name in-game "5.7mm Ammo")
	if ammoType == 3 then sendType = "pistol" end -- Ammunition of the 9MM Pistol 
	if ammoType == 4 then sendType = "smg1" end -- Ammunition of the SMG/MP7
	if ammoType == 5 then sendType = "357" end -- Ammunition of the .357 Magnum
	if ammoType == 6 then sendType = "xbowbolt" end -- Ammunition of the Crossbow
	if ammoType == 7 then sendType = "buckshot" end -- Ammunition of the Shotgun
	if ammoType == 8 then sendType = "rpg_round" end -- Ammunition of the RPG/Rocket Launcher
	if ammoType == 9 then sendType = "smg1_grenade" end -- Ammunition for the SMG/MP7 grenade launcher (secondary fire)
	if ammoType == 10 then sendType = "sniperround" end 
	if ammoType == 11 then sendType = "sniperpenetratedround" end -- (name in-game ".45 Ammo")
	if ammoType == 12 then sendType = "grenade" end -- Note you must be given the grenade weapon (e.g. pl:Give ("weapon_grenade")) before you can throw any grenades
	if ammoType == 13 then sendType = "thumper" end -- Ammunition cannot exceed 2 (name in-game "Explosive C4 Ammo")
	if ammoType == 14 then sendType = "gravity" end -- (name in-game "4.6MM Ammo")
	if ammoType == 15 then sendType = "battery" end -- (name in-game "9MM Ammo")
	if ammoType == 16 then sendType = "gaussEnergy" end 
	if ammoType == 17 then sendType = "combineCannon" end -- (name in-game ".50 Ammo")
	if ammoType == 18 then sendType = "airboatGun" end -- (name in-game "5.56MM Ammo")
	if ammoType == 19 then sendType = "striderMinigun" end -- (name in-game "7.62MM Ammo")
	if ammoType == 20 then sendType = "helicopterGun" end 
	if ammoType == 21 then sendType = "ar2altfire" end -- Ammunition of the AR2/Pulse Rifle 'combine ball' (secondary fire)
	if ammoType == 22 then sendType = "slam" end -- See Grenade

	return sendType
end

function ConvertWepEnt( weaponModel )
	for itemname, item in pairs( PNRP.Items ) do
		if weaponModel == item.Model then
			return item.Ent
		end
	end
	return nil
end

function PNRP.DropWeapon (ply, command, args)
	local myWep = ply:GetActiveWeapon()
	if ( myWep ) then
		local curAmmo = myWep:Clip1()
		
		if PNRP.CheckDefWeps(myWep) then return end
		
		ply:ChatPrint("I exist!")
		ply:ChatPrint("Active Wep:  "..tostring(myWep:GetModel()))
		local wepModel = myWep:GetModel()
		if string.find(myWep:GetModel(), "v_") ~= 1 then
			wepModel = "models/weapons/w_"..string.sub(myWep:GetModel(),string.find(myWep:GetModel(), "v_")+2)
		end
		ply:ChatPrint("After model check:  "..wepModel)
		local wepEnt = ConvertWepEnt( wepModel )
		ply:ChatPrint("My Ent:  "..wepEnt)
		
		local tr = ply:TraceFromEyes(200)
		local trPos = tr.HitPos
		
		local ent = ents.Create(wepEnt)
		local pos = trPos + Vector(0,0,20)
		ent:SetModel(wepModel)
		ent:SetAngles(Angle(0,0,0))
		ent:SetPos(pos)
		ent:Spawn()
		ent:SetNetworkedString("Owner", "World")
		ent:SetNetworkedString("Ammo", myWep:Clip1())
		
		ply:StripWeapon(myWep:GetClass())
	end
end
concommand.Add( "pnrp_dropWep", PNRP.DropWeapon )


function PNRP.GetSpawnflags ( ply )
	local tr = ply:TraceFromEyes(400)
	local ent = tr.Entity
	
	for k,v in pairs(ent:GetKeyValues()) do
--		if string.lower(v) == wep:GetClass() then
--		Msg( tostring(k).." "..tostring(v).."\n")
		ply:ChatPrint(tostring(k)..": ["..tostring(v).."] \n")
--			return true
--		end
	end
--	ply:ChatPrint("Class: "..tostring(ent:GetClass()))
	EntityKeyValueInfo( ent )
--	Msg(EntityKeyValueInfo( ent, 0 ).."\n")
	ply:ChatPrint(tostring(ent:GetTable().HandleAnimation) )
end
concommand.Add( "pnrp_getinfo", PNRP.GetSpawnflags )

function EntityKeyValueInfo( ent, key, value )

--return tostring(key).." "..tostring(value)
	Msg(tostring(ent).." "..tostring(key).." "..tostring(value).."\n")

--	for k,v in pairs(ent:GetKeyValues()) do
--		if string.lower(v) == wep:GetClass() then
--		Msg( tostring(k).." "..tostring(v).."\n")
--		ply:ChatPrint(tostring(k)..": ["..tostring(v).."] \n")
--			return true
--		end
--	end

end

hook.Add( 'EntityKeyValue' , "EntityKeyValueInfo", getMoreInfo )

--EOF