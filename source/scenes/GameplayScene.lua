local playdate <const> = playdate
local gfx <const> = playdate.graphics

class('GameplayScene').extends(BaseScene)
local GameplayScene <const> = GameplayScene

function GameplayScene:init()
	--
end

--- Called each frame
function GameplayScene:update()
	if playdate.buttonJustPressed(playdate.kButtonA) then
		Cdf.changeScene(MainMenuScene)
	end


	if self.rocket then
		self.rocket:changeAngle(Cdf.deltaTime * 45) -- degrees per second
	end
end

--- Called when transition to this scene begins
function GameplayScene:enter()
	-- Animate
end

--- Called when transition to this scene is complete
function GameplayScene:start()
	-- Begin handling input
	self.rocket = Rocket(300, 50, 50)
	self.rocket:add()
end

--- Called when transition away from this scene begins
function GameplayScene:exit()
	-- Stop handling input
end

--- Called when transition away from this scene is complete
function GameplayScene:finish()
	self.rocket:remove()
	--
end
