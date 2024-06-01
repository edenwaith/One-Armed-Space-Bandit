SoundsScene = {}
class("SoundsScene").extends(NobleScene)
local scene = SoundsScene
local gfx <const> = playdate.graphics
local snd <const> = playdate.sound

scene.baseColor = Graphics.kColorWhite

-- The story so far...
-- You've stranded at the Oasis Bar which has all the the appealing odor of a Monolith Burger's bathroom.
-- Your goal is to earn 250 Buckazoids at the Slots-o-Death so you can buy a ship and get off this crusty rock of a planet.

-- Instructions
-- Use the D-pad to raise or lower your bet from 1 to 3 Buckazoids.
-- Pull the crank down to spin. 

-- Winning condition: earn $250 (₿250)
-- Losing conditions:
	-- Lose all of your money (perhaps a silly death message)
	-- Get three skulls and get killed (also have a silly death message or few)
-- Side thought: difficulty level to improve the chances of winning?


-- local background
-- local logo
local menu

-- local sequence

local instructionsText

-- local instrState

-- InstructionsState = {
-- 	First,
-- 	Second,
-- 	Last
-- }

-- Check the YouTube video on how to load in and play MIDI files
-- This will involve taking the tracks, adding a synth player/instrument
-- to each track and then adding them back in.
local synthPlayer = snd.synth.new(snd.kWaveSquare) -- kWaveSawtooth
local sawtoothSynthPlayer = snd.synth.new(snd.kWaveSawtooth)
local sineSynthPlayer = snd.synth.new(playdate.sound.kWaveSine)
local triangleSynthPlayer = snd.synth.new(playdate.sound.kWaveTriangle)
-- synthPlayer:setADSR(0,0.2,1,0.5) -- may not be necessary
-- local midi = snd.sequence.new("../sounds/midiFile.mid")
local sound7 = snd.sequence.new('sounds/Sound7.mid')
local sound24 = snd.sequence.new('sounds/Sound24-Square.mid')
local sound25 = snd.sequence.new('sounds/Sound25.mid')
local sound26 = snd.sequence.new('sounds/Sound26.mid')
local sound27 = snd.sequence.new('sounds/Sound27-Square.mid')
local sound28 = snd.sequence.new('sounds/Sound28.mid')
local sound66 = snd.sequence.new('sounds/Sound66.mid')


-- Keep getting this crash
-- scenes/InstructionsScene.lua:52: bad argument #1 to 'getTrackAtIndex' (playdate.sound.sequence expected, got number)
-- stack traceback:
-- 	[C]: in field 'getTrackAtIndex'
-- 	scenes/InstructionsScene.lua:52: in main chunk

-- The solution: Need to use the : notation, not . notation

-- Try and get number of tracks from MIDI sequence
-- local trackCount = midi.getTrackCount()
-- print("track count: ", trackCount)


function scene:init()
	scene.super.init(self)
	
	
	-- instrState = InstructionsState.First

	instructionsText = "You're stranded at the Oasis Bar which has all the \nappealing odor of a Monolith Burger's bathroom.\n\nYour only hope is to earn 250 Buckazoids at the \nSlots-o-Death so you can buy a ship and get off \nthis crusty rock of a planet."

	-- background = Graphics.image.new("assets/images/background2")
	-- logo = Graphics.image.new("libraries/noble/assets/images/NobleRobotLogo")

	menu = Noble.Menu.new(false, Noble.Text.ALIGN_LEFT, false, Graphics.kColorBlack, 4,6,0, Noble.Text.FONT_MEDIUM)
	-- menu:addItem("Sound2", playSound7) -- Just temp code stuff
	-- menu:addItem("Sound7", playSound7)
	menu:addItem("Chest", playChestSound)
	menu:addItem("Sound24", playSound24)
	menu:addItem("Sound25", playSound25)
	menu:addItem("Sound26", playSound26)
	menu:addItem("Sound27", playSound27)
	menu:addItem("Sound28", playSound28)
	menu:addItem("Sound66", playSound66)
	
	-- Sounds to test:
	-- Sound7: Death tune
	-- Sound24: Victory march
	-- Sound25: Blip
	-- Sound26: Win
	-- Sound27: Didn't Win
	-- Sound28: Laser
