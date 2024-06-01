import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui" -- Used for GridView
-- import '../toyboxes/toyboxes.lua'
-- import 'roomy-playdate'
-- import "TitleScreen"
-- import "InstructionsScreen"
-- import "RoomB"
-- import 'GamePlay'

import 'libraries/noble/Noble'

import 'utilities/Utilities'

import 'scenes/EndGameScene'
import 'scenes/ExampleScene'
import 'scenes/ExampleScene2'
import 'scenes/TitleScene'
import 'scenes/InstructionsScene'
import 'scenes/GameScene'
import 'scenes/SoundsScene'
import 'scenes/CreditsScene'


GameStatus = {
    Death = 1,
    Broke = 2,
    Won = 3,
    New = 4,
    Playing = 5,
    NotPlaying = 6
}

Noble.Settings.setup({
    Difficulty = "Medium"
})

Noble.GameData.setup({
    Score = 0,
    Status = GameStatus.NotPlaying
})

Noble.showFPS = false

-- Load in the TitleScene
Noble.new(TitleScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE) -- CROSS_DISSOLVE -- SLIDE_OFF_DOWN

