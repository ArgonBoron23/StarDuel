/*+------------------------------------------------------------------------+
 |  Filename: ship.t                                                       |
 |  Program Description: A class for laser objects that can be called to   |
 |other programs                                                           |
 +-------------------------------------------------------------------------+
 | Author - Arjun Bhatia                                                   |
 | Date   - June 4 2018                                                    |
 +-------------------------------------------------------------------------+
 | Input  - none                                                           |
 | Output - none                                                           |
 +-------------------------------------------------------------------------+*/
class Laser
    %Declares keys

    %Exports functions and procedures
    export SetX, SetY, SetSpeed, SetAngle, SetColour,
	Show, Move, Accelerate, Banish,
	GetX, GetY

    var iAngle : int
    var sType, sColour : string
    var iShipX, iShipY, iSetSpeed,
	iX, iY, idX, idY, iaX, iaY,
	iSpaceX, iSpaceY : int
    const cLaserLength : int := 30

    var BlastSound : string := "LaserBlast.mp3"

    %Declares process to play a sound effect
    process PlaySound (file : string)
	Music.PlayFile (file)
    end PlaySound

    iX := 0
    iY := 0
    idX := 0
    idY := 0
    iAngle := 0

    iSpaceX := 0
    iSpaceY := 0

    %Calculates a horizontal and vertical distance while playing a sound
    procedure Accelerate
	idX := round (-35 * (sind (iAngle * 10)))
	idY := round (35 * (cosd (iAngle * 10)))

	iX := iShipX + (idX * 2)
	iY := iShipY + (idY * 2)

	iSpaceX := idX div 5
	iSpaceY := idY div 5

	fork PlaySound (BlastSound)
    end Accelerate

    %Sets the angle of the laser
    procedure SetAngle (ipAngle : int)
	iAngle := ipAngle div 10
    end SetAngle

    %Sets the X-coordinate of the laser
    procedure SetX (ipX : int)
	iShipX := ipX
    end SetX

    %Sets the Y-coordinate of the laser
    procedure SetY (ipY : int)
	iShipY := ipY
    end SetY

    %Sets the speed multiplier of the laser
    procedure SetSpeed (ipSpeed : int)
	iSetSpeed := ipSpeed
    end SetSpeed

    %Moves the laser
    procedure Move
	iX += idX * iSetSpeed
	iY += idY * iSetSpeed
	iShipX += idX * iSetSpeed
	iShipY += idY * iSetSpeed
    end Move

    %Draws the laser based on the selected colour
    procedure Show
	if sColour = "red" then
	    Draw.ThickLine (iShipX, iShipY, iX, iY, 9, 40)

	elsif sColour = "blue" then
	    Draw.ThickLine (iShipX, iShipY, iX, iY, 9, 76)
	end if

	Draw.ThickLine (
	    iShipX - iSpaceX,
	    iShipY - iSpaceY,
	    iX + iSpaceX,
	    iY + iSpaceY,
	    3, 255)
    end Show

    %Sets the colour of the laser
    procedure SetColour (spColour : string)
	sColour := spColour
    end SetColour

    %Stops the laser and places it offscreen
    procedure Banish
	iShipX := maxx + 500
	iX := maxx + 500
	idX := 0
	iShipY := maxy + 500
	iY := maxy + 500
	idY := 0
    end Banish

    %Gets the Y coordinate of the laser
    function GetY : int
	result round (iY) - idY * 3
    end GetY

    %Gets the X coordinate of the laser
    function GetX : int
	result round (iX) - idX * 3
    end GetX

end Laser


type LaserClass : pointer to Laser

%Initialises variables
procedure ConstructLaser (var opS : LaserClass)
    new Laser, opS
    opS -> SetColour ('red')
    opS -> SetSpeed (3)
    opS -> Banish
end ConstructLaser

%Banishes laser and frees all variables
procedure DestructLaser (var opS : LaserClass)
    opS -> Banish
    free opS
end DestructLaser
