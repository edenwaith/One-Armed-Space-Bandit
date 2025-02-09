TemplateScene = {}
class("TemplateScene").extends(NobleScene)
local scene = TemplateScene

local gfx <const> = playdate.graphics


function scene:init()
	scene.super.init(self)
end

function scene:enter()
	scene.super.enter(self)
end

function scene:start()
	scene.super.start(self)
end

function scene:drawBackground()
	scene.super.drawBackground(self)
end

function scene:update()
	scene.super.update(self)
end

function scene:exit()
	scene.super.exit(self)
end

function scene:finish()
	scene.super.finish(self)
end