/*+------------------------------------------------------------------------+
 |  Filename: ship.t                                                       |
 |  Program Description: A class for debris objects that can be called to  |
 |other programs                                                           |
 +-------------------------------------------------------------------------+
 | Author - Arjun Bhatia                                                   |
 | Date   - June 4 2018                                                    |
 +-------------------------------------------------------------------------+
 | Input  - none                                                           |
 | Output - none                                                           |
 +-------------------------------------------------------------------------+*/
class Debris

    export SetX, SetY,
	Accelerate, Show, Move, Banish,
	GetX, GetY, IsTouching

    %Declares the array of debris images
    var DebrisPiece : array 1 .. 5 of int
    
    var iAngle, iSpawn, iType : int
    var sType, sColour : string
    var rX1, rY1, rSetSpeed, iDirection, rX, rY : real

    %Declares the radius of the debris pieces
    const cDebrisRadius : int := 60

    %Sets the images of the pieces of debris
    DebrisPiece (1) := Pic.FileNew ("Debris1.bmp")
    DebrisPiece (2) := Pic.FileNew ("Debris2.bmp")
    DebrisPiece (3) := Pic.FileNew ("Debris3.bmp")
    DebrisPiece (4) := Pic.FileNew ("Debris4.bmp")
    DebrisPiece (5) := Pic.FileNew ("DebrisDamaged.bmp")


    iType := 1
    for i : 1 .. 5
	Pic.SetTransparentColour (DebrisPiece (i), black)
	DebrisPiece (i) := Pic.Rotate (DebrisPiece (i), 0, 29, 29)
    end for

    rX1 := 0
    rY1 := 0
    rX := -500
    rY := -500

    %Sets the angle that the debris moves in and the horizontal and vertical distances
    procedure Accelerate (ipDirection : int)
	iAngle := Rand.Int (-30, 30)
	rX1 := 5 * (sind (iAngle))

	iDirection := ipDirection

	rY1 := iDirection * (cosd (iAngle))

	iType := Rand.Int (1, 4)
    end Accelerate

    %Sets the X coordinate of the debris
    procedure SetX (ipX : int)
	rX := ipX
    end SetX

    %Sets the Y coordinate of the debris
    procedure SetY (ipY : int)
	rY := ipY
    end SetY

    %Moves the debris
    procedure Move
	rX += round (rX1)
	rY += round (rY1)
    end Move

    %Draws a piece of debris
    procedure Show
	Pic.Draw (DebrisPiece (iType),
	    round (rX), round (rY), picMerge)
    end Show

    %Draws a damaged debris images, then moves it offscreen
    procedure Banish
	Pic.Draw (DebrisPiece (5),
	    round (rX), round (rY), picMerge)
	delay (20)
	rX := -500
	rY := -500
	rX1 := 0
	rY1 := 0
    end Banish

    %Checks the Y coordinate of the debris
    function GetY : int
	result round (rY) + 45
    end GetY

    %Checks the X coordinate of the debris
    function GetX : int
	result round (rX) + 45
    end GetX

    %Checks if a point is within the hitbox of the debris
    function IsTouching (ipX, ipY : int) : boolean
	if (ipX - (rX + 45)) ** 2 +
		(ipY - (rY + 45)) ** 2
		< cDebrisRadius ** 2 then
	    result true
	else
	    result false
	end if
    end IsTouching

end Debris

type DebrisClass : pointer to Debris

%Initialises variables
procedure ConstructDebris (var opS : DebrisClass)
    new Debris, opS
    opS -> Banish
end ConstructDebris

%Banishes the debris and places it offscreen
procedure DestructDebris (var opS : DebrisClass)
    opS -> Banish
    free opS
end DestructDebris
