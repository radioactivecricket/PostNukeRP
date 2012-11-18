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
		ToolCheck = itemtable.ToolCheck,
		ShopHide = itemtable.ShopHide,
		Capacity = itemtable.Capacity,
		ProfileCost = itemtable.ProfileCost,
		Persistant = itemtable.Persistant,
	}
	
end	

PNRP.Weapons = {}

function PNRP.AddWeapon( weptable )

	PNRP.Weapons[weptable.ID] =
	{
		ID = weptable.ID,
		AmmoType = weptable.AmmoType,	
	}
	
end

if (!SERVER) then return end


--EOF