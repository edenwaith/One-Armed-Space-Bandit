GameScene = {}
class("GameScene").extends(NobleScene)
local scene = GameScene

scene.baseColor = Graphics.kColorBlack

-- local background
-- local logo
-- local menu
local gfx <const> = playdate.graphics
local snd <const> = playdate.sound
local sequence -- probably can get rid of this: TODO: Clean up
local money = 30
-- NOTE: Lua uses snake case to name variables and methods
local currentBet = 1
local crankTick = 0
local is_crank_starting = false

local is_currently_spinning = false 
-- local difficulty = gameDifficulty() -- 1 is hard, 2 is medium, 3 is easy
-- local handicap = (difficulty - 1) * 5
local youLostMessages = {"*You Lose*", "*Tough Luck*", "*It's Hopeless*", "*Eat Sand*", "*Suck Methane*", "*So Sorry*", "*Not A Chance*"}
local spinMessage = "*Press* Ⓐ *or pull the crank down to spin*"

local roll = 0

local firstSlotRotations  = 0
local secondSlotRotations = 0
local thirdSlotRotations  = 0
local rotations = 0

local first_slot_image = 1
local second_slot_image = 1
local third_slot_image = 1

-- Image variables
local skull_image = gfx.image.new("images/skull-dithered")
local cherry_image = gfx.image.new("images/cherries-dithered")
local eye_image = gfx.image.new("images/eye-dithered")
local diamond_image = gfx.image.new("images/diamond-dithered")

local images_array = {skull_image, cherry_image, eye_image, diamond_image}

-- Order of the images rotating:
-- Skull, cherry, diamond, eye

-- Sprite Varaibles
local first_slot_sprite = gfx.sprite.new(images_array[2])
local second_slot_sprite = gfx.sprite.new(images_array[1])
local third_slot_sprite = gfx.sprite.new(images_array[4])

-- Sound variables
local synthPlayer = snd.synth.new(snd.kWaveSquare)
local blipSound = snd.sequence.new('sounds/sound25.mid')
local blipMP3Player = snd.fileplayer.new("sounds/Sound25")
local blipWAVPlayer = snd.sampleplayer.new("sounds/Sound25.wav")

-- Enumerations in Lua: https://unendli.ch/posts/2016-07-22-enumerations-in-lua.html
RollStatus = {
	Death = 1,
    Lost = 2,
    OneCherry = 3,
    TwoCherries = 4,
    ThreeCherries = 5,
    Eyes = 6,
    Diamonds = 7,
    NotPlaying = 8,
}


