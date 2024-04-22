local playdate <const> = playdate
local gfx <const> = playdate.graphics

class('HowToPlayScene').extends(BaseScene)
local HowToPlayScene <const> = HowToPlayScene

local controlsLineHeight = fonts.nicoClean16:getHeight() * 1.5
local controlsImage <const> = gfx.image.new(360, controlsLineHeight * 3)
gfx.pushContext(controlsImage)
gfx.setFont(fonts.nicoClean16)
gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
gfx.drawText(gfx.getLocalizedText("howToPlayScene.launch"), 0, 0)
gfx.drawText(gfx.getLocalizedText("howToPlayScene.steer"), 0, controlsLineHeight)
gfx.drawText(gfx.getLocalizedText("howToPlayScene.switch"), 0, controlsLineHeight * 2)
gfx.popContext()

gfx.pushContext()
gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
gfx.setFont(fonts.nicoPups16)
local storyImage = gfx.imageWithText(gfx.getLocalizedText("howToPlayScene.story"), 360, 1000)
gfx.popContext()

--- Typical constructor, called when scene object is created
function HowToPlayScene:init()
	--
end

--- Called each frame
function HowToPlayScene:update()
	--
end

--- Called when transition to this scene begins
function HowToPlayScene:enter()
	self.controlsSprite = gfx.sprite.new(controlsImage)
	self.controlsSprite:setCenter(0, 0)
	self.controlsSprite:moveTo(20, 40)
	self.controlsSprite:add()

	self.storySprite = gfx.sprite.new(storyImage)
	self.storySprite:setCenter(0, 0)
	self.storySprite:moveTo(20, 65 + controlsLineHeight * 3)
	self.storySprite:add()
end

--- Called when transition to this scene is complete
function HowToPlayScene:start()
	playdate.inputHandlers.push({
		AButtonDown = function()
			self:_handleAButtonDown()
		end,

		BButtonDown = function()
			self:_handleBButtonDown()
		end,
	})
end

--- Called when transition away from this scene begins
function HowToPlayScene:exit()
	playdate.inputHandlers.pop()
end

--- Called when transition away from this scene is complete
function HowToPlayScene:finish()
	self.controlsSprite:remove()
	self.storySprite:remove()
end

function HowToPlayScene:_handleAButtonDown()
	Cdf.changeScene(MainMenuScene)
end

function HowToPlayScene:_handleBButtonDown()
	Cdf.changeScene(MainMenuScene)
end
