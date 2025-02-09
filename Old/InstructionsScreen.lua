class("InstructionsScreen").extends(Room)

local scoreSprite

function InstructionsScreen:enter(previous, ...)
	-- set up the level
	
	playdate.graphics.drawText("Press A or B to play sounds", 95, 100)
	print("Entering InstructionsScreen")
	
	-- gfx.sprite.removeAll()
	
	-- sierraFont = gfx.font.new('fonts/Sierra-AGI-Basic-Latin-and-Supplement')
	-- -- gfx.setFont(sierraFont)
	-- -- sierraFont:setColor(playdate.graphics.kColorBlack)
	-- gfx.drawText("Instructions Screen", 150, 100, sierraFont)
	
	createScoreDisplay()
end

function InstructionsScreen:update(dt)
	-- update entities
end

function InstructionsScreen:leave(next, ...)
	-- destroy entities and cleanup resources
	gfx.sprite.removeAll()
end

function InstructionsScreen:draw()
	-- draw the level
end

function InstructionsScreen:AButtonDown()
	print("AButtonDown")
	sierraFont = gfx.font.new('fonts/Sierra-AGI-Basic-Latin-and-Supplement')
	-- gfx.setFont(sierraFont)
	
	-- playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
	sierraFont:drawText("Instructions Screen", 200, 200)
	
	-- sierraFont:setColor(playdate.graphics.kColorBlack)
	-- gfx.drawText("Instructions Screen", 150, 100, sierraFont)
	updateDisplay()
end

function createScoreDisplay()
	-- Current score sprite
	scoreSprite = gfx.sprite.new()
	score = 0
	scoreSprite:setCenter(0, 0)
	scoreSprite:moveTo(320, 4)
	scoreSprite:add()
end

function updateDisplay()
	-- Current score
	local score = 17
	local scoreText = 'Score: ' .. score
	local instructionsText = "Instructions Screen"
	local textWidth, textHeight = gfx.getTextSize(instructionsText)
	local scoreImage = gfx.image.new(textWidth, textHeight)
	gfx.pushContext(scoreImage)
		-- gfx.drawText(scoreText, 10, 0)
		sierraFont:drawText("Instructions Screen", 0, 0)
	gfx.popContext()
	scoreSprite:setImage(scoreImage)
end

function InstructionsScreen:BButtonDown()
	print("Pop goes the weasel, the weasel!")
	sceneManager:pop()
end