class("TitleScreen").extends(Room)

function TitleScreen:enter(previous, ...)
	-- set up the level
end

function TitleScreen:update(dt)
	-- update entities
end

function TitleScreen:leave(next, ...)
	-- destroy entities and cleanup resources
end

function TitleScreen:draw()
	-- draw the level
end

function TitleScreen:AButtonDown()
  print("Eh, what was that?!")
end

function TitleScreen:BButtonDown()
  print("Watch ouf for the Bees!")
  sceneManager:push(RoomB())
end