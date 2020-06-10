/*+------------------------------------------------------------------------+
 |  Filename: Star Duel.t                                                  |
 |  Program Description: A ship-to-ship combat game with starfighters      |
 +-------------------------------------------------------------------------+
 | Author - Arjun Bhatia                                                   |
 | Date   - June 4 2018                                                    |
 +-------------------------------------------------------------------------+
 | Input  - various key inputs and button presses                          |
 | Output - sounds, music, moving graphics (i.e. ships, laser, torpedos,   |
 | EMPs, shields, etc.), text                                              |
 +-------------------------------------------------------------------------+*/
%Note on variable names
%Q variables represent Quintos
%D variables represent Deuteria

%Sets the run window to maximum size, removes the button bar, and centres it
setscreen ("graphics:max,max,nobuttonbar,position:center;center")
View.Set ("offscreenonly")

%Includes all of the required classes
include "ship.t"
include "laser.t"
include "torpedo.t"
include "emp.t"
include "shield.t"
include "debris.t"
include "graphic.t"

%Declares integer variables
var iCounter, iDebrisCounter, iDebrisDifficulty : int
var iLineX, iLineY : int
var iDInterfaceLights : int := 40
var iQInterfaceLights : int := 76

%Declares constants
const cDisableTime : int := 750
const cLasers : int := 15
const cPlanetRadius : int := 100
const cDebris : int := 10
const cPauseMenuWidth : int := 1500
const cPauseMenuHeight : int := 1000

%Declares boolean variables
var bFinishedBackground : boolean
var bFinishedMenu : boolean
var bMainMenuReturn : boolean
var bTrainingToggle : boolean
var bSkipScenes : boolean := false
var bGameExit : boolean := false

%Declares arrays
var iStarX, iStarY, iStarRadius : array 0 .. 50 of int

%Declares cutscene images and dimensions
var CutsceneImage : array 1 .. 31 of int
var ScaledCutsceneImage : array 1 .. 31 of int

%Declares images of faction logos and planet images
var QuintosLogo, DeuteriaLogo, QuintosPlanet, MinortaPlanet, QaetirusPlanet, MinortaBackground, DeuteriaBackground, QuintosBackground : int

%Declares images for the pause and control menus
var PauseMenu, TrainingBriefing, BattleBriefing : int

%Declares the fonts
var AnnouncementFont := Font.New ("niagara solid:90: italic")
var TitleFont := Font.New ("niagara solid:80:bold, italic")
var SubtitleFont := Font.New ("niagara solid:60: italic")
var ButtonFont := Font.New ("niagara solid:36")
var InterfaceFont := Font.New ("castellar:26:bold, italic")

%Declares different strings of text
var AnnouncementTextD := "PLAYER TWO OF DEUTERIA WINS"
var AnnouncementTextQ := "PLAYER ONE OF QUINTOS WINS"
var AnnouncementTextTie := "DRAW"
var TitleText := "STAR DUEL"
var SubtitleText := "PICK A BATTLE"
var ButtonTextRight := "CAMPAIGN"
var ButtonTextLeft := "TRAINING"
var ButtonTextBottomRight := 'QUIT GAME'
var ButtonTextBottomLeft := 'CONTROLS'
var ButtonTextBattle1 := "MINORTA"
var ButtonTextBattle2 := "QAETIRUS"
var ButtonTextBattle3 := "QUINTOS"
var InterfaceTextQ := "PLAYER ONE"
var InterfaceTextD := "PLAYER TWO"
var PausedTextLarge := "PAUSED"
var PausedTextSmall := "PRESS ANY KEY TO CONTINUE"
var DifficultyTextEasy := "BEGINNER"
var DifficultyTextMedium := "NOVICE"
var DifficultyTextHard := "ACE"
var ResumeText := 'RESUME'
var ReturnMenuText := 'MAIN MENU'
var PressAnyKeyText := 'PRESS ANY KEY TO RETURN TO THE MAIN MENU'
var TrainingSwitchTextQ := 'PRESS G TO SWITCH SHIPS'
var TrainingSwitchTextD := 'PRESS H TO SWITCH SHIPS'

%Declares the widths of the text strings
var AnnouncementWidthTie := Font.Width (AnnouncementTextTie, AnnouncementFont)
var AnnouncementWidthD := Font.Width (AnnouncementTextD, AnnouncementFont)
var AnnouncementWidthQ := Font.Width (AnnouncementTextQ, AnnouncementFont)
var SubtitleWidth := Font.Width (SubtitleText, SubtitleFont)
var TitleWidth := Font.Width (TitleText, TitleFont)
var ButtonWidthRight := Font.Width (ButtonTextRight, ButtonFont)
var ButtonWidthLeft := Font.Width (ButtonTextLeft, ButtonFont)
var ButtonWidthBottomRight := Font.Width (ButtonTextBottomRight, ButtonFont)
var ButtonWidthBottomLeft := Font.Width (ButtonTextBottomLeft, ButtonFont)
var ButtonWidthBattle1 := Font.Width (ButtonTextBattle1, ButtonFont)
var ButtonWidthBattle2 := Font.Width (ButtonTextBattle2, ButtonFont)
var ButtonWidthBattle3 := Font.Width (ButtonTextBattle3, ButtonFont)
var PausedWidthLarge := Font.Width (PausedTextLarge, TitleFont)
var PausedWidthSmall := Font.Width (PausedTextSmall, ButtonFont)
var DifficultyWidthEasy := Font.Width (DifficultyTextEasy, ButtonFont)
var DifficultyWidthMedium := Font.Width (DifficultyTextMedium, ButtonFont)
var DifficultyWidthHard := Font.Width (DifficultyTextHard, ButtonFont)
var ResumeWidth := Font.Width (ResumeText, ButtonFont)
var ReturnMenuWidth := Font.Width (ReturnMenuText, ButtonFont)
var PressAnyKeyWidth := Font.Width (PressAnyKeyText, ButtonFont)
var TrainingSwitchWidthQ := Font.Width (TrainingSwitchTextQ, ButtonFont)
var TrainingSwitchWidthD := Font.Width (TrainingSwitchTextD, ButtonFont)

%Declares the sounds and music
const VictorySound : string := "Victory.wav"
const DrawSound : string := "Draw.wav"
const MenuMusic : string := "AmbientMusic.wav"
const BackgroundMusic : string := "background.wav"
const ButtonSound : string := "buttonsound.mp3"
const TrainingMusic : string := 'TrainingMusic.wav'
const OpeningMusic : string := 'Lift Motif.wav'
const CutsceneMusic : string := 'Cutscene.wav'

%Declares the process to play a sound
process PlaySound (file : string)
    Music.PlayFile (file)
end PlaySound

%Declares the process to play background music
process PlayBackgroundMusic (file : string)
    loop
	Music.PlayFile (file)
	exit when bFinishedBackground
    end loop
end PlayBackgroundMusic

process PlayMenuMusic (file : string)
    loop
	Music.PlayFile (file)
	exit when bFinishedMenu
    end loop
end PlayMenuMusic

%Declares the keys
var keys : array char of boolean

%Declares constants for keys
const UP_ARROW : char := chr (200)
const LEFT_ARROW : char := chr (203)
const RIGHT_ARROW : char := chr (205)
const SHIFT : char := chr (180)
const SPACE : char := chr (32)

%Declares variable counting the amount of lasers fired
var iQLaserCount, iDLaserCount, iTLaserCount : int := 1

%Declares variable counting the amount of debris created
var iDebrisCount : int := 1
iDebrisCounter := 1

%An array of laser objects
var oQLaser, oDLaser, oTLaser : array 1 .. cLasers of LaserClass

%Declares ship objects
var oQShip, oDShip : ShipClass

