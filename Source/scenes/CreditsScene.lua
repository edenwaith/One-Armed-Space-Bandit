import "CoreLibs/timer"
import "CoreLibs/graphics"

CreditsScene = {}
class("CreditsScene").extends(NobleScene)

local scene = CreditsScene
local gfx <const> = playdate.graphics
local snd <const> = playdate.sound

local version_num = playdate.metadata.version
local synthPlayer = snd.synth.new(snd.kWaveSquare)
-- local march_sound = snd.sequence.new('sounds/the_liberty_bell_march.mid') -- find a better version
-- local liberty_bell = snd.fileplayer.new("sounds/Liberty_Bell/liberty_bell_march_louder")
local liberty_bell = snd.fileplayer.new("sounds/Liberty_Bell/the_liberty_bell_march_longer")
local splat = snd.fileplayer.new('sounds/splat')

local footImage <const> = gfx.image.new('images/Foot.png')
local preciousImage <const> = gfx.image.new('images/Precious.png')


-- local default_font <const> = gfx.getSystemFont("normal") -- perhaps this will also work
local sierra_font <const> = gfx.font.new('fonts/Sierra-AGI-Basic-Latin-and-Supplement')

local text_y_delta = 50
local precious_y_delta = 300 -- TODO: Calculate this later
local foot_y_delta = -240
-- Is it possible to read this in from a text file?
local gippazoid_info = "*Slots-o-Death is another fine product by:*\nGippazoid Novelties\n2001 Odessa Blastway\nGurnville, Faydor\nExl Galaxy"
local precious_memoriam = "\n\n*Dedication*\nIn memory of Precious"
local credits_text = "*ONE-ARMED SPACE BANDIT*\nVersion " .. version_num .. "\nCopyright © 2024 Edenwaith\nedenwaith.itch.io/one-armed-space-bandit\n\n*Design, programming, graphics, etc.*\nChad Armstrong\n\n*Original Game Concept*\nThe Two Guys From Andromeda\n\n*Music*\nThe Liberty Bell\nThe Stars and Stripes Forever\nby\nJohn Philips Sousa\n\n*Beta Testers*\nMelissa Armstrong\nMikel Knight\nFester Blatz\n\n" .. gippazoid_info .. precious_memoriam

-- Timer variables
local delayTimer
local textTimer
local footTimer

local playCredits = false 

scene.baseColor = Graphics.kColorBlack

-- This method comes from https://devforum.play.date/t/add-a-drawtextscaled-api-see-code-example/7108/5
--function playdate.graphics.drawTextScaled(text, x, y, scale, font)
-- 	local padding = 0 -- string.upper(text) == text and 6 or 0 -- Weird padding hack?
-- 	local w <const> = font:getTextWidth(text)
-- 	local h <const> = font:getHeight() - padding
-- 	print("Font width: " .. w .. " height: " .. h .. " padding: " .. padding)
-- 	local img <const> = gfx.image.new(w, h, gfx.kColorClear)
-- 	gfx.lockFocus(img)
-- 	gfx.setFont(font)
-- 	gfx.drawTextAligned(text, w / 2, 0, kTextAlignment.center)
-- 	gfx.unlockFocus()
-- 	img:drawScaled(x - (scale * w) / 2, y - (scale * h) / 2, scale)
-- end

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
end

function scene:start()
	scene.super.start(self)
	
	text_y_delta = 50 
	-- TODO: Need to calculate where to place the preciousImage
	
	-- Calculate size of the credits_text
	
	local maxWidth = 240 -- self.maxWidth 
	local textWidth, textHeight = gfx.getTextSizeForMaxWidth(credits_text, maxWidth)
	
	print("textWidth: " .. textWidth .. " textHeight: " .. textHeight)
	
	precious_y_delta = textHeight -- 500
	foot_y_delta = -240
	
	playCredits = true 
	-- playdate.timer.performAfterDelay(750, start_credits_roll)
	delayTimer = playdate.timer 
	delayTimer.performAfterDelay(750, start_credits_roll)

end

function start_credits_roll()
	-- textTimer = playdate.timer.new(8000, function()
	-- 	print("Current time: " .. playdate.getCurrentTimeMilliseconds())
	-- 	text_y_delta -= 1
	-- end)
	-- 
	-- textTimer.repeats = true 
	
	delayTimer:remove() 
	local counter = 0
	
	-- This catch is being used to prevent the credits music playing even after
	-- leaving the Credits scene while the timer delay is waiting.
	if playCredits == false then 
		return 
	end 
	
	local liberty_bell_time = 33500 -- 16750 
	print("text_y_delta start: " .. text_y_delta) -- Starts at 50 
	textTimer = playdate.timer.new(liberty_bell_time, 0, liberty_bell_time, function()
		-- print("Current time: " .. playdate.getCurrentTimeMilliseconds())
		text_y_delta -= 0.6
		precious_y_delta -= 0.6
		counter += 1
	end)
	textTimer.timerEndedCallback = credits_roll_finished 

	playLibertyBell()
end

