local playdate <const> = playdate
local gfx <const> = playdate.graphics

class('MainMenuScene').extends(BaseScene)
local MainMenuScene <const> = MainMenuScene

--- Typical constructor, called when scene object is created
function MainMenuScene:init()
	--
end

--- Called each frame
function MainMenuScene:update()
	gfx.pushContext()
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.drawTextAligned("Main menu (Ⓐ to start)", 200, 120, kTextAlignment.center)
	gfx.popContext()

	if playdate.buttonJustPressed(playdate.kButtonA) then
		Cdf.changeScene(GameplayScene)
	end
end

--- Called when transition to this scene begins
function MainMenuScene:enter()
	-- Animate
end

--- Called when transition to this scene is complete
function MainMenuScene:start()
	-- Begin handling input
end

--- Called when transition away from this scene begins
function MainMenuScene:exit()
	-- Stop handling input
end

--- Called when transition away from this scene is complete
function MainMenuScene:finish()
	--
end