function scene:init()
	scene.super.init(self)

	print("GameScene init")
	-- Trying to reference "os" causes a crash, doesn't know what "os" is 
	-- math.randomseed(os.time()) -- initially seed the random number generator

	-- The Playdate dev docs recommend this to seed the random number generator
	-- https://sdk.play.date/2.3.1/Inside%20Playdate.html#f-getSecondsSinceEpoch
	-- When I leave the scene and come back, the roll seems to be the same value
	-- This can create an exploit where the user comes in, wins, leaves, then comes
	-- back to win again.  Is this randomization enough?
	math.randomseed(playdate.getSecondsSinceEpoch())


	scene.inputHandler = {
		-- upButtonDown = function()
		-- 	menu:selectPrevious()
		-- end,
		-- downButtonDown = function()
		-- 	menu:selectNext()
		-- end,
		
		cranked = function(change, acceleratedChange)
			
			--if (is_crank_starting == true) then
				crankTick = crankTick + change
			--end
			
			local crank_position = playdate.getCrankPosition()
			
			print("crank_position: " .. crank_position)
			
			if (crank_position < 360 and crank_position > 350 and is_crank_starting == false) then
				print("Crank is up!")
				is_crank_starting = true
			end
			
			-- One can also crank the "wrong" direction and trigger this.
			-- Might need to just calculate the change
			if (crank_position < 190 and crank_position > 170 and is_crank_starting == true) then
			-- if (crankTick < -190 and crankTick < -170 and is_crank_starting == true) then
				print("Crank is down")
				is_crank_starting = false
				crankTick = 0
				spin()
			end
			
			-- If the crank position is top, its value will be around 360 or 0.
			-- Pulling down will have a value going from 360 and down to 180
			-- when the crank is pointing down.
			
			-- if (crankTick > 30 or crankTick < -30) then
			-- 	print("crankTick was originally: " .. crankTick)
			-- end
			-- 
			-- if (crankTick > 30) then
			-- 	crankTick = 0
			-- 	-- menu:selectNext()
			-- elseif (crankTick < -30) then
			-- 	crankTick = 0
			-- 	-- menu:selectPrevious()
			-- end
			
			print("cranked value: " .. crankTick .. " change: " .. change .. " and acceleratedChange: " .. acceleratedChange)
		end,
		
		-- AButtonDown = function()
		-- 	menu:click()
		-- end,
		upButtonUp = function()
			-- TODO: Need to check that the game isn't currently spinning
			if is_currently_spinning == false then
				if currentBet < 3 then
					currentBet = currentBet + 1
				end
			end
		end,
		downButtonUp = function()
			if is_currently_spinning == false then
				if currentBet > 1 then
					currentBet = currentBet - 1
				end
			end
		end,
		leftButtonUp = function()
			print("Left button up")
			-- Simulate win state
			Noble.GameData.Status = GameStatus.Won
			Noble.transition(EndGameScene, 1, Noble.TransitionType.CROSS_DISSOLVE)
		end, 
		rightButtonHold = function()
			print("You're broke!")
			Noble.GameData.Status = GameStatus.Broke 
			Noble.transition(EndGameScene, 1, Noble.TransitionType.SLIDE_OFF_DOWN)
		end,
		rightButtonUp = function()
			print("Right button up")
			-- Simulate death state 
			Noble.GameData.Status = GameStatus.Death
			Noble.transition(EndGameScene, 1, Noble.TransitionType.CROSS_DISSOLVE)
		end,
	-- Add left and right D-pad buttons to get to different end game states
		AButtonDown = spin,
		BButtonDown = function()
			if is_currently_spinning == false then
			-- Go back to the previous screen
				Noble.transition(TitleScene, 1, Noble.TransitionType.SLIDE_OFF_DOWN) -- SLIDE_OFF_DOWN
			end
		end
		
	}

end

function scene:enter()
	scene.super.enter(self)
	print("GameScene enter")

	

	sequence = Sequence.new():from(0):to(100, 1.5, Ease.outBounce)
	sequence:start();
	
	-- Might only need to set this if the player isn't already playing
	-- Or have some other option to continue an existing game
	if Noble.GameData.Status == GameStatus.New then
		-- Idea: Perhaps adjust the initial amount of $ to differ based on difficulty level
		money = 30
		roll_status = RollStatus.NotPlaying
		spinMessage =  "*Press* Ⓐ *or pull the crank down to spin*"
	end 
	
	Noble.GameData.Status = GameStatus.Playing
	
	-- Set the initial images when starting
	first_slot_image = math.random(1, 4)
	first_slot_sprite:setImage(images_array[first_slot_image]) 
	second_slot_image = math.random(1, 4)
	second_slot_sprite:setImage(images_array[second_slot_image]) 
	third_slot_image = math.random(1, 4)
	third_slot_sprite:setImage(images_array[third_slot_image]) 
	
end

function scene:start()
	scene.super.start(self)
	print("GameScene start")

	local difficulty = Noble.Settings.get("Difficulty")
	print("Game difficulty is set to " .. difficulty)
	
	rollStatus = RollStatus.NotPlaying
	print("Roll Status: ", rollStatus)
	
	
	first_slot_sprite:moveTo(90, 120)
	first_slot_sprite:add()
	
	second_slot_sprite:moveTo(200, 120)
	second_slot_sprite:add()
	
	third_slot_sprite:moveTo(308, 120)
	third_slot_sprite:add()

	-- This font looks a little too small: is it possible to enlarge?	
	-- local sierraFont = gfx.font.new('fonts/Sierra-AGI-Basic-Latin-and-Supplement')
	-- gfx.setFont(sierraFont)

	-- menu:activate()
	-- if playdate.isCrankDocked() == true then
	-- 	Noble.Input.setCrankIndicatorStatus(true)
	-- end

end

function scene:drawBackground()
	scene.super.drawBackground(self)

	  -- Set the background image
	local backgroundImage = gfx.image.new( "images/Slots-Background" ) -- RoomAbkg
	-- Crash: scenes/GameScene.lua:133: attempt to index a nil value (local 'backgroundImage')
	assert( backgroundImage )
	
	backgroundImage:draw( 0, 0 )
