TitleScene = {}
class("TitleScene").extends(NobleScene)
local scene = TitleScene

local gfx <const> = playdate.graphics

local backgroundImage = gfx.image.new( "images/Title-Scene" ) 
local menu
local difficultyValues = {"Easy", "Medium", "Hard"}

function scene:init()
	scene.super.init(self)

	-- Docs for Noble.Menu: https://noblerobot.github.io/NobleEngine/modules/Noble.Menu.html
	menu = Noble.Menu.new(true, Noble.Text.ALIGN_LEFT, false, Graphics.kColorWhite, 8,8,0, Noble.Text.FONT_MEDIUM, 8, 0)

	menu:addItem("New Game", transitionNewGame)
	
	if Noble.GameData.Status == GameStatus.Playing then
		-- TODO: Need to create some new method or ensure that certain status and variables are set properly
		menu:addItem("Continue Game",  function() Noble.transition(GameScene, 1, Noble.TransitionType.DIP_TO_WHITE) end)
		menu:select("Continue Game")
	end

	menu:addItem("Instructions", function() Noble.transition(InstructionsScene, 1, Noble.TransitionType.DIP_TO_BLACK) end)

	menu:addItem( -- is it possible to change this setting with D-pad?
		"Difficulty",
		function()
			local oldValue = Noble.Settings.get("Difficulty")
			local newValue = math.ringInt(table.indexOfElement(difficultyValues, oldValue)+1, 1, 3)
			Noble.Settings.set("Difficulty", difficultyValues[newValue])
			menu:setItemDisplayName("Difficulty", "Difficulty: " .. difficultyValues[newValue])
		end,
		nil,
		"Difficulty: " .. Noble.Settings.get("Difficulty")
	)
	menu:addItem("Credits", function() Noble.transition(CreditsScene, 1, Noble.TransitionType.DIP_TO_BLACK) end)

	local crankTick = 0

	scene.inputHandler = {
		upButtonDown = function()
			menu:selectPrevious()
		end,
		downButtonDown = function()
			menu:selectNext()
		end,
		cranked = function(change, acceleratedChange)
			crankTick = crankTick + change
			if (crankTick > 60) then
				crankTick = 0
				menu:selectNext()
			elseif (crankTick < -60) then
				crankTick = 0
				menu:selectPrevious()
			end
		end,
		AButtonDown = function()
			menu:click()
		end
	}

end

function transitionNewGame()
	Noble.GameData.Status = GameStatus.New 
	if Noble.GameData.Bet == nil then
		Noble.GameData.Bet = 1
	end
	Noble.transition(GameScene, 1, Noble.TransitionType.DIP_TO_WHITE)
end

function transitionToSoundsScene()
	Noble.transition(SoundsScene, 1, Noble.TransitionType.DIP_TO_BLACK)
end

function scene:enter()
	scene.super.enter(self)
end

function scene:start()
	scene.super.start(self)

	menu:activate()
	Noble.Input.setCrankIndicatorStatus(false)
end

function scene:drawBackground()
	scene.super.drawBackground(self)
	
	  -- Set the background image
	assert( backgroundImage )
	-- Background image adjusted by one pixel to display white line on the right 
	backgroundImage:draw( -1, 0 )
end

function scene:update()
	scene.super.update(self)

 	gfx.setColor(Graphics.kColorBlack)
 	gfx.fillRect(240, 0, 160, 240)
 	menu:draw(250, 20)

	-- Graphics.setColor(Graphics.kColorWhite)
	
	-- When this fill is set, it then draw the background as white, which hides the background image		
	-- gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	-- local version_num = "v" .. playdate.metadata.version 
	-- Noble.Text.draw(version_num, 385, 220, Noble.Text.ALIGN_RIGHT) 
	-- 
	-- -- This is then set so the background image is visible 
	-- Unfortunately, when leaving the Game Scene, it causes weirdness here. :( )
	-- gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)

end

function scene:exit()
	scene.super.exit(self)

	Noble.Input.setCrankIndicatorStatus(false)
end

function scene:finish()
	scene.super.finish(self)
end