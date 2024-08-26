//
//  BaseEntity.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

nonisolated(unsafe) var nextEntityId: Int = 1

class BaseEntity {
	public let id: Int
	
	var entityStore: EntityStore?
	
	init(entityStore: EntityStore) {
		self.entityStore = entityStore
		self.id = nextEntityId
		nextEntityId += 1
	}
	
	func update() {
		
	}
	
	func destroy() {
		self.entityStore = nil
	}
}
