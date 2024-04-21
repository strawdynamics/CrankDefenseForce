local playdate <const> = playdate
local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

class('Scorekeeper').extends()
local Scorekeeper <const> = Scorekeeper
Scorekeeper:implements(StaticEventEmitter)

function Scorekeeper:init()
	self._intermediateHandleRocketExplodedByExplosion = function(payload)
		self:_handleRocketExplodedByExplosion(payload)
	end
	self._intermediateHandleRocketCpuDestroyedByPlayer = function(payload)
		self:_handleRocketCpuDestroyedByPlayer(payload)
	end
	self._intermediateHandleCityHit = function(payload)
		self:_handleCityHit(payload)
	end

	self.score = 0

	self.scoreImage = gfx.image.new(90, 20)
	self.scoreSprite = gfx.sprite.new(self.scoreImage)
	self.scoreSprite:setCenter(0, 0)
	self.scoreSprite:moveTo(3, 0)
	self.scoreSprite:add()
	self:_redrawScore()
end

function Scorekeeper:start()
	self.running = true
	self.score = 0
	self.duration = 0
	self.destroyedCityCount = 0

	Rocket.staticOn('explodedByExplosion', self._intermediateHandleRocketExplodedByExplosion)
	Rocket.staticOn('cpuDestroyedByPlayer', self._intermediateHandleRocketCpuDestroyedByPlayer)
	City.staticOn('hit', self._intermediateHandleCityHit)
end

function Scorekeeper:update()
	if self.running then
		self.duration += Cdf.deltaTime
	end
end

function Scorekeeper:stop()
	self.running = true
	Rocket.staticOff('explodedByExplosion', self._intermediateHandleRocketExplodedByExplosion)
	Rocket.staticOff('cpuDestroyedByPlayer', self._intermediateHandleRocketCpuDestroyedByPlayer)
	City.staticOff('hit', self._intermediateHandleCityHit)
end

function Scorekeeper:exit()
	self.scoreSprite:remove()
end

function Scorekeeper:_handleRocketExplodedByExplosion(_payload)
	self.score += 5
	self:_redrawScore()
end

function Scorekeeper:_handleRocketCpuDestroyedByPlayer(_payload)
	self.score += 15
	self:_redrawScore()
end

function Scorekeeper:_handleCityHit(payload)
	self:_redrawScore()

	if payload.isNewlyDestroyed then
		self.destroyedCityCount += 1

		if self.destroyedCityCount == 5 then
			self:stop()
			self:_staticEmit(
				'gameOver',
				{score = self.score, duration = self.duration}
			)
		end
	else
		-- Small penalty for already destroyed cities
		self.score = math.max(0, self.score - 5)
	end
end

function Scorekeeper:_redrawScore()
	gfx.pushContext(self.scoreImage)
	gfx.clear()
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.setFont(fonts.nicoPups16)
	gfx.drawText(
		gfx.getLocalizedText('scorekeeper.scorePrefix') ..
		self.score ..
		gfx.getLocalizedText('scorekeeper.scoreSuffix'),
		0,
		0
	)
	-- gfx.setColor(gfx.kColorWhite)
	-- gfx.fillRect(0, 0, 90, 20)
	gfx.popContext()
end
