/*+------------------------------------------------------------------------+
 |  Filename: ship.t                                                       |
 |  Program Description: A class for ship objects that can be called to    |
 |other programs                                                           |
 +-------------------------------------------------------------------------+
 | Author - Arjun Bhatia                                                   |
 | Date   - June 4 2018                                                    |
 +-------------------------------------------------------------------------+
 | Input  - none                                                           |
 | Output - none                                                           |
 +-------------------------------------------------------------------------+*/
class Ship

    %Exports functions and procedures
    export SetX, SetY, SetSpeed, SetPlanet, SetAngle,
	Accelerate, Drift, LeftRotate, RightRotate, Disable, Enable,
	Move, Show, Banish, Explode, RemoveInertia,
	SetArmourTotal, SetArmour, DropArmour, AddArmour,
	SetCapacitorTotal, SetCapacitor, ChargeCapacitor, DrainCapacitor,
	GetX, GetY, GetAngle, GetAbility, IsTouching,
	GetArmour, GetArmourPercentage, GetCapacitorPercentage


    %Declares all variables for ship types of both alliances
    var QShip, QShipForward, QShipRight, QShipLeft, QShipDamaged,
	DShip, DShipForward, DShipRight, DShipLeft, DShipDamaged : array 0 .. 35 of int

    %Declares the array of capacitors
    var aCapacitor, aCapacitorTotal : array 0 .. 6 of real

    %Declares ship angle, current ship armour, total possible ship armour
    var iAngle, iArmour, iArmourTotal, iDisableCount : int

    %Declares image for explosion
    var pExplosion : int

    var sType, sPlanet : string
    var rX1, rY1, rX, rY, rSetSpeed : real

    %Sets a speed limit
    const cSpeedLimit : int := 13

    %Declares explosion sound
    var ExplosionSound : string := "explosion.mp3"

    %Declares process to play a sound effect
    process PlaySound (file : string)
	Music.PlayFile (file)
    end PlaySound

    %Quintitian Ships declarations and transparencies
    QShip (0) := Pic.FileNew ("qs_arrow.bmp")
    Pic.SetTransparentColour (QShip (0), black)
    QShipForward (0) := Pic.FileNew ("qs_arrow_forward.bmp")
    Pic.SetTransparentColour (QShipForward (0), black)
    QShipRight (0) := Pic.FileNew ("qs_arrow_right.bmp")
    Pic.SetTransparentColour (QShipRight (0), black)
    QShipLeft (0) := Pic.FileNew ("qs_arrow_left.bmp")
    Pic.SetTransparentColour (QShipLeft (0), black)
    QShipDamaged (0) := Pic.FileNew ("qs_arrow_damaged.bmp")
    Pic.SetTransparentColour (QShipDamaged (0), black)

    %Deuterian Ships declarations and transparencies
    DShip (0) := Pic.FileNew ("ds_protector.bmp")
    Pic.SetTransparentColour (DShip (0), black)
    DShipForward (0) := Pic.FileNew ("ds_protector_forward.bmp")
    Pic.SetTransparentColour (DShipForward (0), black)
    DShipRight (0) := Pic.FileNew ("ds_protector_right.bmp")
    Pic.SetTransparentColour (DShipRight (0), black)
    DShipLeft (0) := Pic.FileNew ("ds_protector_left.bmp")
    Pic.SetTransparentColour (DShipLeft (0), black)
    DShipDamaged (0) := Pic.FileNew ("ds_protector_damaged.bmp")
    Pic.SetTransparentColour (DShipDamaged (0), black)

    %Explosion declaration and transparency
    pExplosion := Pic.FileNew ("explosion.bmp")
    Pic.SetTransparentColour (pExplosion, black)
    pExplosion := Pic.Rotate (pExplosion, 10, 27, 27)

    %Creation of 36 rotated images at 10 degree increments for each of 5 modes for both types of ships
    for i : 0 .. 35
	QShip (i) := Pic.Rotate (QShip (0), i * 10, 27, 27)
	QShipForward (i) := Pic.Rotate (QShipForward (0), i * 10, 27, 27)
	QShipRight (i) := Pic.Rotate (QShipRight (0), i * 10, 27, 27)
	QShipLeft (i) := Pic.Rotate (QShipLeft (0), i * 10, 27, 27)
	QShipDamaged (i) := Pic.Rotate (QShipDamaged (0), i * 10, 27, 27)


	DShip (i) := Pic.Rotate (DShip (0), i * 10, 27, 27)
	DShipForward (i) := Pic.Rotate (DShipForward (0), i * 10, 27, 27)
	DShipRight (i) := Pic.Rotate (DShipRight (0), i * 10, 27, 27)
	DShipLeft (i) := Pic.Rotate (DShipLeft (0), i * 10, 27, 27)
	DShipDamaged (i) := Pic.Rotate (DShipDamaged (0), i * 10, 27, 27)

    end for

    %Initialises type of ship, both speed controls, and the angle of the ship
    sType := "none"
    rX1 := 0
    rY1 := 0
    iAngle := 0
    iDisableCount := 0

    %Calculates a horizontal and vertical distance while playing a sound
    procedure Accelerate
	rX1 -= sind (iAngle * 10) * rSetSpeed
	rY1 += cosd (iAngle * 10) * rSetSpeed
	sType := "forward"
    end Accelerate

    %Sets the X-coordinate of the ship
    procedure SetX (ipX : int)
	rX := ipX
    end SetX

    %Sets the Y-coordinate of the ship
    procedure SetY (ipY : int)
	rY := ipY
    end SetY

    %Sets the angle of the ship
    procedure SetAngle (ipAngle : int)
	iAngle := ipAngle div 10
    end SetAngle

    %Sets the speed multiplier of the ship
    procedure SetSpeed (rpSpeed : real)
	rSetSpeed := rpSpeed
    end SetSpeed

    %Sets the disable time of the ship
    procedure Disable (iTime : int)
	iDisableCount := iTime
    end Disable

    %Sets the disable time of the ship to 0
    procedure Enable
	iDisableCount := 0
    end Enable

    %Rotates the ship counterclockwise and displays a left rotate image
    procedure LeftRotate
	iAngle := (iAngle + 1) mod 36
	sType := "left"
    end LeftRotate

    %Rotates the ship clockwise and displays a right rotate image
    procedure RightRotate
	iAngle := (iAngle - 1) mod 36
	sType := "right"
    end RightRotate

    %Set the appearance of the ship
    procedure SetPlanet (spPlanet : string)
	sPlanet := spPlanet
    end SetPlanet

    %Resets mode of ship drawn
    procedure Drift
	sType := "none"
	if iDisableCount > 0 then
	    iDisableCount -= 1
	end if
    end Drift

    %Stops the ship from moving
    procedure RemoveInertia
	rX1 := 0
	rY1 := 0
    end RemoveInertia

    %Moves ship and keeps the ship within the speed limit
    procedure Move

	rX += round (rX1)
	rY += round (rY1)

	if rX1 < -cSpeedLimit then
	    rX1 := -cSpeedLimit
	end if

	if rY1 < -cSpeedLimit then
	    rY1 := -cSpeedLimit
	end if

	if rX1 > cSpeedLimit then
	    rX1 := cSpeedLimit
	end if

	if rY1 > cSpeedLimit then
	    rY1 := cSpeedLimit
	end if

	if rX > maxx then
	    rX := 0
	end if

	if rX < 0 then
	    rX := maxx
	end if

	if rY > maxy then
	    rY := 60
	end if

	if rY < 60 then
	    rY := maxy
	end if

    end Move

    %Draws the ship based on planet
    procedure Show

	if sPlanet = "Quintos" then
	    if sType = "right" then
		Pic.Draw (QShipRight (iAngle),
		    round (rX) - 27,
		    round (rY) - 27, picMerge)

	    elsif sType = "left" then
		Pic.Draw (QShipLeft (iAngle),
		    round (rX) - 27,
		    round (rY) - 27, picMerge)

	    elsif sType = "forward" then
		Pic.Draw (QShipForward (iAngle),
		    round (rX) - 27,
		    round (rY) - 27, picMerge)

	    elsif sType = "hit" then
		Pic.Draw (QShipDamaged (iAngle),
		    round (rX) - 27,
		    round (rY) - 27, picMerge)

	    else
		Pic.Draw (QShip (iAngle),
		    round (rX) - 27,
		    round (rY) - 27, picMerge)
	    end if

	elsif sPlanet = "Deuteria" then
	    if sType = "right" then
		Pic.Draw (DShipRight (iAngle),
		    round (rX) - 27,
		    round (rY) - 27, picMerge)

	    elsif sType = "left" then
		Pic.Draw (DShipLeft (iAngle),
		    round (rX) - 27,
		    round (rY) - 27, picMerge)

	    elsif sType = "forward" then
		Pic.Draw (DShipForward (iAngle),
		    round (rX) - 27,
		    round (rY) - 27, picMerge)

	    elsif sType = "hit" then
		Pic.Draw (DShipDamaged (iAngle),
		    round (rX) - 27,
		    round (rY) - 27, picMerge)

	    else
		Pic.Draw (DShip (iAngle),
		    round (rX) - 27,
		    round (rY) - 27, picMerge)
	    end if
	end if
    end Show

    %Stops the ship and places it offscreen
    procedure Banish
	rX := maxx + 700
	rY := maxy + 700
	rX1 := 0
	rY1 := 0
    end Banish

    %Draws the explosion image
    procedure Explode
	Pic.Draw (pExplosion,
	    round (rX) - 53,
	    round (rY) - 53, picMerge)
	fork PlaySound (ExplosionSound)
    end Explode

    %Sets total armour
    procedure SetArmourTotal (ipArmour : int)
	iArmourTotal := ipArmour
    end SetArmourTotal

    %Sets the armour
    procedure SetArmour (ipArmour : int)
	iArmour := ipArmour
    end SetArmour

    %Removes armour
    procedure DropArmour (ipDrop : int)
	iArmour -= ipDrop
	sType := "hit"
    end DropArmour

    %Adds armour
    procedure AddArmour (ipAdd : int)
	iArmour += ipAdd
    end AddArmour

    %Sets capacity of selected capacitor from an array
    procedure SetCapacitorTotal (apArray : int, rpCapacity : real)
	aCapacitorTotal (apArray) := rpCapacity
    end SetCapacitorTotal

    %Sets amount of energy in the selected capacitor from an array
    procedure SetCapacitor (apArray : int, rpAmount : real)
	aCapacitor (apArray) := rpAmount

	if aCapacitor (apArray) > aCapacitorTotal (apArray) then
	    aCapacitor (apArray) := aCapacitorTotal (apArray)
	end if
    end SetCapacitor

    %Reduces selected capacitor's amount to 0
    procedure DrainCapacitor (pArray : int)
	aCapacitor (pArray) := 0
    end DrainCapacitor

    %Adds energy to selected capacitor
    procedure ChargeCapacitor (pArray : int, pAmount : real)
	aCapacitor (pArray) += pAmount
	if aCapacitor (pArray) > aCapacitorTotal (pArray) then
	    aCapacitor (pArray) := aCapacitorTotal (pArray)
	end if
    end ChargeCapacitor

    %Checks if the ship is disabled or not
    function GetAbility : boolean
	if iDisableCount <= 0 then
	    result true
	else
	    result false
	end if
    end GetAbility

    %Checks how much armour the ship has
    function GetArmour : int
	result iArmour
    end GetArmour

    %Checks the percentage of armour out of the total armour
    function GetArmourPercentage : int
	result round (iArmour / iArmourTotal * 100)
    end GetArmourPercentage

    %Checks the percentage of energy out of the total energy of a selected capacitor
    function GetCapacitorPercentage (apArray : int) : int
	result round ((aCapacitor (apArray) / aCapacitorTotal (apArray)) * 100)
    end GetCapacitorPercentage

    %Checks Y coordinate of the ship
    function GetY : int
	result round (rY)
    end GetY

    %Checks X coordinate of the ship
    function GetX : int
	result round (rX)
    end GetX

    %Checks the angle of the ship
    function GetAngle : int
	result round (iAngle * 10)
    end GetAngle

    %Checks if given coordinates are within the hitbox of the ship
    function IsTouching (ipX, ipY : int) : boolean
	if
		ipX > rX - 32 and
		ipX < rX + 32 and
		ipY > rY - 32 and
		ipY < rY + 32 then
	    result true
	else
	    result false
	end if
    end IsTouching

end Ship


type ShipClass : pointer to Ship

%Initialises variables
procedure ConstructShip (var opS : ShipClass)
    new Ship, opS
    opS -> SetX (960)
    opS -> SetY (540)
    opS -> SetSpeed (10)
    opS -> SetPlanet ("Deuteria")
    opS -> SetArmourTotal (200)
    opS -> SetArmour (200)
    opS -> SetAngle (0)
    for i : 1 .. 6
	opS -> SetCapacitorTotal (i, 100)
	opS -> SetCapacitor (i, 0)
    end for
end ConstructShip

%Banishes ship and frees all variables
procedure DestructShip (var opS : ShipClass)
    opS -> Banish
    free opS
end DestructShip
