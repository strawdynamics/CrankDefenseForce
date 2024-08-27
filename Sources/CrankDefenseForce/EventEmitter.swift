//
//  EventEmitter.swift
//
//
//  Created by Paul Straw on 8/26/24.
//

protocol EventProtocol {
		associatedtype Payload
}

struct EventEmitter<Event: EventProtocol> {
	private var handlers: [Int: (Event.Payload) -> Void] = [:]
	private var lastId: Int = 0
	
	private mutating func identifier(for event: Event) -> ObjectIdentifier {
			return ObjectIdentifier(Event.self)
	}
	
	mutating func emit(_ payload: Event.Payload) {
			handlers.forEach { _, handler in
					handler(payload)
			}
	}
	
	mutating func on(_ handler: @escaping (Event.Payload) -> Void) -> Int {
			lastId += 1
			handlers[lastId] = handler
			return lastId
	}
	
	mutating func off(_ handlerId: Int) {
			handlers.removeValue(forKey: handlerId)
	}
	
	mutating func reset() {
		self.handlers = [:]
	}
}