%Declares torpedo objects
var oQTorpedo, oDTorpedo : TorpedoClass

%Declares EMP objects
var oQEMP, oDEMP : EMPClass

%Declares shield objects
var oQShield, oDShield : ShieldClass

%An array of debris objects
var oDebris : array 1 .. cDebris of DebrisClass

%An array for position and radius of the stars
var iStarX2, iStarY2, iStarRadius2 : array 0 .. 50 of int

var iPlayers, iDifficulty : int := 0

%Decides the positions and radii of the stars
for i : 1 .. 50
    iStarX2 (i) := Rand.Int (0, maxx)
    iStarY2 (i) := Rand.Int (0, maxy)
    iStarRadius2 (i) := Rand.Int (1, 2)
end for

%Declares variables for the state of the mouse
var mx, my, mb : int

%Declares constants for locations of main menu buttons
const iAX1 : int := 350
const iAY1 : int := 300
const iAX2 : int := 600
const iAY2 : int := 400

%Declares constants for locations of battle menu buttons
const iBX1 : int := 200
const iBY1 : int := 300
const iBX2 : int := 450
const iBY2 : int := 400

%Creates Quintos logo and makes it transparent
QuintosLogo := Pic.FileNew ("QuintosLogo.bmp")
Pic.SetTransparentColour (QuintosLogo, black)
QuintosLogo := Pic.Rotate (QuintosLogo, 0, 0, 0)

%Creates Deuteria logo and makes it transparent
DeuteriaLogo := Pic.FileNew ("DeuteriaLogo.bmp")
Pic.SetTransparentColour (DeuteriaLogo, black)
DeuteriaLogo := Pic.Rotate (DeuteriaLogo, 0, 0, 0)

%Creates image of Quintos
QuintosPlanet := Pic.FileNew ("QuintosSphere.bmp")
Pic.SetTransparentColour (QuintosPlanet, black)
QuintosPlanet := Pic.Rotate (QuintosPlanet, 0, 0, 0)

%Creates image of Minorta
MinortaPlanet := Pic.FileNew ("MinortaSphere.bmp")
Pic.SetTransparentColour (MinortaPlanet, black)
MinortaPlanet := Pic.Rotate (MinortaPlanet, 0, 0, 0)

%Creates image of Qaetirus
QaetirusPlanet := Pic.FileNew ("QaetirusSphere.bmp")
Pic.SetTransparentColour (QaetirusPlanet, black)
QaetirusPlanet := Pic.Rotate (QaetirusPlanet, 0, 0, 0)

%Creates background image of Minorta
MinortaBackground := Pic.FileNew ("BackgroundMinorta.bmp")
Pic.SetTransparentColour (MinortaBackground, black)
MinortaBackground := Pic.Rotate (MinortaBackground, 0, 0, 0)

%Creates background image of Deuteria
DeuteriaBackground := Pic.FileNew ("BackgroundDeuteria.bmp")
Pic.SetTransparentColour (DeuteriaBackground, black)
DeuteriaBackground := Pic.Rotate (DeuteriaBackground, 0, 0, 0)

%Creates background image of Quintos
QuintosBackground := Pic.FileNew ("BackgroundQuintos.bmp")
Pic.SetTransparentColour (QuintosBackground, black)
QuintosBackground := Pic.Rotate (QuintosBackground, 0, 0, 0)

%Creates image of pause menu
PauseMenu := Pic.FileNew ('PauseScreen.jpg')
PauseMenu := Pic.Scale (PauseMenu, round (maxy * 1.5), maxy)
var iPauseMenuWidth : int := Pic.Width (PauseMenu)
var iPauseMenuHeight : int := Pic.Height (PauseMenu)

%Creates image of training briefing screen
TrainingBriefing := Pic.FileNew ('TrainingScreen.jpg')
TrainingBriefing := Pic.Scale (TrainingBriefing, round (maxy * 1.5), maxy)
var iTrainingBriefingWidth : int := Pic.Width (TrainingBriefing)
var iTrainingBriefingHeight : int := Pic.Height (TrainingBriefing)

%Creates image of training battle briefing screen
BattleBriefing := Pic.FileNew ('BattleBriefing.jpg')
BattleBriefing := Pic.Scale (BattleBriefing, round (maxy * 1.5), maxy)
var iBattleBriefingWidth : int := Pic.Width (BattleBriefing)
var iBattleBriefingHeight : int := Pic.Height (BattleBriefing)


%Creates cutscene images
CutsceneImage (1) := Pic.FileNew ('OpeningScene1.jpg')
CutsceneImage (2) := Pic.FileNew ('OpeningScene2.jpg')
CutsceneImage (3) := Pic.FileNew ('OpeningScene3.jpg')
CutsceneImage (4) := Pic.FileNew ('OpeningScene4.jpg')
CutsceneImage (5) := Pic.FileNew ('OpeningScene5.jpg')
CutsceneImage (6) := Pic.FileNew ('OpeningScene6.jpg')
CutsceneImage (7) := Pic.FileNew ('OpeningScene7.jpg')
CutsceneImage (8) := Pic.FileNew ('OpeningScene8.jpg')
CutsceneImage (9) := Pic.FileNew ('OpeningScene9.jpg')
CutsceneImage (10) := Pic.FileNew ('OpeningScene10.jpg')
CutsceneImage (11) := Pic.FileNew ('OpeningScene11.jpg')
CutsceneImage (12) := Pic.FileNew ('OpeningScene12.jpg')
CutsceneImage (13) := Pic.FileNew ('OpeningScene13.jpg')
CutsceneImage (14) := Pic.FileNew ('OpeningScene14.jpg')
CutsceneImage (15) := Pic.FileNew ('OpeningScene15.jpg')
CutsceneImage (16) := Pic.FileNew ('OpeningScene16.jpg')
CutsceneImage (17) := Pic.FileNew ('OpeningScene17.jpg')
CutsceneImage (18) := Pic.FileNew ('OpeningScene18.jpg')
CutsceneImage (19) := Pic.FileNew ('OpeningScene19.jpg')
CutsceneImage (20) := Pic.FileNew ('OpeningScene20.jpg')
CutsceneImage (21) := Pic.FileNew ('OpeningScene21.jpg')
CutsceneImage (22) := Pic.FileNew ('OpeningScene22.jpg')
CutsceneImage (23) := Pic.FileNew ('OpeningScene23.jpg')
CutsceneImage (24) := Pic.FileNew ('OpeningScene24.jpg')
CutsceneImage (25) := Pic.FileNew ('OpeningScene25.jpg')
CutsceneImage (26) := Pic.FileNew ('OpeningScene26.jpg')
CutsceneImage (27) := Pic.FileNew ('OpeningScene27.jpg')
CutsceneImage (28) := Pic.FileNew ('OpeningScene28.jpg')
CutsceneImage (29) := Pic.FileNew ('OpeningScene29.jpg')
CutsceneImage (30) := Pic.FileNew ('OpeningScene30.jpg')
CutsceneImage (31) := Pic.FileNew ('OpeningScene31.jpg')

%Scales all of the cutscene images
for i : 1 .. 31
    ScaledCutsceneImage (i) := Pic.Scale (CutsceneImage (i), round (maxy * 1.5), maxy)
    Pic.Free (CutsceneImage (i))
end for
var iCutsceneImageWidth : int := Pic.Width (ScaledCutsceneImage (1))

%Creates positions for all of the stars
for i : 1 .. 50
    iStarX (i) := Rand.Int (0, maxx)
    iStarY (i) := Rand.Int (0, maxy)
    iStarRadius (i) := Rand.Int (1, 2)
end for

%Start of all of the procedures

