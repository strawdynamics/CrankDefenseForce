import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"

import "util/mixin"
import "util/maths"

import "mixins/EventEmitter"
import "mixins/StaticEventEmitter"

import "Cdf"

import "scenes/BaseScene"
import "scenes/MainMenuScene"
import "scenes/GameplayScene"
import "scenes/TestScene"

import "objects/enemySpawner/EnemySpawner"
import "objects/rocket/Rocket"
import "objects/rocket/RocketExhaust"
import "objects/rocketSilo/RocketSilo"
import "objects/scenePresenter/ScenePresenter"


local playdate <const> = playdate

Cdf.init()

playdate.update = function()
	Cdf.update()
end
