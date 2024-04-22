import "CoreLibs/animation"
import "CoreLibs/graphics"
import "CoreLibs/math"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"

import "util/collision"
import "util/maths"
import "util/mixin"
import "util/string"
import "util/text"

import "mixins/EventEmitter"
import "mixins/StaticEventEmitter"

import "Cdf"

import "scenes/BaseScene"
import "scenes/MainMenuScene"
import "scenes/GameplayScene"
import "scenes/TestScene"
import "scenes/HowToPlayScene"
import "scenes/AboutScene"

import "objects/city/City"
import "objects/enemySpawner/EnemySpawner"
import "objects/explosion/Explosion"
import "objects/gameResults/GameResults"
import "objects/rocket/Rocket"
import "objects/rocket/RocketExhaust"
import "objects/rocketController/RocketController"
import "objects/rocketSilo/RocketSilo"
import "objects/scenePresenter/ScenePresenter"
import "objects/scorekeeper/Scorekeeper"

local playdate <const> = playdate

Cdf.init()

playdate.update = function()
	Cdf.update()
end
