import PlaydateKit

class PowerUp: BaseEntity {
	nonisolated(unsafe) static let noneBitmapTable = try! Graphics.BitmapTable(path: "entities/PowerUp/none")
	nonisolated(unsafe) static let pauseEnemiesBitmapTable = try! Graphics.BitmapTable(path: "entities/PowerUp/pauseEnemies")
	nonisolated(unsafe) static let repairBuildingBitmapTable = try! Graphics.BitmapTable(path: "entities/PowerUp/repairBuilding")

	enum PowerUpType {
		case none
		case pauseEnemies
		case repairBuilding
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
		var position: Point
	}
	struct CollectEvent: EventProtocol {
		typealias Payload = CollectEventPayload
	}
	nonisolated(unsafe) static var collectEmitter = EventEmitter<CollectEvent>()

	private var frameAnimator: Animator<Float>

	private var collected = false

	private var bitmapTable: Graphics.BitmapTable

	let type: PowerUpType
	
	let sprite: PowerUpSprite
	
	init(_ config: Config) {
		type = config.type
		
		sprite = PowerUpSprite(type: type)

		frameAnimator = Animator(Animator.Config(
			duration: 1.2,
			startValue: 0.0,
			endValue: 10.0,
			easingFn: EasingFn.basic(Ease.linear),
			loopMode: .loop,
		))

		switch type {
		case .pauseEnemies:
			bitmapTable = Self.pauseEnemiesBitmapTable
		case .repairBuilding:
			bitmapTable = Self.repairBuildingBitmapTable
		default:
			bitmapTable = Self.noneBitmapTable
		}

		super.init(config.entityStore)
		
		sprite.onCollect = collect
		
		let size: Float = 18

		sprite.zIndex = 90
		sprite.image = bitmapTable[0]!
		sprite.moveTo(config.position)
		sprite.collideRect = Rect(x: 0, y: 0, width: size, height: size)
		sprite.addToDisplayList()
	}

	override func update() {
		frameAnimator.update()
		let animFrame = Int(frameAnimator.currentValue.rounded().truncatingRemainder(dividingBy: 10))
		sprite.image = bitmapTable[animFrame]
	}

	func collect() {
		if collected {
			return
		}
		collected = true

		Self.collectEmitter.emit(CollectEventPayload(
			type: type,
			position: sprite.position
		))

		entityStore.remove(self)
	}

	override func beforeRemove() {
		// Free parent after collect (no `weak`!)
		sprite.onCollect = nil
	}
}
