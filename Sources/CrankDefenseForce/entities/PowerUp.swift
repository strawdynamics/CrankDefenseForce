import PlaydateKit

class PowerUp: BaseEntity {
	nonisolated(unsafe) static let pauseEnemiesBitmapTable = try! Graphics.BitmapTable(path: "entities/PowerUp/pauseEnemies")
	
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
		var position: Point
	}
	struct CollectEvent: EventProtocol {
		typealias Payload = CollectEventPayload
	}
	nonisolated(unsafe) static var collectEmitter = EventEmitter<CollectEvent>()

	private var frameAnimator: Animator<Float>

	private var collected = false

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

		super.init(config.entityStore)
		
		sprite.onCollect = collect
		
		let size: Float = 18

		sprite.zIndex = 90
		sprite.position = config.position
		sprite.setSize(width: size, height: size)
		sprite.collideRect = Rect(x: 0, y: 0, width: size, height: size)
		sprite.image = Self.pauseEnemiesBitmapTable[0]!
		sprite.addToDisplayList()
	}

	override func update() {
		frameAnimator.update()
		let animFrame = Int(frameAnimator.currentValue.rounded().truncatingRemainder(dividingBy: 10))
		sprite.image = Self.pauseEnemiesBitmapTable[animFrame]
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