end


function scene:update()
	scene.super.update(self)

-- 	Graphics.setColor(Graphics.kColorWhite)
-- 	Graphics.setDitherPattern(0.2, Graphics.image.kDitherTypeScreen)
-- 	Graphics.fillRoundRect(15, (sequence:get()*0.75)+3, 185, 145, 15)
-- 	-- menu:draw(30, sequence:get()-15 or 100-15)
-- 
-- 	Graphics.setColor(Graphics.kColorBlack)
-- 	Graphics.fillRoundRect(260, -20, 130, 65, 15)
	-- logo:setInverted(false)
	-- logo:draw(275, 8)
	
-- 	local backgroundImage = gfx.image.new( "images/RoomAbkg" )
	-- assert( backgroundImage )
--	backgroundImage:draw( 0, 0 )
	
	Graphics.setColor(Graphics.kColorBlack)
	Graphics.fillRect(0, 0, 400, 25)
	
	-- Dark black bar at bottom of the screen
	Graphics.fillRect(0, 215, 400, 25)
-- 	
 	Graphics.setColor(Graphics.kColorWhite)
-- 
-- 	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillWhite)
	Graphics.setImageDrawMode(gfx.kDrawModeFillWhite) -- this causes the background image to disappear.
	local winnings = "*You have $" .. money .. "*" -- Concatenate the string with the money value
	Noble.Text.draw(winnings, 15, 4, Noble.Text.ALIGN_LEFT)
 	
	local bet = "*You bet $" .. currentBet .. "*"
	Noble.Text.draw(bet, 300, 4, Noble.Text.ALIGN_LEFT)
	
	
	
	Noble.Text.draw(spinMessage, 200, 219, Noble.Text.ALIGN_CENTER)
	
	-- -- Graphics.setColor(Graphics.kColorBlack)
	-- Graphics.fillRect(86, 56, 8, 8)
	-- Graphics.fillRect(196, 56, 8, 8)
	-- Graphics.fillRect(305, 56, 8, 8)
	
	updateSquares()
	
	Graphics.setImageDrawMode(gfx.kDrawModeCopy ) -- Call this so the background is visible and isn't just a white screen
	
end

function updateSquares()

	local modVal = rotations % 2

	-- This works to ensure the white squares are showing properly, but 
	-- this code has a lot of duplications, probably can be done better.
	-- Lua doesn't have a traditional ternary operator:
	-- http://lua-users.org/wiki/TernaryOperator
	
	-- First slot
 	if rotations < firstSlotRotations then
		
		if modVal == 1 then
			Graphics.setColor(Graphics.kColorWhite)
		else
			Graphics.setColor(Graphics.kColorBlack)
		end
	
	else 
		Graphics.setColor(Graphics.kColorWhite)
	end
	
	Graphics.fillRect(86, 56, 8, 8)
	
	-- Second slot
	 if rotations < secondSlotRotations then
		
		if modVal == 1 then
			Graphics.setColor(Graphics.kColorWhite)
		else
			Graphics.setColor(Graphics.kColorBlack)
		end
	
	else 
		Graphics.setColor(Graphics.kColorWhite)
	end	
	
	-- Third slot
	Graphics.fillRect(196, 56, 8, 8)
	
	if rotations < thirdSlotRotations then
		
		if modVal == 1 then
			Graphics.setColor(Graphics.kColorWhite)
		else
			Graphics.setColor(Graphics.kColorBlack)
		end
	
	else 
		Graphics.setColor(Graphics.kColorWhite)
	end	
	
	Graphics.fillRect(305, 56, 8, 8)

end

function scene:exit()
	scene.super.exit(self)

	-- Need to clear out the sprites, otherwise they remain on the screen
	-- gfx.clear(gfx.kColorWhite)
	first_slot_sprite:remove()
	second_slot_sprite:remove()
	third_slot_sprite:remove()

	Noble.Input.setCrankIndicatorStatus(false)
	sequence = Sequence.new():from(100):to(240, 0.25, Ease.inSine)
	sequence:start();

end

function scene:finish()
	scene.super.finish(self)
end

