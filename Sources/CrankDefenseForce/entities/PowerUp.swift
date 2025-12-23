import PlaydateKit

class PowerUp: BaseEntity, Movable, Toggleable {
	nonisolated(unsafe) static let noneBitmapTable = try! Graphics.BitmapTable(
		path: "entities/PowerUp/none")
	nonisolated(unsafe) static let pauseEnemiesBitmapTable = try! Graphics.BitmapTable(
		path: "entities/PowerUp/pauseEnemies")
	nonisolated(unsafe) static let repairBuildingBitmapTable = try! Graphics.BitmapTable(
		path: "entities/PowerUp/repairBuilding")
	nonisolated(unsafe) static let destroyEnemiesBitmapTable = try! Graphics.BitmapTable(
		path: "entities/PowerUp/destroyEnemies")

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

	private var collisionInitialized = false

	init(_ config: Config) {
		type = config.type

		sprite = PowerUpSprite(type: type)

		frameAnimator = Animator(
			Animator.Config(
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
		case .destroyEnemies:
			bitmapTable = Self.destroyEnemiesBitmapTable
		default:
			bitmapTable = Self.noneBitmapTable
		}

		super.init(config.entityStore)

		sprite.onCollect = collect

		sprite.zIndex = 90
		sprite.image = bitmapTable[0]!
		sprite.moveTo(config.position)

		sprite.addToDisplayList()
	}

	func moveTo(position: PlaydateKit.Point) {
		sprite.moveTo(position)
	}

	override func update() {
		if !collisionInitialized {
			initCollision()
		}

		frameAnimator.update()
		let animFrame = Int(frameAnimator.currentValue.rounded().truncatingRemainder(dividingBy: 10))
		sprite.image = bitmapTable[animFrame]
	}

	func collect() {
		if collected {
			return
		}
		collected = true

		Self.collectEmitter.emit(
			CollectEventPayload(
				type: type,
				position: sprite.position
			))

		switch type {
		case .pauseEnemies:
			Sfx.instance.play(.pauseEnemies)
		case .repairBuilding:
			Sfx.instance.play(.repairBuilding)
		default:
			()
		}

		entityStore.remove(self)
	}

	func initCollision() {
		collisionInitialized = true

		let size: Float = 18
		sprite.collideRect = Rect(x: 0, y: 0, width: size, height: size)
	}

	override func beforeRemove() {
		// Free parent after collect (no `weak`!)
		sprite.onCollect = nil
	}

	func show() {
		sprite.addToDisplayList()
	}

	func hide() {
		sprite.removeFromDisplayList()
	}
}
