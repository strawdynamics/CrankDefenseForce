local playdate <const> = playdate
local gfx <const> = playdate.graphics

class('AboutScene').extends(BaseScene)
local AboutScene <const> = AboutScene

gfx.pushContext()
gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
gfx.setFont(fonts.nicoPups16)
local storyImage = gfx.imageWithText(gfx.getLocalizedText("aboutScene.about"), 360, 1000)
gfx.popContext()

--- Typical constructor, called when scene object is created
function AboutScene:init()
	--
end

--- Called each frame
function AboutScene:update()
	--
end

--- Called when transition to this scene begins
function AboutScene:enter()
	self.aboutSprite = gfx.sprite.new(storyImage)
	self.aboutSprite:setCenter(0, 0)
	self.aboutSprite:moveTo(20, 45)
	self.aboutSprite:add()
end

--- Called when transition to this scene is complete
function AboutScene:start()
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
function AboutScene:exit()
	playdate.inputHandlers.pop()
end

--- Called when transition away from this scene is complete
function AboutScene:finish()
	self.aboutSprite:remove()
end

function AboutScene:_handleAButtonDown()
	Cdf.changeScene(MainMenuScene)
end

function AboutScene:_handleBButtonDown()
	Cdf.changeScene(MainMenuScene)
end
