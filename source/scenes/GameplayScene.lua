local playdate <const> = playdate
local gfx <const> = playdate.graphics
local menu = playdate.getSystemMenu()

class('GameplayScene').extends(BaseScene)
local GameplayScene <const> = GameplayScene

function GameplayScene:init()
	self.enemySpawner = nil
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

	self.enemySpawner = EnemySpawner()
	-- Animate
end

--- Called when transition to this scene is complete
function GameplayScene:start()
	-- Begin handling input

	self.rocket = Rocket(300, 50, 50)
	self.rocket:add()
	self.enemySpawner:start()
end

--- Called when transition away from this scene begins
function GameplayScene:exit()
	menu:removeAllMenuItems()
	-- Stop handling input
end

--- Called when transition away from this scene is complete
function GameplayScene:finish()
	self.rocket:remove()
	self.enemySpawner:finish()
end
