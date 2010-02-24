--Locals
local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")
/*---------------------------------------------------------
  Process system
  
  This is based entirely on the GMStranded gamemode's code.
  Seemed to be an elegent implementation.
---------------------------------------------------------*/
PNRP.Processes = {}

function PNRP.RegisterProcess(name,tbl)
         PNRP.Processes[name] = tbl
end

--Handle think hooks
--From what little I understand, think hooks run every tick.
GM.ProcessThinkHookTable = {}
function GM.ProcessThink()
         local GM = GAMEMODE
         for k,v in pairs(GM.ProcessThinkHookTable) do
             local think;
             if v.Think then think = v:Think() end
             
             local basethink = v:BaseThink()
             
             if think or basethink then
                if v.Owner and v.Owner != NULL and v.Owner:IsValid() then 
                   v.Owner:Freeze(false)
                   --v.Owner:StopProcessBar()
                   v.Owner.InProcess = false
                   v.Owner:SendMessage("Cancelled.",3,Color(200,0,0,255))
                end

                v.IsStopped = true
                timer.Destroy("GMS_ProcessTimer_"..v.TimerID)
                GM.RemoveProcessThink(v)
             end
         end
end

hook.Add("Think","gms_ProcessThinkHooks",GM.ProcessThink)

function GM.AddProcessThink(tbl)
         table.insert(GAMEMODE.ProcessThinkHookTable,tbl)
end

function GM.RemoveProcessThink(tbl)
         for k,v in pairs(GAMEMODE.ProcessThinkHookTable) do
             if v == tbl then
                table.remove(GAMEMODE.ProcessThinkHookTable,k)
             end
         end
end

--Actual processing
function PlayerMeta:DoProcess(name,time,data)
         if self.InProcess then
            --Fail message
         return end
         
        --Need seperate instance
         self.ProcessTable = table.Merge(table.Copy(PNRP.Processes[name]),table.Copy(PNRP.Processes.BaseProcess))
         self.ProcessTable.Owner = self
         self.ProcessTable.Time = time
         self.ProcessTable.TimerID = self:UniqueID()
         if data then self.ProcessTable.Data = data end

         self.InProcess = true

         if self.ProcessTable.OnStart then self.ProcessTable:OnStart() end
         
		--Start think
         GAMEMODE.AddProcessThink(self.ProcessTable)

         timer.Create("PNRP_ProcessTimer_"..self:UniqueID(),time, 1, GAMEMODE.StopProcess, self)
end

function GM.StopProcess(pl)
	if pl == nil or pl.ProcessTable == nil then return end

	--Run stop
	local bool = pl.ProcessTable:BaseStop()
	if pl.ProcessTable.OnStop then pl.ProcessTable:OnStop() end
	--Stop think
	if pl.ProcessTable.Think then GAMEMODE.RemoveProcessThink(pl.ProcessTable) end
         
	pl.InProcess = false
	pl.ProcessTable = nil
end

--Base Process.  God say I'm doing this right...
local PROCESS = {}

function PROCESS:BaseThink()
		if ValidEntity(ent) then
         if self == nil or self.Owner == nil or !self.Owner:Alive() then
            return true
         end

         if !self.Owner:IsValid() or !self.Owner:IsConnected() then return true end
	end
end

function PROCESS:BaseStop()
         if !self.Owner:Alive() or !self.Owner or self.Owner == NULL then return false end
         if !self.Owner:IsValid() then return false end         
         --self.Owner:StopProcessBar()
         return true
end

PNRP.Processes.BaseProcess = PROCESS

--Scavenging Scrap
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:Freeze(true)
         
         self.StartTime = CurTime()
         
         self:PlaySound()
         if !self.Data.Entity.Uses then self.Data.Entity.Uses = math.random(5,20) end
end

function PROCESS:PlaySound()
         if CurTime() - self.StartTime > self.Time then return end
		 
         if self.Owner:Alive() then
			 self.Owner:GetActiveWeapon():SendWeaponAnim(ACT_VM_HITCENTER)
			 self.Owner:EmitSound(Sound("ambient/levels/streetwar/building_rubble"..tostring(math.random(1,5))..".wav"))
			 
			 timer.Simple(1.5,self.PlaySound,self)
		 end
end