%Goes through the cutscene sequence
procedure DrawCutscenes
    fork PlaySound (OpeningMusic)

    for i : 1 .. 31
	cls

	Text.Colour (white)
	put "Press any key"
	put "to skip"



	Pic.Draw (ScaledCutsceneImage (i), maxx div 2 - iCutsceneImageWidth div 2, 0, picCopy)
	for c : 1 .. 1000

	    %Checks for a key press to skip
	    if hasch then
		bSkipScenes := true
		exit
	    end if

	    if i = 6 and c = 1 then
		View.Update
		fork PlaySound (CutsceneMusic)
	    end if

	    delay (8)
	    View.Update
	end for
	Input.Flush
	delay (100)

	%Exits when the user presses a key
	exit when bSkipScenes = true
	View.Update
    end for

    Music.SoundOff
    for i : 1 .. 31
	Pic.Free (ScaledCutsceneImage (i))
    end for

end DrawCutscenes

%Constructs all of the objects
procedure ConstructAll

    %Creates many laser objects
    for i : 1 .. cLasers
	ConstructLaser (oQLaser (i))
	ConstructLaser (oDLaser (i))
	oQLaser (i) -> SetColour ("blue")
	oDLaser (i) -> SetColour ("red")
    end for

    %Creates many debris objects
    for i : 1 .. cDebris
	ConstructDebris (oDebris (i))
    end for

    %Creates EMP objects
    ConstructEMP (oQEMP)
    ConstructEMP (oDEMP)
    oQEMP -> SetColour ("blue")
    oDEMP -> SetColour ("red")

    ConstructShield (oQShield)
    ConstructShield (oDShield)
    oQShield -> SetColour ("blue")
    oDShield -> SetColour ("red")

    %Create torpedo objects
    ConstructTorpedo (oQTorpedo)
    ConstructTorpedo (oDTorpedo)
    oQTorpedo -> SetColour ("blue")
    oDTorpedo -> SetColour ("red")

    %Constructs Quintitian ship
    ConstructShip (oQShip)
    oQShip -> SetPlanet ("Quintos")
    oQShip -> SetSpeed (1)
    oQShip -> SetX (maxx div 3)
    oQShip -> SetY (Rand.Int (80, maxy - 80))

    %Constructs Deuterian ship
    ConstructShip (oDShip)
    oDShip -> SetPlanet ("Deuteria")
    oDShip -> SetSpeed (1)
    oDShip -> SetX ((maxx div 3) * 2)
    oDShip -> SetY (Rand.Int (80, maxy - 80))
end ConstructAll

%Resets parametres of the ship
procedure ReconstructAll (oShip : ShipClass)

    %Banishes all debris
    for i : 1 .. cDebris
	oDebris (i) -> Banish
    end for

    %Places both ships at 1/3 increments along the x
    oDShip -> SetX ((maxx div 3) * 2)
    oQShip -> SetX (maxx div 3)

    %Places ships at random y coordinates
    oShip -> SetY (Rand.Int (80, maxy - 80))
    oShip -> SetArmour (200)

    oShip -> SetAngle (Rand.Int (1, 360))
    oShip -> Enable
    oShip -> RemoveInertia

    oQShield -> Collapse
    oDShield -> Collapse
end ReconstructAll


%Draws the background for single player mode
procedure SetupTraining
    cls
    iLineX := 0
    iLineY := 0

    %Draws vertical lines across the screen
    for i : 1 .. maxx div 15 + 1
	Draw.Line (iLineX, 0, iLineX, maxy, 24)
	iLineX += 15
    end for

    %Draws horizonatal lines across the screen
    for i : 1 .. maxy div 15 + 1
	Draw.Line (0, iLineY, maxx, iLineY, 24)
	iLineY += 15
    end for

    %Check for key presses
    Input.KeyDown (keys)
end SetupTraining

%Draws the background for two player mode
procedure SetupScreen
    cls

    %Draws the stars
    for i : 1 .. 50
	Draw.FillOval (iStarX (i), iStarY (i), iStarRadius (i), iStarRadius (i), 91)
    end for

    %Draws the background based on the difficulty
    if iDifficulty = 1 then
	Pic.Draw (MinortaBackground, 0, 0, picMerge)
    elsif iDifficulty = 2 then
	Pic.Draw (DeuteriaBackground, 0, 0, picMerge)
    else
	Pic.Draw (QuintosBackground, 0, 0, picMerge)
    end if

    %Check for key presses
    Input.KeyDown (keys)
end SetupScreen

%Sets the capacities of all of the capacitors
procedure InitialiseCapacitors

    %Laser capacitors
    oQShip -> SetCapacitorTotal (1, 100)
    oDShip -> SetCapacitorTotal (1, 100)

    %Torpedo capacitors
    oQShip -> SetCapacitorTotal (2, 100)
    oDShip -> SetCapacitorTotal (2, 100)

    %EMP capacitors
    oQShip -> SetCapacitorTotal (3, 500)
    oDShip -> SetCapacitorTotal (3, 500)

    %Shield capacitors
    oQShip -> SetCapacitorTotal (4, 800)
    oDShip -> SetCapacitorTotal (4, 800)
end InitialiseCapacitors

%Sets the capacities of all of the capacitors for training mode
procedure InitialiseTrainingCapacitors

    %Laser capacitors
    oQShip -> SetCapacitorTotal (1, 100)
    oDShip -> SetCapacitorTotal (1, 100)

    %Torpedo capacitors
    oQShip -> SetCapacitorTotal (2, 100)
    oDShip -> SetCapacitorTotal (2, 100)

    %EMP capacitors
    oQShip -> SetCapacitorTotal (3, 100)
    oDShip -> SetCapacitorTotal (3, 100)

    %Shield capacitors
    oQShip -> SetCapacitorTotal (4, 100)
    oDShip -> SetCapacitorTotal (4, 100)
end InitialiseTrainingCapacitors

%Charges Quintitian capacitors
procedure ChargeQCapacitors
    oQShip -> ChargeCapacitor (1, 15)
    oQShip -> ChargeCapacitor (2, 1)
    oQShip -> ChargeCapacitor (3, 1)
    oQShip -> ChargeCapacitor (4, 1)
end ChargeQCapacitors

%Charges Deuterian capacitors
procedure ChargeDCapacitors
    oDShip -> ChargeCapacitor (1, 15)
    oDShip -> ChargeCapacitor (2, 1)
    oDShip -> ChargeCapacitor (3, 1)
    oDShip -> ChargeCapacitor (4, 1)
end ChargeDCapacitors

%Creates a piece of debris
procedure CreateDebris (iSpawnInterval : int)

    if iDebrisCounter = iSpawnInterval then
	oDebris (iDebrisCount) -> SetX (Rand.Int (100, maxx - 100))

	if Rand.Int (1, 2) = 1 then

	    oDebris (iDebrisCount) -> SetY (maxy + 30)
	    oDebris (iDebrisCount) -> Accelerate (-5)
	else
	    oDebris (iDebrisCount) -> SetY (-20)
	    oDebris (iDebrisCount) -> Accelerate (5)
	end if

	%Adds one to the amount of debris
	iDebrisCount += 1

	%Resets the counter for new debris
	iDebrisCounter := 0

    end if

    %Adds to the time before the next debris creation
    iDebrisCounter += 1

    %Resets the debris count to 1 when it is about to exceed the amount of debris objects
    if iDebrisCount >= cDebris - 1 then
	iDebrisCount := 1
    end if

    %Moves debris when they are on the screen
    for i : 1 .. cDebris
	if oDebris (i) -> GetY > -30 and oDebris (i) -> GetY < maxy + 80 then
	    oDebris (i) -> Move
	    oDebris (i) -> Show
	end if
    end for

end CreateDebris


