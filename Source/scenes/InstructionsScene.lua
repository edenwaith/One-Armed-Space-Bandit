InstructionsScene = {}
class("InstructionsScene").extends(NobleScene)
local scene = InstructionsScene
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
-- local menu

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
-- synthPlayer:setADSR(0,0.2,1,0.5) -- may not be necessary
-- local midi = snd.sequence.new("../sounds/midiFile.mid")
local midi = snd.sequence.new('sounds/Sound24-Square.mid')
-- local midi = snd.sequence.new('sounds/Sound7.mid')
-- local midi = snd.sequence.new('foo.midi')

if (midi == nil) then
	print("midi is empty!")
else
	-- says "userdata", but seeing the same thing even with a fake file
	print("midi is of type: ", type(midi))
end

-- Keep getting this crash
-- scenes/InstructionsScene.lua:52: bad argument #1 to 'getTrackAtIndex' (playdate.sound.sequence expected, got number)
-- stack traceback:
-- 	[C]: in field 'getTrackAtIndex'
-- 	scenes/InstructionsScene.lua:52: in main chunk

-- The solution: Need to use the : notation, not . notation

-- Try and get number of tracks from MIDI sequence
-- local trackCount = midi.getTrackCount()
-- print("track count: ", trackCount)

local track1 = midi:getTrackAtIndex(1) -- May have to start at #2, experiment
local track2 = midi:getTrackAtIndex(2)
local track3 = midi:getTrackAtIndex(3) -- From what I saw in Logic Pro, doesn't seem to be much here, but useful in case there is a three track MIDI file, which would have been appropriate for 3-voice Tandy sound.

track1:setInstrument(synthPlayer:copy())
track2:setInstrument(synthPlayer:copy())
track3:setInstrument(synthPlayer:copy())
midi:setTrackAtIndex(1, track1)
midi:setTrackAtIndex(2, track2)
midi:setTrackAtIndex(3, track3)
-- midi:setTempo(80)
midi:setTempo(200) -- 200 for Sound24

function scene:init()
	scene.super.init(self)
	
	
	-- instrState = InstructionsState.First

	instructionsText = "You're stranded at the Oasis Bar which has all the \nappealing odor of a Monolith Burger's bathroom.\n\nYour only hope is to earn 250 Buckazoids at the \nSlots-o-Death so you can buy a ship and get off \nthis crusty rock of a planet."

	-- background = Graphics.image.new("assets/images/background2")
	-- logo = Graphics.image.new("libraries/noble/assets/images/NobleRobotLogo")

-- 	menu = Noble.Menu.new(false, Noble.Text.ALIGN_LEFT, false, Graphics.kColorBlack, 4,6,0, Noble.Text.FONT_SMALL)
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
		upButtonDown = function()
			print("Try and play midi file")
			midi:play()
			midi:setLoops(0)
		end,
		downButtonDown = function()
			midi:stop()
		end,
		-- upButtonDown = function()
		-- 	menu:selectPrevious()
		-- end,
		-- downButtonDown = function()
		-- 	menu:selectNext()
		-- end,
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
		-- AButtonDown = function()
		-- 	menu:click()
		-- end,
		AButtonDown = function()
			instructionsText = "And here is some other text"
		end,
		BButtonDown = function()
			-- Go back to the previous screen
			Noble.transition(TitleScene, 1, Noble.TransitionType.SLIDE_OFF_RIGHT)
			-- print("Go back to the title screen")
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

	-- s:play()

	-- menu:activate()
	-- Noble.Input.setCrankIndicatorStatus(true)

end

function scene:drawBackground()
	scene.super.drawBackground(self)

	-- background:draw(0, 0)
end

function scene:update()
	scene.super.update(self)

-- 	Graphics.setColor(Graphics.kColorWhite)
-- 	Graphics.setDitherPattern(0.2, Graphics.image.kDitherTypeScreen)
-- 	Graphics.fillRoundRect(15, (sequence:get()*0.75)+3, 185, 145, 15)
-- 	-- menu:draw(30, sequence:get()-15 or 100-15)
-- 
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
	Noble.Text.draw("*INSTRUCTIONS*", 200, 4, Noble.Text.ALIGN_CENTER)
	
	-- Change the text to white
	
	-- Noble.Text.setColor(Graphics.kColorBlack)
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillBlack)
	gfx.drawText("_The story so far..._", 10, 40)
	gfx.drawText(instructionsText, 10, 70)
	
	Noble.Text.draw("Press Ⓐ to continue", 385, 220, Noble.Text.ALIGN_RIGHT) -- Ⓑ
	
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
end