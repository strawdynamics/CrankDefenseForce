local playdate <const> = playdate
local gfx <const> = playdate.graphics

local Cdf <const> = Cdf

class('ScenePresenter').extends()
local ScenePresenter <const> = ScenePresenter

local EXIT_DURATION <const> = 0.5
local ENTER_DURATION <const> = 0.5

function ScenePresenter:init()
	self.newSceneClass = nil
	self.isExiting = false
	self.isEntering = false
	self.exitingTime = 0
	self.enteringTime = 0

	self.currentScene = MainMenuScene()

	self.currentScene:enter()
	self.currentScene:start()
end

function ScenePresenter:changeScene(newSceneClass)
	-- Store for later
	self.newSceneClass = newSceneClass

	self.currentScene:exit()
	self.isExiting = true
	self.exitingTime = 0
end

function ScenePresenter:update()
	--
	self.currentScene:update()

	if self.isExiting then
		self:_updateExit()
	elseif self.isEntering then
		self:_updateEnter()
	end
end

function ScenePresenter:_updateExit()
	self.exitingTime += Cdf.deltaTime

	gfx.pushContext()
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, 0, 400 * (self.exitingTime / EXIT_DURATION), 240)
	gfx.popContext()

	if self.exitingTime >= EXIT_DURATION then
		self.isExiting = false
		self.isEntering = true
		self.enteringTime = 0

		self.currentScene:finish()

		self.currentScene = self.newSceneClass()
		self.currentScene:enter()
	end
end

function ScenePresenter:_updateEnter()
	self.enteringTime += Cdf.deltaTime

	gfx.pushContext()
	gfx.setColor(gfx.kColorBlack)
	-- FIXME: Magic numbers
	local width = 400 * (1 - (self.enteringTime / ENTER_DURATION))
	gfx.fillRect(400 - width, 0, width, 240)
	gfx.popContext()

	if self.enteringTime >= ENTER_DURATION then
		self.isEntering = false
		self.currentScene:start()
	end
end
