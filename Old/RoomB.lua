class("RoomB").extends(Room)

startAngle = 0
ds = 0.2
endAngle = 0
de = 0.8
radius = 120
nrings = 12



function RoomB:enter()
	print("Welcome to RoomB")
  local s = playdate.graphics.sprite.new()
  s:setSize(400, 120)
  s:setCenter(0,0)
  s:moveTo(20,10)
  
  gfx.setStrokeLocation(gfx.kStrokeOutside)

  function s:draw()
	playdate.graphics.drawText("room B", 10,10)
  end

  s:add()
end

function RoomB:update(dt)
  -- update entities
  -- print("Update RoomB")
  gfx.clear()
  
  gfx.setColor(gfx.kColorWhite);
  gfx.drawRect(200 - radius, 120 - radius, radius * 2 + 1, radius * 2 + 1)
  
  startAngle = startAngle + ds
  endAngle = endAngle + de
  
  gfx.setColor(gfx.kColorBlack);
  
  for i=1,nrings-1
  do
    local innerRadius = i * radius/nrings
    local outerRadius = (i+1) * radius/nrings
    gfx.setLineWidth(outerRadius - innerRadius)
    gfx.drawArc(200, 120, innerRadius, (nrings - i) * startAngle, (nrings - i) * endAngle)
  end
end

function RoomB:leave(next, ...)
  -- destroy entities and cleanup resources
  print("Leaving RoomB")
  gfx.clear(gfx.kColorWhite)
  gfx.sprite.removeAll()
  -- clear()
end

function RoomB:draw()
  -- draw the level
  -- print("Printing in RoomB")
end

function RoomB:AButtonDown()
	print("Pop goes the weasel, the weasel!")
	sceneManager:pop()
end

function RoomB:BButtonDown()
  print("This button does nothing on this screen.")
end