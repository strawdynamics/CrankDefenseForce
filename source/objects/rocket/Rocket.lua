local playdate <const> = playdate
local gfx <const> = playdate.graphics

local rocketImageTable <const> = gfx.imagetable.new("objects/rocket/rocket")
local rocketExhaustImageTable <const> = gfx.imagetable.new("objects/rocket/rocket-exhaust")

class('Rocket').extends(gfx.sprite)
local Rocket <const> = Rocket

function Rocket:init(x, y, angle)
	Rocket.super.init(self)

	self.x = x
	self.y = y
	self.angle = angle % 360
	self.thrust = 20

	self.cos = 0
	self.sin = 0

	self.exhaust = RocketExhaust(self)
	self.exhaust:add()

	self:moveTo(x, y)
	self:_setImage()
end

function Rocket:update()
	local radAngle = math.rad(self.angle - 90)
	self.cos = math.cos(radAngle)
	self.sin = math.sin(radAngle)

	local newX = self.x + (self.thrust * Cdf.deltaTime * self.cos)
	local newY = self.y + (self.thrust * Cdf.deltaTime * self.sin)

	self.x = newX
	self.y = newY
	self:moveTo(newX, newY)

	self:_setImage()
end

function Rocket:_setImage()
	local newImage = rocketImageTable:getImage(math.ceil(self.angle / 15))
	self:setImage(newImage)
end

function Rocket:changeAngle(delta)
	self.angle = (self.angle + delta) % 360
end

function Rocket:remove()
	Rocket.super.remove(self)
	self.exhaust:remove()
end
