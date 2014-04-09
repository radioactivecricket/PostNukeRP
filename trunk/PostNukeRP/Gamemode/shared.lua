GM.Name 	= "PostNukeRP" --Set the gamemode name
GM.Author 	= "EldarStorm LostInTheWird MainError" --Set the author name
GM.Email 	= "N/A" --Set the author email
GM.Website 	= "http://postnukerp.com" --Set the author website
GM.Version  = "1.1.2"

DeriveGamemode("sandbox") 

PNRP = {}

PNRP_Path = "PostNukeRP/"

PNRP_MOTDPath = "http://postnukerp.com/rules.php"
PNRP_WIKIPath = "http://postnukerp.com/wiki"

--Team Variables

TEAM_WASTELANDER = 6
TEAM_SCAVENGER = 7
TEAM_SCIENCE = 8
TEAM_ENGINEER = 9
TEAM_CULTIVATOR = 5

team.SetUp( TEAM_WASTELANDER, "Wastelander", Color( 125, 125, 125, 255 ) ) --Gray
team.SetUp( TEAM_SCAVENGER, "Scavenger", Color( 102, 51, 0, 225 ) ) --Brown
team.SetUp( TEAM_SCIENCE, "Science", Color( 0, 0, 153, 225 ) ) --Blue
team.SetUp( TEAM_ENGINEER, "Engineer", Color( 255, 204, 0, 225 ) ) --Orange
team.SetUp( TEAM_CULTIVATOR, "Cultivator", Color( 51, 153, 0, 225 ) ) --Green

PNRP.Resources = { }
table.insert(PNRP.Resources,"Scrap")
table.insert(PNRP.Resources,"Small_Parts")
table.insert(PNRP.Resources,"Chemicals")

PNRP.Skills = {}
PNRP.Skills["Scavenging"] 		= {name = "Scavenging", desc ="Better scavenging through experience.", basecost = 150, maxlvl = 5, class = nil}
PNRP.Skills["Endurance"] 		= {name = "Endurance", desc ="Staying on your feet longer, to survive better", basecost = 100, maxlvl = 6, class = {TEAM_WASTELANDER}}
PNRP.Skills["Athletics"] 		= {name = "Athletics", desc ="Running a bit faster always helps.", basecost = 100, maxlvl = 5, class = nil}
PNRP.Skills["Weapon Handling"] 	= {name = "Weapon Handling", desc ="Accuracy with firearms.  Who wouldn't want that?", basecost = 100, maxlvl = 5, class = nil}
PNRP.Skills["Construction"] 	= {name = "Construction", desc ="Know-how to make things cost less.", basecost = 100, maxlvl = 5, class = {TEAM_ENGINEER}}
PNRP.Skills["Backpacking"] 		= {name = "Backpacking", desc ="Knowing how to pack is great for carrying more.", basecost = 50, maxlvl = 5, class = nil}
PNRP.Skills["Animal Husbandry"] = {name = "Animal Husbandry", desc ="Like cattle rearing, but in worm form!", basecost = 150, maxlvl = 5, class = {TEAM_SCIENCE}}
PNRP.Skills["Mining"] 			= {name = "Mining", desc ="Get the most out of your sonic miners!", basecost = 150, maxlvl = 5, class = {TEAM_SCAVENGER}}
PNRP.Skills["Farming"] 			= {name = "Farming", desc ="Take care of those plants less.  God yes...", basecost = 150, maxlvl = 5, class = {TEAM_CULTIVATOR}}
PNRP.Skills["Salvaging"] 		= {name = "Salvaging", desc ="Lose less when taking stuff apart!", basecost = 100, maxlvl = 5, class = nil}

PNRP.ScavItems = {}
PNRP.ScavItems["fuel_h2pod"]		=	100
PNRP.ScavItems["fuel_uranrods"]		=	150
PNRP.ScavItems["intm_sensorpod"]	=	350
PNRP.ScavItems["intm_seeds"]		=	500
PNRP.ScavItems["intm_pulsecore"]	=	275
PNRP.ScavItems["intm_servo"]		=	350
PNRP.ScavItems["intm_diamsaw"]		=	150
PNRP.ScavItems["intm_waterjet"]		=	60
PNRP.ScavItems["intm_solarthinfilm"]=	80
PNRP.ScavItems["intm_fusioncore"]	=	20
PNRP.ScavItems["intm_nukecore"]		=	50
PNRP.ScavItems["food_beans"]		=	1500

