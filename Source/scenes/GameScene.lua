GameScene = {}
class("GameScene").extends(NobleScene)
local scene = GameScene

scene.baseColor = Graphics.kColorBlack

local gfx <const> = playdate.graphics
local snd <const> = playdate.sound

-- NOTE: Lua uses snake case to name variables and methods
local crankTick = 0
local is_crank_starting = false
local is_currently_spinning = false 

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
local laserBeamImage = gfx.image.new("images/laser-table-6")

local images_array = {skull_image, cherry_image, eye_image, diamond_image}

-- Order of the images rotating:
-- Skull, cherry, diamond, eye

-- Sprite Varaibles
local first_slot_sprite = gfx.sprite.new(images_array[3])
local second_slot_sprite = gfx.sprite.new(images_array[2])
local third_slot_sprite = gfx.sprite.new(images_array[4])

local cherriesImageTable = gfx.imagetable.new("images/cherries")
local diamondsImageTable = gfx.imagetable.new("images/diamond")
local eyesImageTable = gfx.imagetable.new("images/eye")
local skullsImageTable = gfx.imagetable.new("images/skull")
local laserImageTable = gfx.imagetable.new("images/laser")

local firstSlotAnimationLoop
local secondSlotAnimationLoop
local thirdSlotAnimationLoop

-- Sound variables
local synthPlayer = snd.synth.new(snd.kWaveSquare)
local blipSound = snd.sequence.new('sounds/sound25.mid')

local laserSoundTimer

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

	-- The Playdate dev docs recommend this to seed the random number generator
	-- https://sdk.play.date/2.3.1/Inside%20Playdate.html#f-getSecondsSinceEpoch
	-- When I leave the scene and come back, the roll seems to be the same value
	-- This can create an exploit where the user comes in, wins, leaves, then comes
	-- back to win again.  Is this randomization enough?
	math.randomseed(playdate.getSecondsSinceEpoch())

	scene.inputHandler = {
		
		cranked = function(change, acceleratedChange)
			
			crankTick = crankTick + change
			
			local crank_position = playdate.getCrankPosition()
			
			if (crank_position < 360 and crank_position > 350 and is_crank_starting == false) then
				is_crank_starting = true
			end
			
			-- One can also crank the "wrong" direction and trigger this.
			-- Might need to just calculate the change
			-- If the crank position is top, its value will be around 360 or 0.
			-- Pulling down will have a value going from 360 and down to 180
			-- when the crank is pointing down.
			if (crank_position < 190 and crank_position > 170 and is_crank_starting == true) then
				is_crank_starting = false
				crankTick = 0
				spin()
			end

		end,
		
		upButtonUp = function()
			
			if is_currently_spinning == false then
				if Noble.GameData.Bet < 3 then
					Noble.GameData.Bet += 1
				end
			end
		end,
		
		downButtonUp = function()
			if is_currently_spinning == false then
				if Noble.GameData.Bet > 1 then
					Noble.GameData.Bet -= 1
				end
			end
		end,
	
		AButtonDown = spin,
		
		BButtonDown = function()
			if is_currently_spinning == false then
				-- Go back to the previous screen
				Noble.transition(TitleScene, 1, Noble.TransitionType.SLIDE_OFF_DOWN) 
			end
		end
	}

end

function scene:enter()
	scene.super.enter(self)
	
	if Noble.GameData.Status == GameStatus.New then
		-- Idea: Perhaps adjust the initial amount of $ to differ based on difficulty level
		Noble.GameData.Money = 30
		roll_status = RollStatus.NotPlaying
		spinMessage =  "*Press* Ⓐ *or pull the crank down to spin*"
		
		-- Set the initial images when starting
		first_slot_image = math.random(1, 4)
		first_slot_sprite:setImage(images_array[first_slot_image]) 
		first_slot_sprite.update = nil 
		second_slot_image = math.random(1, 4)
		second_slot_sprite:setImage(images_array[second_slot_image]) 
		second_slot_sprite.update = nil
		third_slot_image = math.random(1, 4)
		third_slot_sprite:setImage(images_array[third_slot_image]) 
		third_slot_sprite.update = nil 
	end 
	
	Noble.GameData.Status = GameStatus.Playing
	
