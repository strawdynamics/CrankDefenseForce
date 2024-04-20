import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "util/mixin"

import "mixins/EventEmitter"

import "scenes/BaseScene"
import "scenes/MainMenuScene"
import "scenes/TestScene"

import "Cdf"

import "objects/scenePresenter/ScenePresenter"
import "objects/rocket/Rocket"


local playdate <const> = playdate

Cdf.init()

playdate.update = function()
	Cdf.update()
end