%Declares the procedure to draw a ship and to respond to key presses
procedure DrawShip (Alliance : string, oShip : ShipClass, iLaserCount : int,
	oLaser : array 1 .. cLasers of LaserClass, oTorpedo : TorpedoClass, oEMP : EMPClass, oShield : ShieldClass,
	Forward : char, Left : char, Right : char, Laser : char, Torpedo : char, EMP : char, Shield : char)

    %Basic functions
    oShip -> Show
    oShip -> Drift
    oShip -> Move

    %Checks to see if the ship is disabled
    if oShip -> GetAbility then

	%Moves the ship based on the key presses
	if keys (Right) then
	    oShip -> RightRotate
	end if
	if keys (Left) then
	    oShip -> LeftRotate
	end if
	if keys (Forward) then
	    oShip -> Accelerate
	end if

	%If the difficulty is hard, the EMP can be used
	if iDifficulty > 2 then

	    %Fires the EMP if the key is pressed and the capacitor is charged
	    if oShip -> GetCapacitorPercentage (3) = 100 then
		if keys (EMP) then
		    oShip -> DrainCapacitor (3)
		    oEMP -> SetX (oShip -> GetX)
		    oEMP -> SetY (oShip -> GetY)
		    oEMP -> Show

		end if
	    end if

	end if

	%If the difficulty is medium, the shield can be used
	if iDifficulty > 1 then

	    %Projects the shield if the key is pressed and the capacitor is charged
	    if oShip -> GetCapacitorPercentage (4) = 100 then
		if keys (Shield) then
		    oShip -> DrainCapacitor (4)
		    oShield -> SetEnergy (500)
		end if
	    end if

	end if

	%If the difficulty is easy, lasers and torpedos a can be used
	if iDifficulty > 0 then

	    %Fires the laser if the key is pressed and the capacitor is charged
	    if oShip -> GetCapacitorPercentage (1) = 100 then
		if keys (Laser) then
		    if Alliance = 'Deuteria' then
			iDLaserCount += 1
		    elsif Alliance = 'Quintos' then
			iQLaserCount += 1
		    end if
		    oShip -> DrainCapacitor (1)
		    oLaser (iLaserCount) -> SetX (oShip -> GetX)
		    oLaser (iLaserCount) -> SetY (oShip -> GetY)
		    oLaser (iLaserCount) -> SetAngle (oShip -> GetAngle)
		    oLaser (iLaserCount) -> Accelerate
		end if
	    end if

	    %Fires the torpedo if the key is pressed and the capacitor is charged
	    if oShip -> GetCapacitorPercentage (2) = 100 then
		if keys (Torpedo) then
		    oShip -> DrainCapacitor (2)
		    oTorpedo -> SetX (oShip -> GetX)
		    oTorpedo -> SetY (oShip -> GetY)
		    oTorpedo -> SetAngle (oShip -> GetAngle)
		    oTorpedo -> Accelerate
		end if
	    end if

	end if


	%Makes the interface lights on if the ship is not disabled
	if Alliance = 'Quintos' then
	    iQInterfaceLights := 76
	    ChargeQCapacitors
	elsif Alliance = 'Deuteria' then
	    iDInterfaceLights := 40
	    ChargeDCapacitors
	end if
    else

	%If the ship is disabled, the interface lights are greyed out and 'DISABLED' is printed over the interface
	if Alliance = 'Quintos' then
	    iQInterfaceLights := 18
	    Draw.Text ("DISABLED", 65, 8, InterfaceFont, iDInterfaceLights)
	elsif Alliance = 'Deuteria' then
	    iDInterfaceLights := 18
	    Draw.Text ("DISABLED", maxx - 250, 8, InterfaceFont, iQInterfaceLights)
	end if
    end if

    %Projects a shield if it is active
    if oShield -> IsActive then
	oShield -> SetPosition (oShip -> GetX, oShip -> GetY)
	oShield -> Show
    end if

    %Drops the shield's energy by a small amount
    oShield -> DropEnergy
end DrawShip

%The pause button
procedure PauseCheck

    %Pauses the game if the space bar is pressed
    if keys (SPACE) then
	delay (200)
	Input.Flush

	loop

	    %Checks the state of the mouse
	    mousewhere (mx, my, mb)

	    %Draws the background of the pause menu
	    Pic.Draw (PauseMenu, maxx div 2 - iPauseMenuWidth div 2, maxy div 2 - iPauseMenuHeight div 2 + 40, picCopy)

	    %Checks if the return to main menu button on the top button is pressed
	    if mb = 1 and mx > maxx div 2 - (iAX2 - iAX1) div 2 and mx < maxx div 2 + (iAX2 - iAX1) div 2 and
		    my > maxy div 2 - iAY2 + 350 and my < maxy div 2 - iAY1 + 350 then

		%Draws a filled rectangle with a white border around it when the button is pressed
		drawfillbox (maxx div 2 - (iAX2 - iAX1) div 2, maxy div 2 - iAY2 + 350,
		    maxx div 2 + (iAX2 - iAX1) div 2, maxy div 2 - iAY1 + 350, white)
		Draw.Box (maxx div 2 - (iAX2 - iAX1) div 2 - 10, maxy div 2 - iAY2 + 340,
		    maxx div 2 + (iAX2 - iAX1) div 2 + 10, maxy div 2 - iAY1 + 360, white)

		%Plays a sound
		fork PlaySound (ButtonSound)
		View.Update
		bMainMenuReturn := true
		exit

	    else

		%Draws the normal button
		drawfillbox (maxx div 2 - (iAX2 - iAX1) div 2, maxy div 2 - iAY2 + 350,
		    maxx div 2 + (iAX2 - iAX1) div 2, maxy div 2 - iAY1 + 350, 25)
	    end if


	    %Checks if the resume button on the bottom is pressed
	    if mb = 1 and mx > maxx div 2 - (iAX2 - iAX1) div 2 and mx < maxx div 2 + (iAX2 - iAX1) div 2 and
		    my > maxy div 2 - iAY2 + 225 and my < maxy div 2 - iAY1 + 225 then

		%Draws a filled rectangle with a white border around it when the button is pressed
		drawfillbox (maxx div 2 - (iAX2 - iAX1) div 2, maxy div 2 - iAY2 + 225,
		    maxx div 2 + (iAX2 - iAX1) div 2, maxy div 2 - iAY1 + 225, white)
		Draw.Box (maxx div 2 - (iAX2 - iAX1) div 2 - 10, maxy div 2 - iAY2 + 225 - 10,
		    maxx div 2 + (iAX2 - iAX1) div 2 + 10, maxy div 2 - iAY1 + 235, white)

		%Plays a sound
		fork PlaySound (ButtonSound)
		View.Update
		exit

	    else

		%Draws the normal button
		drawfillbox (maxx div 2 - (iAX2 - iAX1) div 2, maxy div 2 - iAY2 + 225,
		    maxx div 2 + (iAX2 - iAX1) div 2, maxy div 2 - iAY1 + 225, 25)
	    end if

	    %Draws the text on the buttons
	    Font.Draw (ResumeText, maxx div 2 - ResumeWidth div 2,
		maxy div 2 - (iAY1 + iAY2) div 2 + 210, ButtonFont, white)
	    Font.Draw (ReturnMenuText, maxx div 2 - ReturnMenuWidth div 2,
		maxy div 2 - (iAY1 + iAY2) div 2 + 335, ButtonFont, white)


	    View.Update
	end loop
	delay (500)
	Input.Flush
    end if
end PauseCheck

