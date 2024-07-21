InstructionsScene = {}
class("InstructionsScene").extends(NobleScene)
local scene = InstructionsScene
local gfx <const> = playdate.graphics
local snd <const> = playdate.sound

local default_font <const> = gfx.getSystemFont("normal")
local sierra_font <const> = gfx.font.new("fonts/Sierra-AGI-Basic-Latin-and-Supplement")

local betting2 <const> = gfx.image.new("images/Betting2") -- Might need to remove this

scene.baseColor = Graphics.kColorWhite

InstructionsPage = {
	Story = 1,
	Directions = 2,
	Betting = 3, 
	-- GridView = 4,
	-- Betting2 = 4,
	Count = 4
}

local instructions_page = InstructionsPage.Story
local titles = { "INSTRUCTIONS", "DIRECTIONS", "BETTING"}
local titleText = titles[instructions_page] --  "*INSTRUCTIONS*"
local instructionsText = "" -- Does this need to be a global var?

-- The story so far...
-- You've stranded at the Oasis Bar which has all the the appealing odor of a Monolith Burger's bathroom.
-- Your goal is to earn 250 Buckazoids at the Slots-o-Death so you can buy a ship and get off this crusty rock of a planet.

-- Instructions
-- Use the D-pad to raise or lower your bet from 1 to 3 Buckazoids.
-- Pull the crank down to spin. 

-- Winning condition: earn $250 (₿250)
-- Losing conditions:
	-- Lose all of your money (perhaps a silly death message)
	-- Get three skulls and get killed (also have a silly death message or few)
-- Side thought: difficulty level to improve the chances of winning?


function scene:init()
	scene.super.init(self)
	
	instructionsText = "You're stranded at the Oasis Bar which has all the \nappealing odor of a Monolith Burger's bathroom.\n\nYour only hope is to earn 250 Buckazoids at the \nSlots-o-Death so you can buy a ship and get off \nthis crusty sore of a planet."

	scene.inputHandler = {
		AButtonDown = function()
			change_page(1) 
		end,
		BButtonDown = function()
			
			if instructions_page == InstructionsPage.Story then
				-- Go back to the previous screen
				Noble.transition(TitleScene, 1, Noble.TransitionType.DIP_TO_WHITE)
			else
				change_page(-1)
			end
			
		end
		
	}

end

-- Go forward or backwards a page in the Instructions.
-- page_num is 1 to go forward and -1 to go backwards
function change_page(page_num) 

	-- Incrementing, going forward a page
	if page_num > 0 then
		if (instructions_page < InstructionsPage.Count - 1) then
			instructions_page += 1
		end
	end 
	
	-- Decrementing, going back a page
	if page_num < 0 then
		if (instructions_page > 1) then
			instructions_page -= 1
		end
	end 
	
	titleText = titles[instructions_page]
end

function scene:enter()
	scene.super.enter(self)
	
	local sierraFont = gfx.font.new('fonts/Sierra-AGI-Basic-Latin-and-Supplement')
	-- gfx.setFont(sierraFont)
	
	local roobert_font <const> =  gfx.font.new('font-rains') -- Roobert-20-Medium
	gfx.setFont(roobert_font)
	
	-- local system_font <const> = gfx.getSystemFont("normal")
	-- system_font <const> = 
	-- gfx.setFont(system_font, playdate.graphics.font.kVariantItalic);
	
end

function scene:start()
	scene.super.start(self)
end

function scene:drawBackground()
	scene.super.drawBackground(self)
end

