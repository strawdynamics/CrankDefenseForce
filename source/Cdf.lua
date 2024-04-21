local playdate <const> = playdate
local gfx <const> = playdate.graphics
local timer <const> = playdate.timer

Cdf = {}

local scenePresenter = nil

Cdf.init = function()
	math.randomseed(playdate.getSecondsSinceEpoch())

	Cdf.deltaTime = 0

	playdate.display.setRefreshRate(40)
	gfx.sprite.setAlwaysRedraw(true)

	gfx.setBackgroundColor(gfx.kColorBlack)

	scenePresenter = ScenePresenter()
end

Cdf.update = function()
	timer.updateTimers()

	Cdf.deltaTime = playdate.getElapsedTime()
	playdate.resetElapsedTime()

	gfx.clear()
	gfx.sprite.update()
	scenePresenter:update()

	-- playdate.drawFPS(192, 0)
end

Cdf.changeScene = function(newSceneClass)
	scenePresenter:changeScene(newSceneClass)
end
