class('EventEmitter').extends()

function EventEmitter:_initEventEmitter()
	if self._eeInitialized then
		return
	end

	self._eeHandlers = {}
	self._eeInitialized = true
end

function EventEmitter:_emit(eventName, payload)
	self:_initEventEmitter()

	if self._eeHandlers[eventName] == nil then
		return
	end

	for i, handler in ipairs(self._eeHandlers[eventName]) do
		handler(self, payload)
	end
end

function EventEmitter:on(eventName, fn)
	self:_initEventEmitter()

	if self._eeHandlers[eventName] == nil then
		self._eeHandlers[eventName] = {}
	end

	table.insert(self._eeHandlers[eventName], fn)
end

function EventEmitter:off(eventName, fn)
	self:_initEventEmitter()

	if self._eeHandlers[eventName] == nil then
		return
	end

	-- NOTE: table.indexOfElement does not work with functions
	local indexToRemove = nil
	for i, handler in ipairs(self._eeHandlers[eventName]) do
		if fn == handler then
			indexToRemove = i
			break
		end
	end

	if indexToRemove ~= nil then
		table.remove(self._eeHandlers[eventName], indexToRemove)
	end
end
