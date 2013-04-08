local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

function BuildPowerNetwork( ent )
	
end

function EntityMeta:PowerLink( ent )
	if !self.PowerItem or !ent.PowerItem then return false end
	
	if self.NetworkContainer ~= nil and self.NetworkContainer == ent.NetworkContainer then return false end
	-- ErrorNoHalt("Ent1:  "..tostring(self).."  Ent2:  "..tostring(ent))
	-- are these both on a network?
	if self.NetworkContainer and ent.NetworkContainer then 
		 -- ErrorNoHalt("NetworkContainer Both\n")
		if self.NetworkContainer.PowerGenerator then
			table.insert(self.DirectLinks, ent)
			table.insert(ent.DirectLinks, self)
			-- ErrorNoHalt("self.LinkedItems:  "..table.ToString(self.NetworkContainer.LinkedItems).."\n")
			-- ErrorNoHalt("ent.LinkedItems:  "..table.ToString(ent.NetworkContainer.LinkedItems).."\n")
			table.Add(self.NetworkContainer.LinkedItems, ent.NetworkContainer.LinkedItems)
			-- ErrorNoHalt("self.LinkedItems, Added:  "..table.ToString(self.NetworkContainer.LinkedItems).."\n")
			table.insert(self.NetworkContainer.LinkedItems, ent.NetworkContainer)
			-- ErrorNoHalt("self.LinkedItems, Added x2:  "..table.ToString(self.NetworkContainer.LinkedItems).."\n")
			ent.LinkedItems = {}
			
			for k, v in pairs(self.NetworkContainer.LinkedItems) do
				-- ErrorNoHalt("LinkedItems loop:  "..tostring(v).."\n")
				v.NetworkContainer = self.NetworkContainer
			end
			
			--Hacky fix.  Clear out duplicates.
			local sanatizedTbl = {}
			local flags = {}
			
			for i=1,#self.NetworkContainer.LinkedItems do
			   if not flags[self.NetworkContainer.LinkedItems[i]] then
				  table.insert(sanatizedTbl, self.NetworkContainer.LinkedItems[i])
				  flags[self.NetworkContainer.LinkedItems[i]] = true
			   end
			end
			table.CopyFromTo(sanatizedTbl, self.NetworkContainer.LinkedItems)
			-- ErrorNoHalt("NetworkContainer.LinkedItems, Sanitized:  "..table.ToString(self.NetworkContainer.LinkedItems).."\n")
		elseif ent.NetworkContainer.PowerGenerator then
			table.insert(self.DirectLinks, ent)
			table.insert(ent.DirectLinks, self)
			table.Add(ent.NetworkContainer.LinkedItems, self.NetworkContainer.LinkedItems)
			for k, v in pairs(ent.NetworkContainer.LinkedItems) do
				v.NetworkContainer = ent.NetworkContainer
			end
			table.insert(ent.NetworkContainer.LinkedItems, self)
			self.NetworkContainer.LinkedItems = {}
			self.NetworkContainer = ent.NetworkContainer
		else
			table.insert(self.DirectLinks, ent)
			table.insert(ent.DirectLinks, self)
			table.Add(self.NetworkContainer.LinkedItems, ent.NetworkContainer.LinkedItems)
			for k, v in pairs(self.NetworkContainer.LinkedItems) do
				v.NetworkContainer = self.NetworkContainer
			end
			table.insert(self.NetworkContainer.LinkedItems, ent)
			ent.NetworkContainer.LinkedItems = {}
			ent.NetworkContainer = self.NetworkContainer
		end
	-- is the first on a network?
	elseif self.NetworkContainer then
		-- ErrorNoHalt("NetworkContainer Only 1st\n")
		if self.NetworkContainer.PowerGenerator then
			ent.NetworkContainer = self.NetworkContainer
			table.insert(self.DirectLinks, ent)
			table.insert(ent.DirectLinks, self)
			table.insert(self.NetworkContainer.LinkedItems, ent)
			for k, v in pairs(ent.NetworkContainer.LinkedItems) do
				v.NetworkContainer = self.NetworkContainer
			end
		elseif ent.PowerGenerator then
			self.NetworkContainer = ent
			ent.NetworkContainer = ent
			table.insert(self.DirectLinks, ent)
			table.insert(ent.DirectLinks, self)
			-- ErrorNoHalt("self.LinkedItems:  "..table.ToString(self.LinkedItems).."\n")
			table.insert(self.NetworkContainer.LinkedItems, self)
			table.Add(ent.NetworkContainer.LinkedItems, self.LinkedItems)
			-- ErrorNoHalt("NetCont.LinkedItems:  "..table.ToString(ent.NetworkContainer.LinkedItems).."\n")
			for k, v in pairs(ent.NetworkContainer.LinkedItems) do
				v.NetworkContainer = self.NetworkContainer
			end
			self.LinkedItems = {}
		else
			ent.NetworkContainer = self.NetworkContainer
			table.insert(self.DirectLinks, ent)
			table.insert(ent.DirectLinks, self)
			table.insert(self.NetworkContainer.LinkedItems, ent)
			for k, v in pairs(ent.NetworkContainer.LinkedItems) do
				v.NetworkContainer = self.NetworkContainer
			end
		end
	--the second?
	elseif ent.NetworkContainer then
		-- ErrorNoHalt("NetworkContainer Only 2nd\n")
		if ent.NetworkContainer.PowerGenerator then
			self.NetworkContainer = ent.NetworkContainer
			table.insert(self.DirectLinks, ent)
			table.insert(ent.DirectLinks, self)
			table.insert(ent.NetworkContainer.LinkedItems, self)
			for k, v in pairs(ent.NetworkContainer.LinkedItems) do
				v.NetworkContainer = self.NetworkContainer
			end
		elseif self.PowerGenerator then
			ent.NetworkContainer = self
			self.NetworkContainer = self
			table.insert(self.DirectLinks, ent)
			table.insert(ent.DirectLinks, self)
			table.insert(ent.NetworkContainer.LinkedItems, ent)
			table.Add(self.NetworkContainer.LinkedItems, ent.LinkedItems)
			for k, v in pairs(self.NetworkContainer.LinkedItems) do
				v.NetworkContainer = self.NetworkContainer
			end
			ent.LinkedItems = {}
		else
			self.NetworkContainer = ent.NetworkContainer
			table.insert(self.DirectLinks, ent)
			table.insert(ent.DirectLinks, self)
			table.insert(ent.NetworkContainer.LinkedItems, self)
			for k, v in pairs(ent.NetworkContainer.LinkedItems) do
				v.NetworkContainer = self.NetworkContainer
			end
		end
	--fuck it, neither of them are
	else
		-- ErrorNoHalt("NetworkContainer Neither\n")
		if ent.PowerGenerator then
			self.NetworkContainer = ent
			ent.NetworkContainer = ent
			table.insert(ent.DirectLinks, self)
			table.insert(self.DirectLinks, ent)
			table.insert(ent.LinkedItems, self)
			for k, v in pairs(ent.NetworkContainer.LinkedItems) do
				v.NetworkContainer = self.NetworkContainer
			end
		else
			self.NetworkContainer = self
			ent.NetworkContainer = self
			table.insert(self.DirectLinks, ent)
			table.insert(ent.DirectLinks, self)
			table.insert(self.LinkedItems, ent)
			for k, v in pairs(ent.NetworkContainer.LinkedItems) do
				v.NetworkContainer = self.NetworkContainer
			end
		end
	end
	
	self.NetworkContainer:UpdatePower()
	
	return true
