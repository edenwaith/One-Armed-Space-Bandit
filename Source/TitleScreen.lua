class("TitleScreen").extends(Room)

function TitleScreen:enter(previous, ...)
	-- set up the level
	print("Entering TitleScreen")
	
	-- local s = playdate.graphics.sprite.new()
	--   s:setSize(400, 120)
	--   s:setCenter(0,0)
	--   s:moveTo(0,0)
	--   -- s:clear()
	--   
	-- function s:draw()
		-- gfx.drawText("Title Screen", 100, 100)
	  	
	
	-- local sierraFont = gfx.font.new('fonts/Sierra-AGI-Basic-Latin-and-Supplement')
	-- gfx.setFont(sierraFont)
	-- -- gfx.setColor(k)
	-- gfx.drawText("Title Screen", 150, 100)
		
	self.setBackground()
	  
	  -- end
end

function TitleScreen:update(dt)
	-- update entities
	if playdate.buttonIsPressed( playdate.kButtonUp ) then
		print("Up button went up the stairs!")
	end
	
	if playdate.buttonJustPressed( playdate.kButtonLeft ) then
		print("Jusst pressed the left button")
	end
	
	if playdate.buttonJustReleased( playdate.kButtonRight ) then
		print("Just released the right button")
	end
	
	if playdate.buttonJustPressed(playdate.kButtonDown ) then
		print("Just pressed the down button")
	end
	
end

function TitleScreen:leave(next, ...)
	-- destroy entities and cleanup resources
end

function TitleScreen:draw()
	-- draw the level
end


-- function TitleScreen:AButtonDown()
-- 
-- end

function playdate.upButtonUp()
	print("up button up!")
end

function playdate.downButtonDown()
	print("down button down, good boy!")
end

function TitleScreen:AButtonDown()
	print("TitleScreen A button pressed")
	sceneManager:push(InstructionsScreen())
end

function TitleScreen:BButtonDown()
	
	-- Note: Keep in mind there can be an issue with the button being pressed multiple 
	-- times when sounds are still playing, so need to catch that.  Perhaps have a more
	-- global sound player if only one sound is played at a time.
  print("Watch ouf for the Bees!")
  -- Load and play a sound
	local soundPlayer = playdate.sound.sampleplayer.new('sounds/Sound25.wav')
	local soundPlayer28 = playdate.sound.sampleplayer.new('sounds/Sound28.wav')
	-- soundPlayer:setRate(1.5)
	-- soundPlayer:setVolume(0.5, 1.0)
	soundPlayer:play(10)
	
	-- Need to figure out a way to tell the first sound to play a certain number of times, 
	-- then once completed then can play the next sound.  Something different with callback?
	-- Perhaps have a loop, then make the determination.
	-- Look at the setFinishCallback(func, [arg]) method
	-- soundPlayer28:play()
  
end

function TitleScreen:setBackground()
  
  print("setBackground")
  -- Set the background image
  local backgroundImage = gfx.image.new( "images/RoomAbkg" )
  assert( backgroundImage )
  
  gfx.sprite.setBackgroundDrawingCallback(
	function( x, y, width, height )
	  backgroundImage:draw( 0, 0 )
	end
  )
end

-- Removes all sprites from the screen
function clearSprites()
   local allSprites = gfx.sprite.getAllSprites()
   for index, sprite in ipairs(allSprites) do
	   sprite:remove()
   end
end