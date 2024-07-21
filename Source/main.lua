import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animation" -- Used for the flashing icon animations
import "CoreLibs/timer"
import "CoreLibs/ui" -- Used for GridView: this can be removed if not used

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
    Bet = 1,
    Money = 30,
    Status = GameStatus.NotPlaying
})

-- Automatically save game data when the player chooses
-- to exit the game via the System Menu or Menu button
function playdate.gameWillTerminate()
    print("gameWillTerminate")
    saveGameData()
end

-- Automatically save game data when the device goes
-- to low-power sleep mode because of a low battery
function playdate.gameWillSleep()
    print("gameWillSleep")
    saveGameData()
end

function saveGameData()
    print("Welcome to saveGameData")
    -- Get the values but perform null coalescing to give default values
    local tempMoney = Noble.GameData.Money or 30
    local tempStatus = Noble.GameData.Status or GameStatus.NotPlaying
    local tempBet = Noble.GameData.Bet or 4
    print("Current money is: " .. tempMoney)
    print("Current status is: " .. tempStatus)
    print("Current bet is: " .. tempBet)
    
    local tempSaveData = { 
        Bet = tempBet, 
        Money = tempMoney, 
        Status = tempStatus 
    }
    local typeSaveData = type(tempSaveData)
    
    print("Money: " .. tempMoney .. " Bet: " .. tempBet .. " Status: " .. tempStatus)
    
    --print("Trying to dump table data")
    -- print("tempSaveData: ", Utilities.dump(tempSaveData))
    
    -- print("Data to save: " .. tempSaveData.Bet .. " " .. tempSaveData.Money .. " " .. tempSaveData.Status)
    
    for k, v in pairs(tempSaveData) do     
        print(k, v) 
    end
    
    print("Now time to save the temp save data")
    
    -- local tempSaveData = Noble.GameData 
    -- print("tempSaveData (" .. type(tempSaveData) .. ") : " .. tempSaveData)
    -- Saving Game State: https://sdk.play.date/2.5.0/Inside%20Playdate.html#saving-state
    Noble.GameData.save(1)
    
    
    -- Save game data into a table first
    -- local gameData = {
    --     currentLevel = level,
    --     currentHealth = health
    -- }
    -- Serialize game data table into the datastore
    playdate.datastore.write(tempSaveData)
end

function loadGameData()
    
    -- Noble.GameData.resetAll()
    
    print("Welcome to loadGameData")
    local numSaveGames = Noble.GameData.getNumberOfSlots()
    local currenSlotNum = Noble.GameData.getCurrentSlot()
    
    local tempSaveData = playdate.datastore.read()
    if tempSaveData ~= nil then
        print("\ntempSaveData\n------------")
        for k, v in pairs(tempSaveData) do     
            print(k, v) 
        end
        
        local betNum = tempSaveData["Bet"] or 1 --Noble.GameData.get("Bet", 1)
        -- Lots of weird issues with ensuring that Bet is not nil
        Noble.GameData.Bet = betNum 
        if betNum ~= nil then 
            print("The bet value is: " .. betNum)
        end 
        
        local savedStatus = tempSaveData["Status"] or GameStatus.NotPlaying 
        Noble.GameData.Status = savedStatus-- Noble.GameData.get("Status", 1)
        if savedStatus ~= nil then 
            print("The saved game status is: " .. savedStatus)
        end 
        
        local moneyValue = tempSaveData["Money"] or 30 -- Noble.GameData.get("Money", 1)
        Noble.GameData.Money = moneyValue
        if moneyValue ~= nil then 
            print("The saved game money stash is: " .. moneyValue)
        end
        
    else
        print("tempSaveData was nil")
    end
    
    print("Number of save games: " .. numSaveGames)
    if currentSlotNum ~= nil then
        print("Current Slot #: " .. currentSlotNum)
    end
    

    
    
    

    
    -- if numSaveGames > 0 then
    --     local gameData = Noble.GameData.getG
    -- end
end

-- TODO: Load up any existing game data from disk
-- Crash on launch: main.lua:40: global 'loadGameData' is not callable (a nil value)
-- Fix: Needed to move the method above this call
loadGameData()

Noble.showFPS = false

-- Load in the TitleScene
Noble.new(TitleScene, 1.5, Noble.TransitionType.CROSS_DISSOLVE) -- CROSS_DISSOLVE -- SLIDE_OFF_DOWN


