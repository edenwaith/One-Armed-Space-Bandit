EndGameScene = {}
class("EndGameScene").extends(NobleScene)
local scene = EndGameScene
local gfx <const> = playdate.graphics
local snd <const> = playdate.sound
local end_game_message = ""
local end_game_title = ""
local sierra_font <const> = gfx.font.new('fonts/Sierra-AGI-Basic-Latin-and-Supplement')

local synthPlayer = snd.synth.new(snd.kWaveSquare) -- kWaveSawtooth
local end_song 
local end_image

scene.baseColor = Graphics.kColorBlack


function scene:init()
	scene.super.init(self)

	local crankTick = 0

	scene.inputHandler = {
		AButtonDown = function()
			Noble.transition(TitleScene, 1, Noble.TransitionType.DIP_TO_WHITE)
		end,
		BButtonDown = function()
			Noble.transition(TitleScene, 1, Noble.TransitionType.DIP_TO_WHITE) -- SLIDE_OFF_DOWN
		end
	}

end

function scene:enter()
	scene.super.enter(self)
	
	local gameStatus = Noble.GameData.Status
	
	if (gameStatus == GameStatus.Death) then
		end_game_title = "WAY TO GO, BEANPOLE!"
		end_game_message = "Congratulations on your \nrecent death! \nYou lose homeboy!"
		end_image = gfx.image.new('images/Fried')
		end_song = snd.sequence.new('sounds/Sound66.mid')
		playDeathSong()
	elseif (gameStatus == GameStatus.Broke) then
		end_game_title = "YOU'RE BROKE!"
		end_game_message = "Pound sand, you bum!" -- "Hit the road, freeloader!" -- "You're broke! Eat sand, you bum!"
		end_image = gfx.image.new('images/Fried')
		end_song = snd.sequence.new('sounds/Sound25-LSL.mid')
	elseif (gameStatus == GameStatus.Won) then
		end_game_title = "YOU WON!"
		end_game_message = "Now it's time to blow this \ntaco stand!"
		end_image = gfx.image.new('images/Buckazoidsq1')
		end_song = snd.sequence.new('sounds/Sound24-Square.mid')
	else
		print("Not sure how you got here")
	end
	
end

function scene:start()
	scene.super.start(self)
	
	local game_status = Noble.GameData.Status
	
	if game_status == GameStatus.Death then
		playDeathSong()
	elseif game_status == GameStatus.Broke then 
		playBrokeSong() 
	elseif game_status == GameStatus.Won then 
		playWinSong()
	end
end

function scene:drawBackground()
	scene.super.drawBackground(self)

	assert(end_image)

	-- Original SCI-style button	
	gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
	end_image:draw(20, 50)
	
	-- Black square outline around the end_image
	gfx.setLineWidth(2);
	Graphics.setColor(Graphics.kColorBlack)
	gfx.drawRect(20, 50, 122, 90)

	-- -- Main Menu button
	-- -- TODO: Create a Button sprite/class
	-- gfx.setLineWidth(2)
	-- gfx.drawRoundRect(248, 196, 132, 26, 0); -- 4 is a nice corner radius
	-- Noble.Text.draw("*Main Menu* Ⓐ", 314, 201, Noble.Text.ALIGN_CENTER) 
	
	-- Is it possible to also draw a border for the image and get it to look good?
	-- background:draw(0, 0)
end

function scene:update()
	scene.super.update(self)
	
	Graphics.setColor(Graphics.kColorBlack)
	Graphics.fillRect(0, 0, 400, 28)
	
	-- Graphics.setColor(Graphics.kColorBlack)
	Graphics.fillRect(0, 215, 400, 25)
	
	-- playdate.graphics.setImageDrawMode(gfx.kDrawModeFillWhite)
	-- Noble.Text.draw("*Main Menu* Ⓑ", 10, 219, Noble.Text.ALIGN_LEFT)
	-- Noble.Text.draw("*Main Menu* Ⓐ", 390, 219, Noble.Text.ALIGN_RIGHT)
	
	-- The Sierra AGI font doesn't have a bold version.
	-- Need to make this larger, draw it slightly bigger?  Maybe up to 50% larger?
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillWhite)
	Utilities.drawTextScaled(end_game_title, 200, 14, 2, sierra_font)
	
	Noble.Text.draw("*Main Menu* Ⓐ", 390, 219, Noble.Text.ALIGN_RIGHT)
	
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillBlack)
	Noble.Text.draw(end_game_message, 162, 50, Noble.Text.ALIGN_LEFT)
	

	-- Noble.Text.draw("Some icons: 🟨 ⊙ 🔒 🎣 ✛ ⬆️ ➡️ ⬇️ ⬅️", 10, 200, Noble.Text.ALIGN_LEFT)
	-- Noble.Text.draw("Press Ⓐ to return to the main menu", 200, 219, Noble.Text.ALIGN_CENTER) 
end

function scene:exit()
	scene.super.exit(self)
	stopAllEndSceneSounds()
end

function scene:finish()
	scene.super.finish(self)
	-- This then causes the background image on the Title Scene to go all black
	-- Called at this point so the transition effect works
	gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
end

function playWinSong()
	stopAllEndSceneSounds()
	
	local track1 = end_song:getTrackAtIndex(1)
	local track2 = end_song:getTrackAtIndex(2)
	local track3 = end_song:getTrackAtIndex(3) 
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	track3:setInstrument(synthPlayer:copy())
	
	end_song:setTrackAtIndex(1, track1)
	end_song:setTrackAtIndex(2, track2)
	end_song:setTrackAtIndex(3, track3)

	end_song:setTempo(200) -- 200 for Sound24
	
	end_song:play()
end

function playBrokeSong()
	stopAllEndSceneSounds()
	
	local track1 = end_song:getTrackAtIndex(1)
	local track2 = end_song:getTrackAtIndex(2)
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	
	end_song:setTrackAtIndex(1, track1)
	end_song:setTrackAtIndex(2, track2)
	
	end_song:setTempo(200) -- 200 for Sound24
	
	end_song:play()
end

function playDeathSong()
	stopAllEndSceneSounds()
	
	local track1 = end_song:getTrackAtIndex(1)
	local track2 = end_song:getTrackAtIndex(2)
	local track3 = end_song:getTrackAtIndex(3) 
	
	synthPlayer:setVolume(0.5)
	local synthVolume = synthPlayer:getVolume()
	print("synthVolume is " .. synthVolume)
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	track3:setInstrument(synthPlayer:copy())
	end_song:setTrackAtIndex(1, track1)
	end_song:setTrackAtIndex(2, track2)
	end_song:setTrackAtIndex(3, track3)
	-- Is there a way to set the volume, some of these are kind of loud
	end_song:setTempo(200)
	
	end_song:play()
end

function stopAllEndSceneSounds()
	end_song:stop()
	-- win_song:stop()
	-- broke_song:stop()
	-- death_song:stop()
end