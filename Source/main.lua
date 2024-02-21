import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
-- import '../toyboxes/toyboxes.lua'
-- import 'roomy-playdate'
-- import "TitleScreen"
-- import "InstructionsScreen"
-- import "RoomB"
-- import 'GamePlay'

import 'libraries/noble/Noble'

import 'utilities/Utilities'

import 'scenes/ExampleScene'
import 'scenes/ExampleScene2'
import 'scenes/TitleScene'
import 'scenes/InstructionsScene'
import 'scenes/GameScene'
import 'scenes/SoundsScene'


Noble.Settings.setup({
    Difficulty = "Medium"
})

Noble.GameData.setup({
    Score = 0
})

Noble.showFPS = true

-- Load in the TitleScene
Noble.new(TitleScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE)