end

function EntityMeta:PowerUnLink()
	if not IsValid(self.NetworkContainer) then return false	end
	
	for _, v in pairs(self.DirectLinks) do
		-- -- ErrorNoHalt("Self ("..tostring(self)..") DirectLink --> "..tostring(v).."\n")
		for key, node in pairs(v.DirectLinks) do
			if node == self then
				table.remove(v.DirectLinks, key)
				break
			end
		end
	end
	for k, v in pairs(self.NetworkContainer.LinkedItems) do
		if v == self then
			table.remove(self.NetworkContainer.LinkedItems, k)
			break
		end
	end
	
	-- -- ErrorNoHalt("self.NetworkContainer = ("..tostring(self.NetworkContainer).."\n")
	
	if self.NetworkContainer == self then
		-- -- ErrorNoHalt("Self ("..tostring(self)..") is NetworkContainer.\n")
		local linkedNodes = {}
		for k, node in pairs(self.DirectLinks) do
			-- -- ErrorNoHalt("Self.DirectLinks["..tostring(k).."] = "..tostring(node).."\n")
			local found = false
			for _, check in pairs(linkedNodes) do
				if check == node then
					-- -- ErrorNoHalt("Self.DirectLinks["..tostring(k).."] = found\n")
					found = true
				end
			end
			
			if not found then
				if table.Count(node.DirectLinks) <= 0 then
					node.NetworkContainer = nil
					
					--SPECIAL CONSIDERATIONS
					-- The turret causing problems again.
					if node:GetClass() == "npc_turret_floor" then
						node:AddRelationship("npc_zombie D_LI 99")
						node:AddRelationship("npc_fastzombie D_LI 99")
						node:AddRelationship("npc_poisonzombie D_LI 99")
						node:AddRelationship("npc_antlion D_LI 99")
						node:AddRelationship("npc_antlionguard D_LI 99")
						node:AddRelationship("npc_headcrab_poison D_LI 99")
						node:AddRelationship("npc_headcrab_fast D_LI 99")
						node:AddRelationship("npc_headcrab D_LI 99")
					end
				else
					if node.PowerGenerator then
						node.NetworkContainer = node
						for _, connectNode in pairs(self.LinkedItems) do
							if connectNode ~= node then
								-- -- ErrorNoHalt("PathToNode:  "..tostring(node).. " --> "..tostring(connectNode).."\n")
								if PathToNode( node, connectNode) then
									table.insert(node.LinkedItems, connectNode)
									connectNode.NetworkContainer = node
									table.insert(linkedNodes, connectNode)
									node.NetworkContainer:UpdatePower()
								end
							end
						end
					else
						local generator = PathToGenerator( node )
						-- -- ErrorNoHalt("PathToGenerator:  "..tostring(node).."\n")
						if IsValid(generator) then
							-- -- ErrorNoHalt("Generator is valid:  "..tostring(node).." --> "..tostring(generator).."\n")
							node.NetworkContainer = generator
							for _, connectNode in pairs(self.LinkedItems) do
								if connectNode ~= node then
									-- -- ErrorNoHalt("PathToNode:  "..tostring(node).. " --> "..tostring(connectNode).."\n")
									if PathToNode( node, connectNode) then
										table.insert(generator.LinkedItems, connectNode)
										connectNode.NetworkContainer = generator
										table.insert(linkedNodes, connectNode)
										node.NetworkContainer:UpdatePower()
									end
								end
							end
						else
							-- -- ErrorNoHalt("Generator is not valid: "..tostring(node).." --> ?\n")
							node.NetworkContainer = node
							for _, connectNode in pairs(self.LinkedItems) do
								if connectNode ~= node then
									-- -- ErrorNoHalt("PathToNode:  "..tostring(node).. " --> "..tostring(connectNode).."\n")
									if PathToNode( node, connectNode) then
										table.insert(node.LinkedItems, connectNode)
										connectNode.NetworkContainer = node
										table.insert(linkedNodes, connectNode)
										node.NetworkContainer:UpdatePower()
									end
								end
							end
						end
					end
				end
			end
		end
	else
		-- -- ErrorNoHalt("Self ("..tostring(self)..") is not NetworkContainer.\n")
		local unlinkedNodes = {}
		-- -- ErrorNoHalt("Self.NetworkContainer ("..tostring(self.NetworkContainer)..") LinkedItems = "..table.ToString(self.NetworkContainer.LinkedItems).."\n")
		for k, node in pairs(self.NetworkContainer.LinkedItems) do
			-- -- ErrorNoHalt("PathToNode:  "..tostring(node).. " --> "..tostring(self.NetworkContainer).."\n")
			if not PathToNode(self.NetworkContainer, node) then
				table.insert(unlinkedNodes, node)
				
			end
		end
		
		for k, v in pairs(unlinkedNodes) do
			for k2, v2 in pairs(self.NetworkContainer.LinkedItems) do
				if v == v2 then
					table.remove(self.NetworkContainer.LinkedItems, k2)
					break
				end
			end
		end
		
		local linkedNodes = {}
		for k, node in pairs(unlinkedNodes) do
			local found = false
			for _, check in pairs(linkedNodes) do
				if check == node then
					found = true
				end
			end
			
			if not found then
				if table.Count(node.DirectLinks) <= 0 then
					node.NetworkContainer = nil
					
					--SPECIAL CONSIDERATIONS
					-- The turret causing problems again.
					if node:GetClass() == "npc_turret_floor" then
						node:AddRelationship("npc_zombie D_LI 99")
						node:AddRelationship("npc_fastzombie D_LI 99")
						node:AddRelationship("npc_poisonzombie D_LI 99")
						node:AddRelationship("npc_antlion D_LI 99")
						node:AddRelationship("npc_antlionguard D_LI 99")
						node:AddRelationship("npc_headcrab_poison D_LI 99")
						node:AddRelationship("npc_headcrab_fast D_LI 99")
						node:AddRelationship("npc_headcrab D_LI 99")
					end
				else
					if node.PowerGenerator then
						node.NetworkContainer = node
						for _, connectNode in pairs(unlinkedNodes) do
							if connectNode ~= node then
								-- -- ErrorNoHalt("PathToNode:  "..tostring(node).. " --> "..tostring(connectNode).."\n")
								if PathToNode( node, connectNode) then
									table.insert(node.LinkedItems, connectNode)
									connectNode.NetworkContainer = node
									table.insert(linkedNodes, connectNode)
									node.NetworkContainer:UpdatePower()
								end
							end
						end
					else
						local generator = PathToGenerator( node )
						-- -- ErrorNoHalt("PathToGenerator:  "..tostring(node).."\n")
						if IsValid(generator) then
							node.NetworkContainer = generator
							for _, connectNode in pairs(unlinkedNodes) do
								if connectNode ~= node then
									-- -- ErrorNoHalt("PathToNode:  "..tostring(node).. " --> "..tostring(connectNode).."\n")
									if PathToNode( node, connectNode) then
										table.insert(generator.LinkedItems, connectNode)
										connectNode.NetworkContainer = generator
										table.insert(linkedNodes, connectNode)
										node.NetworkContainer:UpdatePower()
									end
								end
							end
						else
							node.NetworkContainer = node
							for _, connectNode in pairs(unlinkedNodes) do
								if connectNode ~= node then
									-- -- ErrorNoHalt("PathToNode:  "..tostring(node).. " --> "..tostring(connectNode).."\n")
									if PathToNode( node, connectNode) then
										table.insert(node.LinkedItems, connectNode)
										connectNode.NetworkContainer = node
										table.insert(linkedNodes, connectNode)
										node.NetworkContainer:UpdatePower()
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	self.DirectLinks = {}
	self.LinkedItems = {}
	self.NetworkContainer = nil
