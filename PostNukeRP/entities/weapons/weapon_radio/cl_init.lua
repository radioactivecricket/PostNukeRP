include('shared.lua')

SWEP.PrintName			= "Radio"			
SWEP.Slot				= 5
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.WepSelectIcon		= nil

local function RadioFreq( data )
	local frequency = data:ReadString()
	local freqNumber = tonumber(frequency)
	
	local w = 250
	local h = 150
	local title = "Set Frequency"
	
	local freq_frame = vgui.Create("DFrame")
	--smelt_frame:SetPos( (ScrW()/2) - (w / 2), (ScrH()/2) - (h / 2))
	freq_frame:SetSize( w, h )
	freq_frame:SetTitle( title )
	freq_frame:SetVisible( true )
	freq_frame:SetDraggable( true )
	freq_frame:ShowCloseButton( true )
	freq_frame:Center()
	freq_frame:MakePopup()
	
	local freqSlider = vgui.Create( "DNumSlider", freq_frame )
	    freqSlider:SetSize( freq_frame:GetWide() - 40, 50 ) -- Keep the second number at 50
	    freqSlider:SetPos( 25, 25 )
	    freqSlider:SetText( "Frequency" )
	    freqSlider:SetMin( 400 )
	    freqSlider:SetMax( 800.99 )
	    freqSlider:SetValue( tonumber(frequency) )
	    freqSlider:SetDecimals( 2 )
	
	local SetButton = vgui.Create( "DButton" )
		SetButton:SetParent( freq_frame )
		SetButton:SetText( "Set Frequency" )
		SetButton:SetPos( freq_frame:GetWide() / 2 - 100, 100 )
		SetButton:SetSize( 100, 30 )
		SetButton.DoClick = function ()
			-- local amount = math.Round(tonumber(amountSlider:GetValue()))
			-- if amount < 1 then return end
			datastream.StreamToServer( "setfreq_stream", { ["freq"] = tostring(freqSlider:GetValue()) } )
			
			freq_frame:Close()
		end
end
usermessage.Hook("radiofreq_select", RadioFreq)