function PROCESS:OnStop()
         local num = math.random(1,100)

		 if self.Owner:Team() == 2 then
			self.Data.Chance = self.Data.Chance * 1.5
			self.Data.MaxAmount = self.Data.MaxAmount * 2
		 end
		 
         if num < self.Data.Chance then
            local num2 = math.random(self.Data.MinAmount,self.Data.MaxAmount)
            self.Owner:IncResource("Scrap",num2)
            self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))

            if self.Data.Entity and self.Data.Entity.Uses then self.Data.Entity.Uses = self.Data.Entity.Uses - num2 end
         else
            --self.Owner:SendMessage("Failed.",3,Color(200,0,0,255))
         end
         
         self.Owner:Freeze(false)
         
         if self.Data.Entity and self.Data.Entity.Uses then
            if self.Data.Entity.Uses <= 0 then
               self.Data.Entity:Remove()
            end
         end
end

PNRP.RegisterProcess("ScavScrap",PROCESS)

--Scavving Chems
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:Freeze(true)
         
         self.StartTime = CurTime()
         
         self:PlaySound()
         if !self.Data.Entity.Uses then self.Data.Entity.Uses = math.random(5,20) end
end

function PROCESS:PlaySound()
         if CurTime() - self.StartTime > self.Time then return end
		 
         if self.Owner:Alive() then
			 self.Owner:GetActiveWeapon():SendWeaponAnim(ACT_VM_HITCENTER)
			 self.Owner:EmitSound(Sound("ambient/levels/streetwar/building_rubble"..tostring(math.random(1,5))..".wav"))
			 
			 timer.Simple(1.5,self.PlaySound,self)
		 end
end

function PROCESS:OnStop()
         local num = math.random(1,100)
		 
		 if self.Owner:Team() == 2 then
			self.Data.Chance = self.Data.Chance * 1.5
			self.Data.MaxAmount = self.Data.MaxAmount * 2
		 end

         if num < self.Data.Chance then
            local num2 = math.random(self.Data.MinAmount,self.Data.MaxAmount)
            self.Owner:IncResource("Chemicals",num2)
            self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))

            if self.Data.Entity and self.Data.Entity.Uses then self.Data.Entity.Uses = self.Data.Entity.Uses - num2 end
         else
            --self.Owner:SendMessage("Failed.",3,Color(200,0,0,255))
         end
         
         self.Owner:Freeze(false)
         
         if self.Data.Entity and self.Data.Entity.Uses then
            if self.Data.Entity.Uses <= 0 then
               self.Data.Entity:Remove()
            end
         end
end

PNRP.RegisterProcess("ScavChems",PROCESS)

--Scavving Parts
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:Freeze(true)
         
         self.StartTime = CurTime()
         
         self:PlaySound()
         if !self.Data.Entity.Uses then self.Data.Entity.Uses = math.random(5,20) end
end

function PROCESS:PlaySound()
         if CurTime() - self.StartTime > self.Time then return end
		 
         if self.Owner:Alive() then
			 self.Owner:GetActiveWeapon():SendWeaponAnim(ACT_VM_HITCENTER)
			 self.Owner:EmitSound(Sound("ambient/levels/streetwar/building_rubble"..tostring(math.random(1,5))..".wav"))
			 
			 timer.Simple(1.5,self.PlaySound,self)
		 end
end

function PROCESS:OnStop()
         local num = math.random(1,100)
		 
		 if self.Owner:Team() == 2 then
			self.Data.Chance = self.Data.Chance * 1.5
			self.Data.MaxAmount = self.Data.MaxAmount * 2
		 end

         if num < self.Data.Chance then
            local num2 = math.random(self.Data.MinAmount,self.Data.MaxAmount)
            self.Owner:IncResource("Small_Parts",num2)
            self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))

            if self.Data.Entity and self.Data.Entity.Uses then self.Data.Entity.Uses = self.Data.Entity.Uses - num2 end
         else
            --self.Owner:SendMessage("Failed.",3,Color(200,0,0,255))
         end
         
         self.Owner:Freeze(false)
         
         if self.Data.Entity and self.Data.Entity.Uses then
            if self.Data.Entity.Uses <= 0 then
               self.Data.Entity:Remove()
            end
         end
end

PNRP.RegisterProcess("ScavParts",PROCESS)

--item construction
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:Freeze(true)
         if self.Owner:GetResource("Scrap") < self.Data.Scrap and self.Owner:GetResource("Small_Parts") < self.Data.SmallParts and self.Owner:GetResource("Chemicals") < self.Data.Chems then
			return end
         self.StartTime = CurTime()
         
end

function PROCESS:PlaySound()
         if CurTime() - self.StartTime > self.Time then return end
		 
         if self.Owner:Alive() then
			 self.Owner:GetActiveWeapon():SendWeaponAnim(ACT_VM_HITCENTER)
			 self.Owner:EmitSound(Sound("ambient/materials/metal_rattle"..tostring(math.random(1,4))..".wav"))
			 
			 timer.Simple(1.5,self.PlaySound,self)
		 end
end