end

function PathToNode( sNode, tNode )
	local pathQueue = {}
	local initialPath = {}
	table.insert(initialPath, sNode)
	table.insert(pathQueue, initialPath)
	
	local found = false
	repeat
		local path = table.GetFirstValue(pathQueue)
		---- ErrorNoHalt("path:  "..table.ToString(path))
		table.remove(pathQueue, 1)
		local newPaths = {}
		local lastInPath = path[table.Count(path)]
		---- ErrorNoHalt("lastInPath:  "..tostring(lastInPath))
		for _, link in pairs(lastInPath.DirectLinks) do
			local tempPath = table.Copy(path)
			local match = false
			
			local tableCheck = {}
			for k, v in pairs(tempPath) do
				if not tableCheck[tostring(v)] then
					tableCheck[tostring(v)] = 1
				else
					tableCheck[tostring(v)] = tableCheck[tostring(v)] + 1
				end
				-- for k2, v2 in pairs(tempPath) do
					-- -- ErrorNoHalt("PathToGenerator TempPath: "..tostring(v).."   "..tostring(v2))
					-- if v == v2 and k ~= k2 then
						-- match = true
					-- end
				-- end
			end
			
			for k, v in pairs(tableCheck) do
				if v > 1 then
					match = true
				end
			end
			
			if not match then
				table.insert(tempPath, link)
				table.insert(newPaths, tempPath)
			end
			if link == tNode then 
				found = true 
				break
			end
		end
		
		if not found then
			for _, newPath in pairs(newPaths) do
				table.insert( pathQueue, math.random(table.Count(pathQueue)), newPath )
			end
		end
		
	until found or table.Count(pathQueue) == 0
	
	return found
