class EntityStore {
	public static nonisolated(unsafe) var instance: EntityStore? = nil

	private var entities: [BaseEntity] = []

	init() {
		Self.instance = self
	}

	deinit {
		self.entities.forEach {
			$0.beforeRemove()
		}
	}

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
			let shouldRemove = $0.id == entity.id

			if shouldRemove {
				$0.beforeRemove()
			}

			return shouldRemove
		}
	}

	func get(_ entityId: Int) -> BaseEntity? {
		return self.entities.first {
			$0.id == entityId
		}
	}
}
