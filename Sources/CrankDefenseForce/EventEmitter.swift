protocol EventProtocol {
	associatedtype Payload
}

class EventEmitter<Event: EventProtocol> {
	private var handlers: [Int: (Event.Payload) -> Void] = [:]
	private var lastId: Int = 0
	
	func emit(_ payload: Event.Payload) {
		handlers.forEach { _, handler in
			handler(payload)
		}
	}
	
	func on(_ handler: @escaping (Event.Payload) -> Void) -> Int {
		lastId += 1
		handlers[lastId] = handler
		return lastId
	}
	
	func off(_ handlerId: Int) {
		handlers.removeValue(forKey: handlerId)
	}
	
	func reset() {
		self.handlers = [:]
	}
}
