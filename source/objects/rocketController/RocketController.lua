local playdate <const> = playdate
local gfx <const> = playdate.graphics

local Cdf <const> = Cdf

class('RocketController').extends()
local RocketController <const> = RocketController

local cursorImage <const> = gfx.image.new("objects/rocketController/cursor")

local CRANK_COEFFICIENT <const> = 0.3
local BUTTON_ROTATE_DPS <const> = 180

function RocketController:init()
	self.rocket = nil
	self.currentRocketIndex = -1
	self.rockets = {}

	self.isLeftDown = false
	self.isRightDown = false

	self.cursor = gfx.sprite.new(cursorImage)
	self.cursor:moveTo(200, 120)
	self.cursor:setScale(0)
	self.cursor:add()
	self.isCursorHidden = true

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
		end,

		downButtonDown = function()
			self:_handleDownButtonDown()
		end
	})

	self._intermediateHandleSiloLaunch = function(payload)
		self:_handleSiloLaunch(payload)
	end
	RocketSilo.staticOn('launch', self._intermediateHandleSiloLaunch)
end

function RocketController:update()
	self:_updateCursor()
	self:_updateOobRockets()

	if self.rocket then
		if self.isLeftDown then
			self.rocket:changeAngle(Cdf.deltaTime * -BUTTON_ROTATE_DPS)
		elseif self.isRightDown then
			self.rocket:changeAngle(Cdf.deltaTime * BUTTON_ROTATE_DPS)
		end
	end
end

function RocketController:_updateOobRockets()
	local removedCurrentRocket = false

	-- Iterate backwards so removal doesn't mess up position
	for i = #self.rockets, 1, -1 do
		local rocket = self.rockets[i]

		if rocket.y > 260 or rocket.y < -20 or rocket.x < -20 or rocket.x > 420 then
			if rocket == self.rocket then
				self.rocket = nil
				self.currentRocketIndex = -1
				removedCurrentRocket = true
			end

			rocket:remove()
			table.remove(self.rockets, i)
		end
	end

	if removedCurrentRocket and #self.rockets > 0 then
		self.currentRocketIndex = #self.rockets
		self.rocket = self.rockets[self.currentRocketIndex]
	end
end

function RocketController:_updateCursor()
	if self.rocket then
		if self.isCursorHidden then
			-- Show cursor
			self.isCursorHidden = false
			self.cursorAnimator = gfx.animator.new(240, 0, 1, playdate.easingFunctions.outBounce)
		end

		local newCursorX = playdate.math.lerp(self.cursor.x, self.rocket.x, 0.5)
		local newCursorY = playdate.math.lerp(self.cursor.y, self.rocket.y, 0.5)

		self.cursor:moveTo(newCursorX, newCursorY)
	elseif not self.isCursorHidden then
		-- Hide cursor
		self.isCursorHidden = true
		self.cursorAnimator = gfx.animator.new(240, 1, 0, playdate.easingFunctions.outBounce)
	end

	if self.cursorAnimator then
		self.cursor:setScale(self.cursorAnimator:currentValue())

		if self.cursorAnimator:ended() then
			self.cursorAnimator = nil
		end
	end
end

function RocketController:_handleSiloLaunch(payload)
	self.rocket = payload.rocket
	table.insert(self.rockets, self.rocket)
	self.currentRocketIndex = #self.rockets
end

function RocketController:_selectPreviousRocket()
	if self.currentRocketIndex == -1 then
		return
	end

	self.currentRocketIndex -= 1

	if self.currentRocketIndex == 0 then
		self.currentRocketIndex = #self.rockets
	end

	self.rocket = self.rockets[self.currentRocketIndex]
end

function RocketController:exit()
	RocketSilo.staticOff('launch', self._intermediateHandleSiloLaunch)
	playdate.inputHandlers.pop()

	self.cursor:remove()
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

function RocketController:_handleDownButtonDown()
	self:_selectPreviousRocket()
end
