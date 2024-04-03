EndGameScene = {}
class("EndGameScene").extends(NobleScene)
local scene = EndGameScene
local gfx <const> = playdate.graphics
local end_game_message

scene.baseColor = Graphics.kColorBlack


function scene:init()
	scene.super.init(self)

	local crankTick = 0

	scene.inputHandler = {
		AButtonDown = function()
			Noble.transition(TitleScene, 1, Noble.TransitionType.SLIDE_OFF_DOWN)
		end,
		BButtonDown = function()
			Noble.transition(TitleScene, 1, Noble.TransitionType.SLIDE_OFF_DOWN)
		end
	}

end

function scene:enter()
	scene.super.enter(self)

	print("EndGameScene enter")
	
	local gameStatus = Noble.GameData.Status
	
	if (gameStatus == GameStatus.Death) then
		print("Play death sound")
		end_game_message = "You lose homeboy!"
	elseif (gameStatus == GameStatus.Broke) then
		print("Play broke sound")
		end_game_message = "You're broke! Eat sand, you bum!"
	elseif (gameStatus == GameStatus.Won) then
		print("Play won sound")
		end_game_message = "You won!  Now let's blow this taco stand!"
	else
		print("Not sure how you got here")
	end
	
end

function scene:start()
	scene.super.start(self)
	print("EndGameScene start")
	

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
-- 	menu:draw(30, sequence:get()-15 or 100-15)
-- 
-- 	Graphics.setColor(Graphics.kColorBlack)
-- 	Graphics.fillRoundRect(260, -20, 130, 65, 15)
	-- logo:setInverted(false)
	-- logo:draw(275, 8)
	
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillBlack)
	-- gfx.drawText("_The story so far..._", 10, 40)
	-- gfx.drawText(end_game_message, 10, 70)
	Noble.Text.draw(end_game_message, 200, 120, Noble.Text.ALIGN_CENTER)

	Noble.Text.draw("Press Ⓐ to return to the main menu", 385, 220, Noble.Text.ALIGN_RIGHT) 
end

function scene:exit()
	scene.super.exit(self)
end

function scene:finish()
	scene.super.finish(self)
end