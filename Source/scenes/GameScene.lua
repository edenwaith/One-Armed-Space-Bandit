GameScene = {}
class("GameScene").extends(NobleScene)
local scene = GameScene

scene.baseColor = Graphics.kColorBlack

local gfx <const> = playdate.graphics
local snd <const> = playdate.sound
local sequence -- probably can get rid of this: TODO: Clean up
-- local money = 30 -- Replaced by Noble.GameData.Money
-- NOTE: Lua uses snake case to name variables and methods
-- local Noble.GameData.Bet = 1
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
local blipMP3Player = snd.fileplayer.new("sounds/Sound25")
local blipWAVPlayer = snd.sampleplayer.new("sounds/Sound25.wav")

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
		leftButtonUp = function()
			print("Left button up")
			-- Simulate win state
			Noble.GameData.Status = GameStatus.Won
			Noble.transition(EndGameScene, 1, Noble.TransitionType.CROSS_DISSOLVE)
		end, 
		-- rightButtonHold = function()
		-- 	print("You're broke!")
		-- 	Noble.GameData.Status = GameStatus.Broke 
		-- 	Noble.transition(EndGameScene, 1, Noble.TransitionType.SLIDE_OFF_DOWN)
		-- end,
		rightButtonUp = function()
			print("Right button up")
			-- Simulate death state 
			spinMessage = "*You lose, homeboy!*"
			playLaserSound()
			-- Noble.GameData.Status = GameStatus.Death
			-- Noble.transition(EndGameScene, 1, Noble.TransitionType.CROSS_DISSOLVE)
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
	
	-- Might only need to set this if the player isn't already playing
	-- Or have some other option to continue an existing game
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

end

function scene:drawBackground()
	scene.super.drawBackground(self)

	  -- Set the background image
	local backgroundImage = gfx.image.new( "images/Slots-Background" ) -- RoomAbkg
	-- Crash: scenes/GameScene.lua:133: attempt to index a nil value (local 'backgroundImage')
	assert( backgroundImage )
	
	backgroundImage:draw(0, 0)
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

	local winnings = "*You have $" .. Noble.GameData.Money .. "*" -- Concatenate the string with the money value
	Noble.Text.draw(winnings, 15, 4, Noble.Text.ALIGN_LEFT)
 	
	local bet = "*You bet $" .. Noble.GameData.Bet .. "*"
	Noble.Text.draw(bet, 300, 4, Noble.Text.ALIGN_LEFT)
	
	Noble.Text.draw(spinMessage, 200, 219, Noble.Text.ALIGN_CENTER)
	
	updateSquares()
	
	-- Only checking is_currently_spinning is not correct.
	-- There was also a crash when continuing an existing game, so roll_status may not have been set or saved
	-- if (is_currently_spinning == false and roll_status < 8 and roll_status ~= RollStatus.Lost) then
	-- 	updateAnimationLoops()
	-- end
	
	
	Graphics.setImageDrawMode(gfx.kDrawModeCopy ) -- Call this so the background is visible and isn't just a white screen
	
end

