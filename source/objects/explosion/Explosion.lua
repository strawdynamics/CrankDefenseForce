local playdate <const> = playdate
local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

class('Explosion').extends(gfx.sprite)
local Explosion <const> = Explosion

local EXPLOSION_RADIUS <const> = 32
local EXPLOSION_DURATION_MS <const> = 1600

function Explosion:init(x, y)
	Explosion.super.init(self)

	self:setSize(EXPLOSION_RADIUS * 2, EXPLOSION_RADIUS * 2)
	self:moveTo(x, y)
	self:setCollideRect(0, 0, self:getSize())
	self:setGroups({COLL_EXPLOSION})
	self:setCollidesWithGroups({COLL_CPU_ROCKET, COLL_PLAYER_ROCKET})

	self.radius = 5
	self.sizeAnimator = gfx.animator.new(EXPLOSION_DURATION_MS * 0.5, 5, EXPLOSION_RADIUS)
	self.sizeAnimator.reverses = true
end

function Explosion:update()
	if self.sizeAnimator:ended() then
		self:remove()
	end
end

function Explosion:draw()
	gfx.setColor(gfx.kColorWhite)
	gfx.setDitherPattern(math.max(0.7 - self.sizeAnimator:progress(), 0.2), gfx.image.kDitherTypeBayer8x8)
	self.radius = self.sizeAnimator:currentValue()
	gfx.fillCircleAtPoint(EXPLOSION_RADIUS, EXPLOSION_RADIUS, self.radius)
end
