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
	local thankYouMessage = "\n\nThank you for playing\nOne-Armed Space Bandit."
	
	if (gameStatus == GameStatus.Death) then
		end_game_title = "WAY TO GO, WING NUT!" 
		local randomDeathNum = math.random(1, 3)
		local deathMessages = {
			"You've demonstrated your \ninability to sustain life.  \nYou quickly glance around \nthe room to see if anyone \nsaw you blow it.",
			"Another senseless death. \nYou can help prevent this:  \nVote YES on Lobotomies \nfor Playdate Developers.",
			"Moments before getting \nvaporized, you wonder why \nyou bothered getting up \nthis morning."
		}
		
		end_game_message = deathMessages[randomDeathNum] .. thankYouMessage
		end_image = gfx.image.new('images/Fried')
		end_song = snd.sequence.new('sounds/Sound66.mid')
	elseif (gameStatus == GameStatus.Broke) then
		end_game_title = "YOU'RE BROKE!"
		end_game_message =  "Hit the road, freeloader!\nYou spend your remaining \ndays dumpster diving behind \nthe Oasis Bar." .. thankYouMessage 
		end_image = gfx.image.new('images/poor3')
		end_song = snd.sequence.new('sounds/Sound25-LSL.mid')
	elseif (gameStatus == GameStatus.Won) then
		end_game_title = "YOU WON!"
		end_game_message = "You collect your newly earned \nfilthy lucre and head off to \nTiny's Used Space Ship Lot. \n\nNow it's time to blow this \ntaco stand!"
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

	gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
	end_image:draw(20, 50)
	
	-- Black square outline around the end_image
	gfx.setLineWidth(2);
	Graphics.setColor(Graphics.kColorBlack)
	gfx.drawRect(20, 50, 122, 90)
end

function scene:update()
	scene.super.update(self)
	
	Graphics.setColor(Graphics.kColorBlack)
	Graphics.fillRect(0, 0, 400, 28)
	Graphics.fillRect(0, 215, 400, 25)
	
	
	-- The Sierra AGI font doesn't have a bold version, so scale up
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillWhite)
	Utilities.drawTextScaled(end_game_title, 200, 14, 2, sierra_font)
	
	Noble.Text.draw("*Main Menu* Ⓐ", 390, 219, Noble.Text.ALIGN_RIGHT)
	
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillBlack)
	Noble.Text.draw(end_game_message, 162, 50, Noble.Text.ALIGN_LEFT)
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
	
	synthPlayer:setVolume(0.2)
	
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
	
	synthPlayer:setVolume(0.2)
	
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
	
	synthPlayer:setVolume(0.2)
	local synthVolume = synthPlayer:getVolume()
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	track3:setInstrument(synthPlayer:copy())
	end_song:setTrackAtIndex(1, track1)
	end_song:setTrackAtIndex(2, track2)
	end_song:setTrackAtIndex(3, track3)

	end_song:setTempo(200)
	
	end_song:play()
end

function stopAllEndSceneSounds()
	end_song:stop()
end