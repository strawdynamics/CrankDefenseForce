import PlaydateKit

class PowerUp: BaseEntity {
	nonisolated(unsafe) static let powerUpsBitmapTable = try! Graphics.BitmapTable(path: "powerUps.png")
	
	enum PowerUpType {
		case none
		case pauseEnemies
		case repairCity
		case destroyEnemies
	}
	
	struct Config {
		let position: Point
		let type: PowerUpType
		let entityStore: EntityStore
	}
	
	class PowerUpSprite: Sprite.Sprite {
		let type: PowerUpType
		
		var onCollect: (() -> Void)?
		
		init(type: PowerUpType) {
			self.type = type
		}
		
		func collect() {
			onCollect?()
		}
	}
	
	struct CollectEventPayload {
		var type: PowerUpType
	}
	struct CollectEvent: EventProtocol {
		typealias Payload = CollectEventPayload
	}
	nonisolated(unsafe) static var collectEmitter = EventEmitter<CollectEvent>()
	
	let type: PowerUpType
	
	let sprite: PowerUpSprite
	
	init(_ config: Config) {
		type = config.type
		
		sprite = PowerUpSprite(type: type)
		
		super.init(config.entityStore)
		
		sprite.onCollect = collect
		
		let size: Float = 16
		
		sprite.zIndex = 90
		sprite.position = config.position
		sprite.setSize(width: size, height: size)
		sprite.collideRect = Rect(x: 0, y: 0, width: size, height: size)
		// TODO: Set image based on type
		sprite.addToDisplayList()
	}
	
	func collect() {
		Self.collectEmitter.emit(CollectEventPayload(type: type))
		entityStore.remove(self)
	}
}