function scene:update()
	scene.super.update(self)

	-- local myRoobertFontInstance <const> = playdate.graphics.font.new("Roobert-24-Medium")
	-- playdate.graphics.setFont(myRoobertFontInstance)
	-- myRoobertFontInstance:drawText("Some experimental text", 40, 60)
	
	-- Header
	Graphics.setColor(Graphics.kColorBlack)
	Graphics.fillRect(0, 0, 400, 28)
	
	-- Round rect border for the body content
	gfx.setLineWidth(2)
	gfx.drawRoundRect(0, 28, 400, 187, 4);

	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillWhite)
	Utilities.drawTextScaled(titleText, 200, 14, 2, sierra_font)
	
	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillBlack)
	
	if (instructions_page == InstructionsPage.Story ) then
		gfx.drawText("*The story so far...*", 10, 40)
		gfx.drawText(instructionsText, 10, 70, kTextAlignment.left, 2.0)
		
		-- Ⓐ
		-- Ⓑ
		-- 🟨
		-- ⊙
		-- 🔒
		-- 🎣
		-- ✛
		-- ⬆
		-- ➡
		-- ⬇
		-- ⬅
		
		-- Noble.Text.draw("⬅️ ⬅", 10, 180, Noble.Text.ALIGN_LEFT);
		-- Noble.Text.draw("Some icons: 🟨 ⊙ 🔒 🎣 ✛ ⬆️ ➡️ ⬇️ ⬅️", 10, 200, Noble.Text.ALIGN_LEFT)
		
		Graphics.setColor(Graphics.kColorBlack)
		Graphics.fillRect(0, 215, 400, 25)
		
		playdate.graphics.setImageDrawMode(gfx.kDrawModeFillWhite)
		Noble.Text.draw("*Main Menu* Ⓑ", 10, 219, Noble.Text.ALIGN_LEFT)
		Noble.Text.draw("*Directions* Ⓐ", 390, 219, Noble.Text.ALIGN_RIGHT) -- Ⓑ
		
	elseif (instructions_page == InstructionsPage.Directions) then 
		
		-- Reminder: Need to set the image draw mode to gfx.kDrawModeWhiteTransparent for the PD icons to appear correctly.
		gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)		
		gfx.drawText("*Goal:* \nEarn 250 Buckazoids to win, but beware of \ngetting three skulls or losing all of your money!", 10, 40, kTextAlignment.left, 2.0)
		gfx.drawTextAligned("*Controls:*\n⬆  :  Raise your bet\n⬇  :  Lower your bet\nⒶ or 🎣  :  Spin", 10, 110, kTextAlignment.left, 5.0)
		
		Graphics.setColor(Graphics.kColorBlack)
		Graphics.fillRect(0, 215, 400, 25)
		
		playdate.graphics.setImageDrawMode(gfx.kDrawModeFillWhite)
		
		Noble.Text.draw("*Story* Ⓑ", 10, 219, Noble.Text.ALIGN_LEFT)
		Noble.Text.draw("*Betting* Ⓐ", 390, 219, Noble.Text.ALIGN_RIGHT)

	elseif (instructions_page == InstructionsPage.Betting) then 
		
		-- Border around the body content
		gfx.setLineWidth(2)
		-- drawRoundRect for just the outline, fillRoundRect for a filled version
		gfx.drawRoundRect(10, 40, 380, 164, 4) -- Black border 
		gfx.fillRoundRect(10, 40, 380, 20, 4) -- Background fill for the headers
		
		-- Line to separate the section header
		gfx.drawLine(10, 60, 390, 60)
		-- Vertical line 
		gfx.drawLine(200, 60, 200, 204)
		
		gfx.drawText("1  Cherry \n2 Cherries \n3 Cherries \n3 Eyes \n3 Diamonds \n3 Skulls ", 20, 70, kTextAlignment.left, 2.0); -- 70
		gfx.drawText("Wins 1 \nWins 3 \nWins 5 \nWins 10 \nWins 20 \n= DEATH!", 120, 70, kTextAlignment.left, 2.0);
		gfx.drawText("1  =  1x Payoff\n2 = 2x Payoff\n3 = 3x Payoff", 210, 70, kTextAlignment.left, 2.0) -- 240, 70
		
		-- Set the draw mode so the image isn't all black 
		-- gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)	
		-- betting2:draw(300, 120);
		
		-- Bottom bar 
		Graphics.setColor(Graphics.kColorBlack)
		Graphics.fillRect(0, 215, 400, 25)
		
		playdate.graphics.setImageDrawMode(gfx.kDrawModeFillWhite)
		gfx.drawText("*Winnings*", 18, 42)
		gfx.drawText("*Bet*", 208, 42)
		Noble.Text.draw("*Directions* Ⓑ", 10, 219, Noble.Text.ALIGN_LEFT)
		-- Noble.Text.draw("*GridView* Ⓐ", 390, 219, Noble.Text.ALIGN_RIGHT)
		
	-- elseif (instructions_page == InstructionsPage.GridView) then
	-- 	
	-- 	-- Bottom bar 
	-- 	Graphics.setColor(Graphics.kColorBlack)
	-- 	Graphics.fillRect(0, 215, 400, 25)
	-- 	
	-- 	playdate.graphics.setImageDrawMode(gfx.kDrawModeFillWhite)
	-- 	
	-- 	Noble.Text.draw("*Betting* Ⓑ", 10, 219, Noble.Text.ALIGN_LEFT)
	-- 	
	-- 	listview:drawInRect(220, 20, 160, 210)
	-- 	playdate.timer:updateTimers()
		
	-- elseif (instructions_page == InstructionsPage.Betting2) then
	-- 	
	-- 	gfx.drawText("*Betting*", 10, 40)
	-- 	
	-- 	gfx.drawText("Bet:\n1  =  1x Payoff\n2 = 2x Payoff\n3 = 3x Payoff", 10, 70)
	-- 	
	-- 	Noble.Text.draw("Betting Ⓑ", 10, 215, Noble.Text.ALIGN_LEFT)
		
	end 

end

function scene:exit()
	scene.super.exit(self)
end

function scene:finish()
	scene.super.finish(self)
	-- This then causes the background image on the Title Scene to go all black
	-- Called at this point so the transition effect works
	gfx.setImageDrawMode(gfx.kDrawModeWhiteTransparent)
end