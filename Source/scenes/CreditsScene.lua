import "CoreLibs/timer"
import "CoreLibs/graphics"

CreditsScene = {}
class("CreditsScene").extends(NobleScene)

local scene = CreditsScene
local gfx <const> = playdate.graphics
local snd <const> = playdate.sound

local version_num = playdate.metadata.version
local synthPlayer = snd.synth.new(snd.kWaveSquare)

local liberty_bell = snd.fileplayer.new("sounds/the_liberty_bell_march_longer")
local splat = snd.fileplayer.new('sounds/splat')

local footImage <const> = gfx.image.new('images/Foot.png')
local preciousImage <const> = gfx.image.new('images/Precious.png')
local sierra_font <const> = gfx.font.new('fonts/Sierra-AGI-Basic-Latin-and-Supplement')

local text_y_delta = 50
local precious_y_delta = 300 
local foot_y_delta = -240

local gippazoid_info = "*Slots-o-Death is another fine product by:*\nGippazoid Novelties\n2001 Odessa Blastway\nGurnville, Faydor\nExl Galaxy"
local precious_memoriam = "\n\n*Dedication*\nIn memory of Precious"
local credits_text = "*ONE-ARMED SPACE BANDIT*\nVersion " .. version_num .. "\nCopyright © 2024 Edenwaith\nedenwaith.itch.io/one-armed-space-bandit\n\n*Design, programming, graphics, etc.*\nChad Armstrong\n\n*Original Game Concept*\nThe Two Guys From Andromeda\n\n*Music*\nThe Liberty Bell\nThe Stars and Stripes Forever\nby\nJohn Philips Sousa\n\n*Beta Testers*\nMelissa Armstrong\nMike  Piontek\nJulia Minamata\n\n" .. gippazoid_info .. precious_memoriam

-- Timer variables
local delayTimer
local textTimer
local footTimer

local playCredits = false 

scene.baseColor = Graphics.kColorBlack

function scene:init()
	scene.super.init(self)

	scene.inputHandler = {
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
	local maxWidth = 240 -- self.maxWidth 
	-- Calculate size of the credits_text
	local textWidth, textHeight = gfx.getTextSizeForMaxWidth(credits_text, maxWidth)
	
	precious_y_delta = textHeight 
	foot_y_delta = -240
	
	playCredits = true 
	
	delayTimer = playdate.timer 
	delayTimer.performAfterDelay(750, start_credits_roll)
end

function start_credits_roll()
	
	delayTimer:remove() 
	local counter = 0
	
	-- This catch is being used to prevent the credits music playing even after
	-- leaving the Credits scene while the timer delay is waiting.
	if playCredits == false then 
		return 
	end 
	
	local liberty_bell_time = 33500 -- 16750 

	textTimer = playdate.timer.new(liberty_bell_time, 0, liberty_bell_time, function()
		text_y_delta -= 0.6
		precious_y_delta -= 0.6
		counter += 1
	end)
	
	textTimer.timerEndedCallback = credits_roll_finished 

	playLibertyBell()
end

function credits_roll_finished()
	
	textTimer:remove()

	-- Animate the foot falling and squashing the credits 
	local precWidth, precHeight = preciousImage:getSize()	
	-- 56 is extra padding so the foot comes down far enough
	local total_y_delta = math.abs(text_y_delta) + precHeight + 240 + 56 -- TODO: Add height of image
	local timer_ms = 600
	local incrementer_delta = total_y_delta / 30 / (timer_ms/1000) 
	local foot_incrementer_delta = (math.abs(foot_y_delta) + 240) / 30 / (timer_ms/1000)
	
	footTimer = playdate.timer.new(timer_ms, 0, timer_ms, function()
		text_y_delta += incrementer_delta -- 28
		precious_y_delta += incrementer_delta
		if text_y_delta >= 0 then
			foot_y_delta += foot_incrementer_delta
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
	
	playdate.timer.performAfterDelay(500, function() 
		-- Ensure that text_y_delta is 240 in case of any rounding errors
		text_y_delta = 240
		precious_y_delta = 680 -- TODO: calculate this value
		
		textTimer = playdate.timer.new(2000, 0, 2000, function()
			text_y_delta -= 3.166667
			foot_y_delta -= 6
		end)
		textTimer.timerEndedCallback = resetCredits
	end)
	
end

-- After the credits and animations have completed, reset and start again 
function resetCredits()
	
	textTimer:remove()
	
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

function scene:update()
	scene.super.update(self)
	
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillBlack)
	Noble.Text.draw(credits_text, 200, text_y_delta, Noble.Text.ALIGN_CENTER)
	
	assert(preciousImage)
	gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
	preciousImage:draw(119, precious_y_delta) -- 200 - (162/2)
	
	assert(footImage)

	footImage:draw(75, foot_y_delta) -- image is shifted to the left so the foot and leg look more centered
	
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

end

function scene:finish()
	scene.super.finish(self)
	
	text_y_delta = 50 
	foot_y_delta = -240
	
	-- This then causes the background image on the Title Scene to go all black
	-- Called at this point so the transition effect works
	gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
end