-- 
-- 	menu:addItem(Noble.TransitionType.DIP_TO_BLACK, function() Noble.transition(ExampleScene, 1, Noble.TransitionType.DIP_TO_BLACK) end)
-- 	menu:addItem(Noble.TransitionType.DIP_TO_WHITE, function() Noble.transition(ExampleScene, 1, Noble.TransitionType.DIP_TO_WHITE) end)
-- 	menu:addItem(Noble.TransitionType.DIP_METRO_NEXUS, function() Noble.transition(ExampleScene, 1, Noble.TransitionType.DIP_METRO_NEXUS) end)
-- 	menu:addItem(Noble.TransitionType.DIP_WIDGET_SATCHEL, function() Noble.transition(ExampleScene, 1, Noble.TransitionType.DIP_WIDGET_SATCHEL) end)
-- 	menu:addItem(Noble.TransitionType.CROSS_DISSOLVE, function() Noble.transition(ExampleScene, 1, Noble.TransitionType.CROSS_DISSOLVE) end)
-- 	menu:addItem(Noble.TransitionType.SLIDE_OFF_UP, function() Noble.transition(ExampleScene, 1, Noble.TransitionType.SLIDE_OFF_UP) end)
-- 	menu:addItem(Noble.TransitionType.SLIDE_OFF_DOWN, function() Noble.transition(ExampleScene, 1, Noble.TransitionType.SLIDE_OFF_DOWN) end)
-- 	menu:addItem(Noble.TransitionType.SLIDE_OFF_LEFT, function() Noble.transition(ExampleScene, 1, Noble.TransitionType.SLIDE_OFF_LEFT) end)
-- 	menu:addItem(Noble.TransitionType.SLIDE_OFF_RIGHT, function() Noble.transition(ExampleScene, 1, Noble.TransitionType.SLIDE_OFF_RIGHT) end)
-- 	menu:addItem(
-- 		"Score",
-- 		function()
-- 			local newValue = math.random(100,99999)
-- 			Noble.GameData.set("Score", newValue)
-- 			menu:setItemDisplayName("Score", "Change Score: " .. newValue)
-- 		end, nil,
-- 		"Change Score: " .. Noble.GameData.get("Score")
-- 	)

--	local crankTick = 0

	scene.inputHandler = {
		-- upButtonDown = function()
		-- 	print("Try and play midi file")
		-- 	midi:play()
		-- 	midi:setLoops(0)
		-- end,
		-- downButtonDown = function()
		-- 	midi:stop()
		-- end,
		upButtonDown = function()
			menu:selectPrevious()
		end,
		downButtonDown = function()
			menu:selectNext()
		end,
		-- cranked = function(change, acceleratedChange)
		-- 	crankTick = crankTick + change
		-- 	if (crankTick > 30) then
		-- 		crankTick = 0
		-- 		menu:selectNext()
		-- 	elseif (crankTick < -30) then
		-- 		crankTick = 0
		-- 		menu:selectPrevious()
		-- 	end
		-- end,
		AButtonDown = function()
			menu:click()
		end,
		BButtonDown = function()
			stopAllSounds()
			-- Go back to the previous screen
			Noble.transition(TitleScene, 1, Noble.TransitionType.DIP_TO_WHITE)
		end
		
	}

end

function scene:enter()
	scene.super.enter(self)

	sequence = Sequence.new():from(0):to(100, 1.5, Ease.outBounce)
	sequence:start();

end

function scene:start()
	scene.super.start(self)

	menu:activate()
	-- Noble.Input.setCrankIndicatorStatus(true)

end

function scene:drawBackground()
	scene.super.drawBackground(self)
end

function scene:update()
	scene.super.update(self)

	-- Draw the menu
	-- Graphics.setColor(Graphics.kColorWhite)
	-- Graphics.setDitherPattern(0.2, Graphics.image.kDitherTypeScreen)
	-- Graphics.fillRoundRect(15, (sequence:get()*0.75)+3, 185, 145, 15)
	-- menu:draw(30, sequence:get()-15 or 100-15)

	Graphics.setColor(Graphics.kColorBlack)
	Graphics.setDitherPattern(0.8, Graphics.image.kDitherTypeScreen) -- original value was 0.2
	-- Graphics.fillRoundRect(15, (sequence:get()*0.75)+3, 185, 145, 15)
	Graphics.fillRoundRect(0, 215, 400, 25, 0)
	-- menu:draw(30, sequence:get()-15 or 100-15)
	menu:draw(30, 40)
	
	Graphics.setColor(Graphics.kColorWhite)
	Graphics.fillRoundRect(260, -20, 130, 65, 15)

	Graphics.setColor(Graphics.kColorBlack)
	Graphics.fillRect(0, 0, 400, 25)
	
	Graphics.setColor(Graphics.kColorWhite)