function spin()
	
	-- TODO: Need to check if things are currently spinning, and if so
	-- do not do anything here so it doesn't try to spin again
		
	if is_currently_spinning == true then 
		return 
	else 
		is_currently_spinning = true
	end 
	
	spinMessage = "" -- Reset this message on a new spin
	
	if (currentBet > money) then
		is_currently_spinning = false 
		spinMessage = "Sorry, you don't have enough to bet that much."
	else
	
		roll = math.random(1, 100)
		local handicap = handicap()
		
		if (roll < 3) then  -- Death
			roll_status = RollStatus.Death
		elseif roll < (5 + handicap) then -- 3 Diamonds
			roll_status = RollStatus.Diamonds
		elseif roll < (7 + handicap) then -- 3 Eyes
			roll_status = RollStatus.Eyes
		elseif roll < (11 + handicap) then -- 3 Cherries
			roll_status = RollStatus.ThreeCherries
		elseif roll < (18 + handicap) then -- 2 Cherries
			roll_status = RollStatus.TwoCherries
		elseif roll < (34 + handicap) then -- 1 Cherry
			roll_status = RollStatus.OneCherry
		else -- Lost
			roll_status = RollStatus.Lost 
		end
		
		-- turns = turns + 1
		money = money - currentBet -- Money for the turn 
		
		print("You have $" .. money)
		print("The roll was " .. roll)
		
		rotations = 0
		firstSlotRotations = math.random(5, 11) -- initially 10 to 23
		secondSlotRotations = math.random(13, 19) -- initially 26 to 38
		thirdSlotRotations = math.random(21, 26) -- initially 42 to 53
		
		print("Slot rotations are 1: " .. firstSlotRotations .. " 2: " .. secondSlotRotations .. " 3: " .. thirdSlotRotations)
		
		playBlipSound()
	end
end

-- Select a random number from 1 to 4 to determine a random image to display
-- If exception_num is defined, that particular corresponding image will be
-- excluded from the possible images.  The default value is 2 (cherry)
function random_image_number(exception_num)
	exception_num = exception_num or 2
	
	local random_num = math.random(1, 4)
	
	while (random_num == exception_num)
	do
		random_num = math.random(1, 4)
	end
	
	return random_num
	
end