end

function PathToGenerator( sNode )
	local pathQueue = {}
	local initialPath = {}
	table.insert(initialPath, sNode)
	table.insert(pathQueue, initialPath)
	
	local found = false
	repeat
		local path = table.GetFirstValue(pathQueue)
		---- ErrorNoHalt("PathToGenerator path:  "..table.ToString(path))
		table.remove(pathQueue, 1)
		local newPaths = {}
		local lastInPath = path[table.Count(path)]
		---- ErrorNoHalt("PathToGenerator lastInPath:  "..tostring(lastInPath))
		---- ErrorNoHalt("PathToGenerator Links: "..table.ToString(lastInPath.DirectLinks))
		for _, link in pairs(lastInPath.DirectLinks) do
			local tempPath = table.Copy(path)
			local match = false
			
			local tableCheck = {}
			for k, v in pairs(tempPath) do
				if not tableCheck[tostring(v)] then
					tableCheck[tostring(v)] = 1
				else
					tableCheck[tostring(v)] = tableCheck[tostring(v)] + 1
				end
				-- for k2, v2 in pairs(tempPath) do
					-- -- ErrorNoHalt("PathToGenerator TempPath: "..tostring(v).."   "..tostring(v2))
					-- if v == v2 and k ~= k2 then
						-- match = true
					-- end
				-- end
			end
			
			for k, v in pairs(tableCheck) do
				if v > 1 then
					match = true
				end
			end
			
			if not match then
				table.insert(tempPath, link)
				table.insert(newPaths, tempPath)
			end
			
			if link.PowerGenerator then 
				return link
				--found = true 
				--break
			end
		end
		
		if not found then
			for _, newPath in pairs(newPaths) do
				table.insert( pathQueue, math.random(table.Count(pathQueue)), newPath )
			end
		end
		
	until found or table.Count(pathQueue) == 0
	
	return false
