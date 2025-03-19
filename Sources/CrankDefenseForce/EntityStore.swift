class EntityStore {
	private var entities: [BaseEntity] = []
	
	var entityCount: Int {
		return entities.count
	}
	
	func update() {
		for entity in self.entities {
			entity.update()
		}
	}
	
	func lateUpdate() {
		for entity in self.entities {
			entity.lateUpdate()
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
	
	func get(_ entityId: Int) -> BaseEntity? {
		return self.entities.first {
			$0.id == entityId
		}
	}
	
	// TODO: iterate entities?
}