function PROCESS:OnStop()
         local num = math.random(1,100)

         if num < self.Data.Chance then
            self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))
			
			self.Owner:DecResource("Scrap", self.Data.Scrap)
			self.Owner:DecResource("Small_Parts", self.Data.SmallParts)
			self.Owner:DecResource("Chemicals", self.Data.Chems)
			
			local pos = self.Data.Pos + Vector(0,0,20)
			
			if self.Data.Type == "tool" then
				self.Data.Create(self.Owner, self.Data.Ent, pos)
			else
				local ent = ents.Create(self.Data.Ent)
				if self.Data.Type == "ammo" or self.Data.Type == "weapon" then
			
					ent:SetNetworkedString("Ammo", tostring(self.Data.Energy))

				end
				ent:SetModel(self.Data.Model)
				ent:SetAngles(Angle(0,0,0))
				ent:SetPos(pos)
				ent:Spawn()
				ent:SetNetworkedString("Owner", "World")
			end
			
			Msg(self.Owner:Nick().." created "..tostring(self.Data.Name)..".\n")
         else
            --self.Owner:SendMessage("Failed.",3,Color(200,0,0,255))
         end
         
         self.Owner:Freeze(false)
         
end

PNRP.RegisterProcess("ConstructItem",PROCESS)

--vehicle construction
local PROCESS = {}

function PROCESS:OnStart()
         self.Owner:Freeze(true)
         if self.Owner:GetResource("Scrap") < self.Data.Scrap and self.Owner:GetResource("Small_Parts") < self.Data.SmallParts and self.Owner:GetResource("Chemicals") < self.Data.Chems then
			return end
         self.StartTime = CurTime()
         
end

function PROCESS:PlaySound()
         if CurTime() - self.StartTime > self.Time then return end
		 
         if self.Owner:Alive() then
			 self.Owner:GetActiveWeapon():SendWeaponAnim(ACT_VM_HITCENTER)
			 self.Owner:EmitSound(Sound("ambient/materials/metal_rattle"..tostring(math.random(1,4))..".wav"))
			 
			 timer.Simple(1.5,self.PlaySound,self)
		 end
end

function PROCESS:OnStop()
         local num = math.random(1,100)

         if num < self.Data.Chance then
            self.Owner:EmitSound(Sound("items/ammo_pickup.wav"))
            
			self.Owner:DecResource("Scrap", self.Data.Scrap)
			self.Owner:DecResource("Small_Parts", self.Data.SmallParts)
			self.Owner:DecResource("Chemicals", self.Data.Chems)
			
			local ent = ents.Create(self.Data.Ent)
			local pos = self.Data.Pos + Vector(0,0,20)
			
			ent:SetAngles(Angle(0,0,0))
			ent:SetPos(pos)
			Msg(tostring(self.Data.Model).."\n")
			//This fixes the seating animation for the seats
			if(self.Data.Ent == "prop_vehicle_prisoner_pod") then
				Msg("Seat fix ran. \n")
				local vname = self.Data.ID
				local VehicleList = list.Get( "Vehicles" )
				local vehicle = VehicleList[ vname ]
				
				ent:SetModel(self.Data.Model)
				
				// Not a valid vehicle to be spawning..
				if ( vehicle ) then 
					for k, v in pairs( vehicle.KeyValues ) do
						ent:SetKeyValue( k, v )
					end	 
					ent:Spawn()
					ent:Activate()
					
					ent.VehicleName 	= vname
					ent.VehicleTable 	= vehicle
					ent.ClassOverride 	= vehicle.Class
					//This is the main part that fixes the animation.
					if ( vehicle.Members ) then
						table.Merge( ent, vehicle.Members )
						duplicator.StoreEntityModifier( ent, "VehicleMemDupe", vehicle.Members );
					end
					
					ent:SetNetworkedString("Owner", "World")
				end
			else
			
				ent:SetModel(self.Data.Model)
				ent:SetKeyValue( "actionScale", 1 ) 
				ent:SetKeyValue( "VehicleLocked", 0 ) 
				ent:SetKeyValue( "solid", 6 ) 
				ent:SetKeyValue( "vehiclescript", self.Data.Script ) 
				
				ent:SetKeyValue( "model", self.Data.Model )
				ent:Spawn()
				ent:Activate()
				ent:SetNetworkedString("Owner", "World")
				if self.Data.Ent == "weapon_seat" then
					ent:SetNetworkedString("Type", "1")
				end
			end
         else
            --self.Owner:SendMessage("Failed.",3,Color(200,0,0,255))
         end
         
         self.Owner:Freeze(false)
         
end

PNRP.RegisterProcess("ConstructJeep",PROCESS)