end

function EntityMeta:PathToGenerator( )
	local sNode = self
	local pathQueue = {}
	local initialPath = {}
	table.insert(initialPath, sNode)
	table.insert(pathQueue, initialPath)
	local path = {}
	
	local found = false
	repeat
		path = pathQueue[1]
		---- ErrorNoHalt("PathToGenerator path:  "..table.ToString(path).."\n")
		table.remove(pathQueue, 1)
		local newPaths = {}
		local lastInPath = path[table.Count(path)]
		---- ErrorNoHalt("PathToGenerator lastInPath:  "..tostring(lastInPath).."\n")
		---- ErrorNoHalt("PathToGenerator Links: "..table.ToString(lastInPath.DirectLinks).."\n")
		---- ErrorNoHalt("Repeat!\n")
		for _, link in pairs(lastInPath.DirectLinks) do
			---- ErrorNoHalt("PathToGenerator DL Loop: "..table.ToString(path).."\n")
			local tempPath = table.Copy(path)
			local match = false
			
			---- ErrorNoHalt("PathToGenerator Link: "..tostring(link).."\n")
			
			--Problem Lies Here.  Need new code for loop removal.
			local tableCheck = {}
			table.insert(tempPath, link)
			---- ErrorNoHalt("PathToGenerator Path pre-loop: "..table.ToString(tempPath).."  Path="..table.ToString(path).."\n")
			for k, v in pairs(tempPath) do
				if not tableCheck[tostring(v)] then
					tableCheck[tostring(v)] = 1
				else
					tableCheck[tostring(v)] = tableCheck[tostring(v)] + 1
				end
				-- for k2, v2 in pairs(tempPath) do
					-- -- ErrorNoHalt("PathToGenerator TempPath: "..tostring(v).."   "..tostring(v2))
					-- if v == v2 and k ~= k2 then
						-- match = true
					-- end
				-- end
			end
			
			for k, v in pairs(tableCheck) do
				if v > 1 then
					match = true
				end
			end
			
			---- ErrorNoHalt("PathToGenerator Match: "..tostring(match).."\n")
			
			if not match then
				table.insert(newPaths, tempPath)
			end
			
			if link.PowerGenerator then 
				return link
			end
		end
		
		if not found then
			for _, newPath in pairs(newPaths) do
				---- ErrorNoHalt("PathToGenerator AddPathToQueue: "..table.ToString(newPath).."\n")
				table.insert( pathQueue, math.random(table.Count(pathQueue)), newPath )
			end
		end
		
	until found or table.Count(pathQueue) == 0
	
	return false
end

