import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import '../toyboxes/toyboxes.lua'
import "TitleScreen"
import "RoomB"
-- import 'GamePlay'

-- Super awesome global variables
gfx = playdate.graphics
sceneManager = Manager()

-- gfx.setColor(gfx.kColorWhite)
-- sceneManager.push(GamePlay())

sceneManager:hook()
sceneManager:enter(TitleScreen())

function playdate.update()
    -- gfx.setColor(gfx.kColorBlack)
    -- gfx.fillRect(20, 20, 200, 120)
    gfx.sprite.update()
    playdate.drawFPS(0,0)
    sceneManager:emit('update')
end
