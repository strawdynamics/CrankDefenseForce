local playdate <const> = playdate
local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

local Cdf <const> = Cdf

class('EnemySpawner').extends()
local EnemySpawner <const> = EnemySpawner

local SPAWN_PAUSE_BASE_MS <const> = 5000
local BASE_ROCKET_THRUST <const> = 10

function EnemySpawner:init(cities)
	self.cities = cities
	self.uptime = 0
	self.started = false
	self.spawnTimer = nil
	self.spawnPauseCoefficient = 1

	self._intermediateHandleRocketRemove = function(payload)
		self:_handleRocketRemove(payload)
	end
	Rocket.staticOn('remove', self._intermediateHandleRocketRemove)
end

function EnemySpawner:start()
	self.uptime = 0
	self.started = true
	self.difficulty = 1
	self.rocketThrustModifier = 0
	self.rockets = {}

	self:spawnAndSchedule()
end

function EnemySpawner:update()
	if not self.started then
		return
	end

	self.uptime += Cdf.deltaTime
	self:_updateDifficulty()

	for i, rocket in ipairs(self.rockets) do
		if rocket.y > 280 then
			rocket:remove()
		end
	end
end

function EnemySpawner:_updateDifficulty()
	if self.uptime > 300 then
		self.difficulty = 6
		self.rocketThrustModifier = 6
		self.spawnPauseCoefficient = 0.25
	elseif self.uptime > 240 then
		self.difficulty = 5
		self.rocketThrustModifier = 4
		self.spawnPauseCoefficient = 0.5
	elseif self.uptime > 150 then
		self.difficulty = 4
		self.rocketThrustModifier = 2
		self.spawnPauseCoefficient = 0.65
	elseif self.uptime > 90 then
		self.difficulty = 3
		self.rocketThrustModifier = 1
		self.spawnPauseCoefficient = 0.8
	elseif self.uptime > 45 then
		self.difficulty = 2
		self.spawnPauseCoefficient = 0.9
	end
end

function EnemySpawner:spawnAndSchedule()
	-- Spawn one or more enemies
	self:_spawn()

	-- Schedule next spawn
	-- 0.8 - 1.2
	local rndAdjustPct = 0.8 + math.random() * 0.4
	local duration = SPAWN_PAUSE_BASE_MS * rndAdjustPct * self.spawnPauseCoefficient
	self.spawnTimer = playdate.timer.new(duration, function()
		self:spawnAndSchedule()
	end)
end

function EnemySpawner:_spawn()
	if self.difficulty > 5 then
		-- 6
		-- Lower UFOs
		self:_spawnRocket()
	elseif self.difficulty > 3 then
		-- 4, 5
		-- More UFOs
		self:_spawnRocket()
	elseif self.difficulty > 2 then
		-- 3
		-- Add UFOs
		self:_spawnRocket()
	else
		-- 1, 2
		self:_spawnRocket()
	end
end

function EnemySpawner:_spawnRocket()
	local x = math.random(-40, 440)
	local y = -20

	local targetCity = self.cities[math.random(1, #self.cities)]
	local targetX = targetCity.x + math.random(-10, 10)
	local targetY = targetCity.y - 5

	local down = playdate.geometry.vector2D.new(0, -1)
	local vecToTarget = playdate.geometry.vector2D.new(targetX - x, targetY - y)
	vecToTarget:normalize()
	local angleToTarget = down:angleBetween(vecToTarget)

	local rocket = Rocket(x, y, angleToTarget)
	rocket:setGroups({COLL_CPU_ROCKET})
	rocket:setCollidesWithGroups({COLL_CITY, COLL_PLAYER_ROCKET, COLL_EXPLOSION})
	rocket.thrust = BASE_ROCKET_THRUST + self.rocketThrustModifier
	rocket:add()

	table.insert(self.rockets, rocket)
end

function EnemySpawner:_handleRocketRemove(payload)
	for i, rocket in ipairs(self.rockets) do
		if rocket == payload.rocket then
			table.remove(self.rockets, i)
			return
		end
	end
end

function EnemySpawner:finish()
	-- Iterate backwards to properly remove during iteration
	for i = #self.rockets, 1, -1 do
		local rocket = self.rockets[i]
		rocket:remove()
	end

	Rocket.staticOff('remove', self._intermediateHandleRocketRemove)

	self.started = false
	if self.spawnTimer ~= nil then
		self.spawnTimer:remove()
		self.spawnTimer = nil
	end
end