function EntityMeta:UpdatePower()
	-- -- ErrorNoHalt("UpdatePower called")
	if self ~= self.NetworkContainer then return end
	
	local sumPower = 0
	sumPower = sumPower + self.PowerLevel
	-- -- ErrorNoHalt("Initial sumPower:  "..tostring(sumPower).."\n")
	
	local batteries = {}
	if self:GetClass() == "tool_battery" then
		sumPower = 0
		if self.UnitLeft > 0 and !self.Charging then
			table.insert(batteries, self)
			
		end
	end
	
	for _, v in pairs(self.LinkedItems) do
		if v.PowerLevel == nil then v.PowerLevel = 0 end
		sumPower = sumPower + v.PowerLevel
		
		-- -- ErrorNoHalt("v.PowerLevel:  "..tostring(v.PowerLevel).."\n")
		-- -- ErrorNoHalt("sumPower:  "..tostring(sumPower).."\n")
		
		--  SPECIAL CONSIDERATIONS
		---- ErrorNoHalt("Class:  "..v:GetClass().."\n")
		if v:GetClass() == "tool_battery" then
			if v.UnitLeft > 0 and !v.Charging then
				table.insert(batteries, v)
			end
		end
	end
	
	--  SPECIAL CONSIDERATIONS
	--	This is for ents we don't control, like certain npcs, or things that need to happen on update
	--  for certain power items
	
	
	if table.Count(batteries) > 0 then
		---- ErrorNoHalt("Batteries! \n")
		if sumPower < 0 then
		---- ErrorNoHalt("sumPower < 0 = true! \n")
			local tempSumPower = sumPower
			for k, v in pairs(batteries) do
				---- ErrorNoHalt("battery.PowerLevel = "..tostring(math.abs(math.ceil( tempSumPower / #batteries ))).."\n")
				---- ErrorNoHalt("Key:  "..tostring(k).." \n")
				v.PowerLevel = math.abs(math.ceil( tempSumPower / #batteries ))
				---- ErrorNoHalt("sumPower = "..tostring(sumPower + math.abs(math.ceil( tempSumPower / #batteries ))).." \n")
				sumPower = sumPower + math.abs(math.ceil( tempSumPower / #batteries ))
			end
		end
	end
	
	for _, v in pairs(self.LinkedItems) do
		if v:GetClass() == "npc_turret_floor" then
			if sumPower < 0 then
				v:AddRelationship("npc_zombie D_LI 99")
				v:AddRelationship("npc_fastzombie D_LI 99")
				v:AddRelationship("npc_poisonzombie D_LI 99")
				v:AddRelationship("npc_antlion D_LI 99")
				v:AddRelationship("npc_antlionguard D_LI 99")
				v:AddRelationship("npc_headcrab_poison D_LI 99")
				v:AddRelationship("npc_headcrab_fast D_LI 99")
				v:AddRelationship("npc_headcrab D_LI 99")
				if v.ProgTable then
					if v.Whitelist then
						v:AddRelationship("player D_LI 99")
					end
					for _, ply in pairs(player.GetAll()) do
						if IsValid(ply) then
							v:AddEntityRelationship(ply, D_LI, 99)
						end
					end
					if table.Count(v.ProgTable) > 0 then
						for _, trg in pairs(v.ProgTable) do
							if IsValid(trg) then
								v:AddEntityRelationship(trg, D_LI, 99)
							end
						end
					end
					if IsValid(v:GetNWEntity("ownerent")) then
						v:AddEntityRelationship(v:GetNWEntity("ownerent"), D_LI, 99)
					end
				end
			else
				v:AddRelationship("npc_zombie D_HT 99")
				v:AddRelationship("npc_fastzombie D_HT 99")
				v:AddRelationship("npc_poisonzombie D_HT 99")
				v:AddRelationship("npc_antlion D_HT 99")
				v:AddRelationship("npc_antlionguard D_HT 99")
				v:AddRelationship("npc_headcrab_poison D_HT 99")
				v:AddRelationship("npc_headcrab_fast D_HT 99")
				v:AddRelationship("npc_headcrab D_HT 99")
				if v.ProgTable then
					if v.Whitelist then
						v:AddRelationship("player D_HT 99")
						for _, ply in pairs(player.GetAll()) do
							if IsValid(ply) then
								v:AddEntityRelationship(ply, D_HT, 99)
							end
						end
					else
						v:AddRelationship("player D_LI 99")
						for _, ply in pairs(player.GetAll()) do
							if IsValid(ply) then
								v:AddEntityRelationship(ply, D_LI, 99)
							end
						end
					end
					if table.Count(v.ProgTable) > 0 then
						for _, trg in pairs(v.ProgTable) do
							if IsValid(trg) then
								if v.Whitelist then
									v:AddEntityRelationship(trg, D_LI, 99)
								else
									v:AddEntityRelationship(trg, D_HT, 99)
								end
							end
						end
					end
					if IsValid(v:GetNWEntity("ownerent")) then
						v:AddEntityRelationship(v:GetNWEntity("ownerent"), D_LI, 99)
					end
				end
			end
		end
		
		
	end
	
	
	
	-- END SPECIAL CONSIDERATIONS
	
	self.NetPower = sumPower
	
	---- ErrorNoHalt( "Ent:  "..tostring(self).."  Power:  "..tostring(self.NetPower) )
end
