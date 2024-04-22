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

local MENU_OPTIONS <const> = {
	gfx.getLocalizedText("mainMenuScene.play"),
	gfx.getLocalizedText("mainMenuScene.howToPlay"),
	gfx.getLocalizedText("mainMenuScene.about"),
}

--- Typical constructor, called when scene object is created
function MainMenuScene:init()
	self.titleSprite = gfx.sprite.new(titleTextImage)
	self.titleSprite:setCenter(0, 0)
	self.titleSprite:moveTo(20, 10)
end

--- Called each frame
function MainMenuScene:update()
	if self.gridview then
		self.gridview:drawInRect(20, 130, 360, 100)
	end
end

--- Called when transition to this scene begins
function MainMenuScene:enter()
	self.titleSprite:add()

	-- 0 means full-width
	self.gridview = playdate.ui.gridview.new(0, 30)
	self.gridview:setNumberOfRows(#MENU_OPTIONS)
	function self.gridview:drawCell(section, row, column, selected, x, y, width, height)

		gfx.setFont(fonts.nicoClean16)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

		if selected then
			gfx.setColor(gfx.kColorWhite)
			gfx.fillTriangle(
				x + 0, y,
				x + 9, y + 6,
				x + 0, y + 12
			)
		end

		local textX = x
		if selected then
			textX += 16
		end

		gfx.drawText(MENU_OPTIONS[row], textX, y)
	end
end

--- Called when transition to this scene is complete
function MainMenuScene:start()
	playdate.inputHandlers.push({
		downButtonDown = function()
			self:_handleDownButtonDown()
		end,

		upButtonDown = function()
			self:_handleUpButtonDown()
		end,

		AButtonDown = function()
			self:_handleAButtonDown()
		end,
	})
end

--- Called when transition away from this scene begins
function MainMenuScene:exit()
	playdate.inputHandlers.pop()
end

--- Called when transition away from this scene is complete
function MainMenuScene:finish()
	self.titleSprite:remove()
end

function MainMenuScene:_handleDownButtonDown()
	self.gridview:selectNextRow(true, false, false)
end

function MainMenuScene:_handleUpButtonDown()
	self.gridview:selectPreviousRow(true, false, false)
end

function MainMenuScene:_handleAButtonDown()
	local row = self.gridview:getSelectedRow()

	if row == 1 then
		Cdf.changeScene(GameplayScene)
	elseif row == 2 then
		Cdf.changeScene(HowToPlayScene)
	elseif row == 3 then
		Cdf.changeScene(AboutScene)
	end
end
