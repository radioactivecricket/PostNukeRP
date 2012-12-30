
// Variables that are used on both client and server

SWEP.Author		= "LostInTheWired"
SWEP.Contact		= "N/A"
SWEP.Purpose		= "A turret IFF programmer."
SWEP.Instructions	= "Left click to start programming a turret."

SWEP.ViewModel		= "models/weapons/v_c4.mdl" --"models/Weapons/V_hands.mdl"
SWEP.WorldModel		= "models/weapons/w_c4.mdl" --"models/props_citizen_tech/transponder.mdl"

SWEP.Spawnable      = false
SWEP.AdminSpawnable = false

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.NextLeft = 0
SWEP.NextRight = 0

/*---------------------------------------------------------
	Initialize
---------------------------------------------------------*/
function SWEP:Initialize()

--    if (!SERVER) then return end
	
    self:SetWeaponHoldType("slam")	
						
end
	
/*---------------------------------------------------------
	Deploy
---------------------------------------------------------*/
function SWEP:Deploy()

    -- if (!SERVER) then return end
    -- self.Owner:DrawWorldModel(false)
	
end	
	
	
/*---------------------------------------------------------
	Reload 
---------------------------------------------------------*/
function SWEP:Reload()
	
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
    
	if CurTime() < self.NextLeft then return end
	
	if (!SERVER) then return end
	
	-- local Channel = self.Owner.Channel
	-- if not Channel then Channel = 400.00 end
	
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos()+(self.Owner:GetAimVector()*80)
	tracedata.filter = self.Owner
	local traceRes = util.TraceLine(tracedata)
	
	if traceRes.HitNonWorld then
		if IsValid(traceRes.Entity) and traceRes.Entity:GetClass() == "npc_turret_floor" then
			local ent = traceRes.Entity
			local plUID = PNRP:GetUID( self.Owner )
			local ownerUID = ent:GetNWString( "Owner_UID", "None" )
			local canProg = false
			
			
			if ownerUID == plUID then canProg = true end
			if ent.GetPlayer and type(ent.GetPlayer) == "function" then
				if self.Owner == ent:GetPlayer() then canProg = true end
			end
			
			if not canProg then
				local ownerEnt = ent:GetNWEntity( "ownerent", nil )
				if ent.GetPlayer and type(ent.GetPlayer) == "function" and not ownerEnt then
					ownerEnt = ent:GetPlayer() or nil
				end
				if ownerEnt then
					if ownerEnt.PropBuddyList then
						if ownerEnt.PropBuddyList[PNRP:GetUID( self.Owner )] then
							canProg = true
						end
					end
				end
			end
			
			if canProg then
				net.Start("turretprog_menu")
					net.WriteEntity(ent)
					net.WriteBit(ent.Whitelist)
					net.WriteTable(ent.ProgTable)
				net.Send(self.Owner)
			else
				self.Owner:ChatPrint("This isn't your turret, and do not know the access code.")
			end
		end
	end
	
	-- umsg.Start("radiofreq_select", self.Owner)
		-- umsg.Entity(self.Owner)
		-- umsg.String(Channel)
	-- umsg.End()
	
	self.NextLeft = CurTime() + 1
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
	if CurTime() < self.NextRight then return end
	
	-- if (!SERVER) then return end
	-- self.Owner.RdioPower = (not self.Owner.RdioPower)
	-- local mystring = "Radio is now "

	-- if self.Owner.RdioPower then 
		-- mystring = mystring.."on."
		-- self.Power = "on"
	-- else
		-- mystring = mystring.."off."
		-- self.Power = "off"
	-- end
	
	-- umsg.Start("radiopower_select", self.Owner)
		-- umsg.Bool(self.Owner.RdioPower)
	-- umsg.End()
	
	-- self.Owner:ChatPrint(mystring)
	
	self.NextRight = CurTime() + 1
end

/*---------------------------------------------------------
	Think does nothing 
---------------------------------------------------------*/
function SWEP:Think()

end

