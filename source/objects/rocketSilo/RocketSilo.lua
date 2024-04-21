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

local BASE_THRUST <const> = 42
local LAUNCHPAD_OFFSET_Y <const> = -16

local BASE_ROCKET_PREP_MS <const> = 2500

function RocketSilo:init(label, x, y)
	self.readyForLaunch = true

	self.label = label
	self.x = x
	self.y = y

	self:_initLetterSprite()

	self:setCenter(0.5, 1)
	self:moveTo(x, y)
	self:setImage(rocketSiloImage)

	self:_spawnInitialRocket()

	self._intermediateHandleRocketRemove = function(payload)
		self:_handleRocketRemove(payload)
	end
	Rocket.staticOn('remove', self._intermediateHandleRocketRemove)
end

function RocketSilo:_handleRocketRemove(payload)
	if self.removed then
		return
	end

	if self.rocket == payload.rocket then
		self:_prepareNextRocket()
	end
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
		return true
	else
		self:_abortLaunch()
		return false
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

	self:_prepareNextRocket()
end

function RocketSilo:remove()
	RocketSilo.super.remove(self)
	self.removed = true

	self.letterSprite:remove()

	if self.rocket then
		self.rocket:remove()
	end
end

function RocketSilo:_spawnInitialRocket()
	self:_spawnRocket(self.x, self.y + LAUNCHPAD_OFFSET_Y, 0)
end

function RocketSilo:_prepareNextRocket()
	self:_spawnRocket(self.x, self.y, 0)

	self.rocketPrepAnimator = gfx.animator.new(BASE_ROCKET_PREP_MS, self.y, self.y + LAUNCHPAD_OFFSET_Y, playdate.easingFunctions.inBack)
end

function RocketSilo:_spawnRocket(x, y)
	self.rocket = Rocket(x, y, 0)
	self.rocket:setGroups({COLL_PLAYER_ROCKET})
	self.rocket:setCollidesWithGroups({COLL_CITY, COLL_CPU_ROCKET, COLL_PLAYER_ROCKET, COLL_EXPLOSION})
	self.rocket:add()
end