end

function scene:start()
	scene.super.start(self)

	local difficulty = Noble.Settings.get("Difficulty")
	rollStatus = RollStatus.NotPlaying
	
	first_slot_sprite:moveTo(90, 120)
	first_slot_sprite:add()
	
	second_slot_sprite:moveTo(200, 120)
	second_slot_sprite:add()
	
	third_slot_sprite:moveTo(308, 120)
	third_slot_sprite:add()
end

function scene:drawBackground()
	scene.super.drawBackground(self)

	  -- Set the background image
	local backgroundImage = gfx.image.new( "images/Slots-Background" ) -- RoomAbkg
	
	assert( backgroundImage )
	
	backgroundImage:draw(0, 0)
end


function scene:update()
	scene.super.update(self)
	
	Graphics.setColor(Graphics.kColorBlack)
	Graphics.fillRect(0, 0, 400, 25)
	
	-- Dark black bar at bottom of the screen
	Graphics.fillRect(0, 215, 400, 25)
 	Graphics.setColor(Graphics.kColorWhite)
	Graphics.setImageDrawMode(gfx.kDrawModeFillWhite) -- this causes the background image to disappear.

	local winnings = "*You have $" .. Noble.GameData.Money .. "*" -- Concatenate the string with the money value
	Noble.Text.draw(winnings, 15, 4, Noble.Text.ALIGN_LEFT)
 	
	local bet = "*You bet $" .. Noble.GameData.Bet .. "*"
	Noble.Text.draw(bet, 300, 4, Noble.Text.ALIGN_LEFT)
	
	Noble.Text.draw(spinMessage, 200, 219, Noble.Text.ALIGN_CENTER)
	
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
	
	Graphics.fillRect(86, 55, 8, 8)
	
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
	Graphics.fillRect(196, 55, 8, 8)
	
	if rotations < thirdSlotRotations then
		
		if modVal == 1 then
			Graphics.setColor(Graphics.kColorWhite)
		else
			Graphics.setColor(Graphics.kColorBlack)
		end
	
	else 
		Graphics.setColor(Graphics.kColorWhite)
	end	
	
	Graphics.fillRect(305, 55, 8, 8)

end

function scene:exit()
	scene.super.exit(self)

	-- Need to clear out the sprites, otherwise they remain on the screen
	first_slot_sprite:remove()
	second_slot_sprite:remove()
	third_slot_sprite:remove()
	
	if laserSoundTimer ~= nil then 
		laserSoundTimer:remove()
	end

end

function scene:finish()
	scene.super.finish(self)
end

