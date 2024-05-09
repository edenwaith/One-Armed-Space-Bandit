CreditsScene = {}
class("CreditsScene").extends(NobleScene)
local scene = CreditsScene
local gfx <const> = playdate.graphics
local snd <const> = playdate.sound

local version_num = "v" .. playdate.metadata.version
local synthPlayer = snd.synth.new(snd.kWaveSquare)
local march_sound = snd.sequence.new('sounds/the_liberty_bell_march.mid')

scene.baseColor = Graphics.kColorBlack


function scene:init()
	scene.super.init(self)

	local crankTick = 0

	scene.inputHandler = {
		AButtonDown = function()
			-- Noble.transition(TitleScene, 1, Noble.TransitionType.SLIDE_OFF_DOWN)
			-- If there is anything need for progressing credits
		end,
		BButtonDown = function()
			Noble.transition(TitleScene, 1, Noble.TransitionType.DIP_TO_WHITE)
		end
	}

end

function scene:enter()
	scene.super.enter(self)

	print("CreditsScene enter")
	
end

function scene:start()
	scene.super.start(self)
	print("CreditsScene start")
	
	-- play_march()

end

-- The file does play, but it sounds awful
function play_march()
	
	local track1 = march_sound:getTrackAtIndex(1) 
	local track2 = march_sound:getTrackAtIndex(2)
	local track3 = march_sound:getTrackAtIndex(3) 
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	track3:setInstrument(synthPlayer:copy())
	march_sound:setTrackAtIndex(1, track1)
	march_sound:setTrackAtIndex(2, track2)
	march_sound:setTrackAtIndex(3, track3)
	
	march_sound:setTempo(300) 
	
	march_sound:play()

end

function scene:drawBackground()
	scene.super.drawBackground(self)
end

function loginUISetup()
	
	
	gfx.setLineWidth(4)
	-- gfx.drawText("*wasteof.money*", 10, 5)
	gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
	
	-- Noble.Text.draw("Emoji _Glyphs!_ 🟨⊙🔒🎣✛⬆️➡️⬇️⬅️", 200, 20, Noble.Text.ALIGN_CENTER)
	
	gfx.drawText("Username ⬅️", 25, 45)
	gfx.drawRoundRect(25, 70, 350, 40, 5)
	gfx.drawText("Password ➡️", 25, 125)
	gfx.drawRoundRect(25, 150, 350, 40, 5)
	gfx.drawRoundRect(25, 205, 170, 30, 5)
	gfx.drawRoundRect(205, 205, 170, 30, 5)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(25, 205, 170, 30)
	gfx.fillRect(205, 205, 170, 30)
	-- gfx.setColor(gfx.kColorWhite)
	
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.drawText("*Sign Up* Ⓐ", 75, 212)
	gfx.drawText('*Login* Ⓑ', 255, 212)
	
	gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
	-- Noble.Text.draw("© 2024 Edenwaith", 20)
	-- 
	-- local version_num = "v" .. playdate.metadata.version 
	-- Noble.Text.draw(version_num, 385, 220, Noble.Text.ALIGN_RIGHT) 
	Noble.Text.draw("Emoji _Glyphs!_ 🟨⊙🔒🎣✛⬆️➡️⬇️⬅️", 200, 20, Noble.Text.ALIGN_CENTER)
end

function scene:update()
	scene.super.update(self)

	-- loginUISetup()
-- end
-- 
-- function moreOldUpdate()

-- 	Graphics.setColor(Graphics.kColorWhite)
-- 	Graphics.setDitherPattern(0.2, Graphics.image.kDitherTypeScreen)
-- 	Graphics.fillRoundRect(15, (sequence:get()*0.75)+3, 185, 145, 15)
-- 	menu:draw(30, sequence:get()-15 or 100-15)
-- 
-- 	Graphics.setColor(Graphics.kColorBlack)
-- 	Graphics.fillRoundRect(260, -20, 130, 65, 15)
	-- logo:setInverted(false)
	-- logo:draw(275, 8)
	
	local text_y_delta = 30
	
	Graphics.setColor(Graphics.kColorBlack)
	Graphics.fillRect(0, 0, 400, 25)
	
	-- Graphics.setColor(Graphics.kColorWhite)
	
	-- What if I get ride of this next line?
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillWhite)
	Noble.Text.draw("*CREDITS*", 200, 4, Noble.Text.ALIGN_CENTER)
	
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillBlack)
	Noble.Text.draw("*Design, programming, graphics, etc.*", 200, text_y_delta + 40, Noble.Text.ALIGN_CENTER)
	Noble.Text.draw("Chad Armstrong", 200, text_y_delta + 70, Noble.Text.ALIGN_CENTER)
	
	Noble.Text.draw("*Original game concept*", 200, text_y_delta + 100, Noble.Text.ALIGN_CENTER)
	Noble.Text.draw("The Two Guys from Andromeda", 200, text_y_delta + 130, Noble.Text.ALIGN_CENTER)
	
	-- Copyright and version info 
	Noble.Text.draw("©2024 Edenwaith", 15, 220, Noble.Text.ALIGN_LEFT) 
	Noble.Text.draw(version_num, 385, 220, Noble.Text.ALIGN_RIGHT) 
	
	-- This looks correct right now, but something broke things and so the D-pad glyphs would be all black
	-- playdate.graphics.drawTextAligned("Emoji _Glyphs!_ 🟨⊙🔒🎣✛⬆️➡️⬇️⬅️", 200, text_y_delta + 180, kTextAlignment.center)
	
	-- gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent) -- Need this mode so the other emoji controls render properly and not filled in all black
	-- Noble.Text.draw("Emoji _Glyphs!_ 🟨⊙🔒🎣✛⬆️➡️⬇️⬅️", 200, text_y_delta + 180, Noble.Text.ALIGN_CENTER)
	
	-- This is then turned on so the screen is black when returning to the title scene
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function oldUpdate()
	
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
	Noble.Text.draw("*CREDITS*", 200, 4, Noble.Text.ALIGN_CENTER)
	
	
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillBlack)
	Noble.Text.draw("*Design, programming, graphics, etc.*", 200, text_y_delta + 40, Noble.Text.ALIGN_CENTER)
	Noble.Text.draw("Chad Armstrong", 200, text_y_delta + 70, Noble.Text.ALIGN_CENTER)
	-- Noble.Text.draw(end_game_message, 200, 120, Noble.Text.ALIGN_CENTER)
	
	Noble.Text.draw("*Original game concept*", 200, text_y_delta + 100, Noble.Text.ALIGN_CENTER)
	Noble.Text.draw("The Two Guys from Andromeda", 200, text_y_delta + 130, Noble.Text.ALIGN_CENTER)
	


	-- Noble.Text.draw("Press Ⓑ to return to the main menu", 385, 220, Noble.Text.ALIGN_RIGHT) 
end

function scene:exit()
	march_sound:stop()
	scene.super.exit(self)
end

function scene:finish()
	scene.super.finish(self)
end