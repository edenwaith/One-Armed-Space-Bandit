GameScene = {}
class("GameScene").extends(NobleScene)
local scene = GameScene

scene.baseColor = Graphics.kColorBlack

-- local background
-- local logo
-- local menu
local gfx <const> = playdate.graphics
local snd <const> = playdate.sound
local sequence
local money = 30
local currentBet = 1
local difficulty = 1 -- 1 is hard, 2 is medium, 3 is easy
local handicap = (difficulty - 1) * 5
local youLostMessages = {"You Lose", "Tough Luck", "It's Hopeless", "Eat Sand", "Suck Methane", "So Sorry", "Not A Chance"}
local spinMessage = ""

function scene:init()
	scene.super.init(self)

	-- Trying to reference "os" causes a crash, doesn't know what "os" is 
	-- math.randomseed(os.time()) -- initially seed the random number generator

	-- The Playdate dev docs recommend this to seed the random number generator
	-- https://sdk.play.date/2.3.1/Inside%20Playdate.html#f-getSecondsSinceEpoch
	math.randomseed(playdate.getSecondsSinceEpoch())

	-- background = Graphics.image.new("assets/images/background2")
	-- logo = Graphics.image.new("libraries/noble/assets/images/NobleRobotLogo")

	-- local backgroundImage = gfx.image.new( "images/RoomAbkg" )
	-- assert( backgroundImage )
	-- 
	-- gfx.sprite.setBackgroundDrawingCallback(
	-- 	function( x, y, width, height )
	-- 		-- x,y,width,height is the updated area in sprite-local coordinates
	-- 		-- The clip rect is already set to this area, so we don't need to set it ourselves
	-- 		backgroundImage:draw( 0, 0 )
	-- 	end
	-- )

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
		upButtonUp = function()
			if currentBet < 3 then
				currentBet = currentBet + 1
			end
		end,
		downButtonUp = function()
			if currentBet > 1 then
				currentBet = currentBet - 1
			end
		end,
		AButtonDown = spin,
		BButtonDown = function()
			-- Go back to the previous screen
			Noble.transition(TitleScene, 1, Noble.TransitionType.SLIDE_OFF_DOWN)
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

	-- menu:activate()
	-- Noble.Input.setCrankIndicatorStatus(true)

end

function scene:drawBackground()
	scene.super.drawBackground(self)

	-- background:draw(0, 0)
	
	  -- Set the background image
	local backgroundImage = gfx.image.new( "images/RoomAbkg" )
	assert( backgroundImage )
	
	backgroundImage:draw( 0, 0 )
	
	-- gfx.sprite.setBackgroundDrawingCallback(
	-- 	function( x, y, width, height )
  	--   		backgroundImage:draw( 0, 0 )
	-- 	end
	-- )
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
	
	Graphics.setColor(Graphics.kColorBlack)
	Graphics.fillRect(0, 215, 400, 25)
-- 	
 	Graphics.setColor(Graphics.kColorWhite)
-- 
-- 	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillWhite)
	Graphics.setImageDrawMode(gfx.kDrawModeFillWhite) -- this causes the background image to disappear.
	local winnings = "You have $" .. money -- Concatenate the string with the money value
	Noble.Text.draw(winnings, 15, 4, Noble.Text.ALIGN_LEFT)
 	
	local bet = "You bet $" .. currentBet
	Noble.Text.draw(bet, 300, 4, Noble.Text.ALIGN_LEFT)
	
	Noble.Text.draw(spinMessage, 200, 219, Noble.Text.ALIGN_CENTER)
	
	Graphics.setImageDrawMode(gfx.kDrawModeCopy ) -- Call this so the background is visible and isn't just a white screen
	
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

function spin()
	print("Spin me right round")
	
	local firstSlotRotations = math.random(10, 23)
	local secondSlotRotations = math.random(26, 38)
	local thirdSlotRotations = math.random(42, 53)
	
	print("Slot rotations are 1: " .. firstSlotRotations .. " 2: " .. secondSlotRotations .. " 3: " .. thirdSlotRotations)
	
	local roll = math.random(1, 100)
	-- turns = turns + 1
	money = money - currentBet -- Money for the turn 
	
	print("You have $" .. money)
	print("The roll was " .. roll)
	
	local winnings = 0
	
	if roll < 3 then 
		money = -1
		spinMessage = "You lose, homeboy!"
		playSound66()
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
		local mp3Player = snd.fileplayer.new("sounds/Sound27")
		mp3Player:play()
	end
	
	if winnings > 0 then
		spinMessage = "You won $" .. winnings
		playSound26()
	end

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

function playSound66()
	-- stopAllSounds()
	
	local sound66 = snd.sequence.new('sounds/Sound66.mid')
	local track1 = sound66:getTrackAtIndex(1)
	local track2 = sound66:getTrackAtIndex(2)
	local track3 = sound66:getTrackAtIndex(3) 
	
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