%The pause menu for the main menu
procedure MenuPauseCheck

    %Pauses the game if the space bar is pressed

    delay (200)
    Input.Flush

    loop
	%Checks the state of the mouse
	mousewhere (mx, my, mb)

	%Draws the background of the pause menu
	Pic.Draw (PauseMenu, maxx div 2 - iPauseMenuWidth div 2, maxy div 2 - iPauseMenuHeight div 2 + 40, picCopy)

	%Draws a box over the 'paused' text
	Draw.FillBox (maxx div 2 - 100, maxy div 2 + 210, maxx div 2 + 100, maxy div 2 + 100, 255)

	%Checks if the return to main menu button on the top button is pressed
	if mb = 1 and mx > maxx div 2 - (iAX2 - iAX1) div 2 and mx < maxx div 2 + (iAX2 - iAX1) div 2 and
		my > maxy div 2 - iAY2 + 350 and my < maxy div 2 - iAY1 + 350 then

	    %Draws a filled rectangle with a white border around it when the button is pressed
	    drawfillbox (maxx div 2 - (iAX2 - iAX1) div 2, maxy div 2 - iAY2 + 350,
		maxx div 2 + (iAX2 - iAX1) div 2, maxy div 2 - iAY1 + 350, white)
	    Draw.Box (maxx div 2 - (iAX2 - iAX1) div 2 - 10, maxy div 2 - iAY2 + 340,
		maxx div 2 + (iAX2 - iAX1) div 2 + 10, maxy div 2 - iAY1 + 360, white)

	    %Plays a sound
	    fork PlaySound (ButtonSound)
	    View.Update
	    bMainMenuReturn := true
	    exit

	else

	    %Draws the normal button
	    drawfillbox (maxx div 2 - (iAX2 - iAX1) div 2, maxy div 2 - iAY2 + 350,
		maxx div 2 + (iAX2 - iAX1) div 2, maxy div 2 - iAY1 + 350, 25)
	end if

	%Draws the text on the button
	Font.Draw (ReturnMenuText, maxx div 2 - ReturnMenuWidth div 2,
	    maxy div 2 - (iAY1 + iAY2) div 2 + 335, ButtonFont, white)



	View.Update
    end loop
    delay (500)
    Input.Flush

end MenuPauseCheck


procedure CheckCollisions

    for i : 1 .. cLasers
	%Quintitian laser hits Deuterian ship and does damage if its shield is not active
	if oDShip -> IsTouching (oQLaser (i) -> GetX, oQLaser (i) -> GetY) then

	    %Checks if the shield is active
	    if oDShield -> IsActive then
		oDShield -> Hit
	    else
		oDShip -> DropArmour (15)
	    end if

	    %Removes the laser from the screen when it hits the ship
	    oQLaser (i) -> Banish
	end if
    end for

    %Quintitian torpedo hits Deuterian ship and does damage if its shield is not active
    if oDShip -> IsTouching (oQTorpedo -> GetX, oQTorpedo -> GetY) then

	%Checks if the shield is active
	if oDShield -> IsActive then
	    oDShield -> Hit
	    oDShip -> DropArmour (20)
	else
	    oDShip -> DropArmour (70)
	end if

	%Removes the laser from the screen when it hits the ship
	oQTorpedo -> Banish
    end if

    for i : 1 .. cLasers
	%Deuterian laser hits Quintitian ship
	if oQShip -> IsTouching (oDLaser (i) -> GetX, oDLaser (i) -> GetY) then
	    if oQShield -> IsActive then
		oQShield -> Hit
	    else
		oQShip -> DropArmour (15)
	    end if
	    oDLaser (i) -> Banish
	end if
    end for

    %Deuterian torpedo hits Quintitian ship
    if oQShip -> IsTouching (oDTorpedo -> GetX, oDTorpedo -> GetY) then
	if oQShield -> IsActive then
	    oQShield -> Hit
	    oQShip -> DropArmour (20)
	else
	    oQShip -> DropArmour (70)
	end if
	oDTorpedo -> Banish
    end if

    %Collision of the ships
    if oQShip -> IsTouching (oDShip -> GetX, oDShip -> GetY)
	    or oDShip -> IsTouching (oQShip -> GetX, oQShip -> GetY) then

	if not oDShield -> IsActive then
	    oDShip -> DropArmour (100)
	else
	    oDShield -> Hit
	end if

	if not oQShield -> IsActive then
	    oQShip -> DropArmour (100)
	else
	    oQShield -> Hit
	end if

    end if

    %Quintitian EMP hits Deuterian ship
    if oQEMP -> IsTouching (oDShip -> GetX, oDShip -> GetY) then

	if oDShield -> IsActive then
	    oDShield -> Collapse
	else
	    oDShip -> Disable (cDisableTime)
	    oQEMP -> Banish
	end if

    else
	oQEMP -> Banish
    end if

    %Deuterian EMP hits Quintitian ship
    if oDEMP -> IsTouching (oQShip -> GetX, oQShip -> GetY) then

	if oQShield -> IsActive then
	    oQShield -> Collapse
	else
	    oQShip -> Disable (cDisableTime)
	    oDEMP -> Banish
	end if
    else
	oDEMP -> Banish
    end if

    %Check if a Deuterian torpedo hits an asteroid
    for i : 1 .. cDebris
	if oDebris (i) -> IsTouching (oDTorpedo -> GetX,
		oDTorpedo -> GetY) then
	    oDebris (i) -> Banish
	    oDTorpedo -> Banish
	end if
    end for

    %Check if a Quintitian torpedo hits an asteroid
    for i : 1 .. cDebris
	if oDebris (i) -> IsTouching (oQTorpedo -> GetX,
		oQTorpedo -> GetY) then
	    oDebris (i) -> Banish

	    oQTorpedo -> Banish
	end if
    end for

    %Checks if the Deuterian ship collides with a piece of debris
    for i : 1 .. cDebris
	if oDebris (i) -> IsTouching (oDShip -> GetX,
		oDShip -> GetY) then

	    %Checks if the shield is active
	    if oDShield -> IsActive then
		oDShield -> Hit
		oDebris (i) -> Banish
	    else
		oDebris (i) -> Banish
		oDShip -> DropArmour (30)
	    end if
	end if
    end for

    %Checks if the Quintitian ship collides with a piece of debris
    for i : 1 .. cDebris
	if oDebris (i) -> IsTouching (oQShip -> GetX,
		oQShip -> GetY) then

	    %Checks if the shield is active
	    if oQShield -> IsActive then
		oQShield -> Hit
		oDebris (i) -> Banish

	    else
		oDebris (i) -> Banish
		oQShip -> DropArmour (30)
	    end if
	end if
    end for

    %Checks if any lasers hit a piece of debris
    for l : 1 .. cLasers

	%Deuterian lasers
	for d : 1 .. cDebris
	    if oDebris (d) -> IsTouching (oDLaser (l) -> GetX, oDLaser (l) -> GetY) then
		oDebris (d) -> Banish
		oDLaser (l) -> Banish
	    end if
	end for

	%Quintitian lasers
	for d : 1 .. cDebris
	    if oDebris (d) -> IsTouching (oQLaser (l) -> GetX, oQLaser (l) -> GetY) then
		oDebris (d) -> Banish
		oQLaser (l) -> Banish
	    end if
	end for

    end for


end CheckCollisions

