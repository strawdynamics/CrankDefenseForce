nonisolated(unsafe) var nextEntityId: Int = 1

class BaseEntity {
	let id: Int
	
	var entityStorePtr: Int
	
	var entityStore: EntityStore {
		return unsafeBitCast(entityStorePtr, to: EntityStore.self)
	}
	
	@discardableResult init(_ entityStore: EntityStore) {
		self.entityStorePtr = unsafeBitCast(entityStore, to: Int.self)
		self.id = nextEntityId
		nextEntityId += 1
		entityStore.add(self)
	}
	
	func update() {
		
	}
	
	func lateUpdate() {
		
	}

	func beforeRemove() {

	}
}
 
