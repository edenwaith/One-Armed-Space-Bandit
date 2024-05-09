EndGameScene = {}
class("EndGameScene").extends(NobleScene)
local scene = EndGameScene
local gfx <const> = playdate.graphics
local snd <const> = playdate.sound
local end_game_message

local synthPlayer = snd.synth.new(snd.kWaveSquare) -- kWaveSawtooth
local win_song = snd.sequence.new('sounds/Sound24-Square.mid')
local broke_song = snd.sequence.new('sounds/Sound25-LSL.mid')
local death_song = snd.sequence.new('sounds/Sound66.mid')

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
		playDeathSong()
	elseif (gameStatus == GameStatus.Broke) then
		print("Play broke sound")
		end_game_message = "You're broke!  Hit the road, freeloader!" -- "You're broke! Eat sand, you bum!"
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

	-- Noble.Text.draw("Some icons: 🟨 ⊙ 🔒 🎣 ✛ ⬆️ ➡️ ⬇️ ⬅️", 10, 200, Noble.Text.ALIGN_LEFT)
	Noble.Text.draw("Press Ⓐ to return to the main menu", 200, 219, Noble.Text.ALIGN_CENTER) 
end

function scene:exit()
	scene.super.exit(self)
	stopAllSounds()
end

function scene:finish()
	scene.super.finish(self)
	stopAllSounds()
end

function playWinSong()
	stopAllSounds()
	
	local track1 = win_song:getTrackAtIndex(1)
	local track2 = win_song:getTrackAtIndex(2)
	local track3 = win_song:getTrackAtIndex(3) 
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	track3:setInstrument(synthPlayer:copy())
	
	win_song:setTrackAtIndex(1, track1)
	win_song:setTrackAtIndex(2, track2)
	win_song:setTrackAtIndex(3, track3)

	win_song:setTempo(200) -- 200 for Sound24
	
	win_song:play()
end

function playBrokeSong()
	stopAllSounds()
	
	local track1 = broke_song:getTrackAtIndex(1)
	local track2 = broke_song:getTrackAtIndex(2)
	--local track3 = broke_song:getTrackAtIndex(3) 
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	--track3:setInstrument(synthPlayer:copy())
	
	broke_song:setTrackAtIndex(1, track1)
	broke_song:setTrackAtIndex(2, track2)
	--broke_song:setTrackAtIndex(3, track3)
	
	broke_song:setTempo(200) -- 200 for Sound24
	
	broke_song:play()
end

function playDeathSong()
	stopAllSounds()
	
	local track1 = death_song:getTrackAtIndex(1)
	local track2 = death_song:getTrackAtIndex(2)
	local track3 = death_song:getTrackAtIndex(3) 
	
	synthPlayer:setVolume(0.5)
	local synthVolume = synthPlayer:getVolume()
	print("synthVolume is " .. synthVolume)
	
	track1:setInstrument(synthPlayer:copy())
	track2:setInstrument(synthPlayer:copy())
	track3:setInstrument(synthPlayer:copy())
	death_song:setTrackAtIndex(1, track1)
	death_song:setTrackAtIndex(2, track2)
	death_song:setTrackAtIndex(3, track3)
	-- Is there a way to set the volume, some of these are kind of loud
	death_song:setTempo(200)
	
	death_song:play()
end

function stopAllSounds()
	win_song:stop()
	broke_song:stop()
	death_song:stop()
end