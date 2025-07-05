import PlaydateKit



class BaseEntity {
	let id: Int
	
	var entityStorePtr: Int

	private static nonisolated(unsafe) var nextEntityId: Int = 1

	var entityStore: EntityStore {
		return unsafeBitCast(entityStorePtr, to: EntityStore.self)
	}
	
	@discardableResult init(_ entityStore: EntityStore) {
		self.entityStorePtr = unsafeBitCast(entityStore, to: Int.self)
		self.id = BaseEntity.nextEntityId
		BaseEntity.nextEntityId += 1
		entityStore.add(self)
	}
	
	func update() {
		
	}
	
	func lateUpdate() {
		
	}

	func beforeRemove() {

	}
}
