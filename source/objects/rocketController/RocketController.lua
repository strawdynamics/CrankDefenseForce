local playdate <const> = playdate
local gfx <const> = playdate.graphics

local Cdf <const> = Cdf

class('RocketController').extends()
local RocketController <const> = RocketController

local CRANK_COEFFICIENT <const> = 0.3
local BUTTON_ROTATE_DPS <const> = 180

function RocketController:init()
	self.rocket = nil
	self.isLeftDown = false
	self.isRightDown = false

	playdate.inputHandlers.push({
		cranked = function(change, acceleratedChange)
			self:_handleCranked(change, acceleratedChange)
		end,

		leftButtonDown = function()
			self:_handleLeftButtonDown()
		end,

		leftButtonUp = function()
			self:_handleLeftButtonUp()
		end,

		rightButtonDown = function()
			self:_handleRightButtonDown()
		end,

		rightButtonUp = function()
			self:_handleRightButtonUp()
		end
	})

	self._intermediateHandleSiloLaunch = function(payload)
		self:_handleSiloLaunch(payload)
	end
	RocketSilo.staticOn('launch', self._intermediateHandleSiloLaunch)
end

function RocketController:update()
	if self.isLeftDown then
		self.rocket:changeAngle(Cdf.deltaTime * -BUTTON_ROTATE_DPS)
	elseif self.isRightDown then
		self.rocket:changeAngle(Cdf.deltaTime * BUTTON_ROTATE_DPS)
	end
end

function RocketController:_handleSiloLaunch(payload)
	self.rocket = payload.rocket
end

function RocketController:exit()
	RocketSilo.staticOff('launch', self._intermediateHandleSiloLaunch)
	playdate.inputHandlers.pop()
end

function RocketController:_handleCranked(change, _acceleratedChange)
	if not self.rocket then
		return
	end

	if self.isLeftDown or self.isRightDown then
		return
	end

	self.rocket.angle += change * CRANK_COEFFICIENT
end

function RocketController:_handleLeftButtonDown()
	self.isLeftDown = true
end

function RocketController:_handleLeftButtonUp()
	self.isLeftDown = false
end

function RocketController:_handleRightButtonDown()
	self.isRightDown = true
end

function RocketController:_handleRightButtonUp()
	self.isRightDown = false
end
