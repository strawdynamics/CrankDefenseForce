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

	scenePresenter:update()
end

Cdf.changeScene = function(newSceneClass)
	scenePresenter:changeScene(newSceneClass)
end
