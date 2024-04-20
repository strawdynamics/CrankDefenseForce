local playdate <const> = playdate
local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

local Cdf <const> = Cdf

local rocketSiloImage <const> = gfx.image.new("objects/rocketSilo/rocketSilo")

local letterAImage <const> = gfx.image.new("objects/rocketSilo/siloLetterA")
local letterBImage <const> = gfx.image.new("objects/rocketSilo/siloLetterB")

class('RocketSilo').extends(gfx.sprite)
local RocketSilo <const> = RocketSilo
RocketSilo:implements(StaticEventEmitter)

local BASE_THRUST <const> = 40
local LAUNCHPAD_OFFSET_Y <const> = -16

local BASE_ROCKET_PREP_MS <const> = 1500

function RocketSilo:init(label, x, y)
	self.readyForLaunch = true

	self.label = label
	self.x = x
	self.y = y

	self:_initLetterSprite()

	self:setCenter(0.5, 1)
	self:moveTo(x, y)
	self:setImage(rocketSiloImage)

	self.launchPrepTimer = nil

	self:_spawnInitialRocket()
end

function RocketSilo:_initLetterSprite()
	if self.label == 'A' then
		self.letterSprite = gfx.sprite.new(letterAImage)
	else
		self.letterSprite = gfx.sprite.new(letterBImage)
	end

	self.letterSprite:moveTo(self.x, self.y - 4)
	self.letterSprite:add()
	self.letterSprite:setZIndex(10)
end

function RocketSilo:update()
	if self.rocketPrepAnimator then
		self.rocket:moveTo(self.rocket.x, self.rocketPrepAnimator:currentValue())

		if self.rocketPrepAnimator:ended() then
			self.rocketPrepAnimator = nil
			self.readyForLaunch = true
		end
	end

	if self.abortAnimator then
		self.letterSprite:moveTo(self.x + self.abortAnimator:currentValue(), self.letterSprite.y)

		if self.abortAnimator:ended() then
			self.abortAnimator = nil
			self.letterSprite:moveTo(self.x, self.letterSprite.y)
		end
	end
end

function RocketSilo:attemptLaunch()
	if self.readyForLaunch then
		self:_launch()
	else
		self:_abortLaunch()
	end
end

function RocketSilo:_abortLaunch()
	self.abortAnimator = gfx.animator.new(120, -2, 2, playdate.easingFunctions.inOutCubic)
	self.abortAnimator.repeatCount = 1
	self.abortAnimator.reverses = true
end

function RocketSilo:_launch()
	self.readyForLaunch = false

	self.rocket.thrust = BASE_THRUST
	RocketSilo._staticEmit('launch', { silo = self, rocket = self.rocket })

	-- self.launchPrepTimer = timer.
	self:_prepareNextRocket()
end

function RocketSilo:remove()
	RocketSilo.super.remove(self)

	self.letterSprite:remove()

	if self.rocket then
		self.rocket:remove()
	end
end

function RocketSilo:_spawnInitialRocket()
	self.rocket = Rocket(self.x, self.y + LAUNCHPAD_OFFSET_Y, 0)
	self.rocket:add()
end

function RocketSilo:_prepareNextRocket()
	self.rocket = Rocket(self.x, self.y, 0)
	self.rocket:add()

	self.rocketPrepAnimator = gfx.animator.new(BASE_ROCKET_PREP_MS, self.y, self.y + LAUNCHPAD_OFFSET_Y, playdate.easingFunctions.inBack)
end
