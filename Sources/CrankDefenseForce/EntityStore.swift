//
//  EntityStore.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

class EntityStore {
	var entities: [BaseEntity] = []
	
	func update() {
		for entity in self.entities {
			entity.update()
		}
	}
	
	func add(_ entity: BaseEntity) {
		self.entities.append(entity)
	}
	
	func remove(_ entity: BaseEntity) {
		self.entities.removeAll {
			$0.id == entity.id
		}
	}
	
	func destroy() {
		for entity in self.entities {
			entity.destroy()
		}
	}
}
