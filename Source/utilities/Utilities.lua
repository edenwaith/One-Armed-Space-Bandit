-- Put your utilities and other helper functions here.
-- The "Utilities" table is already defined in "noble/Utilities.lua."
-- Try to avoid name collisions.

local gfx <const> = playdate.graphics

function Utilities.getZero()
	return 0
end

-- This method comes from https://devforum.play.date/t/add-a-drawtextscaled-api-see-code-example/7108/5
function Utilities.drawTextScaled(text, x, y, scale, font)
	local padding = 0 -- string.upper(text) == text and 6 or 0 -- Weird padding hack?
	local w <const> = font:getTextWidth(text)
	local h <const> = font:getHeight() - padding
	-- print("Font width: " .. w .. " height: " .. h .. " padding: " .. padding)
	local img <const> = gfx.image.new(w, h, gfx.kColorClear)
	gfx.lockFocus(img)
	gfx.setFont(font)
	gfx.drawTextAligned(text, w / 2, 0, kTextAlignment.center)
	gfx.unlockFocus()
	img:drawScaled(x - (scale * w) / 2, y - (scale * h) / 2, scale)
end