function credits_roll_finished()
	
	textTimer:remove()
	
	print("credits_roll_finished")
	print("text_y_delta end: " .. text_y_delta) -- -271.8012

	-- Animate the foot falling and squashing the credits 
	
	local precWidth, precHeight = preciousImage:getSize()
	print("precWidth: " .. precWidth .. " precHeight: " .. precHeight)
	
	-- 56 is extra padding so the foot comes down far enough
	local total_y_delta = math.abs(text_y_delta) + precHeight + 240 + 56 -- TODO: Add height of image
	local timer_ms = 600
	local incrementer_delta = total_y_delta / 30 / (timer_ms/1000) -- perhaps add the height of the image, as well?
	local foot_incrementer_delta = (math.abs(foot_y_delta) + 240) / 30 / (timer_ms/1000)
	
	print("foot_y_delta: " .. foot_y_delta .. " foot_incrementer_delta: " .. foot_incrementer_delta)
	print("total_y_delta: " .. total_y_delta .. " incrementer_delta: " .. incrementer_delta .. " foot_incrementer_delta: " .. foot_incrementer_delta)
	
	
	footTimer = playdate.timer.new(timer_ms, 0, timer_ms, function()
		text_y_delta += incrementer_delta -- 28
		precious_y_delta += incrementer_delta
		if text_y_delta >= 0 then
			-- Is this not moving when it should?
			foot_y_delta += foot_incrementer_delta
			print("footTimer -- foot_y_delta is " .. foot_y_delta)
		else 
			print("footTimer -- text_y_delta is " .. text_y_delta)
		end 
	end)
	footTimer.timerEndedCallback = foot_animation_completed
	
	playSplat()
end

function playSplat()
	assert(splat)
	-- This lasts between 0.5 and 0.6 seconds
	splat:play()
end

function foot_animation_completed()
	-- Animate the foot off again to original position and scroll the credits back up
	
	footTimer:remove()
	
	print("After foot animation, the text_y_delta is now: " .. text_y_delta)
	
	
	playdate.timer.performAfterDelay(500, function() 
		-- Ensure that text_y_delta is 240 in case of any rounding errors
		text_y_delta = 240
		precious_y_delta = 680 -- TODO: calculate this value
		
		textTimer = playdate.timer.new(2000, 0, 2000, function()
			-- print("Current time: " .. playdate.getCurrentTimeMilliseconds())
			text_y_delta -= 3.166667
			foot_y_delta -= 6
	
		end)
		textTimer.timerEndedCallback = resetCredits
	end)
	
end

-- After the credits and animations have completed, reset and start again 
-- Or perhaps allow one to scroll on their own?  Hmmm....
function resetCredits()
	
	textTimer:remove()
	
	print("Time to reset the credits")
	text_y_delta = 50
	foot_y_delta = -240
	
	playdate.timer.performAfterDelay(1000, start_credits_roll)
end

function playLibertyBell()
	assert(liberty_bell)
	liberty_bell:play()
end 

function scene:drawBackground()
	scene.super.drawBackground(self)
end

-- TODO: This is some test method, clean up
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
	
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillBlack)
	Noble.Text.draw(credits_text, 200, text_y_delta, Noble.Text.ALIGN_CENTER)
	
	assert(preciousImage)
	gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
	preciousImage:draw(119, precious_y_delta) -- 200 - (162/2)
	
	assert(footImage)

	-- gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
	footImage:draw(75, foot_y_delta) -- image is shifted to the left so the foot and leg look more centered
	
	-- This looks correct right now, but something broke things and so the D-pad glyphs would be all black
	-- playdate.graphics.drawTextAligned("Emoji _Glyphs!_ 🟨⊙🔒🎣✛⬆️➡️⬇️⬅️", 200, text_y_delta + 180, kTextAlignment.center)
	
	-- gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent) -- Need this mode so the other emoji controls render properly and not filled in all black
	-- Noble.Text.draw("Emoji _Glyphs!_ 🟨⊙🔒🎣✛⬆️➡️⬇️⬅️", 200, text_y_delta + 180, Noble.Text.ALIGN_CENTER)
	
	-- This is then turned on so the screen is black when returning to the title scene
	-- This then causes the background image on the Title Scene to go all black
	-- Need to find some way to reset things, perhaps in exit() method
	-- playdate.graphics.setImageDrawMode(gfx.kDrawModeFillBlack)
	-- gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent) -- This seems to fix the problem, but no transition
	
	
	-- Draw the header after the credits text so the text can scroll underneath the header
	Graphics.setColor(Graphics.kColorBlack)
	Graphics.fillRect(0, 0, 400, 28)
	
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillWhite)
	Utilities.drawTextScaled("CREDITS", 200, 14, 2, sierra_font)
	
end

function scene:exit()

	scene.super.exit(self)
	
	playCredits = false
	
	if delayTimer ~= nil then 
		delayTimer:remove()
	end 
	
	if textTimer ~= nil then
		textTimer:remove()
	end
	
	if footTimer ~= nil then
		footTimer:remove()
	end 
	
	liberty_bell:stop()
	splat:stop()
	
	-- TODO: I might need to clear out any graphics or sprites from this scene
end

function scene:finish()
	scene.super.finish(self)
	
	text_y_delta = 50 
	foot_y_delta = -240
	
	-- This then causes the background image on the Title Scene to go all black
	-- Called at this point so the transition effect works
	gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
end