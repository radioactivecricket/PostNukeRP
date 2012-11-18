include('shared.lua')

function ENT:Draw()
	self.Entity:DrawModel()
	local myPlayer = LocalPlayer()
	
	local distance = tonumber(self.Entity:GetNWString("distance"))
	if not distance then return end
	
	local tracedata = {}
	tracedata.start = myPlayer:GetShootPos()
	tracedata.endpos = tracedata.start + (myPlayer:GetAimVector() * 1000)
	tracedata.filter = myPlayer
	local trace = util.TraceLine(tracedata)
	
	if trace.Entity == self then
		local resources = self.Entity:GetNWBool("spwnsRes")
		local antlions = self.Entity:GetNWBool("spwnsAnt")
		local zombies = self.Entity:GetNWBool("spwnsZom")
		
		local mounds = self.Entity:GetNWBool("infMound")
		local indoor = self.Entity:GetNWBool("infIndoor")
		
		local gridMessage = "Distance:  "..tostring(distance).."\nSpawn Resources:  "..tostring(resources).."\nSpawn Antlions:  "..tostring(antlions).."\nSpawn Zombies:  "..tostring(zombies).."\nCan Make Mounds:  "..tostring(mounds).."\nIs Indoor:  "..tostring(indoor)
		AddWorldTip( self.Entity:EntIndex(), gridMessage, 0.5, self.Entity:GetPos(), self.Entity )
		
		local linked = self.Entity:GetNWEntity("infLinked")
		if linked:IsValid() then
			render.SetMaterial( Material( "cable/redlaser" ) )
			render.DrawBeam( self.Entity:GetPos(), linked:GetPos(), 5, 0, 0, Color( 255, 255, 255, 255 ) )
		end
	end
	
	render.SetMaterial( Material( "models/wireframe" ) )
	render.DrawQuadEasy( self.Entity:GetPos(),    --position of the rect
		Vector(0,0,1),        --direction to face in
		distance*2, distance*2,              --size of the rect
		Color( 0, 255, 0, 255 )
	) 
end
