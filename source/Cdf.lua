local playdate <const> = playdate
local gfx <const> = playdate.graphics

Cdf = {}

local scenePresenter = nil

Cdf.init = function()
	Cdf.deltaTime = 0
	playdate.display.setRefreshRate(50)

	gfx.setBackgroundColor(gfx.kColorBlack)

	scenePresenter = ScenePresenter()
end

Cdf.update = function()
	Cdf.deltaTime = playdate.getElapsedTime()
	playdate.resetElapsedTime()

	gfx.clear()

	gfx.sprite.update()

	scenePresenter:update()

	playdate.drawFPS(192, 0)
end

Cdf.changeScene = function(newSceneClass)
	scenePresenter:changeScene(newSceneClass)
end