function spin()
		
	if is_currently_spinning == true then 
		return 
	else 
		is_currently_spinning = true
	end 
	
	spinMessage = "" -- Reset this message on a new spin
	
	if (Noble.GameData.Bet > Noble.GameData.Money) then
		-- NOTE: If Money is -1, then the player should already be dead. 
		is_currently_spinning = false 
		spinMessage = "Sorry, you don't have enough to bet that much."
	else

		roll = math.random(1, 100)
		local handicap = handicap()
		
		if (roll < 3) then  -- Death
			roll_status = RollStatus.Death
		elseif roll < (5 + math.floor(handicap/2)) then -- 3 Diamonds
			-- The handicap is reduced since it resulted in too many 3 Diamonds and 
			-- very few 3 eyes
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
		
		Noble.GameData.Money -= Noble.GameData.Bet -- Money for the turn 
		
		rotations = 0
		firstSlotRotations = math.random(5, 11) -- initially 10 to 23
		secondSlotRotations = math.random(13, 19) -- initially 26 to 38
		thirdSlotRotations = math.random(21, 26) -- initially 42 to 53

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
	
	rotations = rotations + 1
	local modVal = rotations % 4 + 1 -- Need to ensure it is never zero
	local first_image = (rotations + first_slot_image) % 4 + 1
	local second_image = (rotations + second_slot_image) % 4 + 1
	local third_image = (rotations + third_slot_image) % 4 + 1
	local handicap = handicap()
	
	if rotations <= thirdSlotRotations then
		
		-- Need to update the UI here
		if rotations < firstSlotRotations then
			
			first_slot_sprite:setImage(images_array[first_image]) 
			first_slot_sprite.update = nil -- Clear out animations
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
			second_slot_sprite.update = nil -- Clear out animations
			second_slot_image = second_image 
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
		third_slot_sprite.update = nil -- Clear out animations
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
				 
				if (first_slot_image == second_slot_image) and (second_slot_image == third_slot_image) then
					third_slot_image = random_image_number(second_slot_image)
				end
				 
				third_slot_sprite:setImage(images_array[third_slot_image])
			else -- Lost 
				local random_image_num = random_image_number()
				 third_slot_image = random_image_num 
				 
				 if (first_slot_image == second_slot_image) and (second_slot_image == third_slot_image) then
					 third_slot_image = random_image_number(second_slot_image)
				 end
				  
				 third_slot_sprite:setImage(images_array[third_slot_image])
			end
		end 
		
		playBlipSound()
	else
	
		local winnings = 0
		local frameTime = 200 -- Experimental value of 200ms per frame
		
		if (roll < 3) then -- Death
			Noble.GameData.Money = -1
			spinMessage = "*You lose, homeboy!*"
			
			firstSlotAnimationLoop  = gfx.animation.loop.new(frameTime, skullsImageTable, true)
			secondSlotAnimationLoop = gfx.animation.loop.new(frameTime, laserImageTable, false)
			thirdSlotAnimationLoop  = gfx.animation.loop.new(frameTime, skullsImageTable, true)
			
			setupFirstSlotAnimation()
			setupSecondSlotAnimation() -- For this case, do not keep looping
			setupThirdSlotAnimation()
			
			-- Play the lost sound, and the laser timer will start about a second later
			playYouLostSound()
			
			-- Wait 1 second (1000ms) then play the laser sound to give enough time for the animation to complete
			laserSoundTimer = playdate.timer 
			laserSoundTimer.performAfterDelay(1000, playLaserSound)
			
		elseif roll < (5 + math.floor(handicap/2)) then
			
			firstSlotAnimationLoop  = gfx.animation.loop.new(frameTime, diamondsImageTable, true)
			secondSlotAnimationLoop = gfx.animation.loop.new(frameTime, diamondsImageTable, true)
			thirdSlotAnimationLoop  = gfx.animation.loop.new(frameTime, diamondsImageTable, true)
			
			winnings = 20 * Noble.GameData.Bet
			Noble.GameData.Money += winnings
			
		elseif roll < (7 + handicap) then -- 3 Eyes
	
			firstSlotAnimationLoop  = gfx.animation.loop.new(frameTime, eyesImageTable, true)
			secondSlotAnimationLoop = gfx.animation.loop.new(frameTime, eyesImageTable, true)
			thirdSlotAnimationLoop  = gfx.animation.loop.new(frameTime, eyesImageTable, true)
			
			winnings = 10 * Noble.GameData.Bet
			Noble.GameData.Money += winnings
			
		elseif roll < (11 + handicap) then -- 3 Cherries 
			
			firstSlotAnimationLoop  = gfx.animation.loop.new(frameTime, cherriesImageTable, true)
			secondSlotAnimationLoop = gfx.animation.loop.new(frameTime, cherriesImageTable, true)
			thirdSlotAnimationLoop  = gfx.animation.loop.new(frameTime, cherriesImageTable, true)
			 
			winnings = 5 * Noble.GameData.Bet
			Noble.GameData.Money += winnings
			
		elseif roll < (18 + handicap) then -- 2 Cherries
			
			firstSlotAnimationLoop  = gfx.animation.loop.new(frameTime, cherriesImageTable, true)
			secondSlotAnimationLoop = gfx.animation.loop.new(frameTime, cherriesImageTable, true)
			winnings = 3 * Noble.GameData.Bet
			Noble.GameData.Money += winnings
			
		elseif roll < (34 + handicap) then -- 1 Cherry
			
			firstSlotAnimationLoop = gfx.animation.loop.new(frameTime, cherriesImageTable, true)
			winnings = 1 * Noble.GameData.Bet
			Noble.GameData.Money += winnings
			
		else
			
			msgNum = math.random(1, 7)
			spinMessage = youLostMessages[msgNum]
			
			playYouLostSound()
			
			if (Noble.GameData.Money <= 0) then
				Noble.GameData.Status = GameStatus.Broke
				Noble.transition(EndGameScene, 1, Noble.TransitionType.CROSS_DISSOLVE)
			end
			
		end
		
		if winnings > 0 then
			-- The * are to create bold text
			spinMessage = "*You won $" .. winnings .. "*"
			
			playWinSound()
			setupFirstSlotAnimation()
			
			-- May not need to check if the Lost status since this should only be winning states
			if roll_status < 8 and roll_status ~= RollStatus.Lost then 
				
				if roll_status ~= RollStatus.OneCherry then
					setupSecondSlotAnimation()
				end 
				
				-- Any other states other than winning one or two cherries will animate
				-- all three slots
				if roll_status ~= RollStatus.OneCherry and roll_status ~= RollStatus.TwoCherries then
					setupThirdSlotAnimation()
				end 
			end 
			
		end
	
	end

