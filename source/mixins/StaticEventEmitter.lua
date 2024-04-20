class('StaticEventEmitter').extends()
local StaticEventEmitter <const> = StaticEventEmitter

function StaticEventEmitter._initStaticEventEmitter()
  if StaticEventEmitter._sEeInitialized then
    return
  end

  StaticEventEmitter._sEeHandlers = {}
  StaticEventEmitter._sEeInitialized = true
end

function StaticEventEmitter._staticEmit(eventName, obj, payload)
  StaticEventEmitter._initStaticEventEmitter()

  if StaticEventEmitter._sEeHandlers[eventName] == nil then
    return
  end

  for i, handler in ipairs(StaticEventEmitter._sEeHandlers[eventName]) do
    handler(obj, payload)
  end
end

function StaticEventEmitter.staticOn(eventName, fn)
  StaticEventEmitter._initStaticEventEmitter()

  if StaticEventEmitter._sEeHandlers[eventName] == nil then
    StaticEventEmitter._sEeHandlers[eventName] = {}
  end

  table.insert(StaticEventEmitter._sEeHandlers[eventName], fn)
end

function StaticEventEmitter.staticOff(eventName, fn)
  StaticEventEmitter._initStaticEventEmitter()

  if StaticEventEmitter._sEeHandlers[eventName] == nil then
    return
  end

  -- NOTE: table.indexOfElement does not work with functions
  local indexToRemove = nil
  for i, handler in ipairs(StaticEventEmitter._sEeHandlers[eventName]) do
    if fn == handler then
      indexToRemove = i
      break
    end
  end

  if indexToRemove ~= nil then
    table.remove(StaticEventEmitter._sEeHandlers[eventName], indexToRemove)
  end
end
