local buddy_frame

function GM.BuddyWindow( )

	local buddyTable = net.ReadTable()
	--local buddyTable = decoded["buddyTable"]		
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
				
			local PlyComboBox = vgui.Create( "DListView", buddy_frame )
				PlyComboBox:SetPos( 10, 45 )
				PlyComboBox:SetSize( 125, 200 )
				PlyComboBox:SetMultiSelect( false ) -- <removed sarcastic and useless comment>
				PlyComboBox:AddColumn("Name")
			
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
								PlyComboBox:AddLine( v:GetName() )
							end
						end
					end
				end
			
			local AddBuddyBTN = vgui.Create("DButton", buddy_frame )
				AddBuddyBTN:SetText( "Add Buddy >>" )
				AddBuddyBTN:SetPos( 140, 50 )
				AddBuddyBTN:SetSize( 100, 20 ) 
				AddBuddyBTN.DoClick = function()
					if PlyComboBox:GetSelectedLine() then						
		       			local addPlyBuddy = PlyComboBox:GetLine(PlyComboBox:GetSelectedLine()):GetValue(1) 
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
				
			local BuddyComboBox = vgui.Create( "DListView", buddy_frame )
				BuddyComboBox:SetPos( 245, 45 )
				BuddyComboBox:SetSize( 125, 200 )
				BuddyComboBox:SetMultiSelect( false ) 
				BuddyComboBox:AddColumn("Name")
				
				for _, v in pairs(buddyTable) do
						BuddyComboBox:AddLine( v )
				end
			
			local RemBuddyBTN = vgui.Create("DButton", buddy_frame )
				RemBuddyBTN:SetText( "<< Remove Buddy" )
				RemBuddyBTN:SetPos( 140, 75 )
				RemBuddyBTN:SetSize( 100, 20 ) 
				RemBuddyBTN.DoClick = function()
					if BuddyComboBox:GetSelectedLine() then						
		       			local remPlyBuddy = BuddyComboBox:GetLine(BuddyComboBox:GetSelectedLine()):GetValue(1) 
						for _, v in pairs(player.GetAll()) do
							if v:Nick() == remPlyBuddy then
								remPlyBuddy = PNRP:GetUID( v )
							end
						end
						RunConsoleCommand( "PNRP_RemBuddy", remPlyBuddy )

						buddy_frame:Close()
					end
				end	
			
	--		local AddCommBTN = vgui.Create("DButton", buddy_frame )
	--			AddCommBTN:SetText( "Add Community >>" )
	--			AddCommBTN:SetPos( 140, 75 )
	--			AddCommBTN:SetSize( 100, 20 ) 
	--			AddCommBTN.DoClick = function()
					
	--				RunConsoleCommand( "PNRP_AddCommBuddy" )

	--				buddy_frame:Close()
	--			end	
end
--concommand.Add( "pnrp_buddy_window", open_buddy )
--datastream.Hook( "pnrp_OpenBuddyWindow", GM.BuddyWindow )
net.Receive( "pnrp_OpenBuddyWindow", GM.BuddyWindow )

function GM.initBuddy(ply)

	RunConsoleCommand("pnrp_OpenBuddy")

end
concommand.Add( "pnrp_buddy_window",  GM.initBuddy )
