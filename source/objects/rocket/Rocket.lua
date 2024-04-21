local playdate <const> = playdate
local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

local rocketImageTable <const> = gfx.imagetable.new("objects/rocket/rocket")
local rocketExhaustImageTable <const> = gfx.imagetable.new("objects/rocket/rocket-exhaust")

class('Rocket').extends(gfx.sprite)
local Rocket <const> = Rocket
Rocket:implements(StaticEventEmitter)

function Rocket:init(x, y, angle)
	Rocket.super.init(self)

	self.x = x
	self.y = y
	self.angle = angle % 360
	self.thrust = 0

	self.cos = 0
	self.sin = 0

	self.exhaust = RocketExhaust(self)
	self.exhaust:add()

	self:moveTo(x, y)
	self:_setImage()
	self:setCollideRect(0, 0, self:getSize())
end

function Rocket:update()
	local radAngle = math.rad(self.angle - 90)
	self.cos = math.cos(radAngle)
	self.sin = math.sin(radAngle)

	if self.thrust == 0 then
		self.exhaust:setVisible(false)
	else
		self.exhaust:setVisible(true)

		-- Apply thrust
		local deltaX = self.thrust * Cdf.deltaTime * self.cos
		local deltaY = self.thrust * Cdf.deltaTime * self.sin

		self:moveBy(deltaX, deltaY)

		self:_updateCollision()
	end

	self:_setImage()
end

function Rocket:_updateCollision()
	for i, otherSprite in ipairs(self:overlappingSprites()) do
		if otherSprite:isa(Explosion) then
			if playdate.geometry.distanceToPoint(self.x, self.y, otherSprite.x, otherSprite.y) <= otherSprite.radius then
				self:explode()
			end

			return
		end

		if not self:alphaCollision(otherSprite) then
			return
		end

		self:explode()

		if otherSprite:isa(Rocket) then
			otherSprite:remove()
		elseif otherSprite:isa(City) then
			timer.performAfterDelay(300, function()
				otherSprite:destroy()
			end)
		end
	end
end

function Rocket:_setImage()
	local newImage = rocketImageTable:getImage(
		(roundToNearest(self.angle, 15) % 360) / 15 + 1
	)
	self:setImage(newImage)
end

function Rocket:changeAngle(delta)
	self.angle = (self.angle + delta) % 360
end

function Rocket:explode()
	local explosion = Explosion(self.x, self.y)
	explosion:add()

	self:remove()
end

function Rocket:remove()
	Rocket._staticEmit('remove', { rocket = self })
	Rocket.super.remove(self)
	self.exhaust:remove()
end