-- This resulted in the following crash
-- CoreLibs/animation.lua:183: attempt to index a number value (local 'self')
-- stack traceback:
-- 	CoreLibs/animation.lua:183: in field 'draw'
-- 	scenes/GameScene.lua:301: in function 'updateAnimationLoops'
-- 	scenes/GameScene.lua:290: in method 'update'
-- 	libraries/noble/Noble.lua:433: in function <libraries/noble/Noble.lua:425>
function updateAnimationLoops()
	print("updateAnimationLoops: " .. roll_status)
	gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
	-- Not prefer, still might just want to make use of the existing sprites and load the animations there.
	if firstSlotAnimationLoop ~= nil then
		firstSlotAnimationLoop:draw(70, 100)
	end
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
	
	if (Noble.GameData.Bet > Noble.GameData.Money) then
		-- NOTE: If Money is -1, then the player should already be dead.  A bug.
		is_currently_spinning = false 
		spinMessage = "Sorry, you don't have enough to bet that much."
	else
	
		roll = 1 -- math.random(1, 100)
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
		
		-- turns = turns + 1
		Noble.GameData.Money -= Noble.GameData.Bet -- Money for the turn 
		
		print("You have $" .. Noble.GameData.Money)
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
	
		local winnings = 0
		local frameTime = 200 -- Experimental value of 200ms per frame
		
		-- FIXME: Why is this checking the roll instead of the roll_status?!
		if (roll < 3) then -- Death
			Noble.GameData.Money = -1
			spinMessage = "*You lose, homeboy!*"
			
			firstSlotAnimationLoop  = gfx.animation.loop.new(frameTime, skullsImageTable, true)
			secondSlotAnimationLoop = gfx.animation.loop.new(frameTime, laserImageTable, false)
			thirdSlotAnimationLoop  = gfx.animation.loop.new(frameTime, skullsImageTable, true)
			
			setupFirstSlotAnimation()
			setupSecondSlotAnimation() -- For this case, do not keep looping
			-- setupLaserAnimation()
			setupThirdSlotAnimation()
			
			-- Wait one second for the animation, then play the song
			-- playLaserSound()
			
			-- Wait 1 second (1000ms) then play the laser sound to give enough time for the animation to complete
			laserSoundTimer = playdate.timer 
			laserSoundTimer.performAfterDelay(1000, playLaserSound)
			
		elseif roll < (5 + math.floor(handicap/2)) then
			print("You got 3 diamonds")
			firstSlotAnimationLoop  = gfx.animation.loop.new(frameTime, diamondsImageTable, true)
			secondSlotAnimationLoop = gfx.animation.loop.new(frameTime, diamondsImageTable, true)
			thirdSlotAnimationLoop  = gfx.animation.loop.new(frameTime, diamondsImageTable, true)
			
			winnings = 20 * Noble.GameData.Bet
			Noble.GameData.Money += winnings
		elseif roll < (7 + handicap) then -- 3 Eyes
			print("The Eyes have it")
	
			firstSlotAnimationLoop  = gfx.animation.loop.new(frameTime, eyesImageTable, true)
			secondSlotAnimationLoop = gfx.animation.loop.new(frameTime, eyesImageTable, true)
			thirdSlotAnimationLoop  = gfx.animation.loop.new(frameTime, eyesImageTable, true)
			
			winnings = 10 * Noble.GameData.Bet
			Noble.GameData.Money += winnings
		elseif roll < (11 + handicap) then -- 3 Cherries 
			print("3 cherries")
			-- cherriesImageTable
			
			firstSlotAnimationLoop  = gfx.animation.loop.new(frameTime, cherriesImageTable, true)
			secondSlotAnimationLoop = gfx.animation.loop.new(frameTime, cherriesImageTable, true)
			thirdSlotAnimationLoop  = gfx.animation.loop.new(frameTime, cherriesImageTable, true)
			 
			winnings = 5 * Noble.GameData.Bet
			Noble.GameData.Money += winnings
		elseif roll < (18 + handicap) then -- 2 Cherries
			print("2 cherries")
			firstSlotAnimationLoop  = gfx.animation.loop.new(frameTime, cherriesImageTable, true)
			secondSlotAnimationLoop = gfx.animation.loop.new(frameTime, cherriesImageTable, true)
			winnings = 3 * Noble.GameData.Bet
			Noble.GameData.Money += winnings
		elseif roll < (34 + handicap) then -- 1 Cherry
			print("1 cherry")
			firstSlotAnimationLoop = gfx.animation.loop.new(frameTime, cherriesImageTable, true)
			winnings = 1 * Noble.GameData.Bet
			Noble.GameData.Money += winnings
		else
			msgNum = math.random(1, 7)
			spinMessage = youLostMessages[msgNum]
			print(youLostMessages[msgNum])
			playYouLostSound()
			
			if (Noble.GameData.Money <= 0) then
				Noble.GameData.Status = GameStatus.Broke
				Noble.transition(EndGameScene, 1, Noble.TransitionType.CROSS_DISSOLVE)
			end
			
		end
		
		if winnings > 0 then
			-- The * are to create bold text
			spinMessage = "*You won $" .. winnings .. "*"
			print("spinMessage: " .. spinMessage)
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
			
			
			-- TODO: Need to move this into the winSoundFinished method
			-- if (Noble.GameData.Money >= 250) then
			-- 	Noble.GameData.Status = GameStatus.Won
			-- 	Noble.transition(EndGameScene, 1, Noble.TransitionType.CROSS_DISSOLVE)
			-- end
		end
	
	end

end

function setupFirstSlotAnimation()
	first_slot_sprite.update = function()
		first_slot_sprite:setImage(firstSlotAnimationLoop:image())
		-- Optionally, removing the sprite when the animation finished
		-- if not firstSlotAnimationLoop:isValid() then
		-- 	first_slot_sprite:remove()
		-- end
	end
end 

function setupSecondSlotAnimation() 
	second_slot_sprite.update = function()
		second_slot_sprite:setImage(secondSlotAnimationLoop:image())
		-- Optionally, removing the sprite when the animation finished
		-- if not secondSlotAnimationLoop:isValid() then
		-- 	second_slot_sprite:remove()
		-- end
	end
end 

function setupThirdSlotAnimation()
	third_slot_sprite.update = function()
		third_slot_sprite:setImage(thirdSlotAnimationLoop:image())
		-- Optionally, removing the sprite when the animation finished
		-- if not thirdSlotAnimationLoop:isValid() then
		-- 	third_slot_sprite:remove()
		-- end
	end
end 

function setupLaserAnimation() 
	print("Entering setupLaserAnimation")
	second_slot_sprite.update = function()
		second_slot_sprite:setImage(secondSlotAnimationLoop:image())
		
		-- Is there a better way to detect once the animation has completed?
		if not secondSlotAnimationLoop:isValid() then
			-- Note: This will repeat a bunch of times.
			-- print("Trying to play the laser sound now")
			-- Once the animation has completed, start the laser sound
			-- playLaserSound()
			-- second_slot_sprite:remove()
			-- Perhaps remove this animation sprite, then change second_slot_sprite to the last frame
			-- then play the laser sound
				
			second_slot_sprite:setImage(laserBeamImage) 
			second_slot_sprite.update = nil 
			playLaserSound()
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

function playWinSound()
	-- stopAllSounds() -- Why is this commented out?
	print("playWinSound")
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
	print("winSoundFinished")
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
	mp3Player:play() -- How to set a callback when finished?
end

function playLaserSound()
	
	laserSoundTimer:remove()
	
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
	print("laserSoundFinished")
	Noble.GameData.Status = GameStatus.Death
	Noble.transition(EndGameScene, 1, Noble.TransitionType.CROSS_DISSOLVE)
	
	is_currently_spinning = false
end 

function lostSoundFinished()
	print("lostSoundFinished")
	is_currently_spinning = false 
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