%Draws the bottom bar with metres showing armour and weapon recharge
procedure DrawInterface

    %Draws the interface bar and logos
    Draw.FillBox (0, 0, maxx, 40, grey)
    Pic.Draw (QuintosLogo, 3, 2, picMerge)
    Pic.Draw (DeuteriaLogo, maxx - 43, 2, picMerge)

    if iDifficulty > 2 then

	%Quintos EMP
	Draw.FillArc (160, 25, 10, 10, 90,
	    round (oQShip -> GetCapacitorPercentage (3) / 100 * 360) + 90,
	    iQInterfaceLights)
	Draw.Oval (160, 0 + 25, 10, 10, 104)
	drawtriangle (159, 8, 163, 8, 159, 14, iQInterfaceLights)
	drawtriangle (159, 8, 163, 8, 163, 3, iQInterfaceLights)

	%Deuteria EMP
	Draw.FillArc (maxx - 160, 25, 10, 10, 90,
	    round (oDShip -> GetCapacitorPercentage (3) / 100 * 360) + 90,
	    iDInterfaceLights)
	Draw.Oval (maxx - 160, 0 + 25, 10, 10, 68)
	drawtriangle (maxx - 159, 8, maxx - 163, 8, maxx - 159, 14, iDInterfaceLights)
	drawtriangle (maxx - 159, 8, maxx - 163, 8, maxx - 163, 3, iDInterfaceLights)
    end if

    if iDifficulty > 1 then

	%Quintos Shield
	Draw.FillArc (130, 25, 10, 10, 90,
	    round (oQShip -> GetCapacitorPercentage (4) / 100 * 360) + 90,
	    iQInterfaceLights)
	Draw.Oval (130, 0 + 25, 10, 10, 104)
	drawquad (126, 10, 134, 10, 133, 2, 127, 2, iQInterfaceLights)
	Draw.FillOval (130, 10, 3, 1, iQInterfaceLights)

	%Deuteria Shield
	Draw.FillArc (maxx - 130, 25, 10, 10, 90,
	    round (oDShip -> GetCapacitorPercentage (4) / 100 * 360) + 90,
	    iDInterfaceLights)
	Draw.Oval (maxx - 130, 0 + 25, 10, 10, 68)
	drawquad (maxx - 126, 10, maxx - 134, 10, maxx - 133, 2, maxx - 127, 2, iDInterfaceLights)
	Draw.FillOval (maxx - 130, 10, 3, 1, iDInterfaceLights)
    end if

    if iDifficulty > 0 then

	%Quintos Laser
	Draw.FillArc (70, 25, 10, 10, 90,
	    round (oQShip -> GetCapacitorPercentage (1) / 100 * 360) + 90,
	    iQInterfaceLights)
	Draw.Oval (70, 25, 10, 10, 104)
	Draw.FillBox (71, 2, 69, 12, iQInterfaceLights)

	%Deuteria Laser
	Draw.FillArc (maxx - 70, 25, 10, 10, 90,
	    round (oDShip -> GetCapacitorPercentage (1) / 100 * 360) + 90,
	    iDInterfaceLights)
	Draw.Oval (maxx - 70, 25, 10, 10, 68)
	Draw.FillBox (maxx - 71, 2, maxx - 69, 12, iDInterfaceLights)

	%Quintos Torpedo
	Draw.FillArc (100, 25, 10, 10, 90,
	    round (oQShip -> GetCapacitorPercentage (2) / 100 * 360) + 90,
	    iQInterfaceLights)
	Draw.Oval (100, 0 + 25, 10, 10, 104)
	Draw.FillOval (100, 7, 4, 6, iQInterfaceLights)

	%Deuteria Torpedo
	Draw.FillArc (maxx - 100, 25, 10, 10, 90,
	    round (oDShip -> GetCapacitorPercentage (2) / 100 * 360) + 90,
	    iDInterfaceLights)
	Draw.Oval (maxx - 100, 25, 10, 10, 68)
	Draw.FillOval (maxx - 100, 7, 4, 6, iDInterfaceLights)

	%Quintos armour bar
	Draw.FillBox (200, 4, 200 + oQShip -> GetArmourPercentage, 36, iQInterfaceLights)
	Draw.Box (200, 4, 300, 36, 104)

	%Deuteria armour bar
	Draw.FillBox (maxx - 200, 4, maxx - 200 - oDShip -> GetArmourPercentage, 36, iDInterfaceLights)
	Draw.Box (maxx - 200, 4, maxx - 300, 36, 68)

    end if
end DrawInterface

%Removes all weapons from the screen
procedure AllBanish

    %Banishes lasers
    for i : 1 .. cLasers
	oQLaser (i) -> Banish
	oDLaser (i) -> Banish
    end for

    %Banishes torpedos
    oQTorpedo -> Banish
    oDTorpedo -> Banish

    %Banishes EMPs
    oQEMP -> Banish
    oDEMP -> Banish

end AllBanish

%Draws the main menu
procedure MainMenuDraw
    loop
	cls

	%Draws the stars
	for i : 1 .. 50
	    Draw.FillOval (iStarX2 (i), iStarY2 (i), iStarRadius2 (i), iStarRadius2 (i), 91)
	end for

	%Checks the state of the mouse
	mousewhere (mx, my, mb)

	%Draws the button on the top left side and checks if it is pressed
	if mb = 1 and mx > iAX1 and mx < iAX2 and my > iAY1 and my < iAY2 then
	    drawfillbox (iAX1, iAY1, iAX2, iAY2, white)
	    Draw.Box (iAX1 - 10, iAY1 - 10, iAX2 + 10, iAY2 + 10, white)
	    iPlayers := 1
	    iDifficulty := 3
	    iDebrisDifficulty := 50

	    %Plays a sound
	    fork PlaySound (ButtonSound)
	    View.Update
	    exit

	    %Draws a regular button if it is not pressed
	else
	    drawfillbox (iAX1, iAY1, iAX2, iAY2, 25)
	end if

	%Draws the button on the top right side and checks if it is pressed
	if mb = 1 and mx < maxx - iAX1 and mx > maxx - iAX2 and my > iAY1 and my < iAY2 then
	    drawfillbox (maxx - iAX1, iAY1, maxx - iAX2, iAY2, white)
	    Draw.Box (maxx - iAX1 + 10, iAY1 - 10, maxx - iAX2 - 10, iAY2 + 10, white)
	    iPlayers := 2

	    %Plays a sound
	    fork PlaySound (ButtonSound)
	    View.Update
	    exit

	    %Draws a regular button if it is not pressed
	else
	    drawfillbox (maxx - iAX1, iAY1, maxx - iAX2, iAY2, 25)
	end if

	%Draws the button on the bottom left side and checks if it is pressed
	if mb = 1 and mx > iAX1 and mx < iAX2 and my > iAY1 - 150 and my < iAY2 - 150 then
	    drawfillbox (iAX1, iAY1 - 150, iAX2, iAY2 - 150, white)
	    Draw.Box (iAX1 - 10, iAY1 - 160, iAX2 + 10, iAY2 - 140, white)
	    delay (100)

	    %Plays a sound
	    fork PlaySound (ButtonSound)

	    %Pauses the game
	    MenuPauseCheck
	    View.Update

	    %Draws a regular button if it is not pressed
	else
	    drawfillbox (iAX1, iAY1 - 150, iAX2, iAY2 - 150, 25)
	end if

	%Draws the button on the bottom right side and checks if it is pressed
	if mb = 1 and mx < maxx - iAX1 and mx > maxx - iAX2 and my > iAY1 - 150 and my < iAY2 - 150 then
	    drawfillbox (maxx - iAX1, iAY1 - 150, maxx - iAX2, iAY2 - 150, white)
	    Draw.Box (maxx - iAX1 + 10, iAY1 - 160, maxx - iAX2 - 10, iAY2 - 140, white)

	    %Plays a sound
	    fork PlaySound (ButtonSound)

	    %Closes the window
	    Window.Close (defWinID)
	    bGameExit := true
	    View.Update


	    %Draws a regular button if it is not pressed
	else
	    drawfillbox (maxx - iAX1, iAY1 - 150, maxx - iAX2, iAY2 - 150, 25)
	end if

	%Draws the text on the buttons
	Font.Draw (ButtonTextLeft, round ((iAX2 + iAX1) / 2 - ButtonWidthLeft / 2), (iAY1 + iAY2) div 2 - 15, ButtonFont, white)
	Font.Draw (ButtonTextRight, round ((maxx - iAX2 + maxx - iAX1) / 2 - ButtonWidthRight / 2), (iAY1 + iAY2) div 2 - 15, ButtonFont, white)
	Font.Draw (ButtonTextBottomRight, round ((maxx - iAX2 + maxx - iAX1) / 2 - ButtonWidthBottomRight / 2), (iAY1 + iAY2) div 2 - 165, ButtonFont, white)
	Font.Draw (ButtonTextBottomLeft, round ((iAX2 + iAX1) / 2 - ButtonWidthBottomLeft / 2), (iAY1 + iAY2) div 2 - 165, ButtonFont, white)

	%Draws the title of the game
	Font.Draw (TitleText, round (maxx / 2 - TitleWidth / 2), maxy div 4 * 3, TitleFont, white)

	delay (9)
	View.Update
    end loop
    delay (100)
