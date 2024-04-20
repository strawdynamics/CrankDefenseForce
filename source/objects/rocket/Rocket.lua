local playdate <const> = playdate
local gfx <const> = playdate.graphics

local rocketImageTable <const> = gfx.imagetable.new("objects/rocket/rocket")

class('Rocket').extends(gfx.sprite)
local Rocket <const> = Rocket

function Rocket:init(x, y, angle)
	Rocket.super.init(self)

	-- self:

	self._x = x
	self._y = y
	self._angle = angle % 360

	self:moveTo(x, y)
	self:_setImage()
end

function Rocket:update()
	self:_setImage()
end

function Rocket:_setImage()
	local newImage = rocketImageTable:getImage(math.ceil(self._angle / 15))
	self:setImage(newImage)
end

function Rocket:changeAngle(delta)
	self._angle = (self._angle + delta) % 360
end
