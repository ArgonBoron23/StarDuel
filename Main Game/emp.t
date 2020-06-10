/*+------------------------------------------------------------------------+
 |  Filename: ship.t                                                       |
 |  Program Description: A class for EMP objects that can be called to     |
 |other programs                                                           |
 +-------------------------------------------------------------------------+
 | Author - Arjun Bhatia                                                   |
 | Date   - June 4 2018                                                    |
 +-------------------------------------------------------------------------+
 | Input  - none                                                           |
 | Output - none                                                           |
 +-------------------------------------------------------------------------+*/
class EMP
    %Declares keys


    %Exports functions and procedures
    export SetX, SetY, SetColour,
	Show, Banish,
	GetX, GetY, IsTouching

    %Declares the variable for the colour of the EMP
    var sColour : string
    var iX, iY : int

    %Declares the radius of the EMP
    const EMPRadius : int := 200

    %Gets the amount of frames in each GIF
    var numFramesQ := Pic.Frames ("EMPBlue.gif")
    var numFramesD := Pic.Frames ("EMPRed.gif")

    var delayTime : int

    %Declares the array for the frames of the GIF
    var QEMP : array 1 .. numFramesQ of int
    var DEMP : array 1 .. numFramesD of int

    %Creates EMP images
    Pic.FileNewFrames ("EMPBlue.gif", QEMP, delayTime)
    Pic.FileNewFrames ("EMPRed.gif", DEMP, delayTime)

    %Declares the sound effect for an EMP blast
    var BlastSound : string := "EMPBuzz.mp3"

    %Declares the process to play a sound effect
    process PlaySound (file : string)
	Music.PlayFile (file)
    end PlaySound

    iX := 0
    iY := 0

    %Sets the X coordinate of the EMP
    procedure SetX (ipX : int)
	iX := ipX
    end SetX

    %Sets the Y coordinate of the EMP
    procedure SetY (ipY : int)
	iY := ipY
    end SetY

    %Draws the EMP based on the selected colour while playing a sound effect
    procedure Show
	fork PlaySound (BlastSound)
	if sColour = "red" then
	    Pic.DrawFrames (DEMP, iX - EMPRadius, iY - EMPRadius, picMerge, numFramesD, 50, false)

	elsif sColour = "blue" then
	    Pic.DrawFrames (QEMP, iX - EMPRadius, iY - EMPRadius, picMerge, numFramesQ, 50, false)
	end if
    end Show

    %Sets the colour of the EMP
    procedure SetColour (pColour : string)
	sColour := pColour
    end SetColour

    %Places the EMP offscreen
    procedure Banish
	iX := maxx + 500
	iY := maxy + 500
    end Banish

    %Checks if a points is inside the radius of the EMP
    function IsTouching (ipX, ipY : int) : boolean
	if
		(ipX - iX) ** 2 +
		(ipY - iY) ** 2
		< EMPRadius ** 2 then
	    result true
	else
	    result false
	end if
    end IsTouching

    %Checks the Y coordinate of the EMP
    function GetY : int
	result round (iY)
    end GetY

    %Check the X coordinate of the EMP
    function GetX : int
	result round (iX)
    end GetX

end EMP


type EMPClass : pointer to EMP

%Initialises variables
procedure ConstructEMP (var opS : EMPClass)
    new EMP, opS
    opS -> Banish
    opS -> SetColour ('red')
end ConstructEMP

%Banishes the EMP and frees all variables
procedure DestructEMP (var opS : EMPClass)
    opS -> Banish
    free opS
end DestructEMP
