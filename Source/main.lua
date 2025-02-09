import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animation" -- Used for the flashing icon animations
import "CoreLibs/timer"
import "CoreLibs/ui" -- Used for GridView: this can be removed if not used

import 'libraries/noble/Noble'
import 'utilities/Utilities'

import 'scenes/EndGameScene'
import 'scenes/TitleScene'
import 'scenes/InstructionsScene'
import 'scenes/GameScene'
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
    Bet = 1,
    Money = 30,
    Status = GameStatus.NotPlaying
})

-- Automatically save game data when the player chooses
-- to exit the game via the System Menu or Menu button
function playdate.gameWillTerminate()
    saveGameData()
end

-- Automatically save game data when the device goes
-- to low-power sleep mode because of a low battery
function playdate.gameWillSleep()
    saveGameData()
end

function saveGameData()
    -- Get the values but perform null coalescing to give default values
    local tempMoney = Noble.GameData.Money or 30
    local tempStatus = Noble.GameData.Status or GameStatus.NotPlaying
    local tempBet = Noble.GameData.Bet or 1 -- Why is this default to 4?  Change to 1
    
    local tempSaveData = { 
        Bet = tempBet, 
        Money = tempMoney, 
        Status = tempStatus 
    }
    local typeSaveData = type(tempSaveData)
    
    for k, v in pairs(tempSaveData) do     
        print(k, v) 
    end
    
    -- Saving Game State: https://sdk.play.date/2.5.0/Inside%20Playdate.html#saving-state
    Noble.GameData.save(1)

    -- Serialize game data table into the datastore
    playdate.datastore.write(tempSaveData)
end

function loadGameData()
    
    local numSaveGames = Noble.GameData.getNumberOfSlots()
    local currenSlotNum = Noble.GameData.getCurrentSlot()
    local tempSaveData = playdate.datastore.read()
    
    if tempSaveData ~= nil then

        for k, v in pairs(tempSaveData) do     
            print(k, v) 
        end
        
        local betNum = tempSaveData["Bet"] or 1 
        -- Lots of weird issues with ensuring that Bet is not nil
        Noble.GameData.Bet = betNum 
        
        local savedStatus = tempSaveData["Status"] or GameStatus.NotPlaying 
        Noble.GameData.Status = savedStatus-- Noble.GameData.get("Status", 1)
        
        local moneyValue = tempSaveData["Money"] or 30 -- Noble.GameData.get("Money", 1)
        Noble.GameData.Money = moneyValue
        
    else
        print("tempSaveData was nil")
    end
    
end

loadGameData()

Noble.showFPS = false

-- Load in the TitleScene
Noble.new(TitleScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE)


