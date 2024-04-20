local playdate <const> = playdate
local gfx <const> = playdate.graphics

class('TestScene').extends(BaseScene)
local TestScene <const> = TestScene

--- Typical constructor, called when scene object is created
function TestScene:init()
	--
end

--- Called each frame
function TestScene:update()
	gfx.clear()
	gfx.pushContext()
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.drawTextAligned("TestScene", 200, 120, kTextAlignment.center)
	gfx.popContext()

	if playdate.buttonJustPressed(playdate.kButtonA) then
		Cdf.changeScene(MainMenuScene)
	end
end

--- Called when transition to this scene begins
function TestScene:enter()
	-- Animate
end

--- Called when transition to this scene is complete
function TestScene:start()
	-- Begin handling input
end

--- Called when transition away from this scene begins
function TestScene:exit()
	-- Stop handling input
end

--- Called when transition away from this scene is complete
function TestScene:finish()
	--
end
