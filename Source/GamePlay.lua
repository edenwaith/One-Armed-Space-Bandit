class("Gameplay").extends(Room)

function Gameplay:enter(previous, ...)
	-- set up the level
end

function Gameplay:update(dt)
	-- update entities
end

function Gameplay:leave(next, ...)
	-- destroy entities and cleanup resources
end

function Gameplay:draw()
	-- draw the level
end

function GamePlay:BButtonPressed()
	sceneManager:pop()
end