/*+------------------------------------------------------------------------+
 |  Filename: ship.t                                                       |
 |  Program Description: A class for shield objects that can be called to  |
 |other programs                                                           |
 +-------------------------------------------------------------------------+
 | Author - Arjun Bhatia                                                   |
 | Date   - June 4 2018                                                    |
 +-------------------------------------------------------------------------+
 | Input  - none                                                           |
 | Output - none                                                           |
 +-------------------------------------------------------------------------+*/
class Shield

    %Exports the functions and procedures
    export SetPosition, SetColour, SetEnergy,
	Show, Banish, Collapse, Hit, DropEnergy,
	GetX, GetY, IsActive

    var iX, iY, iEnergy : int
    var sType, sColour : string

    %Declares the sound effects
    const HitSound : string := "ForceFieldHit.mp3"
    const ProjectionSound : string := "ShieldProjection.mp3"

    %Declares the process to play sound effects
    process PlaySound (file : string)
	Music.PlayFile (file)
    end PlaySound

    %Sets the X and Y coordinates of the ship
    procedure SetPosition (ipX, ipY : int)
	iX := ipX
	iY := ipY
    end SetPosition

    %Sets the energy of the shield
    procedure SetEnergy (ipEnergy : int)
	iEnergy := ipEnergy
	if ipEnergy > 0 then
	    fork PlaySound (ProjectionSound)
	end if
    end SetEnergy

    %Reduces the energy of the shield
    procedure DropEnergy
	if iEnergy > 0 then
	    iEnergy -= 1
	end if
    end DropEnergy

    %Sets the energy of the shield to 0
    procedure Collapse
	iEnergy := 0
    end Collapse

    %Plays a sound effect
    procedure Hit
	fork PlaySound (HitSound)
    end Hit

    %Draws the shield based on the selected colour
    procedure Show
	if sColour = "red" then
	    Draw.Oval (iX, iY, 30, 30, 40)
	elsif sColour = "blue" then
	    Draw.Oval (iX, iY, 30, 30, 76)
	end if
    end Show

    %Places the shield offscreen
    procedure Banish
	iX := maxx + 500
	iY := maxy + 500
    end Banish

    %Sets the colour of the shield
    procedure SetColour (pColour : string)
	sColour := pColour
    end SetColour

    %Checks the Y coordinate of the shield
    function GetY : int
	result round (iY)
    end GetY

    %Checks the X coordinate of the shield
    function GetX : int
	result round (iX)
    end GetX

    %Checks if the shield's energy is over 0
    function IsActive : boolean
	if iEnergy > 0 then
	    result true
	else
	    result false
	end if
    end IsActive

end Shield


type ShieldClass : pointer to Shield

%Initialises variables
procedure ConstructShield (var opS : ShieldClass)
    new Shield, opS
    opS -> Banish
    opS -> SetColour ('red')
    opS -> SetEnergy (0)
end ConstructShield

%Banishes shield and frees all variables
procedure DestructShield (var opS : ShieldClass)
    opS -> Banish
    free opS
end DestructShield