function continueSpinning()
	
	-- print("Slot rotations are 1: " .. firstSlotRotations .. " 2: " .. secondSlotRotations .. " 3: " .. thirdSlotRotations)
	
	rotations = rotations + 1
	local modVal = rotations % 4 + 1 -- Need to ensure it is never zero
	local first_image = (rotations + first_slot_image) % 4 + 1
	local second_image = (rotations + second_slot_image) % 4 + 1
	local third_image = (rotations + third_slot_image) % 4 + 1
	local handicap = handicap()
	
	-- print("first_image: " .. first_image .. " second_image: " .. second_image .. " third_image: " .. third_image)
	
	if rotations <= thirdSlotRotations then
		
		-- Need to update the UI here
		
		if rotations < firstSlotRotations then
			
			first_slot_sprite:setImage(images_array[first_image]) 
			first_slot_image = first_image
			
		elseif rotations == firstSlotRotations then
			if (roll_status == RollStatus.Death) then -- Death
				first_slot_image = 1
				first_slot_sprite:setImage(images_array[1])
			elseif roll_status == RollStatus.Diamonds then
				first_slot_image = 4
				first_slot_sprite:setImage(images_array[4]) 
			elseif roll_status == RollStatus.Eyes then -- 3 Eyes
				first_slot_image = 3
				first_slot_sprite:setImage(images_array[3])
			elseif roll_status == RollStatus.ThreeCherries then
				first_slot_image = 2
				first_slot_sprite:setImage(images_array[2]) 
			elseif roll_status == RollStatus.TwoCherries then
				first_slot_image = 2
				first_slot_sprite:setImage(images_array[2]) 
			elseif roll_status == RollStatus.OneCherry then
				first_slot_image = 2
				first_slot_sprite:setImage(images_array[2]) 
			else
				-- Need to select a random number, but it can't be 2 
				local random_image_num = random_image_number()
				first_slot_sprite:setImage(images_array[random_image_num])
				first_slot_image = random_image_num
			end
			
			-- If it is a lose scenario, then select something random
		end
		
		if rotations < secondSlotRotations then
			second_slot_sprite:setImage(images_array[second_image]) 
			second_slot_image = second_image -- This works, I guess.  My code is confusing me!
		elseif rotations == secondSlotRotations then
			if (roll_status == RollStatus.Death) then -- Death
				second_slot_image = 1
				second_slot_sprite:setImage(images_array[1])
			elseif roll_status == RollStatus.Diamonds then
				second_slot_image = 4
				second_slot_sprite:setImage(images_array[4]) 
			elseif roll_status == RollStatus.Eyes then -- 3 Eyes
				second_slot_image = 3
				second_slot_sprite:setImage(images_array[3])
			elseif roll_status == RollStatus.ThreeCherries then
				second_slot_image = 2
				second_slot_sprite:setImage(images_array[2])
			elseif roll_status == RollStatus.TwoCherries then
				second_slot_image = 2
				second_slot_sprite:setImage(images_array[2])
			elseif roll_status == RollStatus.OneCherry then
				-- This cannot be a cherry
				-- Need to select a random number, but it can't be 2 
				local random_image_num = random_image_number()
				second_slot_sprite:setImage(images_array[random_image_num])
				second_slot_image = random_image_num
			else 
				-- This probably could be any image...maybe do that, allow any option
				local random_image_num = random_image_number()
				second_slot_sprite:setImage(images_array[random_image_num])
				second_slot_image = random_image_num
			end 
		end
		
		-- Assume that the third slot is still spinning here
		third_slot_sprite:setImage(images_array[third_image]) 
		third_slot_image = third_image
		
		if rotations == thirdSlotRotations then
			if (roll_status == RollStatus.Death) then -- Death
				third_slot_sprite:setImage(images_array[1])
			elseif roll_status == RollStatus.Diamonds then -- 3 Diamonds
				third_slot_sprite:setImage(images_array[4]) 
			elseif roll_status == RollStatus.Eyes then -- 3 Eyes
				third_slot_sprite:setImage(images_array[3])
			elseif roll_status == RollStatus.ThreeCherries then
				third_slot_sprite:setImage(images_array[2])
			elseif (roll_status == RollStatus.TwoCherries) or (roll_status == RollStatus.OneCherry) then
				 local random_image_num = random_image_number()
				 -- This cannot be a cherry
				 -- Need to select a random number, but it can't be 2 
				 third_slot_image = random_image_num
				 
				 -- I think this logic is correct, I just need to ensure that first_slot_image and
				 -- second_slot_image are getting set for all cases.  Perhaps all of these values 
				 -- should be determined at the start of the spin...
				if (first_slot_image == second_slot_image) and (second_slot_image == third_slot_image) then
					third_slot_image = random_image_number(second_slot_image)
					print("LOST! All three images were the same: " .. second_slot_image)
				end
				 
				third_slot_sprite:setImage(images_array[third_slot_image])
			else -- Lost 
				local random_image_num = random_image_number()
				 third_slot_image = random_image_num 
				 
				 if (first_slot_image == second_slot_image) and (second_slot_image == third_slot_image) then
					 third_slot_image = random_image_number(second_slot_image)
					 print("LOST! All three images were the same: " .. second_slot_image)
				 end
				  
				 third_slot_sprite:setImage(images_array[third_slot_image])
			end
		end 
		
		playBlipSound()
	else
	
		is_currently_spinning = false 
		local winnings = 0
		
		if (roll < 3) then 
			money = -1
			spinMessage = "You lose, homeboy!"
			-- playSound66()
			
			-- TODO: Display the laser and play the appropriate sound
			-- Then transition to the EndGameScene 
			
			Noble.GameData.Status = GameStatus.Death
			Noble.transition(EndGameScene, 1, Noble.TransitionType.CROSS_DISSOLVE)
			
		elseif roll < (5 + handicap) then
			print("You got 3 diamonds")
			winnings = 20 * currentBet
			money = money + winnings
		elseif roll < (7 + handicap) then
			print("The Eyes have it")
			winnings = 10 * currentBet
			money = money + winnings
		elseif roll < (11 + handicap) then
			print("3 cherries")
			winnings = 5 * currentBet
			money = money + winnings
		elseif roll < (18 + handicap) then
			print("2 cherries")
			winnings = 3 * currentBet
			money = money + winnings
		elseif roll < (34 + handicap) then
			print("1 cherry")
			winnings = 1 * currentBet
			money = money + winnings
		else
			--- print("You won NOTHING!  Good-day, sir!")
			msgNum = math.random(1, 7)
			spinMessage = youLostMessages[msgNum]
			print(youLostMessages[msgNum])
			playYouLostSound()
			
			if (money <= 0) then
				Noble.GameData.Status = GameStatus.Broke
				Noble.transition(EndGameScene, 1, Noble.TransitionType.CROSS_DISSOLVE)
			end
			
		end
		
		if winnings > 0 then
			-- The * are to create bold text
			spinMessage = "*You won $" .. winnings .. "*"
			playSound26()
			
			if (money >= 250) then
				Noble.GameData.Status = GameStatus.Won
				Noble.transition(EndGameScene, 1, Noble.TransitionType.CROSS_DISSOLVE)
			end
		end
	
	end