-- 	Graphics.fillRoundRect(260, -20, 130, 65, 15)
	-- logo:setInverted(false)
	-- logo:draw(275, 8)
	
	-- Noble.Text.setColor(Graphics.kColorWhite)
	-- Noble.Text.draw(__string, __x, __y[, __alignment=Noble.Text.ALIGN_LEFT[, __localized=false[, __font=Noble.Text.getCurrentFont()]]])
	-- MAYBE draw a black box behind the title and set the text to white
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillWhite)
	Noble.Text.draw("*SOUNDS*", 200, 4, Noble.Text.ALIGN_CENTER)
	
	-- Change the text to white
	
	
	-- playdate.graphics.setImageDrawMode(gfx.kDrawModeFillBlack)
	-- gfx.drawText("_The story so far..._", 10, 40)
	-- gfx.drawText(instructionsText, 10, 70)
	
	-- Noble.Text.setColor(Graphics.kColorBlack) -- causes a crash
	gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
	Noble.Text.draw("*Main Menu* Ⓑ", 385, 220, Noble.Text.ALIGN_RIGHT)
	 -- Ⓐ or Ⓑ
	
	-- playdate.graphics.drawText("Your only hope to get off this crusty rock of a \nplanet is to earn 250 Buckazoids at the \n Slots-o-Death so you can buy a ship.", 10, 110)
								
	-- Your goal is to earn 250 Buckazoids at the Slots-o-Death so you can buy a ship and get off this crusty rock of a planet.
	-- playdate.graphics.drawText("*INSTRUCTIONS*", 10, 40)

end

function scene:exit()
	scene.super.exit(self)

	Noble.Input.setCrankIndicatorStatus(false)
	sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
	sequence:start();

end

function scene:finish()
	scene.super.finish(self)
	-- This then causes the background image on the Title Scene to go all black
	-- Called at this point so the transition effect works
	gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
end

function playChestSound()
	stopAllSounds()
	
	local chestOpen = snd.track.new()
	local note = "A1" -- "F1"
	chestOpen:addNote(1, note, 40, 1.0) -- 127 / 1.0
	chestOpen:addNote(41, note, 20, 0.94) -- 119 / 0.94
	chestOpen:addNote(62, note, 10, 1.0) -- 127 / 1.0
	chestOpen:addNote(73, note, 10, 0.8) -- 
	chestOpen:addNote(84, note, 10, 0.4)
	-- chestOpen:addNote(1,"Bb3", 2)
	-- chestOpen:addNote(5,"C4", 1)
	-- chestOpen:addNote(6,"G4", 1)
	-- chestOpen:addNote(7,"Bb4", 1)
	local chestSynthPlayer = synthPlayer:copy()
	chestSynthPlayer:setADSR(0, 0.15, 0.2, 0)
	
	chestOpen:setInstrument(chestSynthPlayer)
	
	local chestSequence = snd.sequence.new()
	chestSequence:addTrack(chestOpen)
	chestSequence:setTempo(120)
	
	chestSequence:play()
end

-- This one also doesn't sound great, like some notes are missing.
-- For the troublesome audio files, might stick with mp3 or wav instead of MIDI
-- I might try exporting this from one of the other Sierra games and see how that works.
-- Isn't there a nice death tone from SQ2 I could use, instead?
function playSound7MIDI()
	stopAllSounds()
	print("Welcome to Sound7")
	
	local track1 = sound7:getTrackAtIndex(1) -- May have to start at #2, experiment
	local track2 = sound7:getTrackAtIndex(2)
	local track3 = sound7:getTrackAtIndex(3) -- From what I saw in Logic Pro, doesn't seem to be much here, but useful in case there is a three track MIDI file, which would have been appropriate for 3-voice Tandy sound.
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	track3:setInstrument(synthPlayer:copy())
	sound7:setTrackAtIndex(1, track1)
	sound7:setTrackAtIndex(2, track2)
	sound7:setTrackAtIndex(3, track3)
	sound7:setTempo(60) -- For other versions of Sound7, set Tempo to 200
	-- sound7:setVolume(0.5) --  Nope, this doesn't work
	
	sound7:play()
end

function playSound7()
	stopAllSounds()
	
	local mp3Player = snd.fileplayer.new("sounds/Sound7")
	mp3Player:play()
end

