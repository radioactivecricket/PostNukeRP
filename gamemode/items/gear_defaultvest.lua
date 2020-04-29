local ITEM = {}
local WEAPON = {}


ITEM.ID = "gear_defaultvest"

ITEM.Name = "Default Testing Vest"
ITEM.ClassSpawn = "All"
ITEM.Scrap = 100
ITEM.Small_Parts = 100
ITEM.Chemicals = 100
ITEM.Chance = 100
ITEM.Info = "Testing vest."
ITEM.Type = "gear"
ITEM.Remove = true
ITEM.Energy = 30
ITEM.Ent = "weapon_pnrp_ak-comp"  --Change before spawning
ITEM.Model = "models/weapons/w_rif_ak47.mdl"  --Change before spawning
ITEM.Script = ""
ITEM.Weight = 5
ITEM.ShopHide = true

ITEM.GearSlots = {}
ITEM.GearSlots.primary 		= 1
ITEM.GearSlots.secondary	= 1
ITEM.GearSlots.sidearm		= 1
ITEM.GearSlots.melee		= 1
ITEM.GearSlots.lgammo		= 1
ITEM.GearSlots.mdammo		= 3
ITEM.GearSlots.smammo		= 4

--{ ["primary"] = 1, ["secondary"] = 1, ["sidearm"] = 1, ["melee"] = 1, ["lgammo"] = 1, 
--					["mdammo"] = 3, ["smammo"] = 4 }

function ITEM.ToolCheck( p )
	return true
end

function ITEM.Use( ply )
	
end

function ITEM.Create( ply, class, pos )
	
end

PNRP.AddItem(ITEM)