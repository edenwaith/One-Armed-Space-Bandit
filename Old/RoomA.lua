-- NOTE: This room is no longer being actively used!  Ignore!!!!

class("RoomA").extends(Room)

function RoomA:enter()
  print("Welcome to RoomA")
  
  local s = playdate.graphics.sprite.new()
  s:setSize(400, 120)
  s:setCenter(0,0)
  s:moveTo(0,0)
  s:clear()
  
  function s:draw()
	playdate.graphics.drawText("room A", 10,10)
  
    local sierraFont = gfx.font.new('fonts/Sierra-AGI-Basic-Latin-and-Supplement')
    gfx.setFont(sierraFont)
    gfx.drawText("Sierra Love", 30, 30)
  
  end

  s:add()
end

function setBackground()
  
  print("setBackground")
  -- Set the background image
  local backgroundImage = gfx.image.new( "images/RoomAbkg" )
  -- assert( backgroundImage )
  
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

function RoomA:AButtonDown()
  print("Eh, what was that?!")
  -- clearSprites()
  setBackground()
  
end

function RoomA:BButtonDown()
  print("Watch ouf for the Bees!")
  sceneManager:push(RoomB())
end