end MainMenuDraw

%Makes sure array subscripts do not exceed limits and armour does not go into negatives
procedure DataValidation

    %Resets laser count before it exceeds array limit
    if iDLaserCount >= cLasers - 3 then
	iDLaserCount := 1
    end if
    if iQLaserCount >= cLasers - 3 then
	iQLaserCount := 1
    end if

    %Prevents armour from dropping below
    if oDShip -> GetArmour < 0 then
	oDShip -> SetArmour (0)
    end if
    if oQShip -> GetArmour < 0 then
	oQShip -> SetArmour (0)
    end if
end DataValidation

%Draws the menu to select a battle
procedure BattleMenuDraw
    loop
	cls

	%Draws the stars
	for i : 1 .. 50
	    Draw.FillOval (iStarX2 (i), iStarY2 (i), iStarRadius2 (i), iStarRadius2 (i), 91)
	end for

	%Checks the state of the mouse
	mousewhere (mx, my, mb)

	%Draws the button on the left side and checks if it is pressed (easy mode)
	if mb = 1 and
		mx > iBX1 and mx < iBX2 and
		my > iBY1 and my < iBY2 then
	    drawfillbox (iBX1, iBY1, iBX2, iBY2, white)
	    Draw.Box (iBX1 - 10, iBY1 - 10, iBX2 + 10, iBY2 + 10, white)
	    iDifficulty := 1
	    iDebrisDifficulty := 150

	    %Plays a sound
	    fork PlaySound (ButtonSound)
	    View.Update
	    exit

	    %Draws a regular button if it is not pressed
	else
	    drawfillbox (iBX1, iBY1, iBX2, iBY2, 25)
	end if

	%Draws the button in the centre and checks if it is pressed (medium mode)
	if mb = 1 and
		mx > round (maxx / 2 - (iBX2 - iBX1) / 2) and mx < round (maxx / 2 + (iBX2 - iBX1) / 2) and
		my > iBY1 and my < iBY2 then

	    drawfillbox (round (maxx / 2 - (iBX2 - iBX1) / 2), iBY1,
		round (maxx / 2 + (iBX2 - iBX1) / 2), iBY2, white)

	    Draw.Box (round (maxx / 2 - (iBX2 - iBX1) / 2) - 10, iBY1 - 10,
		round (maxx / 2 + (iBX2 - iBX1) / 2) + 10, iBY2 + 10, white)
	    iDifficulty := 2
	    iDebrisDifficulty := 100
	    fork PlaySound (ButtonSound)
	    View.Update
	    exit

	    %Draws a regular button if it is not pressed
	else
	    drawfillbox (round (maxx / 2 - (iBX2 - iBX1) / 2), iBY1,
		round (maxx / 2 + (iBX2 - iBX1) / 2), iBY2, 25)
	end if

	%Draws the button on the right side and checks if it is pressed (hard mode)
	if mb = 1 and
		mx < maxx - iBX1 and mx > maxx - iBX2 and
		my > iBY1 and my < iBY2 then
	    drawfillbox (maxx - iBX1, iBY1, maxx - iBX2, iBY2, white)
	    Draw.Box (maxx - iBX1 + 10, iBY1 - 10, maxx - iBX2 - 10, iBY2 + 10, white)
	    iDifficulty := 3
	    iDebrisDifficulty := 50

	    %Plays a sound
	    fork PlaySound (ButtonSound)
	    View.Update
	    exit

	    %Draws a regular button if it is not pressed
	else
	    drawfillbox (maxx - iBX1, iBY1, maxx - iBX2, iBY2, 25)
	end if

	%Draws the title on this page
	Font.Draw (SubtitleText, round (maxx / 2 - SubtitleWidth / 2), maxy div 4 * 3, SubtitleFont, white)

	%Draws the text on the buttons
	Font.Draw (ButtonTextBattle1, round ((iBX2 + iBX1) / 2 - ButtonWidthBattle1 / 2), (iAY1 + iAY2) div 2 - 15, ButtonFont, white)
	Font.Draw (ButtonTextBattle2, round (maxx / 2 - ButtonWidthBattle2 / 2), (iAY1 + iAY2) div 2 - 15, ButtonFont, white)
	Font.Draw (ButtonTextBattle3, round ((maxx - iBX2 + maxx - iBX1) / 2 - ButtonWidthBattle3 / 2), (iAY1 + iAY2) div 2 - 15, ButtonFont, white)

	%Draws the text for the difficulty
	Font.Draw (DifficultyTextEasy, round ((iBX2 + iBX1) / 2 - DifficultyWidthEasy / 2), (iAY1 + iAY2) div 2 + 70, ButtonFont, 48)
	Font.Draw (DifficultyTextMedium, round (maxx / 2 - DifficultyWidthMedium / 2), (iAY1 + iAY2) div 2 + 70, ButtonFont, 44)
	Font.Draw (DifficultyTextHard, round ((maxx - iBX2 + maxx - iBX1) / 2 - DifficultyWidthHard / 2), (iAY1 + iAY2) div 2 + 70, ButtonFont, 40)

	%Draws the images of the planets
	Pic.Draw (QuintosPlanet, (maxx - iBX2 + maxx - iBX1) div 2 - cPlanetRadius, maxy div 2 - 250, picMerge)
	Pic.Draw (MinortaPlanet, (iBX2 + iBX1) div 2 - cPlanetRadius, maxy div 2 - 250, picMerge)
	Pic.Draw (QaetirusPlanet, maxx div 2 - cPlanetRadius, maxy div 2 - 250, picMerge)

	View.Update
    end loop
    delay (100)
end BattleMenuDraw


%Start of main program
colourback (255)

%Draws cutscenes
DrawCutscenes

%Initialises all objects
ConstructAll

