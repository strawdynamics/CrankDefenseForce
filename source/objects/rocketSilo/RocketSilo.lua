local playdate <const> = playdate
local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

local Cdf <const> = Cdf

local rocketSiloImage <const> = gfx.image.new("objects/rocketSilo/rocketSilo")

class('RocketSilo').extends(gfx.sprite)
local RocketSilo <const> = RocketSilo
RocketSilo:implements(StaticEventEmitter)

local BASE_THRUST <const> = 30
local LAUNCHPAD_OFFSET_Y <const> = -16

local BASE_ROCKET_PREP_MS <const> = 1500

function RocketSilo:init(label, x, y)
	self.readyForLaunch = true

	self.label = label
	self.x = x
	self.y = y

	self:setCenter(0.5, 1)
	self:moveTo(x, y)
	self:setImage(rocketSiloImage)

	self.launchPrepTimer = nil

	self:_spawnInitialRocket()
end

function RocketSilo:update()

	if self.rocketPrepAnimator then
		self.rocket:moveTo(self.rocket.x, self.rocketPrepAnimator:currentValue())

		if self.rocketPrepAnimator:ended() then
			self.rocketPrepAnimator = nil
			self.readyForLaunch = true
		end
	end
end

function RocketSilo:attemptLaunch()
	print(self.label, 'attempt launch')

	if self.readyForLaunch then
		self:_launch()
	else
		print('LAUNCH ABORTED')
	end
end

function RocketSilo:_launch()
	self.readyForLaunch = false

	RocketSilo._staticEmit('launch', self, self.rocket)
	self.rocket.thrust = BASE_THRUST

	-- self.launchPrepTimer = timer.
	self:_prepareNextRocket()
end

function RocketSilo:remove()
	RocketSilo.super.remove(self)

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
