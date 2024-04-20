local playdate <const> = playdate
local gfx <const> = playdate.graphics

local Cdf <const> = Cdf

class('RocketController').extends()
local RocketController <const> = RocketController

local CRANK_COEFFICIENT <const> = 0.3

function RocketController:init()
	self.rocket = nil

	playdate.inputHandlers.push({
		cranked = function(change, acceleratedChange)
			self:_handleCranked(change, acceleratedChange)
		end
	})

	self._intermediateHandleSiloLaunch = function(payload)
		self:_handleSiloLaunch(payload)
	end
	RocketSilo.staticOn('launch', self._intermediateHandleSiloLaunch)
end

function RocketController:update()
	--
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

	self.rocket.angle += change * CRANK_COEFFICIENT
end
