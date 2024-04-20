local playdate <const> = playdate
local gfx <const> = playdate.graphics

local cityImageTable <const> = gfx.imagetable.new("objects/city/city")

class('City').extends(gfx.sprite)
local City <const> = City

function City:init(x, y)
	City.super.init(self)

	self:setImage(cityImageTable:getImage(1))
	self:setCenter(0.5, 1)
	self:moveTo(x, y)
end

function City:update()
	--
end
