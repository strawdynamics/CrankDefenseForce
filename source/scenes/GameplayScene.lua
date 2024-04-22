local playdate <const> = playdate
local gfx <const> = playdate.graphics
local menu = playdate.getSystemMenu()

class('GameplayScene').extends(BaseScene)
local GameplayScene <const> = GameplayScene

function GameplayScene:init()
	self.scorekeeper = Scorekeeper()
	self.gameOver = false
end

function GameplayScene:update()
	if self.enemySpawner then
		self.enemySpawner:update()
	end

	if self.rocketController then
		self.rocketController:update()
	end

	self.scorekeeper:update()
end

--- Called when transition to this scene begins
function GameplayScene:enter()
	menu:removeAllMenuItems()
	menu:addMenuItem(
		gfx.getLocalizedText('systemMenu.titleScreen'),
		function()
			Cdf.changeScene(MainMenuScene)
		end
	)

	self.siloB = RocketSilo('B', 15, 240)
	self.siloB:add()
	self.siloA = RocketSilo('A', 400 - 15, 240)
	self.siloA:add()

	self.cities = {
		City(70, 240),
		City(135, 240),
		City(200, 240),
		City(400 - 135, 240),
		City(400 - 70, 240),
	}

	for i, city in ipairs(self.cities) do
		city:add()
	end

	self.enemySpawner = EnemySpawner(self.cities)
end

--- Called when transition to this scene is complete
function GameplayScene:start()
	self:_startInput()

	self.rocketController = RocketController()

	self.scorekeeper:start()
	self.enemySpawner:start()

	self._intermediateHandleGameOver = function(payload)
		self:_handleGameOver(payload)
	end
	Scorekeeper.staticOn('gameOver', self._intermediateHandleGameOver)
end

function GameplayScene:_startInput()
	playdate.inputHandlers.push({
		AButtonDown = function()
			self:_handleAButtonDown()
		end,

		BButtonDown = function()
			self:_handleBButtonDown()
		end
	})
end

function GameplayScene:_handleAButtonDown()
	if self.gameOver then
		return
	end

	self.siloA:attemptLaunch()
end

function GameplayScene:_handleBButtonDown()
	if self.gameOver then
		return
	end

	self.siloB:attemptLaunch()
end

--- Called when transition away from this scene begins
function GameplayScene:exit()
	menu:removeAllMenuItems()

	Scorekeeper.staticOff('gameOver', self._intermediateHandleGameOver)

	self.scorekeeper:stop()
	self.scorekeeper:exit()

	self.rocketController:exit()

	playdate.inputHandlers.pop()
end

--- Called when transition away from this scene is complete
function GameplayScene:finish()
	for i, city in ipairs(self.cities) do
		city:remove()
	end

	self.enemySpawner:finish()

	self.siloB:remove()
	self.siloA:remove()
end

-- Raised by Scorekeeper
function GameplayScene:_handleGameOver(payload)
	self.gameOver = true
	self.rocketController:handleGameOver()


	print('TODO: SHOW GameResults')
end
