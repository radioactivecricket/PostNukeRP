--Help Menu Frame

local help = 	{

				"Welcome to PostNumeRP.",
				"",
				"What to do? Find recources and stay alive!",
				"",
				"In Game Commands",
				"------------------------------------------------",
				"TAB - Main Menu",
				"F1 - Help (This Menu)",
				"F2 - Pickup / Take or Release Ownership of Car",
				"F3 - Personal Inventory or when looking at your car, Car Inventory",
				"F4 - Shop Menu",
				"F12 - Set / Release Ownership.",
				"",
				"/save - save's your characters data.",
				"/getallcars - picks up any cars that belong to you in the world",
				"/getcar - picks up the car that you are looking at within 200. You must own the car to pick it up.",
				"/stowgun /stowpwep or /putawaygun - Moved your active gun to inventory.",
				"/dropweap or /dropgun - drops your current weapon.",
				"/dropammo ammoType ammount - Drops the type and ammount of ammo.",
				"          ammoTypes = smg1, buckshot, pistol, 357, ect....",
				"/classmenu - Opens the class change menu.",
				"/shop - Opens shop menu.",
				"/inv - Opens the players inventory.",
				"/setowner - Set / Release Ownership.",
				"/sleep - When the players Endurance reaches a certin point the player is able to sleep.",
				"          Players also get a bonus to HP recovery while asleep and the player will automatically wake back up when Endurance is full. ",
				"/wake - Wakes the player from the sleeping state.",
				"/salvage - Salvages the item that you are looking at.",
				"",
				"Hands (Weapon):",
				"          Left Click - Gather Resources.",
				"          Right Click - Knock on Door.",
				"          Alt+Left Click - Unlock Door or Car.",
				"          Alt+Right Click - Lock Door or Car.",
				"",
				"Classes",
				"------------------------------------------------",
				"Note: If enabled by admins, there is a cost to changing classes.",
				"",
				"WASTELANDER:",	
				"Bonus to HP",
				"Bonus to Endurance (In Dev)",
				"",
				"SCAVENGER:",
				"Bonus to Run Speed",
				"Bonus to Gathering Speed",
				"",
				"ENGINEER:",	
				"Ability to create Weapons and Ammo",
				"",
				"SCIENCE:",		
				"Ability to create Med Kits",
				"Ability to create Explosives",
				"",
				"CULTIVATOR:",	
				"Ability to create higher quality food with additional qualities.",
				"",
				"Player Health:",
				"------------------------------------------------",
				"Players may recove HP in many ways.",
				"Get a Health Kit from a Scientist, Wait inside a building, or use /sleep when thier endurance is low enough.",
				"",
				"Player Death:",
				"------------------------------------------------",
				"When you die, you will drop all your equiped weapons and ammo",
				"to the ground. This does not affect whats in your inventory.",
				"If enabled, there is a % cost to your resources when you die.",
				"",
				"Hunger:",
				"------------------------------------------------",
				"A Players hunger will decrease over time and will increase the rate it does down based on what the player is doing.",
				"If a player reaches 0 Hunger they will start to take damage.",
				"Other than the Can O Beans that can be created by any class, the Cultivator is needed to create higher quality food",
				"with better benifits.",
				"Some foods within this class will require special items available to the cultivator.",
				"",
				"Endurance:",
				"------------------------------------------------",
				"Endurance decreases at a steady rate and is replinished by either sleeping or some foods provided by the cultivator",
				"class.",
				"",
				"------------------------------------------------",
				"",
				"PostNukeRP Site: http://postnukerp.com/",
				"PostNukeRP Forums: http://gmdev.thercs.net/",
				"Radioactive Cricket Site: http://radioactivecricket.com/   (Will post updates here too)",
				"Team Echo Forums: http://tecgmodgroup.forumotion.com/",
				"",
				"You can also look for our PostNukeRP Steam group as well."
				}
				
function HelpPanel() 
	local HelpFrame = vgui.Create("DFrame")
		HelpFrame:SetSize(700, 700)
		HelpFrame:SetPos(ScrW() / 2 - HelpFrame:GetWide() / 2, ScrH() / 2 - HelpFrame:GetTall() / 2)
		HelpFrame:SetTitle( "Help Menu" )
		HelpFrame:SetBackgroundBlur(true)
		HelpFrame:SetVisible( true )
		HelpFrame:SetDraggable( true )
		HelpFrame:ShowCloseButton( true )
		HelpFrame:MakePopup()
		
	local pnlList = vgui.Create("DPanelList", HelpFrame)
		pnlList:SetPos(20, 40)
		pnlList:SetSize(HelpFrame:GetWide() - 40, HelpFrame:GetTall() - 60)
		pnlList:EnableVerticalScrollbar(true) 
		pnlList:EnableHorizontal(false) 
		pnlList:SetSpacing(0)
		pnlList:SetPadding(10)
		
		for k, v in pairs( help ) do
			local ReadThis = vgui.Create( "DLabel", HelpFrame )
				ReadThis:SetText( v )
				pnlList:AddItem( ReadThis )
		end	
		
end
concommand.Add("pnrp_help", HelpPanel)

--EOF