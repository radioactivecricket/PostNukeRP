GM.Name 	= "PostNukeRP v44" --Set the gamemode name
GM.Author 	= "EldarStorm LostInTheWird Gmod Addict" --Set the author name
GM.Email 	= "N/A" --Set the author email
GM.Website 	= "http://radioactivecricket.com" --Set the author website

DeriveGamemode("sandbox") 

PNRP = {}

--Team Variables

TEAM_WASTELANDER = 1
TEAM_SCAVENGER = 2
TEAM_SCIENCE = 3
TEAM_ENGINEER = 4
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
				"weapon_real_cs_knife",
				"gmod_camera",
				"gmod_tool"}
				
PNRP.WastelanderSkill={	"Skill_1",
						"Skill_2",
						"Skill_3"}
							
PNRP.ScavengerSkill = {	"Skill_1",
					   	"Skill_2",
					   	"Skill_3"}
							
PNRP.ScienceSkill = {	"Skill_1",
					 	"Skill_2",
					 	"Skill_3"}
							
PNRP.EngineerSkill = {	"Skill_1",
					  	"Skill_2",
					  	"Skill_3"}
							
PNRP.CultivatorSkill = {"Skill_1",
						"Skill_2",
						"Skill_3"}
														
CreateConVar("pnrp_SpawnMobs","1",FCVAR_REPLICATED + FCVAR_NOTIFY)
CreateConVar("pnrp_MaxZombies","30",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MaxFastZombies","5",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MaxPoisonZombs","2",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MaxAntlions","10",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_MaxAntGuards","1",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

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

CreateConVar("pnrp_propPay", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_propCost", "10", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_adminCreateAll", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_adminTouchAll", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_adminNoCost", "0", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_exp2Level", "3", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_toolLevel", "3", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_voiceLimit", "0", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_voiceDist", "1000", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_classChangePay", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_classChangeCost", "10", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_deathPay", "1", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
CreateConVar("pnrp_deathCost", "10", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

CreateConVar("pnrp_maxOwnDoors", "3", FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

local pmeta = FindMetaTable("Player")

function pmeta:IsOutside()

	local trace = {}
	trace.start = self:GetShootPos()
	trace.endpos = trace.start + ( self:GetUp() * 300 )
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

for k, v in pairs( file.FindInLua( "PostNukeRP/gamemode/items/*.lua" ) ) do
	include("items/"..v)
	if (SERVER) then AddCSLuaFile("items/"..v) end
end

function PNRP.FindItemID( class )
	
	for itemname, item in pairs( PNRP.Items ) do
		if class == item.Ent then
			return item.ID
		end
		
	end	
	return nil
	
end

function PNRP.FindWepItem( model )
	local fixedModel = string.sub( model, 1, string.find(model, "v_") - 1).."w"..string.sub( model, string.find(model, "v_") + 1 ) 
	
	for itemname, item in pairs( PNRP.Items ) do
		if fixedModel == item.Model then
			return item
		end
		
	end	
	return nil
	
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

--EOF