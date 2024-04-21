local playdate <const> = playdate
local gfx <const> = playdate.graphics

local cityImageTable <const> = gfx.imagetable.new("objects/city/city")

class('City').extends(gfx.sprite)
local City <const> = City
City:implements(StaticEventEmitter)

function City:init(x, y)
	City.super.init(self)

	self.isDestroyed = false

	self:setImage(cityImageTable:getImage(1))
	self:setCenter(0.5, 1)
	self:moveTo(x, y)
	self:setCollideRect(0, 0, self:getSize())
	self:setGroups({COLL_CITY})
	self:setCollidesWithGroups({COLL_CPU_ROCKET, COLL_PLAYER_ROCKET})
end

function City:update()
	--
end

function City:destroy()
	City._staticEmit('hit', { city = self, isNewlyDestroyed = not self.isDestroyed })

	self.isDestroyed = true
	self:setImage(cityImageTable:getImage(2))
end
