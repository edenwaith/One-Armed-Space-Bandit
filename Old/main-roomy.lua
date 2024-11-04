import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
-- import '../toyboxes/toyboxes.lua'
import 'roomy-playdate'
import "TitleScreen"
import "InstructionsScreen"
import "RoomB"
-- import 'GamePlay'

-- Super awesome global variables
gfx = playdate.graphics
sceneManager = Manager()

-- gfx.setColor(gfx.kColorWhite)
-- sceneManager.push(GamePlay())

sceneManager:hook()
sceneManager:enter(TitleScreen())

-- Game lifecycle methods
function playdate.update()
    -- gfx.setColor(gfx.kColorBlack)
    -- gfx.fillRect(20, 20, 200, 120)
    gfx.sprite.update()
    playdate.drawFPS(0,0)
    sceneManager:emit('update')
end

function playdate.gameWillTerminate()
    print("gameWillTerminate")
end

function playdate.deviceWillSleep()
    print("DeviceWillSleep")
end

function playdate.deviceWillLock()
    print("deviceWillLock")
end

function playdate.deviceDidUnlock()
    print("deviceDidUnlock")
end

function playdate.gameWillPause()
    print("gameWillPause")
end

function playdate.gameWillResume()
    print("gameWillResume")
end

function playdate.upButtonUp()
    print("Up button seen in main.lua")
end