local playdate <const> = playdate
local gfx <const> = playdate.graphics
local menu = playdate.getSystemMenu()

class('GameplayScene').extends(BaseScene)
local GameplayScene <const> = GameplayScene

function GameplayScene:init()
	self.enemySpawner = EnemySpawner()
end

function GameplayScene:update()
	if self.enemySpawner then
		self.enemySpawner:update()
	end


	if self.rocket then
		 -- degrees per second
		self.rocket:changeAngle(Cdf.deltaTime * 45)
	end
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

	-- self.enemySpawner = EnemySpawner()
	-- Animate
end

--- Called when transition to this scene is complete
function GameplayScene:start()
	self:_startInput()

	self.rocketController = RocketController()

	self.rocket = Rocket(300, 50, 50)
	self.rocket:add()
	self.enemySpawner:start()
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
	self.siloA:attemptLaunch()
end

function GameplayScene:_handleBButtonDown()
	self.siloB:attemptLaunch()
end

--- Called when transition away from this scene begins
function GameplayScene:exit()
	menu:removeAllMenuItems()

	self.rocketController:exit()

	playdate.inputHandlers.pop()
end

--- Called when transition away from this scene is complete
function GameplayScene:finish()
	self.rocket:remove()
	self.enemySpawner:finish()

	self.siloB:remove()
	self.siloA:remove()
end
