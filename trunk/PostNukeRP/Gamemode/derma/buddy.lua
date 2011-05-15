local buddy_frame

function GM.BuddyWindow(handler, id, encoded, decoded)

	local buddyTable = decoded["buddyTable"]		
	local ply = LocalPlayer()
	
	local plUID = PNRP:GetUID( ply )
	
	buddy_frame = vgui.Create( "DFrame" )
			buddy_frame:SetSize( 380, 260 ) --Set the size
			buddy_frame:SetPos(ScrW() / 2 - buddy_frame:GetWide() / 2, ScrH() / 2 - buddy_frame:GetTall() / 2) --Set the window in the middle of the players screen/game window
			buddy_frame:SetTitle( "Buddy Menu" ) --Set title
			buddy_frame:SetVisible( true )
			buddy_frame:SetDraggable( true )
			buddy_frame:ShowCloseButton( true )
			buddy_frame:MakePopup()
			
			local PlayerLabel = vgui.Create("DLabel", buddy_frame)
				PlayerLabel:SetPos(10, 25)
				PlayerLabel:SetText("Player List")
				PlayerLabel:SizeToContents() 
				
			local PlyComboBox = vgui.Create( "DComboBox", buddy_frame )
				PlyComboBox:SetPos( 10, 45 )
				PlyComboBox:SetSize( 125, 200 )
				PlyComboBox:SetMultiple( false ) -- <removed sarcastic and useless comment>
			
			local addName = true
				for k,v in pairs(ents.GetAll()) do
					if v:GetClass()=="player" then
						if v:GetName() != ply:Nick() then
							for _, b in pairs(buddyTable) do
								if v:GetName() == b then
									addName = false
								else
									addName = true
								end
							end
							if addName then
								PlyComboBox:AddItem( v:GetName() )
							end
						end
					end
				end
			
			local AddBuddyBTN = vgui.Create("DButton", buddy_frame )
				AddBuddyBTN:SetText( "Add Buddy >>" )
				AddBuddyBTN:SetPos( 140, 50 )
				AddBuddyBTN:SetSize( 100, 20 ) 
				AddBuddyBTN.DoClick = function()
					if PlyComboBox:GetSelectedItems() and PlyComboBox:GetSelectedItems()[1] then 
						local addPlyBuddy = PlyComboBox:GetSelectedItems()[1]:GetValue()
						for _, v in pairs(player.GetAll()) do
							if v:Nick() == addPlyBuddy then
								addPlyBuddy = PNRP:GetUID( v )
							end
						end
						RunConsoleCommand( "PNRP_AddBuddy", addPlyBuddy )

						buddy_frame:Close()
					end
				end	   
			
			local BuddyLabel = vgui.Create("DLabel", buddy_frame)
				BuddyLabel:SetPos(245, 25)
				BuddyLabel:SetText("Buddy List")
				BuddyLabel:SizeToContents() 		
				
			local BuddyComboBox = vgui.Create( "DComboBox", buddy_frame )
				BuddyComboBox:SetPos( 245, 45 )
				BuddyComboBox:SetSize( 125, 200 )
				BuddyComboBox:SetMultiple( false ) -- <removed sarcastic and useless comment>
				
				for _, v in pairs(buddyTable) do
						BuddyComboBox:AddItem( v )
				end
			
			local RemBuddyBTN = vgui.Create("DButton", buddy_frame )
				RemBuddyBTN:SetText( "<< Remove Buddy" )
				RemBuddyBTN:SetPos( 140, 75 )
				RemBuddyBTN:SetSize( 100, 20 ) 
				RemBuddyBTN.DoClick = function()
					if BuddyComboBox:GetSelectedItems() and BuddyComboBox:GetSelectedItems()[1] then 
						local remPlyBuddy = BuddyComboBox:GetSelectedItems()[1]:GetValue()
						for _, v in pairs(player.GetAll()) do
							if v:Nick() == remPlyBuddy then
								remPlyBuddy = PNRP:GetUID( v )
							end
						end
						RunConsoleCommand( "PNRP_RemBuddy", remPlyBuddy )

						buddy_frame:Close()
					end
				end	
end
--concommand.Add( "pnrp_buddy_window", open_buddy )
datastream.Hook( "pnrp_OpenBuddyWindow", GM.BuddyWindow )

function GM.initBuddy(ply)

	RunConsoleCommand("pnrp_OpenBuddy")

end
concommand.Add( "pnrp_buddy_window",  GM.initBuddy )