local PlayerMeta = FindMetaTable("Player")

PNRP.JunkModels = { "models/props_junk/TrashCluster01a.mdl",
	"models/Gibs/helicopter_brokenpiece_03.mdl"}
PNRP.ChemicalModels = { "models/props_junk/garbage128_composite001c.mdl",
	"models/Gibs/gunship_gibs_sensorarray.mdl",
	"models/Gibs/gunship_gibs_eye.mdl"}
PNRP.SmallPartsModels = { "models/props_combine/combine_binocular01.mdl",
	"models/Gibs/Scanner_gib01.mdl", 
	"models/Gibs/Scanner_gib05.mdl" }

PNRP.DefWeps = {"weapon_physcannon",
				"weapon_physgun",
				"gmod_rp_hands",
				"weapon_simplekeys",
				"weapon_pnrp_knife",
				"gmod_camera",
				"gmod_tool"}

PNRP.friendlies = { "npc_floor_turret",
					"npc_hdvermin", 
					"npc_hdvermin_fast", 
					"npc_hdvermin_poison", 
					"npc_petbird_crow", 
					"npc_petbird_gull", 
					"npc_petbird_pigeon" }
														
CreateConVar("pnrp_SpawnMobs","1",FCVAR_REPLICATED + FCVAR_NOTIFY)
CreateConVar("pnrp_MaxZombies","30",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MaxFastZombies","5",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MaxPoisonZombs","2",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MaxAntlions","10",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MaxAntGuards","1",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
--Spawns a zombie when the player dies
CreateConVar("pnrp_PlyDeathZombie","1",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

--Mound Spawner Vars
CreateConVar("pnrp_MaxMounds","1",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MoundRate","5",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MoundChance","15",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MaxMoundAntlions","10",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MoundAntlionsPerCycle","5",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MaxMoundGuards","1",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MoundMobRate","5",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MoundGuardChance","10",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_packCap","75",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_packCapScav","110",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_ReproduceRes","1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MaxReproducedRes","20", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_propSpawnpointProtection", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_propBanning", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_propAllowing", "0", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_AllowPunt", "0", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_propPay", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_propCost", "10", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_adminCreateAll", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_adminTouchAll", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_adminNoCost", "0", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_exp2Level", "4", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_toolLevel", "4", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_voiceLimit", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_voiceDist", "750", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_classChangePay", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_classChangeCost", "10", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_deathPay", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_deathCost", "10", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_maxOwnDoors", "3", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_debug", "0", 0)

local pmeta = FindMetaTable("Player")

function pmeta:IsOutside()

	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = trace.start + Vector( 0, 0, 350 )
	trace.filter = self
	local tr = util.TraceLine( trace )

	if !tr.HitWorld && !tr.HitNonWorld then
	
		return true
		
	end
	
	return false

end		

include("itembase.lua")
if (SERVER) then
	AddCSLuaFile("itembase.lua")
end	

for k, v in pairs( file.Find(PNRP_Path.."gamemode/items/*.lua", "LUA" ) ) do
	include("items/"..v)
	if (SERVER) then AddCSLuaFile("items/"..v) end
end

function PNRP:GetUID( ply )
	local plUID = tostring(ply:GetNetworkedString( "UID" , "None" ))
	if plUID == "None" then
		plUID = ply:UniqueID()
	end
	
	return plUID
end

function PNRP.FindItemID( class )
	
	for itemname, item in pairs( PNRP.Items ) do
		if item.Ent == "prop_physics" and item.ID == class then
			return item.ID
		elseif class == item.Ent then
			return item.ID
		end
		
	end	
	return nil
	
end

function PNRP.FindWepItem( model )
	local fixedModel
	if string.find(model, "v_") then
		fixedModel = string.sub( model, 1, string.find(model, "v_") - 1).."w"..string.sub( model, string.find(model, "v_") + 1 )
	else
		fixedModel = model
	end
	if model == "models/Weapons/V_hands.mdl" or model == "models/weapons/v_hands.mdl" then
		fixedModel = "models/props_citizen_tech/transponder.mdl"
	end
	
	for itemname, item in pairs( PNRP.Items ) do
		if fixedModel == item.Model then
			return item
		end
		
	end	
	return nil
	
end

function GM:StartEntityDriving( ent, ply )
	if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then
		drive.Start( ply, ent )
	end
end

function PNRP.FindAmmoType( id, class )
	if id then
		if PNRP.Items[id].Type == "weapon" then
			return PNRP.Weapons[id].AmmoType	
		end
--		if id == "wep_deagle" or id == "wep_scout" then
--			return "357"
--		elseif id == "wep_p228" then
--			return "pistol"
--		elseif id == "wep_shotgun" then
--			return "buckshot"
--		else
--			return "smg1"
--		end
--	elseif class then
--		if class == "wep_deagle" or class == "wep_scout" then
--			return "357"
--		elseif class == "wep_p228" then
--			return "pistol"
--		elseif class == "wep_shotgun" then
--			return "buckshot"
--		else
--			return "smg1"
--		end
	end
end

function PlayerMeta:TraceFromEyes(dist)
	local trace = {}
	trace.start = self:GetShootPos()
	trace.endpos = trace.start + (self:GetAimVector() * dist)
	trace.filter = self

	return util.TraceLine(trace)
end

----------------------------------------
--		Weapon HOLDTYPE SWITCH fix	  --
--____________________________________--
--	I know this is hacky.  Not much	  --
--	I can do about that.  Only way I  --
--	got the stupid shit to work.	  --
----------------------------------------

local RP_Default_Weapons = {}
RP_Default_Weapons = { "weapon_pnrp_ak-comp", "weapon_pnrp_badlands", "weapon_pnrp_charge", "weapon_pnrp_knife", 
		"weapon_pnrp_p228", "weapon_pnrp_precrifle", "weapon_pnrp_pumpshotgun", "weapon_pnrp_revolver", "weapon_pnrp_saw", 
		"weapon_pnrp_scrapmp", "weapon_pnrp_smg", "weapon_pnrp_57luck", "weapon_pnrp_ump", "weapon_pnrp_m82", "weapon_pnrp_pulserifle",
		"weapon_pnrp_flaregun" }

local function HoldTypeFix()
	for k, v in pairs(player.GetAll()) do
		local myWep = v:GetActiveWeapon()
		if myWep and IsValid(myWep) then
			local wepFound = false
			for _, wepClass in pairs(RP_Default_Weapons) do
				if wepClass == myWep:GetClass() then
					wepFound = true
					break
				end
			end
		
			if wepFound and IsValid(myWep) then
				if v:Crouching() then
					myWep:SetWeaponHoldType(myWep.HoldType)
				elseif myWep:GetNWBool("IsPassive", false) or myWep:GetDTBool(0) or v:KeyDown( IN_SPEED ) then
					if myWep.HoldType == "pistol" or myWep.HoldType == "revolver" or myWep.HoldType == "knife" or myWep.HoldType == "slam" then
						myWep:SetWeaponHoldType("normal")
					else
						myWep:SetWeaponHoldType("passive")
					end
				elseif myWep:GetDTBool(1) and myWep.HoldType == "pistol" then
					myWep:SetWeaponHoldType("revolver")
				elseif myWep:GetDTBool(1) and myWep.HoldType == "shotgun" then
					myWep:SetWeaponHoldType("ar2")
				else
					myWep:SetWeaponHoldType(myWep.HoldType or "normal")
				end
			end
		end
	end
end
hook.Add( "Think", "holdtypefix", HoldTypeFix )

function toIntfromBool(bool)
	if bool == true then
		return 1
	elseif bool == false then
		return 0
	else 
		return bool
	end
end

--Checks the players weight
function PNRP:WeightCk( ply, w )
	local weightCap
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
	end
	local expWeight = PNRP.InventoryWeight( ply ) + weight
	if expWeight <= weightCap then
		return true
	else
		return false
	end
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

--EOF