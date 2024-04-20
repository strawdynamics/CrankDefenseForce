local playdate <const> = playdate

--- Abstract class
class('BaseScene').extends()
local BaseScene <const> = BaseScene

--- Typical constructor, called when scene object is created
function BaseScene:init()
	--
end

--- Called each frame
function BaseScene:update()
	--
end

--- Called when transition to this scene begins
function BaseScene:enter()
	-- Animate
end

--- Called when transition to this scene is complete
function BaseScene:start()
	-- Begin handling input
end

--- Called when transition away from this scene begins
function BaseScene:exit()
	-- Stop handling input
end

--- Called when transition away from this scene is complete
function BaseScene:finish()
	--
end
