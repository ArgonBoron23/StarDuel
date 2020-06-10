/*+------------------------------------------------------------------------+
 |  Filename: ship.t                                                       |
 |  Program Description: A class for torpedo objects that can be called to |
 |other programs                                                           |
 +-------------------------------------------------------------------------+
 | Author - Arjun Bhatia                                                   |
 | Date   - June 4 2018                                                    |
 +-------------------------------------------------------------------------+
 | Input  - none                                                           |
 | Output - none                                                           |
 +-------------------------------------------------------------------------+*/
class Torpedo

    %Exports functions and procedures
    export SetX, SetY, SetSpeed, SetAngle, SetColour,
	Show, Move, Accelerate, Banish,
	GetX, GetY

    %Declares the array of rotated torpedo images
    var QTorpedo, DTorpedo : array 0 .. 23 of int

    var iAngle : int
    var sType, sColour : string
    var iX1, iY1, iX, iY, rSetSpeed : real

    %Declares blast sound
    const BlastSound : string := "TorpedoBlast.mp3"

    %Declares process to play a sound effect
    process PlaySound (file : string)
	Music.PlayFile (file)
    end PlaySound

    %Declares the images of the blue torpedo and makes it transparent
    QTorpedo (0) := Pic.FileNew ("TorpedoBlue.bmp")
    Pic.SetTransparentColour (QTorpedo (0), black)

    %Declares the images of the red torpedo and makes it transparent
    DTorpedo (0) := Pic.FileNew ("TorpedoRed.bmp")
    Pic.SetTransparentColour (DTorpedo (0), black)

    iAngle := 0

    %Creates rotated images
    for i : 0 .. 23
	QTorpedo (i) := Pic.Rotate (QTorpedo (0), i * 15, 29, 29)
	DTorpedo (i) := Pic.Rotate (DTorpedo (0), i * 15, 29, 29)
    end for

    iX1 := 0
    iY1 := 0

    %Calculates a horizontal and vertical distance while playing a sound
    procedure Accelerate
	iX1 := -50 * (sind (iAngle * 15))
	iY1 := +50 * (cosd (iAngle * 15))
	fork PlaySound (BlastSound)
    end Accelerate

    %Sets the angle of the torpedo
    procedure SetAngle (ipAngle : int)
	iAngle := ipAngle div 15
    end SetAngle

    %Sets the X coordinate of the torpedo
    procedure SetX (ipX : int)
	iX := ipX
    end SetX

    %Sets the Y coordinate of the torpedo
    procedure SetY (ipY : int)
	iY := ipY
    end SetY

    %Sets the speed multiplier of the torpedo
    procedure SetSpeed (ipSpeed : int)
	rSetSpeed := ipSpeed
    end SetSpeed

    %Moves the torpedo
    procedure Move
	iX += iX1 / 2
	iY += iY1 / 2

	if iX1 < -46 then
	    iX1 := -46
	end if

	if iY1 < -46 then
	    iY1 := -46
	end if

	if iX1 > 46 then
	    iX1 := 46
	end if

	if iY1 > 46 then
	    iY1 := 46
	end if

    end Move

    %Draws the torpedo based on the selected colour
    procedure Show
	if sColour = "red" then
	    Pic.Draw (DTorpedo (iAngle),
		round (iX) - 27,
		round (iY) - 27, picMerge)
	elsif sColour = "blue" then
	    Pic.Draw (QTorpedo (iAngle),
		round (iX) - 27,
		round (iY) - 27, picMerge)
	end if
    end Show

    %Stops the torpedo and places it offscreen
    procedure Banish
	iX := maxx + 500
	iY := maxy + 500
	iX1 := 0
	iY1 := 0
    end Banish

    %Sets the colour of the torpedo
    procedure SetColour (spColour : string)
	sColour := spColour
    end SetColour

    %Checks the Y coordinate of the torpedo
    function GetY : int
	result round (iY)
    end GetY

    %Checks the X coordinate of the torpedo
    function GetX : int
	result round (iX)
    end GetX
end Torpedo


type TorpedoClass : pointer to Torpedo

%Initialises variables
procedure ConstructTorpedo (var opS : TorpedoClass)
    new Torpedo, opS
    opS -> SetColour ('red')
    opS -> SetX (maxx + 500)
    opS -> SetY (maxy + 500)
    opS -> SetSpeed (1)
end ConstructTorpedo

%Banishes torpedo and frees all variables
procedure DestructTorpedo (var opS : TorpedoClass)
    opS -> Banish
    free opS
end DestructTorpedo
