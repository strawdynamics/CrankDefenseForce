local playdate <const> = playdate
local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

class('GameResults').extends()
local GameResults <const> = GameResults

local BG_WIDTH <const> = 300
local BG_HEIGHT <const> = 180

gfx.pushContext()
gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
gfx.setFont(fonts.lexendDecaBold32)
local defeatImage <const> = gfx.imageWithText(
	gfx.getLocalizedText("gameResults.defeat"),
	280,
	48,
	gfx.kColorClear,
	0, -- leading,
	"…",
	kTextAlignment.center
)
gfx.popContext()

gfx.pushContext()
gfx.setFont(fonts.nicoPups16)
local returnImage <const> = imageWithTextStroked(
	gfx.getLocalizedText("gameResults.return"),
	280,
	30,
	0, -- leading,
	"…",
	kTextAlignment.center,
	3,
	gfx.kDrawModeFillWhite
)
gfx.popContext()

function GameResults:init(payload)
	self.score = payload.score
	self.duration = payload.duration

	self:_buildTimeImage()
	self:_buildScoreImage()

	self.backgroundAnimator = gfx.animator.new(1200, 0, 1, playdate.easingFunctions.outBounce)

	timer.performAfterDelay(500, function()
		self.defeatAnimator = gfx.animator.new(600, 20, 0, playdate.easingFunctions.outCirc)
	end)

	timer.performAfterDelay(650, function()
		self.timeAnimator = gfx.animator.new(600, 15, 0, playdate.easingFunctions.outCirc)
	end)

	timer.performAfterDelay(800, function()
		self.scoreAnimator = gfx.animator.new(600, 15, 0, playdate.easingFunctions.outCirc)
	end)

	timer.performAfterDelay(1500, function()
		self.returnAnimator = gfx.animator.new(600, 10, 0, playdate.easingFunctions.outCirc)

		playdate.inputHandlers.push({
			AButtonDown = function()
				self:_handleAButtonDown()
			end,

			BButtonDown = function()
				self:_handleBButtonDown()
			end,
		})
	end)
end

function GameResults:update()
	self:_drawBackground()

	if self.defeatAnimator then
		self:_drawDefeat()
	end
	if self.timeAnimator then
		self:_drawTime()
	end
	if self.scoreAnimator then
		self:_drawScore()
	end
	if self.returnAnimator then
		self:_drawReturn()
	end
end

function GameResults:_buildTimeImage()
	self.timeImage = gfx.image.new(260, 20)
	gfx.pushContext(self.timeImage)
	gfx.setFont(fonts.nicoClean16)
	gfx.drawText(gfx.getLocalizedText("gameResults.time"), 0, 0)

	gfx.drawTextAligned(formatSecondsForDisplay(self.duration), 260, 0, kTextAlignment.right)
	gfx.popContext()
end

function GameResults:_buildScoreImage()
	self.scoreImage = gfx.image.new(260, 20)
	gfx.pushContext(self.scoreImage)
	gfx.setFont(fonts.nicoClean16)
	gfx.drawText(gfx.getLocalizedText("gameResults.score"), 0, 0)

	gfx.drawTextAligned(self.score, 260, 0, kTextAlignment.right)
	gfx.popContext()
end

function GameResults:_drawBackground()
	local mul = self.backgroundAnimator:currentValue()
	local w = BG_WIDTH * mul
	local h = BG_HEIGHT * mul

	gfx.pushContext()
	gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
	gfx.fillRoundRect(
		200 - (w * 0.5),
		120 - (h * 0.5),
		w,
		h,
		5
	)
	gfx.popContext()
end

function GameResults:_drawDefeat()
	defeatImage:drawAnchored(200, 60 + (self.defeatAnimator:currentValue()), 0.5, 0.5)
end

function GameResults:_drawTime()
	self.timeImage:drawAnchored(200, 110 + (self.timeAnimator:currentValue()), 0.5, 0.5)
end

function GameResults:_drawScore()
	self.scoreImage:drawAnchored(200, 140 + (self.scoreAnimator:currentValue()), 0.5, 0.5)
end

function GameResults:_drawReturn()
	returnImage:drawAnchored(200, 180 + (self.returnAnimator:currentValue()), 0.5, 0.5)
end

function GameResults:exit()
	playdate.inputHandlers.pop()
end

function GameResults:_handleAButtonDown()
	self:exit()
	Cdf.changeScene(MainMenuScene)
end

function GameResults:_handleBButtonDown()
	self:exit()
	Cdf.changeScene(MainMenuScene)
end