end

function setupFirstSlotAnimation()
	first_slot_sprite.update = function()
		first_slot_sprite:setImage(firstSlotAnimationLoop:image())
	end
end 

function setupSecondSlotAnimation() 
	second_slot_sprite.update = function()
		second_slot_sprite:setImage(secondSlotAnimationLoop:image())
	end
end 

function setupThirdSlotAnimation()
	third_slot_sprite.update = function()
		third_slot_sprite:setImage(thirdSlotAnimationLoop:image())
	end
end 

function playBlipSound()
	playBlipSoundMIDI()
end

function playBlipSoundMIDI()
	
	local track1 = blipSound:getTrackAtIndex(1) -- May have to start at #2, experiment
	local track2 = blipSound:getTrackAtIndex(2)
	local track3 = blipSound:getTrackAtIndex(3) 
	
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
	continueSpinning()
end

function playWinSound()

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
	
	sound26:play(winSoundFinished)
end

function winSoundFinished()

	is_currently_spinning = false 
	
	if (Noble.GameData.Money >= 250) then
		Noble.GameData.Status = GameStatus.Won
		Noble.transition(EndGameScene, 1, Noble.TransitionType.CROSS_DISSOLVE)
	end
end

-- Did not win this round sound
function playYouLostSound()
	local mp3Player = snd.fileplayer.new("sounds/YouLost-Even-Shorter")
	mp3Player:setFinishCallback(lostSoundFinished)
	mp3Player:play()
end

function playLaserSound()
	
	if laserSoundTimer ~= nil then
		laserSoundTimer:remove()
	end
	
	local laserSound = snd.sequence.new('sounds/Sound28.mid')
	local track1 = laserSound:getTrackAtIndex(1)
	local track2 = laserSound:getTrackAtIndex(2)
	local track3 = laserSound:getTrackAtIndex(3)
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	track3:setInstrument(synthPlayer:copy())
	
	laserSound:setTrackAtIndex(1, track1)
	laserSound:setTrackAtIndex(2, track2)
	laserSound:setTrackAtIndex(3, track3)
	
	laserSound:setTempo(100)
	
	laserSound:play(laserSoundFinished)
end

function laserSoundFinished()

	Noble.GameData.Status = GameStatus.Death
	Noble.transition(EndGameScene, 1, Noble.TransitionType.CROSS_DISSOLVE)
	
	is_currently_spinning = false
end 

function lostSoundFinished()
	-- Except for the Death roll, reset is_currently_spinning
	if roll_status ~= RollStatus.Death then
		is_currently_spinning = false 
	end
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
	-- The handicap is determined by multiplying the game difficulty by 5
	-- Easy:   2 * 5 = 10
	-- Medium: 1 * 5 = 5
	-- Hard:   0 * 5 = 0
	return difficulty * 5
end