%Main game loop
loop

    %Initialises all required variables
    bMainMenuReturn := false
    bFinishedBackground := false
    bFinishedMenu := false

    %Plays menu music
    fork PlayMenuMusic (MenuMusic)

    %Draws the buttons on the main menu
    MainMenuDraw

    %Sets the background music to stop playing
    bFinishedMenu := true

    cls
    delay (500)

    %Launches into the two-player game if the amount of players is two
    if iPlayers = 2 then


	%Draws the battlebriefing screen for training and waits for a key press
	cls
	Pic.Draw (BattleBriefing, maxx div 2 - iBattleBriefingWidth div 2, maxy div 2 - iBattleBriefingHeight div 2 + 40, picCopy)
	delay (50)
	View.Update
	loop
	    exit when hasch
	end loop
	Input.Flush

	%Draws the battle selection menu
	BattleMenuDraw

	%Re-initialises both ships
	ReconstructAll (oQShip)
	ReconstructAll (oDShip)

	%Initialises capacitors for battle
	InitialiseCapacitors

	%Plays the battle music
	fork PlayBackgroundMusic (BackgroundMusic)

	%Starts the main game loop
	loop

	    SetupScreen

	    %Checks for any collisions
	    CheckCollisions

	    %Creates and moves debris
	    CreateDebris (iDebrisDifficulty)

	    %Displays all of the lasers
	    for i : 1 .. cLasers
		oQLaser (i) -> Show
		oQLaser (i) -> Move
		oDLaser (i) -> Show
		oDLaser (i) -> Move
	    end for

	    %Displays the torpedos
	    oQTorpedo -> Show
	    oQTorpedo -> Move
	    oDTorpedo -> Show
	    oDTorpedo -> Move

	    %Draws the interface at the bottom of the screen
	    DrawInterface

	    %Draws the Deuterian ship
	    DrawShip ('Deuteria', oDShip, iDLaserCount, oDLaser, oDTorpedo, oDEMP, oDShield,
		UP_ARROW, LEFT_ARROW, RIGHT_ARROW, SHIFT, '/', '.', ',')

	    %Draws the Quintitian ship
	    DrawShip ('Quintos', oQShip, iQLaserCount, oQLaser, oQTorpedo, oQEMP, oQShield,
		'w', 'a', 'd', 'q', 'e', 'r', 'f')

	    %Validates array subscripts and positive integers
	    DataValidation

	    %Checks if the user paused the game and displays the menu if they have
	    PauseCheck

	    %Exits when a ship is destroyed
	    exit when oDShip -> GetArmour = 0 or oQShip -> GetArmour = 0

	    %Exits when the user requests it from the pause menu
	    exit when bMainMenuReturn = true



	    Input.Flush
	    delay (50)
	    View.Update
	end loop

	cls

	%Sets the background music to stop playing
	bFinishedBackground := true

	%Removes all weapons from the screen
	AllBanish

	%Draws the background
	SetupScreen

	%Draws Deuterian ship and checks for key presses
	DrawShip ('Deuteria', oDShip, iDLaserCount, oDLaser, oDTorpedo, oDEMP, oDShield,
	    UP_ARROW, LEFT_ARROW, RIGHT_ARROW, SHIFT, '/', '.', ',')

	%Draws Quintitian ship and checks for key presses
	DrawShip ('Quintos', oQShip, iQLaserCount, oQLaser, oQTorpedo, oQEMP, oQShield,
	    'w', 'a', 'd', 'q', 'e', 'r', 'f')

	%Stops music
	Music.PlayFileStop

	%Draws battle interface
	DrawInterface

	delay (50)

	%Check if both ships collided and it is a draw
	if oDShip -> GetArmour = 0 and oQShip -> GetArmour = 0 then
	    oQShip -> Explode
	    oQShip -> Banish
	    oDShip -> Explode
	    oDShip -> Banish
	    Font.Draw (AnnouncementTextTie,
		round (maxx / 2 - AnnouncementWidthTie / 2), maxy div 2,
		AnnouncementFont, white)
	    delay (600)

	    %Plays a sound eefect
	    fork PlaySound (DrawSound)
	    View.Update

	    %Check if the Deuterian ship is destroyed and the Quintitian ship has won
	elsif oDShip -> GetArmour = 0 then
	    oDShip -> Explode
	    oDShip -> Banish
	    Font.Draw (AnnouncementTextQ,
		round (maxx / 2 - AnnouncementWidthQ / 2), maxy div 2,
		AnnouncementFont, iQInterfaceLights)
	    fork PlaySound (VictorySound)
	    View.Update

	    %Check if the Quintitian ship is destroyed and the Deuterian ship has won
	elsif oQShip -> GetArmour = 0 then
	    oQShip -> Explode
	    oQShip -> Banish
	    Font.Draw (AnnouncementTextD,
		maxx div 2 - AnnouncementWidthD div 2, maxy div 2,
		AnnouncementFont, iDInterfaceLights)
	    fork PlaySound (VictorySound)
	    View.Update
	end if

	%If any of the ship's explode, go to the menu when the user presses a key
	Input.Flush
	delay (2000)
	if bMainMenuReturn = false then
	    Font.Draw (PressAnyKeyText, maxx div 2 - PressAnyKeyWidth div 2, maxy div 2 - 100,
		ButtonFont, white)
	    View.Update
	    loop
		exit when hasch
	    end loop
	end if
	Input.Flush

	%Launches into the single player game if the two player game is not selected
    else

	%Re-initialises both ships
	ReconstructAll (oQShip)
	ReconstructAll (oDShip)

	%Initialises fast-charging capacitors
	InitialiseTrainingCapacitors

	%Initialises training ship to Deuteria
	bTrainingToggle := false

	%Draws the briefing screen for training and waits for a key press
	cls
	Pic.Draw (TrainingBriefing, maxx div 2 - iTrainingBriefingWidth div 2, maxy div 2 - iTrainingBriefingHeight div 2 + 40, picCopy)
	delay (50)
	View.Update
	loop
	    exit when hasch
	end loop
	Input.Flush


	%Plays training music
	fork PlayBackgroundMusic (TrainingMusic)

	%Starts the main training loop
	loop

	    SetupTraining

	    %Creates debris at regular intervals
	    CreateDebris (iDebrisDifficulty)

	    %Displays all of the lasers
	    for i : 1 .. cLasers
		oQLaser (i) -> Show
		oQLaser (i) -> Move
		oDLaser (i) -> Show
		oDLaser (i) -> Move
	    end for

	    %Displays the torpedos
	    oQTorpedo -> Show
	    oQTorpedo -> Move
	    oDTorpedo -> Show
	    oDTorpedo -> Move

	    %Makes ships immune to damage
	    oQShip -> SetArmour (200)
	    oDShip -> SetArmour (200)

	    %Draws the interface at the bottom of the screen
	    DrawInterface

	    %Toggles the training ship to Quintos
	    if keys ('g') then
		bTrainingToggle := true
		oQShip -> SetX (maxx div 2)
		oQShip -> SetY (maxy div 2)

		%Toggles the training ship to Deuteria
	    elsif keys ('h') then
		bTrainingToggle := false
		oDShip -> SetX (maxx div 2)
		oDShip -> SetY (maxy div 2)
	    end if

	    %If the ship is Quintitian
	    if bTrainingToggle = true then
		DrawShip ('Quintos', oQShip, iQLaserCount, oQLaser, oQTorpedo, oQEMP, oQShield,
		    'w', 'a', 'd', 'q', 'e', 'r', 'f')

		oDShip -> Banish

		%Draws a rectangle over the Deuterian interface with text over it
		Draw.FillBox (maxx, 0, maxx div 2, 40, grey)
		Font.Draw (TrainingSwitchTextD, maxx - 10 - TrainingSwitchWidthD, 2, ButtonFont, iDInterfaceLights)

		%If the ship is Deuterian
	    else
		DrawShip ('Deuteria', oDShip, iDLaserCount, oDLaser, oDTorpedo, oDEMP, oDShield,
		    UP_ARROW, LEFT_ARROW, RIGHT_ARROW, SHIFT, '/', '.', ',')

		oQShip -> Banish

		%Draws a rectangle over the Quintitian interface with text over it
		Draw.FillBox (0, 0, maxx div 2, 40, grey)
		Font.Draw (TrainingSwitchTextQ, 10, 2, ButtonFont, iQInterfaceLights)
	    end if

	    %Checks for any collisions
	    CheckCollisions

	    %Validates array subscripts and positive integers
	    DataValidation

	    %Checks if the user paused the game and displays the menu if they have
	    PauseCheck

	    %Exits when the user requests it from the pause menu
	    exit when bMainMenuReturn = true

	    %Removes EMPs from the screen
	    oQEMP -> Banish
	    oDEMP -> Banish

	    Input.Flush
	    delay (50)

	    View.Update
	end loop

	%Sets the background music to stop playing
	bFinishedBackground := true

    end if

    View.Update

    %Exits the loop when the user requests it
    exit when bGameExit = true
end loop

return

