local playdate <const> = playdate
local gfx <const> = playdate.graphics

class('MainMenuScene').extends(BaseScene)
local MainMenuScene <const> = MainMenuScene

local titleLineHeight = fonts.lexendDecaBold32:getHeight()
local titleTextImage = gfx.image.new(360, titleLineHeight * 2)
gfx.pushContext(titleTextImage)
gfx.setFont(fonts.lexendDecaBold32)
gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
gfx.drawText(
	gfx.getLocalizedText("mainMenuScene.titleLine1"),
	0,
	0
)
gfx.drawText(
	gfx.getLocalizedText("mainMenuScene.titleLine2"),
	0,
	titleLineHeight
)
gfx.popContext()

--- Typical constructor, called when scene object is created
function MainMenuScene:init()
	self.titleSprite = gfx.sprite.new(titleTextImage)
	self.titleSprite:setCenter(0, 0)
	self.titleSprite:moveTo(20, 20)
end

--- Called each frame
function MainMenuScene:update()
	if playdate.buttonJustPressed(playdate.kButtonA) then
		Cdf.changeScene(GameplayScene)
	end
end

--- Called when transition to this scene begins
function MainMenuScene:enter()
	self.titleSprite:add()
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
	self.titleSprite:remove()
end