function playSound24()
	stopAllSounds()
	-- Is there a way to restart the sound from the beginning if it had been playing?
	print("Welcome to Sound24")
	
	local track1 = sound24:getTrackAtIndex(1) -- May have to start at #2, experiment
	local track2 = sound24:getTrackAtIndex(2)
	local track3 = sound24:getTrackAtIndex(3) -- From what I saw in Logic Pro, doesn't seem to be much here, but useful in case there is a three track MIDI file, which would have been appropriate for 3-voice Tandy sound.
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	track3:setInstrument(synthPlayer:copy())
	sound24:setTrackAtIndex(1, track1)
	sound24:setTrackAtIndex(2, track2)
	sound24:setTrackAtIndex(3, track3)
	-- midi:setTempo(80)
	sound24:setTempo(200) -- 200 for Sound24
	
	sound24:play()
	-- 	midi:setLoops(0)
end

function playSound25()
	stopAllSounds()
	
	local track1 = sound25:getTrackAtIndex(1) -- May have to start at #2, experiment
	local track2 = sound25:getTrackAtIndex(2)
	local track3 = sound25:getTrackAtIndex(3) 
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	track3:setInstrument(synthPlayer:copy())
	sound25:setTrackAtIndex(1, track1)
	sound25:setTrackAtIndex(2, track2)
	sound25:setTrackAtIndex(3, track3)
	sound25:setTempo(200)
	
	sound25:play()
end

function playSound26()
	stopAllSounds()
	
	local track1 = sound26:getTrackAtIndex(1)
	local track2 = sound26:getTrackAtIndex(2)
	local track3 = sound26:getTrackAtIndex(3) 
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	track3:setInstrument(synthPlayer:copy())
	sound26:setTrackAtIndex(1, track1)
	sound26:setTrackAtIndex(2, track2)
	sound26:setTrackAtIndex(3, track3)
	sound26:setTempo(100)
	
	sound26:play()
end

-- This doesn't sound quite as good as the WAV or MP3 file for some reason.
-- Re-exported from AGI Studio, trying again.  The Sound27.mid has 5 tracks
-- but most are empty.  This new version has three tracks, but the third track
-- sounds like a high note which is going to be removed
function playSound27MIDI()
	stopAllSounds()
	
	local track1 = sound27:getTrackAtIndex(1)
	local track2 = sound27:getTrackAtIndex(2)
	-- local track3 = sound27:getTrackAtIndex(3) 
	-- local track4 = sound27:getTrackAtIndex(4)
	-- local track5 = sound27:getTrackAtIndex(5)
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	-- track3:setInstrument(synthPlayer:copy())
	-- track4:setInstrument(synthPlayer:copy())
	-- track5:setInstrument(synthPlayer:copy())
	
	sound27:setTrackAtIndex(1, track1)
	sound27:setTrackAtIndex(2, track2)
	-- sound27:setTrackAtIndex(3, track3)
	-- sound27:setTrackAtIndex(4, track4)
	-- sound27:setTrackAtIndex(5, track5)
	sound27:setTempo(120)
	
	sound27:play()
end

function playSound27()
	stopAllSounds()
	
	local mp3Player = snd.fileplayer.new("sounds/Sound27")
	mp3Player:play()
	-- the documentation says that fileplayer:setVolume() is an option, but 
	-- this just resulted in a crash
end

function playSound28()
	stopAllSounds()
	
	local track1 = sound28:getTrackAtIndex(1)
	local track2 = sound28:getTrackAtIndex(2)
	local track3 = sound28:getTrackAtIndex(3)
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	track3:setInstrument(synthPlayer:copy())
	sound28:setTrackAtIndex(1, track1)
	sound28:setTrackAtIndex(2, track2)
	sound28:setTrackAtIndex(3, track3)
	sound28:setTempo(100)
	
	sound28:play()
end

-- Death sound
-- This is a sequence
function playSound66()
	stopAllSounds()
	
	local track1 = sound66:getTrackAtIndex(1)
	local track2 = sound66:getTrackAtIndex(2)
	local track3 = sound66:getTrackAtIndex(3) 
	
	synthPlayer:setVolume(0.5)
	local synthVolume = synthPlayer:getVolume()
	print("synthVolume is " .. synthVolume)
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	track3:setInstrument(synthPlayer:copy())
	sound66:setTrackAtIndex(1, track1)
	sound66:setTrackAtIndex(2, track2)
	sound66:setTrackAtIndex(3, track3)
	-- Is there a way to set the volume, some of these are kind of loud
	sound66:setTempo(200)
	
	sound66:play()
end

function stopAllSounds()
	sound7:stop()
	sound24:stop()
	sound25:stop()
	sound26:stop()
	sound27:stop()
	sound28:stop()
	sound66:stop()
end