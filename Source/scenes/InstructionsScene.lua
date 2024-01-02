InstructionsScene = {}
class("InstructionsScene").extends(NobleScene)
local scene = InstructionsScene
local gfx = playdate.graphics

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
local sequence

function scene:init()
	scene.super.init(self)

	

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
-- 	Graphics.setColor(Graphics.kColorBlack)
-- 	Graphics.fillRoundRect(260, -20, 130, 65, 15)
	-- logo:setInverted(false)
	-- logo:draw(275, 8)
	
	-- Noble.Text.draw(__string, __x, __y[, __alignment=Noble.Text.ALIGN_LEFT[, __localized=false[, __font=Noble.Text.getCurrentFont()]]])
	Noble.Text.draw("*INSTRUCTIONS*", 200, 10, Noble.Text.ALIGN_CENTER)
	
	gfx.drawText("_The story so far..._", 10, 40)
	gfx.drawText("You're stranded at the Oasis Bar which has all the \nappealing odor of a Monolith Burger's bathroom.\n\nYour only hope is to earn 250 Buckazoids at the \nSlots-o-Death so you can buy a ship and get off \nthis crusty rock of a planet.", 10, 70)
	
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