end

function playBlipSound()
	-- playBlipSoundMP3() -- too slow
	-- playBlipSoundWAV() -- also too slow
	playBlipSoundMIDI() -- this is way too fast
end

function playBlipSoundMP3()
	blipMP3Player:setFinishCallback(blipSoundFinished)
	blipMP3Player:play()
end

function playBlipSoundWAV()
	-- samplePlayer
	blipWAVPlayer:setFinishCallback(blipSoundFinished)
	blipWAVPlayer:play()
end

function playBlipSoundMIDI()
	-- stopAllSounds()
	
	local track1 = blipSound:getTrackAtIndex(1) -- May have to start at #2, experiment
	local track2 = blipSound:getTrackAtIndex(2)
	local track3 = blipSound:getTrackAtIndex(3) 
	
	-- scenes/GameScene.lua:276: synths may only be in one instrument or channel at a time
	local blipSynthPlayer = synthPlayer:copy()
	-- Lower the volume of the blip sound
	blipSynthPlayer:setVolume(0.3)
	
	track1:setInstrument(blipSynthPlayer:copy())
	track2:setInstrument(blipSynthPlayer:copy())
	track3:setInstrument(blipSynthPlayer:copy())
	blipSound:setTrackAtIndex(1, track1)
	blipSound:setTrackAtIndex(2, track2)
	blipSound:setTrackAtIndex(3, track3)
	-- Initially set tp 200, but seemed too fast vs the WAV and MP3 version, which were too slow
	-- Adjusting the tempo seems to have helped.  50 seems like a good balance which isn't too
	-- fast nor too slow.  Trying to set the rate of other file types also adjusted the pitch.
	-- Note: As the slots are finishing, perhaps even slow down this tempo...just a thought.
	blipSound:setTempo(50) 
	
	blipSound:play(blipSoundFinished)
end

function blipSoundFinished()
	-- print("Blip sound finished")
	continueSpinning()
end

function playSound26()
	-- stopAllSounds()
	
	local sound26 = snd.sequence.new('sounds/Sound26.mid')
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

-- Did not win this round sound
function playYouLostSound()
	local mp3Player = snd.fileplayer.new("sounds/Sound27")
	local currentVolume = mp3Player:getVolume()
	-- The volume for this sound is much quieter than other sounds.  Possible to increase in code?
	print("Current mp3Player volume: " .. currentVolume)
	mp3Player:play()
end

-- Death sound
function playSound66()
	-- stopAllSounds()
	
	local sound66 = snd.sequence.new('sounds/Sound66.mid')
	local track1 = sound66:getTrackAtIndex(1)
	local track2 = sound66:getTrackAtIndex(2)
	local track3 = sound66:getTrackAtIndex(3) 
	
	-- This is how I've found that a sequence's volume can be changed
	local synthPlayer66 = snd.synth.new(snd.kWaveSquare)
	synthPlayer66:setVolume(0.5)
	
	track1:setInstrument(synthPlayer66:copy())
	track2:setInstrument(synthPlayer66:copy())
	track3:setInstrument(synthPlayer66:copy())
	sound66:setTrackAtIndex(1, track1)
	sound66:setTrackAtIndex(2, track2)
	sound66:setTrackAtIndex(3, track3)
	-- Is there a way to set the volume, some of these are kind of loud
	sound66:setTempo(200)
	
	sound66:play()
end

function gameDifficulty()
	local gameDiff = Noble.Settings.get("Difficulty")
	
	if (gameDiff == "Easy") then
		return 2
	elseif (gameDiff == "Medium") then
		return 1
	else -- For Hard or unknown cases
		return 0
	end
end

function handicap()
	local difficulty = gameDifficulty()
	-- return (difficulty - 1) * 5 -- That was a major calculation error making the game more challenging! 
	return difficulty * 5
end