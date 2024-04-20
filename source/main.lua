import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"

import "util/mixin"

import "mixins/EventEmitter"

import "Cdf"

import "scenes/BaseScene"
import "scenes/MainMenuScene"
import "scenes/GameplayScene"
import "scenes/TestScene"

import "objects/scenePresenter/ScenePresenter"
import "objects/rocket/Rocket"
import "objects/rocket/RocketExhaust"


local playdate <const> = playdate

Cdf.init()

playdate.update = function()
	Cdf.update()
end
